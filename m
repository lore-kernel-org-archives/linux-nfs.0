From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: fix reference counting for NFSv4 callback thread
Date: Mon, 11 Feb 2008 10:00:20 -0500
Message-ID: <1202742020-28080-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736AbYBKPA2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 10:00:28 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The reference counting for the NFSv4 callback thread stays artificially
high. When this thread comes down, it doesn't properly tear down the
svc_serv, causing a memory leak. In my testing on an older kernel on
x86_64, memory would leak out of the 8k kmalloc slab. So, we're leaking
at least a page of memory every time the thread comes down.

svc_create() creates the svc_serv with a sv_nrthreads count of 1, and
then svc_create_thread() increments that count. Whenever the callback
thread is started it has a sv_nrthreads count of 2. When coming down, it
calls svc_exit_thread() which decrements that count and if it hits 0, it
tears everything down. That never happens here since the count is always
at 2 when the thread exits.

The problem is that nfs_callback_up() should be calling svc_destroy() on
the svc_serv on both success and failure. This is how lockd_up_proto()
handles the reference counting, and doing that here fixes the leak.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bd185a5..ecc06c6 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -105,7 +105,7 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
  */
 int nfs_callback_up(void)
 {
-	struct svc_serv *serv;
+	struct svc_serv *serv = NULL;
 	int ret = 0;
 
 	lock_kernel();
@@ -122,24 +122,30 @@ int nfs_callback_up(void)
 	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
 			      SVC_SOCK_ANONYMOUS);
 	if (ret <= 0)
-		goto out_destroy;
+		goto out_err;
 	nfs_callback_tcpport = ret;
 	dprintk("Callback port = 0x%x\n", nfs_callback_tcpport);
 
 	ret = svc_create_thread(nfs_callback_svc, serv);
 	if (ret < 0)
-		goto out_destroy;
+		goto out_err;
 	nfs_callback_info.serv = serv;
 	wait_for_completion(&nfs_callback_info.started);
 out:
+	/*
+	 * svc_create creates the svc_serv with sv_nrthreads == 1, and then
+	 * svc_create_thread increments that. So we need to call svc_destroy
+	 * on both success and failure so that the refcount is 1 when the
+	 * thread exits.
+	 */
+	if (serv)
+		svc_destroy(serv);
 	mutex_unlock(&nfs_callback_mutex);
 	unlock_kernel();
 	return ret;
-out_destroy:
+out_err:
 	dprintk("Couldn't create callback socket or server thread; err = %d\n",
 		ret);
-	svc_destroy(serv);
-out_err:
 	nfs_callback_info.users--;
 	goto out;
 }
-- 
1.5.3.8

