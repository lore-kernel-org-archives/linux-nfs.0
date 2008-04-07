From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: hold BKL when clearing nfs_callback_info.task
Date: Mon,  7 Apr 2008 09:38:33 -0400
Message-ID: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
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

The global task pointers for the nfs4 callback thread is normally
protected by the nfs_callback_mutex. The exception is when the thread
exits abnormally. When this occurs, this variable is cleared without any
locking.

Make sure that this variable is cleared while still holding the BKL.

Also, there's no reason that nfs_callback_up and nfs_callback_down need
to hold the BKL while trying to lock nfs_callback_mutex. Reverse the
lock order as a micro-optimization.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 2e5de77..2646724 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -84,8 +84,8 @@ nfs_callback_svc(void *vrqstp)
 		}
 		svc_process(rqstp);
 	}
-	unlock_kernel();
 	nfs_callback_info.task = NULL;
+	unlock_kernel();
 	svc_exit_thread(rqstp);
 	return 0;
 }
@@ -99,8 +99,8 @@ int nfs_callback_up(void)
 	struct svc_rqst *rqstp;
 	int ret = 0;
 
-	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
+	lock_kernel();
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
 	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, NULL);
@@ -142,8 +142,8 @@ out:
 	 */
 	if (serv)
 		svc_destroy(serv);
-	mutex_unlock(&nfs_callback_mutex);
 	unlock_kernel();
+	mutex_unlock(&nfs_callback_mutex);
 	return ret;
 out_err:
 	dprintk("Couldn't create callback socket or server thread; err = %d\n",
@@ -157,13 +157,13 @@ out_err:
  */
 void nfs_callback_down(void)
 {
-	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
+	lock_kernel();
 	nfs_callback_info.users--;
 	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL)
 		kthread_stop(nfs_callback_info.task);
-	mutex_unlock(&nfs_callback_mutex);
 	unlock_kernel();
+	mutex_unlock(&nfs_callback_mutex);
 }
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
-- 
1.5.4.1
