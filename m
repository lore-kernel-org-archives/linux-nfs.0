Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:42320 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab2GIPpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2012 11:45:40 -0400
Received: by ghrr11 with SMTP id r11so10209954ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2012 08:45:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/14] NFS: Clean up debugging messages in fs/nfs/client.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 Jul 2012 11:45:38 -0400
Message-ID: <20120709154537.1604.14339.stgit@degas.1015granger.net>
In-Reply-To: <20120709153355.1604.14102.stgit@degas.1015granger.net>
References: <20120709153355.1604.14102.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |   43 +++++++++++++++++++++++++++++++++++++------
 fs/nfs/idmap.c  |    6 ++++++
 2 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ea1e423..47ac301 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -61,6 +61,9 @@ static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 /*
  * Get a unique NFSv4.0 callback identifier which will be used
  * by the V4.0 callback service to lookup the nfs_client struct
+ *
+ * Note: A return of zero means no ident was allocated, and thus
+ *       none should be released when "clp" is destroyed.
  */
 static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 {
@@ -70,13 +73,18 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 	if (clp->rpc_ops->version != 4 || minorversion != 0)
 		return ret;
 retry:
-	if (!idr_pre_get(&nn->cb_ident_idr, GFP_KERNEL))
+	if (!idr_pre_get(&nn->cb_ident_idr, GFP_KERNEL)) {
+		dprintk("NFS: %s idr_pre_get failed\n", __func__);
 		return -ENOMEM;
+	}
 	spin_lock(&nn->nfs_client_lock);
 	ret = idr_get_new(&nn->cb_ident_idr, clp, &clp->cl_cb_ident);
 	spin_unlock(&nn->nfs_client_lock);
 	if (ret == -EAGAIN)
 		goto retry;
+
+	dprintk("NFS: %s nfs_client %p gets callback ident %d\n",
+		__func__, clp, ret);
 	return ret;
 }
 #endif /* CONFIG_NFS_V4 */
@@ -194,6 +202,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 		clp->cl_machine_cred = cred;
 	nfs_fscache_get_client_cookie(clp);
 
+	dprintk("NFS: %s returning new nfs_client = %p ({1})\n",
+		__func__, clp);
 	return clp;
 
 error_cleanup:
@@ -255,8 +265,11 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 {
 	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 
-	if (clp->cl_cb_ident)
+	if (clp->cl_cb_ident) {
 		idr_remove(&nn->cb_ident_idr, clp->cl_cb_ident);
+		dprintk("NFS: %s removed ident %d for nfs_client %p\n",
+			__func__, clp->cl_cb_ident, clp);
+	}
 }
 
 static void pnfs_init_server(struct nfs_server *server)
@@ -293,7 +306,7 @@ static void pnfs_init_server(struct nfs_server *server)
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
-	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
+	dprintk("--> %s destroying nfs_client = %p\n", __func__, clp);
 
 	nfs4_shutdown_client(clp);
 
@@ -310,7 +323,7 @@ static void nfs_free_client(struct nfs_client *clp)
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
-	dprintk("<-- nfs_free_client()\n");
+	dprintk("<-- %s done\n", __func__);
 }
 
 /*
@@ -323,7 +336,8 @@ void nfs_put_client(struct nfs_client *clp)
 	if (!clp)
 		return;
 
-	dprintk("--> nfs_put_client({%d})\n", atomic_read(&clp->cl_count));
+	dprintk("--> %s nfs_client = %p ({%d})\n",
+		__func__, clp, atomic_read(&clp->cl_count));
 	nn = net_generic(clp->cl_net, nfs_net_id);
 
 	if (atomic_dec_and_lock(&clp->cl_count, &nn->nfs_client_lock)) {
@@ -504,6 +518,8 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		atomic_inc(&clp->cl_count);
+		dprintk("%s nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
 		return clp;
 	}
 	return NULL;
@@ -1461,11 +1477,21 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
 	struct nfs_client *clp;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
+	dprintk("NFS: --> %s looking for %d in net %p\n",
+		__func__, cb_ident, net);
+
 	spin_lock(&nn->nfs_client_lock);
 	clp = idr_find(&nn->cb_ident_idr, cb_ident);
-	if (clp)
+	if (clp) {
 		atomic_inc(&clp->cl_count);
+	}
 	spin_unlock(&nn->nfs_client_lock);
+
+	if (clp)
+		dprintk("NFS: <-- %s found nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
+	else
+		dprintk("NFS: <-- %s no matching cb_ident\n", __func__);
 	return clp;
 }
 
@@ -1498,6 +1524,8 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 			continue;
 
 		atomic_inc(&clp->cl_count);
+		dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
 		spin_unlock(&nn->nfs_client_lock);
 		return clp;
 	}
@@ -2008,6 +2036,9 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	server->nfs_client = source->nfs_client;
 	server->destroy = source->destroy;
 	atomic_inc(&server->nfs_client->cl_count);
+	dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
+		__func__, server->nfs_client,
+		atomic_read(&server->nfs_client->cl_count));
 	nfs_server_copy_userdata(server, source);
 
 	server->fsid = fattr->fsid;
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 864c51e..d8a0856 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -50,6 +50,8 @@
 #include "internal.h"
 #include "netns.h"
 
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
 #define NFS_UINT_MAXLEN 11
 
 /* Default cache timeout is 10 minutes */
@@ -559,6 +561,8 @@ restart:
 		    ((event == RPC_PIPEFS_UMOUNT) && !cl_dentry))
 			continue;
 		atomic_inc(&clp->cl_count);
+		dprintk("NFS: <-- %s returning nfs_client = %p ({%d})\n",
+			__func__, clp, atomic_read(&clp->cl_count));
 		spin_unlock(&nn->nfs_client_lock);
 		return clp;
 	}
@@ -573,6 +577,8 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
 	struct nfs_client *clp;
 	int error = 0;
 
+	dprintk("%s\n", __func__);
+
 	if (!try_module_get(THIS_MODULE))
 		return 0;
 

