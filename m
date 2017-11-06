Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v7 09/10] NFSv4: cleanup nfs4_close_done
Date: Mon,  6 Nov 2017 10:27:25 -0500
Message-Id: <20171106152726.13755-10-trond.myklebust@primarydata.com>
In-Reply-To: <20171106152726.13755-9-trond.myklebust@primarydata.com>
References: <20171106152726.13755-1-trond.myklebust@primarydata.com>
 <20171106152726.13755-2-trond.myklebust@primarydata.com>
 <20171106152726.13755-3-trond.myklebust@primarydata.com>
 <20171106152726.13755-4-trond.myklebust@primarydata.com>
 <20171106152726.13755-5-trond.myklebust@primarydata.com>
 <20171106152726.13755-6-trond.myklebust@primarydata.com>
 <20171106152726.13755-7-trond.myklebust@primarydata.com>
 <20171106152726.13755-8-trond.myklebust@primarydata.com>
 <20171106152726.13755-9-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 35 ++++++++++++++++-------------------
 1 file changed, 16 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f11230db8d25..ec62d8ad64ed 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3167,11 +3167,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
@@ -3181,9 +3178,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_WRONG_CRED:
 			calldata->arg.lr_args = NULL;
 			calldata->res.lr_res = NULL;
-			calldata->res.lr_ret = 0;
-			rpc_restart_call_prepare(task);
-			return;
+			goto lr_restart;
 		}
 	}
 
@@ -3199,19 +3194,15 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
@@ -3223,17 +3214,23 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
