Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24513 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755012Ab2D0Vpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:35 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 09/13] NFSv4.1 wake up all tasks on un-connected DS slot table waitq
Date: Fri, 27 Apr 2012 17:53:49 -0400
Message-Id: <1335563633-7191-10-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The DS has a connection error (invalid deviceid). Drain the fore channel
slot table waitq.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 1b9bedb..a63062d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -133,6 +133,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	struct nfs_server *mds_server = NFS_SERVER(inode);
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs_client *mds_client = mds_server->nfs_client;
+	struct nfs4_slot_table *tbl = &clp->cl_session->fc_slot_table;
 
 	if (task->tk_status >= 0)
 		return 0;
@@ -186,6 +187,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		filelayout_mark_devid_invalid(devid);
+		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
-- 
1.7.6.4

