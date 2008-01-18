From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/4] NLM: have nlm_shutdown_hosts kill off all NLM RPC
	tasks
Date: Fri, 18 Jan 2008 16:43:45 -0500
Message-ID: <20080118214345.GM15158@fieldses.org>
References: <1200319518-22422-1-git-send-email-jlayton@redhat.com> <1200319518-22422-2-git-send-email-jlayton@redhat.com> <1200319518-22422-3-git-send-email-jlayton@redhat.com> <1200319518-22422-4-git-send-email-jlayton@redhat.com> <1200319518-22422-5-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58816 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760432AbYARVnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 16:43:49 -0500
In-Reply-To: <1200319518-22422-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 14, 2008 at 09:05:18AM -0500, Jeff Layton wrote:
> If we're shutting down all the nlm_hosts anyway, then it doesn't make
> sense to allow RPC calls to linger. Allowing them to do so can mean
> that the RPC calls can outlive the currently running lockd and can lead
> to a use after free situation.

I assume that all new rpc calls are created by the lockd thread itself
(which also calls nlm_shutdown_hosts(), which guarantees that there
can't be someone about to make an rpc call using the clnt we're
destroying here?

By the way, any idea what the nlm_shutdown_hosts() call in exit_nlm() is
doing?

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/host.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 572601e..8771484 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -377,8 +377,10 @@ nlm_shutdown_hosts(void)
>  	/* First, make all hosts eligible for gc */
>  	dprintk("lockd: nuking all hosts...\n");
>  	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
> -		hlist_for_each_entry(host, pos, chain, h_hash)
> +		hlist_for_each_entry(host, pos, chain, h_hash) {
>  			host->h_expires = jiffies - 1;
> +			rpc_killall_tasks(host->h_rpcclnt);
> +		}
>  	}
>  
>  	/* Then, perform a garbage collection pass */
> -- 
> 1.5.3.7
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
