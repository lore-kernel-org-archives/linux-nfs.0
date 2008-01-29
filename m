From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] NLM: break out of nlmsvc_retry_blocked if lockd is
	coming down
Date: Mon, 28 Jan 2008 19:05:17 -0500
Message-ID: <20080129000517.GY16785@fieldses.org>
References: <1201548551-23592-1-git-send-email-jlayton@redhat.com> <1201548551-23592-2-git-send-email-jlayton@redhat.com> <1201548551-23592-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39764 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752426AbYA2AFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 19:05:21 -0500
In-Reply-To: <1201548551-23592-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 02:29:11PM -0500, Jeff Layton wrote:
> It's possible to end up continually looping in nlmsvc_retry_blocked()
> even when the lockd kthread has been requested to come down. I've been
> able to reproduce this fairly easily by having an RPC grant callback
> queued up to an RPC client that's not bound. If the other host is
> unresponsive, then the block never gets taken off the list, and lockd
> continually respawns new RPC's.
> 
> If lockd is going down anyway, we don't want to keep retrying the
> blocks, so allow it to break out of this loop. Additionally, in that
> situation kthread_stop will have already woken lockd, so when
> nlmsvc_retry_blocked returns, have lockd check for kthread_stop() so
> that it doesn't end up calling svc_recv and waiting for a long time.

Stupid question: how is this different from the kthread_stop() coming
just after this kthread_should_stop() call but before we call
svc_recv()?  What keeps us from waiting in svc_recv() indefinitely after
kthread_stop()?

> This patch prevents this continual looping and allows lockd to
> eventually come down, but this can quite some time since lockd
> won't check the condition in the nlmsvc_retry_blocked while loop
> until nlmsvc_grant_blocked returns. That won't happen until
> all of the portmap requests time out.

So, shutdown problems aside, does that mean an unresponsive client can
cause lock to stop serving lock requests in normal operation?

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/svc.c     |    4 ++++
>  fs/lockd/svclock.c |    3 ++-
>  2 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 5752e1b..a0e5318 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -166,6 +166,10 @@ lockd(void *vrqstp)
>  		} else if (time_before(grace_period_expire, jiffies))
>  			clear_grace_period();
>  
> +		/* nlmsvc_retry_blocked can block, so check for kthread_stop */
> +		if (kthread_should_stop())
> +			break;
> +
>  		/*
>  		 * Find a socket with data available and call its
>  		 * recvfrom routine.
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 2f4d8fa..d8324b6 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -29,6 +29,7 @@
>  #include <linux/sunrpc/svc.h>
>  #include <linux/lockd/nlm.h>
>  #include <linux/lockd/lockd.h>
> +#include <linux/kthread.h>
>  
>  #define NLMDBG_FACILITY		NLMDBG_SVCLOCK
>  
> @@ -867,7 +868,7 @@ nlmsvc_retry_blocked(void)
>  	unsigned long	timeout = MAX_SCHEDULE_TIMEOUT;
>  	struct nlm_block *block;
>  
> -	while (!list_empty(&nlm_blocked)) {
> +	while (!list_empty(&nlm_blocked) && !kthread_should_stop()) {
>  		block = list_entry(nlm_blocked.next, struct nlm_block, b_list);
>  
>  		if (block->b_when == NLM_NEVER)
> -- 
> 1.5.3.7
> 
