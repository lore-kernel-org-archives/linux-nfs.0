From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 24 of 34 - add OP_ILLEGAL, and fix processing of compounds with out of bounds op numbers.
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006KC-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xj-Ra
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf2-0002QC-CR
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:52 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:50:42 +1100
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c         |   16 +++++++++-------
 ./include/linux/nfs4.h      |    1 +
 ./include/linux/nfsd/nfsd.h |    1 +
 3 files changed, 11 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:35.000000000 +1100
@@ -1078,6 +1078,13 @@ nfsd4_decode_compound(struct nfsd4_compo
 		op->opnum = ntohl(*argp->p++);
 
 		switch (op->opnum) {
+		case 2: /* Reserved operation */
+			op->opnum = OP_ILLEGAL;
+			if (argp->minorversion == 0)
+				op->status = nfserr_op_illegal;
+			else 
+				op->status = nfserr_minor_vers_mismatch;
+			break;
 		case OP_ACCESS:
 			op->status = nfsd4_decode_access(argp, &op->u.access);
 			break;
@@ -1175,13 +1182,8 @@ nfsd4_decode_compound(struct nfsd4_compo
 			op->status = nfsd4_decode_release_lockowner(argp, &op->u.release_lockowner);
 			break;
 		default:
-			/*
-			 * According to spec, anything greater than OP_WRITE
-			 * is treated as OP_WRITE+1 in the response.
-			 */
-			if (op->opnum > OP_WRITE)
-			op->opnum = OP_WRITE + 1;
-			op->status = nfserr_notsupp;
+			op->opnum = OP_ILLEGAL;
+			op->status = nfserr_op_illegal;
 			break;
 		}
 

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./include/linux/nfs4.h	2004-02-24 10:42:35.000000000 +1100
@@ -87,6 +87,7 @@ enum nfs_opnum4 {
 	OP_VERIFY = 37,
 	OP_WRITE = 38,
 	OP_RELEASE_LOCKOWNER = 39,
+	OP_ILLEGAL = 10044,
 };
 
 enum nfsstat4 {

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2004-02-24 10:42:35.000000000 +1100
@@ -195,6 +195,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_bad_xdr		__constant_htonl(NFSERR_BAD_XDR)
 #define	nfserr_openmode		__constant_htonl(NFSERR_OPENMODE)
 #define	nfserr_locks_held	__constant_htonl(NFSERR_LOCKS_HELD)
+#define	nfserr_op_illegal	__constant_htonl(NFSERR_OP_ILLEGAL)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
