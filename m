Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34351 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaJPTkC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:40:02 -0400
Received: by mail-ig0-f169.google.com with SMTP id uq10so1670673igb.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:40:01 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id kj6sm14824783igb.6.2014.10.16.12.40.00
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:40:00 -0700 (PDT)
Subject: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:40:00 -0400
Message-ID: <20141016194000.13414.83844.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So far, TCP is the only transport that supports bi-directional RPC.

When mounting with NFSv4.1 using a transport that does not support
bi-directional RPC, establish a TCP sidecar connection to handle
backchannel traffic for a session. The sidecar transport does not
use its forward channel except for sending BIND_CONN_TO_SESSION
operations.

This commit adds logic to create and destroy the sidecar transport.
Subsequent commits add logic to use the transport.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4client.c       |   54 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    2 ++
 3 files changed, 57 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6a4f366..19f49bf 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -78,6 +78,7 @@ const struct rpc_program nfs_program = {
 	.stats			= &nfs_rpcstat,
 	.pipe_dir_name		= NFS_PIPE_DIRNAME,
 };
+EXPORT_SYMBOL_GPL(nfs_program);
 
 struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 5f4b818..b1cc35e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -213,6 +213,8 @@ static void nfs4_destroy_callback(struct nfs_client *clp)
 {
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
 		nfs_callback_down(clp->cl_mvops->minor_version, clp->cl_net);
+	if (clp->cl_bc_rpcclient)
+		rpc_shutdown_client(clp->cl_bc_rpcclient);
 }
 
 static void nfs4_shutdown_client(struct nfs_client *clp)
@@ -291,6 +293,53 @@ int nfs40_init_client(struct nfs_client *clp)
 
 #if defined(CONFIG_NFS_V4_1)
 
+/*
+ * Create a separate rpc_clnt using TCP that can provide a
+ * backchannel service.
+ */
+static int nfs41_create_sidecar_rpc_client(struct nfs_client *clp)
+{
+	struct sockaddr_storage address;
+	struct sockaddr *sap = (struct sockaddr *)&address;
+	struct rpc_create_args args = {
+		.net		= clp->cl_net,
+		.protocol	= XPRT_TRANSPORT_TCP,
+		.address	= sap,
+		.addrsize	= clp->cl_addrlen,
+		.servername	= clp->cl_hostname,
+		.program	= &nfs_program,
+		.version	= clp->rpc_ops->version,
+		.flags		= (RPC_CLNT_CREATE_DISCRTRY |
+				  RPC_CLNT_CREATE_NOPING),
+	};
+	struct rpc_clnt *clnt;
+	struct rpc_cred *cred;
+
+	if (rpc_xprt_is_bidirectional(clp->cl_rpcclient))
+		return 0;
+
+	if (test_bit(NFS_CS_NORESVPORT, &clp->cl_flags))
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+	memcpy(sap, &clp->cl_addr, clp->cl_addrlen);
+	rpc_set_port(sap, NFS_PORT);
+	cred = nfs4_get_clid_cred(clp);
+	if (cred) {
+		args.authflavor = cred->cr_auth->au_flavor;
+		put_rpccred(cred);
+	} else
+		args.authflavor = RPC_AUTH_UNIX;
+
+	clnt = rpc_create(&args);
+	if (IS_ERR(clnt)) {
+		dprintk("%s: cannot create side-car RPC client. Error = %ld\n",
+			__func__, PTR_ERR(clnt));
+		return PTR_ERR(clnt);
+	}
+
+	clp->cl_bc_rpcclient = clnt;
+	return 0;
+}
+
 /**
  * nfs41_init_client - nfs_client initialization tasks for NFSv4.1+
  * @clp - nfs_client to initialize
@@ -300,6 +349,11 @@ int nfs40_init_client(struct nfs_client *clp)
 int nfs41_init_client(struct nfs_client *clp)
 {
 	struct nfs4_session *session = NULL;
+	int ret;
+
+	ret = nfs41_create_sidecar_rpc_client(clp);
+	if (ret)
+		return ret;
 
 	/*
 	 * Create the session and mark it expired.
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 922be2e..159d703 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -87,6 +87,8 @@ struct nfs_client {
 
 	/* The sequence id to use for the next CREATE_SESSION */
 	u32			cl_seqid;
+	/* The optional sidecar backchannel transport */
+	struct rpc_clnt		*cl_bc_rpcclient;
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session;	/* shared session */

