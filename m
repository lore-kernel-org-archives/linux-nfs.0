From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Sun, 22 Jun 2008 20:52:44 -0400
Message-ID: <20080622205244.261a787d@tleilax.poochiereds.net>
References: <20080619101025.24263.patches@notabene>
	<1080619001109.24338@suse.de>
	<20080618210947.2110a541@tleilax.poochiereds.net>
	<18521.50300.572838.123366@notabene.brown>
	<20080619063824.00ca6381@tleilax.poochiereds.net>
	<18526.60523.584503.68076@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbYFWAwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Jun 2008 20:52:55 -0400
In-Reply-To: <18526.60523.584503.68076-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2008 10:20:59 +1000
Neil Brown <neilb@suse.de> wrote:

> On Thursday June 19, jlayton@redhat.com wrote:
> > > 
> > > I wonder why we have all this mucking about this signal masks anyway.
> > > Anyone have any ideas about what it actually achieves?
> > > 
> > 
> > HCH asked me the same question when I did the conversion to kthreads.
> > My interpretation (based on guesswork here) was that we wanted to
> > distinguish between SIGKILL and other allowed signals. A SIGKILL is
> > allowed to interrupt the underlying I/O, but other signals should not.
> 
> Yes, that seems to be the intent of the code, but does it really make
> any sense?
>
> Traditionally, filesystem IO is immune to signals so any signal
> arriving while nfsd is doing filesystem IO is irrelevant.
> I guess network IO can be interrupted, and nfsd is expected to write
> to the network during this time when all-but-SIGKILL is ignored.  So
> maybe the intent was to allow e.g. SIGINT to shut down cleanly, and
> SIGKILL to kill more promptly even if the network was sluggish...
> 
> However I don't think we ever blocked on network write.  And currently
> we try very hard to ensure that there is enough memory to hold a reply
> before we start on a request, so it should definitely never block.
> 
> So until OCFS2 came along, the distinction seems to have been
> meaningless, which is why I questioned it.
> 
> Even with OCFS2 I'm not sure it makes much sense.
> 
> Any time that we shut down NFSD, we really want it to shut down
> promptly.  If SIGINT isn't certain to achieve that, we should just be
> sending SIGKILL.
> Conversely, if it does make sense to keep the two signals, we should
> be educating init.d scripts to make use of them. e.g.
> 
>   killall -2 nfsd
>   sleep 0.1
>   if [ `cat /proc/fs/nfsd/threads` -gt 0 ]
>   then sleep 5
>        killall -9 nfsd
>   fi
> 
> or something more clever.
> 
> I think my leaning is just to remove the distinction.  About the worst
> that can happen if the filesystem decides to respond to the signal is
> that you get a short write or a short read, both of which should be
> correctly handled by the client.
> 

Good points all around. If the sigmask juggling makes no sense, then
I'm OK with removing it. I'd prefer that we simplify the code rather
than trying to get clever with init scripts anyway...

The fact that SuSE (and possibly others) have used SIGKILL to take down
nfsd probably means that removing it is a non-issue (modulo the OCFS
issue your patch fixes).

> 
> This brings up an interesting issue for your kthread conversion.
> The new code uses kthread_stop instead of sending a signal.  That
> means it will block until the threads have completed a request and
> exited.
> If some thread is in a filesystem that is waiting on network IO and
> expects to get a signal if it needs to stop in a hurry, then the
> shutdown could block for a long time.  That might not be what we
> want.
> 
> Particularly as if we are blocked in kthread_stop, then no-one else can
> do a kthread stop....
> 
> I think there are issues here that don't yet have obvious answers.
> Other opinions most welcome.
> 

The latest patch doesn't use kthread_stop with nfsd. I figured it was
best to avoid having multiple takedown methods, and since we're using
signals here anyway, I just kept signaling as the only way to take down
nfsd. Plus, as you mention -- all kthread_stop's are serialized, which
could have meant that nfsd's would take a long time to come down on a
busy box with a lot of them.

As a side note, I'm not terribly thrilled with how kthread_stop is
implemented. I worry that a stuck kthread would block unrelated
kthreads from coming down. I did a patch 6 mos ago or so to make it so
that kthread_stop's could be done in parallel. The downside was that it
added a new field to the task_struct (which is already too bloated,
IMO). It might be worth resurrecting that at some point (possibly
making the new field a union with another field that's unused in
kthreads), or considering a different approach to parallelize
kthread_stop.

-- 
Jeff Layton <jlayton@redhat.com>
