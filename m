From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.10-pre10 RPC changes problem
Date: 01 Jul 2002 16:32:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbs9rjz7s.fsf@charged.uio.no>
References: <200207011338.g61DcNM26138@roma.math.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17P2EG-00045c-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Jul 2002 07:32:36 -0700
To: Andrew Schretter <schrett@math.duke.edu>
In-Reply-To: <200207011338.g61DcNM26138@roma.math.duke.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Andrew Schretter <schrett@math.duke.edu> writes:

     > Trond, I too am having some problems with the recent RPC fixes,
     > my kernels have unresolved symbols in sunrpc.o, namely
     > kmap_prot and kmap_rte which I tracked down to the recent
     > inclusion of pagemap.h in xdr.c (from
     > linux-2.4.19-01-fix_kmap1.dif) and the fact that I have HIGHMEM
     > defined.

     > I've been looking it over for the last 2 days and haven't been
     > able to figure out exactly how to fix the problem.  I suppose
     > that you probably don't have HIGHMEM enable in your kernel
     > config or maybe I'm just missing something.

Duh...

Somebody decided to inline kmap_atomic() for speed, but forgot to
export those two symbols for use in modules (BTW: I presume you meant
kmap_pte?).
This means that the code works fine unless you combine HIGHMEM with
sunrpc being compiled as a module. The problem won't affect fix_kmap1,
but it will affect fix_kmap2 (which uses the kmap_atomic() code).

linux-2.4.19-fix_kmap2, NFS_ALL, and RPC_ALL have now been updated...

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.19-fix_kmap1/arch/i386/kernel/i386_ksyms.c linux-2.4.19-fix_kmap2/arch/i386/kernel/i386_ksyms.c
--- linux-2.4.19-fix_kmap1/arch/i386/kernel/i386_ksyms.c	Sat Dec  8 14:19:15 2001
+++ linux-2.4.19-fix_kmap2/arch/i386/kernel/i386_ksyms.c	Mon Jul  1 16:17:41 2002
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/tty.h>
+#include <linux/highmem.h>
 
 #include <asm/semaphore.h>
 #include <asm/processor.h>
@@ -173,5 +174,10 @@
 EXPORT_SYMBOL(atomic_dec_and_lock);
 #endif
 
+#ifdef CONFIG_HIGHMEM
+EXPORT_SYMBOL(kmap_prot);
+EXPORT_SYMBOL(kmap_pte);
+#endif
+
 extern int is_sony_vaio_laptop;
 EXPORT_SYMBOL(is_sony_vaio_laptop);
diff -u --recursive --new-file linux-2.4.19-fix_kmap1/arch/mips/kernel/mips_ksyms.c linux-2.4.19-fix_kmap2/arch/mips/kernel/mips_ksyms.c
--- linux-2.4.19-fix_kmap1/arch/mips/kernel/mips_ksyms.c	Thu Feb 28 14:57:19 2002
+++ linux-2.4.19-fix_kmap2/arch/mips/kernel/mips_ksyms.c	Mon Jul  1 16:18:51 2002
@@ -16,6 +16,7 @@
 #include <linux/in6.h>
 #include <linux/pci.h>
 #include <linux/ide.h>
+#include <linux/highmem.h>
 
 #include <asm/bootinfo.h>
 #include <asm/checksum.h>
@@ -124,3 +125,8 @@
 #endif
 
 EXPORT_SYMBOL(get_wchan);
+
+#ifdef CONFIG_HIGHMEM
+EXPORT_SYMBOL(kmap_prot);
+EXPORT_SYMBOL(kmap_pte);
+#endif
diff -u --recursive --new-file linux-2.4.19-fix_kmap1/arch/ppc/kernel/ppc_ksyms.c linux-2.4.19-fix_kmap2/arch/ppc/kernel/ppc_ksyms.c
--- linux-2.4.19-fix_kmap1/arch/ppc/kernel/ppc_ksyms.c	Mon Mar 11 15:13:27 2002
+++ linux-2.4.19-fix_kmap2/arch/ppc/kernel/ppc_ksyms.c	Mon Jul  1 16:17:20 2002
@@ -17,6 +17,7 @@
 #include <linux/irq.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include <linux/highmem.h>
 
 #include <asm/page.h>
 #include <asm/semaphore.h>
@@ -364,3 +365,8 @@
 EXPORT_SYMBOL_NOVERS(agp_special_page);
 #endif /* defined(CONFIG_ALL_PPC) */
 
+#ifdef CONFIG_HIGHMEM
+EXPORT_SYMBOL(kmap_prot);
+EXPORT_SYMBOL(kmap_pte);
+#endif
+
diff -u --recursive --new-file linux-2.4.19-fix_kmap1/arch/sparc/kernel/sparc_ksyms.c linux-2.4.19-fix_kmap2/arch/sparc/kernel/sparc_ksyms.c
--- linux-2.4.19-fix_kmap1/arch/sparc/kernel/sparc_ksyms.c	Wed Apr 24 19:18:05 2002
+++ linux-2.4.19-fix_kmap2/arch/sparc/kernel/sparc_ksyms.c	Mon Jul  1 16:19:59 2002
@@ -23,6 +23,7 @@
 #include <linux/pci.h>
 #endif
 #include <linux/pm.h>
+#include <linux/highmem.h>
 
 #include <asm/oplib.h>
 #include <asm/delay.h>
@@ -300,3 +301,8 @@
 
 /* Sun Power Management Idle Handler */
 EXPORT_SYMBOL(pm_idle);
+
+#ifdef CONFIG_HIGHMEM
+EXPORT_SYMBOL(kmap_prot);
+EXPORT_SYMBOL(kmap_pte);
+#endif


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
