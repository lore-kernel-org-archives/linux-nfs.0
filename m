Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751532AbcKNQvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 11:51:46 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Don't allow a lock_state to be freed while checking
Date: Mon, 14 Nov 2016 11:50:44 -0500
Message-Id: <0e6e9dac991cd93e2ae3e6a4b4b41bd974a040cb.1479142099.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While walking the list of lock_states, keep the current nfs4_lock_state
referenced so that it isn't freed while checking.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7897826d7c51..9a1cb9e8c4fc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2564,12 +2564,15 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
 	int status, ret = NFS_OK;
-	struct nfs4_lock_state *lsp;
+	struct nfs4_lock_state *lsp, *tmp;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
 	if (!test_bit(LK_STATE_IN_USE, &state->flags))
 		goto out;
-	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
+	spin_lock(&state->state_lock);
+	list_for_each_entry_safe(lsp, tmp, &state->lock_states, ls_locks) {
+		atomic_inc(&lsp->ls_count);
+		spin_unlock(&state->state_lock);
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
 			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
@@ -2588,7 +2591,10 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 				break;
 			}
 		}
-	};
+		nfs4_put_lock_state(lsp);
+		spin_lock(&state->state_lock);
+	}
+	spin_unlock(&state->state_lock);
 out:
 	return ret;
 }
-- 
2.5.5

