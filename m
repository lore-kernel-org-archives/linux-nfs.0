Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54616 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbaDRSqQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:16 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so1829758iec.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 46/70] NFSd: Migrate the stateid reference into nfs4_preprocess_seqid_op
Date: Fri, 18 Apr 2014 14:44:40 -0400
Message-Id: <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow nfs4_preprocess_seqid_op to take the stateid reference, instead
of having all the callers do so.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ce35edcef193..8e2e519f9b94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4100,8 +4100,11 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
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
 
@@ -4110,16 +4113,18 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
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
 
@@ -4146,8 +4151,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		goto out;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
 	if (oo->oo_flags & NFS4_OO_CONFIRMED)
@@ -4282,8 +4285,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	oo = openowner(stp->st_stateowner);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
@@ -4622,9 +4623,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
 				       NFS4_LOCK_STID, &lock_stp, nn);
-		/* FIXME: move into nfs4_preprocess_seqid_op */
-		if (!status)
-			atomic_inc(&lock_stp->st_stid.sc_count);
 	}
 	if (status)
 		goto out;
@@ -4847,8 +4845,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
-- 
1.9.0

