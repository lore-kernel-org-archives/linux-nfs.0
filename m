From: Greg Banks <gnb@sgi.com>
Subject: [patch 29/29] knfsd: make nfsdstats per-CPU
Date: Wed, 01 Apr 2009 07:28:29 +1100
Message-ID: <20090331202949.006493000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22582 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761570AbZCaVCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make the global nfsdstats structure per-cpu.  Fields in this struct are
incremented one times per READ and WRITE NFS call, and also in various
other more obscure situations.  When the workload is doing READs to
every nfsd on every CPU, it's a very hot and bouncy cacheline indeed.

Tests on a 16 CPU Altix A4700 with 2 10gige Myricom cards, configured
separately (no bonding).  Workload is 640 client threads doing directory
traverals with random small reads, from server RAM.

Before
======

Kernel profile:

  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  5.45   2484.00  2484.00     2883     0.86     1.00  nfsd_ofcache_lookup
  4.91   4720.00  2236.00     2231     1.00     1.00  spin_unlock_irqrestore
  2.80   5994.00  1274.00     1262     1.01     1.01  svc_export_put
  2.74   7242.00  1248.00     3650     0.34     1.00  nfsd_vfs_read	<----
  2.58   8417.00  1175.00     1281     0.92     1.01  svcauth_unix_set_client

After
=====

Kernel profile:

  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  5.01   2276.00  2276.00     2666     0.85     1.00  nfsd_ofcache_lookup
  4.61   4370.00  2094.00     2092     1.00     1.00  ia64_spinlock_contention
  4.20   6279.00  1909.00     3141     0.61     0.78  svc_sock_enqueue
  4.03   8108.00  1829.00     1824     1.00     1.00  spin_unlock_irqrestore
  3.32   9618.00  1510.00     3588     0.42     1.00  spin_lock
  ...
  0.54  36665.00   246.00     2211     0.11     1.00  nfsd_vfs_read	<----

In this case, the throughput did not actually improve until the next
problem was solved (patch knfsd-make-svc-authenticate-scale-2).

Signed-off-by: Greg Banks <gnb@sgi.com>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 fs/nfsd/nfscache.c         |   19 ++++++++++---------
 fs/nfsd/stats.c            |   29 ++++++++++++++++++++++++++++-
 include/linux/nfsd/stats.h |    8 +++++---
 3 files changed, 43 insertions(+), 13 deletions(-)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -55,16 +55,51 @@ static inline void nfsd_stats_prefetch(n
 }
 
 
-struct nfsd_stats	nfsdstats;
+struct nfsd_stats	*nfsdstats_percpu;
 
 nfsd_stats_hash_t nfsd_export_stats_hash;
 nfsd_stats_hash_t nfsd_client_stats_hash;
 int nfsd_stats_enabled = 1;
 int nfsd_stats_prune_period = 2*86400;
 
+/*
+ * Accumulate all the per-cpu struct nfsd_stats
+ * into one global total for emission to userspace.
+ * Relies on struct nfsd_stats being composed of
+ * unsigned ints without gaps, so it can be treated
+ * as an array of unsigned ints.
+ *
+ * Note: we iterate over all possible CPUs instead
+ * of just the online ones to avoid counters going
+ * backwards when CPUs go offline.
+ *
+ * Note: the rcage field needs to be accumulated as
+ * a minimum across all the CPUs, not a sum.
+ */
+static void nfsd_stat_accum(struct nfsd_stats *sp)
+{
+	unsigned int *usp = (unsigned int *)sp;
+	int cpu;
+	int i;
+	unsigned int rcage = ~0;
+
+	memset(sp, 0, sizeof(*sp));
+	for_each_possible_cpu(cpu) {
+		struct nfsd_stats *csp = per_cpu_ptr(nfsdstats_percpu, cpu);
+		unsigned int *ucsp = (unsigned int *)csp;
+		for (i = 0 ; i < sizeof(*sp)/sizeof(unsigned int) ; i++)
+			usp[i] += ucsp[i];
+		rcage = min_t(unsigned int, rcage, csp->rcage);
+	}
+	sp->rcage = rcage;
+}
+
 static int nfsd_proc_show(struct seq_file *seq, void *v)
 {
 	int i;
+	struct nfsd_stats nfsdstats;
+
+	nfsd_stat_accum(&nfsdstats);
 
 	seq_printf(seq, "rc %u %u %u\nfh %u %u %u %u %u\nio %u %u\n",
 		      nfsdstats.rchits,
@@ -715,6 +750,7 @@ nfsd_stat_init(void)
 
 	nfsd_stats_hash_init(&nfsd_export_stats_hash, "export");
 	nfsd_stats_hash_init(&nfsd_client_stats_hash, "client");
+	nfsdstats_percpu = alloc_percpu(struct nfsd_stats);
 }
 
 void
@@ -724,4 +760,5 @@ nfsd_stat_shutdown(void)
 
 	nfsd_stats_hash_destroy(&nfsd_export_stats_hash);
 	nfsd_stats_hash_destroy(&nfsd_client_stats_hash);
+	free_percpu(nfsdstats_percpu);
 }
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -48,11 +48,17 @@ struct nfsd_stats {
 					 * entry reused from the LRU list */
 };
 #define NFSD_INC_STAT(field) \
-	(nfsdstats.field++)
+	(nfsdstats_percpu ? \
+		++(per_cpu_ptr(nfsdstats_percpu, smp_processor_id())->field) : 0)
 #define NFSD_ADD_STAT(field, v) \
-	(nfsdstats.field += (v))
+	(nfsdstats_percpu ? \
+		(per_cpu_ptr(nfsdstats_percpu, smp_processor_id())->field) += (v) : 0)
+/* Note that SET_STAT() always proceeds on per-cpu slot 0 to
+ * preserve the value semantics; this means you CANNOT mix
+ * SET_STAT() with INC_STAT() etc */
 #define NFSD_SET_STAT(field, v) \
-	(nfsdstats.field = (v))
+	(nfsdstats_percpu ? \
+		(per_cpu_ptr(nfsdstats_percpu, 0)->field) = (v) : 0)
 
 
 struct nfsd_op_stats {
@@ -148,7 +154,7 @@ struct nfsd_stats_hiter {
 };
 
 
-extern struct nfsd_stats	nfsdstats;
+extern struct nfsd_stats	*nfsdstats_percpu;
 extern nfsd_stats_hash_t	nfsd_export_stats_hash;
 extern nfsd_stats_hash_t	nfsd_client_stats_hash;
 

--
Greg
