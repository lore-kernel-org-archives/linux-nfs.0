From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 022 of 26] nfsd4: clean up settattr code
Date: Fri, 13 Jan 2006 12:01:05 +1100
Message-ID: <1060113010105.23192@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJZ-0002aj-Qz
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:13 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJX-0006pS-89
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:13 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:08 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:06 +1100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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


Clean up some unnecessary special-casing in the setattr code..

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-01-13 11:51:09.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-01-13 11:51:10.000000000 +1100
@@ -594,10 +594,6 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 {
 	int status = nfs_ok;
 
-	if (!current_fh->fh_dentry)
-		return nfserr_nofilehandle;
-
-	status = nfs_ok;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
 		status = nfs4_preprocess_stateid_op(current_fh,
@@ -799,17 +795,13 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		/* All operations except RENEW, SETCLIENTID, RESTOREFH
 		* SETCLIENTID_CONFIRM, PUTFH and PUTROOTFH
 		* require a valid current filehandle
-		*
-		* SETATTR NOFILEHANDLE error handled in nfsd4_setattr
-		* due to required returned bitmap argument
 		*/
 		if ((!current_fh->fh_dentry) &&
 		   !((op->opnum == OP_PUTFH) || (op->opnum == OP_PUTROOTFH) ||
 		   (op->opnum == OP_SETCLIENTID) ||
 		   (op->opnum == OP_SETCLIENTID_CONFIRM) ||
 		   (op->opnum == OP_RENEW) || (op->opnum == OP_RESTOREFH) ||
-		   (op->opnum == OP_RELEASE_LOCKOWNER) ||
-		   (op->opnum == OP_SETATTR))) {
+		   (op->opnum == OP_RELEASE_LOCKOWNER))) {
 			op->status = nfserr_nofilehandle;
 			goto encode_op;
 		}


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
