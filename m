Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:34998 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbaFZTPG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:06 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so3235099qac.11
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:06 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 059/117] nfsd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
Date: Thu, 26 Jun 2014 15:12:39 -0400
Message-Id: <1403810017-16062-60-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
index 32d0238cb0bf..b810be1ce2f7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4368,6 +4368,8 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 						NFS4_OPEN_STID, stpp, nn);
 	if (status)
 		return status;
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&(*stpp)->st_stid.sc_count);
 	oo = openowner((*stpp)->st_stateowner);
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED))
 		return nfserr_bad_stateid;
@@ -4487,12 +4489,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	if (!test_access(od->od_share_access, stp)) {
 		dprintk("NFSD: access not a subset current bitmap: 0x%lx, input access=%08x\n",
 			stp->st_access_bmap, od->od_share_access);
-		goto out;
+		goto put_stateid;
 	}
 	if (!test_deny(od->od_share_deny, stp)) {
 		dprintk("NFSD:deny not a subset current bitmap: 0x%lx, input deny=%08x\n",
 			stp->st_deny_bmap, od->od_share_deny);
-		goto out;
+		goto put_stateid;
 	}
 	nfs4_stateid_downgrade(stp, od->od_share_access);
 
@@ -4501,6 +4503,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	status = nfs_ok;
+put_stateid:
+	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
@@ -4851,6 +4855,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp = NULL;
+	struct nfs4_ol_stateid *open_stp = NULL;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
@@ -4878,8 +4883,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
-		struct nfs4_ol_stateid *open_stp = NULL;
-
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
 			memcpy(&lock->v.new.clientid,
@@ -5007,6 +5010,8 @@ out:
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

