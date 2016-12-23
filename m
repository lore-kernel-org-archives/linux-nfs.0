Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:4535 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756581AbcLWQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:31 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 08/16] SUNRPC AUTH_GSS store and use gss3 label assertion
Date: Fri, 23 Dec 2016 11:04:20 -0500
Message-ID: <1482509068-24516-9-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Store gss3 assertions in the parent gss_cl_ctx. Choose to use a child
or parent context handle in gss_marshal and in gss3_reply_verifier.

Note: Need to add a test for full mode labeling. Current code only tests
for the GSS version == 3 and selinx enabled.

In gss_cred_set_ctx() after assigning a new gss context to a credential,
call gss3_create_label which will kick off an RPCSED_GSS_CREATE for the
thread's label if selinux is enabled.

In gss_match(), check if the current threads SeLinux label (sid)  has
a matching label assertion. If not, kick off an RPCSEC_GSS_CREATE for
the thread's label.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h    |   6 +++
 include/linux/sunrpc/gss_api.h     |  10 ++++
 include/linux/sunrpc/svcauth_gss.h |   1 +
 net/sunrpc/auth_gss/auth_gss.c     | 105 ++++++++++++++++++++++++++++++++++---
 net/sunrpc/auth_gss/svcauth_gss.c  |   2 +-
 5 files changed, 117 insertions(+), 7 deletions(-)

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
index 68ec78c..bbcb100 100644
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
+	struct xdr_netobj	gss3_handle;
+	u32			gss3_num;
+	struct gss3_assertion_u	*gss3_assertion;
+};
+
 /* The mechanism-independent gss-api context: */
 struct gss_ctx {
 	struct gss_api_mech	*mech_type;
diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 726aff1..af45bff 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -22,6 +22,7 @@
 void gss_svc_shutdown_net(struct net *net);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 u32 svcauth_gss_flavor(struct auth_domain *dom);
+int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e39c1af..de0c9ef 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -57,6 +57,8 @@
 #include "../netns.h"
 
 static int gss3_create_label(struct rpc_cred *cred);
+static struct gss3_assert *gss3_use_child_handle(struct gss_cl_ctx *ctx);
+static struct gss3_assert *gss3_match_label(struct gss3_assert_list *in);
 
 static const struct rpc_authops authgss_ops;
 
@@ -206,6 +208,8 @@ struct gss_auth {
 		ctx->gc_seq = 1;	/* NetApp 6.4R1 doesn't accept seq. no. 0 */
 		spin_lock_init(&ctx->gc_seq_lock);
 		atomic_set(&ctx->count,1);
+		INIT_LIST_HEAD(&ctx->gc_alist.assert_list);
+		spin_lock_init(&ctx->gc_alist.assert_lock);
 	}
 	return ctx;
 }
@@ -1457,6 +1461,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 	struct gss_cl_ctx *ctx;
+	struct gss3_assert *g3a;
 	int ret;
 
 	if (test_bit(RPCAUTH_CRED_NEW, &rc->cr_flags))
@@ -1494,6 +1499,13 @@ static void gss_pipe_free(struct gss_pipe *p)
 		/* tell NFS layer that key will expire soon */
 		set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
 	}
+	if (ret) {
+		ctx = gss_cred_get_ctx(rc);
+		g3a = gss3_match_label(&ctx->gc_alist);
+		if (!g3a)
+			gss3_create_label(rc);
+		gss_put_ctx(ctx);
+	}
 	return ret;
 }
 
@@ -1514,6 +1526,7 @@ static void gss_pipe_free(struct gss_pipe *p)
 	struct xdr_netobj mic;
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
+	struct gss3_assert *g3a;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
 
@@ -1528,7 +1541,11 @@ static void gss_pipe_free(struct gss_pipe *p)
 	*p++ = htonl((u32)ctx->gc_proc);
 	*p++ = htonl((u32)req->rq_seqno);
 	*p++ = htonl((u32)gss_cred->gc_service);
-	p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
+	g3a = gss3_use_child_handle(ctx);
+	if (g3a)
+		p = xdr_encode_netobj(p, &g3a->gss3_handle);
+	else
+		p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
 	*cred_len = htonl((p - (cred_len + 1)) << 2);
 
 	/* We compute the checksum for the verifier over the xdr-encoded bytes
@@ -1597,6 +1614,73 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
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
+static struct gss3_assert *
+gss3_match_label(struct gss3_assert_list *in)
+{
+	struct gss3_assert *found;
+	struct xdr_netobj label;
+
+	/* Need a Full Mode stanza in /etc/selinux/config to check */
+	if (!selinux_is_enabled())
+		return NULL;
+
+	/* grab the current threads subject label */
+	security_current_sid_to_context((char **)&label.data, &label.len);
+	rcu_read_lock();
+	list_for_each_entry_rcu(found, &in->assert_list, gss3_list) {
+		struct gss3_label *gl;
+
+		if (found->gss3_assertion->au_type != GSS3_LABEL)
+			continue;
+		gl = &found->gss3_assertion->u.au_label;
+		if (netobj_equal(&gl->la_label, &label))
+			goto out;
+	}
+	found = NULL;
+out:
+	rcu_read_lock();
+	return found;
+}
+
+static struct gss3_assert *
+gss3_use_child_handle(struct gss_cl_ctx *ctx)
+{
+	struct gss3_assert *g3a = NULL;
+
+	if (ctx->gc_v == RPC_GSS3_VERSION && ctx->gc_proc == RPC_GSS_PROC_DATA)
+		g3a = gss3_match_label(&ctx->gc_alist);
+	return g3a;
+}
+
+/**
  * GSS3_createargs_maxsz and GSS3_createres_maxsz
  * include no rgss3_assertion_u payload.
  *
@@ -1691,10 +1775,6 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	gl->la_label.data = kmemdup(p, gl->la_label.len, GFP_KERNEL);
 	if (!gl->la_label.data)
 		goto out_free_assert;
-	/**
-	 * Note: need to store the assertion with the child handle
-	 * in the gss context cache.
-	 */
 
 	g3cr->cr_assertions = g3a;
 
@@ -1811,6 +1891,7 @@ struct rpc_procinfo gss3_label_assertion[] = {
 	};
 	struct gss3_create_args *cargs = NULL;
 	struct gss3_label *gl;
+	struct gss3_assert *g3a = NULL;
 	int ret = -EINVAL;
 
 	if (!ctx)
@@ -1861,6 +1942,13 @@ struct rpc_procinfo gss3_label_assertion[] = {
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
 out_free_args:
@@ -1916,6 +2004,7 @@ struct rpc_procinfo gss3_label_assertion[] = {
 {
 	struct gss_cred *g_cred = container_of(cred, struct gss_cred, gc_base);
 	void	*gss3_buf = NULL;
+	struct gss3_assert *g3a;
 	__be32 *crlen, *ptr = NULL;
 	int len;
 
@@ -1942,7 +2031,11 @@ struct rpc_procinfo gss3_label_assertion[] = {
 	*ptr++ = htonl(ctx->gc_proc);
 	*ptr++ = *seq;
 	*ptr++ = htonl(g_cred->gc_service);
-	ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
+	g3a = gss3_use_child_handle(ctx);
+	if (g3a)
+		ptr = xdr_encode_netobj(ptr, &g3a->gss3_handle);
+	else
+		ptr = xdr_encode_netobj(ptr, &ctx->gc_wire_ctx);
 
 	/* backfill cred length */
 	*crlen = htonl((ptr - (crlen + 1)) << 2);
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 45662d7..edf71a0 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -63,7 +63,7 @@
  *
  */
 
-static int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b)
+int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b)
 {
 	return a->len == b->len && 0 == memcmp(a->data, b->data, a->len);
 }
-- 
1.8.3.1

