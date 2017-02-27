Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:2918 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751515AbdB0W25 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Feb 2017 17:28:57 -0500
Subject: Re: [PATCH Version 5 08/17] SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with
 label payload
To: <andros@netapp.com>, <bfields@fieldses.org>
References: <20170224221953.5502-1-andros@netapp.com>
 <20170224221953.5502-9-andros@netapp.com>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <2b5eea85-4221-eb5d-314d-f18ac137bf5a@Netapp.com>
Date: Mon, 27 Feb 2017 16:47:01 -0500
MIME-Version: 1.0
In-Reply-To: <20170224221953.5502-9-andros@netapp.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 02/24/2017 05:19 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 140 ++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 138 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 6ffb16d..98971cf 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -52,9 +52,12 @@
>  #include <linux/sunrpc/gss_api.h>
>  #include <linux/uaccess.h>
>  #include <linux/hashtable.h>
> +#include <linux/security.h>
>  
>  #include "../netns.h"
>  
> +static int gss3_create_label(struct rpc_cred *cred, int gss_vers);
> +
>  static const struct rpc_authops authgss_ops;
>  
>  static const struct rpc_credops gss_credops;
> @@ -128,6 +131,20 @@ gss_put_ctx(struct gss_cl_ctx *ctx)
>  		gss_free_ctx(ctx);
>  }
>  
> +/* gss3_label_enabled:
> + * Called to determine if Full Mode Mandatory Access Control (MAC)
> + * over a GSS connection is desired.
> + *
> + * Note:
> + * Currently Full Mode MAC is assuemed if SeLinux is enabled and
> + * RPCSEC_GSS version 3 is in use.
> + */
> +static inline bool
> +gss3_label_assertion_is_enabled(u32 rpcsec_version)
> +{
> +	return (rpcsec_version == RPC_GSS3_VERSION && selinux_is_enabled());
> +}
> +
>  /* gss_cred_set_ctx:
>   * called by gss_upcall_callback and gss_create_upcall in order
>   * to set the gss context. The actual exchange of an old context
> @@ -145,6 +162,7 @@ gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
>  	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>  	smp_mb__before_atomic();
>  	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
> +	gss3_create_label(cred, ctx->gc_v);
>  }
>  
>  static const void *
> @@ -1602,6 +1620,75 @@ static int gss_cred_is_negative_entry(struct rpc_cred *cred)
>  #define GSS3_createres_maxsz   (1 /* cr_hlen */ + \
>  				XDR_QUADLEN(1024) /* cr_handle*/ + \
>  				GSS3_createargs_maxsz)
> +#define GSS3_labelargs_maxsz	(1 /* la_lfs */ + \
> +				 1 /* la_pi */ + \
> +				 1 /* la_label.len */ + \
> +				 XDR_QUADLEN(1024) /* la_label.data */)
> +#define GSS3_labelres_maxsz	GSS3_labelargs_maxsz
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
> +static int
> +gss3_dec_label(struct rpc_rqst *req, struct xdr_stream *xdr,
> +	       struct gss3_create_res *g3cr)
> +{
> +	struct gss3_label *gl;
> +	struct gss3_assertion_u *g3a;
> +	__be32 *p;
> +
> +	/* Used to store assertion in parent gss_cl_ctx */
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
>  
>  static void
>  gss3_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
> @@ -1618,6 +1705,8 @@ gss3_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
>  	*p++ = type;
>  	switch (type) {
>  	case GSS3_LABEL:
> +		gss3_enc_label(req, xdr, g3ca);
> +		break;
>  	case GSS3_PRIVS:
>  	default:
>  		/* drop through to return */
> @@ -1673,6 +1762,9 @@ gss3_dec_create(struct rpc_rqst *req, struct xdr_stream *xdr,
>  	type = be32_to_cpup(p++);
>  	switch (type) {
>  	case GSS3_LABEL:
> +		if (gss3_dec_label(req, xdr, g3cr) != 0)
> +			goto out_free_handle;
> +		break;
>  	case GSS3_PRIVS:
>  	default:
>  		pr_warn("RPC    Unsupported gss3 create assertion %d\n", type);
> @@ -1692,13 +1784,16 @@ gss3_dec_create(struct rpc_rqst *req, struct xdr_stream *xdr,
>  
>  #define RPC_PROC_NULL 0
>  
> +#define GSS3_create_args_max	(GSS3_createargs_maxsz + GSS3_labelargs_maxsz)
> +#define GSS3_create_res_max	(GSS3_createres_maxsz + GSS3_labelres_maxsz)
> +
>  struct rpc_procinfo gss3_label_assertion[] = {
>  	[RPC_GSS_PROC_CREATE] = {
>  		.p_proc		= RPC_PROC_NULL,
>  		.p_encode	= (kxdreproc_t)gss3_enc_create,
>  		.p_decode	= (kxdrdproc_t)gss3_dec_create,
> -		.p_arglen	= GSS3_createargs_maxsz,
> -		.p_replen	= GSS3_createres_maxsz,
> +		.p_arglen	= GSS3_create_args_max,
> +		.p_replen	= GSS3_create_res_max,
>  		.p_statidx	= RPC_GSS_PROC_CREATE,
>  		.p_timer	= 0,
>  		.p_name		= "GSS_PROC_CREATE",
> @@ -1773,6 +1868,47 @@ gss3_proc_create(struct rpc_cred *cred, struct gss3_assertion_u *asserts,
>  	return ret;
>  }
>  
> +/**
> + * GSS3 Label Assertion
> + *
> + * Support one label assertion
> + *
> + * XXX Return not checked. Should we fail nfs requests if
> + * a label fails to be created? I think the server enforcing
> + * Full Mode MAC will reject an NFS request that does not use
> + * a GSS3 (child) context with the correct label.
> + */
> +static int
> +gss3_create_label(struct rpc_cred *cred, int gss_vers)
> +{
> +	struct gss3_assertion_u *asserts;
> +	struct gss3_label *gl;
> +	int ret;
> +
> +	if (!gss3_label_assertion_is_enabled(gss_vers))
> +		return -EINVAL;
> +
> +	asserts = kzalloc(sizeof(*asserts), GFP_NOFS);
> +	if (!asserts)
> +		return -ENOMEM;
> +
> +	/* NOTE: not setting la_lfs, la_pi. Do we even need them? */
> +	asserts->au_type = GSS3_LABEL;
> +	gl = &asserts->u.au_label;
> +
> +	ret = -EINVAL;
> +	ret = security_current_sid_to_context((char **)&gl->la_label.data,
> +					      &gl->la_label.len);

I think you only need to assign "ret" once here

Thanks,
Anna

> +	if (ret)
> +		goto out_free_asserts;
> +
> +	return gss3_proc_create(cred, asserts, 1);
> +
> +out_free_asserts:
> +	kfree(asserts);
> +	return ret;
> +}
> +
>  /*
>  * Refresh credentials. XXX - finish
>  */
> 
