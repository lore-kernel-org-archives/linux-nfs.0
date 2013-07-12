Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f178.google.com ([209.85.213.178]:61237 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964936Ab3GLQiM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:38:12 -0400
Received: by mail-ye0-f178.google.com with SMTP id m15so3165649yen.23
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:38:12 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id e42sm60849755yhh.25.2013.07.12.09.32.55
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:55 -0700 (PDT)
Subject: [PATCH v1 10/19] NFS: Implement a transport blocking scheme for
 migration
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:54 -0400
Message-ID: <20130712163254.1444.29296.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an NFSv4 migration event occurs, an NFS client must redirect
a mount point's underlying RPC transport to a different NFS server.

Before performing this redirection, the client must plug the RPC
transport to prevent the initiation of new requests, and allow
any pending requests or the migrating FSID to complete.

Only then is it safe to swap in a transport to the destination
server.  This is like NFSv4.1 session draining, so we adopt a
similar approach.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4client.c       |    4 ++++
 fs/nfs/nfs4proc.c         |   43 ++++++++++++++++++++++++++++++++++++++-----
 fs/nfs/nfs4state.c        |   19 +++++++++++++++++++
 include/linux/nfs_fs_sb.h |    4 ++++
 5 files changed, 66 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ae05978..b9c839e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -29,6 +29,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
 	NFS4CLNT_PURGE_STATE,
 	NFS4CLNT_BIND_CONN_TO_SESSION,
+	NFS4CLNT_BLOCK_XPRT,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 3aec2de..4d208e0 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -72,6 +72,10 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	if (clp->cl_minorversion == 0) {
+		init_completion(&clp->cl_xpcomplete);
+		rpc_init_wait_queue(&clp->cl_xpwaitq, "NFSv4.0 xprt");
+	}
 	return clp;
 
 error:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 20768e8..bb5100a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -414,6 +414,40 @@ static int nfs4_run_rpc_task(struct rpc_clnt *clnt,
 	return ret;
 }
 
+/*
+ * Returns -EAGAIN if task must wait for migration recovery;
+ * otherwise, zero is returned.
+ */
+static int nfs4_transport_setup(const struct nfs_server *server,
+				struct rpc_task *task)
+{
+	struct nfs_client *clp = server->nfs_client;
+
+	spin_lock(&clp->cl_lock);
+	if (test_bit(NFS4CLNT_BLOCK_XPRT, &clp->cl_state)) {
+		rpc_sleep_on(&clp->cl_xpwaitq, task, NULL);
+		spin_unlock(&clp->cl_lock);
+		dprintk("--> %s transport blocked for server %s\n",
+			__func__, clp->cl_hostname);
+		return -EAGAIN;
+	}
+	atomic_inc(&clp->cl_xppending);
+	spin_unlock(&clp->cl_lock);
+
+	rpc_call_start(task);
+	return 0;
+}
+
+static int nfs4_transport_done(const struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+
+	if (atomic_dec_and_test(&clp->cl_xppending) &&
+	    test_bit(NFS4CLNT_BLOCK_XPRT, &clp->cl_state))
+		complete(&clp->cl_xpcomplete);
+	return 1;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -558,7 +592,7 @@ static int nfs4_sequence_done(const struct nfs_server *server,
 			      struct nfs4_sequence_res *res)
 {
 	if (res->sr_slot == NULL)
-		return 1;
+		return nfs4_transport_done(server);
 	return nfs41_sequence_done(task, res);
 }
 
@@ -650,7 +684,7 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 	int ret = 0;
 
 	if (session == NULL) {
-		rpc_call_start(task);
+		ret = nfs4_transport_setup(server, task);
 		goto out;
 	}
 
@@ -723,15 +757,14 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 			       struct nfs4_sequence_res *res,
 			       struct rpc_task *task)
 {
-	rpc_call_start(task);
-	return 0;
+	return nfs4_transport_setup(server, task);
 }
 
 static int nfs4_sequence_done(const struct nfs_server *server,
 			      struct rpc_task *task,
 			      struct nfs4_sequence_res *res)
 {
-	return 1;
+	return nfs4_transport_done(server);
 }
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 71fc85d..ae482b2 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -355,6 +355,25 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 
 #endif /* CONFIG_NFS_V4_1 */
 
+static void nfs4_end_drain_xprt(struct nfs_client *clp)
+{
+	if (test_and_clear_bit(NFS4CLNT_BLOCK_XPRT, &clp->cl_state))
+		rpc_wake_up(&clp->cl_xpwaitq);
+}
+
+static int nfs4_begin_drain_xprt(struct nfs_client *clp)
+{
+	set_bit(NFS4CLNT_BLOCK_XPRT, &clp->cl_state);
+	spin_lock(&clp->cl_lock);
+	if (atomic_read(&clp->cl_xppending)) {
+		INIT_COMPLETION(clp->cl_xpcomplete);
+		spin_unlock(&clp->cl_lock);
+		return wait_for_completion_interruptible(&clp->cl_xpcomplete);
+	}
+	spin_unlock(&clp->cl_lock);
+	return 0;
+}
+
 /**
  * nfs4_get_clid_cred - Acquire credential for a setclientid operation
  * @clp: client state handle
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3b7fa2a..ad47c90 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -78,6 +78,10 @@ struct nfs_client {
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
 
+	atomic_t		cl_xppending;
+	struct completion	cl_xpcomplete;
+	struct rpc_wait_queue	cl_xpwaitq;
+
 	/* The sequence id to use for the next CREATE_SESSION */
 	u32			cl_seqid;
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */

