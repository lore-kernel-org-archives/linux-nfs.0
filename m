From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 3 of 4] cpumask: export node_to_cpu_mask consistently
Date: Fri, 04 Aug 2006 15:37:00 +1000
Message-ID: <1154669820.21040.2355.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8sMt-0002kY-It
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 22:37:07 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8sMt-0003pp-TH
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 22:37:08 -0700
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

cpumask: ensure that node_to_cpumask() is available to modules for
all supported combinations of architecture and CONFIG_NUMA.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 arch/i386/kernel/smpboot.c |    1 +
 arch/ia64/kernel/numa.c    |    1 +
 2 files changed, 2 insertions(+)

Index: linux-2.6.18-rc2/arch/i386/kernel/smpboot.c
===================================================================
--- linux-2.6.18-rc2.orig/arch/i386/kernel/smpboot.c	2006-08-03 13:29:58.956798616 +1000
+++ linux-2.6.18-rc2/arch/i386/kernel/smpboot.c	2006-08-03 13:30:34.716149882 +1000
@@ -609,6 +609,7 @@ extern struct {
 /* which logical CPUs are on which nodes */
 cpumask_t node_2_cpu_mask[MAX_NUMNODES] __read_mostly =
 				{ [0 ... MAX_NUMNODES-1] = CPU_MASK_NONE };
+EXPORT_SYMBOL(node_2_cpu_mask);
 /* which node each logical CPU is on */
 int cpu_2_node[NR_CPUS] __read_mostly = { [0 ... NR_CPUS-1] = 0 };
 EXPORT_SYMBOL(cpu_2_node);
Index: linux-2.6.18-rc2/arch/ia64/kernel/numa.c
===================================================================
--- linux-2.6.18-rc2.orig/arch/ia64/kernel/numa.c	2006-08-03 13:30:03.548201734 +1000
+++ linux-2.6.18-rc2/arch/ia64/kernel/numa.c	2006-08-03 13:31:01.696642365 +1000
@@ -28,6 +28,7 @@ u16 cpu_to_node_map[NR_CPUS] __cacheline
 EXPORT_SYMBOL(cpu_to_node_map);
 
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+EXPORT_SYMBOL_GPL(node_to_cpu_mask);
 
 /**
  * build_cpu_to_node_map - setup cpu to node and node to cpumask arrays

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
