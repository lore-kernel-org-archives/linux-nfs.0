From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 2 of 2] cpumask: use EXPORT_SYMBOL_GPL for new exports
Date: Tue, 08 Aug 2006 13:26:01 +1000
Message-ID: <1155007561.29877.217.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIES-0007L2-Eb
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:26:16 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIES-0001Ig-PU
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:26:17 -0700
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

cpumask: use EXPORT_SYMBOL_GPL instead of EXPORT_SYMBOL to export
cpu_possible_map and cpu_online_map.  Thanks to Zwane Mwaikambo
for pointing this out.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 arch/arm/kernel/smp.c           |    4 ++--
 arch/cris/arch-v32/kernel/smp.c |    2 +-
 arch/sh/kernel/smp.c            |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.18-rc2/arch/arm/kernel/smp.c
===================================================================
--- linux-2.6.18-rc2.orig/arch/arm/kernel/smp.c
+++ linux-2.6.18-rc2/arch/arm/kernel/smp.c
@@ -36,9 +36,9 @@
  * The online bitmask indicates that the CPU is up and running.
  */
 cpumask_t cpu_possible_map;
-EXPORT_SYMBOL(cpu_possible_map);
+EXPORT_SYMBOL_GPL(cpu_possible_map);
 cpumask_t cpu_online_map;
-EXPORT_SYMBOL(cpu_online_map);
+EXPORT_SYMBOL_GPL(cpu_online_map);
 
 /*
  * as from 2.5, kernels no longer have an init_tasks structure
Index: linux-2.6.18-rc2/arch/cris/arch-v32/kernel/smp.c
===================================================================
--- linux-2.6.18-rc2.orig/arch/cris/arch-v32/kernel/smp.c
+++ linux-2.6.18-rc2/arch/cris/arch-v32/kernel/smp.c
@@ -28,7 +28,7 @@ spinlock_t cris_atomic_locks[] = { [0 ..
 
 /* CPU masks */
 cpumask_t cpu_online_map = CPU_MASK_NONE;
-EXPORT_SYMBOL(cpu_online_map);
+EXPORT_SYMBOL_GPL(cpu_online_map);
 cpumask_t phys_cpu_present_map = CPU_MASK_NONE;
 EXPORT_SYMBOL(phys_cpu_present_map);
 
Index: linux-2.6.18-rc2/arch/sh/kernel/smp.c
===================================================================
--- linux-2.6.18-rc2.orig/arch/sh/kernel/smp.c
+++ linux-2.6.18-rc2/arch/sh/kernel/smp.c
@@ -42,7 +42,7 @@ cpumask_t cpu_possible_map;
 EXPORT_SYMBOL(cpu_possible_map);
 
 cpumask_t cpu_online_map;
-EXPORT_SYMBOL(cpu_online_map);
+EXPORT_SYMBOL_GPL(cpu_online_map);
 static atomic_t cpus_booted = ATOMIC_INIT(0);
 
 /* These are defined by the board-specific code. */


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
