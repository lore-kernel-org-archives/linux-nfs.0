From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 3 of 4] Allow larger NFSd MAXBLKSIZE on architectures with larger PAGE_SIZE
Date: Mon, 16 Aug 2004 13:58:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BwYdv-0002Zn-75@notabene.cse.unsw.edu.au>
References: <20040816135256.9819.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwYg8-0008EP-62
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 21:01:00 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BwYg7-0002d3-NI
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 21:01:00 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


This patch makes NFSSVC_MAXBLKSIZE depend on PAGE_SIZE so that machines
with large page sizes can take advantage of that feature to serve NFS
with larger blocksizes, increasing performance and avoiding a fallback
to synchronous traffic between machines with page sizes greater than 8K.
Also, documents the actual constraints on NFSSVC_MAXBLKSIZE.

From: Greg Banks <gnb@sgi.com>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./include/linux/nfsd/const.h |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff ./include/linux/nfsd/const.h~current~ ./include/linux/nfsd/const.h
--- ./include/linux/nfsd/const.h~current~	2004-08-16 09:53:48.000000000 +1000
+++ ./include/linux/nfsd/const.h	2004-08-16 09:53:48.000000000 +1000
@@ -12,6 +12,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs3.h>
+#include <asm/page.h>
 
 /*
  * Maximum protocol version supported by knfsd
@@ -19,9 +20,16 @@
 #define NFSSVC_MAXVERS		3
 
 /*
- * Maximum blocksize supported by daemon currently at 8K
+ * Maximum blocksize supported by daemon.  We want the largest
+ * value which 1) fits in a UDP datagram less some headers
+ * 2) is a multiple of page size 3) can be successfully kmalloc()ed
+ * by each nfsd.   
  */
-#define NFSSVC_MAXBLKSIZE	(8*1024)
+#if PAGE_SIZE > (16*1024)
+#define NFSSVC_MAXBLKSIZE	(32*1024)
+#else
+#define NFSSVC_MAXBLKSIZE	(2*PAGE_SIZE)
+#endif
 
 #ifdef __KERNEL__
 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
