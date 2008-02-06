From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Wed, 6 Feb 2008 13:53:27 -0500
Message-ID: <20080206135327.136b9c4f@barsoom.rdu.redhat.com>
References: <1202322103-13716-1-git-send-email-jlayton@redhat.com>
	<1202322103-13716-2-git-send-email-jlayton@redhat.com>
	<1202322103-13716-3-git-send-email-jlayton@redhat.com>
	<1202322991.8549.7.camel@heimdal.trondhjem.org>
	<20080206134702.14c9d4f0@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:46367 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758658AbYBFTwK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 14:52:10 -0500
In-Reply-To: <20080206134702.14c9d4f0-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Feb 2008 13:47:02 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 06 Feb 2008 13:36:31 -0500
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > 
> > On Wed, 2008-02-06 at 13:21 -0500, Jeff Layton wrote:
> > > Have lockd_up start lockd using kthread_run. With this change,
> > > lockd_down now blocks until lockd actually exits, so there's no
> > > longer need for the waitqueue code at the end of lockd_down. This
> > > also means that only one lockd can be running at a time which
> > > simplifies the code within lockd's main loop.
> > > 
> > > This also adds a check for kthread_should_stop in the main loop of
> > > nlmsvc_retry_blocked and after that function returns. There's no
> > > sense continuing to retry blocks if lockd is coming down anyway.
> > > 
> > > The main difference between this patch and earlier ones is that it
> > > changes lockd_down to again send SIGKILL to lockd when it's coming
> > > down. svc_recv() uses schedule_timeout, so we can end up blocking
> > > there for a long time if we end up calling into it after
> > > kthread_stop wakes up lockd. Sending a SIGKILL should help ensure
> > > that svc_recv returns quickly if this occurs.
> > > 
> > > Because kthread_stop blocks until the kthread actually goes down,
> > > we have to send the signal before calling it. This means that
> > > there is a very small race window like this where lockd_down
> > > could block for a long time:
> > 
> > Having looked again at the code, could you please remind me _why_ we
> > need to signal the process?
> > 
> > AFAICS, kthread_stop() should normally wake the process up if it is
> > in the schedule_timeout() state in svc_recv() since it uses
> > wake_up_process(). Shouldn't the only difference be that svc_recv()
> > will return -EAGAIN instead of -EINTR?
> > 
> > If so, why can't we just forgo the signal?
> > 
> 
> There's no guarantee that kthread_stop() won't wake up lockd before
> schedule_timeout() gets called, but after the last check for
> kthread_should_stop().
> 

Sorry, I hit send too quick...

I'm certainly open to alternatives to signaling, but having a pending
signal seems to be the best way to ensure that we don't end up blocking
in schedule_timeout() here.

As a side note, I've rolled up a patch to add a kthread_stop_sig()
variant that will use "force_sig" to wake up a kthread instead of just
waking it up. I've not tested it yet, but once I do and if we can get
it in then we should be able to close the race I'm talking about in
this patch description as well...

-- 
Jeff Layton <jlayton@redhat.com>
