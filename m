Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:42763 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392AbaG2Uez (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:55 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so314566qge.10
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 17/38] nfsd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
Date: Tue, 29 Jul 2014 16:34:00 -0400
Message-Id: <1406666061-14175-18-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
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
index 5e31bc6a03a6..7fa25be7ef2e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4405,6 +4405,8 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 						NFS4_OPEN_STID, stpp, nn);
 	if (status)
 		return status;
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&(*stpp)->st_stid.sc_count);
 	oo = openowner((*stpp)->st_stateowner);
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED))
 		return nfserr_bad_stateid;
@@ -4509,12 +4511,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
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
 
@@ -4523,6 +4525,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	status = nfs_ok;
+put_stateid:
+	nfs4_put_stid(&stp->st_stid);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
@@ -4883,6 +4887,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp = NULL;
+	struct nfs4_ol_stateid *open_stp = NULL;
 	struct nfs4_file *fp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
@@ -4910,8 +4915,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
-		struct nfs4_ol_stateid *open_stp = NULL;
-
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
 			memcpy(&lock->v.new.clientid,
@@ -5039,6 +5042,8 @@ out:
 		fput(filp);
 	if (lock_stp)
 		nfs4_put_stid(&lock_stp->st_stid);
+	if (open_stp)
+		nfs4_put_stid(&open_stp->st_stid);
 	if (status && new_state)
 		release_lock_stateid(lock_stp);
 	nfsd4_bump_seqid(cstate, status);
-- 
1.9.3

