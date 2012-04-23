Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab2DWU4O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:56:14 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:56:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/20] NFS: Clean up debugging messages in fs/nfs/client.c
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:56:12 -0400
Message-ID: <20120423205612.11446.89496.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7330673..beb001b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -192,6 +192,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 		clp->cl_machine_cred = cred;
 	nfs_fscache_get_client_cookie(clp);
 
+	dprintk("NFS: %s returning new nfs_client = %p ({1})\n",
+		__func__, clp);
 	return clp;
 
 error_cleanup:
@@ -291,7 +293,7 @@ static void pnfs_init_server(struct nfs_server *server)
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
+	dprintk("--> %s destroying nfs_client = %p\n", __func__, clp);
 
 	nfs4_shutdown_client(clp);
 
@@ -308,7 +310,7 @@ static void nfs_free_client(struct nfs_client *clp)
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
-	dprintk("<-- nfs_free_client()\n");
+	dprintk("<-- %s done\n", __func__);
 }
 
 /*
@@ -321,7 +323,8 @@ void nfs_put_client(struct nfs_client *clp)
 	if (!clp)
 		return;
 
-	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
+	dprintk("--> %s nfs_client = %p ({%d})\n",
+		__func__, clp, atomic_read(&clp->cl_count));
 	nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
@@ -500,6 +503,8 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		atomic_inc(&clp->cl_count);
+		dprintk("%s nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
 		return clp;
 	}
 	return NULL;
@@ -1433,8 +1438,11 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
 
 	spin_lock(&nn->nfs_client_lock);
 	clp = idr_find(&nn->cb_ident_idr, cb_ident);
-	if (clp)
+	if (clp) {
+		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
 		atomic_inc(&clp->cl_count);
+	}
 	spin_unlock(&nn->nfs_client_lock);
 	return clp;
 }
@@ -1468,6 +1476,8 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 			continue;
 
 		atomic_inc(&clp->cl_count);
+		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
 		spin_unlock(&nn->nfs_client_lock);
 		return clp;
 	}
@@ -1978,6 +1988,9 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	server->nfs_client = source->nfs_client;
 	server->destroy = source->destroy;
 	atomic_inc(&server->nfs_client->cl_count);
+	dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+		__func__, server->nfs_client,
+		atomic_read(&server->nfs_client->cl_count));
 	nfs_server_copy_userdata(server, source);
 
 	server->fsid = fattr->fsid;

