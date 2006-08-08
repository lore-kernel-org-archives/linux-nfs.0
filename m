From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 3 of 5] knfsd: avoid nfsd CPU scheduler overload
Date: Tue, 08 Aug 2006 14:07:13 +1000
Message-ID: <1155010032.29877.235.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIsA-00023o-S4
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:07:18 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIsB-0007cR-2N
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:07:19 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: avoid overloading the CPU scheduler with enormous load averages
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


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svc.h |    2 ++
 net/sunrpc/svcsock.c       |   25 +++++++++++++++++++------
 2 files changed, 21 insertions(+), 6 deletions(-)

Index: linux-2.6.18-rc2/include/linux/sunrpc/svc.h
===================================================================
--- linux-2.6.18-rc2.orig/include/linux/sunrpc/svc.h	2006-08-04 16:00:10.890410874 +1000
+++ linux-2.6.18-rc2/include/linux/sunrpc/svc.h	2006-08-04 16:08:35.253729312 +1000
@@ -40,6 +40,7 @@ struct svc_pool {
 	struct list_head	sp_sockets;	/* pending sockets */
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
 	struct list_head	sp_all_threads;	/* all server threads */
+	int			sp_nwaking;	/* number of threads woken but not yet active */
 } ____cacheline_aligned_in_smp;
 
 /*
@@ -233,6 +234,7 @@ struct svc_rqst {
 						 * cache pages */
 	wait_queue_head_t	rq_wait;	/* synchronization */
 	struct task_struct	*rq_task;	/* service thread */
+	int			rq_waking;	/* 1 if thread is being woken */
 };
 
 /*
Index: linux-2.6.18-rc2/net/sunrpc/svcsock.c
===================================================================
--- linux-2.6.18-rc2.orig/net/sunrpc/svcsock.c	2006-08-04 16:06:24.266537165 +1000
+++ linux-2.6.18-rc2/net/sunrpc/svcsock.c	2006-08-04 16:08:35.297723665 +1000
@@ -67,6 +67,8 @@
 #define RPCDBG_FACILITY	RPCDBG_SVCSOCK
 
 
+#define SVC_MAX_WAKING 5
+
 static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 					 int *errp, int pmap_reg);
 static void		svc_udp_data_ready(struct sock *, int);
@@ -154,6 +156,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	struct svc_pool *pool;
 	struct svc_rqst	*rqstp;
 	int cpu;
+	int thread_avail;
 
 	if (!(svsk->sk_flags &
 	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)|(1<<SK_DEFERRED)) ))
@@ -167,11 +170,6 @@ svc_sock_enqueue(struct svc_sock *svsk)
 
 	spin_lock_bh(&pool->sp_lock);
 
-	if (!list_empty(&pool->sp_threads) &&
-	    !list_empty(&pool->sp_sockets))
-		printk(KERN_ERR
-			"svc_sock_enqueue: threads and sockets both waiting??\n");
-
 	if (test_bit(SK_DEAD, &svsk->sk_flags)) {
 		/* Don't enqueue dead sockets */
 		dprintk("svc: socket %p is dead, not enqueued\n", svsk->sk_sk);
@@ -207,7 +205,14 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 
 
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
@@ -222,6 +227,8 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;
 		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
+		rqstp->rq_waking = 1;
+		pool->sp_nwaking++;
 		BUG_ON(svsk->sk_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
@@ -1307,6 +1314,12 @@ svc_recv(struct svc_serv *serv, struct s
 		spin_lock_bh(&pool->sp_lock);
 		remove_wait_queue(&rqstp->rq_wait, &wait);
 
+		if (rqstp->rq_waking) {
+			rqstp->rq_waking = 0;
+			pool->sp_nwaking--;
+			BUG_ON(pool->sp_nwaking < 0);
+		}
+
 		if (!(svsk = rqstp->rq_sock)) {
 			svc_thread_dequeue(pool, rqstp);
 			spin_unlock_bh(&pool->sp_lock);


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
