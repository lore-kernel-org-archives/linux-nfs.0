Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2867 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884Ab1CJAT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 19:19:29 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] NFSv4: nfs4_state_mark_reclaim_nograce() should be static
Date: Wed,  9 Mar 2011 19:19:19 -0500
Message-Id: <1299716359-30977-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1299716359-30977-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1299716359-30977-1-git-send-email-Trond.Myklebust@netapp.com>
 <1299716359-30977-2-git-send-email-Trond.Myklebust@netapp.com>
 <1299716359-30977-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There are no more external users of nfs4_state_mark_reclaim_nograce() or
nfs4_state_mark_reclaim_reboot(), so mark them as static.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    2 --
 fs/nfs/nfs4state.c |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 42884b3..560ebde 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -315,8 +315,6 @@ extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
-extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
-extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_recall_slot(struct nfs_client *clp);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 47c8dcd..0592288 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1018,7 +1018,7 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 	nfs4_schedule_state_manager(clp);
 }
 
-int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
+static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
 
 	set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
@@ -1032,7 +1032,7 @@ int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *st
 	return 1;
 }
 
-int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
+static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
 {
 	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
-- 
1.7.4

