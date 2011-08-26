Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53244 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/15] nfsd4: get lock checks out of preprocess_seqid_op
Date: Fri, 26 Aug 2011 18:28:31 -0400
Message-Id: <1314397716-18602-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We've got some lock-specific code here in nfs4_preprocess_seqid_op which
is only used by nfsd4_lock().  Move it to the caller.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   49 ++++++++++++++++++++-----------------------------
 1 files changed, 20 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3c4e7ef..b8903b5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3398,7 +3398,7 @@ static __be32
 nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 stateid_t *stateid, int flags,
 			 struct nfs4_stateowner **sopp,
-			 struct nfs4_stateid **stpp, struct nfsd4_lock *lock)
+			 struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *stp;
 	struct nfs4_stateowner *sop;
@@ -3441,27 +3441,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	*stpp = stp;
 	*sopp = sop = stp->st_stateowner;
 
-	if (lock) {
-		clientid_t *lockclid = &lock->v.new.clientid;
-		struct nfs4_client *clp = sop->so_client;
-		int lkflg = 0;
-		__be32 status;
-
-		lkflg = setlkflg(lock->lk_type);
-
-		if (lock->lk_is_new) {
-			if (!sop->so_is_open_owner)
-				return nfserr_bad_stateid;
-			if (!nfsd4_has_session(cstate) &&
-			    !same_clid(&clp->cl_clientid, lockclid))
-				return nfserr_bad_stateid;
-		}
-		/* stp is the open stateid */
-		status = nfs4_check_openmode(stp, lkflg);
-		if (status)
-			return status;
-	}
-
 	if (nfs4_check_fh(current_fh, stp)) {
 		dprintk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
 		return nfserr_bad_stateid;
@@ -3524,7 +3503,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if ((status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
 					CONFIRM | OPEN_STATE,
-					&oc->oc_stateowner, &stp, NULL)))
+					&oc->oc_stateowner, &stp)))
 		goto out; 
 
 	sop = oc->oc_stateowner;
@@ -3587,7 +3566,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 					od->od_seqid,
 					&od->od_stateid, 
 					OPEN_STATE,
-					&od->od_stateowner, &stp, NULL)))
+					&od->od_stateowner, &stp)))
 		goto out; 
 
 	status = nfserr_inval;
@@ -3637,7 +3616,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					close->cl_seqid,
 					&close->cl_stateid, 
 					OPEN_STATE | CLOSE_STATE,
-					&close->cl_stateowner, &stp, NULL)))
+					&close->cl_stateowner, &stp)))
 		goto out; 
 	status = nfs_ok;
 	update_stateid(&stp->st_stateid);
@@ -3999,6 +3978,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock conflock;
 	__be32 status = 0;
 	unsigned int strhashval;
+	int lkflg;
 	int err;
 
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
@@ -4034,11 +4014,17 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
 					OPEN_STATE,
-		                        &lock->lk_replay_owner, &open_stp,
-					lock);
+		                        &lock->lk_replay_owner, &open_stp);
 		if (status)
 			goto out;
+		status = nfserr_bad_stateid;
 		open_sop = lock->lk_replay_owner;
+		if (!open_sop->so_is_open_owner)
+			goto out;
+		if (!nfsd4_has_session(cstate) &&
+				!same_clid(&open_sop->so_client->cl_clientid,
+						&lock->v.new.clientid))
+			goto out;
 		/* create lockowner and lock stateid */
 		fp = open_stp->st_file;
 		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
@@ -4061,7 +4047,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				       lock->lk_old_lock_seqid, 
 				       &lock->lk_old_lock_stateid, 
 				       LOCK_STATE,
-				       &lock->lk_replay_owner, &lock_stp, lock);
+				       &lock->lk_replay_owner, &lock_stp);
 		if (status)
 			goto out;
 		lock_sop = lock->lk_replay_owner;
@@ -4069,6 +4055,11 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	/* lock->lk_replay_owner and lock_stp have been created or found */
 
+	lkflg = setlkflg(lock->lk_type);
+	status = nfs4_check_openmode(lock_stp, lkflg);
+	if (status)
+		goto out;
+
 	status = nfserr_grace;
 	if (locks_in_grace() && !lock->lk_reclaim)
 		goto out;
@@ -4261,7 +4252,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					locku->lu_seqid, 
 					&locku->lu_stateid, 
 					LOCK_STATE,
-					&locku->lu_stateowner, &stp, NULL)))
+					&locku->lu_stateowner, &stp)))
 		goto out;
 
 	filp = find_any_file(stp->st_file);
-- 
1.7.4.1

