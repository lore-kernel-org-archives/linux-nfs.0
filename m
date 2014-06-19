Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:41374 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758027AbaFSOv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:57 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so2218719qgf.28
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 041/104] NFSd: Add reference counting to nfs4_preprocess_confirmed_seqid_op
Date: Thu, 19 Jun 2014 10:49:47 -0400
Message-Id: <1403189450-18729-42-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that all the callers put the open stateid after use.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b0144269f9d..ff6e0f99413c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4224,6 +4224,8 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 						NFS4_OPEN_STID, stpp, nn);
 	if (status)
 		return status;
+	/* FIXME: move into nfs4_preprocess_seqid_op */
+	atomic_inc(&(*stpp)->st_stid.sc_count);
 	oo = openowner((*stpp)->st_stateowner);
 	if (!(oo->oo_flags & NFS4_OO_CONFIRMED))
 		return nfserr_bad_stateid;
@@ -4364,12 +4366,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
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
 	nfs4_stateid_downgrade(stp, od->od_share_access, od->od_share_deny);
 
@@ -4378,6 +4380,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	status = nfs_ok;
+put_stateid:
+	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
@@ -4734,6 +4738,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_ol_stateid *lock_stp = NULL;
+	struct nfs4_ol_stateid *open_stp = NULL;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
 	struct file_lock *conflock = NULL;
@@ -4760,8 +4765,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (lock->lk_is_new) {
-		struct nfs4_ol_stateid *open_stp = NULL;
-
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
 			memcpy(&lock->v.new.clientid,
@@ -4884,6 +4887,8 @@ out:
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

