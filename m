Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33273 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcBAEl1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 23:41:27 -0500
Received: by mail-io0-f178.google.com with SMTP id f81so144117800iof.0
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 20:41:27 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 11/13] NFSv4.1: nfs4_proc_bind_conn_to_session must iterate over all connections
Date: Sun, 31 Jan 2016 23:40:28 -0500
Message-Id: <1454301630-17358-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454301630-17358-11-git-send-email-trond.myklebust@primarydata.com>
References: <1454301630-17358-1-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-2-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-3-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-4-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-5-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-6-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-7-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-8-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-9-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-10-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new helper to ensure that nfs4_proc_bind_conn_to_session() is called
for all connections.
However ensure that we only set the backchannel flag for the connection
pointed to by rpc_clnt->cl_xprt.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 48 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4bfc33ad0563..36471e013a73 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6783,12 +6783,16 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 }
 
 /*
- * nfs4_proc_bind_conn_to_session()
+ * nfs4_proc_bind_one_conn_to_session()
  *
  * The 4.1 client currently uses the same TCP connection for the
  * fore and backchannel.
  */
-int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
+static
+int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
+		struct nfs_client *clp,
+		struct rpc_cred *cred)
 {
 	int status;
 	struct nfs41_bind_conn_to_session_args args = {
@@ -6803,6 +6807,13 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
 		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clnt,
+		.rpc_xprt = xprt,
+		.rpc_message = &msg,
+		.flags = RPC_TASK_TIMEOUT,
+	};
+	struct rpc_task *task;
 
 	dprintk("--> %s\n", __func__);
 
@@ -6810,7 +6821,16 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
 	if (!(clp->cl_session->flags & SESSION4_BACK_CHAN))
 		args.dir = NFS4_CDFC4_FORE;
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	/* Do not set the backchannel flag unless this is clnt->cl_xprt */
+	if (xprt != rcu_access_pointer(clnt->cl_xprt))
+		args.dir = NFS4_CDFC4_FORE;
+
+	task = rpc_run_task(&task_setup_data);
+	if (!IS_ERR(task)) {
+		status = task->tk_status;
+		rpc_put_task(task);
+	} else
+		status = PTR_ERR(task);
 	trace_nfs4_bind_conn_to_session(clp, status);
 	if (status == 0) {
 		if (memcmp(res.sessionid.data,
@@ -6837,6 +6857,31 @@ out:
 	return status;
 }
 
+struct rpc_bind_conn_calldata {
+	struct nfs_client *clp;
+	struct rpc_cred *cred;
+};
+
+static int
+nfs4_proc_bind_conn_to_session_callback(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
+		void *calldata)
+{
+	struct rpc_bind_conn_calldata *p = calldata;
+
+	return nfs4_proc_bind_one_conn_to_session(clnt, xprt, p->clp, p->cred);
+}
+
+int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	struct rpc_bind_conn_calldata data = {
+		.clp = clp,
+		.cred = cred,
+	};
+	return rpc_clnt_iterate_for_each_xprt(clp->cl_rpcclient,
+			nfs4_proc_bind_conn_to_session_callback, &data);
+}
+
 /*
  * Minimum set of SP4_MACH_CRED operations from RFC 5661 in the enforce map
  * and operations we'd like to see to enable certain features in the allow map
-- 
2.5.0

