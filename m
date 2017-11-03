Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 10/10] NFSv4: Clean up nfs4_delegreturn_done
Date: Fri,  3 Nov 2017 07:35:39 -0400
Message-Id: <20171103113539.5551-11-trond.myklebust@primarydata.com>
In-Reply-To: <20171103113539.5551-10-trond.myklebust@primarydata.com>
References: <20171103113539.5551-1-trond.myklebust@primarydata.com>
 <20171103113539.5551-2-trond.myklebust@primarydata.com>
 <20171103113539.5551-3-trond.myklebust@primarydata.com>
 <20171103113539.5551-4-trond.myklebust@primarydata.com>
 <20171103113539.5551-5-trond.myklebust@primarydata.com>
 <20171103113539.5551-6-trond.myklebust@primarydata.com>
 <20171103113539.5551-7-trond.myklebust@primarydata.com>
 <20171103113539.5551-8-trond.myklebust@primarydata.com>
 <20171103113539.5551-9-trond.myklebust@primarydata.com>
 <20171103113539.5551-10-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 291fe9ca531e..a6b47feee552 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5792,11 +5792,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 			break;
 		case -NFS4ERR_OLD_STATEID:
 			if (nfs4_refresh_layout_stateid(&data->args.lr_args->stateid,
-						data->inode)) {
-				data->res.lr_ret = 0;
-				rpc_restart_call_prepare(task);
-				return;
-			}
+						data->inode))
+				goto lr_restart;
 			/* Fallthrough */
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_DELEG_REVOKED:
@@ -5806,9 +5803,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		case -NFS4ERR_WRONG_CRED:
 			data->args.lr_args = NULL;
 			data->res.lr_res = NULL;
-			data->res.lr_ret = 0;
-			rpc_restart_call_prepare(task);
-			return;
+			goto lr_restart;
 		}
 	}
 
@@ -5828,29 +5823,30 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		task->tk_status = 0;
 		break;
 	case -NFS4ERR_OLD_STATEID:
-		if (nfs4_refresh_delegation_stateid(&data->stateid, data->inode)) {
-			task->tk_status = 0;
-			rpc_restart_call_prepare(task);
-			return;
-		}
+		if (nfs4_refresh_delegation_stateid(&data->stateid, data->inode))
+			goto out_restart;
 		task->tk_status = 0;
 		break;
 	case -NFS4ERR_ACCESS:
 		if (data->args.bitmask) {
 			data->args.bitmask = NULL;
 			data->res.fattr = NULL;
-			task->tk_status = 0;
-			rpc_restart_call_prepare(task);
-			return;
+			goto out_restart;
 		}
+		/* Fallthrough */
 	default:
 		if (nfs4_async_handle_error(task, data->res.server,
 					    NULL, NULL) == -EAGAIN) {
-			rpc_restart_call_prepare(task);
-			return;
+			goto out_restart;
 		}
 	}
 	data->rpc_status = task->tk_status;
+	return;
+lr_restart:
+	data->res.lr_ret = 0;
+out_restart:
+	task->tk_status = 0;
+	rpc_restart_call_prepare(task);
 }
 
 static void nfs4_delegreturn_release(void *calldata)
-- 
2.13.6
