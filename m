Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52446 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752647AbdG1UW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:22:29 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 07/12] SUNRPC-AUTH_GSS gss3_free_assertions
Date: Fri, 28 Jul 2017 16:21:53 -0400
Message-ID: <1501273318-14200-8-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Upon GSS context destruction, Free all associated GSS3 child assertions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/gss_api.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c | 51 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 7e5da3a..4e02204 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -19,6 +19,7 @@
 
 struct gss3_assert {
 	struct list_head	gss3_list;  /* per context list of assertions */
+	struct rcu_head		gss3_rcu;
 	struct xdr_netobj	gss3_handle; /* child handle */
 	u32			gss3_num;  /* always one for now */
 	struct gss3_assertion_u	*gss3_assertion;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 1014521..0df1938 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -60,6 +60,7 @@
 static struct gss3_assert *gss3_use_child_handle(struct rpc_cred *cred,
 						 struct gss_cl_ctx *ctx);
 static struct gss3_assert *gss3_match_label(struct gss3_assert_list *in);
+static void gss3_free_assertions(struct gss3_assert_list *in);
 
 static const struct rpc_authops authgss_ops;
 
@@ -130,8 +131,10 @@ struct gss_auth {
 static inline void
 gss_put_ctx(struct gss_cl_ctx *ctx)
 {
-	if (atomic_dec_and_test(&ctx->count))
+	if (atomic_dec_and_test(&ctx->count)) {
+		gss3_free_assertions(&ctx->gc_alist);
 		gss_free_ctx(ctx);
+	}
 }
 
 /* gss3_label_enabled:
@@ -1672,6 +1675,52 @@ static void gss3_free_label(struct gss3_label *gl)
 	kfree(gl->la_label.data);
 }
 
+static void
+gss3_free_assertion(struct gss3_assert *freeme)
+{
+	/* allocated in gss3_dec_create */
+	kfree(freeme->gss3_handle.data);
+
+	/* gss3_num is always one for now */
+	switch (freeme->gss3_assertion->au_type) {
+	case GSS3_LABEL:
+		gss3_free_label(&freeme->gss3_assertion->u.au_label);
+	break;
+	case GSS3_PRIVS:
+	default:
+		pr_warn("RPC  %s Can't free unsupported au_type %d\n",
+			__func__, freeme->gss3_assertion->au_type);
+		return;
+	}
+	kfree(freeme);
+}
+
+static void
+gss3_free_assert_callback(struct rcu_head *head)
+{
+	struct gss3_assert *g3a = container_of(head, struct gss3_assert,
+					       gss3_rcu);
+	gss3_free_assertion(g3a);
+}
+
+static void
+gss3_free_assert(struct gss3_assert *ap)
+{
+	call_rcu(&ap->gss3_rcu, gss3_free_assert_callback);
+}
+
+static void gss3_free_assertions(struct gss3_assert_list *in)
+{
+	struct gss3_assert *found;
+
+	list_for_each_entry_rcu(found, &in->assert_list, gss3_list) {
+		spin_lock(&in->assert_lock);
+		list_del_rcu(&found->gss3_list);
+		spin_unlock(&in->assert_lock);
+		gss3_free_assert(found);
+	}
+}
+
 static struct gss3_assert *
 gss3_match_label(struct gss3_assert_list *in)
 {
-- 
1.8.3.1

