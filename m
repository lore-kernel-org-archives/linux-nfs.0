Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34653 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbbHaBrr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2015 21:47:47 -0400
Received: by pabzx8 with SMTP id zx8so121457227pab.1
        for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2015 18:47:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix a protocol issue with CLOSE stateids
Date: Sun, 30 Aug 2015 18:47:42 -0700
Message-Id: <1440985662-15667-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661 Section 18.2.4, CLOSE is supposed to return
the zero stateid. This means that nfs_clear_open_stateid_locked()
cannot assume that the result stateid will always match the 'other'
field of the existing open stateid when trying to determine a race
with a parallel OPEN.

Instead, we look at the argument, and check for matches.

Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2923abf2fc0c..366b81c185f6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1231,6 +1231,7 @@ static void nfs_resync_open_stateid_locked(struct nfs4_state *state)
 }
 
 static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
+		nfs4_stateid *arg_stateid,
 		nfs4_stateid *stateid, fmode_t fmode)
 {
 	clear_bit(NFS_O_RDWR_STATE, &state->flags);
@@ -1249,8 +1250,9 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	if (stateid == NULL)
 		return;
 	/* Handle races with OPEN */
-	if (!nfs4_stateid_match_other(stateid, &state->open_stateid) ||
-	    !nfs4_stateid_is_newer(stateid, &state->open_stateid)) {
+	if (!nfs4_stateid_match_other(arg_stateid, &state->open_stateid) ||
+	    (nfs4_stateid_match_other(stateid, &state->open_stateid) &&
+	    !nfs4_stateid_is_newer(stateid, &state->open_stateid))) {
 		nfs_resync_open_stateid_locked(state);
 		return;
 	}
@@ -1259,10 +1261,12 @@ static void nfs_clear_open_stateid_locked(struct nfs4_state *state,
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void nfs_clear_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
+static void nfs_clear_open_stateid(struct nfs4_state *state,
+	nfs4_stateid *arg_stateid,
+	nfs4_stateid *stateid, fmode_t fmode)
 {
 	write_seqlock(&state->seqlock);
-	nfs_clear_open_stateid_locked(state, stateid, fmode);
+	nfs_clear_open_stateid_locked(state, arg_stateid, stateid, fmode);
 	write_sequnlock(&state->seqlock);
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
 		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
@@ -2707,7 +2711,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				goto out_release;
 			}
 	}
-	nfs_clear_open_stateid(state, res_stateid, calldata->arg.fmode);
+	nfs_clear_open_stateid(state, &calldata->arg.stateid,
+			res_stateid, calldata->arg.fmode);
 out_release:
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
-- 
2.4.3

