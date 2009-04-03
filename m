From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 22/35] nfsd: pass nfsd4_compound_state* to nfs4_preprocess_{state,seq}id_op
Date: Fri,  3 Apr 2009 08:28:41 +0300
Message-ID: <1238736521-17766-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25927 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756183AbZDCF2r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:47 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we only use cstate->current_fh,
will also be used by nfsd41 code.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c         |   10 ++++------
 fs/nfsd/nfs4state.c        |   22 ++++++++++++++--------
 include/linux/nfsd/state.h |    4 +++-
 3 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ae21a4e..e6a0f31 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -513,9 +513,8 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 	/* check stateid */
-	if ((status = nfs4_preprocess_stateid_op(&cstate->current_fh,
-				&read->rd_stateid,
-				RD_STATE, &read->rd_filp))) {
+	if ((status = nfs4_preprocess_stateid_op(cstate, &read->rd_stateid,
+						 RD_STATE, &read->rd_filp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -646,7 +645,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
-		status = nfs4_preprocess_stateid_op(&cstate->current_fh,
+		status = nfs4_preprocess_stateid_op(cstate,
 			&setattr->sa_stateid, WR_STATE, NULL);
 		nfs4_unlock_state();
 		if (status) {
@@ -686,8 +685,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	status = nfs4_preprocess_stateid_op(&cstate->current_fh, stateid,
-					WR_STATE, &filp);
+	status = nfs4_preprocess_stateid_op(cstate, stateid, WR_STATE, &filp);
 	if (filp)
 		get_file(filp);
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9192e5b..f49f305 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2810,10 +2810,12 @@ static int is_delegation_stateid(stateid_t *stateid)
 * Checks for stateid operations
 */
 __be32
-nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int flags, struct file **filpp)
+nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
+			   stateid_t *stateid, int flags, struct file **filpp)
 {
 	struct nfs4_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
+	struct svc_fh *current_fh = &cstate->current_fh;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	__be32 status;
 
@@ -2878,10 +2880,14 @@ setlkflg (int type)
  * Checks for sequence id mutating operations. 
  */
 static __be32
-nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *stateid, int flags, struct nfs4_stateowner **sopp, struct nfs4_stateid **stpp, struct nfsd4_lock *lock)
+nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
+			 stateid_t *stateid, int flags,
+			 struct nfs4_stateowner **sopp,
+			 struct nfs4_stateid **stpp, struct nfsd4_lock *lock)
 {
 	struct nfs4_stateid *stp;
 	struct nfs4_stateowner *sop;
+	struct svc_fh *current_fh = &cstate->current_fh;
 	__be32 status;
 
 	dprintk("NFSD: preprocess_seqid_op: seqid=%d " 
@@ -3004,7 +3010,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 
-	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
+	if ((status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					CONFIRM | OPEN_STATE,
 					&oc->oc_stateowner, &stp, NULL)))
@@ -3074,7 +3080,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
+	if ((status = nfs4_preprocess_seqid_op(cstate,
 					od->od_seqid,
 					&od->od_stateid, 
 					OPEN_STATE,
@@ -3127,7 +3133,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 	/* check close_lru for replay */
-	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
+	if ((status = nfs4_preprocess_seqid_op(cstate,
 					close->cl_seqid,
 					&close->cl_stateid, 
 					OPEN_STATE | CLOSE_STATE,
@@ -3474,7 +3480,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 
 		/* validate and update open stateid and open seqid */
-		status = nfs4_preprocess_seqid_op(&cstate->current_fh,
+		status = nfs4_preprocess_seqid_op(cstate,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
 					OPEN_STATE,
@@ -3501,7 +3507,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 	} else {
 		/* lock (lock owner + lock stateid) already exists */
-		status = nfs4_preprocess_seqid_op(&cstate->current_fh,
+		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
 				       LOCK_STATE,
@@ -3697,7 +3703,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 									        
-	if ((status = nfs4_preprocess_seqid_op(&cstate->current_fh,
+	if ((status = nfs4_preprocess_seqid_op(cstate,
 					locku->lu_seqid, 
 					&locku->lu_stateid, 
 					LOCK_STATE,
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 18dcffa..836c0d6 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -333,7 +333,9 @@ struct nfs4_stateid {
 	((err) != nfserr_stale_stateid) &&      \
 	((err) != nfserr_bad_stateid))
 
-extern __be32 nfs4_preprocess_stateid_op(struct svc_fh *current_fh,
+struct nfsd4_compound_state;
+
+extern __be32 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		stateid_t *stateid, int flags, struct file **filp);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
-- 
1.6.2.1

