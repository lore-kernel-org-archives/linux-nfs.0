Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:62496 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752505AbdG1UWI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:22:08 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 05/12] SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with label payload
Date: Fri, 28 Jul 2017 16:21:51 -0400
Message-ID: <1501273318-14200-6-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Declaration of GSS3 structures.
Determination of Full Mac labeling enabled. GSSv3 in use, SeLinux enabled,
and krb5i or krb5p in use.
Creation and xdr encoding an decoding of a gss3_label payload.
Generic gss3_proc_create that sends an RPC_GSS_PROC_CREATE operation with
any gss3 assertion payload.

Upon success, store the RPC_GSS_PROC_CREATE reply GSS3 assertions
in the parent gss_cl_ctx.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h |  59 ++++++
 include/linux/sunrpc/gss_api.h  |   7 +
 net/sunrpc/auth_gss/auth_gss.c  | 397 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 463 insertions(+)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index dbcdcc2..16b4f20 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -62,6 +62,11 @@ struct rpc_gss_init_res {
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
@@ -79,6 +84,7 @@ struct gss_cl_ctx {
 	struct xdr_netobj	gc_acceptor;
 	u32			gc_win;
 	unsigned long		gc_expiry;
+	struct gss3_assert_list	gc_alist;
 	struct rcu_head		gc_rcu;
 };
 
@@ -92,6 +98,59 @@ struct gss_cred {
 	unsigned long		gc_upcall_timestamp;
 };
 
+/** GSS3 */
+enum gss3_type {
+	GSS3_LABEL = 0,
+	GSS3_PRIVS = 1,
+};
+
+struct gss3_chan_binding {
+	u32	cb_len;
+	void	*cb_binding;
+};
+
+struct gss3_mp_auth {
+	u32	mp_handle_len;
+	void	*mp_handle;
+	u32	*mp_mic_len;
+	void	*mp_mic;	/* header mic */
+};
+
+struct gss3_label {
+	u32			la_lfs;
+	u32			la_pi;
+	struct xdr_netobj	la_label;
+};
+
+struct gss3_privs {
+	struct xdr_netobj	pr_name;
+	struct xdr_netobj	pr_data;
+};
+
+struct gss3_assertion_u {
+	u32	au_type;
+	union {
+		struct gss3_label	au_label;
+		struct gss3_privs	au_privs;
+	} u;
+};
+
+struct gss3_create_args {
+	struct gss3_mp_auth		*ca_mp_auth;
+	struct gss3_chan_binding	*ca_chan_bind;
+	u32			ca_num;
+	struct gss3_assertion_u	*ca_assertions;
+};
+
+struct gss3_create_res {
+	u32		cr_hlen;
+	void		*cr_handle;
+	struct gss3_mp_auth		*cr_mp_auth;
+	struct gss3_chan_binding	*cr_chan_bind;
+	u32			cr_num;
+	struct gss3_assertion_u	*cr_assertions;
+};
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_AUTH_GSS_H */
 
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 68ec78c..7e5da3a 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -17,6 +17,13 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/uio.h>
 
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
index 28c5491..46c0068 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -52,9 +52,12 @@
 #include <linux/sunrpc/gss_api.h>
 #include <linux/uaccess.h>
 #include <linux/hashtable.h>
+#include <linux/security.h>
 
 #include "../netns.h"
 
+static int gss3_create_label(struct rpc_cred *cred);
+
 static const struct rpc_authops authgss_ops;
 
 static const struct rpc_credops gss_credops;
@@ -128,6 +131,21 @@ struct gss_auth {
 		gss_free_ctx(ctx);
 }
 
+/* gss3_label_enabled:
+ * Called to determine if Full Mode Mandatory Access Control (MAC)
+ * over a GSS connection is desired.
+ *
+ * Note:
+ * Currently Full Mode MAC is assuemed if SeLinux is enabled and
+ * RPCSEC_GSS version 3 with KRB5i or KRB5p is in use.
+ */
+static inline bool
+gss3_label_assertion_is_enabled(u32 rpcsec_version, rpc_authflavor_t fl)
+{
+	return (rpcsec_version == RPC_GSS3_VERSION && selinux_is_enabled() &&
+		((fl == RPC_AUTH_GSS_KRB5I) || (fl == RPC_AUTH_GSS_KRB5P)));
+}
+
 /* gss_cred_set_ctx:
  * called by gss_upcall_callback and gss_create_upcall in order
  * to set the gss context. The actual exchange of an old context
@@ -145,6 +163,9 @@ struct gss_auth {
 	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	smp_mb__before_atomic();
 	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
+	if (gss3_label_assertion_is_enabled(ctx->gc_v,
+					    cred->cr_auth->au_flavor))
+		gss3_create_label(cred);
 }
 
 static const void *
@@ -201,6 +222,8 @@ struct gss_auth {
 		ctx->gc_seq = 1;	/* NetApp 6.4R1 doesn't accept seq. no. 0 */
 		spin_lock_init(&ctx->gc_seq_lock);
 		atomic_set(&ctx->count,1);
+		INIT_LIST_HEAD(&ctx->gc_alist.assert_list);
+		spin_lock_init(&ctx->gc_alist.assert_lock);
 	}
 	return ctx;
 }
@@ -1596,6 +1619,380 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	return 0;
 }
 
+/**
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
+static void gss3_free_label(struct gss3_label *gl)
+{
+	kfree(gl->la_label.data);
+}
+
+/**
+ * GSS3_createargs_maxsz and GSS3_createres_maxsz
+ * include no rgss3_assertion_u payload.
+ */
+#define GSS3_createargs_maxsz  (1 /* empty ca_mp_auth */ + \
+				1 /* empty ca_chan_bind */ + \
+				1 /* ca_num */ + \
+				1 /* au_type */)
+#define GSS3_createres_maxsz   (1 /* cr_hlen */ + \
+				XDR_QUADLEN(XDR_MAX_NETOBJ) /* cr_handle*/ + \
+				GSS3_createargs_maxsz)
+#define GSS3_labelargs_maxsz	(1 /* la_lfs */ + \
+				 1 /* la_pi */ + \
+				 1 /* la_label.len */ + \
+				 XDR_QUADLEN(XDR_MAX_NETOBJ) /* la_label */)
+#define GSS3_labelres_maxsz	GSS3_labelargs_maxsz
+
+static void
+gss3_enc_label(struct rpc_rqst *req, struct xdr_stream *xdr,
+	       const struct gss3_create_args *g3ca)
+{
+	struct gss3_label *gl;
+	int len;
+	__be32 *p;
+
+	gl = &g3ca->ca_assertions[0].u.au_label;
+
+	dprintk("RPC: %5u encoding GSSv3 label %s:%d\n", req->rq_task->tk_pid,
+		(char *)gl->la_label.data, gl->la_label.len);
+
+	len = 4 + 4 + (XDR_QUADLEN(gl->la_label.len) << 2) + 4;
+	p = xdr_reserve_space(xdr, len);
+	*p++ = cpu_to_be32(0); /* la_lfs */
+	*p++ = cpu_to_be32(0); /* la_pi */
+	p = xdr_encode_netobj(p, &gl->la_label);
+}
+
+static int
+gss3_dec_label(struct rpc_rqst *req, struct xdr_stream *xdr,
+	       struct gss3_create_res *g3cr)
+{
+	struct gss3_label *gl;
+	struct gss3_assertion_u *g3a;
+	__be32 *p;
+
+	/* Used to store assertion in parent gss_cl_ctx */
+	g3a = kzalloc(sizeof(*g3a), GFP_KERNEL);
+	if (!g3a)
+		goto out_err;
+
+	g3a->au_type = GSS3_LABEL;
+	gl = &g3a->u.au_label;
+
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	gl->la_lfs = be32_to_cpup(p++);
+	gl->la_pi = be32_to_cpup(p++);
+	gl->la_label.len = be32_to_cpup(p++);
+
+	p = xdr_inline_decode(xdr, gl->la_label.len);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	gl->la_label.data = kmemdup(p, gl->la_label.len, GFP_KERNEL);
+	if (!gl->la_label.data)
+		goto out_free_assert;
+
+	g3cr->cr_assertions = g3a;
+
+	return 0;
+
+out_free_assert:
+	kfree(g3a);
+out_err:
+	return -EIO;
+out_overflow:
+	pr_warn("RPC    %s End of receive buffer. Remaining len: %tu words.\n",
+		__func__, xdr->end - xdr->p);
+	goto out_free_assert;
+}
+
+static void
+gss3_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
+		const struct gss3_create_args *g3ca)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, GSS3_createargs_maxsz << 2);
+	*p++ = cpu_to_be32(0); /* NULL ca_mp_auth */
+	*p++ = cpu_to_be32(0); /* NULL ca_chan_bind */
+	*p++ = cpu_to_be32(g3ca->ca_num);
+	*p++ = cpu_to_be32(g3ca->ca_assertions->au_type);
+
+	switch (g3ca->ca_assertions->au_type) {
+	case GSS3_LABEL:
+		gss3_enc_label(req, xdr, g3ca);
+		break;
+	case GSS3_PRIVS:
+	default:
+		/* drop through to return */
+		pr_warn("RPC    Unsupported gss3 create assertion %d\n",
+			g3ca->ca_assertions->au_type);
+	}
+}
+
+static int
+gss3_dec_create(struct rpc_rqst *req, struct xdr_stream *xdr,
+		struct gss3_create_res *g3cr)
+{
+	u32 dummy, type;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	g3cr->cr_hlen = be32_to_cpup(p++);
+
+	p = xdr_inline_decode(xdr, g3cr->cr_hlen + 16);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	g3cr->cr_handle = kmemdup(p, g3cr->cr_hlen, GFP_KERNEL);
+	if (!g3cr->cr_handle)
+		goto out_err;
+
+	p += XDR_QUADLEN(g3cr->cr_hlen);
+
+	/* cr_mp_auth: not supported */
+	dummy = be32_to_cpup(p++);
+	if (dummy != 0) {
+		pr_warn("RPC    gss3 create cr_mp_auth not supported\n");
+		goto out_free_handle;
+	}
+
+	/* cr_chan_bind: not supported */
+	dummy = be32_to_cpup(p++);
+	if (dummy != 0) {
+		pr_warn("RPC    gss3 create cr_chan_bind not supported\n");
+		goto out_free_handle;
+	}
+
+	/* Support one assertion */
+	g3cr->cr_num = be32_to_cpup(p++);
+	if (g3cr->cr_num != 1) {
+		pr_warn("RPC    gss3 multiple assertions %d unspported\n",
+			g3cr->cr_num);
+		goto out_free_handle;
+	}
+
+	/* au_type */
+	type = be32_to_cpup(p++);
+	switch (type) {
+	case GSS3_LABEL:
+		if (gss3_dec_label(req, xdr, g3cr) != 0)
+			goto out_free_handle;
+		break;
+	case GSS3_PRIVS:
+	default:
+		pr_warn("RPC    Unsupported gss3 create assertion %d\n", type);
+		goto out_free_handle;
+	}
+	return 0;
+
+out_free_handle:
+	kfree(g3cr->cr_handle);
+out_err:
+	return -EIO;
+out_overflow:
+	pr_warn("RPC    %s End of receive buffer. Remaining len: %tu words.\n",
+		__func__, xdr->end - xdr->p);
+	goto out_err;
+}
+
+#define RPC_PROC_NULL 0
+
+#define GSS3_create_args_max	(GSS3_createargs_maxsz + GSS3_labelargs_maxsz)
+#define GSS3_create_res_max	(GSS3_createres_maxsz + GSS3_labelres_maxsz)
+
+struct rpc_procinfo gss3_ops[] = {
+	[RPC_GSS_PROC_CREATE] = {
+		.p_proc		= RPC_PROC_NULL,
+		.p_encode	= (kxdreproc_t)gss3_enc_create,
+		.p_decode	= (kxdrdproc_t)gss3_dec_create,
+		.p_arglen	= GSS3_create_args_max,
+		.p_replen	= GSS3_create_res_max,
+		.p_statidx	= RPC_GSS_PROC_CREATE,
+		.p_timer	= 0,
+		.p_name		= "GSS_PROC_CREATE",
+	},
+};
+
+/**
+ * Default callback for async GSS RPC calls
+ * NOTE: same as rpc_default_ops()
+ */
+static void
+gss_rpc_default_callback(struct rpc_task *task, void *data)
+{
+}
+
+static const struct rpc_call_ops gss_rpc_default_ops = {
+	.rpc_call_done = gss_rpc_default_callback,
+};
+
+/**
+ * RPC_GSS_PROC_CREATE operation
+ *    Return the resultant child context handle or an error.
+ *
+ * @cred:       the credential holding the parent gss3 context
+ * @asserts:    assertions for RPC_GSS_PROC_CREATE args, allocated
+ *              and freed by caller on success or failure of
+ *              gss3_proc_create.
+ * @numasserts: currently only one assert supported.
+ *
+ * Notes:
+ *    1) Spec says we MUST use integrity or privacy security service.
+ *       First pass; use rpc_gss_svc_none.
+ *    2) Upon success, the returned list of assertions established on the
+ *       server is saved in the parent context assertion list
+ */
+static struct xdr_netobj *
+gss3_proc_create(struct rpc_cred *cred, struct gss3_assertion_u *asserts,
+		 int numasserts)
+{
+	struct gss_auth *gss_auth = container_of(cred->cr_auth, struct gss_auth,
+						 rpc_auth);
+	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
+	struct rpc_task *task;
+	struct gss3_create_res cres = {
+		.cr_mp_auth = 0,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &gss3_ops[RPC_GSS_PROC_CREATE],
+		.rpc_resp = &cres,
+		.rpc_cred = cred,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = gss_auth->client,
+		.rpc_message = &msg,
+		.callback_ops = &gss_rpc_default_ops,
+		.flags = 0,
+	};
+	struct gss3_create_args *cargs = NULL;
+	struct gss3_assert *g3a = NULL;
+	struct xdr_netobj *ret = ERR_PTR(-EINVAL);
+
+	if (!ctx || !asserts)
+		goto out;
+	/**
+	 * Take a reference to ensure the cred sticks around as we create
+	 * a child context
+	 */
+	get_rpccred(cred);
+
+	ret = ERR_PTR(-ENOMEM);
+	cargs = kzalloc(sizeof(*cargs), GFP_NOFS);
+	if (!cargs)
+		goto out_err;
+
+	/* args asserts allocated and freed by caller */
+	cargs->ca_assertions = asserts;
+
+	cargs->ca_num = numasserts;
+	ctx->gc_proc = RPC_GSS_PROC_CREATE;
+	cred->cr_ops = &gss_credops;
+
+	msg.rpc_argp = cargs;
+
+	/* Want a sync rpc call */
+	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task)) {
+		ret = ERR_CAST(task);
+		goto out_free_assert;
+	}
+	if (task->tk_status != 0) {
+		ret = ERR_PTR(task->tk_status);
+		goto out_free_assert;
+	}
+	rpc_put_task(task);
+
+	g3a = gss3_alloc_init_assertion(&cres);
+	if (IS_ERR(g3a)) {
+		ret = ERR_CAST(g3a);
+		goto out_free_assert;
+	}
+	gss3_insert_assertion(&ctx->gc_alist, g3a);
+
+	ret = &g3a->gss3_handle;
+
+out_free_assert:
+	kfree(cargs);
+out_err:
+	ctx->gc_proc = RPC_GSS_PROC_DATA;
+	gss_put_ctx(ctx);
+	put_rpccred(cred);
+out:
+	return ret;
+}
+
+/**
+ * GSS3 Label Assertion
+ *
+ * Support one label assertion
+ *
+ * Asserts are freed regardless of success or failure
+ * as the asserts accepted and returned by the server are saved.
+ */
+static int
+gss3_create_label(struct rpc_cred *cred)
+{
+	struct gss3_assertion_u *asserts;
+	struct gss3_label *gl;
+	struct xdr_netobj *chandle;
+	int ret;
+
+	asserts = kzalloc(sizeof(*asserts), GFP_NOFS);
+	if (!asserts)
+		return -ENOMEM;
+
+	/* NOTE: not setting la_lfs, la_pi */
+	asserts->au_type = GSS3_LABEL;
+	gl = &asserts->u.au_label;
+
+	ret = security_current_sid_to_context((char **)&gl->la_label.data,
+					      &gl->la_label.len);
+	if (ret)
+		goto out_free_asserts;
+
+	chandle = gss3_proc_create(cred, asserts, 1);
+	if (IS_ERR(chandle))
+		ret = PTR_ERR(chandle);
+
+out_free_asserts:
+	gss3_free_label(gl);
+	kfree(asserts);
+	return ret;
+}
+
 /*
 * Refresh credentials. XXX - finish
 */
-- 
1.8.3.1

