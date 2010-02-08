From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: don't clear sm_monitored on nsm_reboot_lookup
Date: Mon, 8 Feb 2010 16:21:17 -0500
Message-ID: <20100208212117.GC14942@fieldses.org>
References: <1265400562-8409-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38514 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802Ab0BHVUy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 16:20:54 -0500
In-Reply-To: <1265400562-8409-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 05, 2010 at 03:09:22PM -0500, Jeff Layton wrote:
> When lockd gets a notify downcall from statd, it'll search its hosts
> cache and then clear the sm_monitored bit on the host it finds. The idea
> is apparently to make lockd redo a SM_MON on the next lock request.
> 
> This is unnecessary and causes the kernel's NSM cache to go out of sync
> with statd. statd doesn't stop monitoring a host when it gets a
> SM_NOTIFY and there's no guarantee that another lock will occur after
> the reclaim and before the unmount. In that event, no SM_UNMON will
> occur.

Thanks, applied.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/lockd/mon.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index f956651..fefa4df 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -349,9 +349,9 @@ retry:
>   * nsm_reboot_lookup - match NLMPROC_SM_NOTIFY arguments to an nsm_handle
>   * @info: pointer to NLMPROC_SM_NOTIFY arguments
>   *
> - * Returns a matching nsm_handle if found in the nsm cache; the returned
> - * nsm_handle's reference count is bumped and sm_monitored is cleared.
> - * Otherwise returns NULL if some error occurred.
> + * Returns a matching nsm_handle if found in the nsm cache. The returned
> + * nsm_handle's reference count is bumped. Otherwise returns NULL if some
> + * error occurred.
>   */
>  struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
>  {
> @@ -370,12 +370,6 @@ struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
>  	atomic_inc(&cached->sm_count);
>  	spin_unlock(&nsm_lock);
>  
> -	/*
> -	 * During subsequent lock activity, force a fresh
> -	 * notification to be set up for this host.
> -	 */
> -	cached->sm_monitored = 0;
> -
>  	dprintk("lockd: host %s (%s) rebooted, cnt %d\n",
>  			cached->sm_name, cached->sm_addrbuf,
>  			atomic_read(&cached->sm_count));
> -- 
> 1.6.6
> 
