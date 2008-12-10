From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 14/27] NLM: Decode "priv" argument of NLMPROC_SM_NOTIFY
	as an opaque
Date: Wed, 10 Dec 2008 17:29:48 -0500
Message-ID: <20081210222948.GL1212@fieldses.org>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000338.24075.50442.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38710 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbYLJW3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 17:29:50 -0500
In-Reply-To: <20081206000338.24075.50442.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2008 at 07:03:39PM -0500, Chuck Lever wrote:
> The NLM XDR decoders for the NLMPROC_SM_NOTIFY procedure should treat
> their "priv" argument truly as an opaque, as defined by the protocol,
> and let the upper layers figure out what is in it.
> 
> This will make it easier to modify the contents and interpretation of
> the "priv" argument, and keep knowledge about what's in "priv" local
> to fs/lockd/mon.c.
> 
> For now, the NLM and NSM implementations should behave exactly as they
> did before.
> 
> The formation of the address of the rebooted host in
> nlm_host_rebooted() may look a little strange, but it is the inverse
> of how nsm_init_private() forms the private cookie.  Plus, it's
> going away soon anyway.

OK, applied these four.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/host.c           |    3 ++-
>  fs/lockd/xdr.c            |    4 ++--
>  fs/lockd/xdr4.c           |    4 ++--
>  include/linux/lockd/xdr.h |    8 ++++----
>  4 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index ed10338..dc41e46 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -453,9 +453,10 @@ void nlm_release_host(struct nlm_host *host)
>   */
>  void nlm_host_rebooted(const struct nlm_reboot *info)
>  {
> +	__be32 *p = (__be32 *)&info->priv.data;
>  	const struct sockaddr_in sin = {
>  		.sin_family		= AF_INET,
> -		.sin_addr.s_addr	= info->addr,
> +		.sin_addr.s_addr	= *p,
>  	};
>  	struct hlist_head *chain;
>  	struct hlist_node *pos;
> diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
> index 1f22629..4cc7d01 100644
> --- a/fs/lockd/xdr.c
> +++ b/fs/lockd/xdr.c
> @@ -349,8 +349,8 @@ nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp)
>  	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
>  		return 0;
>  	argp->state = ntohl(*p++);
> -	/* Preserve the address in network byte order */
> -	argp->addr = *p++;
> +	memcpy(&argp->priv.data, p, sizeof(argp->priv.data));
> +	p += XDR_QUADLEN(SM_PRIV_SIZE);
>  	return xdr_argsize_check(rqstp, p);
>  }
>  
> diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
> index 50c493a..61d1714 100644
> --- a/fs/lockd/xdr4.c
> +++ b/fs/lockd/xdr4.c
> @@ -356,8 +356,8 @@ nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct nlm_reboot *argp
>  	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len, SM_MAXSTRLEN)))
>  		return 0;
>  	argp->state = ntohl(*p++);
> -	/* Preserve the address in network byte order */
> -	argp->addr  = *p++;
> +	memcpy(&argp->priv.data, p, sizeof(argp->priv.data));
> +	p += XDR_QUADLEN(SM_PRIV_SIZE);
>  	return xdr_argsize_check(rqstp, p);
>  }
>  
> diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
> index 6b51992..6338866 100644
> --- a/include/linux/lockd/xdr.h
> +++ b/include/linux/lockd/xdr.h
> @@ -83,10 +83,10 @@ struct nlm_res {
>   * statd callback when client has rebooted
>   */
>  struct nlm_reboot {
> -	char *		mon;
> -	unsigned int	len;
> -	u32		state;
> -	__be32		addr;
> +	char			*mon;
> +	unsigned int		len;
> +	u32			state;
> +	struct nsm_private	priv;
>  };
>  
>  /*
> 
