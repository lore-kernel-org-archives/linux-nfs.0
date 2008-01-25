From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 084/112] NFS: Fix the 'proto=' mount option
Date: Fri, 25 Jan 2008 11:37:54 -0500
Message-ID: <20080125163753.31887.10102.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755704AbYAYRAE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:04 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseo010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:01 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if you have a server mounted using networking protocol, you
cannot specify a different value using the 'proto=' option on another
mountpoint.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |   20 +++++++++++++-------
 include/linux/nfs_fs_sb.h |    1 +
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 03d9bed..18fcb05 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -100,6 +100,7 @@ struct nfs_client_initdata {
 	const struct sockaddr *addr;
 	size_t addrlen;
 	const struct nfs_rpc_ops *rpc_ops;
+	int proto;
 };
 
 /*
@@ -138,6 +139,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	INIT_LIST_HEAD(&clp->cl_superblocks);
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
 
+	clp->cl_proto = cl_init->proto;
+
 #ifdef CONFIG_NFS_V4
 	init_rwsem(&clp->cl_sem);
 	INIT_LIST_HEAD(&clp->cl_delegations);
@@ -289,6 +292,9 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		if (clp->rpc_ops != data->rpc_ops)
 			continue;
 
+		if (clp->cl_proto != data->proto)
+			continue;
+
 		/* Match the full socket address */
 		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
 			continue;
@@ -414,14 +420,14 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 /*
  * Create an RPC client handle
  */
-static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
+static int nfs_create_rpc_client(struct nfs_client *clp,
 				 const struct rpc_timeout *timeparms,
 				 rpc_authflavor_t flavor,
 				 int flags)
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
-		.protocol	= proto,
+		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
 		.timeout	= timeparms,
@@ -565,8 +571,7 @@ static int nfs_init_client(struct nfs_client *clp,
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, data->nfs_server.protocol,
-				timeparms, RPC_AUTH_UNIX, 0);
+	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX, 0);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -589,6 +594,7 @@ static int nfs_init_server(struct nfs_server *server,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
 		.rpc_ops = &nfs_v2_clientops,
+		.proto = data->nfs_server.protocol,
 	};
 	struct rpc_timeout timeparms;
 	struct nfs_client *clp;
@@ -894,7 +900,6 @@ error:
  * Initialise an NFS4 client record
  */
 static int nfs4_init_client(struct nfs_client *clp,
-		int proto,
 		const struct rpc_timeout *timeparms,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour)
@@ -910,7 +915,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
-	error = nfs_create_rpc_client(clp, proto, timeparms, authflavour,
+	error = nfs_create_rpc_client(clp, timeparms, authflavour,
 					RPC_CLNT_CREATE_DISCRTRY);
 	if (error < 0)
 		goto error;
@@ -949,6 +954,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		.addr = addr,
 		.addrlen = addrlen,
 		.rpc_ops = &nfs_v4_clientops,
+		.proto = proto,
 	};
 	struct nfs_client *clp;
 	int error;
@@ -961,7 +967,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		error = PTR_ERR(clp);
 		goto error;
 	}
-	error = nfs4_init_client(clp, proto, timeparms, ip_addr, authflavour);
+	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour);
 	if (error < 0)
 		goto error_put;
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d15c948..b5ba5f7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -29,6 +29,7 @@ struct nfs_client {
 
 	struct rpc_clnt *	cl_rpcclient;
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS protocol vector */
+	int			cl_proto;	/* Network transport protocol */
 
 #ifdef CONFIG_NFS_V4
 	u64			cl_clientid;	/* constant */
