From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 12 of 34 - readdir error code fix
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006IS-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPq5-0006rw-Fq
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPe6-0002JN-Pb
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:37:54 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
To: Andrew Morton <akpm@osdl.org>
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


changes nfserr_readdir_nospc to nfserr_toosmall, following rfc3530
which has no nfserr_readdir_nospc.

error 10030 which was nfserr_readdir_nospc is actually nfserr_restorefh.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c         |    2 +-
 ./fs/nfsd/nfs4xdr.c         |    8 ++++----
 ./fs/nfsd/nfsxdr.c          |    2 +-
 ./fs/nfsd/vfs.c             |    2 +-
 ./include/linux/nfs.h       |    2 +-
 ./include/linux/nfsd/nfsd.h |    2 +-
 6 files changed, 9 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2004-02-24 10:42:32.000000000 +1100
@@ -796,7 +796,7 @@ encode_entry(struct readdir_cd *ccd, con
 	elen = slen + NFS3_ENTRY_BAGGAGE
 		+ (plus? NFS3_ENTRYPLUS_BAGGAGE : 0);
 	if (cd->buflen < elen) {
-		cd->common.err = nfserr_readdir_nospc;
+		cd->common.err = nfserr_toosmall;
 		return -EINVAL;
 	}
 	*p++ = xdr_one;				 /* mark entry present */

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:32.000000000 +1100
@@ -1688,7 +1688,7 @@ out:
 	return 0;
 
 nospc:
-	cd->common.err = nfserr_readdir_nospc;
+	cd->common.err = nfserr_toosmall;
 	return -EINVAL;
 }
 
@@ -2097,7 +2097,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	 */
 	maxcount = (maxcount >> 2) - 4;
 	if (maxcount < 0)
-		return nfserr_readdir_nospc;
+		return nfserr_toosmall;
 
 	svc_take_page(resp->rqstp);
 	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
@@ -2111,9 +2111,9 @@ nfsd4_encode_readdir(struct nfsd4_compou
 			      &offset,
 			      &readdir->common, nfsd4_encode_dirent);
 	if (nfserr == nfs_ok &&
-	    readdir->common.err == nfserr_readdir_nospc &&
+	    readdir->common.err == nfserr_toosmall &&
 	    readdir->buffer == page) 
-		nfserr = nfserr_readdir_nospc;
+		nfserr = nfserr_toosmall;
 	if (nfserr)
 		return nfserr;
 

diff ./fs/nfsd/nfsxdr.c~current~ ./fs/nfsd/nfsxdr.c
--- ./fs/nfsd/nfsxdr.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2004-02-24 10:42:32.000000000 +1100
@@ -484,7 +484,7 @@ nfssvc_encode_entry(struct readdir_cd *c
 
 	slen = XDR_QUADLEN(namlen);
 	if ((buflen = cd->buflen - slen - 4) < 0) {
-		cd->common.err = nfserr_readdir_nospc;
+		cd->common.err = nfserr_toosmall;
 		return -EINVAL;
 	}
 	*p++ = xdr_one;				/* mark entry present */

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./fs/nfsd/vfs.c	2004-02-24 10:42:32.000000000 +1100
@@ -1494,7 +1494,7 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 		err = cdp->err;
 	*offsetp = file.f_pos;
 
-	if (err == nfserr_eof || err == nfserr_readdir_nospc)
+	if (err == nfserr_eof || err == nfserr_toosmall)
 		err = nfs_ok; /* can still be found in ->err */
 out_close:
 	nfsd_close(&file);

diff ./include/linux/nfs.h~current~ ./include/linux/nfs.h
--- ./include/linux/nfs.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfs.h	2004-02-24 10:42:32.000000000 +1100
@@ -92,7 +92,7 @@
 	NFSERR_NOT_SAME = 10027,	/*       v4 */
 	NFSERR_LOCK_RANGE = 10028,	/*       v4 */
 	NFSERR_SYMLINK = 10029,		/*       v4 */
-	NFSERR_READDIR_NOSPC = 10030,	/*       v4 */
+	NFSERR_RESTOREFH = 10030,	/*       v4 */
 	NFSERR_LEASE_MOVED = 10031,	/*       v4 */
 	NFSERR_ATTRNOTSUPP = 10032,	/*       v4 */
 	NFSERR_NO_GRACE = 10033,	/*       v4 */

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2004-02-24 10:42:32.000000000 +1100
@@ -190,7 +190,7 @@ void		nfsd_lockd_shutdown(void);
 #define nfserr_bad_seqid	__constant_htonl(NFSERR_BAD_SEQID)
 #define	nfserr_symlink		__constant_htonl(NFSERR_SYMLINK)
 #define	nfserr_not_same		__constant_htonl(NFSERR_NOT_SAME)
-#define	nfserr_readdir_nospc	__constant_htonl(NFSERR_READDIR_NOSPC)
+#define	nfserr_restorefh	__constant_htonl(NFSERR_RESTOREFH)
 #define	nfserr_bad_xdr		__constant_htonl(NFSERR_BAD_XDR)
 #define	nfserr_openmode		__constant_htonl(NFSERR_OPENMODE)
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
