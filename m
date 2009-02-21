From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH v2 1/1]: nfsd: Change caching from ino/dev to file-handle
Date: Sat, 21 Feb 2009 12:57:08 +0530
Message-ID: <OFA0ED8D34.6B0C2A77-ON65257564.0025E8CE-65257564.0028EFF8@in.ibm.com>
References: <20090124123457.10995.57636.sendpatchset@localhost.localdomain>	<20090124123511.10995.88449.sendpatchset@localhost.localdomain> <20090220154903.1e0c6952@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:41207 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbZBUH1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Feb 2009 02:27:54 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n1L7RjXZ025984
	for <linux-nfs@vger.kernel.org>; Sat, 21 Feb 2009 12:57:45 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1L7P1Q14391142
	for <linux-nfs@vger.kernel.org>; Sat, 21 Feb 2009 12:55:01 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n1L7RiQU016815
	for <linux-nfs@vger.kernel.org>; Sat, 21 Feb 2009 18:27:44 +1100
In-Reply-To: <20090220154903.1e0c6952-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

Thanks for your review comments.

> It would be nice to break up this patchset some. It's very hard to
> review large-scale changes like this, and this is quite frankly not
> code that is often touched by human hands. Being able to do a git
> bisect if we run across bugs after these changes would be a very nice
> thing. It won't be helpful though unless the changes are in smaller
> pieces.

OK, I will try to break this up and send it again.

> In your earlier discussion with Bruce, you mentioned trying to
> determine when to flush the cache. When the exports table is changed
> via exportfs, the exports kernel cache is also flushed. Hooking into
> that might be the best thing...

Thanks for this suggestion - I will look into how to do this.

> I'd also go ahead and get rid of the ra_ prefixes unless you feel
> they're needed. It'd be best to clean this up so that we don't have to
> muck around in here later.

OK.

> > +/* Number of jiffies to cache the file before releasing */
> > +#define NFSD_CACHE_JIFFIES      100
>
> It'd probably be better to express this in terms of HZ so that this is
> a fixed amount of time regardless of how the kernel is compiled.

Definitely it should have been in terms of HZ.

> > +/* List of FH cache entries that has to be cleaned up when they expire
*/
> > +static struct list_head      nfsd_daemon_list;
> > +
>
> ^^^ some more descriptive variable names would be welcome...

OK.

> ...I can't say I'm thrilled about adding a kthread for this but don't
> have any specific objections. I wonder if it might be better to just
> periodically schedule (and reschedule) delayed work to the events queue
> whenever a cache entry is touched?

I was originally using queue_delayed_work but found the performance was
better when using a daemon (in that context, I had also submitted a patch
to lkml to implement a new API - queue_update_delayed_work - see:
http://lwn.net/Articles/300919/). I think the problem was due to heavy
contention with kernel timer locks, especially if there are a lot of
parallel reads at the same time (contention for the same timer "base" lock
with regular kernel timers used in other subsystems).

But I will run a test with delayed work and compare with a daemon and
report
what difference I find.

Bruce had also suggested doing a profile on new vs old kernel. Can someone
tell me what to run exactly (I got the oprofile compiled in, what user
commands
should I run and what should I look for/report)?

I would like to resubmit after getting Bruce's comments addressed, your
suggestion about workqueue vs daemon and the other changes suggested.

Thanks,

- KK

