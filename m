Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38952 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754407Ab1EET13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2011 15:27:29 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH V2 1/1] NFSv41: Resend on NFS4ERR_RETRY_UNCACHED_REP
Date: Tue,  3 May 2011 13:43:03 -0400
Message-Id: <1304444583-32252-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Free the slot and resend the RPC with new session <slot#,seq#>.

For nfs4_async_handle_error, return -EAGAIN and set the task->tk_status to 0
to restart the async rpc in the rpc_restart_call_prepare state which resets
the slot.

For nfs4_handle_exception, retrying a call that uses nfs4_call_sync will
reset the slot via nfs41_call_sync_prepare.

For open/close/lock/locku/delegreturn/layoutcommit/unlink/rename/write
cachethis is true, so these operations will not trigger an
NFS4ERR_RETRY_UNCACHED_REP.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    2 ++
 fs/nfs/nfs4proc.c       |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 6f8192f..7841ea6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -117,6 +117,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -EKEYEXPIRED:
 		rpc_delay(task, FILELAYOUT_POLL_RETRY_MAX);
 		break;
+	case -NFS4ERR_RETRY_UNCACHED_REP:
+		break;
 	default:
 		dprintk("%s DS error. Retry through MDS %d\n", __func__,
 			task->tk_status);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b8e1ac6..f8a8efb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -300,6 +300,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
+		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
 			exception->retry = 1;
 			break;
@@ -3677,6 +3678,7 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
+		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
 			task->tk_status = 0;
 			return -EAGAIN;
@@ -4847,6 +4849,8 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 		dprintk("%s Retry: tk_status %d\n", __func__, task->tk_status);
 		rpc_delay(task, NFS4_POLL_RETRY_MIN);
 		task->tk_status = 0;
+		/* fall through */
+	case -NFS4ERR_RETRY_UNCACHED_REP:
 		nfs_restart_rpc(task, data->clp);
 		return;
 	}
@@ -5491,6 +5495,8 @@ static int nfs41_reclaim_complete_handle_errors(struct rpc_task *task, struct nf
 		break;
 	case -NFS4ERR_DELAY:
 		rpc_delay(task, NFS4_POLL_RETRY_MAX);
+		/* fall through */
+	case -NFS4ERR_RETRY_UNCACHED_REP:
 		return -EAGAIN;
 	default:
 		nfs4_schedule_lease_recovery(clp);
-- 
1.7.3.1

