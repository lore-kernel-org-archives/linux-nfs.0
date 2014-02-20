Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33489 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaBTC2k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 21:28:40 -0500
Received: by mail-ob0-f177.google.com with SMTP id wp18so1436063obc.22
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 18:28:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] NFSv4: Use correct locking when updating nfs4_state in nfs4_close_done
Date: Wed, 19 Feb 2014 21:28:24 -0500
Message-Id: <1392863305-14870-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392863305-14870-5-git-send-email-trond.myklebust@primarydata.com>
References: <1392863305-14870-1-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-2-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-3-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-4-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The stateid and state->flags should be updated atomically under
protection of the state->seqlock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 65 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 35 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 96e0bd42f38c..1f593a0bd938 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1149,6 +1149,38 @@ static bool nfs_need_update_open_stateid(struct nfs4_state *state,
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
@@ -1168,13 +1200,6 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
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
@@ -2489,26 +2514,6 @@ static void nfs4_free_closedata(void *data)
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
@@ -2527,9 +2532,9 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
@@ -2543,7 +2548,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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

