From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: fix code that makes auth_gss send destroy_cred
 message
Date: Thu, 18 Dec 2008 13:15:02 -0500
Message-ID: <1229624102.7789.36.camel@heimdal.trondhjem.org>
References: <1229622675-13596-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38622 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbYLRSPM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2008 13:15:12 -0500
In-Reply-To: <1229622675-13596-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-12-18 at 12:51 -0500, Jeff Layton wrote:
> There's a bit of a chicken and egg problem when it comes to destroying
> auth_gss credentials. When we destroy the last instance of a GSSAPI RPC
> credential, we should send a NULL RPC call with a GSS procedure of
> RPCSEC_GSS_DESTROY to hint to the server that it can destroy those
> creds.
> 
> This isn't happening because we're setting clearing the uptodate bit on
> the credentials and then setting the operations to the gss_nullops. When
> we go to do the RPC call, we try to refresh the creds. That fails with
> -EACCES and the call fails.
> 
> Fix this by not clearing the UPTODATE bit for the credentials and adding
> a new crdestroy op for gss_nullops that just tears down the cred without
> trying to destroy the context.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |   23 ++++++++++++++++-------
>  1 files changed, 16 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 853a414..e22fb45 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -693,7 +693,7 @@ gss_destroying_context(struct rpc_cred *cred)
>  	struct rpc_task *task;
>  
>  	if (gss_cred->gc_ctx == NULL ||
> -	    test_and_clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
> +	    test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
>  		return 0;
>  
>  	gss_cred->gc_ctx->gc_proc = RPC_GSS_PROC_DESTROY;
> @@ -757,14 +757,14 @@ gss_free_cred_callback(struct rcu_head *head)
>  }
>  
>  static void
> -gss_destroy_cred(struct rpc_cred *cred)
> +gss_destroy_nullcred(struct rpc_cred *cred)
>  {
> -	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
> -	struct gss_auth *gss_auth = container_of(cred->cr_auth, struct gss_auth, rpc_auth);
> +	struct gss_cred *gss_cred = container_of(cred, struct gss_cred,
> +						 gc_base);


Ugh, ugh, ugh, ugh... It was nice and legible before!

> +	struct gss_auth *gss_auth = container_of(cred->cr_auth,
> +						 struct gss_auth, rpc_auth);
>  	struct gss_cl_ctx *ctx = gss_cred->gc_ctx;
>  
> -	if (gss_destroying_context(cred))
> -		return;
>  	rcu_assign_pointer(gss_cred->gc_ctx, NULL);
>  	call_rcu(&cred->cr_rcu, gss_free_cred_callback);
>  	if (ctx)
> @@ -772,6 +772,15 @@ gss_destroy_cred(struct rpc_cred *cred)
>  	kref_put(&gss_auth->kref, gss_free_callback);
>  }
>  
> +static void
> +gss_destroy_cred(struct rpc_cred *cred)
> +{
> +
> +	if (gss_destroying_context(cred))
> +		return;
> +	gss_destroy_nullcred(cred);
> +}
> +
>  /*
>   * Lookup RPCSEC_GSS cred for the current process
>   */
> @@ -1324,7 +1333,7 @@ static const struct rpc_credops gss_credops = {
>  
>  static const struct rpc_credops gss_nullops = {
>  	.cr_name	= "AUTH_GSS",
> -	.crdestroy	= gss_destroy_cred,
> +	.crdestroy	= gss_destroy_nullcred,
>  	.crbind		= rpcauth_generic_bind_cred,
>  	.crmatch	= gss_match,
>  	.crmarshal	= gss_marshal,

