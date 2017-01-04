Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:18644 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761373AbdADVvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 16:51:53 -0500
Subject: Re: [PATCH Version 3 07/16] SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with
 label payload
To: <andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
 <1482509068-24516-8-git-send-email-andros@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <251f8c0f-d2b3-5757-dfc5-675024621d94@Netapp.com>
Date: Wed, 4 Jan 2017 16:51:44 -0500
MIME-Version: 1.0
In-Reply-To: <1482509068-24516-8-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Andy,

On 12/23/2016 11:04 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  include/linux/sunrpc/auth_gss.h |  54 ++++++++
>  net/sunrpc/auth_gss/auth_gss.c  | 282 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 336 insertions(+)
> 
> diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
> index 4ab63a9..b2a5a61 100644
> --- a/include/linux/sunrpc/auth_gss.h
> +++ b/include/linux/sunrpc/auth_gss.h
> @@ -93,6 +93,60 @@ struct gss_cred {
>  	unsigned long		gc_upcall_timestamp;
>  };
>  
> +/** GSS3 */
> +enum gss3_type {
> +	GSS3_LABEL = 0,
> +	GSS3_PRIVS = 1,
> +};
> +
> +struct gss3_chan_binding {
> +	u32	cb_len;
> +	void	*cb_binding;
> +};
> +
> +struct gss3_mp_auth {
> +	u32	mp_handle_len;
> +	void	*mp_handle;
> +	u32	*mp_mic_len;
> +	void	*mp_mic;	/* header mic */
> +};
> +
> +struct gss3_label {
> +	u32			la_lfs;
> +	u32			la_pi;
> +	struct xdr_netobj	la_label;
> +};
> +
> +struct gss3_privs {
> +	char	*pr_name;
> +	u32	pr_num;
> +	void	*pr_data;
> +};
> +
> +struct gss3_assertion_u {
> +	u32	au_type;
> +	union {
> +		struct gss3_label	au_label;
> +		struct gss3_privs	au_privs;
> +	} u;
> +};
> +
> +struct gss3_create_args {
> +	struct gss3_mp_auth		*ca_mp_auth;
> +	struct gss3_chan_binding	*ca_chan_bind;
> +	u32			ca_num;
> +	struct gss3_assertion_u	*ca_assertions;
> +};
> +
> +struct gss3_create_res {
> +	u32		cr_hlen;
> +	void		*cr_handle;
> +	struct gss3_mp_auth		*cr_mp_auth;
> +	struct gss3_chan_binding	*cr_chan_bind;
> +	u32			cr_num;
> +	struct gss3_assertion_u	*cr_assertions;
> +};
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_SUNRPC_AUTH_GSS_H */
>  
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index d11f421..e39c1af 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -52,9 +52,12 @@
>  #include <linux/sunrpc/gss_api.h>
>  #include <asm/uaccess.h>
>  #include <linux/hashtable.h>
> +#include <linux/security.h>
>  
>  #include "../netns.h"
>  
> +static int gss3_create_label(struct rpc_cred *cred);
> +
>  static const struct rpc_authops authgss_ops;
>  
>  static const struct rpc_credops gss_credops;
> @@ -145,6 +148,8 @@ struct gss_auth {
>  	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>  	smp_mb__before_atomic();
>  	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
> +	/* XXXX make void? check retunr ?? */
> +	gss3_create_label(cred);
>  }
>  
>  static const void *
> @@ -1591,6 +1596,283 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
>  	return 0;
>  }
>  
> +/**
> + * GSS3_createargs_maxsz and GSS3_createres_maxsz
> + * include no rgss3_assertion_u payload.
> + *
> + * GSS3_createargs_maxsz is currently for one label.
> + */
> +#define GSS3_createargs_maxsz	(1 /* empty ca_mp_auth */ + \
> +				 1 /* empty ca_chan_bind */ + \
> +				 1 /* ca_num */ + \
> +				 1 /* au_type */)
> +#define GSS3_labelargs_maxsz	(1 /* la_lfs */ + \
> +				 1 /* la_pi */ + \
> +				 1 /* la_label.len */ + \
> +				 XDR_QUADLEN(1024) /* la_label.data */)
> +#define GSS3_createres_maxsz	(1 /* cr_hlen */ + \
> +				 XDR_QUADLEN(1024) /* cr_handle*/ + \
> +				 GSS3_createargs_maxsz)
> +#define GSS3_labelres_maxsz	GSS3_labelargs_maxsz
> +
> +#define GSS3_listargs_maxsz	(1) /* dummy */
> +#define GSS3_listres_maxsz	(1) /* dummy */
> +
> +static void
> +gss3_enc_label(struct rpc_rqst *req, struct xdr_stream *xdr,
> +	       const struct gss3_create_args *g3ca)
> +{
> +	struct gss3_label *gl;
> +	__be32 *p;
> +
> +	gl = &g3ca->ca_assertions[0].u.au_label;
> +
> +	dprintk("RPC: %5u encoding GSSv3 label %s:%d\n", req->rq_task->tk_pid,
> +		(char *)gl->la_label.data, gl->la_label.len);
> +
> +	p = xdr_reserve_space(xdr, GSS3_labelargs_maxsz << 2);
> +	*p++ = cpu_to_be32(0); /* la_lfs */
> +	*p++ = cpu_to_be32(0); /* la_pi */
> +	p = xdr_encode_netobj(p, &gl->la_label);
> +}
> +
> +static void
> +gss3_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
> +		const struct gss3_create_args *g3ca)
> +{
> +	u32 type;
> +	__be32 *p;
> +
> +	p = xdr_reserve_space(xdr, GSS3_createargs_maxsz << 2);
> +	*p++ = cpu_to_be32(0); /* NULL ca_mp_auth */
> +	*p++ = cpu_to_be32(0); /* NULL ca_chan_bind */
> +	*p++ = cpu_to_be32(g3ca->ca_num);
> +	/* the payload is a gss3_label */
> +	type = cpu_to_be32(g3ca->ca_assertions->au_type);
> +	*p++ = type;
> +	switch (type) {
> +	case GSS3_LABEL:
> +		gss3_enc_label(req, xdr, g3ca);
> +		break;
> +	case GSS3_PRIVS:
> +	default:
> +		/* drop through to return */
> +		pr_warn("RPC    Unsupported gss3 create assertion %d\n", type);
> +	}
> +}
> +
> +static int
> +gss3_dec_label(struct rpc_rqst *req, struct xdr_stream *xdr,
> +	       struct gss3_create_res *g3cr)
> +{
> +	struct gss3_label *gl;
> +	struct gss3_assertion_u *g3a;
> +	__be32 *p;
> +
> +	g3a = kzalloc(sizeof(*g3a), GFP_KERNEL);
> +	if (!g3a)
> +		goto out_err;
> +
> +	g3a->au_type = GSS3_LABEL;
> +	gl = &g3a->u.au_label;
> +
> +	p = xdr_inline_decode(xdr, 12);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +
> +	gl->la_lfs = be32_to_cpup(p++);
> +	gl->la_pi = be32_to_cpup(p++);
> +	gl->la_label.len = be32_to_cpup(p++);
> +
> +	p = xdr_inline_decode(xdr, gl->la_label.len);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +
> +	gl->la_label.data = kmemdup(p, gl->la_label.len, GFP_KERNEL);
> +	if (!gl->la_label.data)
> +		goto out_free_assert;
> +	/**
> +	 * Note: need to store the assertion with the child handle
> +	 * in the gss context cache.
> +	 */
> +
> +	g3cr->cr_assertions = g3a;
> +
> +	return 0;
> +
> +out_free_assert:
> +	kfree(g3a);
> +out_err:
> +	return -EIO;
> +out_overflow:
> +	pr_warn("RPC    %s End of receive buffer. Remaining len: %tu words.\n",
> +		__func__, xdr->end - xdr->p);
> +	goto out_free_assert;
> +}
> +
> +static int
> +gss3_dec_create(struct rpc_rqst *req, struct xdr_stream *xdr,
> +		struct gss3_create_res *g3cr)
> +{
> +	u32 dummy, type;
> +	__be32 *p;
> +
> +	p = xdr_inline_decode(xdr, 4);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +	g3cr->cr_hlen = be32_to_cpup(p++);
> +
> +	p = xdr_inline_decode(xdr, g3cr->cr_hlen + 16);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +
> +	g3cr->cr_handle = kmemdup(p, g3cr->cr_hlen, GFP_KERNEL);
> +	if (!g3cr->cr_handle)
> +		goto out_err;
> +
> +	p += XDR_QUADLEN(g3cr->cr_hlen);
> +
> +	/* cr_mp_auth: not supported */
> +	dummy = be32_to_cpup(p++);
> +	if (dummy != 0) {
> +		pr_warn("RPC    gss3 create cr_mp_auth not supported\n");
> +		goto out_free_handle;
> +	}
> +
> +	/* cr_chan_bind: not supported */
> +	dummy = be32_to_cpup(p++);
> +	if (dummy != 0) {
> +		pr_warn("RPC    gss3 create cr_chan_bind not supported\n");
> +		goto out_free_handle;
> +	}
> +
> +	/* Support one label assertion */
> +	g3cr->cr_num = be32_to_cpup(p++);
> +	if (g3cr->cr_num != 1) {
> +		pr_warn("RPC    gss3 multiple assertions %d unspported\n",
> +			g3cr->cr_num);
> +		goto out_free_handle;
> +	}
> +
> +	/* au_type */
> +	type = be32_to_cpup(p++);
> +	switch (type) {
> +	case GSS3_LABEL:
> +		if (gss3_dec_label(req, xdr, g3cr) != 0)
> +			goto out_free_handle;
> +		break;
> +	case GSS3_PRIVS:
> +	default:
> +		pr_warn("RPC    Unsupported gss3 create assertion %d\n", type);
> +		goto out_free_handle;
> +	}
> +	return 0;
> +
> +out_free_handle:
> +	kfree(g3cr->cr_handle);
> +out_err:
> +	return -EIO;
> +out_overflow:
> +	pr_warn("RPC    %s End of receive buffer. Remaining len: %tu words.\n",
> +		__func__, xdr->end - xdr->p);
> +	goto out_err;
> +}
> +
> +#define RPC_PROC_NULL 0
> +
> +struct rpc_procinfo gss3_label_assertion[] = {
> +	[RPC_GSS_PROC_CREATE] = {
> +		.p_proc		= RPC_PROC_NULL,
> +		.p_encode	= (kxdreproc_t)gss3_enc_create,
> +		.p_decode	= (kxdrdproc_t)gss3_dec_create,
> +		.p_arglen	= GSS3_createargs_maxsz + GSS3_labelargs_maxsz,
> +		.p_replen	= GSS3_createres_maxsz + GSS3_labelres_maxsz,
> +		.p_statidx	= RPC_GSS_PROC_CREATE,
> +		.p_timer	= 0,
> +		.p_name		= "GSS_CREATE_LABEL",
> +	},
> +};
> +
> +/** GSSv3 RPC_GSS_PROC_CREATE operation
> + * Note: MUST use integrity or privacy security service.
> + *	First pass; use rpc_gss_svc_none.
> + *
> + * scontext: returned from security_sid_to_scontext(u32 sid, char **scontext)
> + */
> +static int
> +gss3_create_label(struct rpc_cred *cred)
> +{
> +	struct gss_auth *gss_auth = container_of(cred->cr_auth, struct gss_auth,
> +						 rpc_auth);
> +	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
> +	struct rpc_task *task;
> +	struct gss3_create_res cres = {
> +		.cr_mp_auth = 0,
> +	};
> +	struct gss3_create_args *cargs = NULL;
> +	struct gss3_label *gl;
> +	int ret = -EINVAL;
> +
> +	if (!ctx)
> +		goto out;
> +	/**
> +	 * Take a reference to ensure the cred sticks around as we create
> +	 * a child context
> +	 * XXX does grabbing a reference to the context (gss_cred_get_ctx)
> +	 * also keep the cred from being removed?
> +	 * XXX do we need to keep this cred reference until the child context
> +	 * handle and associated assertion is removed?
> +	 */
> +	get_rpccred(cred);
> +
> +	if (ctx->gc_v != RPC_GSS3_VERSION || !selinux_is_enabled())
> +		goto out_err;
> +
> +	ret = -ENOMEM;
> +	cargs = kzalloc(sizeof(*cargs), GFP_NOFS);
> +	if (!cargs)
> +		goto out_err;
> +	cargs->ca_assertions = kzalloc(sizeof(*cargs->ca_assertions), GFP_NOFS);
> +	if (!cargs->ca_assertions)
> +		goto out_free_args;
> +
> +	/* NOTE: not setting la_lfs, la_pi. Do we even need them? */
> +	cargs->ca_num = 1;
> +	cargs->ca_assertions->au_type = GSS3_LABEL;
> +	gl = &cargs->ca_assertions->u.au_label;
> +
> +	ret = security_current_sid_to_context((char **)&gl->la_label.data,
> +					      &gl->la_label.len);

This function only exists if CONFIG_SECURITY_SELINUX=y, as the kbuild bot pointed out.  What is the right thing to do here if selinux isn't compiled in?

Also, do you need to check the value of "ret" here before going on?

Thanks,
Anna

> +
> +	ctx->gc_proc = RPC_GSS_PROC_CREATE;
> +	cred->cr_ops = &gss_credops;
> +
> +	/* Want a sync rpc call */
> +	task = rpc_call_null_payload(gss_auth->client, cred,
> +				     0, cargs, &cres,
> +				    &gss3_label_assertion[RPC_GSS_PROC_CREATE]);
> +	if (IS_ERR(task)) {
> +		ret = PTR_ERR(task);
> +		goto out_free_assert;
> +	}
> +	if (task->tk_status != 0) {
> +		ret = task->tk_status;
> +		goto out_free_assert;
> +	}
> +	rpc_put_task(task);
> +
> +out_free_assert:
> +	kfree(cargs->ca_assertions);
> +out_free_args:
> +	kfree(cargs);
> +out_err:
> +	ctx->gc_proc = RPC_GSS_PROC_DATA;
> +	gss_put_ctx(ctx);
> +	put_rpccred(cred);
> +out:
> +	return ret;
> +}
> +
>  /*
>  * Refresh credentials. XXX - finish
>  */
> 
