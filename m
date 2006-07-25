From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 18:33:20 +1000
Message-ID: <1153816400.21040.153.camel@hole.melbourne.sgi.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5IM4-0003FM-55
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 01:33:28 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5IM4-0005S0-5z
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 01:33:28 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17605.50325.842862.8823@cse.unsw.edu.au>
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

On Tue, 2006-07-25 at 17:13, Neil Brown wrote:
> On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> > These applied cleanly to Linus' GIT yesterday, but clash with
> > today's set of 9 patches.  I'd appreciate advice in picking up
> > those pieces, especially how patch your 007/9 interacts with
> > my 008/11.
> 
> I cannot see a serious conflict...

So far it doesn't seem to as bad as I'd feared ;-)

> > 001 knfsd: move tempsock aging to timer
> 
> Looks good.
> Has the subtle side effect that when we reach our limit on the number
> of permitted tcp connections, the one that is discarded is the one
> that has been open the longest, rather than the one that has be unused
> for the longest.  The comment there says
> 			/*
> 			 * Always select the oldest socket. It's not fair,
> 			 * but so is life
> 			 */
> so I guess it is still correct ('oldest' is ambiguous).  The new
> situation is probably equally (un)fair - would you agree?

Agreed.  The algorithm makes no pretence at fairness, but at least
we're no longer bouncing cachelines in global data structures to
check for old sockets (a infrequent corner case) on every incoming
packet (the main performance path).

> > 002 knfsd: convert sk_inuse to atomic_t
> 
> Have you measured the performance impact of this?

Not in isolation, just as part of this total patchset.

> You gain by taking the spinlock less often, but lose by having to use
> atomic ops even when under the spinlock.

Agreed.

> This could well be a net benefit, and could vary on different archs.
> It would be nice to have measurements - or at least a believable
> argument in favour of a net gain.

Ok, here are some (12 month old) numbers.  Test is an Altix A350
server, IRIX NFS clients mounting over TCP, 32K rsize, streaming
reads from separate files.  N is the number of NICs in the server,
the number of CPUs in the server, and the number of clients
(all 3 increased together).  The number of NUMA nodes is N/2.

N	Throughput, MiB/s	CPU usage, % (max=N*100)
	Before	After		Before	After
---	------	----		-----	-----
4	312	435		350	228
6	500	656		501	418
8	562	804		690	589


> > 004 knfsd: convert sk_reserved to atomic_t
> > 	These move various data structures out from the
> > 	protection of the svc_serv.sv_lock
> 
> Cut/paste error with the comment for this one :-) - fixed.
> Same comment as 002.  I'm guessing that you measure sv_lock as being
> heavily contended. 

Actually, it wasn't contended all that much, although I'm sure if I'd
tried a 16 or 32 cpu test it would have been.  However even without
contention, on NUMA we get lots of CPU wastage from having to bounce
the cachelines of the (effectively) global svc_serv between nodes every
time an nfsd writes to it.  It doesn't help that the CPU scheduler
moves nfsds around to other nodes "to balance the load".

A simple experiment showed running the NFS server with any significant
load was taking far too much CPU, nonlinearly with load, and that CPU
usage could be reduced by limiting the NFS service to a subset of CPUs,
and most effectively by limiting it to a single node.  CPU profiling
showed no outstanding contributions from ia64_spin_lock_contention()
but lots of time doing the normal svc loop.  This combined with
previous experience on NUMA machines was enough to point the finger.

Basically, the goal of these patches is to reduce writes to the global
svc_serv, and it just happened that taking/dropping sv_lock was the
majority (by code lines) of those writes.  BTW, the global `nfsdstat'
is also a significant contributor, I have a patch to help alleviate
that too.


>  Could you quote some measurements?

The difference in CPU usage numbers in the above table should
give you an indication.

> > 005 knfsd: test and set SK_BUSY atomically
> > 	This provides correct update for the SK_BUSY bit
> 
> Whitespace error line 50 :-) - fixed
> 
> Feeling a little uneasy that the rule
>  must call svc_sock_enqueue after clearing SK_BUSY
> is not being obeyed....  

It's a bogus rule.  That comment doesn't really describe
the way SK_BUSY works at all.

> You have more pending patches that touch this code?

These particular lines, no.

Perhaps a little background will help explain why this patch
is necessary (it's pretty unobvious).  Currently, locking works
like this:

a) fields in svc_serv are protected by svc_serv->sv_lock

b) svc_socket is attached to exactly one svc_serv forever
   and is protected by svc_serv->sv_lock too

After patch 011, we have a situation where

a) fields in svc_pool are protected by svc_pool->sp_lock

b) (remaining) fields in svc_serv are protected by svc_serv->sv_lock

c) svc_socket is attached to exactly one svc_serv forever but
   we don't want to use svc_serv->sv_lock

d) svc_socket can float between svc_pool's (although this hardly
   ever happens, unless you have irq spraying, or ethernet bonding
   in round-robin mode, or udp).

So we need some extra synchronisation to ensure that two cpus in
different svc_pool's don't both try to attach the svc_socket to
their svc_pool.  When that happens the lists get confused, with
all kinds of evil consequences (this happened during a customer 
trial, most embarrassing).

The SK_BUSY bit's existing semantics are almost exactly "I'm
attached to a svc_pool", except for atomicity, so I just made it
atomic.  Effectively, it's doing part of the job that sv_lock
used to.

> > 006 knfsd: split svc_serv into pools
> > 	The first major step: split off hot fields from svc_serv
> > 	into new svc_pool structure
> 
>  kmalloc + memset == kzalloc. Fixed.
>    I also took the assignment out of the if and removed
>    the unnecessary cast.

Sure.  Wouldn't kcalloc() be a better fit?

I just noticed there's also a bogus comment added, can you
please apply this incremental patch?

Index: linus-git/net/sunrpc/svcsock.c
===================================================================
--- linus-git.orig/net/sunrpc/svcsock.c	2006-07-25 18:28:48.000000000 +1000
+++ linus-git/net/sunrpc/svcsock.c	2006-07-25 18:29:21.488534818 +1000
@@ -49,7 +49,7 @@
  * 	svc_pool->sp_lock protects most of the fields of that pool.
  * 	svc_serv->sv_lock protects sv_tempsocks, sv_permsocks, sv_tmpcnt.
  *	when both need to be taken (rare), svc_serv->sv_lock is first.
- *	BKL protects svc_serv->sv_nrthread, svc_pool->sp_nrthread
+ *	BKL protects svc_serv->sv_nrthread.
  *	svc_sock->sk_defer_lock protects the svc_sock->sk_deferred list
  *      svc_sock->sk_flags.SK_BUSY prevents a svc_sock being enqueued multiply.
  *


> > 007 knfsd: add svc_get
> 
> Yes... using nr_threads as a pseudo ref count really stinks.
> I wonder if we can make that go away.  Maybe have a 
> refcount separate from nr_threads, and nr_thread != 0 
> causes a refcount of 1...

Or just rename it sv_refcount and stop pretending it means
something else?  It seems silly to have two variables which
are almost exactly the same number, and where the difference
doesn't matter  (IIRC the only places it's actually used as
"number of threads" is for estimating upper bounds on socket
buffer space which is already pretty approximate).

> You remove a comment that you had previously added.  Why?
>   -- not fixed pending explanation...

Umm...where?

> > 008 knfsd: add svc_set_num_threads
> 
> I like this a lot.  I don't see the serious conflict yet.... maybe
> when I try applying the patches.
> 
> > 009 knfsd: use svc_set_num_threads
> > 	Move management of nfsd threads from fs/nfsd to net/sunrpc
> > 010 knfsd: make pools numa aware 2
> > 	The second major step: a pool per node or cpu
> 
> -		printk("nfsd: initialising 1 global pool\n");
> +		printk("nfsd: initialising 1 global thread pool\n");
> Makes it a bit clearer for Jo Sysadmin. - fixed

Beaut.

> All the #if's are a bit of a shame.  I wonder what can be removed.

I did try to isolate them in one patch and one one small set
of functions.  But if we can remove them, that'd be great.

> e.g. if we put
> #ifndef CONFIG_NUMA
> # define node_online_map undefined
> # define any_online_node(x) 
> # define nr_cpus_node(node) num_online_cpus()
> #endif
> then I think svc_pool_map_init won't need any #if ...

Those look almost like good default definitions for <linux/topology.h>,
except it might be convenient to have any_online_node(x) non-empty.

> 
> I'll get you to review that fix...
> 
> Also, I don't see that you need both cpu_to_pool and node_to_pool.
> Could you just have a node_to_pool and on SMP systems treat the
> cpu number as a node number?

Sure, we only need a single array for each direction, I could
have called them "map" and "reversemap" ;-)  I tried to make
their purpose slightly clearer.

> 
> I'll post the interesting revisions in a little while.

Cool.

> 
> Thanks a lot - this is much-needed work.
> 

No worries ;-)

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
