Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47382 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965048Ab2CVTTn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 15:19:43 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 05/11] NFSv4.1: mark deviceid invalid on filelayout DS connection errors
Date: Thu, 22 Mar 2012 15:19:33 -0400
Message-Id: <1332443979-2302-6-git-send-email-andros@netapp.com>
In-Reply-To: <1332443979-2302-1-git-send-email-andros@netapp.com>
References: <1332443979-2302-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This prevents the use of any layout for i/o that references the deviceid.
I/O is redirected through the MDS.

Redirect the unhandled failed I/O to the MDS without marking either the
layout or the deviceid invalid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   79 +++++++++++++++++++++++++++++------------------
 fs/nfs/nfs4filelayout.h |    3 ++
 2 files changed, 52 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 3802937..869ce26 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -116,14 +116,13 @@ void filelayout_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
-					 int *reset)
+					 struct nfs4_deviceid_node *devid)
 {
 	struct nfs_server *mds_server = NFS_SERVER(state->inode);
 	struct nfs_client *mds_client = mds_server->nfs_client;
 
 	if (task->tk_status >= 0)
 		return 0;
-	*reset = 0;
 
 	switch (task->tk_status) {
 	/* MDS state errors */
@@ -158,11 +157,22 @@ static int filelayout_async_handle_error(struct rpc_task *task,
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
+		dprintk("%s DS connection error %d\n", __func__,
+			task->tk_status);
+		filelayout_mark_devid_invalid(devid);
+		/* fall through */
 	default:
-		dprintk("%s DS error. Retry through MDS %d\n", __func__,
+		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
-		*reset = 1;
-		break;
+		return -NFS4ERR_RESET_TO_MDS;
 	}
 out:
 	task->tk_status = 0;
@@ -179,16 +189,19 @@ wait_on_recovery:
 static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
-	int reset = 0;
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	int err;
 
 	dprintk("%s DS read\n", __func__);
 
-	if (filelayout_async_handle_error(task, data->args.context->state,
-					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
-			filelayout_reset_read(task, data);
+	err = filelayout_async_handle_error(task, data->args.context->state,
+					  data->ds_clp, devid);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_MDS:
+		filelayout_reset_read(task, data);
+		/* fall through */
+	case -EAGAIN:
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -260,14 +273,17 @@ static void filelayout_read_release(void *data)
 static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_write_data *data)
 {
-	int reset = 0;
-
-	if (filelayout_async_handle_error(task, data->args.context->state,
-					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
-			filelayout_reset_write(task, data);
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	int err;
+
+	err = filelayout_async_handle_error(task, data->args.context->state,
+					  data->ds_clp, devid);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_MDS:
+		filelayout_reset_write(task, data);
+		/* fall through */
+	case -EAGAIN:
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -290,16 +306,19 @@ static void prepare_to_resend_writes(struct nfs_write_data *data)
 static int filelayout_commit_done_cb(struct rpc_task *task,
 				     struct nfs_write_data *data)
 {
-	int reset = 0;
-
-	if (filelayout_async_handle_error(task, data->args.context->state,
-					  data->ds_clp, &reset) == -EAGAIN) {
-		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
-			__func__, data->ds_clp, data->ds_clp->cl_session);
-		if (reset)
-			prepare_to_resend_writes(data);
-		else
-			rpc_restart_call_prepare(task);
+	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	int err;
+
+	err = filelayout_async_handle_error(task, data->args.context->state,
+					  data->ds_clp, devid);
+
+	switch (err) {
+	case -NFS4ERR_RESET_TO_MDS:
+		prepare_to_resend_writes(data);
+		return -EAGAIN;
+
+	case -EAGAIN:
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index b54b389..745324c 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -41,6 +41,9 @@
 #define NFS4_PNFS_MAX_STRIPE_CNT 4096
 #define NFS4_PNFS_MAX_MULTI_CNT  256 /* 256 fit into a u8 stripe_index */
 
+/* error codes for internal use */
+#define NFS4ERR_RESET_TO_MDS   12001
+
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
 	STRIPE_DENSE = 2
-- 
1.7.6.4

