Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:6612 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966263AbcLWQGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:45 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 09/16] SUNRPC AUTH_GSS free assertions
Date: Fri, 23 Dec 2016 11:04:21 -0500
Message-ID: <1482509068-24516-10-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 40 ++++++++++++++++++++++++++++++++++++++--
 1 file changed, 38 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index de0c9ef..8445ff4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -59,6 +59,7 @@
 static int gss3_create_label(struct rpc_cred *cred);
 static struct gss3_assert *gss3_use_child_handle(struct gss_cl_ctx *ctx);
 static struct gss3_assert *gss3_match_label(struct gss3_assert_list *in);
+static void gss3_free_assertions(struct gss3_assert_list *in);
 
 static const struct rpc_authops authgss_ops;
 
@@ -1262,11 +1263,10 @@ static void gss_pipe_free(struct gss_pipe *p)
 static void
 gss_do_free_ctx(struct gss_cl_ctx *ctx)
 {
-	dprintk("RPC:       %s\n", __func__);
-
 	gss_delete_sec_context(&ctx->gc_gss_ctx);
 	kfree(ctx->gc_wire_ctx.data);
 	kfree(ctx->gc_acceptor.data);
+	gss3_free_assertions(&ctx->gc_alist);
 	kfree(ctx);
 }
 
@@ -1642,6 +1642,41 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	spin_unlock(&alist->assert_lock);
 }
 
+static void gss3_free_label(struct gss3_label *gl)
+{
+	kfree(gl->la_label.data);
+}
+
+/**
+ * Note: Currently, only support for one assertion so gss3_num always = 1
+ */
+static void gss3_free_assertions(struct gss3_assert_list *in)
+{
+	struct gss3_assert *found;
+
+	spin_lock(&in->assert_lock);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(found, &in->assert_list, gss3_list) {
+		list_del_rcu(&found->gss3_list);
+		/* allocated in gss3_dec_label */
+		kfree(found->gss3_handle.data);
+		/* gss3_num is always one for now */
+		switch (found->gss3_assertion->au_type) {
+		case GSS3_LABEL:
+			gss3_free_label(&found->gss3_assertion->u.au_label);
+			break;
+		case GSS3_PRIVS:
+		default:
+			pr_warn("RPC  %s Can't free unsupported au_type %d\n",
+				__func__, found->gss3_assertion->au_type);
+			return;
+		}
+	}
+	rcu_read_unlock();
+	spin_unlock(&in->assert_lock);
+}
+
 static struct gss3_assert *
 gss3_match_label(struct gss3_assert_list *in)
 {
@@ -1806,6 +1841,7 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	if (unlikely(!p))
 		goto out_overflow;
 
+	/* freed in gss3_free_assertions */
 	g3cr->cr_handle = kmemdup(p, g3cr->cr_hlen, GFP_KERNEL);
 	if (!g3cr->cr_handle)
 		goto out_err;
-- 
1.8.3.1

