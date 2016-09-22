Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35698 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965694AbcIVRkA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 13:40:00 -0400
Received: by mail-it0-f68.google.com with SMTP id e20so5326493itc.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 10:39:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH v7 23/31] NFSv4: Fix a race when updating an open_stateid
Date: Thu, 22 Sep 2016 13:39:13 -0400
Message-Id: <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're replacing an old stateid which has a different 'other' field,
then we probably need to free the old stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ddfb300addf..338684195e95 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1399,11 +1399,12 @@ static void nfs_test_and_clear_all_open_stateid(struct nfs4_state *state)
 }
 
 static bool nfs_need_update_open_stateid(struct nfs4_state *state,
-		nfs4_stateid *stateid)
+		const nfs4_stateid *stateid, nfs4_stateid *freeme)
 {
 	if (test_and_set_bit(NFS_OPEN_STATE, &state->flags) == 0)
 		return true;
 	if (!nfs4_stateid_match_other(stateid, &state->open_stateid)) {
+		nfs4_stateid_copy(freeme, &state->open_stateid);
 		nfs_test_and_clear_all_open_stateid(state);
 		return true;
 	}
@@ -1467,7 +1468,9 @@ static void nfs_clear_open_stateid(struct nfs4_state *state,
 		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
 }
 
-static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
+static void nfs_set_open_stateid_locked(struct nfs4_state *state,
+		const nfs4_stateid *stateid, fmode_t fmode,
+		nfs4_stateid *freeme)
 {
 	switch (fmode) {
 		case FMODE_READ:
@@ -1479,14 +1482,18 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *
 		case FMODE_READ|FMODE_WRITE:
 			set_bit(NFS_O_RDWR_STATE, &state->flags);
 	}
-	if (!nfs_need_update_open_stateid(state, stateid))
+	if (!nfs_need_update_open_stateid(state, stateid, freeme))
 		return;
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
 		nfs4_stateid_copy(&state->stateid, stateid);
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, fmode_t fmode)
+static void __update_open_stateid(struct nfs4_state *state,
+		const nfs4_stateid *open_stateid,
+		const nfs4_stateid *deleg_stateid,
+		fmode_t fmode,
+		nfs4_stateid *freeme)
 {
 	/*
 	 * Protect the call to nfs4_state_set_mode_locked and
@@ -1499,16 +1506,22 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 		set_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
 	if (open_stateid != NULL)
-		nfs_set_open_stateid_locked(state, open_stateid, fmode);
+		nfs_set_open_stateid_locked(state, open_stateid, fmode, freeme);
 	write_sequnlock(&state->seqlock);
 	update_open_stateflags(state, fmode);
 	spin_unlock(&state->owner->so_lock);
 }
 
-static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, nfs4_stateid *delegation, fmode_t fmode)
+static int update_open_stateid(struct nfs4_state *state,
+		const nfs4_stateid *open_stateid,
+		const nfs4_stateid *delegation,
+		fmode_t fmode)
 {
+	struct nfs_server *server = NFS_SERVER(state->inode);
+	struct nfs_client *clp = server->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	struct nfs_delegation *deleg_cur;
+	nfs4_stateid freeme = {0};
 	int ret = 0;
 
 	fmode &= (FMODE_READ|FMODE_WRITE);
@@ -1530,7 +1543,8 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
 		goto no_delegation_unlock;
 
 	nfs_mark_delegation_referenced(deleg_cur);
-	__update_open_stateid(state, open_stateid, &deleg_cur->stateid, fmode);
+	__update_open_stateid(state, open_stateid, &deleg_cur->stateid,
+			fmode, &freeme);
 	ret = 1;
 no_delegation_unlock:
 	spin_unlock(&deleg_cur->lock);
@@ -1538,11 +1552,14 @@ no_delegation:
 	rcu_read_unlock();
 
 	if (!ret && open_stateid != NULL) {
-		__update_open_stateid(state, open_stateid, NULL, fmode);
+		__update_open_stateid(state, open_stateid, NULL, fmode, &freeme);
 		ret = 1;
 	}
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
-		nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
+		nfs4_schedule_state_manager(clp);
+	if (freeme.type != 0)
+		nfs4_test_and_free_stateid(server, &freeme,
+				state->owner->so_cred);
 
 	return ret;
 }
-- 
2.7.4

