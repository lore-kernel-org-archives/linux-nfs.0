Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 09/10] NFSv4: cleanup nfs4_close_done
Date: Fri,  3 Nov 2017 07:35:38 -0400
Message-Id: <20171103113539.5551-10-trond.myklebust@primarydata.com>
In-Reply-To: <20171103113539.5551-9-trond.myklebust@primarydata.com>
References: <20171103113539.5551-1-trond.myklebust@primarydata.com>
 <20171103113539.5551-2-trond.myklebust@primarydata.com>
 <20171103113539.5551-3-trond.myklebust@primarydata.com>
 <20171103113539.5551-4-trond.myklebust@primarydata.com>
 <20171103113539.5551-5-trond.myklebust@primarydata.com>
 <20171103113539.5551-6-trond.myklebust@primarydata.com>
 <20171103113539.5551-7-trond.myklebust@primarydata.com>
 <20171103113539.5551-8-trond.myklebust@primarydata.com>
 <20171103113539.5551-9-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 79306a903453..291fe9ca531e 100644
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
@@ -3223,10 +3214,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
@@ -3234,6 +3223,13 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
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
