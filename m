Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:37648 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbaFZTPH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:07 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so3444752qgd.38
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:07 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 060/117] nfsd: Migrate the stateid reference into nfs4_preprocess_seqid_op
Date: Thu, 26 Jun 2014 15:12:40 -0400
Message-Id: <1403810017-16062-61-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Allow nfs4_preprocess_seqid_op to take the stateid reference, instead
of having all the callers do so.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b810be1ce2f7..0eb74ffb8db5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4353,8 +4353,11 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	nfsd4_cstate_assign_replay(cstate, stp->st_stateowner);
 
 	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
-	if (!status)
+	if (!status) {
+		/* FIXME: move into find_stateid_by_type */
+		atomic_inc(&stp->st_stid.sc_count);
 		*stpp = stp;
+	}
 	return status;
 }
 
@@ -4363,16 +4366,18 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 {
 	__be32 status;
 	struct nfs4_openowner *oo;
+	struct nfs4_ol_stateid *stp;
 
 	status = nfs4_preprocess_seqid_op(cstate, seqid, stateid,
-						NFS4_OPEN_STID, stpp, nn);
+						NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		return status;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&(*stpp)->st_stid.sc_count);
-	oo = openowner((*stpp)->st_stateowner);
-	if (!(oo->oo_flags & NFS4_OO_CONFIRMED))
+	oo = openowner(stp->st_stateowner);
+	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
+		put_generic_stateid(stp);
 		return nfserr_bad_stateid;
+	}
+	*stpp = stp;
 	return nfs_ok;
 }
 
@@ -4399,8 +4404,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		goto out;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
 	if (oo->oo_flags & NFS4_OO_CONFIRMED)
@@ -4564,8 +4567,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
@@ -4912,9 +4913,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
 				       NFS4_LOCK_STID, &lock_stp, nn);
-		/* FIXME: move into nfs4_preprocess_seqid_op */
-		if (!status)
-			atomic_inc(&lock_stp->st_stid.sc_count);
 	}
 	if (status)
 		goto out;
@@ -5142,8 +5140,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
-- 
1.9.3

