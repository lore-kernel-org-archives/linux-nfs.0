Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:37209 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbaF3Pvv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:51 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so7254162qcz.28
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 055/114] nfsd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
Date: Mon, 30 Jun 2014 11:49:24 -0400
Message-Id: <1404143423-24381-56-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that all the callers put the open stateid after use.
Necessary step toward client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8ed48d0015e1..f2df0778448e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4356,6 +4356,8 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 						NFS4_OPEN_STID, stpp, nn);
 	if (status)
 		return status;
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&(*stpp)->st_stid.sc_count);
 	oo = openowner((*stpp)->st_stateowner);
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED))
 		return nfserr_bad_stateid;
@@ -4459,12 +4461,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	if (!test_access(od->od_share_access, stp)) {
 		dprintk("NFSD: access not a subset of current bitmap: 0x%hhx, input access=%08x\n",
 			stp->st_access_bmap, od->od_share_access);
-		goto out;
+		goto put_stateid;
 	}
 	if (!test_deny(od->od_share_deny, stp)) {
 		dprintk("NFSD: deny not a subset of current bitmap: 0x%hhx, input deny=%08x\n",
 			stp->st_deny_bmap, od->od_share_deny);
-		goto out;
+		goto put_stateid;
 	}
 	nfs4_stateid_downgrade(stp, od->od_share_access);
 
@@ -4473,6 +4475,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	status = nfs_ok;
+put_stateid:
+	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
@@ -4827,6 +4831,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp = NULL;
+	struct nfs4_ol_stateid *open_stp = NULL;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
@@ -4853,8 +4858,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
-		struct nfs4_ol_stateid *open_stp = NULL;
-
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
 			memcpy(&lock->v.new.clientid,
@@ -4977,6 +4980,8 @@ out:
 		fput(filp);
 	if (lock_stp)
 		put_generic_stateid(lock_stp);
+	if (open_stp)
+		put_generic_stateid(open_stp);
 	if (status && new_state)
 		release_lockowner_if_empty(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
-- 
1.9.3

