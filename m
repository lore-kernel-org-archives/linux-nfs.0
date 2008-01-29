From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NLM: break out of nlmsvc_retry_blocked if lockd is
 coming down
Date: Mon, 28 Jan 2008 20:12:10 -0500
Message-ID: <20080128201210.376097e6@tleilax.poochiereds.net>
References: <1201548551-23592-1-git-send-email-jlayton@redhat.com>
	<1201548551-23592-2-git-send-email-jlayton@redhat.com>
	<1201548551-23592-3-git-send-email-jlayton@redhat.com>
	<20080129000517.GY16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbYA2BMO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 20:12:14 -0500
In-Reply-To: <20080129000517.GY16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Jan 2008 19:05:17 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 28, 2008 at 02:29:11PM -0500, Jeff Layton wrote:
> > It's possible to end up continually looping in
> > nlmsvc_retry_blocked() even when the lockd kthread has been
> > requested to come down. I've been able to reproduce this fairly
> > easily by having an RPC grant callback queued up to an RPC client
> > that's not bound. If the other host is unresponsive, then the block
> > never gets taken off the list, and lockd continually respawns new
> > RPC's.
> > 
> > If lockd is going down anyway, we don't want to keep retrying the
> > blocks, so allow it to break out of this loop. Additionally, in that
> > situation kthread_stop will have already woken lockd, so when
> > nlmsvc_retry_blocked returns, have lockd check for kthread_stop() so
> > that it doesn't end up calling svc_recv and waiting for a long time.
> 
> Stupid question: how is this different from the kthread_stop() coming
> just after this kthread_should_stop() call but before we call
> svc_recv()?  What keeps us from waiting in svc_recv() indefinitely
> after kthread_stop()?
> 

Nothing at all, unfortunately :-(

Since we've taken signalling out of the lockd_down codepath, this gets
a lot trickier than it used to be. I'm starting to wonder if we should
go back to sending a signal on lockd_down.

> > This patch prevents this continual looping and allows lockd to
> > eventually come down, but this can quite some time since lockd
> > won't check the condition in the nlmsvc_retry_blocked while loop
> > until nlmsvc_grant_blocked returns. That won't happen until
> > all of the portmap requests time out.
> 
> So, shutdown problems aside, does that mean an unresponsive client can
> cause lock to stop serving lock requests in normal operation?
> 

Possibly.

I think that in general what happens is that blocks eventually get
reinserted into the list with an expire time that is well after the
current jiffies and we eventually hit this condition:

                if (time_after(block->b_when,jiffies)) {
                        timeout = block->b_when - jiffies;
                        break;
                }

...but I was seeing lockd loop in this loop over several iterations
without returning back up to the main lockd loop. I think what was
happening was that we were inserting the block with a later jiffies in
nlmsvc_grant_blocked, but the rpcbind attempts would end up taking
longer than that timeout. So when we returned from
nlmsvc_grant_blocked() that condition would no longer fire, and we'd end up retrying the grant callback again.

As to why we don't see this more often, I'm not sure. I probably need
to experiment a bit more with it to make sure I'm understanding this
correctly.

Let me do that and get back to you...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
