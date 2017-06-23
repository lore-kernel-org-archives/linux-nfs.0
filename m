Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:10992 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750932AbdFWO1E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 10:27:04 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] PNFS for stateid errors retry against MDS first
Date: Fri, 23 Jun 2017 10:26:59 -0400
Message-ID: <20170623142659.81480-2-kolga@netapp.com>
In-Reply-To: <20170623142659.81480-1-kolga@netapp.com>
References: <20170623142659.81480-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upon receiving a stateid error such as BAD_STATEID, the client
should retry the operation against the MDS before deciding to
do stateid recovery.

Previously, the code would initiate state recovery and it could
lead to a race in a state manager that could chose an incorrect
recovery method which would lead to the EIO failure for the
application.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/filelayout/filelayout.c         | 28 ----------------------------
 fs/nfs/flexfilelayout/flexfilelayout.c | 33 ---------------------------------
 2 files changed, 61 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index ce82da1..61dcb4b 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -126,32 +126,13 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
-	struct nfs_server *mds_server = NFS_SERVER(inode);
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
-	struct nfs_client *mds_client = mds_server->nfs_client;
 	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	if (task->tk_status >= 0)
 		return 0;
 
 	switch (task->tk_status) {
-	/* MDS state errors */
-	case -NFS4ERR_DELEG_REVOKED:
-	case -NFS4ERR_ADMIN_REVOKED:
-	case -NFS4ERR_BAD_STATEID:
-	case -NFS4ERR_OPENMODE:
-		if (state == NULL)
-			break;
-		if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
-			goto out_bad_stateid;
-		goto wait_on_recovery;
-	case -NFS4ERR_EXPIRED:
-		if (state != NULL) {
-			if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
-				goto out_bad_stateid;
-		}
-		nfs4_schedule_lease_recovery(mds_client);
-		goto wait_on_recovery;
 	/* DS session errors */
 	case -NFS4ERR_BADSESSION:
 	case -NFS4ERR_BADSLOT:
@@ -211,17 +192,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
 	}
-out:
 	task->tk_status = 0;
 	return -EAGAIN;
-out_bad_stateid:
-	task->tk_status = -EIO;
-	return 0;
-wait_on_recovery:
-	rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
-	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
-		rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
-	goto out;
 }
 
 /* NFS_PROTO call done callback routines */
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 23542dc..1f2ac3d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1050,34 +1050,10 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
-	struct nfs_server *mds_server = NFS_SERVER(inode);
-
 	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
-	struct nfs_client *mds_client = mds_server->nfs_client;
 	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	switch (task->tk_status) {
-	/* MDS state errors */
-	case -NFS4ERR_DELEG_REVOKED:
-	case -NFS4ERR_ADMIN_REVOKED:
-	case -NFS4ERR_BAD_STATEID:
-		if (state == NULL)
-			break;
-		nfs_remove_bad_delegation(state->inode, NULL);
-	case -NFS4ERR_OPENMODE:
-		if (state == NULL)
-			break;
-		if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
-			goto out_bad_stateid;
-		goto wait_on_recovery;
-	case -NFS4ERR_EXPIRED:
-		if (state != NULL) {
-			if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
-				goto out_bad_stateid;
-		}
-		nfs4_schedule_lease_recovery(mds_client);
-		goto wait_on_recovery;
-	/* DS session errors */
 	case -NFS4ERR_BADSESSION:
 	case -NFS4ERR_BADSLOT:
 	case -NFS4ERR_BAD_HIGH_SLOT:
@@ -1137,17 +1113,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
 	}
-out:
 	task->tk_status = 0;
 	return -EAGAIN;
-out_bad_stateid:
-	task->tk_status = -EIO;
-	return 0;
-wait_on_recovery:
-	rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
-	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
-		rpc_wake_up_queued_task(&mds_client->cl_rpcwaitq, task);
-	goto out;
 }
 
 /* Retry all errors through either pNFS or MDS except for -EJUKEBOX */
-- 
1.8.3.1

