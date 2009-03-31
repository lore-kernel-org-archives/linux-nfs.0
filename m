From: Greg Banks <gnb@sgi.com>
Subject: [patch 04/29] knfsd: Add stats updating API
Date: Wed, 01 Apr 2009 07:28:04 +1100
Message-ID: <20090331202939.355585000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22572 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756196AbZCaVCf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add APIs for the NFS server code to use to update per-client
and per-export statistics.  Functions nfsd_stats_pre() and
nfsd_stats_post() are called before and after each NFS call.  Function
nfsd_stats_update_op() is provided to update the stats for a particular
NFS operation, and several convenience wrappers for it are provided.

Note that the NFS server code needs to be instrumented to call the
nfsd_stats_update_op() function at appropriate times, rather than
have the generic RPC code do those updates.  This is necessary if we
are to support per-export stats, because the operation's file handle
(which tells us the export in use) is not available until after
NFS-specific XDR decoding.

Note also that the API transparently handles the complex way
that NFSv4 maps operations to calls, compared to the old simple
NFSv2/v3 arrangement.  The NFS code just calls nfsd_stats_update_op()
once for each operation.  The first time this happens in each NFS
call, some per-call accounting is done as well as per-op accouting.
The second and subsequent calls to nfsd_stats_update_op() in an NFS
call will only do per-op accounting.  This is designed to simplify
the instrumentation needed in each NFS call code.

Also, fill out the struct nfsd_op_stats with the actual counters.
Note that the "ops" used to store the stats are neither precisely the
NFSv2/3 calls nor the NFSv4 operations.  Instead they're an abstract
set of operations, with some NFS operations merged together where
we're not really interested in the differences (e.g. NFSv3 CREATE,
MKDIR, SYMLINK, and several other calls are lumped together into a
"MKINODE" op).  Conversely, the WRITE call is split into two "ops"
depending on whether it's marked STABLE, because this has a significant
performance effect.

Contains code based on patches from Harshula Jayasuriya <harshula@sgi.com>
and Peter Leckie <pleckie@sgi.com>.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfssvc.c           |    4 +
 fs/nfsd/stats.c            |   97 ++++++++++++++++++++++++++++++
 include/linux/nfsd/stats.h |  107 +++++++++++++++++++++++++++++++++-
 include/linux/sunrpc/svc.h |    1 
 4 files changed, 208 insertions(+), 1 deletion(-)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -328,6 +328,103 @@ out_unlock:
 	up_write(&sh->sh_sem);
 }
 
+static void __nfsd_stats_begin_call(struct svc_rqst *rqstp,
+				    nfsd_stats_hentry_t *se)
+{
+	struct nfsd_op_stats *os = &se->se_data;
+
+	os->os_bytes_in += rqstp->rq_arg.len;
+}
+
+static void __nfsd_stats_end_call(struct svc_rqst *rqstp,
+				  nfsd_stats_hentry_t *se,
+				  int tb)
+{
+	struct nfsd_op_stats *os = &se->se_data;
+
+	if (tb >= 0)
+		os->os_service_times[tb]++;
+	os->os_bytes_out += rqstp->rq_res.len;
+
+	if (rqstp->rq_prog == NFS_PROGRAM) {
+		if (rqstp->rq_vers >= 2 && rqstp->rq_vers <= 4)
+			os->os_versions[rqstp->rq_vers-2]++;
+	}
+
+	switch (rqstp->rq_prot)
+	{
+	case IPPROTO_TCP:
+		os->os_transports[NFSD_STATS_TRANSPORT_TCP]++;
+		break;
+	case IPPROTO_UDP:
+		os->os_transports[NFSD_STATS_TRANSPORT_UDP]++;
+		break;
+#if defined(CONFIG_SUNRPC_XPRT_RDMA) || defined(CONFIG_SUNRPC_XPRT_RDMA_MODULE)
+	case IPPROTO_MAX:
+		os->os_transports[NFSD_STATS_TRANSPORT_RDMA]++;
+		break;
+#endif
+	}
+}
+
+static void __nfsd_stats_op(struct svc_rqst *rqstp,
+			    nfsd_stats_hentry_t *se,
+			    int rbucket, int wbucket, int op)
+{
+	struct nfsd_op_stats *os = &se->se_data;
+
+	if (rbucket >= 0)
+		os->os_read_sizes[rbucket]++;
+	if (wbucket >= 0)
+		os->os_write_sizes[wbucket]++;
+
+	os->os_ops[op]++;
+}
+
+void nfsd_stats_update_op(struct svc_rqst *rqstp, struct svc_fh *fh,
+			  int rbucket, int wbucket, int op)
+{
+	if (!nfsd_stats_enabled)
+		return;
+
+	/* interesting things happen here 2 patches hence */
+}
+
+void nfsd_stats_pre(struct svc_rqst *rqstp)
+{
+	svc_time_mark(&rqstp->rq_start_time);
+}
+
+static inline int time_bucket(const struct timespec *ts)
+{
+	int i = 0;
+	unsigned long ns = ts->tv_sec * NSEC_PER_SEC + ts->tv_nsec;
+
+	if (ns) {
+		ns = (ns-1) >> 11;	/* smallest bucket is 256 usec */
+		while (i < NFSD_STATS_SVCTIME_NUM)
+		{
+			if (!ns)
+				break;
+			i++;
+			ns >>= 1;
+		}
+	}
+	return i;
+}
+
+void nfsd_stats_post(struct svc_rqst *rqstp)
+{
+	int tb = -1;
+	struct timespec svctime;
+
+	/* calculate service time and update the stats */
+	if (svc_time_elapsed(&rqstp->rq_start_time, &svctime) == 0)
+		tb = time_bucket(&svctime);
+
+	/* interesting things happen here 2 patches hence */
+}
+
 
 void
 nfsd_stat_init(void)
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -41,7 +41,60 @@ struct nfsd_stats {
 };
 
 struct nfsd_op_stats {
-	/* nothing to see here, yet */
+#define NFSD_STATS_OP_FSINFO	0	/* includes NULLPROC,FSSTAT,FSINFO,
+					 * PATHCONF,ROOT(v2),WRITECACHE(v2) */
+#define NFSD_STATS_OP_MKINODE	1	/* includes CREATE,MKDIR,SYMLINK,
+					 * MKNOD,RENAME,LINK */
+#define NFSD_STATS_OP_GETATTR	2
+#define NFSD_STATS_OP_SETATTR	3
+#define NFSD_STATS_OP_LOOKUP	4
+#define NFSD_STATS_OP_ACCESS	5
+#define NFSD_STATS_OP_READ	6	/* includes READ,READLINK */
+#define NFSD_STATS_OP_SWRITE	7	/* sync WRITEs */
+#define NFSD_STATS_OP_AWRITE	8	/* async WRITEs */
+#define NFSD_STATS_OP_COMMIT	9
+#define NFSD_STATS_OP_REMOVE	10
+#define NFSD_STATS_OP_RMDIR	11
+#define NFSD_STATS_OP_READDIR	12
+#define NFSD_STATS_OP_READDIRP	13
+#define NFSD_STATS_OP_XATTR	14	/* includes all NFSACL ops too */
+#define NFSD_STATS_OP_LOCKD	15	/* all LOCKD ops except: */
+#define NFSD_STATS_OP_SHARE	16	/* includes LOCKD's SHARE,UNSHARE */
+#define NFSD_STATS_OP_GRANTED	17	/* includes LOCKD' GRANTED */
+#define NFSD_STATS_OP_NUM	18
+	unsigned long	os_ops[NFSD_STATS_OP_NUM];
+	unsigned long	os_bytes_in;
+	unsigned long	os_bytes_out;
+#define NFSD_STATS_SIZE_LE4K		0
+#define NFSD_STATS_SIZE_LE8K		1
+#define NFSD_STATS_SIZE_LE16K		2
+#define NFSD_STATS_SIZE_LE32K		3
+#define NFSD_STATS_SIZE_LE64K		4
+#define NFSD_STATS_SIZE_LE128K		5
+#define NFSD_STATS_SIZE_LE256K		6
+#define NFSD_STATS_SIZE_LE512K		7
+#define NFSD_STATS_SIZE_GT512K		8
+#define NFSD_STATS_SIZE_NUM		9
+	unsigned long	os_read_sizes[NFSD_STATS_SIZE_NUM];
+	unsigned long	os_write_sizes[NFSD_STATS_SIZE_NUM];
+#define NFSD_STATS_TRANSPORT_UDP	0
+#define NFSD_STATS_TRANSPORT_TCP	1
+#define NFSD_STATS_TRANSPORT_RDMA	2
+#define NFSD_STATS_TRANSPORT_NUM	3
+	unsigned long	os_transports[NFSD_STATS_TRANSPORT_NUM];
+#define NFSD_STATS_VERSION_V2		0
+#define NFSD_STATS_VERSION_V3		1
+#define NFSD_STATS_VERSION_V4		2
+#define NFSD_STATS_VERSION_NUM		3
+	unsigned long	os_versions[NFSD_STATS_VERSION_NUM];
+#define NFSD_STATS_SVCTIME_LE256US	0
+#define NFSD_STATS_SVCTIME_LE1MS	1
+#define NFSD_STATS_SVCTIME_LE4MS	2
+#define NFSD_STATS_SVCTIME_LE16MS	3
+#define NFSD_STATS_SVCTIME_LE64MS	4
+#define NFSD_STATS_SVCTIME_GT64MS	5
+#define NFSD_STATS_SVCTIME_NUM		6
+	unsigned long	os_service_times[NFSD_STATS_SVCTIME_NUM];
 };
 
 
@@ -88,6 +141,58 @@ nfsd_stats_get(nfsd_stats_hentry_t *se)
 }
 extern void nfsd_stats_put(nfsd_stats_hentry_t *se);
 
+extern void nfsd_stats_update_op(struct svc_rqst *rqstp, struct svc_fh *fh,
+				 int rbucket, int wbucket, int op);
+
+static inline void nfsd_stats_update(struct svc_rqst *rqstp, struct svc_fh *fh,
+				     int op)
+{
+	nfsd_stats_update_op(rqstp, fh, -1, -1, op);
+}
+
+static inline int nfsd_stats_size_bucket(unsigned int size)
+{
+	int i = 0;
+
+	if (size) {
+		size = (size-1) >> 12;	/* smallest bucket is 4K */
+		while (i < NFSD_STATS_SIZE_NUM-1)
+		{
+			if (!size)
+				break;
+			i++;
+			size >>= 1;
+		}
+	}
+	return i;
+}
+
+static inline void nfsd_stats_update_read(struct svc_rqst *rqstp,
+					  struct svc_fh *fh,
+					  unsigned int size)
+{
+	nfsd_stats_update_op(rqstp,fh,
+			     nfsd_stats_size_bucket(size),
+			     /*wbucket*/-1,
+			     NFSD_STATS_OP_READ);
+}
+
+static inline void nfsd_stats_update_write(struct svc_rqst *rqstp,
+					   struct svc_fh *fh,
+					   unsigned int size, int stable)
+{
+	nfsd_stats_update_op(rqstp,fh,
+			     /*rbucket*/-1,
+			     nfsd_stats_size_bucket(size),
+			     (stable ? NFSD_STATS_OP_SWRITE :
+				       NFSD_STATS_OP_AWRITE));
+}
+/* nfsd calls this before servicing a request */
+void nfsd_stats_pre(struct svc_rqst *rqstp);
+/* nfsd calls this after servicing a request */
+void nfsd_stats_post(struct svc_rqst *rqstp);
+
+
 
 
 #endif /* __KERNEL__ */
Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -290,6 +290,7 @@ struct svc_rqst {
 	wait_queue_head_t	rq_wait;	/* synchronization */
 	struct task_struct	*rq_task;	/* service thread */
 	int			rq_waking;	/* 1 if thread is being woken */
+	struct svc_time		rq_start_time;
 };
 
 /*
Index: bfields/fs/nfsd/nfssvc.c
===================================================================
--- bfields.orig/fs/nfsd/nfssvc.c
+++ bfields/fs/nfsd/nfssvc.c
@@ -468,8 +468,12 @@ nfsd(void *vrqstp)
 		/* Lock the export hash tables for reading. */
 		exp_readlock();
 
+		nfsd_stats_pre(rqstp);
+
 		svc_process(rqstp);
 
+		nfsd_stats_post(rqstp);
+
 		/* Unlock export hash tables */
 		exp_readunlock();
 	}

--
Greg
