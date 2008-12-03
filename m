From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/6] NLM: Clean up nsm_monitor() call
Date: Wed, 3 Dec 2008 16:28:59 -0500
Message-ID: <20081203212859.GR16846@fieldses.org>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185805.10600.23630.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58777 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752788AbYLCV3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2008 16:29:03 -0500
In-Reply-To: <20081201185805.10600.23630.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 01, 2008 at 01:58:05PM -0500, Chuck Lever wrote:
> Clean up: A few minor clean-ups for nsm_unmonitor():

Looks fine, but might prefer this slightly finer-grained:

> 
>  o  Arrange dprintk and check of sm_monitored consistently with
>     nsm_monitor().
> 
>  o  nsm_unmonitor()'s only caller doesn't care about the return code,
>     so eliminate it (thanks, Bruce).
> 
>  o  The nsm_handle's reference count is bumped in nlm_lookup_host()
>     so it should be decremented in nlm_destroy_host() to make it
>     easier to see the balance of these two operations.  For the
>     moment we leave nsm_release() public.

That might be a candidate to split out as a separate patch.

> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 78d5f59..b76d9b2 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -107,33 +107,30 @@ int nsm_monitor(const struct nlm_host *host)
>  	return status;
>  }
>  
> -/*
> - * Cease to monitor remote host
> +/**
> + * nsm_unmonitor - Unregister peer notification
> + * @nsm: pointer to nsm_handle of peer to stop monitoring
> + *
> + * If this peer is monitored, this function sends an upcall to
> + * tell the local rpc.statd not to send this peer a notification
> + * when we reboot.
>   */
> -int
> -nsm_unmonitor(struct nlm_host *host)
> +void nsm_unmonitor(struct nsm_handle *nsm)
>  {
> -	struct nsm_handle *nsm = host->h_nsmhandle;
> -	struct nsm_res	res;
> -	int		status = 0;
> +	struct nsm_res res;
>  
> -	if (nsm == NULL)
> -		return 0;

Hm.  Yeah, can't see how it could ever have been called with NULL--might
be worth a changelog comment, though.

--b.

> -	host->h_nsmhandle = NULL;
> +	dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
>  
> -	if (atomic_read(&nsm->sm_count) == 1
> -	 && nsm->sm_monitored && !nsm->sm_sticky) {
> -		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
> +	if (!nsm->sm_monitored)
> +		return;
>  
> -		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
> -		if (status < 0)
> +	if (atomic_read(&nsm->sm_count) == 1 && !nsm->sm_sticky) {
> +		if (nsm_mon_unmon(nsm, SM_UNMON, &res) < 0)
>  			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
> -					host->h_name);
> +					nsm->sm_name);
>  		else
>  			nsm->sm_monitored = 0;
>  	}
> -	nsm_release(nsm);
> -	return status;
>  }
>  
>  /*
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 4ca6f39..e2fa968 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -237,6 +237,7 @@ void		  nsm_release(struct nsm_handle *);
>   * Host monitoring
>   */
>  int		  nsm_monitor(const struct nlm_host *host);
> +void		  nsm_unmonitor(struct nsm_handle *nsm);
>  
>  /*
>   * This is used in garbage collection and resource reclaim
> diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
> index 546b610..896a5e3 100644
> --- a/include/linux/lockd/sm_inter.h
> +++ b/include/linux/lockd/sm_inter.h
> @@ -41,7 +41,6 @@ struct nsm_res {
>  	u32		state;
>  };
>  
> -int		nsm_unmonitor(struct nlm_host *);
>  extern int	nsm_local_state;
>  
>  #endif /* LINUX_LOCKD_SM_INTER_H */
> 
