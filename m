Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:41138 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbaBKThT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:37:19 -0500
Received: by mail-ig0-f178.google.com with SMTP id uq10so9465289igb.5
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:37:19 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: Use correct locking when updating nfs4_state in nfs4_close_done
Date: Tue, 11 Feb 2014 14:37:08 -0500
Message-Id: <1392147428-23087-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392147428-23087-5-git-send-email-trond.myklebust@primarydata.com>
References: <1392147428-23087-1-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-2-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-3-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-4-git-send-email-trond.myklebust@primarydata.com>
 <1392147428-23087-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The stateid and state->flags should be updated atomically under
protection of the state->seqlock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 65 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 35 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4eb78f6c3623..c0015c2d2ac2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1151,6 +1151,38 @@ static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 	return false;
 }
 
+static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
+		nfs4_stateid *stateid, fmode_t fmode)
+{
+	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
+	case FMODE_WRITE:
+		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+		break;
+	case FMODE_READ:
+		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+		break;
+	case 0:
+		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
+		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+		clear_bit(NFS_OPEN_STATE, &state->flags);
+	}
+	if (stateid == NULL)
+		return;
+	if (!nfs_need_update_open_stateid(state, stateid))
+		return;
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
+		nfs4_stateid_copy(&state->stateid, stateid);
+	nfs4_stateid_copy(&state->open_stateid, stateid);
+}
+
+static void nfs_clear_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
+{
+	write_seqlock(&state->seqlock);
+	nfs_clear_open_stateid_locked(state, stateid, fmode);
+	write_sequnlock(&state->seqlock);
+}
+
 static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
 {
 	switch (fmode) {
@@ -1170,13 +1202,6 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void nfs_set_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
-{
-	write_seqlock(&state->seqlock);
-	nfs_set_open_stateid_locked(state, stateid, fmode);
-	write_sequnlock(&state->seqlock);
-}
-
 static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
 {
 	/*
@@ -2491,26 +2516,6 @@ static void nfs4_free_closedata(void *data)
 	kfree(calldata);
 }
 
-static void nfs4_close_clear_stateid_flags(struct nfs4_state *state,
-		fmode_t fmode)
-{
-	spin_lock(&state->owner->so_lock);
-	clear_bit(NFS_O_RDWR_STATE, &state->flags);
-	switch (fmode & (FMODE_READ|FMODE_WRITE)) {
-	case FMODE_WRITE:
-		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
-		break;
-	case FMODE_READ:
-		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
-		break;
-	case 0:
-		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
-		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
-		clear_bit(NFS_OPEN_STATE, &state->flags);
-	}
-	spin_unlock(&state->owner->so_lock);
-}
-
 static void nfs4_close_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_closedata *calldata = data;
@@ -2529,9 +2534,9 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->roc)
 				pnfs_roc_set_barrier(state->inode,
 						     calldata->roc_barrier);
-			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
+			nfs_clear_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
-			break;
+			goto out_release;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_OLD_STATEID:
@@ -2545,7 +2550,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				goto out_release;
 			}
 	}
-	nfs4_close_clear_stateid_flags(state, calldata->arg.fmode);
+	nfs_clear_open_stateid(state, NULL, calldata->arg.fmode);
 out_release:
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
-- 
1.8.5.3

