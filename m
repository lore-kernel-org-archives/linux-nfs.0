From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 17:13:25 +1000
Message-ID: <17605.50325.842862.8823@cse.unsw.edu.au>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5H7J-00056P-U5
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 00:14:10 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5H7J-0003XZ-Nk
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 00:14:10 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Tuesday July 25
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

On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> G'day,
> 
> These 11 patches make the Linux NFS server scale gracefully
> on large NUMA and SMP machines.  The two basic approaches
> are to eliminate code (such as tempsock aging) from the main
> svc loop, and to move the hot locks and data structures from
> svc_serv into a new svc_pool which can be allocated per-node
> or per-cpu.
> 

Sounds incredibly sensible.

> These applied cleanly to Linus' GIT yesterday, but clash with
> today's set of 9 patches.  I'd appreciate advice in picking up
> those pieces, especially how patch your 007/9 interacts with
> my 008/11.

I cannot see a serious conflict...

> 
> 001 knfsd: move tempsock aging to timer

Looks good.
Has the subtle side effect that when we reach our limit on the number
of permitted tcp connections, the one that is discarded is the one
that has been open the longest, rather than the one that has be unused
for the longest.  The comment there says
			/*
			 * Always select the oldest socket. It's not fair,
			 * but so is life
			 */
so I guess it is still correct ('oldest' is ambiguous).  The new
situation is probably equally (un)fair - would you agree?

> 002 knfsd: convert sk_inuse to atomic_t

Have you measured the performance impact of this?

You gain by taking the spinlock less often, but lose by having to use
atomic ops even when under the spinlock.
This could well be a net benefit, and could vary on different archs.
It would be nice to have measurements - or at least a believable
argument in favour of a net gain.

> 003 knfsd: use new lock for svc_sock deferred list

Yep, good.

> 004 knfsd: convert sk_reserved to atomic_t
> 	These move various data structures out from the
> 	protection of the svc_serv.sv_lock

Cut/paste error with the comment for this one :-) - fixed.
Same comment as 002.  I'm guessing that you measure sv_lock as being
heavily contended.  Could you quote some measurements?

> 005 knfsd: test and set SK_BUSY atomically
> 	This provides correct update for the SK_BUSY bit

Whitespace error line 50 :-) - fixed

Feeling a little uneasy that the rule
 must call svc_sock_enqueue after clearing SK_BUSY
is not being obeyed....  
You have more pending patches that touch this code?

> 006 knfsd: split svc_serv into pools
> 	The first major step: split off hot fields from svc_serv
> 	into new svc_pool structure

 kmalloc + memset == kzalloc. Fixed.
   I also took the assignment out of the if and removed
   the unnecessary cast.

> 007 knfsd: add svc_get

Yes... using nr_threads as a pseudo ref count really stinks.
I wonder if we can make that go away.  Maybe have a 
refcount separate from nr_threads, and nr_thread != 0 
causes a refcount of 1...

You remove a comment that you had previously added.  Why?
  -- not fixed pending explanation...

> 008 knfsd: add svc_set_num_threads

I like this a lot.  I don't see the serious conflict yet.... maybe
when I try applying the patches.

> 009 knfsd: use svc_set_num_threads
> 	Move management of nfsd threads from fs/nfsd to net/sunrpc
> 010 knfsd: make pools numa aware 2
> 	The second major step: a pool per node or cpu

-		printk("nfsd: initialising 1 global pool\n");
+		printk("nfsd: initialising 1 global thread pool\n");
Makes it a bit clearer for Jo Sysadmin. - fixed

All the #if's are a bit of a shame.  I wonder what can be removed.
e.g. if we put
#ifndef CONFIG_NUMA
# define node_online_map undefined
# define any_online_node(x) 
# define nr_cpus_node(node) num_online_cpus()
#endif
then I think svc_pool_map_init won't need any #if ...

I'll get you to review that fix...

Also, I don't see that you need both cpu_to_pool and node_to_pool.
Could you just have a node_to_pool and on SMP systems treat the
cpu number as a node number?

> 011 knfsd: allow admin to set nthreads per node
> 	Admin interface to control #threads per pool

Looks simple enough.

Thanks.  I now have all those patches applied.

I'll post the interesting revisions in a little while.

Thanks a lot - this is much-needed work.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
