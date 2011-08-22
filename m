Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530Ab1HVVMs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Aug 2011 17:12:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/4] NFSv4: renewd needs to be able to handle the NFS4ERR_CB_PATH_DOWN error
Date: Mon, 22 Aug 2011 17:12:40 -0400
Message-Id: <1314047560-24534-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1314047560-24534-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1314047560-24534-1-git-send-email-Trond.Myklebust@netapp.com>
 <1314047560-24534-2-git-send-email-Trond.Myklebust@netapp.com>
 <1314047560-24534-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The NFSv4 spec does not specify that the server must repeat that error,
so in order to avoid having the delegations revoked, we should handle
it immediately.

Also note that NFS4ERR_CB_PATH_DOWN does in fact renew the lease...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    8 ++++++--
 fs/nfs/nfs4state.c |    6 ++++++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e1b6607..3e93e9a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -350,6 +350,7 @@ extern void nfs4_close_sync(struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
+extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_recall_slot(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e89940a..4700fae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3374,9 +3374,13 @@ static void nfs4_renew_done(struct rpc_task *task, void *calldata)
 
 	if (task->tk_status < 0) {
 		/* Unless we're shutting down, schedule state recovery! */
-		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) != 0)
+		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) == 0)
+			return;
+		if (task->tk_status != NFS4ERR_CB_PATH_DOWN) {
 			nfs4_schedule_lease_recovery(clp);
-		return;
+			return;
+		}
+		nfs4_schedule_path_down_recovery(clp);
 	}
 	do_renew_lease(clp, timestamp);
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 72ab97e..39914be 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1038,6 +1038,12 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 	nfs4_schedule_state_manager(clp);
 }
 
+void nfs4_schedule_path_down_recovery(struct nfs_client *clp)
+{
+	nfs_handle_cb_pathdown(clp);
+	nfs4_schedule_state_manager(clp);
+}
+
 static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
 
-- 
1.7.6

