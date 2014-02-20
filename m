Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f52.google.com ([209.85.219.52]:64787 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaBTC2l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 21:28:41 -0500
Received: by mail-oa0-f52.google.com with SMTP id i4so1156921oah.39
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 18:28:41 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] NFSv4: Clear the open state flags if the new stateid does not match
Date: Wed, 19 Feb 2014 21:28:25 -0500
Message-Id: <1392863305-14870-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392863305-14870-6-git-send-email-trond.myklebust@primarydata.com>
References: <1392863305-14870-1-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-2-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-3-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-4-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-5-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC3530 and RFC5661 both prescribe that the 'opaque' field of the
open stateid returned by new OPEN/OPEN_DOWNGRADE/CLOSE calls for
the same file and open owner should match.
If this is not the case, assume that the open state has been lost,
and that we need to recover it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h   |  1 +
 fs/nfs/nfs4proc.c  | 30 ++++++++++++++++++++++++++----
 fs/nfs/nfs4state.c |  2 +-
 3 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index df81fcc138a7..e1d1badbe53c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -427,6 +427,7 @@ extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs_inode_find_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid);
+extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *, struct nfs4_state *);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
 extern int nfs4_wait_clnt_recover(struct nfs_client *clp);
 extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1f593a0bd938..2427ef4c4d63 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1137,13 +1137,30 @@ static void update_open_stateflags(struct nfs4_state *state, fmode_t fmode)
 	nfs4_state_set_mode_locked(state, state->state | fmode);
 }
 
+static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
+{
+	struct nfs_client *clp = state->owner->so_server->nfs_client;
+	bool need_recover = false;
+
+	if (test_and_clear_bit(NFS_O_RDONLY_STATE, &state->flags) && state->n_rdonly)
+		need_recover = true;
+	if (test_and_clear_bit(NFS_O_WRONLY_STATE, &state->flags) && state->n_wronly)
+		need_recover = true;
+	if (test_and_clear_bit(NFS_O_RDWR_STATE, &state->flags) && state->n_rdwr)
+		need_recover = true;
+	if (need_recover)
+		nfs4_state_mark_reclaim_nograce(clp, state);
+}
+
 static bool nfs_need_update_open_stateid(struct nfs4_state *state,
 		nfs4_stateid *stateid)
 {
 	if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
 		return true;
-	if (!nfs4_stateid_match_other(stateid, &state->open_stateid))
+	if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
+		nfs_test_and_clear_all_open_stateid(state);
 		return true;
+	}
 	if (nfs4_stateid_is_newer(stateid, &state->open_stateid))
 		return true;
 	return false;
@@ -1179,6 +1196,8 @@ static void nfs_clear_open_stateid(struct nfs4_state *state, nfs4_stateid *state
 	write_seqlock(&state->seqlock);
 	nfs_clear_open_stateid_locked(state, stateid, fmode);
 	write_sequnlock(&state->seqlock);
+	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
+		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
 }
 
 static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
@@ -1255,6 +1274,8 @@ no_delegation:
 		__update_open_stateid(state, open_stateid, NULL, fmode);
 		ret = 1;
 	}
+	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
+		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
 
 	return ret;
 }
@@ -1488,12 +1509,15 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 	struct nfs4_state *newstate;
 	int ret;
 
+	/* Don't trigger recovery in nfs_test_and_clear_all_open_stateid */
+	clear_bit(NFS_O_RDWR_STATE, &state->flags);
+	clear_bit(NFS_O_WRONLY_STATE, &state->flags);
+	clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 	/* memory barrier prior to reading state->n_* */
 	clear_bit(NFS_DELEGATED_STATE, &state->flags);
 	clear_bit(NFS_OPEN_STATE, &state->flags);
 	smp_rmb();
 	if (state->n_rdwr != 0) {
-		clear_bit(NFS_O_RDWR_STATE, &state->flags);
 		ret = nfs4_open_recover_helper(opendata, FMODE_READ|FMODE_WRITE, &newstate);
 		if (ret != 0)
 			return ret;
@@ -1501,7 +1525,6 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 			return -ESTALE;
 	}
 	if (state->n_wronly != 0) {
-		clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 		ret = nfs4_open_recover_helper(opendata, FMODE_WRITE, &newstate);
 		if (ret != 0)
 			return ret;
@@ -1509,7 +1532,6 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 			return -ESTALE;
 	}
 	if (state->n_rdonly != 0) {
-		clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 		ret = nfs4_open_recover_helper(opendata, FMODE_READ, &newstate);
 		if (ret != 0)
 			return ret;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e5be72518bd7..b524df9f6a74 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1321,7 +1321,7 @@ static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_st
 	return 1;
 }
 
-static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
+int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
 {
 	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
-- 
1.8.5.3

