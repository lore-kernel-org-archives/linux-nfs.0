Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579Ab1KALAu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 07:00:50 -0400
Date: Tue, 1 Nov 2011 06:59:58 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        Oleg Nesterov <oleg@redhat.com>, linux-pm@vger.kernel.org,
        linux-cifs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
 fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111101065958.50addab5@tlielax.poochiereds.net>
In-Reply-To: <20111101041337.39077229@tlielax.poochiereds.net>
References: <20111031221743.GA18855@google.com>
	<201111010024.16659.rjw@sisk.pl>
	<20111031233059.GI18855@google.com>
	<20111101005505.GO18855@google.com>
	<20111101041337.39077229@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Nov 2011 04:13:37 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 31 Oct 2011 17:55:05 -0700
> Tejun Heo <tj@kernel.org> wrote:
> 
> > Hey, again.
> > 
> > On Mon, Oct 31, 2011 at 04:30:59PM -0700, Tejun Heo wrote:
> > > I can't remember one off the top of my head but I'm pretty sure there
> > > at least are few which expect tight inter-locking between sleeps and
> > > wakeups.  I'll look for examples and post reply.  ISTR them being
> > > kernel threads so this might not apply directly but it's still a
> > > dangerous game to play.
> > 
> > Hmm... I couldn't find KILLABLE used like that but here are two
> > UNINTERRUPTIBLE sleep examples.
> > 
> > * kthread_start() depends on the fact that a kthread won't be woken up
> >   from UNINTERRUPTIBLE sleep spuriously.
> > 
> > * jfs_flush_journal() doesn't check whether the wakeup was spurious
> >   after waiting if !tblkGC_COMMITTED.
> > 
> > Maybe we can re-define KILLABLE as killable && freezable but IMHO that
> > requires pretty strong rationales.  If at all possible, let's not
> > diddle with that if it can be worked around some other way.
> > 
> > Thank you.
> > 
> 
> (cc'ing Trond and the linux-nfs mailing list -- fwiw, he maintains the
> NFS client code -- Bruce is the NFS server maintainer and probably has
> little interest in this thread).
> 
> The main reason for this change is primarily that we have people with
> laptops and nfs and cifs mounts that sometimes fail to suspend.
> 
> IIUC, the TASK_KILLABLE was mostly added to ensure that file-store
> writes would be uninterruptible, but still allow those tasks to be
> killed if the process is going down anyway.
> 
> The intr/nointr mount options in NFS have been deprecated since
> TASK_KILLABLE was added. The scheme now is basically that those sleeps
> ignore any signals except for fatal ones. So, that knob is meaningless
> and has been for a long time now.
> 
> cifs never had a working intr/nointr knob, but signal handling while
> waiting for replies was always a difficult thing to handle correctly. I
> don't think the right answer is to go back to using such a knob in cifs
> or nfs.
> 
> I suppose we could look at going back to the world of complicated
> signal handling and TASK_INTERRUPTIBLE, but that's not a trivial change
> either. The TASK_WAKE_FREEZABLE flag you mention might make more sense
> than doing that.
> 

Also, since task state and signal handling clearly isn't my forte...can
you clarify what the main difference is in using a TASK_KILLABLE sleep
vs. TASK_INTERRUPTIBLE with all signals but SIGKILL blocked?

I know that the process state would end up different (S vs. D state).
Is there anything else we'd need to be concerned with if we converted
all these call sites to use such a scheme in lieu of a new
TASK_WAKE_FREEZABLE flag or similar?

-- 
Jeff Layton <jlayton@redhat.com>
