Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53250 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752816Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/15] nfsd4: remove HAS_SESSION
Date: Fri, 26 Aug 2011 18:28:28 -0400
Message-Id: <1314397716-18602-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This flag doesn't really buy us anything.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   30 ++++++++++--------------------
 fs/nfsd/state.h     |    3 +--
 fs/nfsd/xdr4.h      |    2 +-
 3 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7fb6ddc..a77d8a5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3170,13 +3170,13 @@ grace_disallows_io(struct inode *inode)
 	return locks_in_grace() && mandatory_lock(inode);
 }
 
-static int check_stateid_generation(stateid_t *in, stateid_t *ref, int flags)
+static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
 {
 	/*
 	 * When sessions are used the stateid generation number is ignored
 	 * when it is zero.
 	 */
-	if ((flags & HAS_SESSION) && in->si_generation == 0)
+	if (has_session && in->si_generation == 0)
 		goto out;
 
 	/* If the client sends us a stateid from the future, it's buggy: */
@@ -3208,7 +3208,7 @@ static int is_open_stateid(struct nfs4_stateid *stateid)
 	return stateid->st_openstp == NULL;
 }
 
-__be32 nfs4_validate_stateid(stateid_t *stateid, int flags)
+__be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 {
 	struct nfs4_stateid *stp = NULL;
 	__be32 status = nfserr_stale_stateid;
@@ -3225,7 +3225,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, int flags)
 	if (!stp->st_stateowner->so_confirmed)
 		goto out;
 
-	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
+	status = check_stateid_generation(stateid, &stp->st_stateid, has_session);
 	if (status)
 		goto out;
 
@@ -3253,9 +3253,6 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (grace_disallows_io(ino))
 		return nfserr_grace;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
-
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(current_fh, stateid, flags);
 
@@ -3272,8 +3269,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		dp = find_delegation_stateid(ino, stateid);
 		if (!dp)
 			goto out;
-		status = check_stateid_generation(stateid, &dp->dl_stateid,
-						  flags);
+		status = check_stateid_generation(stateid, &dp->dl_stateid, nfsd4_has_session(cstate));
 		if (status)
 			goto out;
 		status = nfs4_check_delegmode(dp, flags);
@@ -3294,7 +3290,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		if (!stp->st_stateowner->so_confirmed)
 			goto out;
 		status = check_stateid_generation(stateid, &stp->st_stateid,
-						  flags);
+						  nfsd4_has_session(cstate));
 		if (status)
 			goto out;
 		status = nfs4_check_openmode(stp, flags);
@@ -3423,9 +3419,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	if (STALE_STATEID(stateid))
 		return nfserr_stale_stateid;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
-
 	/*
 	* We return BAD_STATEID if filehandle doesn't match stateid, 
 	* the confirmed flag is incorrecly set, or the generation 
@@ -3459,7 +3452,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		if (lock->lk_is_new) {
 			if (!sop->so_is_open_owner)
 				return nfserr_bad_stateid;
-			if (!(flags & HAS_SESSION) &&
+			if (!nfsd4_has_session(cstate) &&
 			    !same_clid(&clp->cl_clientid, lockclid))
 				return nfserr_bad_stateid;
 			/* stp is the open stateid */
@@ -3484,7 +3477,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	*  For the moment, we ignore the possibility of 
 	*  generation number wraparound.
 	*/
-	if (!(flags & HAS_SESSION) && seqid != sop->so_seqid)
+	if (!nfsd4_has_session(cstate) && seqid != sop->so_seqid)
 		goto check_replay;
 
 	if (sop->so_confirmed && flags & CONFIRM) {
@@ -3497,7 +3490,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 				" confirmed yet!\n");
 		return nfserr_bad_stateid;
 	}
-	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
+	status = check_stateid_generation(stateid, &stp->st_stateid, nfsd4_has_session(cstate));
 	if (status)
 		return status;
 	renew_client(sop->so_client);
@@ -3681,14 +3674,11 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	stateid_t *stateid = &dr->dr_stateid;
 	struct inode *inode;
 	__be32 status;
-	int flags = 0;
 
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		return status;
 	inode = cstate->current_fh.fh_dentry->d_inode;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	status = nfserr_bad_stateid;
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
@@ -3703,7 +3693,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = find_delegation_stateid(inode, stateid);
 	if (!dp)
 		goto out;
-	status = check_stateid_generation(stateid, &dp->dl_stateid, flags);
+	status = check_stateid_generation(stateid, &dp->dl_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
 	renew_client(dp->dl_client);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5cfebe5..4a69c89 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -439,7 +439,6 @@ struct nfs4_stateid {
 };
 
 /* flags for preprocess_seqid_op() */
-#define HAS_SESSION             0x00000001
 #define CONFIRM                 0x00000002
 #define OPEN_STATE              0x00000004
 #define LOCK_STATE              0x00000008
@@ -476,7 +475,7 @@ extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
-extern __be32 nfs4_validate_stateid(stateid_t *, int);
+extern __be32 nfs4_validate_stateid(stateid_t *, bool);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index d2a8d044..663193b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -351,7 +351,7 @@ struct nfsd4_saved_compoundargs {
 
 struct nfsd4_test_stateid {
 	__be32		ts_num_ids;
-	__be32		ts_has_session;
+	bool		ts_has_session;
 	struct nfsd4_compoundargs *ts_saved_args;
 	struct nfsd4_saved_compoundargs ts_savedp;
 };
-- 
1.7.4.1

