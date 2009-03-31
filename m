From: Greg Banks <gnb@sgi.com>
Subject: [patch 27/29] knfsd: move hot procedure count field out of svc_procedure
Date: Wed, 01 Apr 2009 07:28:27 +1100
Message-ID: <20090331202947.986110000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22587 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762517AbZCaVCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The svc_procedure structure contains a number of very static fields
which describe each RPC call that can be made.  However the pc_count
field is a counter of calls received.  For any given workload there
will be some of these that are very hot cachelines indeed.

This patch moves the counters to a dynamically allocated per-cpu
area at the end of the svc_stat structure attached to the svc_serv.
The pc_count field is used only as an index into that area, so that the
svc_procedure cachelines remain constant after service initialisation.

The result is dramatically less time spent in svc_process() and
nfsd_dispatch() waiting for svc_procedure cachelines to bounce.

Tests on a 16 CPU Altix A4700 with 2 10gige Myricom cards, configured
separately (no bonding).  Workload is 640 client threads doing directory
traverals with random small reads, from server RAM.

Before
======

Kernel profile:

  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  6.33   2813.00  2813.00    29979     0.09     1.01  svc_process	<----
  ^^^^
  4.66   4883.00  2070.00     2065     1.00     1.00  spin_unlock_irqrestore
  4.06   6687.00  1804.00     2182     0.83     1.00  nfsd_ofcache_lookup
  3.20   8110.00  1423.00    10932     0.13     1.00  nfsd_dispatch	<----
  ^^^^
  3.03   9456.00  1346.00     1343     1.00     1.00  nfsd_cache_lookup
  2.62  10622.00  1166.00     4645     0.25     1.01  svc_tcp_recvfrom
  2.47  11720.00  1098.00     1096     1.00     1.00  ia64_spinlock_contention

Call rate:

nullarbor:~ # pmdumptext nfs3.server.calls
...
Thu Dec 13 01:45:27     194796.183
Thu Dec 13 01:45:28     194677.118
Thu Dec 13 01:45:29     193932.692
Thu Dec 13 01:45:30     194294.364
Thu Dec 13 01:45:31     194971.276
Thu Dec 13 01:45:32     194111.207
Thu Dec 13 01:45:33     194999.635
Thu Dec 13 01:45:34     195312.594
Thu Dec 13 01:45:35     195707.293
Thu Dec 13 01:45:36     194610.353
Thu Dec 13 01:45:37     195913.662


After
=====

Kernel profile:

  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  5.32   2420.00  2420.00     2793     0.87     1.00  nfsd_ofcache_lookup
  4.21   4337.00  1917.00     1894     1.01     1.01  spin_unlock_irqrestore
  3.05   5723.00  1386.00     1375     1.01     1.01  ia64_spinlock_contention
  2.76   6977.00  1254.00     1250     1.00     1.00  svc_export_put
  2.67   8193.00  1216.00     1210     1.00     1.01  find_get_page
  2.57   9362.00  1169.00     1247     0.94     1.01  svcauth_unix_set_client
  ...
  0.93  29904.00   425.00    29154     0.01     1.02  svc_process	<----
  ^^^^
  ...
  0.35  38663.00   159.00    11859     0.01     1.01  nfsd_dispatch	<----
  ^^^^

call rate:

nullarbor:~ # pmdumptext nfs3.server.calls
...
Thu Dec 13 06:35:43     242547.513
Thu Dec 13 06:35:44     242257.033
Thu Dec 13 06:35:45     242144.719
Thu Dec 13 06:35:46     242857.100
Thu Dec 13 06:35:47     241464.156
Thu Dec 13 06:35:48     241182.933
Thu Dec 13 06:35:49     241294.968
Thu Dec 13 06:35:50     241606.887

i.e. about a 24.2% improvement in call rate.  Note, this includes the
performance gain from the previous patch which made svc_stat per-cpu.

Signed-off-by: Greg Banks <gnb@sgi.com>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 include/linux/sunrpc/stats.h |    1 +
 include/linux/sunrpc/svc.h   |    2 +-
 net/sunrpc/stats.c           |    2 +-
 net/sunrpc/svc.c             |   10 +++++++---
 4 files changed, 10 insertions(+), 5 deletions(-)

Index: bfields/include/linux/sunrpc/stats.h
===================================================================
--- bfields.orig/include/linux/sunrpc/stats.h
+++ bfields/include/linux/sunrpc/stats.h
@@ -34,6 +34,7 @@ struct svc_stat {
 				rpcbadfmt,
 				rpcbadauth,
 				rpcbadclnt;
+	unsigned int		callcnt[];
 };
 
 void			rpc_proc_init(void);
Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -77,6 +77,7 @@ struct svc_pool {
 struct svc_serv {
 	struct svc_program *	sv_program;	/* RPC program */
 	struct svc_stat *	sv_stats_percpu;/* RPC statistics */
+	unsigned int		sv_stats_ncalls;/* how many slots in svc_stat.callcnt[] */
 	spinlock_t		sv_lock;
 	unsigned int		sv_nrthreads;	/* # of server threads */
 	unsigned int		sv_maxconn;	/* max connections allowed or
@@ -408,7 +409,7 @@ struct svc_procedure {
 	kxdrproc_t		pc_release;	/* XDR free result */
 	unsigned int		pc_argsize;	/* argument struct size */
 	unsigned int		pc_ressize;	/* result struct size */
-	unsigned int		pc_count;	/* call count */
+	unsigned int		pc_countidx;	/* index into svc_stat.callcnt[] */
 	unsigned int		pc_cachetype;	/* cache info (NFS) */
 	unsigned int		pc_xdrressize;	/* maximum size of XDR reply */
 };
Index: bfields/net/sunrpc/stats.c
===================================================================
--- bfields.orig/net/sunrpc/stats.c
+++ bfields/net/sunrpc/stats.c
@@ -91,12 +91,13 @@ static void svc_stat_accum(const struct 
 	unsigned int *usp = (unsigned int *)sp;
 	int cpu;
 	int i;
+	int n = sizeof(*sp)/sizeof(unsigned int) + serv->sv_stats_ncalls;
 
 	memset(sp, 0, sizeof(*sp));
 	for_each_possible_cpu(cpu) {
 		unsigned int *ucsp = (unsigned int *)
 					per_cpu_ptr(serv->sv_stats_percpu, cpu);
-		for (i = 0 ; i < sizeof(*sp)/sizeof(unsigned int) ; i++)
+		for (i = 0 ; i < n ; i++)
 			usp[i] += ucsp[i];
 	}
 }
@@ -109,13 +110,17 @@ void svc_seq_show(struct seq_file *seq, 
 {
 	/* TODO: report call counts from the non-primary programs */
 	const struct svc_program *prog = serv->sv_program;
-	struct svc_stat accum;
-	struct svc_stat *statp = &accum;
+	struct svc_stat *statp;
 	const struct svc_procedure *proc;
 	const struct svc_version *vers;
 	unsigned int i, j;
 
-	svc_stat_accum(serv, &accum);
+	statp = kzalloc(sizeof(struct svc_stat) +
+			sizeof(unsigned int) * serv->sv_stats_ncalls,
+			GFP_KERNEL);
+	if (!statp)
+		return;
+	svc_stat_accum(serv, statp);
 
 	seq_printf(seq,
 		"net %u %u %u %u\n",
@@ -136,9 +141,11 @@ void svc_seq_show(struct seq_file *seq, 
 			continue;
 		seq_printf(seq, "proc%d %u", i, vers->vs_nproc);
 		for (j = 0; j < vers->vs_nproc; j++, proc++)
-			seq_printf(seq, " %u", proc->pc_count);
+			seq_printf(seq, " %u", statp->callcnt[proc->pc_countidx]);
 		seq_putc(seq, '\n');
 	}
+
+	kfree(statp);
 }
 EXPORT_SYMBOL_GPL(svc_seq_show);
 
Index: bfields/net/sunrpc/svc.c
===================================================================
--- bfields.orig/net/sunrpc/svc.c
+++ bfields/net/sunrpc/svc.c
@@ -365,6 +365,7 @@ __svc_create(struct svc_program *prog, u
 	unsigned int vers;
 	unsigned int xdrsize;
 	unsigned int i;
+	unsigned int countidx = 0;
 
 	if (!(serv = kzalloc(sizeof(*serv), GFP_KERNEL)))
 		return NULL;
@@ -386,6 +387,8 @@ __svc_create(struct svc_program *prog, u
 					prog->pg_lovers = vers;
 				if (prog->pg_vers[vers]->vs_xdrsize > xdrsize)
 					xdrsize = prog->pg_vers[vers]->vs_xdrsize;
+				for (i = 0 ; i < prog->pg_vers[vers]->vs_nproc ; i++)
+					prog->pg_vers[vers]->vs_proc[i].pc_countidx = countidx++;
 			}
 		prog = prog->pg_next;
 	}
@@ -395,7 +398,9 @@ __svc_create(struct svc_program *prog, u
 	init_timer(&serv->sv_temptimer);
 	spin_lock_init(&serv->sv_lock);
 
-	serv->sv_stats_percpu = __alloc_percpu(sizeof(struct svc_stat),
+	serv->sv_stats_ncalls = countidx;
+	serv->sv_stats_percpu = __alloc_percpu(sizeof(struct svc_stat) +
+					       sizeof(unsigned int) * countidx,
 					       __alignof__(struct svc_stat));
 	if (!serv->sv_stats_percpu) {
 		kfree(serv);
@@ -1098,8 +1103,8 @@ svc_process(struct svc_rqst *rqstp)
 	statp = resv->iov_base +resv->iov_len;
 	svc_putnl(resv, RPC_SUCCESS);
 
-	/* Bump per-procedure stats counter */
-	procp->pc_count++;
+	/* Bump per-procedure per-cpu stats counter */
+	SVC_INC_STAT(serv, callcnt[procp->pc_countidx]);
 
 	/* Initialize storage for argp and resp */
 	memset(rqstp->rq_argp, 0, procp->pc_argsize);

--
Greg
