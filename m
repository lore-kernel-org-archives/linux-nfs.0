From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 905314 (1/2): make NFSSVC_MAXBLKSIZE depend on PAGE_SIZE
Date: Fri, 28 Nov 2003 23:43:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC742E7.910F518B@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APhyN-0001Qc-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 04:43:47 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1APhyM-0005jX-Mq
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 04:43:46 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

G'day,

SGI bug #905314

This patch makes NFSSVC_MAXBLKSIZE depend on PAGE_SIZE so that machines
with large page sizes can take advantage of that feature to serve NFS
with larger blocksizes, increasing performance and avoiding a fallback
to synchronous traffic between machines with page sizes greater than 8K.
Also, documents the actual constraints on NFSSVC_MAXBLKSIZE.

The patch has been running for some hours now, reading and writing NFSv3
over UDP on gigabit ethernet between two Altix boxes (16K page sizes) with
4G RAM each.  I have verified with ethereal that reads and writes proceed
in 32K blocks, and performance tests show good throughput for streaming
reads and writes (although 2.6.0-test8 still does better).


--- /usr/tmp/TmpDir.28396-0/linux/linux/include/linux/nfsd/const.h_1.5	Fri Nov 28
23:07:47 2003
+++ linux/include/linux/nfsd/const.h	Fri Nov 28 23:07:36 2003
@@ -12,6 +12,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs3.h>
+#include <asm/page.h>
 
 /*
  * Maximum protocol version supported by knfsd
@@ -19,9 +20,24 @@
 #define NFSSVC_MAXVERS		3
 
 /*
- * Maximum blocksize supported by daemon currently at 8K
+ * Maximum blocksize supported by daemon.  The value is
+ * constrained by 1) has to fit in a UDP datagram less some
+ * headers 2) must be a multiple of page size 3) will have to
+ * be allocated plus some headers as a physically contiguous
+ * buffer for each nfsd.   For best performance we usually want
+ * the largest value consistent with those constraints.   The
+ * fuzziest condition is 3;  here we choose to limit the gfp
+ * allocation order <= 2 and cross our fingers.  Note we also
+ * choose powers of 2 like the client code even though there's
+ * no good reason to do so.
  */
+#if PAGE_SIZE > (8*1024)
+#define NFSSVC_MAXBLKSIZE	(32*1024)
+#elif PAGE_SIZE == (8*1024)
+#define NFSSVC_MAXBLKSIZE	(16*1024)
+#else /* 4K pages */
 #define NFSSVC_MAXBLKSIZE	(8*1024)
+#endif
 
 #ifdef __KERNEL__
 



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
