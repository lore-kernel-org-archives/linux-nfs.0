From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 017 of 26] nfsd4: nfs4state.c miscellaneous goto removals
Date: Fri, 13 Jan 2006 12:01:01 +1100
Message-ID: <1060113010101.23132@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJc-0002b7-Ml
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:16 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJb-0006rI-2Q
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:16 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:11 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:02 +1100
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


Remove some goto's that made the logic here a little more tortuous than
necessary.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |   33 ++++++++++++++-------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-01-13 11:51:08.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-01-13 11:51:08.000000000 +1100
@@ -592,25 +592,21 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 	status = nfs_ok;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
-		if ((status = nfs4_preprocess_stateid_op(current_fh,
-						&setattr->sa_stateid,
-						CHECK_FH | WR_STATE, NULL))) {
-			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
-			goto out_unlock;
-		}
+		status = nfs4_preprocess_stateid_op(current_fh,
+			&setattr->sa_stateid, CHECK_FH | WR_STATE, NULL);
 		nfs4_unlock_state();
+		if (status) {
+			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!");
+			return status;
+		}
 	}
 	status = nfs_ok;
 	if (setattr->sa_acl != NULL)
 		status = nfsd4_set_nfs4_acl(rqstp, current_fh, setattr->sa_acl);
 	if (status)
-		goto out;
+		return status;
 	status = nfsd_setattr(rqstp, current_fh, &setattr->sa_iattr,
 				0, (time_t)0);
-out:
-	return status;
-out_unlock:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -628,15 +624,17 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid,
-					CHECK_FH | WR_STATE, &filp))) {
-		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
-		goto out;
-	}
+	status = nfs4_preprocess_stateid_op(current_fh, stateid,
+					CHECK_FH | WR_STATE, &filp);
 	if (filp)
 		get_file(filp);
 	nfs4_unlock_state();
 
+	if (status) {
+		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
+		return status;
+	}
+
 	write->wr_bytes_written = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
 	p = (u32 *)write->wr_verifier.data;
@@ -652,9 +650,6 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	if (status == nfserr_symlink)
 		status = nfserr_inval;
 	return status;
-out:
-	nfs4_unlock_state();
-	return status;
 }
 
 /* This routine never returns NFS_OK!  If there are no other errors, it


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
