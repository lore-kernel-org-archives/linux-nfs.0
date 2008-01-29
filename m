From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NLM: break out of nlmsvc_retry_blocked if lockd is
 coming down
Date: Tue, 29 Jan 2008 06:23:12 -0500
Message-ID: <20080129062312.33ba5a54@tleilax.poochiereds.net>
References: <1201548551-23592-1-git-send-email-jlayton@redhat.com>
	<1201548551-23592-2-git-send-email-jlayton@redhat.com>
	<1201548551-23592-3-git-send-email-jlayton@redhat.com>
	<20080129000517.GY16785@fieldses.org>
	<20080128201210.376097e6@tleilax.poochiereds.net>
	<20080129012351.GE16785@fieldses.org>
	<20080128212942.77035005@tupile.poochiereds.net>
	<20080129030249.GJ16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754258AbYA2LXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 06:23:18 -0500
In-Reply-To: <20080129030249.GJ16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Jan 2008 22:02:49 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 28, 2008 at 09:29:42PM -0500, Jeff Layton wrote:
> > On Mon, 28 Jan 2008 20:23:51 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Jan 28, 2008 at 08:12:10PM -0500, Jeff Layton wrote:
> > > > On Mon, 28 Jan 2008 19:05:17 -0500
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Mon, Jan 28, 2008 at 02:29:11PM -0500, Jeff Layton wrote:
> > > > > > It's possible to end up continually looping in
> > > > > > nlmsvc_retry_blocked() even when the lockd kthread has been
> > > > > > requested to come down. I've been able to reproduce this
> > > > > > fairly easily by having an RPC grant callback queued up to
> > > > > > an RPC client that's not bound. If the other host is
> > > > > > unresponsive, then the block never gets taken off the list,
> > > > > > and lockd continually respawns new RPC's.
> > > > > > 
> > > > > > If lockd is going down anyway, we don't want to keep
> > > > > > retrying the blocks, so allow it to break out of this loop.
> > > > > > Additionally, in that situation kthread_stop will have
> > > > > > already woken lockd, so when nlmsvc_retry_blocked returns,
> > > > > > have lockd check for kthread_stop() so that it doesn't end
> > > > > > up calling svc_recv and waiting for a long time.
> > > > > 
> > > > > Stupid question: how is this different from the
> > > > > kthread_stop() coming just after this kthread_should_stop()
> > > > > call but before we call svc_recv()?  What keeps us from
> > > > > waiting in svc_recv() indefinitely after kthread_stop()?
> > > > > 
> > > > 
> > > > Nothing at all, unfortunately :-(
> > > > 
> > > > Since we've taken signalling out of the lockd_down codepath,
> > > > this gets a lot trickier than it used to be. I'm starting to
> > > > wonder if we should go back to sending a signal on lockd_down.
> > > 
> > > OK, thanks.  So do I keep these patches, or not?  This sounds
> > > like a regression (if perhaps a very minor one--I'm not quite
> > > clear).  Help!
> > > 
> > 
> > Well, if we reintroduce signalling in lockd_down then this
> > particular problem goes away. It may be reasonable to add that back
> > into the mix for now.
> > 
> > As to the more general question of whether to keep these patches...
> > 
> > Most of them are pretty innocuous, but the patch to convert to
> > kthread API is the biggest change. 2.6.25 might be a bit aggressive
> > for that. It wouldn't hurt to let the conversion to kthread API
> > brew until 2.6.26.
> > 
> > lockd still does have a use after free problem though, so patch 1/2
> > here might be worth considering even without changing things over to
> > kthreads. I've not tested it on a kernel without the kthread
> > patches, however. I can do that if you think that's the right
> > approach.
> 
> Pfft, I was hoping you'd tell me what to do.
> 
> But, yes, it sounds like dropping the kthread conversion and sending
> in that one bugfix is probably wisest.  (But I assume we should keep
> the first of those three patches, "SUNRPC: spin svc_rqst
> initialization to its own function".)
> 

Yes. The first patch fixes a possible NULL pointer dereference so I
think we want that one here. This patch:

    Subject: [PATCH 2/4] SUNRPC: export svc_sock_update_bufs

...should be safe too, though it's not strictly needed until we convert
lockd to the kthread API.

So at this point we have 2 questions:

1) is there a way to make sure we don't block in svc_recv() without
resorting to signals and can we reasonably mix signaling +
kthread_stop? There may be a chicken and egg problem involved here
though I haven't thought it through yet...

2) can an unresponsive client make lockd loop continuously in
nlmsvc_retry_blocked() and prevent it from serving new lock requests?

I'll try to get answers to both of these...

-- 
Jeff Layton <jlayton@redhat.com>
