From: Greg Banks <gnb@sgi.com>
Subject: [patch 26/29] knfsd: make svc_serv.sv_stats per-CPU
Date: Wed, 01 Apr 2009 07:28:26 +1100
Message-ID: <20090331202947.593872000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22584 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762433AbZCaVCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split the svc_stat structure pointed to by svc_serv.sv_stats into
a structure per-cpu, and aggregate all the per-cpu structures just
before emitting them to userspace via /proc.  This avoids bouncing
cachelines when updating stats.  See next patch for performance
numbers.

Signed-off-by: Greg Banks <gnb@sgi.com>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 include/linux/sunrpc/svc.h |    6 +++---
 net/sunrpc/stats.c         |   34 +++++++++++++++++++++++-----------
 net/sunrpc/svc.c           |    8 ++++----
 3 files changed, 30 insertions(+), 18 deletions(-)

Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -76,7 +76,7 @@ struct svc_pool {
  */
 struct svc_serv {
 	struct svc_program *	sv_program;	/* RPC program */
-	struct svc_stat *	sv_stats;	/* RPC statistics */
+	struct svc_stat *	sv_stats_percpu;/* RPC statistics */
 	spinlock_t		sv_lock;
 	unsigned int		sv_nrthreads;	/* # of server threads */
 	unsigned int		sv_maxconn;	/* max connections allowed or
@@ -110,8 +110,8 @@ struct svc_serv {
 #endif /* CONFIG_NFSD_V4_1 */
 };
 #define SVC_INC_STAT(serv, field) \
-	((serv)->sv_stats ? \
-		++((serv)->sv_stats->field) : 0)
+	((serv)->sv_stats_percpu ? \
+		++(per_cpu_ptr((serv)->sv_stats_percpu, smp_processor_id())->field) : 0)
 
 /*
  * We use sv_nrthreads as a reference count.  svc_destroy() drops
Index: bfields/net/sunrpc/stats.c
===================================================================
--- bfields.orig/net/sunrpc/stats.c
+++ bfields/net/sunrpc/stats.c
@@ -75,17 +75,48 @@ static const struct file_operations rpc_
 };
 
 /*
+ * Accumulate all the per-cpu struct svc_stat
+ * into one global total for emission to userspace.
+ * Relies on struct svc_stat being composed of
+ * unsigned ints without gaps, so it can be treated
+ * as an array of unsigned ints.
+ *
+ * Note: we iterate over all possible CPUs instead
+ * of just the online ones to avoid counters going
+ * backwards when CPUs go offline.
+ */
+static void svc_stat_accum(const struct svc_serv *serv,
+			   struct svc_stat *sp)
+{
+	unsigned int *usp = (unsigned int *)sp;
+	int cpu;
+	int i;
+
+	memset(sp, 0, sizeof(*sp));
+	for_each_possible_cpu(cpu) {
+		unsigned int *ucsp = (unsigned int *)
+					per_cpu_ptr(serv->sv_stats_percpu, cpu);
+		for (i = 0 ; i < sizeof(*sp)/sizeof(unsigned int) ; i++)
+			usp[i] += ucsp[i];
+	}
+}
+
+
+/*
  * Get RPC server stats
  */
 void svc_seq_show(struct seq_file *seq, const struct svc_serv *serv)
 {
 	/* TODO: report call counts from the non-primary programs */
 	const struct svc_program *prog = serv->sv_program;
-	struct svc_stat *statp = serv->sv_stats;
+	struct svc_stat accum;
+	struct svc_stat *statp = &accum;
 	const struct svc_procedure *proc;
 	const struct svc_version *vers;
 	unsigned int i, j;
 
+	svc_stat_accum(serv, &accum);
+
 	seq_printf(seq,
 		"net %u %u %u %u\n",
 			statp->netcnt,
Index: bfields/net/sunrpc/svc.c
===================================================================
--- bfields.orig/net/sunrpc/svc.c
+++ bfields/net/sunrpc/svc.c
@@ -395,8 +395,9 @@ __svc_create(struct svc_program *prog, u
 	init_timer(&serv->sv_temptimer);
 	spin_lock_init(&serv->sv_lock);
 
-	serv->sv_stats = kzalloc(sizeof(struct svc_stat), GFP_KERNEL);
-	if (!serv->sv_stats) {
+	serv->sv_stats_percpu = __alloc_percpu(sizeof(struct svc_stat),
+					       __alignof__(struct svc_stat));
+	if (!serv->sv_stats_percpu) {
 		kfree(serv);
 		return NULL;
 	}
@@ -406,7 +407,7 @@ __svc_create(struct svc_program *prog, u
 		kcalloc(serv->sv_nrpools, sizeof(struct svc_pool),
 			GFP_KERNEL);
 	if (!serv->sv_pools) {
-		kfree(serv->sv_stats);
+		free_percpu(serv->sv_stats_percpu);
 		kfree(serv);
 		return NULL;
 	}
@@ -495,7 +496,7 @@ svc_destroy(struct svc_serv *serv)
 
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
-	kfree(serv->sv_stats);
+	free_percpu(serv->sv_stats_percpu);
 	kfree(serv);
 }
 EXPORT_SYMBOL_GPL(svc_destroy);

--
Greg
