From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/69] NFS: expand flags passed to nfs_create_rpc_client()
Date: Tue, 23 Dec 2008 18:02:08 -0500
Message-ID: <20081223230208.13743.71684.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbYLWXXm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:42 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7O021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The nfs_create_rpc_client() function sets up an RPC client for an NFS
mount point.  Add an option that allows it to set up an RPC transport
from an unprivileged port.

Instead of having nfs_create_rpc_client()'s callers retain local
knowledge about how to set up an RPC client, create a couple of flag
arguments to control the use of RPC_CLNT_CREATE flags.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7547600..d11cdaa 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -470,7 +470,7 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 static int nfs_create_rpc_client(struct nfs_client *clp,
 				 const struct rpc_timeout *timeparms,
 				 rpc_authflavor_t flavor,
-				 int flags)
+				 int discrtry, int noresvport)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
@@ -482,9 +482,13 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
-		.flags		= flags,
 	};
 
+	if (discrtry)
+		args.flags |= RPC_CLNT_CREATE_DISCRTRY;
+	if (noresvport)
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+
 	if (!IS_ERR(clp->cl_rpcclient))
 		return 0;
 
@@ -623,7 +627,7 @@ static int nfs_init_client(struct nfs_client *clp,
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX, 0);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX, 0, 0);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -979,7 +983,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	clp->rpc_ops = &nfs_v4_clientops;
 
 	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-					RPC_CLNT_CREATE_DISCRTRY);
+				      1, 0);
 	if (error < 0)
 		goto error;
 	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));

