Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix a regression in DELEGRETURN
Date: Thu, 10 Nov 2016 16:06:28 -0500
Message-Id: <1478811988-16627-1-git-send-email-trond.myklebust@primarydata.com>
List-ID: <linux-nfs.vger.kernel.org>

We don't want to call nfs4_free_revoked_stateid() in the case where
the delegreturn was successful.

Reported-by: Benjamin Coddington <bcodding@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7897826d7c51..6a1d650e0419 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5569,6 +5569,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case 0:
 		renew_lease(data->res.server, data->timestamp);
+		break;
 	case -NFS4ERR_ADMIN_REVOKED:
 	case -NFS4ERR_DELEG_REVOKED:
 	case -NFS4ERR_EXPIRED:
@@ -5579,8 +5580,6 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_OLD_STATEID:
 	case -NFS4ERR_STALE_STATEID:
 		task->tk_status = 0;
-		if (data->roc)
-			pnfs_roc_set_barrier(data->inode, data->roc_barrier);
 		break;
 	default:
 		if (nfs4_async_handle_error(task, data->res.server,
@@ -5590,6 +5589,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		}
 	}
 	data->rpc_status = task->tk_status;
+	if (data->roc && data->rpc_status == 0)
+		pnfs_roc_set_barrier(data->inode, data->roc_barrier);
 }
 
 static void nfs4_delegreturn_release(void *calldata)
-- 
2.7.4
