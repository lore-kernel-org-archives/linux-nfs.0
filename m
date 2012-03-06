Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030791Ab2CFOqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 09:46:55 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        stable@vger.kernel.org
Subject: [PATCH 3/3] NFSv4.1 do not clear NFS_DELEAGED_STATE until stateid is tested
Date: Tue,  6 Mar 2012 09:46:45 -0500
Message-Id: <1331045205-3031-4-git-send-email-andros@netapp.com>
In-Reply-To: <1331045205-3031-1-git-send-email-andros@netapp.com>
References: <1331045205-3031-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs41_open_expired() will test the delegation stateid based on
NFS_DELEGATED_STATE being set. If the stateid is bad, nfs4_open_recover
will clear the NFS_DELEGATED_STATE bit recovering the delegation.

Signed-off-by: Andy Adamson <andros@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4state.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7bd9822..44fcd60 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -696,7 +696,10 @@ static void __nfs4_close(struct nfs4_state *state,
 			call_close |= test_bit(NFS_O_RDWR_STATE, &state->flags);
 		}
 		if (newstate == 0)
+{
+printk("%s CLEAR NFS_DELEGATED_STATE state %p\n", __func__, state);
 			clear_bit(NFS_DELEGATED_STATE, &state->flags);
+}
 	}
 	nfs4_state_set_mode_locked(state, newstate);
 	spin_unlock(&owner->so_lock);
@@ -1097,7 +1100,7 @@ void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4
 {
 	struct nfs_client *clp = server->nfs_client;
 
-	if (test_and_clear_bit(NFS_DELEGATED_STATE, &state->flags))
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
 		nfs_async_inode_return_delegation(state->inode, &state->stateid);
 	nfs4_state_mark_reclaim_nograce(clp, state);
 	nfs4_schedule_state_manager(clp);
-- 
1.7.6.4

