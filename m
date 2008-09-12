From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/7] lockd: Use sockaddr_storage for h_saddr field
Date: Thu, 11 Sep 2008 21:41:54 -0400
Message-ID: <20080912014154.GA27568@fieldses.org>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net> <20080903183546.16867.90601.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52027 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819AbYILBl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2008 21:41:58 -0400
In-Reply-To: <20080903183546.16867.90601.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 03, 2008 at 02:35:46PM -0400, Chuck Lever wrote:
> @@ -294,7 +294,7 @@ nlm_bind_host(struct nlm_host *host)
>  			.protocol	= host->h_proto,
>  			.address	= nlm_addr(host),
>  			.addrsize	= host->h_addrlen,
> -			.saddress	= (struct sockaddr *)&host->h_saddr,
> +			.saddress	= nlm_srcaddr(host),

Just out of curiosity--in the patch 1 and 3, you also add a length
field.  Here you don't.  Why the difference?  None of the new length
fields seem to be used yet.

--b.

>  			.timeout	= &timeparms,
>  			.servername	= host->h_name,
>  			.program	= &nlm_program,
> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> index 198b4e5..d3d1330 100644
> --- a/fs/lockd/svcsubs.c
> +++ b/fs/lockd/svcsubs.c
> @@ -418,7 +418,7 @@ EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_sb);
>  static int
>  nlmsvc_match_ip(void *datap, struct nlm_host *host)
>  {
> -	return nlm_cmp_addr(&host->h_saddr, datap);
> +	return nlm_cmp_addr(nlm_srcaddr_in(host), datap);
>  }
>  
>  /**
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 41d7a8e..964e6c9 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -40,7 +40,7 @@ struct nlm_host {
>  	struct hlist_node	h_hash;		/* doubly linked list */
>  	struct sockaddr_storage	h_addr;		/* peer address */
>  	size_t			h_addrlen;
> -	struct sockaddr_in	h_saddr;	/* our address (optional) */
> +	struct sockaddr_storage	h_srcaddr;	/* our address (optional) */
>  	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
>  	char *			h_name;		/* remote hostname */
>  	u32			h_version;	/* interface version */
> @@ -64,7 +64,7 @@ struct nlm_host {
>  	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
>  
>  	char			h_addrbuf[48],	/* address eyecatchers */
> -				h_saddrbuf[48];
> +				h_srcaddrbuf[48];
>  };
>  
>  struct nsm_handle {
> @@ -90,6 +90,16 @@ static inline struct sockaddr *nlm_addr(const struct nlm_host *host)
>  	return (struct sockaddr *)&host->h_addr;
>  }
>  
> +static inline struct sockaddr_in *nlm_srcaddr_in(const struct nlm_host *host)
> +{
> +	return (struct sockaddr_in *)&host->h_srcaddr;
> +}
> +
> +static inline struct sockaddr *nlm_srcaddr(const struct nlm_host *host)
> +{
> +	return (struct sockaddr *)&host->h_srcaddr;
> +}
> +
>  /*
>   * Map an fl_owner_t into a unique 32-bit "pid"
>   */
> 
