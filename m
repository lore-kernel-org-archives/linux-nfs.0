From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 15 of 34 - Correct error returns.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006It-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqH-0006tM-5y
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPpw-0005bf-4t
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:08 -0800
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


Call decode_fattr on writable attributes to check
for xdr errors, incorrect utf8, etc.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c        |    5 +++--
 ./fs/nfsd/nfs4xdr.c         |   21 +++++++++++++++++++++
 ./include/linux/nfsd/nfsd.h |    1 +
 3 files changed, 25 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:32.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:33.000000000 +1100
@@ -584,8 +584,9 @@ nfsd4_verify(struct svc_rqst *rqstp, str
 
 	if ((verify->ve_bmval[0] & ~NFSD_SUPPORTED_ATTRS_WORD0)
 	    || (verify->ve_bmval[1] & ~NFSD_SUPPORTED_ATTRS_WORD1))
-		return nfserr_notsupp;
-	if (verify->ve_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1)
+		return nfserr_attrnotsupp;
+	if ((verify->ve_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)
+	    || (verify->ve_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1))
 		return nfserr_inval;
 	if (verify->ve_attrlen & 3)
 		return nfserr_inval;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:32.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:33.000000000 +1100
@@ -908,10 +908,31 @@ nfsd4_decode_setclientid_confirm(struct 
 static int
 nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify)
 {
+#if 0
+	struct nfsd4_compoundargs save = {
+		.p = argp->p,
+		.end = argp->end,
+		.rqstp = argp->rqstp,
+	};
+	u32             ve_bmval[2];
+	struct iattr    ve_iattr;           /* request */
+	struct nfs4_acl *ve_acl;            /* request */
+#endif
 	DECODE_HEAD;
 
 	if ((status = nfsd4_decode_bitmap(argp, verify->ve_bmval)))
 		goto out;
+
+	/* For convenience's sake, we compare raw xdr'd attributes in
+	 * nfsd4_proc_verify; however we still decode here just to return
+	 * correct error in case of bad xdr. */
+#if 0
+	status = nfsd4_decode_fattr(ve_bmval, &ve_iattr, &ve_acl);
+	if (status == nfserr_inval) {
+		status = nfserrno(status);
+		goto out;
+	}
+#endif	
 	READ_BUF(4);
 	READ32(verify->ve_attrlen);
 	READ_BUF(verify->ve_attrlen);

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-02-24 10:42:32.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2004-02-24 10:42:33.000000000 +1100
@@ -191,6 +191,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_symlink		__constant_htonl(NFSERR_SYMLINK)
 #define	nfserr_not_same		__constant_htonl(NFSERR_NOT_SAME)
 #define	nfserr_restorefh	__constant_htonl(NFSERR_RESTOREFH)
+#define	nfserr_attrnotsupp	__constant_htonl(NFSERR_ATTRNOTSUPP)
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
