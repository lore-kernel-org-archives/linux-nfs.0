Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v7 10/10] NFSv4: Clean up nfs4_delegreturn_done
Date: Mon,  6 Nov 2017 10:27:26 -0500
Message-Id: <20171106152726.13755-11-trond.myklebust@primarydata.com>
In-Reply-To: <20171106152726.13755-10-trond.myklebust@primarydata.com>
References: <20171106152726.13755-1-trond.myklebust@primarydata.com>
 <20171106152726.13755-2-trond.myklebust@primarydata.com>
 <20171106152726.13755-3-trond.myklebust@primarydata.com>
 <20171106152726.13755-4-trond.myklebust@primarydata.com>
 <20171106152726.13755-5-trond.myklebust@primarydata.com>
 <20171106152726.13755-6-trond.myklebust@primarydata.com>
 <20171106152726.13755-7-trond.myklebust@primarydata.com>
 <20171106152726.13755-8-trond.myklebust@primarydata.com>
 <20171106152726.13755-9-trond.myklebust@primarydata.com>
 <20171106152726.13755-10-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ec62d8ad64ed..cbcb27b724bf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5793,11 +5793,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
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
@@ -5807,9 +5804,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		case -NFS4ERR_WRONG_CRED:
 			data->args.lr_args = NULL;
 			data->res.lr_res = NULL;
-			data->res.lr_ret = 0;
-			rpc_restart_call_prepare(task);
-			return;
+			goto lr_restart;
 		}
 	}
 
@@ -5829,29 +5824,30 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
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
