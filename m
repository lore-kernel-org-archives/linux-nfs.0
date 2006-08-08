From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Tue, 08 Aug 2006 20:22:44 +1000
Message-ID: <1155032558.29877.324.camel@hole.melbourne.sgi.com>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAOjc-0006bq-Mm
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 03:22:52 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAOjc-00032M-T2
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 03:22:53 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17624.17621.428870.694339@cse.unsw.edu.au>
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

On Tue, 2006-08-08 at 18:01, Neil Brown wrote:
> On Tuesday August 8, gnb@melbourne.sgi.com wrote:
> > G'day,
> > 
> > Five more patches which fix various issues found in knfsd,
> > mostly directly performance-related.
> 
> Thanks.  I'll have a bit more of a look in a day or two,

Suddenly we've all got a lot of reading to do  ;-)

>  but just
> quickly:
> 
> > 
> > 1 of 5 knfsd: make readahead params cache SMP-friendly
> > 	the racache is a global contention point and performance
> >       bottleneck in some read-dominated workloads, alleviate that
> > 
> 
> Looks good, though might become irrelevant if the 'new' readahead code
> goes ahead (the racache can just be discarded).

I haven't looked at the new readahead code.  Does it no longer
store anything attached to struct file?

> 
> > 2 of 5 knfsd: cache ipmap per TCP socket
> > 	for TCP we can avoid doing a hash lookup on the ip_map
> > 	cache for every RPC call
> 
> Looks sane, but I'm wondering why:
>  
> +static inline int cache_valid(struct cache_head *h)
> +{
> +	return (h->expiry_time != 0 && test_bit(CACHE_VALID, &h->flags));
> +}
> +
> 
> we need to test expiry_time here. Is not the test on CACHE_VALID
> enough?

Hmm, it seemed necessary when I wrote that line.

Looking at current cache.c code, when a cache entry is replaced
with a new one in sunrpc_cache_update(), the old one is left in
a state where CACHE_VALID is set but h->expiry_time == 0.  It's
in that state while it's waiting for the last ref to be dropped.

Before the patch, that state was transient and we would soon after
drop that reference.  After the patch we keep a ref alive for a
long time attached to the svc_sock, so if the ip_map enters that
state we need to drop that ref and lookup again.  That was why I
needed to check for both the VALID flag and a zero expiry time.

The test case that caused the addition of that logic was a 2nd
mount from the same IP address.  In the codebase before your
cache rewrite, that would cause ip_map_lookup() to replace the
existing valid ip_map as described.  I haven't followed the
current logic of ip_map_lookup() to see what it does, but it
does still seem to be an issue.

> > 3 of 5 knfsd: avoid nfsd CPU scheduler overload
> > 	avoid enormous load averages and CPU scheduler overload
> > 	with workloads which generate extremely high call rates
> 
> Not sure I quite understand all the implications of this yet.
> There would have to be lots of active sockets because each socket can
> only be waking one thread.  But that is entirely possible with TCP.

It's real easy when you have 200 active clients on TCP.  It's a
whole lot easier when you have 2000.

> So a request comes in on a TCP socket and we decide not to queue it to
> a process just yet, so it stays on the pool queue.
> That means it doesn't get handled until some process in the queue
> finishes it's request.  
> These seems to suggest quite some room for unfairness on request
> handling.
> That may not be a problem, but I'm not sure...

I don't think it changes the order in which sockets get serviced,
just how many we try to do at the same time.  Maybe I've missed
some subtle side effect.

> Maybe when one thread wakes up it should kick the next one to wake
> up???

??  Not sure what you mean.

We want to keep the number of threads woken to a minimum.
Ideally, a small subset (around 5) of the threads on a pool
are hot in cache and handle all the requests when the calls
are quickly satisfied from memory, and the others kick in only
when calls need to block on disk traffic.

> Or am I missing something.
> 
> > 
> > 4 of 5 knfsd: add RPC pool thread stats
> > 	add some statistics to the svc_pool
> 
> Could we get a paragraph or 3 explaining how to interpret these stats?

For each pool, we see

id <poolid>
ps <packets> <socks-queued> <threads-woken> <overloads-avoided> <threads-timedout>

<poolid>
	the pool id, i.e. 0..npools-1
<packets>
	how many times more data arrived on an NFS socket
	(more precisely, how many times svc_sock_enqueue was called)
<socks-queued>
	how many times a socket was queued, because there were not
	enough nfsd threads to service it
<threads-woken>
	how many times an nfsd thread was woken to handle a socket
<overloads-avoided>
	how many times it was necessary not to wake a thread, because
	too many threads had been woken recently for the cpus in this
	pool to run them
<threads-timedout>
	how many times a thread timed out waiting for a socket to
	need handling



> And we have to do something about svc_put.  With this patch as it
> stands, if you:
>   write some sockets to 'portlist' (with no threads running)
>   look at the pool stats
>   try to start thread
> the ports will have been forgotten because looking at the pool
> stats destroyed the ports...
> 
> > 
> > 5 of 5 knfsd: remove nfsd threadstats
> > 	remove the 'th' stats line from /proc/net/rc/nfsd, it's
> > 	a global contention point in high call rate workloads
> > 
> 
> Yes..... I can appreciate all the problems that you identify.
> But before removing this I would like to have something to replace it.
> Some that gives some sort of vague idea about whether you have a
> suitable number of threads or not.
> Does your pool stats provide that at all?

This patch, no.  Probably the most useful stat in this patch is
the packets per pool, which gives you some idea of how balanced
across pools your traffic is.

I'm still working on another patch (it only recently became possible
with the ktime_t code) which replaces threadstats fully.  That patch
adds nanosecond resolution busy and idle counters to each thread,
then aggregates them per-pool when you read the pool_stats file.
After export to userspace and rate conversion, these numbers tell
us directly what percentage of the nfsds are currently being used.

That patch worked on two platforms some weeks ago, but I'm not sure
it's ready for primetime.  I can post it for comment if you like?

> What I would really like it auto-scaling of the number of threads to
> match the load.  I wonder if that is a good idea?

Yes it is.

The original purpose of the pool_stats file was to drive a userspace
balancing daemon to do that, and I have written most of such a daemon.
The trouble is that measuring demand for nfsds from what meagre stats
it was possible to measure in a 2.6.9 kernel proved difficult.  The
new pool idle counter provides a direct measure of the excess nfsd
capacity, which it will be then easy to write a control loop for.

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
