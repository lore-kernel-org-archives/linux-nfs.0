From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 26 of 34 - Add a check in OP_LOCK for new lockowners to ensure that the open stateid is
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006KU-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xe-HB
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPqf-0005ht-Nn
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:53 -0800
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

owned by the lockowner clientid.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |   32 +++++++++++++++++++++++++-------
 1 files changed, 25 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:34.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:35.000000000 +1100
@@ -1401,7 +1401,7 @@ out:
  * Checks for sequence id mutating operations. 
  */
 int
-nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp)
+nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp, clientid_t *lockclid)
 {
 	int status;
 	struct nfs4_stateid *stp;
@@ -1438,6 +1438,21 @@ nfs4_preprocess_seqid_op(struct svc_fh *
 
 	status = nfserr_bad_stateid;
 
+	/* for new lock stateowners, check that the lock->v.new.open_stateid
+	 * refers to an open stateowner, and that the lockclid 
+	 * (nfs4_lock->v.new.clientid) is the same as the 
+	 * open_stateid->st_stateowner->so_client->clientid
+	 */
+	if (lockclid) {
+		struct nfs4_stateowner *sop = stp->st_stateowner;	
+		struct nfs4_client *clp = sop->so_client;
+
+		if (!sop->so_is_open_owner)
+			goto out;
+		if (!cmp_clid(&clp->cl_clientid, lockclid))
+			goto out;
+	}
+
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
 		printk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
 		stp->st_vfs_set = 0;
@@ -1524,7 +1539,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 	if ((status = nfs4_preprocess_seqid_op(current_fh, oc->oc_seqid,
 					&oc->oc_req_stateid,
 					CHECK_FH | CONFIRM | OPEN_STATE,
-					&oc->oc_stateowner, &stp)))
+					&oc->oc_stateowner, &stp, NULL)))
 		goto out; 
 
 	sop = oc->oc_stateowner;
@@ -1556,7 +1571,7 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 	if ((status = nfs4_preprocess_seqid_op(current_fh, od->od_seqid, 
 					&od->od_stateid, 
 					CHECK_FH | OPEN_STATE, 
-					&od->od_stateowner, &stp)))
+					&od->od_stateowner, &stp, NULL)))
 		goto out; 
 
 	status = nfserr_inval;
@@ -1596,7 +1611,7 @@ nfsd4_close(struct svc_rqst *rqstp, stru
 	if ((status = nfs4_preprocess_seqid_op(current_fh, close->cl_seqid, 
 					&close->cl_stateid, 
 					CHECK_FH | OPEN_STATE, 
-					&close->cl_stateowner, &stp)))
+					&close->cl_stateowner, &stp, NULL)))
 		goto out; 
 	/*
 	*  Return success, but first update the stateid.
@@ -1852,12 +1867,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 			printk("NFSD: nfsd4_lock: clientid is stale!\n");
 			goto out;
 		}
+		/* does the clientid in the lock owner own the open stateid? */
+
 		/* validate and update open stateid and open seqid */
 		status = nfs4_preprocess_seqid_op(current_fh, 
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
 		                        CHECK_FH | OPEN_STATE,
-		                        &open_sop, &open_stp);
+		                        &open_sop, &open_stp,
+					&lock->v.new.clientid);
 		if (status)
 			goto out;
 		/* create lockowner and lock stateid */
@@ -1889,7 +1907,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
 				       CHECK_FH | LOCK_STATE, 
-				       &lock->lk_stateowner, &lock_stp);
+				       &lock->lk_stateowner, &lock_stp, NULL);
 		if (status)
 			goto out;
 	}
@@ -2094,7 +2112,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 					locku->lu_seqid, 
 					&locku->lu_stateid, 
 					CHECK_FH | LOCK_STATE, 
-					&locku->lu_stateowner, &stp)))
+					&locku->lu_stateowner, &stp, NULL)))
 		goto out;
 
 	filp = &stp->st_vfs_file;


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
