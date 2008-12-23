From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/69] NFS: move nfs_server flag initialization
Date: Tue, 23 Dec 2008 18:02:08 -0500
Message-ID: <20081223230208.13743.68946.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbYLWXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:46 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFj006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Make it possible for the NFSv4 mount set up logic to pass mount option
flags down the stack to nfs_create_rpc_client().

This is immediately useful if we want NFS mount options to modulate
settings of the underlying RPC transport, but it may be useful at some
later point if other parts of the NFSv4 mount initialization logic
want to know what the mount options are.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d11cdaa..2719033 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1063,6 +1063,10 @@ static int nfs4_init_server(struct nfs_server *server,
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
 
+	/* Initialise the client representation from the mount data */
+	server->flags = data->flags;
+	server->caps |= NFS_CAP_ATOMIC_OPEN;
+
 	/* Get a client record */
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
@@ -1075,10 +1079,6 @@ static int nfs4_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
-	/* Initialise the client representation from the mount data */
-	server->flags = data->flags;
-	server->caps |= NFS_CAP_ATOMIC_OPEN;
-
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
 	if (data->wsize)
@@ -1181,6 +1181,10 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	parent_server = NFS_SB(data->sb);
 	parent_client = parent_server->nfs_client;
 
+	/* Initialise the client representation from the parent server */
+	nfs_server_copy_userdata(server, parent_server);
+	server->caps |= NFS_CAP_ATOMIC_OPEN;
+
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
 	error = nfs4_set_client(server, data->hostname,
@@ -1193,10 +1197,6 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	/* Initialise the client representation from the parent server */
-	nfs_server_copy_userdata(server, parent_server);
-	server->caps |= NFS_CAP_ATOMIC_OPEN;
-
 	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
 	if (error < 0)
 		goto error;

