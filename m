From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 4 of 4] knfsd: handle non-contiguous cpu and node
	numbers
Date: Fri, 04 Aug 2006 15:37:46 +1000
Message-ID: <1154669863.21040.2357.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8sNc-0002lR-4x
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 22:37:52 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8sNc-0003vi-FV
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 22:37:52 -0700
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

knfsd: when allocating per-cpu or per-node rpc thread pools, handle
the case of noncontiguous cpu or node numbers.

Tested:

Machine                         ARCH    SMP NUMA    SUNRPC  nodes   cpus    hpni    hppi    pools(mode)
-------                         ----    --- ----    ------  -----   ----    ----    ----    ------------
4 cpu Xeon SMP                  x86_64  y   y       y       1       4       31      7       4 (percpu)
4 cpu Xeon SMP                  x86_64  y   y       m       1       4       31      7       4 (percpu)
4 cpu Xeon SMP                  x86_64  y   n       y       0       4       0       7       4 (percpu)
4 cpu Xeon SMP                  x86_64  y   n       m       0       4       0       7       4 (percpu)
4 cpu Xeon SMP                  x86_64  n   n       y       0       1       0       0       1 (global)
4 cpu Xeon SMP                  x86_64  n   n       m       0       1       0       0       1 (global)
4 cpu (2 node) Itanium NUMA     ia64    y   y       m       2       4       1023    3       2 (pernode)
2 cpu (1 node) Itanium NUMA     ia64    y   y       m       1       2       1023    1       1 (global)

* number of nodes and cpus from /sys/devices/system/
* hpni = value of highest_possible_node_id()
* hppi = value of highest_possible_processor_id()

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: linus-git/net/sunrpc/svc.c
===================================================================
--- linus-git.orig/net/sunrpc/svc.c	2006-08-01 15:38:30.000000000 +1000
+++ linus-git/net/sunrpc/svc.c	2006-08-02 13:20:35.979647782 +1000
@@ -116,7 +116,7 @@ fail:
 static int
 svc_pool_map_init_percpu(struct svc_pool_map *m)
 {
-	unsigned int maxpools = num_possible_cpus();
+	unsigned int maxpools = highest_possible_processor_id()+1;
 	unsigned int pidx = 0;
 	unsigned int cpu;
 	int err;
@@ -144,7 +144,7 @@ svc_pool_map_init_percpu(struct svc_pool
 static int
 svc_pool_map_init_pernode(struct svc_pool_map *m)
 {
-	unsigned int maxpools = num_possible_nodes();
+	unsigned int maxpools = highest_possible_node_id()+1;
 	unsigned int pidx = 0;
 	unsigned int node;
 	int err;

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
