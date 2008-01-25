From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 083/112] NFS: Support per-mountpoint timeout parameters.
Date: Fri, 25 Jan 2008 11:37:53 -0500
Message-ID: <20080125163753.31887.68691.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14368 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbYAYRAE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:04 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseq010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:01 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |   82 ++++++++++++++++++++++++++-------------------
 fs/nfs/super.c            |    4 +-
 include/linux/nfs_fs_sb.h |    2 -
 3 files changed, 49 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 59a6dcc..03d9bed 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -415,18 +415,16 @@ static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
  * Create an RPC client handle
  */
 static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
-						unsigned int timeo,
-						unsigned int retrans,
-						rpc_authflavor_t flavor,
-						int flags)
+				 const struct rpc_timeout *timeparms,
+				 rpc_authflavor_t flavor,
+				 int flags)
 {
-	struct rpc_timeout	timeparms;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
-		.timeout	= &timeparms,
+		.timeout	= timeparms,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
@@ -437,10 +435,6 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 	if (!IS_ERR(clp->cl_rpcclient))
 		return 0;
 
-	nfs_init_timeout_values(&timeparms, proto, timeo, retrans);
-	clp->retrans_timeo = timeparms.to_initval;
-	clp->retrans_count = timeparms.to_retries;
-
 	clnt = rpc_create(&args);
 	if (IS_ERR(clnt)) {
 		dprintk("%s: cannot create RPC client. Error = %ld\n",
@@ -515,7 +509,9 @@ static inline void nfs_init_server_aclclient(struct nfs_server *server)
 /*
  * Create a general RPC client
  */
-static int nfs_init_server_rpcclient(struct nfs_server *server, rpc_authflavor_t pseudoflavour)
+static int nfs_init_server_rpcclient(struct nfs_server *server,
+		const struct rpc_timeout *timeo,
+		rpc_authflavor_t pseudoflavour)
 {
 	struct nfs_client *clp = server->nfs_client;
 
@@ -525,6 +521,11 @@ static int nfs_init_server_rpcclient(struct nfs_server *server, rpc_authflavor_t
 		return PTR_ERR(server->client);
 	}
 
+	memcpy(&server->client->cl_timeout_default,
+			timeo,
+			sizeof(server->client->cl_timeout_default));
+	server->client->cl_timeout = &server->client->cl_timeout_default;
+
 	if (pseudoflavour != clp->cl_rpcclient->cl_auth->au_flavor) {
 		struct rpc_auth *auth;
 
@@ -549,6 +550,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server, rpc_authflavor_t
  * Initialise an NFS2 or NFS3 client
  */
 static int nfs_init_client(struct nfs_client *clp,
+			   const struct rpc_timeout *timeparms,
 			   const struct nfs_parsed_mount_data *data)
 {
 	int error;
@@ -564,7 +566,7 @@ static int nfs_init_client(struct nfs_client *clp,
 	 * - RFC 2623, sec 2.3.2
 	 */
 	error = nfs_create_rpc_client(clp, data->nfs_server.protocol,
-				data->timeo, data->retrans, RPC_AUTH_UNIX, 0);
+				timeparms, RPC_AUTH_UNIX, 0);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -588,6 +590,7 @@ static int nfs_init_server(struct nfs_server *server,
 		.addrlen = data->nfs_server.addrlen,
 		.rpc_ops = &nfs_v2_clientops,
 	};
+	struct rpc_timeout timeparms;
 	struct nfs_client *clp;
 	int error;
 
@@ -605,7 +608,9 @@ static int nfs_init_server(struct nfs_server *server,
 		return PTR_ERR(clp);
 	}
 
-	error = nfs_init_client(clp, data);
+	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
+			data->timeo, data->retrans);
+	error = nfs_init_client(clp, &timeparms, data);
 	if (error < 0)
 		goto error;
 
@@ -629,7 +634,7 @@ static int nfs_init_server(struct nfs_server *server,
 	if (error < 0)
 		goto error;
 
-	error = nfs_init_server_rpcclient(server, data->auth_flavors[0]);
+	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 	if (error < 0)
 		goto error;
 
@@ -889,7 +894,8 @@ error:
  * Initialise an NFS4 client record
  */
 static int nfs4_init_client(struct nfs_client *clp,
-		int proto, int timeo, int retrans,
+		int proto,
+		const struct rpc_timeout *timeparms,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour)
 {
@@ -904,7 +910,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
-	error = nfs_create_rpc_client(clp, proto, timeo, retrans, authflavour,
+	error = nfs_create_rpc_client(clp, proto, timeparms, authflavour,
 					RPC_CLNT_CREATE_DISCRTRY);
 	if (error < 0)
 		goto error;
@@ -936,7 +942,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		const size_t addrlen,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
-		int proto, int timeo, int retrans)
+		int proto, const struct rpc_timeout *timeparms)
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
@@ -955,7 +961,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		error = PTR_ERR(clp);
 		goto error;
 	}
-	error = nfs4_init_client(clp, proto, timeo, retrans, ip_addr, authflavour);
+	error = nfs4_init_client(clp, proto, timeparms, ip_addr, authflavour);
 	if (error < 0)
 		goto error_put;
 
@@ -976,10 +982,26 @@ error:
 static int nfs4_init_server(struct nfs_server *server,
 		const struct nfs_parsed_mount_data *data)
 {
+	struct rpc_timeout timeparms;
 	int error;
 
 	dprintk("--> nfs4_init_server()\n");
 
+	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
+			data->timeo, data->retrans);
+
+	/* Get a client record */
+	error = nfs4_set_client(server,
+			data->nfs_server.hostname,
+			(const struct sockaddr *)&data->nfs_server.address,
+			data->nfs_server.addrlen,
+			data->client_address,
+			data->auth_flavors[0],
+			data->nfs_server.protocol,
+			&timeparms);
+	if (error < 0)
+		goto error;
+
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
 	server->caps |= NFS_CAP_ATOMIC_OPEN;
@@ -994,8 +1016,9 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
 
-	error = nfs_init_server_rpcclient(server, data->auth_flavors[0]);
+	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 
+error:
 	/* Done */
 	dprintk("<-- nfs4_init_server() = %d\n", error);
 	return error;
@@ -1018,18 +1041,6 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	/* Get a client record */
-	error = nfs4_set_client(server,
-			data->nfs_server.hostname,
-			(struct sockaddr *)&data->nfs_server.address,
-			data->nfs_server.addrlen,
-			data->client_address,
-			data->auth_flavors[0],
-			data->nfs_server.protocol,
-			data->timeo, data->retrans);
-	if (error < 0)
-		goto error;
-
 	/* set up the general RPC client */
 	error = nfs4_init_server(server, data);
 	if (error < 0)
@@ -1103,8 +1114,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				parent_client->cl_ipaddr,
 				data->authflavor,
 				parent_server->client->cl_xprt->prot,
-				parent_client->retrans_timeo,
-				parent_client->retrans_count);
+				parent_server->client->cl_timeout);
 	if (error < 0)
 		goto error;
 
@@ -1112,7 +1122,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	nfs_server_copy_userdata(server, parent_server);
 	server->caps |= NFS_CAP_ATOMIC_OPEN;
 
-	error = nfs_init_server_rpcclient(server, data->authflavor);
+	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
 	if (error < 0)
 		goto error;
 
@@ -1181,7 +1191,9 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 
 	server->fsid = fattr->fsid;
 
-	error = nfs_init_server_rpcclient(server, source->client->cl_auth->au_flavor);
+	error = nfs_init_server_rpcclient(server,
+			source->client->cl_timeout,
+			source->client->cl_auth->au_flavor);
 	if (error < 0)
 		goto out_free_server;
 	if (!IS_ERR(source->client_acl))
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3cbe32f..0d1bc61 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -479,8 +479,8 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	}
 	seq_printf(m, ",proto=%s",
 		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_PROTO));
-	seq_printf(m, ",timeo=%lu", 10U * clp->retrans_timeo / HZ);
-	seq_printf(m, ",retrans=%u", clp->retrans_count);
+	seq_printf(m, ",timeo=%lu", 10U * nfss->client->cl_timeout->to_initval / HZ);
+	seq_printf(m, ",retrans=%u", nfss->client->cl_timeout->to_retries);
 	seq_printf(m, ",sec=%s", nfs_pseudoflavour_to_name(nfss->client->cl_auth->au_flavor));
 }
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 912cfe8..d15c948 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -29,8 +29,6 @@ struct nfs_client {
 
 	struct rpc_clnt *	cl_rpcclient;
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS protocol vector */
-	unsigned long		retrans_timeo;	/* retransmit timeout */
-	unsigned int		retrans_count;	/* number of retransmit tries */
 
 #ifdef CONFIG_NFS_V4
 	u64			cl_clientid;	/* constant */
