Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5726 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751447AbdBXWUL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:11 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 11/17] SUNRPC AUTH_GSS free assertions
Date: Fri, 24 Feb 2017 17:19:47 -0500
Message-ID: <20170224221953.5502-12-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 49 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 47 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0b925fb..5daab12 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -59,6 +59,7 @@
 static int gss3_create_label(struct rpc_cred *cred, int gss_vers);
 static struct gss3_assert *gss3_use_child_handle(struct gss_cl_ctx *ctx);
 static struct gss3_assert *gss3_match_label(struct gss3_assert_list *in);
+static void gss3_free_assertions(struct gss3_assert_list *in);
 
 static const struct rpc_authops authgss_ops;
 
@@ -1275,11 +1276,10 @@ gss_destroying_context(struct rpc_cred *cred)
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
 
@@ -1657,6 +1657,50 @@ gss3_insert_assertion(struct gss3_assert_list *alist, struct gss3_assert *g3a)
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
+	struct gss3_assert *found, *tmp;
+	LIST_HEAD(freelist);
+
+	rcu_read_lock();
+	spin_lock(&in->assert_lock);
+	list_for_each_entry_rcu(found, &in->assert_list, gss3_list) {
+		list_del_rcu(&found->gss3_list);
+		list_add(&found->gss3_list, &freelist);
+	}
+	rcu_read_unlock();
+	spin_unlock(&in->assert_lock);
+	synchronize_rcu();
+
+	list_for_each_entry_safe(found, tmp, &freelist, gss3_list) {
+		list_del(&found->gss3_list);
+
+		/* allocated in gss3_dec_label */
+		kfree(found->gss3_handle.data);
+
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
+		kfree(found);
+	}
+}
+
 static struct gss3_assert *
 gss3_match_label(struct gss3_assert_list *in)
 {
@@ -1821,6 +1865,7 @@ gss3_dec_create(struct rpc_rqst *req, struct xdr_stream *xdr,
 	if (unlikely(!p))
 		goto out_overflow;
 
+	/* freed in gss3_free_assertions */
 	g3cr->cr_handle = kmemdup(p, g3cr->cr_hlen, GFP_KERNEL);
 	if (!g3cr->cr_handle)
 		goto out_err;
-- 
2.9.3

