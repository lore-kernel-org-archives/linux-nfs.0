Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab2DQV5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 17:57:00 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3HLuxmY026985
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 17:56:59 -0400
Date: Tue, 17 Apr 2012 17:56:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/5] SUNRPC: split upcall function to extract reusable
 parts
Message-ID: <20120417215658.GB5861@pad.fieldses.org>
References: <1334669948-4156-1-git-send-email-simo@redhat.com>
 <1334669948-4156-4-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1334669948-4156-4-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2012 at 09:39:06AM -0400, Simo Sorce wrote:
> This is needed to share code between the current server upcall mechanism
> and the new gssproxy upcall mechanism introduced in a following patch.

I'll go ahead and take this now, as it seems like reasonable cleanup
independent of the rest.

--b.

> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c |  110 +++++++++++++++++++++++--------------
>  1 files changed, 69 insertions(+), 41 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 274df6410057fa23e991545d80fdb90ab37e0b6f..aa1b649749741c82e60f0f528ac645197fd7ab35 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -965,16 +965,17 @@ svcauth_gss_set_client(struct svc_rqst *rqstp)
>  }
>  
>  static inline int
> -gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp, struct rsi *rsip)
> +gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
> +		struct xdr_netobj *out_handle, int *major_status)
>  {
>  	struct rsc *rsci;
>  	int        rc;
>  
> -	if (rsip->major_status != GSS_S_COMPLETE)
> +	if (*major_status != GSS_S_COMPLETE)
>  		return gss_write_null_verf(rqstp);
> -	rsci = gss_svc_searchbyctx(cd, &rsip->out_handle);
> +	rsci = gss_svc_searchbyctx(cd, out_handle);
>  	if (rsci == NULL) {
> -		rsip->major_status = GSS_S_NO_CONTEXT;
> +		*major_status = GSS_S_NO_CONTEXT;
>  		return gss_write_null_verf(rqstp);
>  	}
>  	rc = gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN);
> @@ -982,6 +983,61 @@ gss_write_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp, struct rsi
>  	return rc;
>  }
>  
> +static inline int
> +gss_read_verf(struct rpc_gss_wire_cred *gc,
> +	      struct kvec *argv, __be32 *authp,
> +	      struct xdr_netobj *in_handle,
> +	      struct xdr_netobj *in_token)
> +{
> +	struct xdr_netobj tmpobj;
> +
> +	/* Read the verifier; should be NULL: */
> +	*authp = rpc_autherr_badverf;
> +	if (argv->iov_len < 2 * 4)
> +		return SVC_DENIED;
> +	if (svc_getnl(argv) != RPC_AUTH_NULL)
> +		return SVC_DENIED;
> +	if (svc_getnl(argv) != 0)
> +		return SVC_DENIED;
> +	/* Martial context handle and token for upcall: */
> +	*authp = rpc_autherr_badcred;
> +	if (gc->gc_proc == RPC_GSS_PROC_INIT && gc->gc_ctx.len != 0)
> +		return SVC_DENIED;
> +	if (dup_netobj(in_handle, &gc->gc_ctx))
> +		return SVC_CLOSE;
> +	*authp = rpc_autherr_badverf;
> +	if (svc_safe_getnetobj(argv, &tmpobj)) {
> +		kfree(in_handle->data);
> +		return SVC_DENIED;
> +	}
> +	if (dup_netobj(in_token, &tmpobj)) {
> +		kfree(in_handle->data);
> +		return SVC_CLOSE;
> +	}
> +
> +	return 0;
> +}
> +
> +static inline int
> +gss_write_resv(struct kvec *resv, size_t size_limit,
> +	       struct xdr_netobj *out_handle, struct xdr_netobj *out_token,
> +	       int major_status, int minor_status)
> +{
> +	if (resv->iov_len + 4 > size_limit)
> +		return -1;
> +	svc_putnl(resv, RPC_SUCCESS);
> +	if (svc_safe_putnetobj(resv, out_handle))
> +		return -1;
> +	if (resv->iov_len + 3 * 4 > size_limit)
> +		return -1;
> +	svc_putnl(resv, major_status);
> +	svc_putnl(resv, minor_status);
> +	svc_putnl(resv, GSS_SEQ_WIN);
> +	if (svc_safe_putnetobj(resv, out_token))
> +		return -1;
> +	return 0;
> +}
> +
>  /*
>   * Having read the cred already and found we're in the context
>   * initiation case, read the verifier and initiate (or check the results
> @@ -994,36 +1050,15 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
>  {
>  	struct kvec *argv = &rqstp->rq_arg.head[0];
>  	struct kvec *resv = &rqstp->rq_res.head[0];
> -	struct xdr_netobj tmpobj;
>  	struct rsi *rsip, rsikey;
>  	int ret;
>  	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
>  
> -	/* Read the verifier; should be NULL: */
> -	*authp = rpc_autherr_badverf;
> -	if (argv->iov_len < 2 * 4)
> -		return SVC_DENIED;
> -	if (svc_getnl(argv) != RPC_AUTH_NULL)
> -		return SVC_DENIED;
> -	if (svc_getnl(argv) != 0)
> -		return SVC_DENIED;
> -
> -	/* Martial context handle and token for upcall: */
> -	*authp = rpc_autherr_badcred;
> -	if (gc->gc_proc == RPC_GSS_PROC_INIT && gc->gc_ctx.len != 0)
> -		return SVC_DENIED;
>  	memset(&rsikey, 0, sizeof(rsikey));
> -	if (dup_netobj(&rsikey.in_handle, &gc->gc_ctx))
> -		return SVC_CLOSE;
> -	*authp = rpc_autherr_badverf;
> -	if (svc_safe_getnetobj(argv, &tmpobj)) {
> -		kfree(rsikey.in_handle.data);
> -		return SVC_DENIED;
> -	}
> -	if (dup_netobj(&rsikey.in_token, &tmpobj)) {
> -		kfree(rsikey.in_handle.data);
> -		return SVC_CLOSE;
> -	}
> +	ret = gss_read_verf(gc, argv, authp,
> +			    &rsikey.in_handle, &rsikey.in_token);
> +	if (ret)
> +		return ret;
>  
>  	/* Perform upcall, or find upcall result: */
>  	rsip = rsi_lookup(sn->rsi_cache, &rsikey);
> @@ -1036,19 +1071,12 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
>  
>  	ret = SVC_CLOSE;
>  	/* Got an answer to the upcall; use it: */
> -	if (gss_write_init_verf(sn->rsc_cache, rqstp, rsip))
> +	if (gss_write_init_verf(sn->rsc_cache, rqstp,
> +				&rsip->out_handle, &rsip->major_status))
>  		goto out;
> -	if (resv->iov_len + 4 > PAGE_SIZE)
> -		goto out;
> -	svc_putnl(resv, RPC_SUCCESS);
> -	if (svc_safe_putnetobj(resv, &rsip->out_handle))
> -		goto out;
> -	if (resv->iov_len + 3 * 4 > PAGE_SIZE)
> -		goto out;
> -	svc_putnl(resv, rsip->major_status);
> -	svc_putnl(resv, rsip->minor_status);
> -	svc_putnl(resv, GSS_SEQ_WIN);
> -	if (svc_safe_putnetobj(resv, &rsip->out_token))
> +	if (gss_write_resv(resv, PAGE_SIZE,
> +			   &rsip->out_handle, &rsip->out_token,
> +			   rsip->major_status, rsip->minor_status))
>  		goto out;
>  
>  	ret = SVC_COMPLETE;
> -- 
> 1.7.7.6
> 
