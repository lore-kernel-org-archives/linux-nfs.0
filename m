From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] lockd: close potential race with rapid
	lockd_up/lockd_down cycle
Date: Wed, 11 Jun 2008 10:03:12 -0400
Message-ID: <1213192992-7635-4-git-send-email-jlayton@redhat.com>
References: <1213192992-7635-1-git-send-email-jlayton@redhat.com>
	<1213192992-7635-2-git-send-email-jlayton@redhat.com>
	<1213192992-7635-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1213192992-7635-3-git-send-email-jlayton@redhat.com>
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

If lockd_down is called very rapidly after lockd_up returns, then
there is a slim chance that lockd() will never be called. kthread()
will return before calling the function, so we'll end up never
actually calling the cleanup functions for the thread.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 2169af4..5bd9bf0 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -50,7 +50,7 @@ EXPORT_SYMBOL(nlmsvc_ops);
 static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
 static struct task_struct	*nlmsvc_task;
-static struct svc_serv		*nlmsvc_serv;
+static struct svc_rqst		*nlmsvc_rqst;
 int				nlmsvc_grace_period;
 unsigned long			nlmsvc_timeout;
 
@@ -194,20 +194,11 @@ lockd(void *vrqstp)
 
 		svc_process(rqstp);
 	}
-
 	flush_signals(current);
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
-
 	unlock_kernel();
-
-	nlmsvc_task = NULL;
-	nlmsvc_serv = NULL;
-
-	/* Exit the RPC thread */
-	svc_exit_thread(rqstp);
-
 	return 0;
 }
 
@@ -254,16 +245,15 @@ int
 lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 {
 	struct svc_serv *serv;
-	struct svc_rqst *rqstp;
 	int		error = 0;
 
 	mutex_lock(&nlmsvc_mutex);
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_serv) {
+	if (nlmsvc_rqst) {
 		if (proto)
-			error = make_socks(nlmsvc_serv, proto);
+			error = make_socks(nlmsvc_rqst->rq_server, proto);
 		goto out;
 	}
 
@@ -288,9 +278,10 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Create the kernel thread and wait for it to start.
 	 */
-	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
-	if (IS_ERR(rqstp)) {
-		error = PTR_ERR(rqstp);
+	nlmsvc_rqst = svc_prepare_thread(serv, &serv->sv_pools[0]);
+	if (IS_ERR(nlmsvc_rqst)) {
+		error = PTR_ERR(nlmsvc_rqst);
+		nlmsvc_rqst = NULL;
 		printk(KERN_WARNING
 			"lockd_up: svc_rqst allocation failed, error=%d\n",
 			error);
@@ -298,16 +289,15 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	}
 
 	svc_sock_update_bufs(serv);
-	nlmsvc_serv = rqstp->rq_server;
 
-	nlmsvc_task = kthread_run(lockd, rqstp, serv->sv_name);
+	nlmsvc_task = kthread_run(lockd, nlmsvc_rqst, serv->sv_name);
 	if (IS_ERR(nlmsvc_task)) {
 		error = PTR_ERR(nlmsvc_task);
+		svc_exit_thread(nlmsvc_rqst);
 		nlmsvc_task = NULL;
-		nlmsvc_serv = NULL;
+		nlmsvc_rqst = NULL;
 		printk(KERN_WARNING
 			"lockd_up: kthread_run failed, error=%d\n", error);
-		svc_exit_thread(rqstp);
 		goto destroy_and_out;
 	}
 
@@ -346,6 +336,9 @@ lockd_down(void)
 		BUG();
 	}
 	kthread_stop(nlmsvc_task);
+	svc_exit_thread(nlmsvc_rqst);
+	nlmsvc_task = NULL;
+	nlmsvc_rqst = NULL;
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
-- 
1.5.3.6
