Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:47664 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbaF3Pvw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:52 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so6667395qaj.9
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 056/114] nfsd: Migrate the stateid reference into nfs4_preprocess_seqid_op
Date: Mon, 30 Jun 2014 11:49:25 -0400
Message-Id: <1404143423-24381-57-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index f2df0778448e..2b7ce084eb04 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4341,8 +4341,11 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
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
 
@@ -4351,16 +4354,18 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
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
 
@@ -4387,8 +4392,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		goto out;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
 	if (oo->oo_flags & NFS4_OO_CONFIRMED)
@@ -4536,8 +4539,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
@@ -4887,9 +4888,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
 				       NFS4_LOCK_STID, &lock_stp, nn);
-		/* FIXME: move into nfs4_preprocess_seqid_op */
-		if (!status)
-			atomic_inc(&lock_stp->st_stid.sc_count);
 	}
 	if (status)
 		goto out;
@@ -5112,8 +5110,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

