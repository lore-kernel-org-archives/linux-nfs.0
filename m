Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5726 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751444AbdBXWUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:10 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 09/17] SUNRPC AUTH_GSS store GSS3 assertions in parent gss_cl_ctx
Date: Fri, 24 Feb 2017 17:19:45 -0500
Message-ID: <20170224221953.5502-10-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h |  6 ++++++
 include/linux/sunrpc/gss_api.h  | 10 ++++++++++
 net/sunrpc/auth_gss/auth_gss.c  | 39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index b2a5a61..7f7b378 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -63,6 +63,11 @@ struct rpc_gss_init_res {
 	struct xdr_netobj	gr_token;	/* token */
 };
 
+struct gss3_assert_list {
+	struct list_head	assert_list;
+	spinlock_t		assert_lock;
+};
+
 /* The gss_cl_ctx struct holds all the information the rpcsec_gss client
  * code needs to know about a single security context.  In particular,
  * gc_gss_ctx is the context handle that is used to do gss-api calls, while
@@ -80,6 +85,7 @@ struct gss_cl_ctx {
 	struct xdr_netobj	gc_acceptor;
 	u32			gc_win;
 	unsigned long		gc_expiry;
+	struct gss3_assert_list	gc_alist;
 	struct rcu_head		gc_rcu;
 };
 
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 68ec78c..c2c6354 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -17,6 +17,16 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/uio.h>
 
+/* one gss3 assertion plus associated child context handle
+ * XXX more than one assertion per child context?
+ */
+struct gss3_assert {
+	struct list_head	gss3_list;  /* per context list of assertions */
+	struct xdr_netobj	gss3_handle; /* child handle */
+	u32			gss3_num;  /* always one for now */
+	struct gss3_assertion_u	*gss3_assertion;
+};
+
 /* The mechanism-independent gss-api context: */
 struct gss_ctx {
 	struct gss_api_mech	*mech_type;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 98971cf..18b97a7 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -219,6 +219,8 @@ gss_alloc_context(void)
 		ctx->gc_seq = 1;	/* NetApp 6.4R1 doesn't accept seq. no. 0 */
 		spin_lock_init(&ctx->gc_seq_lock);
 		atomic_set(&ctx->count,1);
+		INIT_LIST_HEAD(&ctx->gc_alist.assert_list);
+		spin_lock_init(&ctx->gc_alist.assert_lock);
 	}
 	return ctx;
 }
@@ -1610,6 +1612,35 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 }
 
 /**
+ * The gss3_handle and gss3_assertions are allocated in gss3_dec_label
+ */
+static struct gss3_assert *
+gss3_alloc_init_assertion(struct gss3_create_res *cres)
+{
+	struct gss3_assert *ret;
+
+	ret = kzalloc(sizeof(*ret), GFP_NOFS);
+	if (!ret)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&ret->gss3_list);
+	ret->gss3_handle.len = cres->cr_hlen;
+	ret->gss3_handle.data = cres->cr_handle;
+	ret->gss3_num = cres->cr_num;
+	ret->gss3_assertion = cres->cr_assertions;
+	return ret;
+}
+
+void
+gss3_insert_assertion(struct gss3_assert_list *alist, struct gss3_assert *g3a)
+{
+	spin_lock(&alist->assert_lock);
+	/* list_add_tail_rcu(new,head) inserts new before head */
+	list_add_tail_rcu(&g3a->gss3_list, &alist->assert_list);
+	spin_unlock(&alist->assert_lock);
+}
+
+/**
  * GSS3_createargs_maxsz and GSS3_createres_maxsz
  * include no rgss3_assertion_u payload.
  */
@@ -1820,6 +1851,7 @@ gss3_proc_create(struct rpc_cred *cred, struct gss3_assertion_u *asserts,
 		.cr_mp_auth = 0,
 	};
 	struct gss3_create_args *cargs = NULL;
+	struct gss3_assert *g3a = NULL;
 	int ret = -EINVAL;
 
 	if (!ctx || !asserts)
@@ -1857,6 +1889,13 @@ gss3_proc_create(struct rpc_cred *cred, struct gss3_assertion_u *asserts,
 	}
 	rpc_put_task(task);
 
+	g3a = gss3_alloc_init_assertion(&cres);
+	if (IS_ERR(g3a)) {
+		ret = PTR_ERR(task);
+		goto out_free_assert;
+	}
+	gss3_insert_assertion(&ctx->gc_alist, g3a);
+
 out_free_assert:
 	kfree(cargs->ca_assertions);
 	kfree(cargs);
-- 
2.9.3

