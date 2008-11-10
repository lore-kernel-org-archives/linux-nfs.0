From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 72/85] nfs41: Allow NFSv4 and NFSv4.1 callback services to coexist
Date: Mon, 10 Nov 2008 22:31:04 +0200
Message-ID: <1226349064-9633-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60059 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbYKJUbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:31:11 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Tracks the nfs_callback_info for both versions, enabling the callback
service for v4 and v4.1 to run concurrently and be stopped independently
of each other.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |   50 ++++++++++++++++++++++++--------------------------
 fs/nfs/callback.h |    7 ++-----
 fs/nfs/client.c   |    4 +++-
 3 files changed, 29 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 036d66a..ff9ce3e 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -35,7 +35,7 @@ struct nfs_callback_data {
 	struct task_struct *task;
 };
 
-static struct nfs_callback_data nfs_callback_info;
+static struct nfs_callback_data nfs_callback_info[NFS4_MAX_MINOR_VERSION + 1];
 static DEFINE_MUTEX(nfs_callback_mutex);
 static struct svc_program nfs4_callback_program;
 
@@ -68,7 +68,7 @@ module_param_call(callback_tcpport, param_set_port, param_get_int,
 		 &nfs_callback_set_tcpport, 0644);
 
 /*
- * This is the callback kernel thread.
+ * This is the NFSv4 callback kernel thread.
  */
 static int
 nfs4_callback_svc(void *vrqstp)
@@ -169,8 +169,6 @@ nfs41_callback_svc(void *vrqstp)
 		finish_wait(&serv->sv_cb_waitq, &wq);
 	}
 	unlock_kernel();
-	nfs_callback_info.task = NULL;
-	svc_exit_thread(rqstp);
 	return 0;
 }
 
@@ -216,6 +214,7 @@ int nfs_callback_up(u32 minorversion, void *args)
 	struct svc_serv *serv = NULL;
 	struct svc_rqst *rqst;
 	int (* callback_svc)(void *vrqstp);
+	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 	char svc_name[12];
 	int ret = 0;
 #if defined(CONFIG_NFS_V4_1)
@@ -223,10 +222,10 @@ int nfs_callback_up(u32 minorversion, void *args)
 #endif /* CONFIG_NFS_V4_1 */
 
 	mutex_lock(&nfs_callback_mutex);
-	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL) {
+	if (cb_info->users++ || cb_info->task != NULL) {
 #if defined(CONFIG_NFS_V4_1)
 		if (minorversion)
-			xprt->bc_serv = nfs_callback_info.serv;
+			xprt->bc_serv = cb_info->serv;
 #endif /* CONFIG_NFS_V4_1 */
 		goto out;
 	}
@@ -258,17 +257,14 @@ int nfs_callback_up(u32 minorversion, void *args)
 	svc_sock_update_bufs(serv);
 
 	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
-	nfs_callback_info.serv = serv;
-	nfs_callback_info.rqst = rqst;
-	nfs_callback_info.task = kthread_run(callback_svc,
-					     nfs_callback_info.rqst,
-					     svc_name);
-	if (IS_ERR(nfs_callback_info.task)) {
-		ret = PTR_ERR(nfs_callback_info.task);
-		svc_exit_thread(nfs_callback_info.rqst);
-		nfs_callback_info.serv = NULL;
-		nfs_callback_info.rqst = NULL;
-		nfs_callback_info.task = NULL;
+	cb_info->serv = serv;
+	cb_info->rqst = rqst;
+	cb_info->task = kthread_run(callback_svc, cb_info->rqst, svc_name);
+	if (IS_ERR(cb_info->task)) {
+		ret = PTR_ERR(cb_info->task);
+		svc_exit_thread(cb_info->rqst);
+		cb_info->rqst = NULL;
+		cb_info->task = NULL;
 		goto out_err;
 	}
 out:
@@ -285,23 +281,25 @@ out:
 out_err:
 	dprintk("NFS: Couldn't create callback socket or server thread; "
 		"err = %d\n", ret);
-	nfs_callback_info.users--;
+	cb_info->users--;
 	goto out;
 }
 
 /*
  * Kill the callback thread if it's no longer being used.
  */
-void nfs_callback_down(void)
+void nfs_callback_down(int minorversion)
 {
+	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
+
 	mutex_lock(&nfs_callback_mutex);
-	nfs_callback_info.users--;
-	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL) {
-		kthread_stop(nfs_callback_info.task);
-		svc_exit_thread(nfs_callback_info.rqst);
-		nfs_callback_info.serv = NULL;
-		nfs_callback_info.rqst = NULL;
-		nfs_callback_info.task = NULL;
+	cb_info->users--;
+	if (cb_info->users == 0 && cb_info->task != NULL) {
+		kthread_stop(cb_info->task);
+		svc_exit_thread(cb_info->rqst);
+		cb_info->serv = NULL;
+		cb_info->rqst = NULL;
+		cb_info->task = NULL;
 	}
 	mutex_unlock(&nfs_callback_mutex);
 }
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 49ea368..4c69b27 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -64,11 +64,8 @@ extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy);
 
 #ifdef CONFIG_NFS_V4
 extern int nfs_callback_up(u32 minorversion, void *args);
-extern void nfs_callback_down(void);
-#else
-#define nfs_callback_up()	(0)
-#define nfs_callback_down()	do {} while(0)
-#endif
+extern void nfs_callback_down(int minorversion);
+#endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_V4_1
 /*
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1c0cae9..dc5b6e7 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -193,8 +193,10 @@ static void nfs_free_client(struct nfs_client *clp)
 	if (!IS_ERR(clp->cl_rpcclient))
 		rpc_shutdown_client(clp->cl_rpcclient);
 
+#ifdef CONFIG_NFS_V4
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down();
+		nfs_callback_down(clp->cl_minorversion);
+#endif /* CONFIG_NFS_V4 */
 
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
-- 
1.6.0.2

