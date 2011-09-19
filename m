Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34289 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753172Ab1ISNPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 09:15:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd4: hash closed stateid's like any other
Date: Mon, 19 Sep 2011 09:15:43 -0400
Message-Id: <1316438143-1057-5-git-send-email-bfields@redhat.com>
In-Reply-To: <20110919131415.GB32498@fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Look up closed stateid's in the stateid hash like any other stateid
rather than searching the close lru.

This is simpler, and fixes a bug: currently we handle only the case of a
close that is the last close for a given stateowner, but not the case of
a close for a stateowner that still has active opens on other files.
Thus in a case like:

	open(owner, file1)
	open(owner, file2)
	close(owner, file2)
	close(owner, file2)

the final close won't be recognized as a retransmission.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  101 +++++++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |    4 ++-
 2 files changed, 56 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 922f47d..e5cba83 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -406,7 +406,6 @@ static int nfs4_access_to_omode(u32 access)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	list_del(&stp->st_stid.sc_hash);
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perstateowner);
 }
@@ -437,6 +436,7 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	struct file *file;
 
 	unhash_generic_stateid(stp);
+	list_del(&stp->st_stid.sc_hash);
 	file = find_any_file(stp->st_file);
 	if (file)
 		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
@@ -485,6 +485,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
+	list_del(&stp->st_stid.sc_hash);
 	free_generic_stateid(stp);
 }
 
@@ -501,12 +502,22 @@ static void unhash_openowner(struct nfs4_openowner *oo)
 	}
 }
 
+static void release_last_closed_stateid(struct nfs4_openowner *oo)
+{
+	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
+
+	if (s) {
+		list_del_init(&s->st_stid.sc_hash);
+		free_generic_stateid(s);
+		oo->oo_last_closed_stid = NULL;
+	}
+}
+
 static void release_openowner(struct nfs4_openowner *oo)
 {
 	unhash_openowner(oo);
 	list_del(&oo->oo_close_lru);
-	if (oo->oo_last_closed_stid)
-		free_generic_stateid(oo->oo_last_closed_stid);
+	release_last_closed_stateid(oo);
 	nfs4_free_openowner(oo);
 }
 
@@ -3099,23 +3110,11 @@ laundromat_main(struct work_struct *not_used)
 	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
 }
 
-static struct nfs4_openowner * search_close_lru(stateid_t *s)
-{
-	struct nfs4_openowner *local;
-	struct nfs4_ol_stateid *os;
-
-	list_for_each_entry(local, &close_lru, oo_close_lru) {
-		os = local->oo_last_closed_stid;
-		if (same_stateid(&os->st_stid.sc_stateid, s))
-			return local;
-	}
-	return NULL;
-}
-
-static inline int
-nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
+static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	return fhp->fh_dentry->d_inode != stp->st_file->fi_inode;
+	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+		return nfserr_bad_stateid;
+	return nfs_ok;
 }
 
 static int
@@ -3283,7 +3282,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
-	if (s->sc_type == NFS4_DELEG_STID) {
+	switch (s->sc_type) {
+	case NFS4_DELEG_STID:
 		dp = delegstateid(s);
 		status = nfs4_check_delegmode(dp, flags);
 		if (status)
@@ -3293,10 +3293,12 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			*filpp = dp->dl_file->fi_deleg_file;
 			BUG_ON(!*filpp);
 		}
-	} else { /* open or lock stateid */
+		break;
+	case NFS4_OPEN_STID:
+	case NFS4_LOCK_STID:
 		stp = openlockstateid(s);
-		status = nfserr_bad_stateid;
-		if (nfs4_check_fh(current_fh, stp))
+		status = nfs4_check_fh(current_fh, stp);
+		if (status)
 			goto out;
 		if (stp->st_stateowner->so_is_open_owner
 		    && !(openowner(stp->st_stateowner)->oo_flags & NFS4_OO_CONFIRMED))
@@ -3311,6 +3313,9 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			else
 				*filpp = find_writeable_file(stp->st_file);
 		}
+		break;
+	default:
+		return nfserr_bad_stateid;
 	}
 	status = nfs_ok;
 out:
@@ -3362,6 +3367,9 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			ret = nfsd4_free_lock_stateid(openlockstateid(s));
 		else
 			ret = nfserr_locks_held;
+		break;
+	default:
+		ret = nfserr_bad_stateid;
 	}
 out:
 	nfs4_unlock_state();
@@ -3390,12 +3398,19 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	__be32 status;
 
-	if (nfs4_check_fh(current_fh, stp))
-		return nfserr_bad_stateid;
 	status = nfsd4_check_seqid(cstate, sop, seqid);
 	if (status)
 		return status;
-	return check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
+	if (stp->st_stid.sc_type == NFS4_CLOSED_STID)
+		/*
+		 * "Closed" stateid's exist *only* to return
+		 * nfserr_replay_me from the previous step.
+		 */
+		return nfserr_bad_stateid;
+	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
+	if (status)
+		return status;
+	return nfs4_check_fh(current_fh, stp);
 }
 
 /* 
@@ -3564,8 +3579,13 @@ void nfsd4_purge_closed_stateid(struct nfs4_stateowner *so)
 		return;
 	}
 	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
-	free_generic_stateid(oo->oo_last_closed_stid);
-	oo->oo_last_closed_stid = NULL;
+	release_last_closed_stateid(oo);
+}
+
+static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
+{
+	unhash_open_stateid(s);
+	s->st_stid.sc_type = NFS4_CLOSED_STID;
 }
 
 /*
@@ -3584,24 +3604,10 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			cstate->current_fh.fh_dentry->d_name.name);
 
 	nfs4_lock_state();
-	/* check close_lru for replay */
-	status = nfs4_preprocess_confirmed_seqid_op(cstate, close->cl_seqid,
-					&close->cl_stateid, &stp);
-	if (stp == NULL && status == nfserr_expired) {
-		/*
-		 * Also, we should make sure this isn't just the result of
-		 * a replayed close:
-		 */
-		oo = search_close_lru(&close->cl_stateid);
-		/* It's not stale; let's assume it's expired: */
-		if (oo == NULL)
-			goto out;
-		cstate->replay_owner = &oo->oo_owner;
-		status = nfsd4_check_seqid(cstate, &oo->oo_owner, close->cl_seqid);
-		if (status)
-			goto out;
-		status = nfserr_bad_seqid;
-	}
+	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
+					&close->cl_stateid,
+					NFS4_OPEN_STID|NFS4_CLOSED_STID,
+					&stp);
 	if (status)
 		goto out; 
 	oo = openowner(stp->st_stateowner);
@@ -3609,9 +3615,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-	/* unhash_open_stateid() calls nfsd_close() if needed */
+	nfsd4_close_open_stateid(stp);
 	oo->oo_last_closed_stid = stp;
-	unhash_open_stateid(stp);
 
 	/* place unused nfs4_stateowners on so_close_lru list to be
 	 * released by the laundromat service after the lease period
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d6aec4f..da68bf6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -76,7 +76,9 @@ struct nfs4_stid {
 #define NFS4_OPEN_STID 1
 #define NFS4_LOCK_STID 2
 #define NFS4_DELEG_STID 4
-	char sc_type;
+/* For an open stateid kept around *only* to process close replays: */
+#define NFS4_CLOSED_STID 8
+	unsigned char sc_type;
 	struct list_head sc_hash;
 	stateid_t sc_stateid;
 };
-- 
1.7.4.1

