Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33226 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdEBQiZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:38:25 -0400
Received: by mail-io0-f196.google.com with SMTP id o22so7015738iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:38:20 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 3/5] NFSv4: Allow multiple connections to NFSv4.x (x>0) servers
Date: Tue,  2 May 2017 12:38:09 -0400
Message-Id: <20170502163812.6211-6-trond.myklebust@primarydata.com>
In-Reply-To: <20170502163812.6211-5-trond.myklebust@primarydata.com>
References: <20170502163812.6211-1-trond.myklebust@primarydata.com>
 <20170502163812.6211-2-trond.myklebust@primarydata.com>
 <20170502163812.6211-3-trond.myklebust@primarydata.com>
 <20170502163812.6211-4-trond.myklebust@primarydata.com>
 <20170502163812.6211-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the user specifies the -onconn=<number> mount option, and the transport
protocol is TCP, then set up <number> connections to the server. The
connections will all go to the same IP address.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/client.c           |  2 ++
 fs/nfs/internal.h         |  1 +
 fs/nfs/nfs4client.c       | 10 ++++++++--
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e0302101e18a..c5b0f3e270a3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -180,6 +180,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
 
 	clp->cl_proto = cl_init->proto;
+	clp->cl_nconnect = cl_init->nconnect;
 	clp->cl_net = get_net(cl_init->net);
 
 	cred = rpc_lookup_machine_cred("*");
@@ -488,6 +489,7 @@ int nfs_create_rpc_client(struct nfs_client *clp,
 	struct rpc_create_args args = {
 		.net		= clp->cl_net,
 		.protocol	= clp->cl_proto,
+		.nconnect	= clp->cl_nconnect,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
 		.timeout	= cl_init->timeparms,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31757a742e9b..abe5d3934eaf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -77,6 +77,7 @@ struct nfs_client_initdata {
 	struct nfs_subversion *nfs_mod;
 	int proto;
 	u32 minorversion;
+	unsigned int nconnect;
 	struct net *net;
 	const struct rpc_timeout *timeparms;
 };
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 692a7a8bfc7a..c9b10b7829f0 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -834,7 +834,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		const size_t addrlen,
 		const char *ip_addr,
 		int proto, const struct rpc_timeout *timeparms,
-		u32 minorversion, struct net *net)
+		u32 minorversion, unsigned int nconnect,
+		struct net *net)
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = hostname,
@@ -849,6 +850,8 @@ static int nfs4_set_client(struct nfs_server *server,
 	};
 	struct nfs_client *clp;
 
+	if (minorversion > 0 && proto == XPRT_TRANSPORT_TCP)
+		cl_init.nconnect = nconnect;
 	if (server->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 	if (server->options & NFS_OPTION_MIGRATION)
@@ -1040,6 +1043,7 @@ static int nfs4_init_server(struct nfs_server *server,
 			data->nfs_server.protocol,
 			&timeparms,
 			data->minorversion,
+			data->nfs_server.nconnect,
 			data->net);
 	if (error < 0)
 		return error;
@@ -1124,6 +1128,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
 				parent_client->cl_mvops->minor_version,
+				parent_client->cl_nconnect,
 				parent_client->cl_net);
 	if (error < 0)
 		goto error;
@@ -1215,7 +1220,8 @@ int nfs4_update_server(struct nfs_server *server, const char *hostname,
 	nfs_server_remove_lists(server);
 	error = nfs4_set_client(server, hostname, sap, salen, buf,
 				clp->cl_proto, clnt->cl_timeout,
-				clp->cl_minorversion, net);
+				clp->cl_minorversion,
+				clp->cl_nconnect, net);
 	nfs_put_client(clp);
 	if (error != 0) {
 		nfs_server_insert_lists(server);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2a70f34dffe8..b7e6b94d1246 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -55,6 +55,7 @@ struct nfs_client {
 	struct nfs_subversion *	cl_nfs_mod;	/* pointer to nfs version module */
 
 	u32			cl_minorversion;/* NFSv4 minorversion */
+	unsigned int		cl_nconnect;	/* Number of connections */
 	struct rpc_cred		*cl_machine_cred;
 
 #if IS_ENABLED(CONFIG_NFS_V4)
-- 
2.9.3

