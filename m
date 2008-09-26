From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/10] lockd: Adjust signature of nlm_host_rebooted to
	handle non-AF_INET
Date: Fri, 26 Sep 2008 18:27:00 -0400
Message-ID: <20080926222700.GG7138@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161749.4963.84067.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45236 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbYIZW1J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 18:27:09 -0400
In-Reply-To: <20080917161749.4963.84067.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2008 at 11:17:50AM -0500, Chuck Lever wrote:
> Pass a struct sockaddr * and length to nlm_host_rebooted() to accomodate
> non-AF_INET addresses.

OK, thanks.

> +/**
> + * nlm_host_rebooted - Release all resources held by rebooted host
> + * @sap: network address of peer that just rebooted
> + * @salen: length of peer's network address
> + * @hostname: hostname of peer that just rebooted
> + * @hostname_len: length of peer's hostname
> + * @new_state: peer's new nsmstate
> + *
> + * We were notified that the host indicated by address "sap"
> + * has rebooted.  Release all resources held by that peer.
>   */
> -void nlm_host_rebooted(const struct sockaddr_in *sin,
> -				const char *hostname,
> -				unsigned int hostname_len,
> -				u32 new_state)
> +void nlm_host_rebooted(const struct sockaddr *sap, const size_t salen,
> +		       const char *hostname, const size_t hostname_len,
> +		       const u32 new_state)
>  {
>  	struct hlist_head *chain;
>  	struct hlist_node *pos;
>  	struct nsm_handle *nsm;
>  	struct nlm_host	*host;
>  
> -	nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
> -			hostname, hostname_len, 0);
> +	nsm = nsm_find(sap, salen, hostname, hostname_len, 0);
>  	if (nsm == NULL) {
>  		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
> -				hostname_len, hostname);
> +				(int)hostname_len, hostname);

This seems unrelated to the current patch.  And there's been no change
to the signedness of hostname_len.  Do we care?

--b.

>  		return;
>  	}
>  
>  	dprintk("lockd: nlm_host_rebooted(%.*s, %s)\n",
> -			hostname_len, hostname, nsm->sm_addrbuf);
> +			(int)hostname_len, hostname, nsm->sm_addrbuf);
>  
>  	/* When reclaiming locks on this peer, make sure that
>  	 * we set up a new notification */
> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index 89eb6f9..9e1c751 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -447,8 +447,10 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
>  	 * reclaim all locks we hold on this server.
>  	 */
>  	memset(&saddr, 0, sizeof(saddr));
> +	saddr.sin_family = AF_INET;
>  	saddr.sin_addr.s_addr = argp->addr;
> -	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
> +	nlm_host_rebooted((struct sockaddr *)&saddr, sizeof(saddr),
> +			  argp->mon, argp->len, argp->state);
>  
>  	return rpc_success;
>  }
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index 361aac2..fcb7998 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -479,8 +479,10 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
>  	 * reclaim all locks we hold on this server.
>  	 */
>  	memset(&saddr, 0, sizeof(saddr));
> +	saddr.sin_family = AF_INET;
>  	saddr.sin_addr.s_addr = argp->addr;
> -	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
> +	nlm_host_rebooted((struct sockaddr *)&saddr, sizeof(saddr),
> +			  argp->mon, argp->len, argp->state);
>  
>  	return rpc_success;
>  }
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 165ef7a..075095f 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -229,8 +229,11 @@ void		  nlm_rebind_host(struct nlm_host *);
>  struct nlm_host * nlm_get_host(struct nlm_host *);
>  void		  nlm_release_host(struct nlm_host *);
>  void		  nlm_shutdown_hosts(void);
> -extern void	  nlm_host_rebooted(const struct sockaddr_in *, const char *,
> -					unsigned int, u32);
> +extern void	  nlm_host_rebooted(const struct sockaddr *sap,
> +					const size_t salen,
> +					const char *hostname,
> +					const size_t hostname_len,
> +					const u32 new_state);
>  void		  nsm_release(struct nsm_handle *);
>  
>  
> 
