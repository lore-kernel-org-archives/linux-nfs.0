From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: convert nfs4 callback thread to kthread API
Date: Wed, 20 Feb 2008 08:55:30 -0500
Message-ID: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

There's a general push to convert kernel threads to use the (much
cleaner) kthread API. This patch converts the NFSv4 callback kernel
thread to the kthread API. In addition to being generally cleaner this
also removes the dependency on signals when shutting down the thread.

Note that this patch depends on the recent patches to svc_recv() to
make it check kthread_should_stop() periodically. Those patches are
in Bruce's tree at the moment and are slated for 2.6.26 along with
the lockd conversion, so this conversion is probably also appropriate
for 2.6.26.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |   72 +++++++++++++++++++++++++---------------------------
 1 files changed, 35 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index ecc06c6..d13f202 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -15,6 +15,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/mutex.h>
 #include <linux/freezer.h>
+#include <linux/kthread.h>
 
 #include <net/inet_sock.h>
 
@@ -27,9 +28,7 @@
 struct nfs_callback_data {
 	unsigned int users;
 	struct svc_serv *serv;
-	pid_t pid;
-	struct completion started;
-	struct completion stopped;
+	struct task_struct *task;
 };
 
 static struct nfs_callback_data nfs_callback_info;
@@ -57,27 +56,20 @@ module_param_call(callback_tcpport, param_set_port, param_get_int,
 /*
  * This is the callback kernel thread.
  */
-static void nfs_callback_svc(struct svc_rqst *rqstp)
+static int
+nfs_callback_svc(void *vrqstp)
 {
 	int err;
+	struct svc_rqst *rqstp = vrqstp;
 
-	__module_get(THIS_MODULE);
-	lock_kernel();
-
-	nfs_callback_info.pid = current->pid;
-	daemonize("nfsv4-svc");
-	/* Process request with signals blocked, but allow SIGKILL.  */
-	allow_signal(SIGKILL);
 	set_freezable();
 
-	complete(&nfs_callback_info.started);
-
-	for(;;) {
-		if (signalled()) {
-			if (nfs_callback_info.users == 0)
-				break;
-			flush_signals(current);
-		}
+	/*
+	 * FIXME: do we really need to run this under the BKL? If so, please
+	 * add a comment about what it's intended to protect.
+	 */
+	lock_kernel();
+	while (!kthread_should_stop()) {
 		/*
 		 * Listen for a request on the socket
 		 */
@@ -92,12 +84,10 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
 		}
 		svc_process(rqstp);
 	}
-
-	svc_exit_thread(rqstp);
-	nfs_callback_info.pid = 0;
-	complete(&nfs_callback_info.stopped);
 	unlock_kernel();
-	module_put_and_exit(0);
+	nfs_callback_info.task = NULL;
+	svc_exit_thread(rqstp);
+	return 0;
 }
 
 /*
@@ -106,14 +96,13 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
 int nfs_callback_up(void)
 {
 	struct svc_serv *serv = NULL;
+	struct svc_rqst *rqstp;
 	int ret = 0;
 
 	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
-	if (nfs_callback_info.users++ || nfs_callback_info.pid != 0)
+	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
-	init_completion(&nfs_callback_info.started);
-	init_completion(&nfs_callback_info.stopped);
 	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
 	ret = -ENOMEM;
 	if (!serv)
@@ -126,15 +115,28 @@ int nfs_callback_up(void)
 	nfs_callback_tcpport = ret;
 	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
 
-	ret = svc_create_thread(nfs_callback_svc, serv);
-	if (ret < 0)
+	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
+	if (IS_ERR(rqstp)) {
+		ret = PTR_ERR(rqstp);
 		goto out_err;
+	}
+
+	svc_sock_update_bufs(serv);
 	nfs_callback_info.serv = serv;
-	wait_for_completion(&nfs_callback_info.started);
+
+	nfs_callback_info.task = kthread_run(nfs_callback_svc, rqstp,
+					     "nfsv4-svc");
+	if (IS_ERR(nfs_callback_info.task)) {
+		ret = PTR_ERR(nfs_callback_info.task);
+		nfs_callback_info.serv = NULL;
+		nfs_callback_info.task = NULL;
+		svc_exit_thread(rqstp);
+		goto out_err;
+	}
 out:
 	/*
 	 * svc_create creates the svc_serv with sv_nrthreads == 1, and then
-	 * svc_create_thread increments that. So we need to call svc_destroy
+	 * svc_prepare_thread increments that. So we need to call svc_destroy
 	 * on both success and failure so that the refcount is 1 when the
 	 * thread exits.
 	 */
@@ -158,12 +160,8 @@ void nfs_callback_down(void)
 	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
 	nfs_callback_info.users--;
-	do {
-		if (nfs_callback_info.users != 0 || nfs_callback_info.pid == 0)
-			break;
-		if (kill_proc(nfs_callback_info.pid, SIGKILL, 1) < 0)
-			break;
-	} while (wait_for_completion_timeout(&nfs_callback_info.stopped, 5*HZ) == 0);
+	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL)
+		kthread_stop(nfs_callback_info.task);
 	mutex_unlock(&nfs_callback_mutex);
 	unlock_kernel();
 }
-- 
1.5.3.8
