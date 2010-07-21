Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328Ab0GUUPW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 16:15:22 -0400
Date: Wed, 21 Jul 2010 16:14:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #4)
Message-ID: <20100721201437.GD28123@fieldses.org>
References: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 21, 2010 at 09:21:41AM -0400, Jeff Layton wrote:
> Right now, nfsd keeps a lockd reference for each socket that it has
> open. This is unnecessary and complicates the error handling on startup
> and shutdown. Change it to just do a lockd_up when starting the first
> nfsd thread just do a single lockd_down when taking down the last nfsd
> thread. Because of the strange way the sv_count is handled, this
> requires an extra flag to tell whether the nfsd_serv holds a reference
> for lockd or not.
> 
> This patch also changes the error handling in nfsd_create_serv a bit
> too. There doesn't seem to be any need to reset the nfssvc_boot time if
> the nfsd startup failed.
> 
> Note though that this does change the user-visible behavior slightly.
> Today, a lockd_up is done whenever a socket fd is handed off to the
> kernel. With this change, lockd is brought up as soon as the first
> thread is started. I think this makes more sense. If there are problems
> in userspace, the old scheme had the possibility to start lockd long
> before any nfsd threads were started. This patch helps minimize that
> possibility.

The nfs4 state startup has the same problem that I think lockd_up was
designed to solve.

There's a bunch of stuff that only makes sense to run when nrthreads
transitions from zero to nonzero, or vice-versa; so, if we stick them
all in one helper function I think it's cleaner and solves another minor
startup bug.  Something like this?

(Incremental on top of your last patch, with some noise due to moving
stuff around to avoid forward references.  I'll clean these up and
resend.)

Then we could also get rid of some of the individual flags (nfs4_init at
least), I think.

--b.

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2e15db0..fd2524b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -25,7 +25,6 @@
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 struct timeval			nfssvc_boot;
-static bool			nfsd_lockd_up;
 
 /*
  * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
@@ -181,16 +180,79 @@ int nfsd_nrthreads(void)
 	return rv;
 }
 
+static int nfsd_init_socks(int port)
+{
+	int error;
+	if (!list_empty(&nfsd_serv->sv_permsocks))
+		return 0;
+
+	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
+					SVC_SOCK_DEFAULTS);
+	if (error < 0)
+		return error;
+
+	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
+					SVC_SOCK_DEFAULTS);
+	if (error < 0)
+		return error;
+
+	return 0;
+}
+
+static bool nfsd_up = false;
+
+static int nfsd_startup(unsigned short port, int nrservs)
+{
+	int ret;
+
+	/*
+	 * Readahead param cache - will no-op if it already exists.
+	 * (Note therefore results will be suboptimal if number of
+	 * threads is modified after nfsd start.)
+	 */
+	ret = nfsd_racache_init(2*nrservs);
+	if (ret)
+		return ret;
+	ret = nfsd_init_socks(port);
+	if (ret)
+		goto out_racache;
+	ret = lockd_up();
+	if (ret)
+		return ret;
+	ret = nfs4_state_start();
+	if (ret)
+		goto out_lockd;
+	nfsd_reset_versions();
+	nfsd_up = true;
+	return 0;
+out_lockd:
+	lockd_down();
+out_racache:
+	nfsd_racache_shutdown();
+	return ret;
+}
+
+static void nfsd_shutdown(void)
+{
+	/*
+	 * write_ports can create the server without actually starting
+	 * any threads--if we get shut down before any threads are
+	 * started, the nfsd_last_thread will be run before any of this
+	 * other initialization has been done.
+	 */
+	if (!nfsd_up)
+		return;
+	nfs4_state_shutdown();
+	lockd_down();
+	nfsd_racache_shutdown();
+	nfsd_up = false;
+}
+
 static void nfsd_last_thread(struct svc_serv *serv)
 {
 	/* When last nfsd thread exits we need to do some clean-up */
-	if (nfsd_lockd_up) {
-		lockd_down();
-		nfsd_lockd_up = false;
-	}
 	nfsd_serv = NULL;
-	nfsd_racache_shutdown();
-	nfs4_state_shutdown();
+	nfsd_shutdown();
 
 	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
 			    "cache\n");
@@ -276,25 +338,6 @@ int nfsd_create_serv(void)
 	return err;
 }
 
-static int nfsd_init_socks(int port)
-{
-	int error;
-	if (!list_empty(&nfsd_serv->sv_permsocks))
-		return 0;
-
-	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
-					SVC_SOCK_DEFAULTS);
-	if (error < 0)
-		return error;
-
-	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
-					SVC_SOCK_DEFAULTS);
-	if (error < 0)
-		return error;
-
-	return 0;
-}
-
 int nfsd_nrpools(void)
 {
 	if (nfsd_serv == NULL)
@@ -369,11 +412,16 @@ int nfsd_set_nrthreads(int n, int *nthreads)
 	return err;
 }
 
+/*
+ * Adjust the number of threads and return the new number of threads.
+ * This is also the function that starts the server if necessary, if
+ * this is the first time nrservs is nonzero.
+ */
 int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	bool	lockd_started = false;
+	bool	first_thread;
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
@@ -385,59 +433,33 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
-	/* Readahead param cache - will no-op if it already exists */
-	error =	nfsd_racache_init(2*nrservs);
-	if (error<0)
-		goto out;
+	first_thread = (nfsd_serv->sv_nrthreads == 0) && (nrservs != 0);
 
-	/* start lockd iff we're starting threads */
-	if ((nrservs > 0) && !nfsd_lockd_up) {
-		error = lockd_up();
-		if (error != 0)
+	if (first_thread) {
+		error = nfsd_startup(port, nrservs);
+		if (error)
 			goto out;
-		nfsd_lockd_up = true;
-		lockd_started = true;
 	}
 
-	error = nfs4_state_start();
-	if (error)
-		goto out;
-
-	nfsd_reset_versions();
-
 	error = nfsd_create_serv();
 	if (error)
-		goto shutdown_state;
-
-	error = nfsd_init_socks(port);
-	if (error)
-		goto failure;
+		goto out_shutdown;
 
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
-	if (error == 0)
-		/* We are holding a reference to nfsd_serv which
-		 * we don't want to count in the return value,
-		 * so subtract 1
-		 */
-		error = nfsd_serv->sv_nrthreads - 1;
-
-	/* if we brought all threads down, do a lockd_down */
-	if ((error == 0) && nfsd_lockd_up) {
-		lockd_down();
-		nfsd_lockd_up = false;
-	}
+	if (error)
+		goto out_destroy;
+	/* We are holding a reference to nfsd_serv which
+	 * we don't want to count in the return value,
+	 * so subtract 1
+	 */
+	error = nfsd_serv->sv_nrthreads - 1;
 
-failure:
+out_destroy:
 	svc_destroy(nfsd_serv);		/* Release server */
-shutdown_state:
-	if (error < 0)
-		nfs4_state_shutdown();
+out_shutdown:
+	if (error < 0 && first_thread)
+		nfsd_shutdown();
 out:
-	/* lockd_down if there was an error, and we did a lockd_up */
-	if (lockd_started && error < 0) {
-		lockd_down();
-		nfsd_lockd_up = false;
-	}
 	mutex_unlock(&nfsd_mutex);
 	return error;
 }
