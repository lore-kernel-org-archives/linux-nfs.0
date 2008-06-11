From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] nfs4: fix potential race with rapid nfs_callback_up/down cycle
Date: Wed, 11 Jun 2008 10:03:11 -0400
Message-ID: <1213192992-7635-3-git-send-email-jlayton@redhat.com>
References: <1213192992-7635-1-git-send-email-jlayton@redhat.com>
 <1213192992-7635-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbYFKODU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 10:03:20 -0400
In-Reply-To: <1213192992-7635-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the nfsv4 callback thread is rapidly brought up and down, it's
possible that nfs_callback_svc might never get a chance to run. If
this happens, the cleanup at thread exit might never occur, throwing
the refcounting off and nfs_callback_info in an incorrect state.

Move the clean functions into nfs_callback_down. Also change the
nfs_callback_info struct to track the svc_rqst rather than svc_serv
since we need to know that to call svc_exit_thread.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |   30 ++++++++++++++++--------------
 1 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 9e713d2..f447f4b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -27,7 +27,7 @@
 
 struct nfs_callback_data {
 	unsigned int users;
-	struct svc_serv *serv;
+	struct svc_rqst *rqst;
 	struct task_struct *task;
 };
 
@@ -91,18 +91,15 @@ nfs_callback_svc(void *vrqstp)
 		svc_process(rqstp);
 	}
 	unlock_kernel();
-	nfs_callback_info.task = NULL;
-	svc_exit_thread(rqstp);
 	return 0;
 }
 
 /*
- * Bring up the server process if it is not already up.
+ * Bring up the callback thread if it is not already up.
  */
 int nfs_callback_up(void)
 {
 	struct svc_serv *serv = NULL;
-	struct svc_rqst *rqstp;
 	int ret = 0;
 
 	mutex_lock(&nfs_callback_mutex);
@@ -120,22 +117,23 @@ int nfs_callback_up(void)
 	nfs_callback_tcpport = ret;
 	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
 
-	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
-	if (IS_ERR(rqstp)) {
-		ret = PTR_ERR(rqstp);
+	nfs_callback_info.rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
+	if (IS_ERR(nfs_callback_info.rqst)) {
+		ret = PTR_ERR(nfs_callback_info.rqst);
+		nfs_callback_info.rqst = NULL;
 		goto out_err;
 	}
 
 	svc_sock_update_bufs(serv);
-	nfs_callback_info.serv = serv;
 
-	nfs_callback_info.task = kthread_run(nfs_callback_svc, rqstp,
+	nfs_callback_info.task = kthread_run(nfs_callback_svc,
+					     nfs_callback_info.rqst,
 					     "nfsv4-svc");
 	if (IS_ERR(nfs_callback_info.task)) {
 		ret = PTR_ERR(nfs_callback_info.task);
-		nfs_callback_info.serv = NULL;
+		svc_exit_thread(nfs_callback_info.rqst);
+		nfs_callback_info.rqst = NULL;
 		nfs_callback_info.task = NULL;
-		svc_exit_thread(rqstp);
 		goto out_err;
 	}
 out:
@@ -157,14 +155,18 @@ out_err:
 }
 
 /*
- * Kill the server process if it is not already down.
+ * Kill the callback thread if it's no longer being used.
  */
 void nfs_callback_down(void)
 {
 	mutex_lock(&nfs_callback_mutex);
 	nfs_callback_info.users--;
-	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL)
+	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL) {
 		kthread_stop(nfs_callback_info.task);
+		svc_exit_thread(nfs_callback_info.rqst);
+		nfs_callback_info.rqst = NULL;
+		nfs_callback_info.task = NULL;
+	}
 	mutex_unlock(&nfs_callback_mutex);
 }
 
-- 
1.5.3.6

