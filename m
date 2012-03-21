Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36490 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198Ab2CUTqy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:54 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 05/12] NFSv4.1: mark deviceid invalid on filelayout DS connection errors
Date: Wed, 21 Mar 2012 15:46:17 -0400
Message-Id: <1332359184-1887-6-git-send-email-andros@netapp.com>
In-Reply-To: <1332359184-1887-1-git-send-email-andros@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This prevents the use of any layout for i/o that references the deviceid.
I/O is redirected through the MDS.

Redirect the unhandled failed I/O to the MDS without marking either the
layout or the deviceid invalid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   65 ++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4filelayout.h |    6 ++++
 2 files changed, 54 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 3802937..1f1be26 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -116,7 +116,7 @@ void filelayout_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
-					 int *reset)
+					 unsigned long *reset)
 {
 	struct nfs_server *mds_server = NFS_SERVER(state->inode);
 	struct nfs_client *mds_client = mds_server->nfs_client;
@@ -158,10 +158,23 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		break;
 	case -NFS4ERR_RETRY_UNCACHED_REP:
 		break;
+	/* RPC connection errors */
+	case -ECONNREFUSED:
+	case -EHOSTDOWN:
+	case -EHOSTUNREACH:
+	case -ENETUNREACH:
+	case -EIO:
+	case -ETIMEDOUT:
+	case -EPIPE:
+		dprintk("%s DS connection error. Retry through MDS %d\n",
+			__func__, task->tk_status);
+		set_bit(NFS4_RESET_DEVICEID, reset);
+		set_bit(NFS4_RESET_TO_MDS, reset);
+		break;
 	default:
-		dprintk("%s DS error. Retry through MDS %d\n", __func__,
-			task->tk_status);
-		*reset = 1;
+		dprintk("%s Unhandled DS error. Retry through MDS %d\n",
+			__func__, task->tk_status);
+		set_bit(NFS4_RESET_TO_MDS, reset);
 		break;
 	}
 out:
@@ -179,16 +192,22 @@ wait_on_recovery:
 static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
-	int reset = 0;
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	unsigned long reset = 0;
 
 	dprintk("%s DS read\n", __func__);
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
 					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
+
+		dprintk("%s reset 0x%lx ds_clp %p session %p\n", __func__,
+			reset, data->ds_clp, data->ds_clp->cl_session);
+
+		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
 			filelayout_reset_read(task, data);
+			if (test_bit(NFS4_RESET_DEVICEID, &reset))
+				filelayout_mark_devid_invalid(devid);
+		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -260,14 +279,20 @@ static void filelayout_read_release(void *data)
 static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_write_data *data)
 {
-	int reset = 0;
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	unsigned long reset = 0;
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
 					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
+
+		dprintk("%s reset 0x%lx ds_clp %p session %p\n", __func__,
+			reset, data->ds_clp, data->ds_clp->cl_session);
+
+		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
 			filelayout_reset_write(task, data);
+			if (test_bit(NFS4_RESET_DEVICEID, &reset))
+				filelayout_mark_devid_invalid(devid);
+		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -290,16 +315,22 @@ static void prepare_to_resend_writes(struct nfs_write_data *data)
 static int filelayout_commit_done_cb(struct rpc_task *task,
 				     struct nfs_write_data *data)
 {
-	int reset = 0;
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	unsigned long reset = 0;
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
 					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
+
+		dprintk("%s reset 0x%lx ds_clp %p session %p\n", __func__,
+			reset, data->ds_clp, data->ds_clp->cl_session);
+
+		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
 			prepare_to_resend_writes(data);
-		else
+			if (test_bit(NFS4_RESET_DEVICEID, &reset))
+				filelayout_mark_devid_invalid(devid);
+		} else {
 			rpc_restart_call_prepare(task);
+		}
 		return -EAGAIN;
 	}
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index b54b389..08b667a 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -41,6 +41,12 @@
 #define NFS4_PNFS_MAX_STRIPE_CNT 4096
 #define NFS4_PNFS_MAX_MULTI_CNT  256 /* 256 fit into a u8 stripe_index */
 
+/* internal use */
+enum nfs4_fl_reset_state {
+	NFS4_RESET_TO_MDS = 0,
+	NFS4_RESET_DEVICEID,
+};
+
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
 	STRIPE_DENSE = 2
-- 
1.7.6.4

