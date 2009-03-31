From: Greg Banks <gnb@sgi.com>
Subject: [patch 08/29] knfsd: Gather per-client stats
Date: Wed, 01 Apr 2009 07:28:08 +1100
Message-ID: <20090331202940.748845000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22580 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762218AbZCaVCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uses the new stats infrastructure to record and export NFS statistics
on a per-client basis.  

A file /proc/fs/nfsd/client_stats is provided to allow userspace
programs to read the statistics.

Unfortunately, we use a hash lookup in a locked global table on
every operation.  The next patch avoids that for the common TCP case.

Contains code based on a patch from Harshula Jayasuriya <harshula@sgi.com>.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfsctl.c                |   15 ++++++++++++++
 fs/nfsd/stats.c                 |   30 ++++++++++++++++++++++++++++-
 include/linux/nfsd/stats.h      |    1 
 include/linux/sunrpc/svc.h      |    1 
 include/linux/sunrpc/svc_xprt.h |   28 +++++++++++++++++++++++++++
 5 files changed, 74 insertions(+), 1 deletion(-)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -37,6 +37,7 @@
 
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 
@@ -60,6 +61,7 @@ struct svc_stat		nfsd_svcstats = {
 };
 
 nfsd_stats_hash_t nfsd_export_stats_hash;
+nfsd_stats_hash_t nfsd_client_stats_hash;
 int nfsd_stats_enabled = 1;
 int nfsd_stats_prune_period = 2*86400;
 
@@ -418,12 +420,30 @@ void nfsd_stats_update_op(struct svc_rqs
 	/* all ops in the call: update per-export stats */
 	if (rqstp->rq_export_stats)
 		__nfsd_stats_op(rqstp, rqstp->rq_export_stats, rbucket, wbucket, op);
+
+	/* first op in the call: find and cache per-client stats */
+	if (rqstp->rq_client_stats == NULL) {
+		char *client, buf[SVC_FORMAT_ADDR_MAX];
+		se = NULL;
+		client = __svc_format_addr(svc_addr(rqstp), buf, sizeof(buf));
+		if (client != NULL)
+			se = nfsd_stats_find(&nfsd_client_stats_hash, client, strlen(client));
+		if (se != NULL) {
+			/* take over the new reference from nfsd_stats_find() */
+			rqstp->rq_client_stats = se;
+			__nfsd_stats_begin_call(rqstp, se);
+		}
+	}
+	/* all ops in the call: update per-client stats */
+	if (rqstp->rq_client_stats)
+		__nfsd_stats_op(rqstp, rqstp->rq_client_stats, rbucket, wbucket, op);
 }
 
 void nfsd_stats_pre(struct svc_rqst *rqstp)
 {
 	svc_time_mark(&rqstp->rq_start_time);
 	rqstp->rq_export_stats = NULL;
+	rqstp->rq_client_stats = NULL;
 }
 
 static inline int time_bucket(const struct timespec *ts)
@@ -449,7 +469,7 @@ void nfsd_stats_post(struct svc_rqst *rq
 	int tb = -1;
 	struct timespec svctime;
 
-	if (rqstp->rq_export_stats == NULL)
+	if (rqstp->rq_export_stats == NULL && rqstp->rq_client_stats == NULL)
 		return;
 
 	/* calculate service time and update the stats */
@@ -461,6 +481,12 @@ void nfsd_stats_post(struct svc_rqst *rq
 		nfsd_stats_put(rqstp->rq_export_stats);
 		rqstp->rq_export_stats = NULL;
 	}
+
+	if (rqstp->rq_client_stats != NULL) {
+		__nfsd_stats_end_call(rqstp, rqstp->rq_client_stats, tb);
+		nfsd_stats_put(rqstp->rq_client_stats);
+		rqstp->rq_client_stats = NULL;
+	}
 }
 
 
@@ -643,6 +669,7 @@ nfsd_stat_init(void)
 	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
 
 	nfsd_stats_hash_init(&nfsd_export_stats_hash, "export");
+	nfsd_stats_hash_init(&nfsd_client_stats_hash, "client");
 }
 
 void
@@ -651,4 +678,5 @@ nfsd_stat_shutdown(void)
 	svc_proc_unregister("nfsd");
 
 	nfsd_stats_hash_destroy(&nfsd_export_stats_hash);
+	nfsd_stats_hash_destroy(&nfsd_client_stats_hash);
 }
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -136,6 +136,7 @@ struct nfsd_stats_hiter {
 extern struct nfsd_stats	nfsdstats;
 extern struct svc_stat		nfsd_svcstats;
 extern nfsd_stats_hash_t	nfsd_export_stats_hash;
+extern nfsd_stats_hash_t	nfsd_client_stats_hash;
 
 void	nfsd_stat_init(void);
 void	nfsd_stat_shutdown(void);
Index: bfields/fs/nfsd/nfsctl.c
===================================================================
--- bfields.orig/fs/nfsd/nfsctl.c
+++ bfields/fs/nfsd/nfsctl.c
@@ -67,6 +67,7 @@ enum {
 	NFSD_Stats_Enabled,
 	NFSD_Stats_Prune_Period,
 	NFSD_Export_Stats,
+	NFSD_Client_Stats,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -1090,6 +1091,19 @@ static ssize_t write_ports(struct file *
 	return rv;
 }
 
+static int client_stats_open(struct inode *inode, struct file *file)
+{
+	return nfsd_stats_open(file, &nfsd_client_stats_hash);
+}
+
+static struct file_operations client_stats_operations = {
+	.open		= client_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+	.owner		= THIS_MODULE,
+};
+
 
 int nfsd_max_blksize;
 
@@ -1377,6 +1391,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Stats_Enabled] = {"stats_enabled", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_Stats_Prune_Period] = {"stats_prune_period", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_Export_Stats] = {"export_stats", &export_stats_operations, S_IRUGO},
+		[NFSD_Client_Stats] = {"client_stats", &client_stats_operations, S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -292,6 +292,7 @@ struct svc_rqst {
 	int			rq_waking;	/* 1 if thread is being woken */
 	struct svc_time		rq_start_time;
 	struct nfsd_stats_hentry *rq_export_stats;
+	struct nfsd_stats_hentry *rq_client_stats;
 };
 
 /*
Index: bfields/include/linux/sunrpc/svc_xprt.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc_xprt.h
+++ bfields/include/linux/sunrpc/svc_xprt.h
@@ -164,4 +164,32 @@ static inline char *__svc_print_addr(con
 
 	return buf;
 }
+
+/*
+ * Build a string describing the sockaddr, which is
+ * suitable for use as a unique client key.  Ignores
+ * the port.  Unlike __svc_print_addr(), may return
+ * NULL if the address cannot be decoded.
+ */
+#define SVC_FORMAT_ADDR_MAX	    42
+static inline char *__svc_format_addr(struct sockaddr *sa,
+				      char *buf, size_t len)
+{
+	switch (sa->sa_family) {
+	case AF_INET:
+		snprintf(buf, len, "%pI4",
+			&((struct sockaddr_in *)sa)->sin_addr);
+		break;
+
+	case AF_INET6:
+		snprintf(buf, len, "%pI6",
+			 &((struct sockaddr_in6 *)sa)->sin6_addr);
+		break;
+
+	default:
+		return NULL;
+	}
+	return buf;
+}
+
 #endif /* SUNRPC_SVC_XPRT_H */

--
Greg
