From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Thu, 24 Dec 2009 00:44:58 +0100
Message-ID: <1261611898.18047.37.camel@localhost>
References: <1261015420.1947.54.camel@serenity>
	 <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost>
	 <1261232747.1947.194.camel@serenity>
	 <20091222122557.GA604@atrey.karlin.mff.cuni.cz>
	 <1261498815.13028.63.camel@serenity>  <20091223183912.GE3159@quack.suse.cz>
	 <1261599385.13028.142.camel@serenity>  <1261604952.18047.7.camel@localhost>
	 <1261610013.13028.151.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470AbZLWXpV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2009 18:45:21 -0500
In-Reply-To: <1261610013.13028.151.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-12-23 at 18:13 -0500, Steve Rago wrote: 
> On Wed, 2009-12-23 at 22:49 +0100, Trond Myklebust wrote:
> 
> > > When to send the commit is a complex question to answer.  If you delay
> > > it long enough, the server's flusher threads will have already done most
> > > of the work for you, so commits can be cheap, but you don't have access
> > > to the necessary information to figure this out.  You can't delay it too
> > > long, though, because the unstable pages on the client will grow too
> > > large, creating memory pressure.  I have a second patch, which I haven't
> > > posted yet, that adds feedback piggy-backed on the NFS write response,
> > > which allows the NFS client to free pages proactively.  This greatly
> > > reduces the need to send commit messages, but it extends the protocol
> > > (in a backward-compatible manner), so it could be hard to convince
> > > people to accept.
> > 
> > There are only 2 cases when the client should send a COMMIT: 
> >      1. When it hits a synchronisation point (i.e. when the user calls
> >         f/sync(), or close(), or when the user sets/clears a file
> >         lock). 
> >      2. When memory pressure causes the VM to wants to free up those
> >         pages that are marked as clean but unstable.
> > 
> > We should never be sending COMMIT in any other situation, since that
> > would imply that the client somehow has better information on how to
> > manage dirty pages on the server than the server's own VM.
> > 
> > Cheers
> >   Trond
> 
> #2 is the difficult one.  If you wait for memory pressure, you could
> have waited too long, because depending on the latency of the commit,
> you could run into low-memory situations.  Then mayhem ensues, the
> oom-killer gets cranky (if you haven't disabled it), and stuff starts
> failing and/or hanging.  So you need to be careful about setting the
> threshold for generating a commit so that the client doesn't run out of
> memory before the server can respond.

Right, but this is why we have limits on the total number of dirty pages
that can be kept in memory. The NFS unstable writes don't significantly
change that model, they just add an extra step: once all the dirty data
has been transmitted to the server, your COMMIT defines a
synchronisation point after which you know that the data you just sent
is all on disk. Given a reasonable NFS server implementation, it will
already have started the write out of that data, and so hopefully the
COMMIT operation itself will run reasonably quickly.

Any userland application with basic data integrity requirements will
have the same expectations. It will write out the data and then fsync()
at regular intervals. I've never heard of any expectations from
filesystem and VM designers that applications should be required to
fine-tune the length of those intervals in order to achieve decent
performance.

Cheers
  Trond
