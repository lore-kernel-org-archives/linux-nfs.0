From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 1 of 2] cpumask: use EXPORT_SYMBOL_GPL for new exports
Date: Tue, 08 Aug 2006 13:25:34 +1000
Message-ID: <1155007534.29877.215.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIEK-0007Kw-4y
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:26:08 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIEJ-0001Hb-Ga
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 20:26:08 -0700
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
node_2_cpu_mask.  Thanks to Zwane Mwaikambo for pointing this out.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 arch/i386/kernel/smpboot.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.18-rc2/arch/i386/kernel/smpboot.c
===================================================================
--- linux-2.6.18-rc2.orig/arch/i386/kernel/smpboot.c
+++ linux-2.6.18-rc2/arch/i386/kernel/smpboot.c
@@ -609,7 +609,7 @@ extern struct {
 /* which logical CPUs are on which nodes */
 cpumask_t node_2_cpu_mask[MAX_NUMNODES] __read_mostly =
 				{ [0 ... MAX_NUMNODES-1] = CPU_MASK_NONE };
-EXPORT_SYMBOL(node_2_cpu_mask);
+EXPORT_SYMBOL_GPL(node_2_cpu_mask);
 /* which node each logical CPU is on */
 int cpu_2_node[NR_CPUS] __read_mostly = { [0 ... NR_CPUS-1] = 0 };
 EXPORT_SYMBOL(cpu_2_node);


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
