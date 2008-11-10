From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 66/85] nfs41: Implement NFSv4.1 callback service process.
Date: Mon, 10 Nov 2008 22:30:00 +0200
Message-ID: <1226349000-9433-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60035 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbYKJUaG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:30:06 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

nfs41_callback_up() initializes the necessary queues and creates the new
nfs41_callback_svc thread.  This thread executes the callback service which
waits for requests to arrive on the svc_serv->sv_cb_list.

NFS41_BC_MIN_CALLBACKS is set to 1 because we expect callbacks to not
cause substantial latency.

The actual processing of the callback will be implemented as a separate patch.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.c          |   76 +++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/callback.h          |    8 +++++
 include/linux/sunrpc/svc.h |    2 +
 3 files changed, 85 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 2f5acd3..86f4d88 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -16,6 +16,9 @@
 #include <linux/mutex.h>
 #include <linux/freezer.h>
 #include <linux/kthread.h>
+#if defined(CONFIG_NFS_V4_1)
+#include <linux/sunrpc/bc_xprt.h>
+#endif
 
 #include <net/inet_sock.h>
 
@@ -126,6 +129,69 @@ nfs4_callback_up(struct svc_serv *serv)
 	return svc_prepare_thread(serv, &serv->sv_pools[0]);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * The callback service for NFSv4.1 callbacks
+ */
+static int
+nfs41_callback_svc(void *vrqstp)
+{
+	struct svc_rqst *rqstp = vrqstp;
+	struct svc_serv *serv = rqstp->rq_server;
+	struct rpc_rqst *req;
+	int error;
+	DEFINE_WAIT(wq);
+
+	set_freezable();
+
+	/*
+	 * FIXME: do we really need to run this under the BKL? If so, please
+	 * add a comment about what it's intended to protect.
+	 */
+	lock_kernel();
+	while (!kthread_should_stop()) {
+		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
+		spin_lock_bh(&serv->sv_cb_lock);
+		if (!list_empty(&serv->sv_cb_list)) {
+			req = list_first_entry(&serv->sv_cb_list,
+					struct rpc_rqst, rq_bc_list);
+			list_del(&req->rq_bc_list);
+			spin_unlock_bh(&serv->sv_cb_lock);
+			dprintk("Invoking bc_svc_process()\n");
+			error = bc_svc_process(serv, req, rqstp);
+			dprintk("bc_svc_process() returned w/ error code= %d\n",
+				error);
+		} else {
+			spin_unlock_bh(&serv->sv_cb_lock);
+			schedule();
+		}
+		finish_wait(&serv->sv_cb_waitq, &wq);
+	}
+	unlock_kernel();
+	nfs_callback_info.task = NULL;
+	svc_exit_thread(rqstp);
+	return 0;
+}
+
+/*
+ * Bring up the NFSv4.1 callback service
+ */
+struct svc_rqst *
+nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
+{
+	/*
+	 * Save the svc_serv in the transport so that it can
+	 * be referenced when the session backchannel is initialized
+	 */
+	xprt->bc_serv = serv;
+
+	INIT_LIST_HEAD(&serv->sv_cb_list);
+	spin_lock_init(&serv->sv_cb_lock);
+	init_waitqueue_head(&serv->sv_cb_waitq);
+	return svc_prepare_thread(serv, &serv->sv_pools[0]);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
 /*
  * Bring up the callback thread if it is not already up.
  */
@@ -136,6 +202,9 @@ int nfs_callback_up(u32 minorversion, void *args)
 	int (* callback_svc)(void *vrqstp);
 	char svc_name[12];
 	int ret = 0;
+#if defined(CONFIG_NFS_V4_1)
+	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
+#endif /* CONFIG_NFS_V4_1 */
 
 	mutex_lock(&nfs_callback_mutex);
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
@@ -153,7 +222,12 @@ int nfs_callback_up(u32 minorversion, void *args)
 		rqst = nfs4_callback_up(serv);
 		callback_svc = nfs4_callback_svc;
 	} else {
-		BUG();	/* for now */
+#if defined(CONFIG_NFS_V4_1)
+		rqst = nfs41_callback_up(serv, xprt);
+		callback_svc = nfs41_callback_svc;
+#else  /* CONFIG_NFS_V4_1 */
+		BUG();
+#endif /* CONFIG_NFS_V4_1 */
 	}
 	if (IS_ERR(rqst)) {
 		ret = PTR_ERR(rqst);
diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index a2b3ce4..49ea368 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -70,6 +70,14 @@ extern void nfs_callback_down(void);
 #define nfs_callback_down()	do {} while(0)
 #endif
 
+#ifdef CONFIG_NFS_V4_1
+/*
+ * Callbacks are expected to not cause substantial latency,
+ * so we limit their concurrency to 1.
+ */
+#define NFS41_BC_MIN_CALLBACKS 1
+#endif /* CONFIG_NFS_V4_1 */
+
 extern unsigned int nfs_callback_set_tcpport;
 extern unsigned short nfs_callback_tcpport;
 
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 1d3b971..1bb51dc 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -403,6 +403,8 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
 int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
 void		   svc_destroy(struct svc_serv *);
 int		   svc_process(struct svc_rqst *);
+int		   bc_svc_process(struct svc_serv *, struct rpc_rqst *,
+			struct svc_rqst *);
 int		   svc_register(const struct svc_serv *, const unsigned short,
 				const unsigned short);
 
-- 
1.6.0.2

