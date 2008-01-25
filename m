From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 097/100] NLM: have nlm_shutdown_hosts kill off all NLM
 RPC tasks
Date: Fri, 25 Jan 2008 18:55:48 -0500
Message-ID: <20080125185548.5363f046@tleilax.poochiereds.net>
References: <20080125231521.GG25141@fieldses.org>
	<1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-88-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-89-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-90-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-91-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-92-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-93-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-94-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-95-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-96-git-send-email-bfields@citi.umich.edu>
	<1201303040-7779-97-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbYAYXzy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:55:54 -0500
In-Reply-To: <1201303040-7779-97-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Jan 2008 18:17:17 -0500
"J. Bruce Fields" <bfields@citi.umich.edu> wrote:

> From: Jeff Layton <jlayton@redhat.com>
> 
> If we're shutting down all the nlm_hosts anyway, then it doesn't make
> sense to allow RPC calls to linger. Allowing them to do so can mean
> that the RPC calls can outlive the currently running lockd and can
> lead to a use after free situation.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: NeilBrown <neilb@suse.de>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/lockd/host.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index ebec009..76e4bf5 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -379,8 +379,10 @@ nlm_shutdown_hosts(void)
>  	/* First, make all hosts eligible for gc */
>  	dprintk("lockd: nuking all hosts...\n");
>  	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH;
> ++chain) {
> -		hlist_for_each_entry(host, pos, chain, h_hash)
> +		hlist_for_each_entry(host, pos, chain, h_hash) {
>  			host->h_expires = jiffies - 1;
> +			rpc_killall_tasks(host->h_rpcclnt);
> +		}
>  	}
>  
>  	/* Then, perform a garbage collection pass */

I was doing some more testing today, and noticed that the original
problem that this patch is intended to fix resurfaced. I think this
patch just changes the timing on the race somehow, but I haven't tracked
it down completely yet.

There's also another problem -- it's possible for host->h_rpcclnt to be
NULL, and that has special meaning for rpc_killall_tasks. For now, I
suggest that we drop this patch until I have a chance to work on it
further.

The other related patches in this series should be OK, however.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
