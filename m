From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/10] lockd: Adjust nlmclnt_lookup_host() signature to
	accomodate non-AF_INET
Date: Fri, 26 Sep 2008 18:02:21 -0400
Message-ID: <20080926220221.GD7138@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161728.4963.48337.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36651 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbYIZWC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 18:02:29 -0400
In-Reply-To: <20080917161728.4963.48337.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2008 at 11:17:28AM -0500, Chuck Lever wrote:
> Pass a struct sockaddr * and a length to nlmclnt_lookup_host() to
> accomodate non-AF_INET family addresses.

I'd prefer separate patches here too, though since the two changes
(null-terminated hostname and sockaddr) are a bit easier to separate
visually, it doesn't bother me as much here....

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/clntlock.c         |    5 ++---
>  fs/lockd/host.c             |   34 ++++++++++++++++++++++++----------
>  include/linux/lockd/lockd.h |    9 +++++----
>  3 files changed, 31 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
> index 237224a..9eaf306 100644
> --- a/fs/lockd/clntlock.c
> +++ b/fs/lockd/clntlock.c
> @@ -58,10 +58,9 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
>  	if (status < 0)
>  		return ERR_PTR(status);
>  
> -	host = nlmclnt_lookup_host((struct sockaddr_in *)nlm_init->address,
> +	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
>  				   nlm_init->protocol, nlm_version,
> -				   nlm_init->hostname,
> -				   strlen(nlm_init->hostname));
> +				   nlm_init->hostname);
>  	if (host == NULL) {
>  		lockd_down();
>  		return ERR_PTR(-ENOLCK);
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index c9d25d1..b9c87e1 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -267,29 +267,43 @@ nlm_destroy_host(struct nlm_host *host)
>  	kfree(host);
>  }
>  
> -/*
> - * Find an NLM server handle in the cache. If there is none, create it.
> +/**
> + * nlmclnt_lookup_host - Find an NLM host handle matching a remote server
> + * @sap: network address of server
> + * @salen: length of server address
> + * @protocol: transport protocol to use
> + * @version: NLM protocol version
> + * @hostname: '\0'-terminated hostname of server
> + *
> + * Returns an nlm_host structure that matches the passed-in
> + * [server address, transport protocol, NLM version, server hostname].
> + * If one doesn't already exist in the host cache, a new handle is
> + * created and returned.
>   */
> -struct nlm_host *nlmclnt_lookup_host(const struct sockaddr_in *sin,
> -				     int proto, u32 version,
> -				     const char *hostname,
> -				     unsigned int hostname_len)
> +struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
> +				     const size_t salen,
> +				     const unsigned short protocol,
> +				     const u32 version, const char *hostname)
>  {
>  	const struct sockaddr source = {
>  		.sa_family	= AF_UNSPEC,
>  	};
>  	struct nlm_lookup_host_info ni = {
>  		.peer		= NLM_SERVER,
> -		.sap		= (struct sockaddr *)sin,
> -		.salen		= sizeof(*sin),
> -		.protocol	= proto,
> +		.sap		= sap,
> +		.salen		= salen,
> +		.protocol	= protocol,
>  		.version	= version,
>  		.hostname	= hostname,
> -		.hostname_len	= hostname_len,
> +		.hostname_len	= strlen(hostname),
>  		.src_sap	= &source,
>  		.src_len	= sizeof(source),
>  	};
>  
> +	dprintk("lockd: nlmclnt_lookup_host(host='%s', vers=%u, proto=%s)\n",
> +			(hostname ? hostname : "<none>"), version,
> +			(protocol == IPPROTO_UDP ? "udp" : "tcp"));
> +
>  	return nlm_lookup_host(&ni);
>  }
>  
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index ec8af11..693d57b 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -215,10 +215,11 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
>  /*
>   * Host cache
>   */
> -struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr_in *sin,
> -					int proto, u32 version,
> -					const char *hostname,
> -					unsigned int hostname_len);
> +struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
> +					const size_t salen,
> +					const unsigned short protocol,
> +					const u32 version,
> +					const char *hostname);
>  struct nlm_host  *nlmsvc_lookup_host(struct svc_rqst *, const char *,
>  					unsigned int);
>  struct rpc_clnt * nlm_bind_host(struct nlm_host *);
> 
