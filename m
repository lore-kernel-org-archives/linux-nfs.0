From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 13 of 34 - correctly tests and sets nfserr_nofilehandle for current and save fh.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Ib-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqI-0006tw-Pz
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPeJ-0002Lf-Ru
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:08 -0800
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


nfsd4_restore_fh() returns nfserr_restorefh instead of nfserr_nofilehandle

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |   32 ++++++++++++++++++++++++++++----
 ./fs/nfsd/nfs4xdr.c  |   10 ++++++++--
 2 files changed, 36 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:32.000000000 +1100
@@ -192,7 +192,7 @@ static inline int
 nfsd4_restorefh(struct svc_fh *current_fh, struct svc_fh *save_fh)
 {
 	if (!save_fh->fh_dentry)
-		return nfserr_nofilehandle;
+		return nfserr_restorefh;
 
 	fh_dup2(current_fh, save_fh);
 	return nfs_ok;
@@ -336,8 +336,10 @@ static inline int
 nfsd4_link(struct svc_rqst *rqstp, struct svc_fh *current_fh,
 	   struct svc_fh *save_fh, struct nfsd4_link *link)
 {
-	int status;
+	int status = nfserr_nofilehandle;
 
+	if (!save_fh->fh_dentry)
+		return status;
 	status = nfsd_link(rqstp, current_fh, link->li_name, link->li_namelen, save_fh);
 	if (!status)
 		set_change_info(&link->li_cinfo, current_fh);
@@ -458,8 +460,10 @@ static inline int
 nfsd4_rename(struct svc_rqst *rqstp, struct svc_fh *current_fh,
 	     struct svc_fh *save_fh, struct nfsd4_rename *rename)
 {
-	int status;
+	int status = nfserr_nofilehandle;
 
+	if (!save_fh->fh_dentry)
+		return status;
 	status = nfsd_rename(rqstp, save_fh, rename->rn_sname,
 			     rename->rn_snamelen, current_fh,
 			     rename->rn_tname, rename->rn_tnamelen);
@@ -474,8 +478,12 @@ static inline int
 nfsd4_setattr(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_setattr *setattr)
 {
 	struct nfs4_stateid *stp;
-	int status = nfs_ok;
+	int status = nfserr_nofilehandle;
+
+	if (!current_fh->fh_dentry)
+		goto out;
 
+	status = nfs_ok;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 
 		status = nfserr_bad_stateid;
@@ -679,6 +687,22 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			goto encode_op;
 		}
 
+		/* All operations except RENEW, SETCLIENTID, RESTOREFH
+		* SETCLIENTID_CONFIRM, PUTFH and PUTROOTFH 
+		* require a valid current filehandle 
+		*
+		* SETATTR NOFILEHANDLE error handled in nfsd4_setattr
+		* due to required returned bitmap argument
+		*/ 
+		if ((!current_fh.fh_dentry) && 
+		   !((op->opnum == OP_PUTFH) || (op->opnum == OP_PUTROOTFH) ||
+		   (op->opnum == OP_SETCLIENTID) ||
+		   (op->opnum == OP_SETCLIENTID_CONFIRM) ||
+		   (op->opnum == OP_RENEW) || (op->opnum == OP_RESTOREFH) ||
+		   (op->opnum == OP_SETATTR))) {
+			op->status = nfserr_nofilehandle;
+			goto encode_op;
+		}
 		switch (op->opnum) {
 		case OP_ACCESS:
 			op->status = nfsd4_access(rqstp, &current_fh, &op->u.access);

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:32.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:32.000000000 +1100
@@ -2226,8 +2226,14 @@ nfsd4_encode_operation(struct nfsd4_comp
 
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
-	statp = p++;                  /* to be backfilled at the end */
-	ADJUST_ARGS();
+	if ((op->opnum != OP_SETATTR) && (op->opnum != OP_LOCK) && (op->opnum != OP_LOCKT) && (op->opnum != OP_SETCLIENTID) && (op->status)) { 
+		*p++ = op->status;              
+		ADJUST_ARGS();
+		return;
+	} else {
+		statp = p++;        /* to be backfilled at the end */
+		ADJUST_ARGS();
+	}
 
 	switch (op->opnum) {
 	case OP_ACCESS:


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
