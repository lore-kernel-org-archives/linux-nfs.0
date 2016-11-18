Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46484 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751716AbcKRKDY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 05:03:24 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Keep a reference on lock states while checking
Date: Fri, 18 Nov 2016 05:03:22 -0500
Message-Id: <6a50c9ed9077e43de5da454a2413769a0b383d58.1479427989.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While walking the list of lock_states, keep a reference on each
nfs4_lock_state to be checked, otherwise the lock state could be removed
while the check performs TEST_STATEID and possible FREE_STATEID.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7897826d7c51..57d102d0f075 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2564,15 +2564,23 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 static int nfs41_check_expired_locks(struct nfs4_state *state)
 {
 	int status, ret = NFS_OK;
-	struct nfs4_lock_state *lsp;
+	struct nfs4_lock_state *lsp, *prev = NULL;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
 	if (!test_bit(LK_STATE_IN_USE, &state->flags))
 		goto out;
+
+	spin_lock(&state->state_lock);
 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
 			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
 
+			atomic_inc(&lsp->ls_count);
+			spin_unlock(&state->state_lock);
+
+			nfs4_put_lock_state(prev);
+			prev = lsp;
+
 			status = nfs41_test_and_free_expired_stateid(server,
 					&lsp->ls_stateid,
 					cred);
@@ -2587,8 +2595,11 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 				ret = status;
 				break;
 			}
+			spin_lock(&state->state_lock);
 		}
-	};
+	}
+	spin_unlock(&state->state_lock);
+	nfs4_put_lock_state(prev);
 out:
 	return ret;
 }
-- 
2.5.5

