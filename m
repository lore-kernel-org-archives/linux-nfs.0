From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 7 - Ease increasing the max block size for NFS replies.
Date: Tue, 17 Dec 2002 12:59:27 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18O715-0000pI-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O71O-0003no-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 17:59:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.239] == wireless-239.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 17 Dec 2002 12:59:36 +1100
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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



This requires making NFSv2 return the right number in statfs
requests.  NFSv3 already does.

The size should really be boot/module option.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfsxdr.c           |    2 +-
 ./include/linux/nfsd/const.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfsxdr.c~current~ ./fs/nfsd/nfsxdr.c
--- ./fs/nfsd/nfsxdr.c~current~	2002-12-17 09:50:41.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2002-12-17 09:50:41.000000000 +1100
@@ -385,7 +385,7 @@ nfssvc_encode_statfsres(struct svc_rqst 
 {
 	struct statfs	*stat = &resp->stats;
 
-	*p++ = htonl(8 * 1024);		/* max transfer size */
+	*p++ = htonl(NFSSVC_MAXBLKSIZE);	/* max transfer size */
 	*p++ = htonl(stat->f_bsize);
 	*p++ = htonl(stat->f_blocks);
 	*p++ = htonl(stat->f_bfree);

diff ./include/linux/nfsd/const.h~current~ ./include/linux/nfsd/const.h
--- ./include/linux/nfsd/const.h~current~	2002-12-17 09:50:41.000000000 +1100
+++ ./include/linux/nfsd/const.h	2002-12-17 09:50:41.000000000 +1100
@@ -21,7 +21,7 @@
 /*
  * Maximum blocksize supported by daemon currently at 8K
  */
-#define NFSSVC_MAXBLKSIZE	8192
+#define NFSSVC_MAXBLKSIZE	(8*1024)
 
 #ifdef __KERNEL__
 


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
