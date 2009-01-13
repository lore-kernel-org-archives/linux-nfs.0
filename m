Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:37735 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752253AbZAMK06 (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 05:26:58 -0500
Message-Id: <20090113102653.664553000@sgi.com>
References: <20090113102633.719563000@sgi.com>
Date: Tue, 13 Jan 2009 21:26:35 +1100
From: Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
Subject: [patch 2/3] knfsd: avoid overloading the CPU scheduler with enormous load averages
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Avoid overloading the CPU scheduler with enormous load averages
when handling high call-rate NFS loads.  When the knfsd bottom half
is made aware of an incoming call by the socket layer, it tries to
choose an nfsd thread and wake it up.  As long as there are idle
threads, one will be woken up.

If there are lot of nfsd threads (a sensible configuration when
the server is disk-bound or is running an HSM), there will be many
more nfsd threads than CPUs to run them.  Under a high call-rate
low service-time workload, the result is that almost every nfsd is
runnable, but only a handful are actually able to run.  This situation
causes two significant problems:

1. The CPU scheduler takes over 10% of each CPU, which is robbing
   the nfsd threads of valuable CPU time.

2. At a high enough load, the nfsd threads starve userspace threads
   of CPU time, to the point where daemons like portmap and rpc.mountd
   do not schedule for tens of seconds at a time.  Clients attempting
   to mount an NFS filesystem timeout at the very first step (opening
   a TCP connection to portmap) because portmap cannot wake up from
   select() and call accept() in time.

Disclaimer: these effects were observed on a SLES9 kernel, modern
kernels' schedulers may behave more gracefully.

The solution is simple: keep in each svc_pool a counter of the number
of threads which have been woken but have not yet run, and do not wake
any more if that count reaches an arbitrary small threshold.

Testing was on a 4 CPU 4 NIC Altix using 4 IRIX clients, each with 16
synthetic client threads simulating an rsync (i.e. recursive directory
listing) workload reading from an i386 RH9 install image (161480
regular files in 10841 directories) on the server.  That tree is small
enough to fill in the server's RAM so no disk traffic was involved.
This setup gives a sustained call rate in excess of 60000 calls/sec
before being CPU-bound on the server.  The server was running 128 nfsds.

Profiling showed schedule() taking 6.7% of every CPU, and __wake_up()
taking 5.2%.  This patch drops those contributions to 3.0% and 2.2%.
Load average was over 120 before the patch, and 20.9 after.

This patch is a forward-ported version of knfsd-avoid-nfsd-overload
which has been shipping in the SGI "Enhanced NFS" product since 2006.
It has been posted before:

http://article.gmane.org/gmane.linux.nfs/10374

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/svc_xprt.c      |   25 ++++++++++++++++++-------
 2 files changed, 20 insertions(+), 7 deletions(-)

Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -41,6 +41,7 @@ struct svc_pool {
 	struct list_head	sp_sockets;	/* pending sockets */
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
 	struct list_head	sp_all_threads;	/* all server threads */
+	int			sp_nwaking;	/* number of threads woken but not yet active */
 } ____cacheline_aligned_in_smp;
 
 /*
@@ -264,6 +265,7 @@ struct svc_rqst {
 						 * cache pages */
 	wait_queue_head_t	rq_wait;	/* synchronization */
 	struct task_struct	*rq_task;	/* service thread */
+	int			rq_waking;	/* 1 if thread is being woken */
 };
 
 /*
Index: bfields/net/sunrpc/svc_xprt.c
===================================================================
--- bfields.orig/net/sunrpc/svc_xprt.c
+++ bfields/net/sunrpc/svc_xprt.c
@@ -14,6 +14,8 @@
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
+#define SVC_MAX_WAKING 5
+
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
@@ -298,6 +300,7 @@ void svc_xprt_enqueue(struct svc_xprt *x
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
+	int thread_avail;
 
 	if (!(xprt->xpt_flags &
 	      ((1<<XPT_CONN)|(1<<XPT_DATA)|(1<<XPT_CLOSE)|(1<<XPT_DEFERRED))))
@@ -309,12 +312,6 @@ void svc_xprt_enqueue(struct svc_xprt *x
 
 	spin_lock_bh(&pool->sp_lock);
 
-	if (!list_empty(&pool->sp_threads) &&
-	    !list_empty(&pool->sp_sockets))
-		printk(KERN_ERR
-		       "svc_xprt_enqueue: "
-		       "threads and transports both waiting??\n");
-
 	if (test_bit(XPT_DEAD, &xprt->xpt_flags)) {
 		/* Don't enqueue dead transports */
 		dprintk("svc: transport %p is dead, not enqueued\n", xprt);
@@ -353,7 +350,14 @@ void svc_xprt_enqueue(struct svc_xprt *x
 	}
 
  process:
-	if (!list_empty(&pool->sp_threads)) {
+	/* Work out whether threads are available */
+	thread_avail = !list_empty(&pool->sp_threads);	/* threads are asleep */
+	if (pool->sp_nwaking >= SVC_MAX_WAKING) {
+		/* too many threads are runnable and trying to wake up */
+		thread_avail = 0;
+	}
+
+	if (thread_avail) {
 		rqstp = list_entry(pool->sp_threads.next,
 				   struct svc_rqst,
 				   rq_list);
@@ -368,6 +372,8 @@ void svc_xprt_enqueue(struct svc_xprt *x
 		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+		rqstp->rq_waking = 1;
+		pool->sp_nwaking++;
 		BUG_ON(xprt->xpt_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
@@ -633,6 +639,11 @@ int svc_recv(struct svc_rqst *rqstp, lon
 		return -EINTR;
 
 	spin_lock_bh(&pool->sp_lock);
+	if (rqstp->rq_waking) {
+		rqstp->rq_waking = 0;
+		pool->sp_nwaking--;
+		BUG_ON(pool->sp_nwaking < 0);
+	}
 	xprt = svc_xprt_dequeue(pool);
 	if (xprt) {
 		rqstp->rq_xprt = xprt;

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
