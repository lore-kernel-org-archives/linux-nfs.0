Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38746 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727604AbeIEWj2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 18:39:28 -0400
Received: by mail-io0-f195.google.com with SMTP id y3-v6so6723262ioc.5
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 11:08:10 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFS: Don't open code clearing of delegation state
Date: Wed,  5 Sep 2018 14:07:15 -0400
Message-Id: <20180905180715.99485-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905180715.99485-3-trond.myklebust@hammerspace.com>
References: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
 <20180905180715.99485-2-trond.myklebust@hammerspace.com>
 <20180905180715.99485-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a helper for the case when the nfs4 open state has been set to use
a delegation stateid, and we want to revert to using the open stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e4456ac9556..8220a168282e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1637,6 +1637,14 @@ static void nfs_state_set_delegation(struct nfs4_state *state,
 	write_sequnlock(&state->seqlock);
 }
 
+static void nfs_state_clear_delegation(struct nfs4_state *state)
+{
+	write_seqlock(&state->seqlock);
+	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
+	clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	write_sequnlock(&state->seqlock);
+}
+
 static int update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *open_stateid,
 		const nfs4_stateid *delegation,
@@ -2145,10 +2153,7 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx,
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
-	write_seqlock(&state->seqlock);
-	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
-	write_sequnlock(&state->seqlock);
-	clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	nfs_state_clear_delegation(state);
 	switch (type & (FMODE_READ|FMODE_WRITE)) {
 	case FMODE_READ|FMODE_WRITE:
 	case FMODE_WRITE:
@@ -2601,10 +2606,7 @@ static void nfs_finish_clear_delegation_stateid(struct nfs4_state *state,
 		const nfs4_stateid *stateid)
 {
 	nfs_remove_bad_delegation(state->inode, stateid);
-	write_seqlock(&state->seqlock);
-	nfs4_stateid_copy(&state->stateid, &state->open_stateid);
-	write_sequnlock(&state->seqlock);
-	clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	nfs_state_clear_delegation(state);
 }
 
 static void nfs40_clear_delegation_stateid(struct nfs4_state *state)
@@ -2672,13 +2674,14 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
 	if (delegation == NULL) {
 		rcu_read_unlock();
+		nfs_state_clear_delegation(state);
 		return;
 	}
 
 	nfs4_stateid_copy(&stateid, &delegation->stateid);
 	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags)) {
 		rcu_read_unlock();
-		nfs_finish_clear_delegation_stateid(state, &stateid);
+		nfs_state_clear_delegation(state);
 		return;
 	}
 
-- 
2.17.1
