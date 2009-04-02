From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 19/21] SQUASHME: nfsd41: calculate HAS_SESSION in nfs4_preprocess_seqid_op
Date: Fri,  3 Apr 2009 01:38:55 +0300
Message-ID: <1238711935-22614-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30285 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760211AbZDBWjB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:39:01 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use nfsd4_has_session(cstate) in nfs4_preprocess_seqid_op rather
than passing it in.

squash into "nfsd41: stateid handling"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   34 +++++++++++-----------------------
 1 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0bdbff4..92d5feb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2974,6 +2974,10 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 
 	if (STALE_STATEID(stateid))
 		return nfserr_stale_stateid;
+
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
+
 	/*
 	* We return BAD_STATEID if filehandle doesn't match stateid, 
 	* the confirmed flag is incorrecly set, or the generation 
@@ -3140,7 +3144,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	__be32 status;
 	struct nfs4_stateid *stp;
 	unsigned int share_access;
-	int flags = OPEN_STATE;
 
 	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3150,13 +3153,11 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 			|| !deny_valid(od->od_share_deny))
 		return nfserr_inval;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_seqid_op(cstate,
 					od->od_seqid,
 					&od->od_stateid, 
-					flags,
+					OPEN_STATE,
 					&od->od_stateowner, &stp, NULL)))
 		goto out; 
 
@@ -3199,20 +3200,17 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfs4_stateid *stp;
-	int flags = OPEN_STATE | CLOSE_STATE;
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	/* check close_lru for replay */
 	if ((status = nfs4_preprocess_seqid_op(cstate,
 					close->cl_seqid,
 					&close->cl_stateid, 
-					flags,
+					OPEN_STATE | CLOSE_STATE,
 					&close->cl_stateowner, &stp, NULL)))
 		goto out; 
 	status = nfs_ok;
@@ -3528,7 +3526,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = 0;
 	unsigned int strhashval;
 	unsigned int cmd;
-	int err, flags = 0;
+	int err;
 
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
 		(long long) lock->lk_offset,
@@ -3559,15 +3557,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		    STALE_CLIENTID(&lock->lk_new_clientid))
 			goto out;
 
-		flags = OPEN_STATE;
-		if (nfsd4_has_session(cstate))
-			flags |= HAS_SESSION;
-
 		/* validate and update open stateid and open seqid */
 		status = nfs4_preprocess_seqid_op(cstate,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
-					flags,
+					OPEN_STATE,
 		                        &lock->lk_replay_owner, &open_stp,
 					lock);
 		if (status)
@@ -3590,15 +3584,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		if (lock_stp == NULL)
 			goto out;
 	} else {
-		flags = LOCK_STATE;
-		if (nfsd4_has_session(cstate))
-			flags |= HAS_SESSION;
-
 		/* lock (lock owner + lock stateid) already exists */
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
-				       flags,
+				       LOCK_STATE,
 				       &lock->lk_replay_owner, &lock_stp, lock);
 		if (status)
 			goto out;
@@ -3780,7 +3770,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file *filp = NULL;
 	struct file_lock file_lock;
 	__be32 status;
-	int err, flags = LOCK_STATE;
+	int err;
 						        
 	dprintk("NFSD: nfsd4_locku: start=%Ld length=%Ld\n",
 		(long long) locku->lu_offset,
@@ -3789,14 +3779,12 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	nfs4_lock_state();
 									        
 	if ((status = nfs4_preprocess_seqid_op(cstate,
 					locku->lu_seqid, 
 					&locku->lu_stateid, 
-					flags,
+					LOCK_STATE,
 					&locku->lu_stateowner, &stp, NULL)))
 		goto out;
 
-- 
1.6.2.1

