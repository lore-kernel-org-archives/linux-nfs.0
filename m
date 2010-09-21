Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754407Ab0IUUzJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 16:55:09 -0400
Date: Tue, 21 Sep 2010 16:53:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/6] sunrpc: close connection when a request is
 irretrievably lost.
Message-ID: <20100921205343.GB10570@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
 <20100812070406.11459.61914.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100812070406.11459.61914.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Apologies for the delay getting to the rest of these.

On Thu, Aug 12, 2010 at 05:04:07PM +1000, NeilBrown wrote:
> If we drop a request in the sunrpc layer, either due kmalloc failure,
> or due to a cache miss when we could not queue the request for later
> replay, then close the connection to encourage the client to retry sooner.
> 
> Note that if the drop happens in the NFS layer, NFSERR_JUKEBOX
> (aka NFS4ERR_DELAY) is returned to guide the client concerning
> replay.

Looks fine, but:

> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index d9017d6..6359c42 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1055,6 +1055,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  		goto err_bad;
>  	case SVC_DENIED:
>  		goto err_bad_auth;
> +	case SVC_CLOSE:
> +		if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
> +			svc_close_xprt(rqstp->rq_xprt);

There are also dropit's later in svc_process_common when xdr encoding
fails.  I wonder if we should close there?

Well, it's an odd case.  Seems like it should almost be declared a
programming error and made a WARN().

Applying as is.--b.

>  	case SVC_DROP:
>  		goto dropit;
>  	case SVC_COMPLETE:
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 2073116..e91b550 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -674,6 +674,8 @@ static struct group_info *unix_gid_find(uid_t uid, struct svc_rqst *rqstp)
>  	switch (ret) {
>  	case -ENOENT:
>  		return ERR_PTR(-ENOENT);
> +	case -ETIMEDOUT:
> +		return ERR_PTR(-ESHUTDOWN);
>  	case 0:
>  		gi = get_group_info(ug->gi);
>  		cache_put(&ug->h, &unix_gid_cache);
> @@ -720,8 +722,9 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
>  	switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
>  		default:
>  			BUG();
> -		case -EAGAIN:
>  		case -ETIMEDOUT:
> +			return SVC_CLOSE;
> +		case -EAGAIN:
>  			return SVC_DROP;
>  		case -ENOENT:
>  			return SVC_DENIED;
> @@ -736,6 +739,8 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
>  	switch (PTR_ERR(gi)) {
>  	case -EAGAIN:
>  		return SVC_DROP;
> +	case -ESHUTDOWN:
> +		return SVC_CLOSE;
>  	case -ENOENT:
>  		break;
>  	default:
> @@ -776,7 +781,7 @@ svcauth_null_accept(struct svc_rqst *rqstp, __be32 *authp)
>  	cred->cr_gid = (gid_t) -1;
>  	cred->cr_group_info = groups_alloc(0);
>  	if (cred->cr_group_info == NULL)
> -		return SVC_DROP; /* kmalloc failure - client must retry */
> +		return SVC_CLOSE; /* kmalloc failure - client must retry */
>  
>  	/* Put NULL verifier */
>  	svc_putnl(resv, RPC_AUTH_NULL);
> @@ -840,7 +845,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
>  		goto badcred;
>  	cred->cr_group_info = groups_alloc(slen);
>  	if (cred->cr_group_info == NULL)
> -		return SVC_DROP;
> +		return SVC_CLOSE;
>  	for (i = 0; i < slen; i++)
>  		GROUP_AT(cred->cr_group_info, i) = svc_getnl(argv);
>  	if (svc_getu32(argv) != htonl(RPC_AUTH_NULL) || svc_getu32(argv) != 0) {
> 
> 
