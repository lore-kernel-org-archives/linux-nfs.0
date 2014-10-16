Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:53844 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708AbaJPTkT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:40:19 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so265457igc.12
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:40:17 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id ro6sm14834946igb.3.2014.10.16.12.40.17
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:40:17 -0700 (PDT)
Subject: [PATCH v1 15/16] NFS: Bind side-car connection to session
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:40:16 -0400
Message-ID: <20141016194016.13414.14921.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When recovering from a network partition, a client must identify
both the forward and backchannel it wants bound to a session.

Usually these use the same transport, which can be re-bound to the
session with a single BIND_CONN_TO_SESSION operation.

But with a sidecar backchannel, the fore and back channels use
separate transports that must be bound to the transport connection
using separate BC2S operations.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4client.c |    5 ++++-
 fs/nfs/nfs4proc.c   |   48 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b1cc35e..97cc170 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -246,7 +246,10 @@ static int nfs4_init_callback(struct nfs_client *clp)
 	struct rpc_xprt *xprt;
 	int error;
 
-	xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
+	if (clp->cl_bc_rpcclient)
+		xprt = rcu_dereference_raw(clp->cl_bc_rpcclient->cl_xprt);
+	else
+		xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
 
 	if (nfs4_has_session(clp)) {
 		error = xprt_setup_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9a8ffb7..2eaf7ec 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6569,18 +6569,16 @@ nfs41_same_server_scope(struct nfs41_server_scope *a,
 	return false;
 }
 
-/*
- * nfs4_proc_bind_conn_to_session()
- *
- * The 4.1 client currently uses the same TCP connection for the
- * fore and backchannel.
- */
-int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
+static int _nfs4_proc_bind_conn_to_session(struct nfs_client *clp,
+					   struct rpc_cred *cred,
+					   struct rpc_clnt *clnt,
+					   u32 dir_from_client,
+					   u32 dir_from_server)
 {
 	int status;
 	struct nfs41_bind_conn_to_session_args args = {
 		.client = clp,
-		.dir = NFS4_CDFC4_BACK_OR_BOTH,
+		.dir = dir_from_client,
 	};
 	struct nfs41_bind_conn_to_session_res res;
 	struct rpc_message msg = {
@@ -6599,7 +6597,7 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
 		goto out;
 	}
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
+	status = rpc_call_sync(clnt, &msg, RPC_TASK_TIMEOUT);
 	trace_nfs4_bind_conn_to_session(clp, status);
 	if (status == 0) {
 		if (memcmp(res.session->sess_id.data,
@@ -6608,7 +6606,7 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
 			status = -EIO;
 			goto out_session;
 		}
-		if (res.dir != NFS4_CDFS4_BOTH) {
+		if (res.dir != dir_from_server) {
 			dprintk("NFS: %s: Unexpected direction from server\n",
 				__func__);
 			status = -EIO;
@@ -6628,6 +6626,36 @@ out:
 	return status;
 }
 
+/**
+ * nfs4_proc_bind_conn_to_session - (re)bind fore/back channels to session
+ * @clp: per-server state
+ * @cred: credential for managing state
+ *
+ * Returns zero on success, or a negative errno or negative NFS4ERR.
+ */
+int nfs4_proc_bind_conn_to_session(struct nfs_client *clp,
+				   struct rpc_cred *cred)
+{
+	int ret;
+
+	if (!clp->cl_bc_rpcclient)
+		return _nfs4_proc_bind_conn_to_session(clp, cred,
+						clp->cl_rpcclient,
+						NFS4_CDFC4_BACK_OR_BOTH,
+						NFS4_CDFS4_BOTH);
+
+	ret = _nfs4_proc_bind_conn_to_session(clp, cred,
+						clp->cl_bc_rpcclient,
+						NFS4_CDFC4_BACK,
+						NFS4_CDFS4_BACK);
+	if (ret)
+		return ret;
+	return _nfs4_proc_bind_conn_to_session(clp, cred,
+						clp->cl_rpcclient,
+						NFS4_CDFC4_FORE,
+						NFS4_CDFS4_FORE);
+}
+
 /*
  * Minimum set of SP4_MACH_CRED operations from RFC 5661 in the enforce map
  * and operations we'd like to see to enable certain features in the allow map

