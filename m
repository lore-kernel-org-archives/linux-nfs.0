Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41488 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932105AbdDGSPy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:54 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/34] NFS: Clean up extra dprintk()s in client.c
Date: Fri, 7 Apr 2017 14:15:06 -0400
Message-ID: <20170407181528.2832-13-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/client.c | 45 +++------------------------------------------
 1 file changed, 3 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 675142189181..3ffbffe8f39f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -240,8 +240,6 @@ static void pnfs_init_server(struct nfs_server *server)
  */
 void nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
-
 	nfs_fscache_release_client_cookie(clp);
 
 	/* -EIO all pending I/O */
@@ -256,8 +254,6 @@ void nfs_free_client(struct nfs_client *clp)
 	kfree(clp->cl_hostname);
 	kfree(clp->cl_acceptor);
 	kfree(clp);
-
-	dprintk("<-- nfs_free_client()\n");
 }
 EXPORT_SYMBOL_GPL(nfs_free_client);
 
@@ -271,7 +267,6 @@ void nfs_put_client(struct nfs_client *clp)
 	if (!clp)
 		return;
 
-	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
 	nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
@@ -382,9 +377,6 @@ nfs_found_client(const struct nfs_client_initdata *cl_init,
 	}
 
 	smp_rmb();
-
-	dprintk("<-- %s found nfs_client %p for %s\n",
-		__func__, clp, cl_init->hostname ?: "");
 	return clp;
 }
 
@@ -403,9 +395,6 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 		return NULL;
 	}
 
-	dprintk("--> nfs_get_client(%s,v%u)\n",
-		cl_init->hostname, rpc_ops->version);
-
 	/* see if the client already exists */
 	do {
 		spin_lock(&nn->nfs_client_lock);
@@ -430,8 +419,6 @@ struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_init)
 		new = rpc_ops->alloc_client(cl_init);
 	} while (!IS_ERR(new));
 
-	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
-		cl_init->hostname, PTR_ERR(new));
 	return new;
 }
 EXPORT_SYMBOL_GPL(nfs_get_client);
@@ -662,8 +649,6 @@ static int nfs_init_server(struct nfs_server *server,
 	struct nfs_client *clp;
 	int error;
 
-	dprintk("--> nfs_init_server()\n");
-
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
 	if (data->flags & NFS_MOUNT_NORESVPORT)
@@ -671,10 +656,8 @@ static int nfs_init_server(struct nfs_server *server,
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init);
-	if (IS_ERR(clp)) {
-		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
+	if (IS_ERR(clp))
 		return PTR_ERR(clp);
-	}
 
 	server->nfs_client = clp;
 
@@ -719,13 +702,11 @@ static int nfs_init_server(struct nfs_server *server,
 	server->mountd_protocol = data->mount_server.protocol;
 
 	server->namelen  = data->namlen;
-	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
 error:
 	server->nfs_client = NULL;
 	nfs_put_client(clp);
-	dprintk("<-- nfs_init_server() = xerror %d\n", error);
 	return error;
 }
 
@@ -795,12 +776,10 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 	struct nfs_client *clp = server->nfs_client;
 	int error;
 
-	dprintk("--> nfs_probe_fsinfo()\n");
-
 	if (clp->rpc_ops->set_capabilities != NULL) {
 		error = clp->rpc_ops->set_capabilities(server, mntfh);
 		if (error < 0)
-			goto out_error;
+			return error;
 	}
 
 	fsinfo.fattr = fattr;
@@ -808,7 +787,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 	memset(fsinfo.layouttype, 0, sizeof(fsinfo.layouttype));
 	error = clp->rpc_ops->fsinfo(server, mntfh, &fsinfo);
 	if (error < 0)
-		goto out_error;
+		return error;
 
 	nfs_server_set_fsinfo(server, &fsinfo);
 
@@ -823,12 +802,7 @@ int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs
 			server->namelen = pathinfo.max_namelen;
 	}
 
-	dprintk("<-- nfs_probe_fsinfo() = 0\n");
 	return 0;
-
-out_error:
-	dprintk("nfs_probe_fsinfo: error = %d\n", -error);
-	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_probe_fsinfo);
 
@@ -930,8 +904,6 @@ EXPORT_SYMBOL_GPL(nfs_alloc_server);
  */
 void nfs_free_server(struct nfs_server *server)
 {
-	dprintk("--> nfs_free_server()\n");
-
 	nfs_server_remove_lists(server);
 
 	if (server->destroy != NULL)
@@ -950,7 +922,6 @@ void nfs_free_server(struct nfs_server *server)
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
-	dprintk("<-- nfs_free_server()\n");
 }
 EXPORT_SYMBOL_GPL(nfs_free_server);
 
@@ -1030,10 +1001,6 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	struct nfs_fattr *fattr_fsinfo;
 	int error;
 
-	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
-		(unsigned long long) fattr->fsid.major,
-		(unsigned long long) fattr->fsid.minor);
-
 	server = nfs_alloc_server();
 	if (!server)
 		return ERR_PTR(-ENOMEM);
@@ -1065,10 +1032,6 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
 		server->namelen = NFS4_MAXNAMLEN;
 
-	dprintk("Cloned FSID: %llx:%llx\n",
-		(unsigned long long) server->fsid.major,
-		(unsigned long long) server->fsid.minor);
-
 	error = nfs_start_lockd(server);
 	if (error < 0)
 		goto out_free_server;
@@ -1077,13 +1040,11 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	server->mount_time = jiffies;
 
 	nfs_free_fattr(fattr_fsinfo);
-	dprintk("<-- nfs_clone_server() = %p\n", server);
 	return server;
 
 out_free_server:
 	nfs_free_fattr(fattr_fsinfo);
 	nfs_free_server(server);
-	dprintk("<-- nfs_clone_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(nfs_clone_server);
-- 
2.12.2

