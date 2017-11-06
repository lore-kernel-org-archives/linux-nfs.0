Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v8 09/11] NFSv4: cleanup nfs4_close_done
Date: Mon,  6 Nov 2017 15:28:09 -0500
Message-Id: <20171106202811.70202-10-trond.myklebust@primarydata.com>
In-Reply-To: <20171106202811.70202-9-trond.myklebust@primarydata.com>
References: <20171106202811.70202-1-trond.myklebust@primarydata.com>
 <20171106202811.70202-2-trond.myklebust@primarydata.com>
 <20171106202811.70202-3-trond.myklebust@primarydata.com>
 <20171106202811.70202-4-trond.myklebust@primarydata.com>
 <20171106202811.70202-5-trond.myklebust@primarydata.com>
 <20171106202811.70202-6-trond.myklebust@primarydata.com>
 <20171106202811.70202-7-trond.myklebust@primarydata.com>
 <20171106202811.70202-8-trond.myklebust@primarydata.com>
 <20171106202811.70202-9-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 35 ++++++++++++++++-------------------
 1 file changed, 16 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0d6941d548f8..1f16cd17b437 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3168,11 +3168,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			break;
 		case -NFS4ERR_OLD_STATEID:
 			if (nfs4_refresh_layout_stateid(&calldata->arg.lr_args->stateid,
-						calldata->inode)) {
-				calldata->res.lr_ret = 0;
-				rpc_restart_call_prepare(task);
-				return;
-			}
+						calldata->inode))
+				goto lr_restart;
 			/* Fallthrough */
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_DELEG_REVOKED:
@@ -3182,9 +3179,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_WRONG_CRED:
 			calldata->arg.lr_args = NULL;
 			calldata->res.lr_res = NULL;
-			calldata->res.lr_ret = 0;
-			rpc_restart_call_prepare(task);
-			return;
+			goto lr_restart;
 		}
 	}
 
@@ -3200,19 +3195,15 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->arg.bitmask != NULL) {
 				calldata->arg.bitmask = NULL;
 				calldata->res.fattr = NULL;
-				task->tk_status = 0;
-				rpc_restart_call_prepare(task);
-				goto out_release;
+				goto out_restart;
 
 			}
 			break;
 		case -NFS4ERR_OLD_STATEID:
 			/* Did we race with OPEN? */
 			if (nfs4_refresh_open_stateid(&calldata->arg.stateid,
-						state)) {
-				task->tk_status = 0;
-				rpc_restart_call_prepare(task);
-			}
+						state))
+				goto out_restart;
 			goto out_release;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
@@ -3224,17 +3215,23 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_BAD_STATEID:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN) {
-				rpc_restart_call_prepare(task);
-				goto out_release;
-			}
+			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
+				goto out_restart;
 	}
 	nfs_clear_open_stateid(state, &calldata->arg.stateid,
 			res_stateid, calldata->arg.fmode);
 out_release:
+	task->tk_status = 0;
 	nfs_release_seqid(calldata->arg.seqid);
 	nfs_refresh_inode(calldata->inode, &calldata->fattr);
 	dprintk("%s: done, ret = %d!\n", __func__, task->tk_status);
+	return;
+lr_restart:
+	calldata->res.lr_ret = 0;
+out_restart:
+	task->tk_status = 0;
+	rpc_restart_call_prepare(task);
+	goto out_release;
 }
 
 static void nfs4_close_prepare(struct rpc_task *task, void *data)
-- 
2.13.6
