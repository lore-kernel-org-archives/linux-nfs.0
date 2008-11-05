From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/12] lockd: fix nsm_unmonitor return value
Date: Wed, 5 Nov 2008 17:14:03 -0500
Message-ID: <F2834787-8C32-48D5-85D0-B539DDBFEDC2@oracle.com>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net> <1225915611-2401-1-git-send-email-bfields@citi.umich.edu> <1225915611-2401-2-git-send-email-bfields@citi.umich.edu> <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:16990 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbYKEWOL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 17:14:11 -0500
In-Reply-To: <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 5, 2008, at 3:06 PM, J. Bruce Fields wrote:
> Note that the only caller of nsm_unmonitor has no use for its return
> value.

I noticed this too.

It might be cleaner if we passed the nsm_handle by itself as the  
argument to nsm_{un}monitor.  h_name actually points to the name in  
the nsm_handle.

>
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
> fs/lockd/mon.c                 |    8 +++-----
> include/linux/lockd/sm_inter.h |    2 +-
> 2 files changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 4e7e958..480f197 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -97,15 +97,14 @@ nsm_monitor(struct nlm_host *host)
> /*
>  * Cease to monitor remote host
>  */
> -int
> -nsm_unmonitor(struct nlm_host *host)
> +void nsm_unmonitor(struct nlm_host *host)
> {
> 	struct nsm_handle *nsm = host->h_nsmhandle;
> 	struct nsm_res	res;
> -	int		status = 0;
> +	int		status;
>
> 	if (nsm == NULL)
> -		return 0;
> +		return;
> 	host->h_nsmhandle = NULL;
>
> 	if (atomic_read(&nsm->sm_count) == 1
> @@ -120,7 +119,6 @@ nsm_unmonitor(struct nlm_host *host)
> 			nsm->sm_monitored = 0;
> 	}
> 	nsm_release(nsm);
> -	return status;
> }
>
> /*
> diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/ 
> sm_inter.h
> index 5a5448b..b069598 100644
> --- a/include/linux/lockd/sm_inter.h
> +++ b/include/linux/lockd/sm_inter.h
> @@ -42,7 +42,7 @@ struct nsm_res {
> };
>
> int		nsm_monitor(struct nlm_host *);
> -int		nsm_unmonitor(struct nlm_host *);
> +void		nsm_unmonitor(struct nlm_host *);
> extern int	nsm_local_state;
>
> #endif /* LINUX_LOCKD_SM_INTER_H */
> -- 
> 1.5.5.rc1
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



