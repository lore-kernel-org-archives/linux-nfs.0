Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:53212 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755035AbeFRRfk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jun 2018 13:35:40 -0400
From: Bill Baker <bill.baker@oracle.com>
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4 client live hangs after live data migration recovery
Date: Mon, 18 Jun 2018 12:35:55 -0500
Message-Id: <1529343355-10499-1-git-send-email-bill.baker@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bill Baker <Bill.Baker@Oracle.com>

After a live data migration event at the NFS server, the client may send
I/O requests to the wrong server, causing a live hang due to repeated
recovery events.  On the wire, this will appear as an I/O request failing
with NFS4ERR_BADSESSION, followed by successful CREATE_SESSION, repeatedly.
NFS4ERR_BADSSESSION is returned because the session ID being used was
issued by the other server and is not valid at the old server.

The failure is caused by async worker threads having cached the transport
(xprt) in the rpc_task structure.  After the migration recovery completes,
the task is redispatched and the task resends the request to the wrong
server based on the old value still present in tk_xprt.

The solution is to recompute the tk_xprt field of the rpc_task structure
so that the request goes to the correct server.

Signed-off-by: Bill Baker <bill.baker@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Helen Chao <helen.chao@oracle.com>
---
 fs/nfs/nfs4proc.c           |  9 ++++++++-
 include/linux/sunrpc/clnt.h |  1 +
 net/sunrpc/clnt.c           | 28 ++++++++++++++++++++--------
 3 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed45090..2b1552b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -581,8 +581,15 @@ int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_
 		ret = -EIO;
 	return ret;
 out_retry:
-	if (ret == 0)
+	if (ret == 0) {
 		exception->retry = 1;
+		/*
+		 * For NFS4ERR_MOVED, the client transport will need to
+		 * be recomputed after migration recovery has completed.
+		 */
+		if (errorcode == -NFS4ERR_MOVED)
+			rpc_task_release_transport(task);
+	}
 	return ret;
 }
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 9b11b6a..73d5c4a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -156,6 +156,7 @@ int		rpc_switch_client_transport(struct rpc_clnt *,
 
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
+void		rpc_task_release_transport(struct rpc_task *);
 void		rpc_task_release_client(struct rpc_task *);
 
 int		rpcb_create_local(struct net *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d839c33..0d85425 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -965,10 +965,20 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 }
 EXPORT_SYMBOL_GPL(rpc_bind_new_program);
 
+void rpc_task_release_transport(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+
+	if (xprt) {
+		task->tk_xprt = NULL;
+		xprt_put(xprt);
+	}
+}
+EXPORT_SYMBOL_GPL(rpc_task_release_transport);
+
 void rpc_task_release_client(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
-	struct rpc_xprt *xprt = task->tk_xprt;
 
 	if (clnt != NULL) {
 		/* Remove from client task list */
@@ -979,12 +989,14 @@ void rpc_task_release_client(struct rpc_task *task)
 
 		rpc_release_client(clnt);
 	}
+	rpc_task_release_transport(task);
+}
 
-	if (xprt != NULL) {
-		task->tk_xprt = NULL;
-
-		xprt_put(xprt);
-	}
+static
+void rpc_task_set_transport(struct rpc_task *task, struct rpc_clnt *clnt)
+{
+	if (!task->tk_xprt)
+		task->tk_xprt = xprt_iter_get_next(&clnt->cl_xpi);
 }
 
 static
@@ -992,8 +1004,7 @@ void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 {
 
 	if (clnt != NULL) {
-		if (task->tk_xprt == NULL)
-			task->tk_xprt = xprt_iter_get_next(&clnt->cl_xpi);
+		rpc_task_set_transport(task, clnt);
 		task->tk_client = clnt;
 		atomic_inc(&clnt->cl_count);
 		if (clnt->cl_softrtry)
@@ -1512,6 +1523,7 @@ void rpc_force_rebind(struct rpc_clnt *clnt)
 		clnt->cl_program->version[clnt->cl_vers]->counts[idx]++;
 	clnt->cl_stats->rpccnt++;
 	task->tk_action = call_reserve;
+	rpc_task_set_transport(task, clnt);
 }
 
 /*
-- 
1.8.3.1

