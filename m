Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:60194 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbaG2Ue4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:56 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so297085qgd.40
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 18/38] nfsd: Migrate the stateid reference into nfs4_preprocess_seqid_op
Date: Tue, 29 Jul 2014 16:34:01 -0400
Message-Id: <1406666061-14175-19-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
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
index 7fa25be7ef2e..e348ab1bde40 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4390,8 +4390,11 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		cstate->replay_owner = stp->st_stateowner;
 
 	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
-	if (!status)
+	if (!status) {
+		/* FIXME: move into find_stateid_by_type */
+		atomic_inc(&stp->st_stid.sc_count);
 		*stpp = stp;
+	}
 	return status;
 }
 
@@ -4400,16 +4403,18 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
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
+		nfs4_put_stid(&stp->st_stid);
 		return nfserr_bad_stateid;
+	}
+	*stpp = stp;
 	return nfs_ok;
 }
 
@@ -4436,8 +4441,6 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		goto out;
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
 	if (oo->oo_flags & NFS4_OO_CONFIRMED)
@@ -4587,8 +4590,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	/* FIXME: move into nfs4_preprocess_seqid_op */
-	atomic_inc(&stp->st_stid.sc_count);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
@@ -4944,9 +4945,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
 				       NFS4_LOCK_STID, &lock_stp, nn);
-		/* FIXME: move into nfs4_preprocess_seqid_op */
-		if (!status)
-			atomic_inc(&lock_stp->st_stid.sc_count);
 	}
 	if (status)
 		goto out;
@@ -5175,8 +5173,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

