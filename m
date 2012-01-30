Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:48404 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab2A3TaG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:06 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:05 -0700
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 35390C9004D
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:30:00 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTxZY263256
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:29:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTwve015797
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 17:29:58 -0200
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTvXI015726
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 17:29:57 -0200
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/13] NFS: Handle replication on a timeout error
Date: Mon, 30 Jan 2012 13:29:54 -0600
Message-Id: <1327951795-16400-13-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_handle_exception and nfs4_async_handle_error now handle ETIMEDOUT
errors by replacing the transport with a replicated server.

The RPC layer tries to handle timeouts by itself in most cases. It
should be made aware of presence of replicated servers so that it can
return time out failures sooner for replication. Right, now it is a
hack, it returns tasks that encounter first timeout.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs4proc.c |   14 ++++++++++++++
 net/sunrpc/clnt.c |   12 ++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 775adb3..2198b13 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -265,6 +265,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 	switch(errorcode) {
 		case 0:
 			return 0;
+		case -ETIMEDOUT:
+			nfs4_schedule_replication_recovery(server);
+			goto wait_on_recovery;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OPENMODE:
@@ -3716,6 +3719,16 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	if (task->tk_status >= 0)
 		return 0;
 	switch(task->tk_status) {
+		case -ETIMEDOUT:
+			printk(KERN_ERR "%s ERROR: %d calling replicate recovery\n",
+				__func__, task->tk_status);
+			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+			nfs4_schedule_replication_recovery(server);
+			if (test_bit(NFS4CLNT_MANAGER_RUNNING,
+				     &clp->cl_state) == 0)
+				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
+							task);
+			goto restart_call;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OPENMODE:
@@ -3762,6 +3775,7 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;
 }
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e9e8097..ed15b44 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1830,6 +1830,18 @@ call_timeout(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
+	/*
+	 * TODO: If replicated server is present, propagate timeout
+	 * failures as soon as possible to upper layers.  We just
+	 * assume that replicated server is present in this RFC patch.
+	 * RPC client should be made aware of replication later.
+	 */
+	if (1) {
+
+		rpc_exit(task, -ETIMEDOUT);
+		return;
+	}
+
 	if (xprt_adjust_timeout(task->tk_rqstp) == 0) {
 		dprintk("RPC: %5u call_timeout (minor)\n", task->tk_pid);
 		goto retry;
-- 
1.7.8.3

