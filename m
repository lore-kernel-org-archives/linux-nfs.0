From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 11] knfsd: Introduction - Make knfsd more
	NUMA-aware
Date: Mon, 31 Jul 2006 10:41:42 +1000
Message-ID: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7Lr1-0003nG-VZ
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:41:57 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7Lr1-0006wa-58
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:41:56 -0700
To: Andrew Morton <akpm@osdl.org>
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

Following are 11 patches from Greg Banks which combine to make knfsd
more Numa-aware.  They reduce hitting on 'global' data structures, and
create some data-structures that can be node-local.

knfsd threads are bound to a particular node, and the thread to handle
a new request is chosen from the threads that are attach to the node
that received the interrupt.

The distribution of threads across nodes can be controlled by a new
file in the 'nfsd' filesystem, though the default approach of an even
spread is probably fine for most sites.

Some (old) numbers that show the efficacy of these patches:
N == number of NICs == number of CPUs == nmber of clients.
Number of NUMA nodes == N/2

N	Throughput, MiB/s	CPU usage, % (max=N*100)
	Before	After		Before	After
---	------	----		-----	-----
4	312	435		350	228
6	500	656		501	418
8	562	804		690	589


 [PATCH 001 of 11] knfsd: move tempsock aging to a timer
 [PATCH 002 of 11] knfsd: convert sk_inuse to atomic_t
 [PATCH 003 of 11] knfsd: use new lock for svc_sock deferred list
 [PATCH 004 of 11] knfsd: convert sk_reserved to atomic_t
 [PATCH 005 of 11] knfsd: test and set SK_BUSY atomically
 [PATCH 006 of 11] knfsd: split svc_serv into pools
 [PATCH 007 of 11] knfsd: add svc_get
 [PATCH 008 of 11] knfsd: add svc_set_num_threads
 [PATCH 009 of 11] knfsd: use svc_set_num_threads to manage threads in knfsd
 [PATCH 010 of 11] knfsd: make rpc threads pools numa aware
 [PATCH 011 of 11] knfsd: allow admin to set nthreads per node

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
