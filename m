Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab1BDVeo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:44 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 24/40] NFS move nfs_client initialization into nfs_get_client
Date: Fri,  4 Feb 2011 16:33:46 -0500
Message-Id: <1296855242-2592-25-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-24-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Now nfs_get_client returns an nfs_client ready to be used no matter if it was
found or created.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |   66 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 46 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ea2d032..5cfcd40 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -81,6 +81,15 @@ retry:
 }
 #endif /* CONFIG_NFS_V4 */
 
+static int nfs4_init_client(struct nfs_client *clp,
+		const struct rpc_timeout *timeparms,
+		const char *ip_addr,
+		rpc_authflavor_t authflavour,
+		int noresvport);
+static int nfs_init_client(struct nfs_client *clp,
+			   const struct rpc_timeout *timeparms,
+			   int noresvport);
+
 /*
  * RPC cruft for NFS
  */
@@ -482,7 +491,11 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
  * Look up a client by IP address and protocol version
  * - creates a new record if one doesn't yet exist
  */
-static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
+static struct nfs_client *nfs_get_client(struct nfs_client_initdata *cl_init,
+					 const struct rpc_timeout *timeparms,
+					 const char *ip_addr,
+					 rpc_authflavor_t authflavour,
+					 int noresvport)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
@@ -513,6 +526,17 @@ install_client:
 	clp = new;
 	list_add(&clp->cl_share_link, &nfs_client_list);
 	spin_unlock(&nfs_client_lock);
+
+	if (cl_init->rpc_ops->version == 4)
+		error = nfs4_init_client(clp, timeparms, ip_addr, authflavour,
+					 noresvport);
+	else
+		error = nfs_init_client(clp, timeparms, noresvport);
+
+	if (error < 0) {
+		nfs_put_client(clp);
+		return ERR_PTR(error);
+	}
 	dprintk("--> nfs_get_client() = %p [new]\n", clp);
 	return clp;
 
@@ -771,7 +795,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
  */
 static int nfs_init_client(struct nfs_client *clp,
 			   const struct rpc_timeout *timeparms,
-			   const struct nfs_parsed_mount_data *data)
+			   int noresvport)
 {
 	int error;
 
@@ -786,7 +810,7 @@ static int nfs_init_client(struct nfs_client *clp,
 	 * - RFC 2623, sec 2.3.2
 	 */
 	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
-				      0, data->flags & NFS_MOUNT_NORESVPORT);
+				      0, noresvport);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -822,19 +846,17 @@ static int nfs_init_server(struct nfs_server *server,
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
@@ -1313,7 +1335,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 		const struct rpc_timeout *timeparms,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
-		int flags)
+		int noresvport)
 {
 	int error;
 
@@ -1327,7 +1349,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	clp->rpc_ops = &nfs_v4_clientops;
 
 	error = nfs_create_rpc_client(clp, timeparms, authflavour,
-				      1, flags & NFS_MOUNT_NORESVPORT);
+				      1, noresvport);
 	if (error < 0)
 		goto error;
 	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
@@ -1380,22 +1402,16 @@ int nfs4_set_client(struct nfs_server *server,
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
@@ -1614,6 +1630,16 @@ error:
 	return ERR_PTR(error);
 }
 
+#else /* CONFIG_NFS_V4 */
+static int nfs4_init_client(struct nfs_client *clp,
+			    const struct rpc_timeout *timeparms,
+			    const char *ip_addr,
+			    rpc_authflavor_t authflavour,
+			    int noresvport)
+{
+	return -EPROTONOSUPPORT;
+}
+
 #endif /* CONFIG_NFS_V4 */
 
 /*
-- 
1.6.6

