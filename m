Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:62012 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079AbbGMSCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:02:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 08/10] NFS: Remove nfs41_server_notify_{target|highest}_slotid_update()
Date: Mon, 13 Jul 2015 14:01:31 -0400
Message-ID: <1436810493-22806-9-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All these functions do is call nfs41_ping_server() without adding
anything.  Let's remove them and give nfs41_ping_server() a better name
instead.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_proc.c |  2 +-
 fs/nfs/nfs4_fs.h       |  4 +---
 fs/nfs/nfs4proc.c      |  2 +-
 fs/nfs/nfs4state.c     | 12 +-----------
 4 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 29e3c1b..624bef7 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -554,7 +554,7 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	status = htonl(NFS4_OK);
 
 	nfs41_set_target_slotid(fc_tbl, args->crsa_target_highest_slotid);
-	nfs41_server_notify_target_slotid_update(cps->clp);
+	nfs41_notify_server(cps->clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea3bee9..50cfc4c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -405,9 +405,7 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 int nfs41_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **, struct rpc_cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
-extern void nfs41_server_notify_target_slotid_update(struct nfs_client *clp);
-extern void nfs41_server_notify_highest_slotid_update(struct nfs_client *clp);
-
+extern void nfs41_notify_server(struct nfs_client *);
 #else
 static inline void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b911fb0..b5a4f95 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -583,7 +583,7 @@ out_unlock:
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
 	if (send_new_highest_used_slotid)
-		nfs41_server_notify_highest_slotid_update(session->clp);
+		nfs41_notify_server(session->clp);
 }
 
 int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 605840d..6f51282 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2152,23 +2152,13 @@ void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_session_recovery);
 
-static void nfs41_ping_server(struct nfs_client *clp)
+void nfs41_notify_server(struct nfs_client *clp)
 {
 	/* Use CHECK_LEASE to ping the server with a SEQUENCE */
 	set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	nfs4_schedule_state_manager(clp);
 }
 
-void nfs41_server_notify_target_slotid_update(struct nfs_client *clp)
-{
-	nfs41_ping_server(clp);
-}
-
-void nfs41_server_notify_highest_slotid_update(struct nfs_client *clp)
-{
-	nfs41_ping_server(clp);
-}
-
 static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
-- 
2.4.5

