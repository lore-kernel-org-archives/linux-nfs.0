From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] [PATCH v2 1/1]: nfsd: Change caching from ino/dev to
 file-handle
Date: Sat, 21 Feb 2009 08:35:26 -0800
Message-ID: <20090221083526.67a640de@tupile.poochiereds.net>
References: <20090124123457.10995.57636.sendpatchset@localhost.localdomain>
	<20090124123511.10995.88449.sendpatchset@localhost.localdomain>
	<20090220154903.1e0c6952@tupile.poochiereds.net>
	<OFA0ED8D34.6B0C2A77-ON65257564.0025E8CE-65257564.0028EFF8@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52511 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbZBUQgI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 21 Feb 2009 11:36:08 -0500
In-Reply-To: <OFA0ED8D34.6B0C2A77-ON65257564.0025E8CE-65257564.0028EFF8@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > ...I can't say I'm thrilled about adding a kthread for this but don't
> > have any specific objections. I wonder if it might be better to just
> > periodically schedule (and reschedule) delayed work to the events queue
> > whenever a cache entry is touched?
> 
> I was originally using queue_delayed_work but found the performance was
> better when using a daemon (in that context, I had also submitted a patch
> to lkml to implement a new API - queue_update_delayed_work - see:
> http://lwn.net/Articles/300919/). I think the problem was due to heavy
> contention with kernel timer locks, especially if there are a lot of
> parallel reads at the same time (contention for the same timer "base" lock
> with regular kernel timers used in other subsystems).
> 
> But I will run a test with delayed work and compare with a daemon and
> report
> what difference I find.
> 
> Bruce had also suggested doing a profile on new vs old kernel. Can someone
> tell me what to run exactly (I got the oprofile compiled in, what user
> commands
> should I run and what should I look for/report)?
> 
> I would like to resubmit after getting Bruce's comments addressed, your
> suggestion about workqueue vs daemon and the other changes suggested.
> 

It seems strange that performance would suffer from using the generic
workqueue for that. The daemon in this patch is just there to clean up
the cache, correct?

If you have valid reasons for choosing a separate kthread to handle the
cleanup then I'm ok with that. It would be a good idea to document
the reasons for that design decision in the patch description so that
we're aware of them. Hard numbers would also help make the case either
way.

As far as oprofile...it's been a while since I've used it but when I do
I usually start with wcohen's page:

http://people.redhat.com/wcohen/

-- 
Jeff Layton <jlayton@redhat.com>
