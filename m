From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 44/85] nfs41: kick start nfs41 session recovery when handling errors
Date: Mon, 10 Nov 2008 22:25:56 +0200
Message-ID: <1226348756-8694-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48847 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950AbYKJU0F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:26:05 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 917d630..a4f5b15 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3256,6 +3256,25 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
 			task->tk_status = 0;
 			return -EAGAIN;
+#if defined(CONFIG_NFS_V4_1)
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_BACK_CHAN_BUSY:
+		case -NFS4ERR_SEQ_MISORDERED:
+		case -NFS4ERR_SEQUENCE_POS:
+		case -NFS4ERR_REQ_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
+		case -NFS4ERR_RETRY_UNCACHED_REP:
+		case -NFS4ERR_TOO_MANY_OPS:
+		case -NFS4ERR_OP_NOT_IN_SESSION:
+			dprintk("%s ERROR %d, Reset session\n", __func__,
+				task->tk_status);
+			nfs41_set_session_reset(clp->cl_session);
+			task->tk_status = 0;
+			return -EAGAIN;
+#endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
@@ -3331,7 +3350,30 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			ret = nfs4_wait_clnt_recover(server->client, clp);
 			if (ret == 0)
 				exception->retry = 1;
+#if !defined(CONFIG_NFS_V4_1)
 			break;
+#else /* !defined(CONFIG_NFS_V4_1) */
+			if (!server->nfs_client->cl_minorversion)
+				break;
+			/* FALLTHROUGH */
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_BACK_CHAN_BUSY:
+		case -NFS4ERR_SEQ_MISORDERED:
+		case -NFS4ERR_SEQUENCE_POS:
+		case -NFS4ERR_REQ_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
+		case -NFS4ERR_RETRY_UNCACHED_REP:
+		case -NFS4ERR_TOO_MANY_OPS:
+		case -NFS4ERR_OP_NOT_IN_SESSION:
+			dprintk("%s ERROR: %d Reset session\n", __func__,
+				errorcode);
+			nfs41_set_session_reset(clp->cl_session);
+			exception->retry = 1;
+			/* FALLTHROUGH */
+#endif /* !defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
@@ -4735,8 +4777,37 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_server *server = (struct nfs_server *)data;
+	struct nfs_client *clp = server->nfs_client;
 
 	nfs4_sequence_done(server, task->tk_msg.rpc_resp, task->tk_status);
+
+	if (task->tk_status < 0) {
+		switch (task->tk_status) {
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_EXPIRED:
+		case -NFS4ERR_CB_PATH_DOWN:
+			nfs4_schedule_state_recovery(clp);
+		case -NFS4ERR_BADSLOT:
+		case -NFS4ERR_BADSESSION:
+		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		case -NFS4ERR_BACK_CHAN_BUSY:
+		case -NFS4ERR_SEQ_MISORDERED:
+		case -NFS4ERR_SEQUENCE_POS:
+		case -NFS4ERR_REQ_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG:
+		case -NFS4ERR_REP_TOO_BIG_TO_CACHE:
+		case -NFS4ERR_RETRY_UNCACHED_REP:
+		case -NFS4ERR_TOO_MANY_OPS:
+		case -NFS4ERR_OP_NOT_IN_SESSION:
+			dprintk("%s ERROR %d Reset session\n", __func__,
+				task->tk_status);
+
+			if (nfs4_async_handle_error(task, server) == -EAGAIN) {
+				nfs4_restart_rpc(task, server);
+				return;
+			}
+		}
+	}
 	nfs4_sequence_free_slot(server, task->tk_msg.rpc_resp);
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
-- 
1.6.0.2

