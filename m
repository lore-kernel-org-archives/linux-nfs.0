From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 2] Allow larger NFSd MAXBLKSIZE on architectures with larger PAGE_SIZE
Date: Tue, 27 Jul 2004 14:09:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BpJHD-0005cm-80@notabene.cse.unsw.edu.au>
References: <20040727140509.21492.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpJHK-0002rV-JO
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:09:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BpJHJ-00018R-Ud
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 21:09:26 -0700
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
--- ./include/linux/nfsd/const.h~current~	2004-07-27 13:59:14.000000000 +1000
+++ ./include/linux/nfsd/const.h	2004-07-27 13:59:14.000000000 +1000
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
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
