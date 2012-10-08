Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18330 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409Ab2JHRwQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 13:52:16 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4.1: pNFS has no business touching the slot table wait queue...
Date: Mon,  8 Oct 2012 13:50:30 -0400
Message-Id: <1349718630-26008-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1349718630-26008-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1349718630-26008-1-git-send-email-Trond.Myklebust@netapp.com>
 <1349718630-26008-2-git-send-email-Trond.Myklebust@netapp.com>
 <1349718630-26008-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Aside from it being a layering violation, there is no point in doing so:
- If slots are available, then the waitqueue will be empty.
- If no slots are available, then the wake up just causes waitqueue churn.
- If the slot table is being drained, then the state recovery machinery
  will manage the waitqueue using the calls to nfs4_begin/end_drain_session.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 52d8472..368f11f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -131,7 +131,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	struct nfs_server *mds_server = NFS_SERVER(inode);
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs_client *mds_client = mds_server->nfs_client;
-	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	if (task->tk_status >= 0)
 		return 0;
@@ -191,7 +190,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		 * layout is destroyed and a new valid layout is obtained.
 		 */
 		pnfs_destroy_layout(NFS_I(inode));
-		rpc_wake_up(&tbl->slot_tbl_waitq);
 		goto reset;
 	/* RPC connection errors */
 	case -ECONNREFUSED:
@@ -206,7 +204,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		nfs4_mark_deviceid_unavailable(devid);
 		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
 		_pnfs_return_layout(inode);
-		rpc_wake_up(&tbl->slot_tbl_waitq);
 		nfs4_ds_disconnect(clp);
 		/* fall through */
 	default:
-- 
1.7.11.4

