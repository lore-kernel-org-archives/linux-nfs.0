From: Dave Chinner <david@fromorbit.com>
Subject: Re: high latency NFS
Date: Mon, 4 Aug 2008 12:14:26 +1000
Message-ID: <20080804021426.GF6119@disturbed>
References: <200807241311.31457.shuey@purdue.edu> <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au> <200807302235.50068.shuey@purdue.edu> <20080731031512.GA26203@fieldses.org> <18577.25513.494821.481623@notabene.brown> <20080801072320.GE6201@disturbed> <20080801191559.GI7764@fieldses.org> <20080804003206.GB6119@disturbed> <20080804011158.GA8066@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail01.adl6.internode.on.net ([203.16.214.146]:1148 "EHLO
	ipmail01.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753931AbYHDCOd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2008 22:14:33 -0400
In-Reply-To: <20080804011158.GA8066@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 03, 2008 at 09:11:58PM -0400, J. Bruce Fields wrote:
> On Mon, Aug 04, 2008 at 10:32:06AM +1000, Dave Chinner wrote:
> > On Fri, Aug 01, 2008 at 03:15:59PM -0400, J. Bruce Fields wrote:
> > > On Fri, Aug 01, 2008 at 05:23:20PM +1000, Dave Chinner wrote:
> > > > On Thu, Jul 31, 2008 at 05:03:05PM +1000, Neil Brown wrote:
> > > > > You might want to track the max length of the request queue too and
> > > > > start more threads if the queue is long, to allow a quick ramp-up.
> > > > 
> > > > Right, but even request queue depth is not a good indicator. You
> > > > need to leep track of how many NFSDs are actually doing useful
> > > > work. That is, if you've got an NFSD on the CPU that is hitting
> > > > the cache and not blocking, you don't need more NFSDs to handle
> > > > that load because they can't do any more work than the NFSD
> > > > that is currently running is. 
> > > > 
> > > > i.e. take the solution that Greg banks used for the CPU scheduler
> > > > overload issue (limiting the number of nfsds woken but not yet on
> > > > the CPU),
> > > 
> > > I don't remember that, or wasn't watching when it happened.... Do you
> > > have a pointer?
> > 
> > Ah, I thought that had been sent to mainline because it was
> > mentioned in his LCA talk at the start of the year. Slides
> > 65-67 here:
> > 
> > http://mirror.linux.org.au/pub/linux.conf.au/2007/video/talks/41.pdf
> 
> OK, so to summarize: when the rate of incoming rpc's is very high (and,
> I guess, when we're serving everything out of cache and don't have IO
> wait), all the nfsd threads will stay runable all the time.  That keeps
> userspace processes from running (possibly for "minutes").  And that's a
> problem even on a server dedicated only to nfs, since it affects portmap
> and rpc.mountd.

In a nutshell.

> The solution is given just as "limit the # of nfsd's woken but not yet
> on CPU."  It'd be interesting to see more details.

Simple counters, IIRC (memory hazy so it might be a bit different).
Basically, when we queue a request we check a wakeup counter. If
the wakeup counter is less than a certain threshold (e.g. 5) we
issue a wakeup to get another NFSD running. When the NFSD first
runs and dequeues a request, it then decrements the wakeup counter,
effectively marking that NFSD as busy doing work. IIRC a small
threshold was necessary to ensure we always had enough NFSDs ready
to run if there was some I/O going on (i.e. a mixture of blocking
and non-blocking RPCs).

i.e. we need to track the wakeup-to-run latency to prevent waking too
many NFSDs and loading the run queue unnecessarily.

> Off hand, this seems like it should be at least partly the scheduler's
> job.

Partly, yes, in that the scheduler overhead shouldn't increase when we
do this. However, from an efficiency point of view, if we are blindly
waking NFSDs when it is not necessary then (IMO) we've got an NFSD
problem....

> E.g. could we tell it to schedule all the nfsd threads as a group?
> I suppose the disadvantage to that is that we'd lose information about
> how many threads are actually needed, hence lose the chance to reap
> unneeded threads?

I don't know enough about how the group scheduling works to be able
to comment in detail. In theory it sounds like it would prevent
the starvation problems, but if it prevents implementation of
dynamic NFSD pools then I don't think it's a good idea....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
