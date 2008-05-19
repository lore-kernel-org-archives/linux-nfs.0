From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and
	remove	signaling for shutdown
Date: Tue, 20 May 2008 09:52:14 +1000
Message-ID: <18482.4782.858347.981553@notabene.brown>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: message from Greg Banks on Monday May 19
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

On Monday May 19, gnb@melbourne.sgi.com wrote:
> I think we also need to protect those against svc_create_pooled(). I
> tried this a few weeks back in an attempt to deal with a customer's
> problem, but gave up in disgust when the obvious changes resulted in the
> nfsds self-deadlocking during startup.  The svc_serv was being created
> as a side effect of the first write to a /proc/fs/nfsd/ file, and the
> locking was very very confused.  I think it would be great if you gave
> that code some care and attention.

What was confused???

Here is a quick-and-dirty conversion to mutexs.  It starts and stops
threads without any deadlocking or lockdep warnings.  I haven't tried
to synthesise any races so I cannot promise it is perfect, but it
feels close at least.

You are correct of course, svc_create_pooled is one of the bits that
needs protection.

NeilBrown


Replace lock_kernel with a mutex for nfsd thread startup/shutdown locking.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c |   39 +++++++++++++++++++++++++--------------
 ./fs/nfsd/nfssvc.c |   28 ++++++++++++++++------------
 2 files changed, 41 insertions(+), 26 deletions(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2008-05-20 09:49:52.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2008-05-20 09:50:25.000000000 +1000
@@ -441,6 +441,8 @@ static ssize_t write_threads(struct file
 	return strlen(buf);
 }
 
+extern struct mutex nfsd_mutex;
+
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 {
 	/* if size > 0, look for an array of number of threads per node
@@ -450,22 +452,26 @@ static ssize_t write_pool_threads(struct
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
@@ -496,10 +502,12 @@ static ssize_t write_pool_threads(struct
 		mesg += len;
 	}
 
+	mutex_unlock(&nfsd_mutex);
 	return (mesg-buf);
 
 out_free:
 	kfree(nthreads);
+	mutex_unlock(&nfsd_mutex);
 	return rv;
 }
 
@@ -566,14 +574,13 @@ static ssize_t write_versions(struct fil
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
@@ -603,9 +610,7 @@ static ssize_t write_ports(struct file *
 			/* Decrease the count, but don't shutdown the
 			 * the service
 			 */
-			lock_kernel();
 			nfsd_serv->sv_nrthreads--;
-			unlock_kernel();
 		}
 		return err < 0 ? err : 0;
 	}
@@ -614,10 +619,8 @@ static ssize_t write_ports(struct file *
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
@@ -655,7 +658,6 @@ static ssize_t write_ports(struct file *
 		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
 			if (port == 0)
 				return -EINVAL;
-			lock_kernel();
 			if (nfsd_serv) {
 				xprt = svc_find_xprt(nfsd_serv, transport,
 						     AF_UNSPEC, port);
@@ -666,13 +668,22 @@ static ssize_t write_ports(struct file *
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
@@ -691,13 +702,13 @@ static ssize_t write_maxblksize(struct f
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

diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
--- .prev/fs/nfsd/nfssvc.c	2008-05-20 09:49:52.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2008-05-20 09:47:59.000000000 +1000
@@ -190,13 +190,15 @@ void nfsd_reset_versions(void)
 	}
 }
 
+DEFINE_MUTEX(nfsd_mutex);
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
@@ -223,7 +225,7 @@ int nfsd_create_serv(void)
 				      nfsd, SIG_NOCLEAN, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		err = -ENOMEM;
-	unlock_kernel();
+
 	do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	return err;
 }
@@ -282,6 +284,8 @@ int nfsd_set_nrthreads(int n, int *nthre
 	int tot = 0;
 	int err = 0;
 
+	WARN_ON(!mutex_is_locked(&nfsd_mutex));
+
 	if (nfsd_serv == NULL || n <= 0)
 		return 0;
 
@@ -316,7 +320,6 @@ int nfsd_set_nrthreads(int n, int *nthre
 		nthreads[0] = 1;
 
 	/* apply the new numbers */
-	lock_kernel();
 	svc_get(nfsd_serv);
 	for (i = 0; i < n; i++) {
 		err = svc_set_num_threads(nfsd_serv, &nfsd_serv->sv_pools[i],
@@ -325,7 +328,6 @@ int nfsd_set_nrthreads(int n, int *nthre
 			break;
 	}
 	svc_destroy(nfsd_serv);
-	unlock_kernel();
 
 	return err;
 }
@@ -334,8 +336,8 @@ int
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
@@ -363,7 +365,7 @@ nfsd_svc(unsigned short port, int nrserv
  failure:
 	svc_destroy(nfsd_serv);		/* Release server */
  out:
-	unlock_kernel();
+	mutex_unlock(&nfsd_mutex);
 	return error;
 }
 
@@ -399,7 +401,7 @@ nfsd(struct svc_rqst *rqstp)
 	sigset_t shutdown_mask, allowed_mask;
 
 	/* Lock module and set up kernel thread */
-	lock_kernel();
+	mutex_lock(&nfsd_mutex);
 	daemonize("nfsd");
 
 	/* After daemonize() this kernel thread shares current->fs
@@ -417,11 +419,13 @@ nfsd(struct svc_rqst *rqstp)
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
@@ -477,7 +481,7 @@ nfsd(struct svc_rqst *rqstp)
 	/* Clear signals before calling svc_exit_thread() */
 	flush_signals(current);
 
-	lock_kernel();
+	mutex_lock(&nfsd_mutex);
 
 	nfsdstats.th_cnt --;
 
@@ -486,7 +490,7 @@ out:
 	svc_exit_thread(rqstp);
 
 	/* Release module */
-	unlock_kernel();
+	mutex_unlock(&nfsd_mutex);
 	module_put_and_exit(0);
 }
