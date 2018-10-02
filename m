Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56518 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726194AbeJCCYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Oct 2018 22:24:06 -0400
Date: Tue, 2 Oct 2018 15:39:08 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/15] SUNRPC: Remove the server 'authtab_lock' and just
 use RCU
Message-ID: <20181002193908.GB9073@fieldses.org>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181001144157.3515-2-trond.myklebust@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 01, 2018 at 10:41:43AM -0400, Trond Myklebust wrote:
> Module removal is RCU safe by design, so we really have no need to
> lock the 'authtab[]' array.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  net/sunrpc/svcauth.c | 52 +++++++++++++++++++++++++++++---------------
>  1 file changed, 34 insertions(+), 18 deletions(-)
> 
> diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
> index bb8db3cb8032..f83443856cd1 100644
> --- a/net/sunrpc/svcauth.c
> +++ b/net/sunrpc/svcauth.c
> @@ -27,12 +27,32 @@
>  extern struct auth_ops svcauth_null;
>  extern struct auth_ops svcauth_unix;
>  
> -static DEFINE_SPINLOCK(authtab_lock);
> -static struct auth_ops	*authtab[RPC_AUTH_MAXFLAVOR] = {
> -	[0] = &svcauth_null,
> -	[1] = &svcauth_unix,
> +static struct auth_ops __rcu *authtab[RPC_AUTH_MAXFLAVOR] = {
> +	[RPC_AUTH_NULL] = (struct auth_ops __force __rcu *)&svcauth_null,
> +	[RPC_AUTH_UNIX] = (struct auth_ops __force __rcu *)&svcauth_unix,

I didn't know about "__rcu" and "__force __rcu".  Grepping turns up
relevant documentation for RCU_INIT_POINTER in include/linux/rcupdate.h,
OK, I think I get it.--b.

>  };
>  
> +static struct auth_ops *
> +svc_get_auth_ops(rpc_authflavor_t flavor)
> +{
> +	struct auth_ops		*aops;
> +
> +	if (flavor >= RPC_AUTH_MAXFLAVOR)
> +		return NULL;
> +	rcu_read_lock();
> +	aops = rcu_dereference(authtab[flavor]);
> +	if (aops != NULL && !try_module_get(aops->owner))
> +		aops = NULL;
> +	rcu_read_unlock();
> +	return aops;
> +}
> +
> +static void
> +svc_put_auth_ops(struct auth_ops *aops)
> +{
> +	module_put(aops->owner);
> +}
> +
>  int
>  svc_authenticate(struct svc_rqst *rqstp, __be32 *authp)
>  {
> @@ -45,14 +65,11 @@ svc_authenticate(struct svc_rqst *rqstp, __be32 *authp)
>  
>  	dprintk("svc: svc_authenticate (%d)\n", flavor);
>  
> -	spin_lock(&authtab_lock);
> -	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor]) ||
> -	    !try_module_get(aops->owner)) {
> -		spin_unlock(&authtab_lock);
> +	aops = svc_get_auth_ops(flavor);
> +	if (aops == NULL) {
>  		*authp = rpc_autherr_badcred;
>  		return SVC_DENIED;
>  	}
> -	spin_unlock(&authtab_lock);
>  
>  	rqstp->rq_auth_slack = 0;
>  	init_svc_cred(&rqstp->rq_cred);
> @@ -82,7 +99,7 @@ int svc_authorise(struct svc_rqst *rqstp)
>  
>  	if (aops) {
>  		rv = aops->release(rqstp);
> -		module_put(aops->owner);
> +		svc_put_auth_ops(aops);
>  	}
>  	return rv;
>  }
> @@ -90,13 +107,14 @@ int svc_authorise(struct svc_rqst *rqstp)
>  int
>  svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops)
>  {
> +	struct auth_ops *old;
>  	int rv = -EINVAL;
> -	spin_lock(&authtab_lock);
> -	if (flavor < RPC_AUTH_MAXFLAVOR && authtab[flavor] == NULL) {
> -		authtab[flavor] = aops;
> -		rv = 0;
> +
> +	if (flavor < RPC_AUTH_MAXFLAVOR) {
> +		old = cmpxchg((struct auth_ops ** __force)&authtab[flavor], NULL, aops);
> +		if (old == NULL || old == aops)
> +			rv = 0;
>  	}
> -	spin_unlock(&authtab_lock);
>  	return rv;
>  }
>  EXPORT_SYMBOL_GPL(svc_auth_register);
> @@ -104,10 +122,8 @@ EXPORT_SYMBOL_GPL(svc_auth_register);
>  void
>  svc_auth_unregister(rpc_authflavor_t flavor)
>  {
> -	spin_lock(&authtab_lock);
>  	if (flavor < RPC_AUTH_MAXFLAVOR)
> -		authtab[flavor] = NULL;
> -	spin_unlock(&authtab_lock);
> +		rcu_assign_pointer(authtab[flavor], NULL);
>  }
>  EXPORT_SYMBOL_GPL(svc_auth_unregister);
>  
> -- 
> 2.17.1
