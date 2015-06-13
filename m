Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34596 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbbFMXWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2015 19:22:25 -0400
Date: Sat, 13 Jun 2015 18:22:22 -0500
From: Tejun Heo <tj@kernel.org>
To: Petr Mladek <pmladek@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
        Richard Weinberger <richard@nod.at>,
        Steven Rostedt <rostedt@goodmis.org>,
        David Woodhouse <dwmw2@infradead.org>, linux-mtd@lists.infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Chris Mason <clm@fb.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>,
        Michal Hocko <mhocko@suse.cz>, live-patching@vger.kernel.org,
        linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 07/18] kthread: Make iterant kthreads freezable by
 default
Message-ID: <20150613232222.GB346@mtj.duckdns.org>
References: <1433516477-5153-1-git-send-email-pmladek@suse.cz>
 <1433516477-5153-8-git-send-email-pmladek@suse.cz>
 <20150609072003.GY21465@mtj.duckdns.org>
 <20150609155313.GC9409@pathway.suse.cz>
 <20150610043154.GG11955@mtj.duckdns.org>
 <20150612132440.GH9409@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150612132440.GH9409@pathway.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey, Petr.

On Fri, Jun 12, 2015 at 03:24:40PM +0200, Petr Mladek wrote:
> > * While hibernating, freezing writeback workers and whoever else which
> >   might issue IOs.  This is because we have to thaw devices to issue
> >   IOs to write out the prepared hibernation image.  If new IOs are
> >   issued from page cache or whereever when the devices are thawed for
> >   writing out the hibernation image, the hibernation image and the
> >   data on the disk deviate.
> 
> Just an idea. I do not say that it is a good solution. If we already
> thaw devices needed to write the data. It should be possible to thaw
> also kthreads needed to write the data.

Sure, we'd end up having to mark the involved kthreads and whatever
they may depend on with "freeze for snapshotting but not for writing
out images".

> >   Note that this only works because currently none of the block
> >   drivers which may be used to write out hibernation images depend on
> >   freezable kthreads and hopefully nobody issues IOs from unfreezable
> >   kthreads or bh or softirq, which, I think, can happen with
> >   preallocated requests or bio based devices.
> 
> It means that some kthreads must be stopped, some must be available,
> and we do not mind about the rest. I wonder which group is bigger.
> It might help to decide about the more safe default. It is not easy
> for me to decide :-/

Please do not spread freezer more than necessary.  It's not about
which part is larger but about not completely losing track of what's
going on.  At least now we can say "this needs freezer because XYZ"
and that XYZ actually points to something which needs to be
synchronized for PM operations.  If we flip the polarity, all we're
left with is "this can't be frozen because it deadlocks with XYZ"
which is a lot less information, both in terms of relevance and
amount, than the other way around.

> >   This is a very brittle approach.  Instead of controlling things
> >   where it actually can be controlled - the IO ingress point - we're
> >   trying to control all its users with a pretty blunt tool while at
> >   the same time depending on the fact that some of the low level
> >   subsystems don't happen to make use of the said blunt tool.
> >
> >   I think what we should do is simply blocking all non-image IOs from
> >   the block layer while writing out hibernation image.  It'd be
> >   simpler and a lot more reliable.
> 
> This sounds like an interesting idea to me. Do you already have some
> more precise plan in mind?

Unfortunately, no.  No concrete plans or patches yet but even then I'm
pretty sure we don't wanna head the other direction.  It's just wrong.

> Unfortunately, for me it is not easy to judge it. I wonder how many
> interfaces would need to get hacked to make this working.

Not much really.  We just need a way to flag IOs to write image - be
that a bio / request flag or task flag and then a way to tell the
block layer to block everything else.

> Also I wonder if they would be considered as a hack or a clean
> solution by the affected parties. By other words, I wonder if it is
> realistic.

I'd say it's pretty realistic.  This is synchronizing where the
operations need to be synchronized.  What part would be hackish?

> > * Device drivers which interact with their devices in a fully
> >   synchronous manner so that blocking the kthread always reliably
> >   quiesces the device.  For this to be true, the device shouldn't
> >   carry over any state across the freezing points.  There are drivers
> >   which are actually like this and it works for them.
> 
> I am trying to sort it in my head. In each case, we need to stop these
> kthreads in some well defined state. Also the kthread (or device)
> must be able to block the freezing if they are not in the state yet.

Whether kthreads need to be stopped or not is periphery once you have
a proper blocking / draining mechanism.  The thing is most of these
kthreads are blocked on requests coming down from upper layers anyway.
Once you plug queueing of new requests and drain whatever is in
flight, the kthread isn't gonna do anything anyway.

> The stop points are defined by try_to_freeze() now. And freezable
> kthreads block the freezer until they reach these points.

I'm repeating myself but that only works for fully synchronous devices
(ie. kthread processing one command at a time).  You need to drain
whatever is in flight too.  You can't do that with simple freezing
points.  There's a reason why a lot of drivers can't rely on freezer
for PM operations.  Drivers which can fully depend on freezer would be
minority.

> >   However, my impression is that people don't really scrutinize why
> >   freezer works for a specific case and tend to spray them all over
> >   and develop a fuzzy sense that freezing will somehow magically make
> >   the driver ready for PM operatoins.  It doesn't help that freezer is
> >   such a blunt tool and our historical usage has always been fuzzy -
> >   in the earlier days, we depended on freezer even when we knew it
> >   wasn't sufficient probably because updating all subsystems and
> >   drivers were such a huge undertaking and freezer kinda sorta works
> >   in many cases.
> 
> I try to better understand why freezer is considered to be a blunt
> tool. Is it because it is a generic API, try_to_freeze() is put on
> "random" locations, so that it does not define the safe point
> precisely enough?

Not that.  I don't know how to explain it better.  Hmmm... okay, let's
say there's a shared queue Q and N users o fit.  If you wanna make Q
empty and keep it that way for a while, the right thing to do is
blocking new queueing and then wait till Q drains - you choke the
entity that you wanna control.

Instead of that, freezer is trying to block the "N" users part.  In
majority of cases, it blocks enough but it's pretty difficult to be
sure whether you actually got all N of them (as some of them may not
involve kthreads at all or unfreezable kthreads might end up doing
those operations too on corner cases) and it's also not that clear
whether blocking the N users actually make Q empty.  Maybe there are
things which can be in flight asynchronously on Q even all its N users
are blocked.  This is inherently finicky.

> >   IMHO we'd be a lot better served by blocking the kthread from PM
> >   callbacks explicitly for these drivers to unify control points for
> >   PM operations and make what's going on a lot more explicit.  This
> >   will surely involve a bit more boilerplate code but with the right
> >   helpers it should be mostly trivial and I believe that it's likely
> >   to encourage higher quality PM operations why getting rid of this
> >   fuzzy feeling around the freezer.
> 
> I agree. There is needed some synchronization between the device
> drivers and kthread to make sure that they are on the same note.

No, not kthreads.  They should be synchronizing on the actual entities
that they wanna keep empty.  Where the kthreads are don't matter at
all.  It's the wrong thing to control in most cases.  In the minority
of cases where blocking kthread is enough, we can do that explicitly
from the usual PM callbacks.

> If I get this correctly. It works the following way now. PM notifies
> both kthreads (via freezer) and device drivers (via callbacks) about
> that the suspend is in progress. They are supposed to go into a sane
> state. But there is no explicit communication between the kthread
> and the driver.
> 
> What do you exactly mean with the callbacks? Should they set some
> flags that would navigate the kthread into some state?

The driver PM callbacks.

> > I'm strongly against this.  We really don't want to make it even
> > fuzzier.  There are finite things which need to be controlled for PM
> > operations and I believe what we need to do is identifying them and
> > implementing explicit and clear control mechanisms for them, not
> > spreading this feel-good mechanism even more, further obscuring where
> > those points are.
> 
> I see. This explains why you are so strongly against changing the
> default. I see the following in the kernel sources:
> 
> 	 61  set_freezable()
> 	 97  kthread_create()
> 	 259 kthread_run()
> 
> I means that only about 17% kthreads are freezable these days.

And some of them probably don't even need it.

> > This becomes the game of "is it frozen ENOUGH yet?"  and that "enough"
> > is extremely difficult to determine as we're not looking at the choke
> > spots at all and freezable kthreads only cover part of kernel
> > activity.  The fuzzy enoughness also actually inhibits development of
> > proper mechanisms - "I believe this is frozen ENOUGH at this point so
> > it is probably safe to assume that X, Y and Z aren't happening
> > anymore" and it usually is except when it's not.
> 
> I am not sure what you mean by frozen enough? I think that a tasks
> is either frozen or not. Do I miss something, please?

Please refer back to the above Q and N users example.  Sure, each
kthread is either frozen or thawed; however, whether you got all of N
or not is pretty difficult to tell reliably and I'd say a lot of the
currently existing freezer usage is pretty fuzzy on that respect.

Thanks.

-- 
tejun
