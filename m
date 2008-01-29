From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] NLM: break out of nlmsvc_retry_blocked if lockd is
	coming down
Date: Mon, 28 Jan 2008 20:23:51 -0500
Message-ID: <20080129012351.GE16785@fieldses.org>
References: <1201548551-23592-1-git-send-email-jlayton@redhat.com> <1201548551-23592-2-git-send-email-jlayton@redhat.com> <1201548551-23592-3-git-send-email-jlayton@redhat.com> <20080129000517.GY16785@fieldses.org> <20080128201210.376097e6@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47270 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbYA2BXz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 20:23:55 -0500
In-Reply-To: <20080128201210.376097e6-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 08:12:10PM -0500, Jeff Layton wrote:
> On Mon, 28 Jan 2008 19:05:17 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jan 28, 2008 at 02:29:11PM -0500, Jeff Layton wrote:
> > > It's possible to end up continually looping in
> > > nlmsvc_retry_blocked() even when the lockd kthread has been
> > > requested to come down. I've been able to reproduce this fairly
> > > easily by having an RPC grant callback queued up to an RPC client
> > > that's not bound. If the other host is unresponsive, then the block
> > > never gets taken off the list, and lockd continually respawns new
> > > RPC's.
> > > 
> > > If lockd is going down anyway, we don't want to keep retrying the
> > > blocks, so allow it to break out of this loop. Additionally, in that
> > > situation kthread_stop will have already woken lockd, so when
> > > nlmsvc_retry_blocked returns, have lockd check for kthread_stop() so
> > > that it doesn't end up calling svc_recv and waiting for a long time.
> > 
> > Stupid question: how is this different from the kthread_stop() coming
> > just after this kthread_should_stop() call but before we call
> > svc_recv()?  What keeps us from waiting in svc_recv() indefinitely
> > after kthread_stop()?
> > 
> 
> Nothing at all, unfortunately :-(
> 
> Since we've taken signalling out of the lockd_down codepath, this gets
> a lot trickier than it used to be. I'm starting to wonder if we should
> go back to sending a signal on lockd_down.

OK, thanks.  So do I keep these patches, or not?  This sounds like a
regression (if perhaps a very minor one--I'm not quite clear).  Help!

--b.

> 
> > > This patch prevents this continual looping and allows lockd to
> > > eventually come down, but this can quite some time since lockd
> > > won't check the condition in the nlmsvc_retry_blocked while loop
> > > until nlmsvc_grant_blocked returns. That won't happen until
> > > all of the portmap requests time out.
> > 
> > So, shutdown problems aside, does that mean an unresponsive client can
> > cause lock to stop serving lock requests in normal operation?
> > 
> 
> Possibly.
> 
> I think that in general what happens is that blocks eventually get
> reinserted into the list with an expire time that is well after the
> current jiffies and we eventually hit this condition:
> 
>                 if (time_after(block->b_when,jiffies)) {
>                         timeout = block->b_when - jiffies;
>                         break;
>                 }
> 
> ...but I was seeing lockd loop in this loop over several iterations
> without returning back up to the main lockd loop. I think what was
> happening was that we were inserting the block with a later jiffies in
> nlmsvc_grant_blocked, but the rpcbind attempts would end up taking
> longer than that timeout. So when we returned from
> nlmsvc_grant_blocked() that condition would no longer fire, and we'd end up retrying the grant callback again.
> 
> As to why we don't see this more often, I'm not sure. I probably need
> to experiment a bit more with it to make sure I'm understanding this
> correctly.
> 
> Let me do that and get back to you...
