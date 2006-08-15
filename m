From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Tue, 15 Aug 2006 21:38:45 +1000
Message-ID: <1155641925.17651.162.camel@hole.melbourne.sgi.com>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
	<17624.29880.852610.256270@cse.unsw.edu.au>
	<1155097112.16378.46.camel@hole.melbourne.sgi.com>
	<17633.19689.468810.139040@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCxG2-0003rQ-Mn
	for nfs@lists.sourceforge.net; Tue, 15 Aug 2006 04:38:54 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCxG1-0007cq-VR
	for nfs@lists.sourceforge.net; Tue, 15 Aug 2006 04:38:55 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17633.19689.468810.139040@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2006-08-15 at 14:26, Neil Brown wrote:
> On Wednesday August 9, gnb@melbourne.sgi.com wrote:
> > 
> > Ok, for comment only...this patch won't apply for several reasons
> > but hopefully you can get the gist of what I was trying to do.
> 
> Thanks.  It does give a good gist.
> 
> Trying to remember back to why I did the current stats the way I did,
> and comparing with this, the big difference seems to be how
> burst-behaviour is recognised.
> 
> By counting only idle and busy time, your stats would not be able to
> distinguish between a load of (say) 10 requests each requiring 1ms
> arriving at once, and those same ten arriving at 1ms intervals.

That's right, my busy+idle stats effectively integrate the time
spent servicing requests after they're dequeued, so time spent
limited by availability of nfsds is not measured.

However the sockets-queued stat from my other stats patch lets
you detect that situation.

My first stab at automatic control was to use sockets-queued,
expressed as %age of incoming packets, to decide when to increase
the number of nfsds.  To decide when to decrease, I tweaked
the svc_recv() timeout down to 30 seconds and measured the
rate at which those occur as a %age of packets arriving.
Then, it got...interesting (see below).

> The first scenario can benefit from having 10 threads (lower
> latency).  The second would not.

Yes, this is one aspect of the burst problem.

> Is that an issue?  I'm not certain, but I have a feeling that NFS
> traffic is likely to be fairly bursty.  

Yes, burstiness is a problem for the automatic control algorithm
when there are a small to medium number of clients (with large
numbers of clients, the burstiness tends to average out).

To avoid oscillations you need damping, and that limits your
ability to respond to the start of bursts.  So you need to
configure spare capacity to handle bursts in the short term.
You also need some hysteresis for the long term, so that bursts
ratchet up the number of threads and the second burst has
the capacity it needs.

But this is true no matter which metrics you use to make your
control decisions.

> In the interests of minimising
> latency I think we want to auto-configure to be ready to catch that
> burst.

Agreed.

> I imagine the ideal auto-configure regime would be to ramp up the
> number of threads fairly quickly on demand, and then have them slowly
> drop away when the demand isn't there.

Precisely.

On Irix, the documented behaviour of the default tunables is:

* limit the rate of thread creation so that a pool-equivalent
  can go from minimum threads (1) to maximum threads (32) in
  1 second.

* threads die when they have been completely idle for 65 seconds.

These were the settings chosen to be most generally useful
across the widest range of workloads.

> The minimal stat I would want would be something like a count of the
> number of times that 'svc_sock_enqueue' found that pool->sp_threads
> was list_empty.

Sockets-queued in the "add pool stats" patch.

>   While that number is increasing we add threads at
> some set rate (1 per second?).  When it stops increasing we drop
> threads very slowly (1 per hour?).

This is very close to what I originally planned, and is
similar to Irix' documented behaviour.

The problem with this approach is accounting for the case of a
sustained heavy load.  Imagine that for many consecutive control
intervals, more packets arrive than can be handled by the number
of CPUs available.  Socket queues grow until an equilibrium is
reached when TCP closes windows sufficiently that clients can't
send any more calls.

In this situation the machine is hitting the "queuing sockets
because no threads are available" case on every single packet.
The algorithm you describe thus decides to add a thread every
time it makes a control decision, and the number of threads
grows until the load stops or we reach the limit on the number
of threads.

Those new threads are not actually helping because there isn't
enough CPU to run them.  In fact, without the "avoid CPU overload"
patch the machine gets very sick because CPU run queues are
enormous and all the spare CPU time goes into the scheduler.

On Linux, each of these new threads is now allocating 1MiB+2pages,
at exactly the same time when memory is under pressure from
all the queued skbuffs.

To avoid this situation, the control loop decision needs to
be made more complex (this is why I added an overloads-avoided
metric to the pool stats).  But then you end up juggling several
different metrics trying to figure out whether the machine is
idle, or in one of the possible equilibrium states, or in a
burst, or in sustained demand increase, or what.

In short, it gets messy and I was hoping using %idle would make
it clean.

> Possibly the %idle number could be used to change the rate of
> rise/decline.  But I'm not convinced that it can be used all by
> itself.

I haven't done all the experiments yet, so I can't comment.

I will say that the busy/idle stats are one useful way of measuring
how well an automatic control loop is working.  The other would be
to simulate a bursty client and measure average latency vs burst length
at the client (I haven't done this in my client yet).

BTW, the problem that has me worried about the busy/idle stats is
the efficiency and scalability of getting the monotonic clock sample
on 32bit x86 platforms.  Current measurements indicate a major problem
there, and I might need to try to tweak the HPET driver before the
busy/idle stats are usable.

I have the skeleton of a user-space control loop written, I can
post that if you like.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
