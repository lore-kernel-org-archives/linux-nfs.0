From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 000 of 11] knfsd: NUMAisation
Date: Tue, 25 Jul 2006 15:27:54 +1000
Message-ID: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5FSb-0004vs-GV
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:28:01 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5FSZ-0001Oz-KA
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:28:01 -0700
To: Neil Brown <neilb@suse.de>
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

G'day,

These 11 patches make the Linux NFS server scale gracefully
on large NUMA and SMP machines.  The two basic approaches
are to eliminate code (such as tempsock aging) from the main
svc loop, and to move the hot locks and data structures from
svc_serv into a new svc_pool which can be allocated per-node
or per-cpu.

These applied cleanly to Linus' GIT yesterday, but clash with
today's set of 9 patches.  I'd appreciate advice in picking up
those pieces, especially how patch your 007/9 interacts with
my 008/11.

001 knfsd: move tempsock aging to timer
002 knfsd: convert sk_inuse to atomic_t
003 knfsd: use new lock for svc_sock deferred list
004 knfsd: convert sk_reserved to atomic_t
	These move various data structures out from the
	protection of the svc_serv.sv_lock
005 knfsd: test and set SK_BUSY atomically
	This provides correct update for the SK_BUSY bit
006 knfsd: split svc_serv into pools
	The first major step: split off hot fields from svc_serv
	into new svc_pool structure
007 knfsd: add svc_get
008 knfsd: add svc_set_num_threads
009 knfsd: use svc_set_num_threads
	Move management of nfsd threads from fs/nfsd to net/sunrpc
010 knfsd: make pools numa aware 2
	The second major step: a pool per node or cpu
011 knfsd: allow admin to set nthreads per node
	Admin interface to control #threads per pool

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
