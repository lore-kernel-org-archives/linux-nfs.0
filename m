Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36143 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965694AbcIVRkH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:07 -0400
Received: by mail-it0-f67.google.com with SMTP id n143so5337153ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:40:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 30/31] NFSv4: If recovery failed for a specific open stateid, then don't retry
Date: Thu, 22 Sep 2016 13:39:20 -0400
Message-Id: <1474565961-21303-31-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-30-git-send-email-trond.myklebust@primarydata.com>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-2-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-3-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-4-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-5-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-6-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-7-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-8-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-9-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-10-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-11-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-12-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-13-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-14-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-25-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-26-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-27-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-28-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-29-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-30-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0a25f70a3b0b..5f4281ec5f72 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -991,6 +991,8 @@ int nfs4_select_rw_stateid(struct nfs4_state *state,
 {
 	int ret;
 
+	if (!nfs4_valid_open_stateid(state))
+		return -EIO;
 	if (cred != NULL)
 		*cred = NULL;
 	ret = nfs4_copy_lock_stateid(dst, state, lockowner);
@@ -1303,6 +1305,8 @@ void nfs4_schedule_path_down_recovery(struct nfs_client *clp)
 static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
 
+	if (!nfs4_valid_open_stateid(state))
+		return 0;
 	set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
 	/* Don't recover state that expired before the reboot */
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
@@ -1316,6 +1320,8 @@ static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_st
 
 int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
 {
+	if (!nfs4_valid_open_stateid(state))
+		return 0;
 	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
 	set_bit(NFS_OWNER_RECLAIM_NOGRACE, &state->owner->so_flags);
@@ -1327,9 +1333,8 @@ int nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4_
 {
 	struct nfs_client *clp = server->nfs_client;
 
-	if (!nfs4_valid_open_stateid(state))
+	if (!nfs4_state_mark_reclaim_nograce(clp, state))
 		return -EBADF;
-	nfs4_state_mark_reclaim_nograce(clp, state);
 	dprintk("%s: scheduling stateid recovery for server %s\n", __func__,
 			clp->cl_hostname);
 	nfs4_schedule_state_manager(clp);
@@ -1380,15 +1385,14 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 		state = ctx->state;
 		if (state == NULL)
 			continue;
-		if (nfs4_stateid_match_other(&state->stateid, stateid)) {
-			nfs4_state_mark_reclaim_nograce(clp, state);
+		if (nfs4_stateid_match_other(&state->stateid, stateid) &&
+		    nfs4_state_mark_reclaim_nograce(clp, state)) {
 			found = true;
 			continue;
 		}
-		if (nfs_state_lock_state_matches_stateid(state, stateid)) {
-			nfs4_state_mark_reclaim_nograce(clp, state);
+		if (nfs_state_lock_state_matches_stateid(state, stateid) &&
+		    nfs4_state_mark_reclaim_nograce(clp, state))
 			found = true;
-		}
 	}
 	spin_unlock(&inode->i_lock);
 
-- 
2.7.4

