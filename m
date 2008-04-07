From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NLM: hold BKL when clearing global lockd task and serv vars
Date: Mon,  7 Apr 2008 09:38:34 -0400
Message-ID: <1207575514-6703-2-git-send-email-jlayton@redhat.com>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
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

The global task and serv pointers for lockd are normally protected by
the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
this occurs, these variables are cleared without any locking.

Make sure that these variables are cleared while still holding the BKL,
and have lockd_up and lockd_down take the BKL.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 66b5c98..efba919 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -191,12 +191,11 @@ lockd(void *vrqstp)
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
-
-	unlock_kernel();
-
 	nlmsvc_task = NULL;
 	nlmsvc_serv = NULL;
 
+	unlock_kernel();
+
 	/* Exit the RPC thread */
 	svc_exit_thread(rqstp);
 
@@ -250,6 +249,7 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	int		error = 0;
 
 	mutex_lock(&nlmsvc_mutex);
+	lock_kernel();
 	/*
 	 * Check whether we're already up and running.
 	 */
@@ -312,6 +312,7 @@ destroy_and_out:
 out:
 	if (!error)
 		nlmsvc_users++;
+	unlock_kernel();
 	mutex_unlock(&nlmsvc_mutex);
 	return error;
 }
@@ -324,6 +325,7 @@ void
 lockd_down(void)
 {
 	mutex_lock(&nlmsvc_mutex);
+	lock_kernel();
 	if (nlmsvc_users) {
 		if (--nlmsvc_users)
 			goto out;
@@ -339,6 +341,7 @@ lockd_down(void)
 	}
 	kthread_stop(nlmsvc_task);
 out:
+	unlock_kernel();
 	mutex_unlock(&nlmsvc_mutex);
 }
 EXPORT_SYMBOL(lockd_down);
-- 
1.5.4.1
