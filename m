From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 19/39] nfs41: Allow NFSv4 and NFSv4.1 callback services to coexist
Date: Fri,  1 May 2009 02:22:20 +0300
Message-ID: <1241133740-922-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12024 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754367AbZD3XW2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:28 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Tracks the nfs_callback_info for both versions, enabling the callback
service for v4 and v4.1 to run concurrently and be stopped independently
of each other.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c |   50 ++++++++++++++++++++++++--------------------------
 fs/nfs/callback.h |    7 ++-----
 fs/nfs/client.c   |    2 +-
 3 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 4bf60b2..972e38b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -36,7 +36,7 @@ struct nfs_callback_data {
 	struct task_struct *task;
 };
 
-static struct nfs_callback_data nfs_callback_info;
+static struct nfs_callback_data nfs_callback_info[NFS4_MAX_MINOR_VERSION + 1];
 static DEFINE_MUTEX(nfs_callback_mutex);
 static struct svc_program nfs4_callback_program;
 
@@ -60,7 +60,7 @@ module_param_call(callback_tcpport, param_set_port, param_get_int,
 		 &nfs_callback_set_tcpport, 0644);
 
 /*
- * This is the callback kernel thread.
+ * This is the NFSv4 callback kernel thread.
  */
 static int
 nfs4_callback_svc(void *vrqstp)
@@ -174,8 +174,6 @@ nfs41_callback_svc(void *vrqstp)
 		finish_wait(&serv->sv_cb_waitq, &wq);
 	}
 	unlock_kernel();
-	nfs_callback_info.task = NULL;
-	svc_exit_thread(rqstp);
 	return 0;
 }
 
@@ -221,6 +219,7 @@ int nfs_callback_up(u32 minorversion, void *args)
 	struct svc_serv *serv = NULL;
 	struct svc_rqst *rqstp;
 	int (*callback_svc)(void *vrqstp);
+	struct nfs_callback_data *cb_info = &nfs_callback_info[minorversion];
 	char svc_name[12];
 	int ret = 0;
 #if defined(CONFIG_NFS_V4_1)
@@ -228,10 +227,10 @@ int nfs_callback_up(u32 minorversion, void *args)
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
@@ -263,17 +262,14 @@ int nfs_callback_up(u32 minorversion, void *args)
 	svc_sock_update_bufs(serv);
 
 	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
-	nfs_callback_info.serv = serv;
-	nfs_callback_info.rqst = rqstp;
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
+	cb_info->rqst = rqstp;
+	cb_info->task = kthread_run(callback_svc, cb_info->rqst, svc_name);
+	if (IS_ERR(cb_info->task)) {
+		ret = PTR_ERR(cb_info->task);
+		svc_exit_thread(cb_info->rqst);
+		cb_info->rqst = NULL;
+		cb_info->task = NULL;
 		goto out_err;
 	}
 out:
@@ -290,23 +286,25 @@ out:
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
index f2696ba..ed52e06 100644
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
 
 /*
  * nfs41: Callbacks are expected to not cause substantial latency,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index df2b40d..ac6575c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -181,7 +181,7 @@ static void nfs4_destroy_callback(struct nfs_client *clp)
 {
 #ifdef CONFIG_NFS_V4
 	if (__test_and_clear_bit(NFS_CS_CALLBACK, &clp->cl_res_state))
-		nfs_callback_down();
+		nfs_callback_down(clp->cl_minorversion);
 #endif /* CONFIG_NFS_V4 */
 }
 
-- 
1.6.2.1

