Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab1BPSjB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:01 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 2 03/18] NFS move nfs_client initialization into nfs_get_client
Date: Tue, 15 Feb 2011 03:38:48 -0500
Message-Id: <1297759143-2045-4-git-send-email-andros@netapp.com>
In-Reply-To: <1297759143-2045-1-git-send-email-andros@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Now nfs_get_client returns an nfs_client ready to be used no matter if it was
found or created.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c         |   56 +++++++++++++++++++++++++---------------------
 fs/nfs/internal.h       |    9 +++++++
 fs/nfs/nfs3proc.c       |    1 +
 fs/nfs/nfs4proc.c       |    1 +
 fs/nfs/proc.c           |    1 +
 include/linux/nfs_xdr.h |    3 ++
 6 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index bd3ca32..b9ed2a8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -481,7 +481,12 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
+static struct nfs_client *
+nfs_get_client(const struct nfs_client_initdata *cl_init,
+	       const struct rpc_timeout *timeparms,
+	       const char *ip_addr,
+	       rpc_authflavor_t authflavour,
+	       int noresvport)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
@@ -512,6 +517,13 @@ install_client:
 	clp = new;
 	list_add(&clp->cl_share_link, &nfs_client_list);
 	spin_unlock(&nfs_client_lock);
+
+	error = cl_init->rpc_ops->init_client(clp, timeparms, ip_addr,
+					      authflavour, noresvport);
+	if (error < 0) {
+		nfs_put_client(clp);
+		return ERR_PTR(error);
+	}
 	dprintk("--> nfs_get_client() = %p [new]\n", clp);
 	return clp;
 
@@ -767,9 +779,9 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
 /*
  * Initialise an NFS2 or NFS3 client
  */
-static int nfs_init_client(struct nfs_client *clp,
-			   const struct rpc_timeout *timeparms,
-			   const struct nfs_parsed_mount_data *data)
+int nfs_init_client(struct nfs_client *clp, const struct rpc_timeout *timeparms,
+		    const char *ip_addr, rpc_authflavor_t authflavour,
+		    int noresvport)
 {
 	int error;
 
@@ -784,7 +796,7 @@ static int nfs_init_client(struct nfs_client *clp,
 	 * - RFC 2623, sec 2.3.2
 	 */
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
-				      0, data->flags & NFS_MOUNT_NORESVPORT);
+				      0, noresvport);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -820,19 +832,17 @@ static int nfs_init_server(struct nfs_server *server,
 		cl_init.rpc_ops = &nfs_v3_clientops;
 #endif
 
+	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
+			data->timeo, data->retrans);
+
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init);
+	clp = nfs_get_client(&cl_init, &timeparms, NULL, RPC_AUTH_UNIX,
+			     data->flags & NFS_MOUNT_NORESVPORT);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
 	}
 
-	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
-			data->timeo, data->retrans);
-	error = nfs_init_client(clp, &timeparms, data);
-	if (error < 0)
-		goto error;
-
 	server->nfs_client = clp;
 
 	/* Initialise the client representation from the mount data */
@@ -1307,11 +1317,11 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 /*
  * Initialise an NFS4 client record
  */
-static int nfs4_init_client(struct nfs_client *clp,
-		const struct rpc_timeout *timeparms,
-		const char *ip_addr,
-		rpc_authflavor_t authflavour,
-		int flags)
+int nfs4_init_client(struct nfs_client *clp,
+		     const struct rpc_timeout *timeparms,
+		     const char *ip_addr,
+		     rpc_authflavor_t authflavour,
+		     int noresvport)
 {
 	int error;
 
@@ -1325,7 +1335,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	clp->rpc_ops = &nfs_v4_clientops;
 
 	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-				      1, flags & NFS_MOUNT_NORESVPORT);
+				      1, noresvport);
 	if (error < 0)
 		goto error;
 	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
@@ -1378,22 +1388,16 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(&cl_init);
+	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour,
+			     server->flags & NFS_MOUNT_NORESVPORT);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
 	}
-	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour,
-					server->flags);
-	if (error < 0)
-		goto error_put;
 
 	server->nfs_client = clp;
 	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
 	return 0;
-
-error_put:
-	nfs_put_client(clp);
 error:
 	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
 	return error;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cf9fdbd..4d7b3a9 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -215,6 +215,10 @@ extern struct rpc_procinfo nfs4_procedures[];
 
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
+extern int nfs_init_client(struct nfs_client *clp,
+			   const struct rpc_timeout *timeparms,
+			   const char *ip_addr, rpc_authflavor_t authflavour,
+			   int noresvport);
 
 /* dir.c */
 extern int nfs_access_cache_shrinker(struct shrinker *shrink,
@@ -274,6 +278,11 @@ extern int nfs_migrate_page(struct address_space *,
 #endif
 
 /* nfs4proc.c */
+extern int nfs4_init_client(struct nfs_client *clp,
+			    const struct rpc_timeout *timeparms,
+			    const char *ip_addr,
+			    rpc_authflavor_t authflavour,
+			    int noresvport);
 extern int _nfs4_call_sync(struct nfs_server *server,
 			   struct rpc_message *msg,
 			   struct nfs4_sequence_args *args,
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index ce939c0..d0c80d8 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -885,4 +885,5 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.lock		= nfs3_proc_lock,
 	.clear_acl_cache = nfs3_forget_cached_acls,
 	.close_context	= nfs_close_context,
+	.init_client	= nfs_init_client,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78936a8..7faec0f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5595,6 +5595,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.clear_acl_cache = nfs4_zap_acl_attr,
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
+	.init_client	= nfs4_init_client,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 77d5e21..b8ec170 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -741,4 +741,5 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.lock		= nfs_proc_lock,
 	.lock_check_bounds = nfs_lock_check_bounds,
 	.close_context	= nfs_close_context,
+	.init_client	= nfs_init_client,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 51bfadb..d159fe7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1040,6 +1040,7 @@ struct nfs_write_data {
 };
 
 struct nfs_access_entry;
+struct nfs_client;
 
 /*
  * RPC procedure vector for NFSv2/NFSv3 demuxing
@@ -1104,6 +1105,8 @@ struct nfs_rpc_ops {
 				struct nfs_open_context *ctx,
 				int open_flags,
 				struct iattr *iattr);
+	int	(*init_client) (struct nfs_client *, const struct rpc_timeout *,
+				const char *, rpc_authflavor_t, int);
 };
 
 /*
-- 
1.7.2.3

