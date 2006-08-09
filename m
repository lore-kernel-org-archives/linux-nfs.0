From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0 of 5] knfsd: miscellaneous performance-related
	fixes
Date: Wed, 09 Aug 2006 14:18:32 +1000
Message-ID: <1155097112.16378.46.camel@hole.melbourne.sgi.com>
References: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
	<17624.17621.428870.694339@cse.unsw.edu.au>
	<1155032558.29877.324.camel@hole.melbourne.sgi.com>
	<17624.29880.852610.256270@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAfWk-0005nq-KT
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 21:18:42 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAfWk-0003Vg-OV
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 21:18:43 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17624.29880.852610.256270@cse.unsw.edu.au>
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

On Tue, 2006-08-08 at 21:25, Neil Brown wrote:
> On Tuesday August 8, gnb@melbourne.sgi.com wrote:
> > I'm still working on another patch (it only recently became possible
> > with the ktime_t code) which replaces threadstats fully.  That patch
> > adds nanosecond resolution busy and idle counters to each thread,
> > then aggregates them per-pool when you read the pool_stats file.
> > After export to userspace and rate conversion, these numbers tell
> > us directly what percentage of the nfsds are currently being used.
> > 
> > That patch worked on two platforms some weeks ago, but I'm not sure
> > it's ready for primetime.  I can post it for comment if you like?
> 
> Please!
> I always feel a bit guilty complaining about a patch that has been
> thoroughly tested and polished.  Seeing things early removed the guilt :-)

Ok, for comment only...this patch won't apply for several reasons
but hopefully you can get the gist of what I was trying to do.
--
knfsd: Maintain per-thread nanosecond resolution counters for time
nfsd threads spend idle (i.e. queued on the pool or waking up) and
busy (doing cpu work to service requests or blocking waiting for
disk I/O).  Accumulate those counter per-pool on demand and export
them via /proc/fs/nfsd/pool_stats.

The expectation is that userspace will rate-convert the counters
from nanoseconds to nanosec-per-sec and then scale down to a
multiple percentage, by analogy with CPU utilisation stats.  For
example, a 4 CPU machine can report: 

150% user 100% sys 50% intr 100 % idle

Where the total is Ncpus * 100%.  By analogy, a machine with 4 nfsd
threads can report:

300% busy 100% idle

(where the total is Nthreads * 100%) meaning that on average 3 of
the threads are doing useful NFS work and 1 is not being used.

By presenting thread usage as just two numbers, we make it easy
for a sysadmin to understand whether we have too many threads for
the currently running workload.  For example, a machine with 16
threads which reports 327% busy 1273% idle has about 12 threads
more than it needs to satisfy the workload.

Also, the %idle number is potentially an ideal input for an
automatic control loop.  That control loop would attempt to keep
the %idle number at some predetermined small level (I like 100%),
by adding new threads (if the %idle falls too low) or removing
threads (if %idle climbs too high).

Please consider this patch a beta release only.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 fs/nfsd/stats.c            |   25 ++++++++++++------
 include/linux/sunrpc/svc.h |   14 ++++++++++
 net/sunrpc/svc.c           |   17 ++++++++++++
 net/sunrpc/svcsock.c       |   45 +++++++++++++++++++++++++++++++---
 4 files changed, 89 insertions(+), 12 deletions(-)

Index: linux/fs/nfsd/stats.c
===================================================================
--- linux.orig/fs/nfsd/stats.c	2006-06-20 19:52:02.854477556 +1000
+++ linux/fs/nfsd/stats.c	2006-06-21 17:11:45.117989613 +1000
@@ -423,16 +423,25 @@ void nfsd_stats_update_op(struct svc_rqs
 	}
 }
 
-static inline ktime_t ktime_get(void)
+static inline ktime_t svc_elapsed_ktime(struct svc_rqst *rqstp, int newstate)
 {
-	struct timespec ts;
-	ktime_get_ts(&ts);
-	return timespec_to_ktime(ts);
+	ktime_t now, elapsed;
+	int oldstate = rqstp->rq_state;
+
+	now = ktime_get();
+	elapsed = ktime_sub(now, rqstp->rq_timestamp);
+	rqstp->rq_timestamp = now;
+
+	rqstp->rq_times[oldstate] = ktime_add(rqstp->rq_times[oldstate],
+					      elapsed);
+	rqstp->rq_state = newstate;
+
+	return elapsed;
 }
 
 void nfsd_stats_pre(struct svc_rqst *rqstp)
 {
-	rqstp->rq_timestamp = ktime_get();
+	svc_elapsed_ktime(rqstp, /*going busy*/1);
 	rqstp->rq_export_stats = NULL;
 	rqstp->rq_client_stats = NULL;
 }
@@ -458,15 +467,13 @@ static inline int time_bucket(const ktim
 void nfsd_stats_post(struct svc_rqst *rqstp)
 {
 	int tb = -1;
-	ktime_t now, svctime;
+	ktime_t svctime;
 
 	if (rqstp->rq_export_stats == NULL && rqstp->rq_client_stats == NULL)
 		return;
 
 	/* calculate service time and update the stats */
-	now = ktime_get();
-	svctime = ktime_sub(now, rqstp->rq_timestamp);
-	rqstp->rq_timestamp = now;
+	svctime = svc_elapsed_ktime(rqstp, /*going idle*/0);
 	tb = time_bucket(svctime);
 
 
Index: linux/include/linux/sunrpc/svc.h
===================================================================
--- linux.orig/include/linux/sunrpc/svc.h	2006-06-20 19:30:48.083987201 +1000
+++ linux/include/linux/sunrpc/svc.h	2006-06-21 17:13:49.625163996 +1000
@@ -30,6 +30,11 @@ struct svc_pool_stats {
 	unsigned long	threads_woken;
 	unsigned long	overloads_avoided;
 	unsigned long	threads_timedout;
+	ktime_t		dead_times[2];		/* Counts accumulated idle
+						 * and busy times for threads
+						 * which have died, to avoid
+						 * the /proc counters going
+						 * backward. */
 };
 
 /*
@@ -251,6 +256,8 @@ struct svc_rqst {
 	wait_queue_head_t	rq_wait;	/* synchronization */
 	struct task_struct	*rq_task;	/* service thread */
 	int			rq_waking;	/* 1 if thread is being woken */
+	int			rq_state;	/* 0=idle 1=busy */
+	ktime_t			rq_times[2];	/* cumulative time spent idle,busy */
 	ktime_t			rq_timestamp;	/* time of last idle<->busy transition */
 	struct nfsd_stats_hentry *rq_export_stats;
 	struct nfsd_stats_hentry *rq_client_stats;
@@ -440,5 +447,12 @@ static inline struct svc_pool *svc_pool_
 #endif
 }
 
+static inline ktime_t ktime_get(void)
+{
+	struct timespec ts;
+	ktime_get_ts(&ts);
+	return timespec_to_ktime(ts);
+}
+
 
 #endif /* SUNRPC_SVC_H */
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2006-06-20 19:52:02.858383300 +1000
+++ linux/net/sunrpc/svcsock.c	2006-06-21 17:25:43.140054463 +1000
@@ -1733,19 +1733,58 @@ static void svc_pool_stats_stop(struct s
 static int svc_pool_stats_show(struct seq_file *m, void *p)
 {
 	struct svc_pool *pool = p;
+	ktime_t times[2], now;
+	struct list_head *iter;
+	int state;
+	unsigned nthreads;
 
 	if (p == (void *)1) {
-		seq_puts(m, "# pool packets-arrived sockets-enqueued threads-woken overloads-avoided threads-timedout\n");
+		seq_puts(m, "# pool packets-arrived sockets-enqueued "
+			    "threads-woken overloads-avoided threads-timedout "
+			    "num-threads nanosec-idle nanosec-busy\n");
 		return 0;
 	}
 
-	seq_printf(m, "%u %lu %lu %lu %lu %lu\n",
+	/*
+	 * Here we accumulate the times for each thread in the pool,
+	 * and only print accumulated times rather than each thread's
+	 * time.  Experience shows that the per-pool numbers are useful,
+	 * but the per-thread numbers are Too Much Information.
+	 */
+	nthreads = 0;
+	now = ktime_get();
+
+	/* take sp_lock to traverse sp_all_threads; this also
+	 * prevents threads from transitioning busy<->idle */
+	spin_lock(&pool->sp_lock);
+	/* initialise accumulators to time accumulated by dead threads */
+	times[0] = pool->sp_stats.dead_times[0];
+	times[1] = pool->sp_stats.dead_times[1];
+
+	list_for_each(iter, &pool->sp_all_threads) {
+		struct svc_rqst *rqstp =
+			list_entry(iter, struct svc_rqst, rq_all);
+		times[0] = ktime_add(times[0], rqstp->rq_times[0]);
+		times[1] = ktime_add(times[1], rqstp->rq_times[1]);
+		/* interpolate time from last change to now */
+		state = rqstp->rq_state;
+		times[state] = ktime_add(times[state],
+				         ktime_sub(now, rqstp->rq_timestamp));
+		nthreads++;
+	}
+
+	spin_unlock(&pool->sp_lock);
+
+	seq_printf(m, "%u %lu %lu %lu %lu %lu %u %lu %lu\n",
 		pool->sp_id,
 		pool->sp_stats.packets,
 		pool->sp_stats.sockets_queued,
 		pool->sp_stats.threads_woken,
 		pool->sp_stats.overloads_avoided,
-		pool->sp_stats.threads_timedout);
+		pool->sp_stats.threads_timedout,
+		nthreads,
+		ktime_to_ns(times[0]),
+		ktime_to_ns(times[1]));
 
 	return 0;
 }
Index: linux/net/sunrpc/svc.c
===================================================================
--- linux.orig/net/sunrpc/svc.c	2006-06-20 19:28:40.198213294 +1000
+++ linux/net/sunrpc/svc.c	2006-06-21 17:24:25.476421936 +1000
@@ -395,6 +395,8 @@ __svc_create_thread(svc_thread_fn func, 
 	spin_unlock_bh(&pool->sp_lock);
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
+	rqstp->rq_state = 0;	/* idle */
+	rqstp->rq_timestamp = ktime_get();
 
 #if SVC_HAVE_MULTIPLE_POOLS
 	if (serv->sv_nrpools > 1)
@@ -540,12 +542,27 @@ svc_exit_thread(struct svc_rqst *rqstp)
 {
 	struct svc_serv	*serv = rqstp->rq_server;
 	struct svc_pool	*pool = rqstp->rq_pool;
+	ktime_t now;
 
 	svc_release_buffer(rqstp);
 	kfree(rqstp->rq_resp);
 	kfree(rqstp->rq_argp);
 	kfree(rqstp->rq_auth_data);
+
+	/* interpolate time since last state change */
+	now = ktime_get();
+	rqstp->rq_times[rqstp->rq_state] = ktime_add(
+					    rqstp->rq_times[rqstp->rq_state],
+					    ktime_sub(now,
+						      rqstp->rq_timestamp));
 	spin_lock_bh(&pool->sp_lock);
+	/* remember accumulated time in dead_times */
+	pool->sp_stats.dead_times[0] = ktime_add(
+					    pool->sp_stats.dead_times[0],
+					    rqstp->rq_times[0]);
+	pool->sp_stats.dead_times[1] = ktime_add(
+					    pool->sp_stats.dead_times[1],
+					    rqstp->rq_times[1]);
 	list_del(&rqstp->rq_all);
 	spin_unlock_bh(&pool->sp_lock);
 	kfree(rqstp);


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
