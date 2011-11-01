Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab1KATnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 15:43:50 -0400
Date: Tue, 1 Nov 2011 20:39:23 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Tejun Heo <tj@kernel.org>
Cc: Jeff Layton <jlayton@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
	fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111101193923.GA9444@redhat.com>
References: <201111010024.16659.rjw@sisk.pl> <20111031233059.GI18855@google.com> <20111101005505.GO18855@google.com> <20111101041337.39077229@tlielax.poochiereds.net> <20111101065958.50addab5@tlielax.poochiereds.net> <20111101163059.GR18855@google.com> <20111101175953.GB5358@redhat.com> <20111101180601.GV18855@google.com> <20111101181329.GA6739@redhat.com> <20111101182753.GW18855@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111101182753.GW18855@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/01, Tejun Heo wrote:
>
> Hello,
>
> On Tue, Nov 01, 2011 at 07:13:29PM +0100, Oleg Nesterov wrote:
> > On 11/01, Tejun Heo wrote:
> > >
> > > Yeah yeah, Trond already pointed it out.  I forgot about the
> > > sigpending special case in schedule(), which I think is rather odd,
> >
> > I disagree with "rather odd" ;)
> >
> > We have a lot of examples of
> >
> > 	current->state = TASK_INTERRUPTIBLE;
> > 	...
> > 	if (signal_pending())
> > 		break;
> > 	schedule();
> >
> > Without that special case in schedule() the code above becomes racy.
> > Just consider __wait_event_interruptible().
>
> But __wait_event_interruptible() does proper set-TASK_*, check
> sigpending and schedule() sequence.  As long as the waker performs
> seg-sigpending, wakeup sequence in the correct order, nothing is
> broken (as w/ any other wakeup conditions).  The special case deals
> with callers which don't check sigpending between set-TASK_* and
> schedule() and that's the part I think is a bit odd.

OK, agreed, __wait_event_interruptible() was a bad example.

Yes, this is only needed for the code which doesn't check
signal_pending() "properly", or doesn't check it at all before
schedule(). OK, say, wait_for_completion_interruptible().
Or schedule_timeout_interruptible().

I suspect we have a lot more examples. Historically linux allows to
set TASK_INTERRUPTIBLE and schedule() without any checks.

> Whether I feel
> odd or not is irrelevant tho - it's already there.

Yes, I don't think we can remove it.

> > > Any better ideas?
> >
> > Well. As a simple (probably temporary) fix, I'd suggest
> >
> > 	#define wait_event_freezekillable(wq, condition)
> > 	{
> > 		freezer_do_not_count();
> > 		__retval = wait_event_killable(condition);
> > 		freezer_count();
> > 		__retval;
> > 	}
> >
> > Do you think it can work?
>
> Yeah, probably.  I was hoping to remove count/do_not_count tho.

Or at least rename it ;)

> Hmmm... maybe we can just flip PF_NOFREEZE instead with a bit of
> modification, I think.

Perhaps.

Or we can add TASK_FREEZABLE (like TASK_WAKEKILL), iirc we already
discussed this some time ago. And probably it makes sense to add the
generic wait_event_state().

Oleg.

