Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54704 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936079AbdJQOqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 10:46:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4: Move __update_open_stateid() into update_open_stateid()
Date: Tue, 17 Oct 2017 10:46:13 -0400
Message-Id: <8b671c2132effa3b8874c4b2eaf86b991d1ddf64.1508248965.git.bcodding@redhat.com>
In-Reply-To: <cover.1508248965.git.bcodding@redhat.com>
References: <cover.1508248965.git.bcodding@redhat.com>
In-Reply-To: <cover.1508248965.git.bcodding@redhat.com>
References: <cover.1508248965.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The two calls to __update_open_stateid() can be removed so that we have
only a single section protected by the so_lock and state seqlock. This
allows us to open-code __update_open_stateid().  This is done so that in a
laater patch we can indicated that the state's stateid was not updated
because it had previously been updated with a more recent sequence id.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 71 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 34 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d90132642340..7e0ae74ceb4f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1440,29 +1440,6 @@ static void nfs_set_open_stateid_locked(struct nfs4_state *state,
 	nfs4_stateid_copy(&state->open_stateid, stateid);
 }
 
-static void __update_open_stateid(struct nfs4_state *state,
-		const nfs4_stateid *open_stateid,
-		const nfs4_stateid *deleg_stateid,
-		fmode_t fmode,
-		nfs4_stateid *freeme)
-{
-	/*
-	 * Protect the call to nfs4_state_set_mode_locked and
-	 * serialise the stateid update
-	 */
-	spin_lock(&state->owner->so_lock);
-	write_seqlock(&state->seqlock);
-	if (deleg_stateid != NULL) {
-		nfs4_stateid_copy(&state->stateid, deleg_stateid);
-		set_bit(NFS_DELEGATED_STATE, &state->flags);
-	}
-	if (open_stateid != NULL)
-		nfs_set_open_stateid_locked(state, open_stateid, fmode, freeme);
-	write_sequnlock(&state->seqlock);
-	update_open_stateflags(state, fmode);
-	spin_unlock(&state->owner->so_lock);
-}
-
 static int update_open_stateid(struct nfs4_state *state,
 		const nfs4_stateid *open_stateid,
 		const nfs4_stateid *delegation,
@@ -1485,27 +1462,47 @@ static int update_open_stateid(struct nfs4_state *state,
 	spin_lock(&deleg_cur->lock);
 	if (rcu_dereference(nfsi->delegation) != deleg_cur ||
 	   test_bit(NFS_DELEGATION_RETURNING, &deleg_cur->flags) ||
-	    (deleg_cur->type & fmode) != fmode)
-		goto no_delegation_unlock;
+	    (deleg_cur->type & fmode) != fmode) {
+		spin_unlock(&deleg_cur->lock);
+		deleg_cur = NULL;
+		goto no_delegation;
+	}
 
 	if (delegation == NULL)
 		delegation = &deleg_cur->stateid;
-	else if (!nfs4_stateid_match(&deleg_cur->stateid, delegation))
-		goto no_delegation_unlock;
-
-	nfs_mark_delegation_referenced(deleg_cur);
-	__update_open_stateid(state, open_stateid, &deleg_cur->stateid,
-			fmode, &freeme);
-	ret = 1;
-no_delegation_unlock:
-	spin_unlock(&deleg_cur->lock);
+	else if (!nfs4_stateid_match(&deleg_cur->stateid, delegation)) {
+		spin_unlock(&deleg_cur->lock);
+		deleg_cur = NULL;
+	}
+
 no_delegation:
-	rcu_read_unlock();
+	/*
+	 * Protect the call to nfs4_state_set_mode_locked and
+	 * serialise the stateid update
+	 */
+	spin_lock(&state->owner->so_lock);
+	write_seqlock(&state->seqlock);
+	if (deleg_cur) {
+		nfs_mark_delegation_referenced(deleg_cur);
+		nfs4_stateid_copy(&state->stateid, &deleg_cur->stateid);
+		set_bit(NFS_DELEGATED_STATE, &state->flags);
+		ret = 1;
+	}
 
-	if (!ret && open_stateid != NULL) {
-		__update_open_stateid(state, open_stateid, NULL, fmode, &freeme);
+	if (open_stateid) {
+		nfs_set_open_stateid_locked(state, open_stateid, fmode, &freeme);
 		ret = 1;
 	}
+
+	write_sequnlock(&state->seqlock);
+	update_open_stateflags(state, fmode);
+	spin_unlock(&state->owner->so_lock);
+
+	if (deleg_cur)
+		spin_unlock(&deleg_cur->lock);
+
+	rcu_read_unlock();
+
 	if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
 		nfs4_schedule_state_manager(clp);
 	if (freeme.type != 0)
-- 
2.9.3

