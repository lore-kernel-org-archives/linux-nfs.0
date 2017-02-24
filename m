Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:18075 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751444AbdBXWUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:08 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 07/17] SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with no payload
Date: Fri, 24 Feb 2017 17:19:43 -0500
Message-ID: <20170224221953.5502-8-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h |  54 ++++++++++++
 net/sunrpc/auth_gss/auth_gss.c  | 182 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 236 insertions(+)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index 4ab63a9..b2a5a61 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -93,6 +93,60 @@ struct gss_cred {
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
+	char	*pr_name;
+	u32	pr_num;
+	void	*pr_data;
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
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 499cf99..6ffb16d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1591,6 +1591,188 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
 	return 0;
 }
 
+/**
+ * GSS3_createargs_maxsz and GSS3_createres_maxsz
+ * include no rgss3_assertion_u payload.
+ */
+#define GSS3_createargs_maxsz  (1 /* empty ca_mp_auth */ + \
+				1 /* empty ca_chan_bind */ + \
+				1 /* ca_num */ + \
+				1 /* au_type */)
+#define GSS3_createres_maxsz   (1 /* cr_hlen */ + \
+				XDR_QUADLEN(1024) /* cr_handle*/ + \
+				GSS3_createargs_maxsz)
+
+static void
+gss3_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
+		const struct gss3_create_args *g3ca)
+{
+	u32 type;
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, GSS3_createargs_maxsz << 2);
+	*p++ = cpu_to_be32(0); /* NULL ca_mp_auth */
+	*p++ = cpu_to_be32(0); /* NULL ca_chan_bind */
+	*p++ = cpu_to_be32(g3ca->ca_num);
+	type = cpu_to_be32(g3ca->ca_assertions->au_type);
+	*p++ = type;
+	switch (type) {
+	case GSS3_LABEL:
+	case GSS3_PRIVS:
+	default:
+		/* drop through to return */
+		pr_warn("RPC    Unsupported gss3 create assertion %d\n", type);
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
+	/* XXX Support one assertion */
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
+struct rpc_procinfo gss3_label_assertion[] = {
+	[RPC_GSS_PROC_CREATE] = {
+		.p_proc		= RPC_PROC_NULL,
+		.p_encode	= (kxdreproc_t)gss3_enc_create,
+		.p_decode	= (kxdrdproc_t)gss3_dec_create,
+		.p_arglen	= GSS3_createargs_maxsz,
+		.p_replen	= GSS3_createres_maxsz,
+		.p_statidx	= RPC_GSS_PROC_CREATE,
+		.p_timer	= 0,
+		.p_name		= "GSS_PROC_CREATE",
+	},
+};
+
+/**
+ * RPC_GSS_PROC_CREATE operation
+ *
+ * Notes:
+ *    1) Spec says we MUST use integrity or privacy security service.
+ *    First pass; use rpc_gss_svc_none.
+ *    2) asserts are allocated by caller, and freed here.
+ */
+static int
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
+	struct gss3_create_args *cargs = NULL;
+	int ret = -EINVAL;
+
+	if (!ctx || !asserts)
+		goto out;
+	/**
+	 * Take a reference to ensure the cred sticks around as we create
+	 * a child context
+	 * XXX does grabbing a reference to the context (gss_cred_get_ctx)
+	 * also keep the cred from being removed?
+	 * XXX do we need to keep this cred reference until the child context
+	 * handle and associated assertion is removed?
+	 */
+	get_rpccred(cred);
+
+	ret = -ENOMEM;
+	cargs = kzalloc(sizeof(*cargs), GFP_NOFS);
+	if (!cargs)
+		goto out_err;
+
+	cargs->ca_assertions = asserts;
+	cargs->ca_num = numasserts;
+	ctx->gc_proc = RPC_GSS_PROC_CREATE;
+	cred->cr_ops = &gss_credops;
+
+	/* Want a sync rpc call */
+	task = rpc_call_null_payload(gss_auth->client, cred, 0, cargs, &cres,
+				    &gss3_label_assertion[RPC_GSS_PROC_CREATE]);
+	if (IS_ERR(task)) {
+		ret = PTR_ERR(task);
+		goto out_free_assert;
+	}
+	if (task->tk_status != 0) {
+		ret = task->tk_status;
+		goto out_free_assert;
+	}
+	rpc_put_task(task);
+
+out_free_assert:
+	kfree(cargs->ca_assertions);
+	kfree(cargs);
+out_err:
+	ctx->gc_proc = RPC_GSS_PROC_DATA;
+	gss_put_ctx(ctx);
+	put_rpccred(cred);
+out:
+	return ret;
+}
+
 /*
 * Refresh credentials. XXX - finish
 */
-- 
2.9.3

