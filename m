From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 55/85] nfs41: Refactor NFSv4 callback service
Date: Mon, 10 Nov 2008 22:27:53 +0200
Message-ID: <1226348873-9062-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59988 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbYKJU2E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:28:04 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prepare the NFSv4 callback service mechanism to understand v4.0 and v4.1
callbacks. Create a new function nfs4_callback_up() that contains the
minor version 0 specific logic.  It is invoked by nfs_callback_up().

Augment the list of arguments passed to nfs_callback_up() since it will need
to deal with minor version 1 as well.  Move the creation of the backchannel
after the rpc_client has been initialized since the rpc_xprt structure will be
needed to crated the NFSv4.1 callback.

Keep a pointer to the callback_svc that will be set
as per the minor version used.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |   62 +++++++++++++++++++++++++++++++++++++---------------
 fs/nfs/callback.h |    2 +-
 fs/nfs/client.c   |   23 ++++++++++---------
 3 files changed, 57 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index c2e9cfd..e792706 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -67,7 +67,7 @@ module_param_call(callback_tcpport, param_set_port, param_get_int,
  * This is the callback kernel thread.
  */
 static int
-nfs_callback_svc(void *vrqstp)
+nfs4_callback_svc(void *vrqstp)
 {
 	int err, preverr = 0;
 	struct svc_rqst *rqstp = vrqstp;
@@ -104,12 +104,37 @@ nfs_callback_svc(void *vrqstp)
 	return 0;
 }
 
+
+/*
+ * Prepare to bring up the NFSv4 callback service
+ */
+struct svc_rqst *
+nfs4_callback_up(struct svc_serv *serv)
+{
+	int ret;
+
+	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
+			      SVC_SOCK_ANONYMOUS);
+	if (unlikely(ret <= 0)) {
+		if (ret == 0)
+			ret = -EIO;
+		return ERR_PTR(ret);
+	}
+	nfs_callback_tcpport = ret;
+	dprintk("NFS: Callback listener port = %u (af %u)\n",
+			nfs_callback_tcpport, nfs_callback_family);
+	return svc_prepare_thread(serv, &serv->sv_pools[0]);
+}
+
 /*
  * Bring up the callback thread if it is not already up.
  */
-int nfs_callback_up(void)
+int nfs_callback_up(u32 minorversion, void *args)
 {
 	struct svc_serv *serv = NULL;
+	struct svc_rqst *rqstp;
+	int (* callback_svc)(void *vrqstp);
+	char svc_name[12];
 	int ret = 0;
 
 	mutex_lock(&nfs_callback_mutex);
@@ -117,30 +142,31 @@ int nfs_callback_up(void)
 		goto out;
 	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE,
 				nfs_callback_family, NULL);
-	ret = -ENOMEM;
-	if (!serv)
-		goto out_err;
-
-	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
-			      SVC_SOCK_ANONYMOUS);
-	if (ret <= 0)
+	if (!serv) {
+		ret = -ENOMEM;
 		goto out_err;
-	nfs_callback_tcpport = ret;
-	dprintk("NFS: Callback listener port = %u (af %u)\n",
-			nfs_callback_tcpport, nfs_callback_family);
+	}
 
-	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
-	if (IS_ERR(nfs_callback_info.rqst)) {
-		ret = PTR_ERR(nfs_callback_info.rqst);
-		nfs_callback_info.rqst = NULL;
+	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
+	 * need to monitor and control them both */
+	if (!minorversion) {
+		rqstp = nfs4_callback_up(serv);
+		callback_svc = nfs4_callback_svc;
+	} else {
+		BUG();	/* for now */
+	}
+	if (IS_ERR(rqstp)) {
+		ret = PTR_ERR(rqstp);
 		goto out_err;
 	}
 
 	svc_sock_update_bufs(serv);
 
-	nfs_callback_info.task = kthread_run(nfs_callback_svc,
+	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
+	nfs_callback_info.rqst = rqstp;
+	nfs_callback_info.task = kthread_run(callback_svc,
 					     nfs_callback_info.rqst,
-					     "nfsv4-svc");
+					     svc_name);
 	if (IS_ERR(nfs_callback_info.task)) {
 		ret = PTR_ERR(nfs_callback_info.task);
 		svc_exit_thread(nfs_callback_info.rqst);
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index bb25d21..a2b3ce4 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -63,7 +63,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getat
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
 
 #ifdef CONFIG_NFS_V4
-extern int nfs_callback_up(void);
+extern int nfs_callback_up(u32 minorversion, void *args);
 extern void nfs_callback_down(void);
 #else
 #define nfs_callback_up()	(0)
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c69424d..1c0cae9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -129,12 +129,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	clp->rpc_ops = cl_init->rpc_ops;
 
-	if (cl_init->rpc_ops->version == 4) {
-		if (nfs_callback_up() < 0)
-			goto error_2;
-		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
-	}
-
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
@@ -144,7 +138,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	if (cl_init->hostname) {
 		clp->cl_hostname = kstrdup(cl_init->hostname, GFP_KERNEL);
 		if (!clp->cl_hostname)
-			goto error_3;
+			goto error_cleanup;
 	}
 
 	INIT_LIST_HEAD(&clp->cl_superblocks);
@@ -167,10 +161,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	return clp;
 
-error_3:
-	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down();
-error_2:
+error_cleanup:
 	kfree(clp);
 error_0:
 	return NULL;
@@ -1008,6 +999,16 @@ static int nfs4_init_client(struct nfs_client *clp,
 		goto error;
 	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
 
+	/* Start the callback server */
+	error = nfs_callback_up(clp->cl_minorversion,
+		clp->cl_rpcclient->cl_xprt);
+	if (error < 0) {
+		dprintk("%s: failed to start callback. Error = %d\n",
+			__func__, error);
+		goto error;
+	}
+	__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+
 	error = nfs_idmap_new(clp);
 	if (error < 0) {
 		dprintk("%s: failed to create idmapper. Error = %d\n",
-- 
1.6.0.2

