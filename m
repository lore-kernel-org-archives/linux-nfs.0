From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] knfsd: Replace lock_kernel with a mutex for nfsd thread
	startup/shutdown locking.
Date: Fri,  6 Jun 2008 11:12:47 -0400
Message-ID: <1212765171-26042-2-git-send-email-jlayton@redhat.com>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, gnb@melbourne.sgi.com
To: bfields@fieldses.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1212765171-26042-1-git-send-email-jlayton@redhat.com>
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

From: Neil Brown <neilb@suse.de>

This removes the BKL from the RPC service creation codepath. The BKL
really isn't adequate for this job since some of this info needs
protection across sleeps.

Also, add some comments to try and clarify how the locking should work
and to make it clear that the BKL isn't necessary as long as there is
adequate locking between tasks when touching the svc_serv fields.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfsctl.c          |   37 +++++++++++++++++++++++--------------
 fs/nfsd/nfssvc.c          |   45 ++++++++++++++++++++++++++++++++-------------
 include/linux/nfsd/nfsd.h |    1 +
 net/sunrpc/svc.c          |   15 +++++++++------
 4 files changed, 65 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5ac00c4..049d2a9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -450,22 +450,26 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	int i;
 	int rv;
 	int len;
-    	int npools = nfsd_nrpools();
+	int npools;
 	int *nthreads;
 
+	mutex_lock(&nfsd_mutex);
+	npools = nfsd_nrpools();
 	if (npools == 0) {
 		/*
 		 * NFS is shut down.  The admin can start it by
 		 * writing to the threads file but NOT the pool_threads
 		 * file, sorry.  Report zero threads.
 		 */
+		mutex_unlock(&nfsd_mutex);
 		strcpy(buf, "0\n");
 		return strlen(buf);
 	}
 
 	nthreads = kcalloc(npools, sizeof(int), GFP_KERNEL);
+	rv = -ENOMEM;
 	if (nthreads == NULL)
-		return -ENOMEM;
+		goto out_free;
 
 	if (size > 0) {
 		for (i = 0; i < npools; i++) {
@@ -496,10 +500,12 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 		mesg += len;
 	}
 
+	mutex_unlock(&nfsd_mutex);
 	return (mesg-buf);
 
 out_free:
 	kfree(nthreads);
+	mutex_unlock(&nfsd_mutex);
 	return rv;
 }
 
@@ -566,14 +572,13 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 	return len;
 }
 
-static ssize_t write_ports(struct file *file, char *buf, size_t size)
+static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 {
 	if (size == 0) {
 		int len = 0;
-		lock_kernel();
+
 		if (nfsd_serv)
 			len = svc_xprt_names(nfsd_serv, buf, 0);
-		unlock_kernel();
 		return len;
 	}
 	/* Either a single 'fd' number is written, in which
@@ -603,9 +608,7 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 			/* Decrease the count, but don't shutdown the
 			 * the service
 			 */
-			lock_kernel();
 			nfsd_serv->sv_nrthreads--;
-			unlock_kernel();
 		}
 		return err < 0 ? err : 0;
 	}
@@ -614,10 +617,8 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		int len = 0;
 		if (!toclose)
 			return -ENOMEM;
-		lock_kernel();
 		if (nfsd_serv)
 			len = svc_sock_names(buf, nfsd_serv, toclose);
-		unlock_kernel();
 		if (len >= 0)
 			lockd_down();
 		kfree(toclose);
@@ -655,7 +656,6 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
 			if (port == 0)
 				return -EINVAL;
-			lock_kernel();
 			if (nfsd_serv) {
 				xprt = svc_find_xprt(nfsd_serv, transport,
 						     AF_UNSPEC, port);
@@ -666,13 +666,22 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 				} else
 					err = -ENOTCONN;
 			}
-			unlock_kernel();
 			return err < 0 ? err : 0;
 		}
 	}
 	return -EINVAL;
 }
 
+static ssize_t write_ports(struct file *file, char *buf, size_t size)
+{
+	ssize_t rv;
+	mutex_lock(&nfsd_mutex);
+	rv = __write_ports(file, buf, size);
+	mutex_unlock(&nfsd_mutex);
+	return rv;
+}
+
+
 int nfsd_max_blksize;
 
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
@@ -691,13 +700,13 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 		if (bsize > NFSSVC_MAXBLKSIZE)
 			bsize = NFSSVC_MAXBLKSIZE;
 		bsize &= ~(1024-1);
-		lock_kernel();
+		mutex_lock(&nfsd_mutex);
 		if (nfsd_serv && nfsd_serv->sv_nrthreads) {
-			unlock_kernel();
+			mutex_unlock(&nfsd_mutex);
 			return -EBUSY;
 		}
 		nfsd_max_blksize = bsize;
-		unlock_kernel();
+		mutex_unlock(&nfsd_mutex);
 	}
 	return sprintf(buf, "%d\n", nfsd_max_blksize);
 }
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 941041f..512bd04 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -53,11 +53,27 @@
 extern struct svc_program	nfsd_program;
 static void			nfsd(struct svc_rqst *rqstp);
 struct timeval			nfssvc_boot;
-       struct svc_serv 		*nfsd_serv;
 static atomic_t			nfsd_busy;
 static unsigned long		nfsd_last_call;
 static DEFINE_SPINLOCK(nfsd_call_lock);
 
+/*
+ * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
+ * of the svc_serv struct. In particular, ->sv_nrthreads but also to some
+ * extent ->sv_temp_socks and ->sv_permsocks. It also protects nfsdstats.th_cnt
+ *
+ * If (out side the lock) nfsd_serv is non-NULL, then it must point to a
+ * properly initialised 'struct svc_serv' with ->sv_nrthreads > 0. That number
+ * of nfsd threads must exist and each must listed in ->sp_all_threads in each
+ * entry of ->sv_pools[].
+ *
+ * Transitions of the thread count between zero and non-zero are of particular
+ * interest since the svc_serv needs to be created and initialized at that
+ * point, or freed.
+ */
+DEFINE_MUTEX(nfsd_mutex);
+struct svc_serv 		*nfsd_serv;
+
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
 static struct svc_version *	nfsd_acl_version[] = {
@@ -190,13 +206,14 @@ void nfsd_reset_versions(void)
 	}
 }
 
+
 int nfsd_create_serv(void)
 {
 	int err = 0;
-	lock_kernel();
+
+	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
 		svc_get(nfsd_serv);
-		unlock_kernel();
 		return 0;
 	}
 	if (nfsd_max_blksize == 0) {
@@ -223,7 +240,7 @@ int nfsd_create_serv(void)
 				      nfsd, SIG_NOCLEAN, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
-	unlock_kernel();
+
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
 }
@@ -282,6 +299,8 @@ int nfsd_set_nrthreads(int n, int *nthreads)
 	int tot = 0;
 	int err = 0;
 
+	WARN_ON(!mutex_is_locked(&nfsd_mutex));
+
 	if (nfsd_serv == NULL || n <= 0)
 		return 0;
 
@@ -316,7 +335,6 @@ int nfsd_set_nrthreads(int n, int *nthreads)
 		nthreads[0] = 1;
 
 	/* apply the new numbers */
-	lock_kernel();
 	svc_get(nfsd_serv);
 	for (i = 0; i < n; i++) {
 		err = svc_set_num_threads(nfsd_serv, &nfsd_serv->sv_pools[i],
@@ -325,7 +343,6 @@ int nfsd_set_nrthreads(int n, int *nthreads)
 			break;
 	}
 	svc_destroy(nfsd_serv);
-	unlock_kernel();
 
 	return err;
 }
@@ -334,8 +351,8 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	
-	lock_kernel();
+
+	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
 	error = -EINVAL;
 	if (nrservs <= 0)
@@ -363,7 +380,7 @@ nfsd_svc(unsigned short port, int nrservs)
  failure:
 	svc_destroy(nfsd_serv);		/* Release server */
  out:
-	unlock_kernel();
+	mutex_unlock(&nfsd_mutex);
 	return error;
 }
 
@@ -399,7 +416,7 @@ nfsd(struct svc_rqst *rqstp)
 	sigset_t shutdown_mask, allowed_mask;
 
 	/* Lock module and set up kernel thread */
-	lock_kernel();
+	mutex_lock(&nfsd_mutex);
 	daemonize("nfsd");
 
 	/* After daemonize() this kernel thread shares current->fs
@@ -417,11 +434,13 @@ nfsd(struct svc_rqst *rqstp)
 	siginitsetinv(&shutdown_mask, SHUTDOWN_SIGS);
 	siginitsetinv(&allowed_mask, ALLOWED_SIGS);
 
+
 	nfsdstats.th_cnt++;
 
 	rqstp->rq_task = current;
 
-	unlock_kernel();
+	mutex_unlock(&nfsd_mutex);
+
 
 	/*
 	 * We want less throttling in balance_dirty_pages() so that nfs to
@@ -477,7 +496,7 @@ nfsd(struct svc_rqst *rqstp)
 	/* Clear signals before calling svc_exit_thread() */
 	flush_signals(current);
 
-	lock_kernel();
+	mutex_lock(&nfsd_mutex);
 
 	nfsdstats.th_cnt --;
 
@@ -486,7 +505,7 @@ out:
 	svc_exit_thread(rqstp);
 
 	/* Release module */
-	unlock_kernel();
+	mutex_unlock(&nfsd_mutex);
 	module_put_and_exit(0);
 }
 
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 41d30c9..88d85b9 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -54,6 +54,7 @@ typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
+extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
 
 extern struct seq_operations nfs_exports_op;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 01c7e31..7bffaff 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -461,7 +461,8 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 EXPORT_SYMBOL(svc_create_pooled);
 
 /*
- * Destroy an RPC service.  Should be called with the BKL held
+ * Destroy an RPC service. Should be called with appropriate locking to
+ * protect the sv_nrthreads, sv_permsocks and sv_tempsocks.
  */
 void
 svc_destroy(struct svc_serv *serv)
@@ -578,9 +579,10 @@ out_enomem:
 EXPORT_SYMBOL(svc_prepare_thread);
 
 /*
- * Create a thread in the given pool.  Caller must hold BKL.
- * On a NUMA or SMP machine, with a multi-pool serv, the thread
- * will be restricted to run on the cpus belonging to the pool.
+ * Create a thread in the given pool.  Caller must hold BKL or another lock to
+ * serialize access to the svc_serv struct. On a NUMA or SMP machine, with a
+ * multi-pool serv, the thread will be restricted to run on the cpus belonging
+ * to the pool.
  */
 static int
 __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
@@ -674,7 +676,7 @@ found_pool:
  * of threads the given number.  If `pool' is non-NULL, applies
  * only to threads in that pool, otherwise round-robins between
  * all pools.  Must be called with a svc_get() reference and
- * the BKL held.
+ * the BKL or another lock to protect access to svc_serv fields.
  *
  * Destroying threads relies on the service threads filling in
  * rqstp->rq_task, which only the nfs ones do.  Assumes the serv
@@ -722,7 +724,8 @@ svc_set_num_threads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 EXPORT_SYMBOL(svc_set_num_threads);
 
 /*
- * Called from a server thread as it's exiting.  Caller must hold BKL.
+ * Called from a server thread as it's exiting. Caller must hold the BKL or
+ * the "service mutex", whichever is appropriate for the service.
  */
 void
 svc_exit_thread(struct svc_rqst *rqstp)
-- 
1.5.3.6
