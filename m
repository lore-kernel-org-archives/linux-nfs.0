From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] lockd: Add address family-agnostic helper for
	zeroing the port number
Date: Tue, 26 Aug 2008 15:03:19 -0400
Message-ID: <20080826190319.GF4380@fieldses.org>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164232.20488.11685.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760074AbYHZTDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Aug 2008 15:03:43 -0400
In-Reply-To: <20080822164232.20488.11685.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It would be nice if not necessary just to move nfs_set_port() somewhere
common and use that (maybe with a more generic name).

That aside, all 5 patches are OK by me.

--b.

On Fri, Aug 22, 2008 at 12:42:33PM -0400, Chuck Lever wrote:
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/host.c |   14 +++++++++++++-
>  1 files changed, 13 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 55ef751..3f0c1a8 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -39,6 +39,18 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
>  					 const char *hostname,
>  					 unsigned int hostname_len);
>  
> +static void nlm_clear_port(struct sockaddr *sap)
> +{
> +	switch (sap->sa_family) {
> +	case AF_INET:
> +		((struct sockaddr_in *)sap)->sin_port = 0;
> +		break;
> +	case AF_INET6:
> +		((struct sockaddr_in6 *)sap)->sin6_port = 0;
> +		break;
> +	}
> +}
> +
>  static void nlm_display_address(const struct sockaddr *sap,
>  				char *buf, const size_t len)
>  {
> @@ -149,7 +161,7 @@ static struct nlm_host *nlm_lookup_host(int server,
>  	}
>  	host->h_name	   = nsm->sm_name;
>  	host->h_addr       = *sin;
> -	host->h_addr.sin_port = 0;	/* ouch! */
> +	nlm_clear_port((struct sockaddr *)&host->h_addr);
>  	host->h_saddr	   = *ssin;
>  	host->h_version    = version;
>  	host->h_proto      = proto;
> 
