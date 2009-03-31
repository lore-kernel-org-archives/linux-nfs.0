From: Greg Banks <gnb@sgi.com>
Subject: [patch 06/29] knfsd: Gather per-export stats
Date: Wed, 01 Apr 2009 07:28:06 +1100
Message-ID: <20090331202940.087008000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22584 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761779AbZCaVCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uses the new stats infrastructure to record and export NFS statistics
on a per-export basis.  The export is chosen according to the first
filehandle presented in the incoming call.  If an NFSv4 call references
filehandles on multiple exports, all statistics will be recorded
against the first one.  If the call does not reference any filehandles
(e.g. NFSv3 NULL call), it will not be counted in the per-export stats
(although later it will be counted in the per-client stats).

A file /proc/fs/nfsd/export_stats is provided to allow userspace
programs to read the statistics.

To avoid a hash lookup in a locked global table on every operation,
the stats entry is cached on the struct svc_export.

Contains code based on a patch from Harshula Jayasuriya <harshula@sgi.com>.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/export.c            |   33 +++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c            |   15 ++++++++++++++
 fs/nfsd/stats.c             |   35 +++++++++++++++++++++++++++++++--
 include/linux/nfsd/export.h |    1 
 include/linux/nfsd/stats.h  |    1 
 include/linux/sunrpc/svc.h  |    1 
 6 files changed, 84 insertions(+), 2 deletions(-)

Index: bfields/fs/nfsd/export.c
===================================================================
--- bfields.orig/fs/nfsd/export.c
+++ bfields/fs/nfsd/export.c
@@ -27,6 +27,7 @@
 #include <linux/hash.h>
 #include <linux/module.h>
 #include <linux/exportfs.h>
+#include <linux/list.h>
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
@@ -44,6 +45,7 @@ typedef struct svc_export	svc_export;
 
 static void		exp_do_unexport(svc_export *unexp);
 static int		exp_verify_string(char *cp, int max);
+static nfsd_stats_hentry_t *exp_stats_find(struct path *);
 
 /*
  * We have two caches.
@@ -333,6 +335,8 @@ static void svc_export_put(struct kref *
 	auth_domain_put(exp->ex_client);
 	kfree(exp->ex_pathname);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
+	if (exp->ex_stats)
+		nfsd_stats_put(exp->ex_stats);
 	kfree(exp);
 }
 
@@ -673,6 +677,34 @@ static int svc_export_match(struct cache
 		orig->ex_path.mnt == new->ex_path.mnt;
 }
 
+/*
+ * Find and return a stats hentry in the export stats hash,
+ * given the mount+dentry for the export, creating it if
+ * necessary.  Will return NULL on OOM or if stats disabled.
+ */
+static nfsd_stats_hentry_t *exp_stats_find(struct path *pp)
+{
+	char *buf, *pathname;
+	int len;
+	nfsd_stats_hentry_t *se = NULL;
+
+	dprintk("exp_stats_find: mnt %p dentry %p\n", pp->mnt, pp->dentry);
+
+	/* construct the export's path in a temporary page */
+	buf = (char *)__get_free_page(GFP_KERNEL);
+	if (buf == NULL)
+		return NULL;
+
+	pathname = d_path(pp, buf, PAGE_SIZE);
+	if (!IS_ERR(pathname)) {
+		len = buf + PAGE_SIZE - 1 - pathname;
+		se = nfsd_stats_find(&nfsd_export_stats_hash, pathname, len);
+	}
+
+	free_page((unsigned long)buf);
+	return se;
+}
+
 static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 {
 	struct svc_export *new = container_of(cnew, struct svc_export, h);
@@ -686,6 +718,7 @@ static void svc_export_init(struct cache
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
+	new->ex_stats = exp_stats_find(&new->ex_path);
 }
 
 static void export_update(struct cache_head *cnew, struct cache_head *citem)
Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -49,6 +49,7 @@ struct svc_stat		nfsd_svcstats = {
 	.program	= &nfsd_program,
 };
 
+nfsd_stats_hash_t nfsd_export_stats_hash;
 int nfsd_stats_enabled = 1;
 int nfsd_stats_prune_period = 2*86400;
 
@@ -384,15 +385,34 @@ static void __nfsd_stats_op(struct svc_r
 void nfsd_stats_update_op(struct svc_rqst *rqstp, struct svc_fh *fh,
 			  int rbucket, int wbucket, int op)
 {
+    	nfsd_stats_hentry_t *se;
+
 	if (!nfsd_stats_enabled)
 		return;
 
-	/* interesting things happen here 2 patches hence */
+	/* first op in the call: find and cache per-export stats */
+	if (fh != NULL &&
+	    fh->fh_export != NULL &&
+	    (se = fh->fh_export->ex_stats) != NULL &&
+	    rqstp->rq_export_stats == NULL) {
+		/*
+		 * We want the stats to survive fh_put() of the filehandle
+		 * so we can update os_bytes_out and service time in
+		 * nfsd_stats_post().  So grab a reference here.
+		 */
+		nfsd_stats_get(se);
+		rqstp->rq_export_stats = se;
+		__nfsd_stats_begin_call(rqstp, se);
+	}
+	/* all ops in the call: update per-export stats */
+	if (rqstp->rq_export_stats)
+		__nfsd_stats_op(rqstp, rqstp->rq_export_stats, rbucket, wbucket, op);
 }
 
 void nfsd_stats_pre(struct svc_rqst *rqstp)
 {
 	svc_time_mark(&rqstp->rq_start_time);
+	rqstp->rq_export_stats = NULL;
 }
 
 static inline int time_bucket(const struct timespec *ts)
@@ -418,11 +438,18 @@ void nfsd_stats_post(struct svc_rqst *rq
 	int tb = -1;
 	struct timespec svctime;
 
+	if (rqstp->rq_export_stats == NULL)
+		return;
+
 	/* calculate service time and update the stats */
 	if (svc_time_elapsed(&rqstp->rq_start_time, &svctime) == 0)
 		tb = time_bucket(&svctime);
 
-	/* interesting things happen here 2 patches hence */
+	if (rqstp->rq_export_stats != NULL) {
+		__nfsd_stats_end_call(rqstp, rqstp->rq_export_stats, tb);
+		nfsd_stats_put(rqstp->rq_export_stats);
+		rqstp->rq_export_stats = NULL;
+	}
 }
 
 
@@ -603,10 +630,14 @@ void
 nfsd_stat_init(void)
 {
 	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
+
+	nfsd_stats_hash_init(&nfsd_export_stats_hash, "export");
 }
 
 void
 nfsd_stat_shutdown(void)
 {
 	svc_proc_unregister("nfsd");
+
+	nfsd_stats_hash_destroy(&nfsd_export_stats_hash);
 }
Index: bfields/include/linux/nfsd/export.h
===================================================================
--- bfields.orig/include/linux/nfsd/export.h
+++ bfields/include/linux/nfsd/export.h
@@ -92,6 +92,7 @@ struct svc_export {
 	struct nfsd4_fs_locations ex_fslocs;
 	int			ex_nflavors;
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
+	struct nfsd_stats_hentry *ex_stats;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -135,6 +135,7 @@ struct nfsd_stats_hiter {
 
 extern struct nfsd_stats	nfsdstats;
 extern struct svc_stat		nfsd_svcstats;
+extern nfsd_stats_hash_t	nfsd_export_stats_hash;
 
 void	nfsd_stat_init(void);
 void	nfsd_stat_shutdown(void);
Index: bfields/fs/nfsd/nfsctl.c
===================================================================
--- bfields.orig/fs/nfsd/nfsctl.c
+++ bfields/fs/nfsd/nfsctl.c
@@ -66,6 +66,7 @@ enum {
 	NFSD_MaxBlkSize,
 	NFSD_Stats_Enabled,
 	NFSD_Stats_Prune_Period,
+	NFSD_Export_Stats,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -179,6 +180,19 @@ static const struct file_operations expo
 	.owner		= THIS_MODULE,
 };
 
+static int export_stats_open(struct inode *inode, struct file *file)
+{
+	return nfsd_stats_open(file, &nfsd_export_stats_hash);
+}
+
+static struct file_operations export_stats_operations = {
+	.open		= export_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+	.owner		= THIS_MODULE,
+};
+
 extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
 
 static struct file_operations pool_stats_operations = {
@@ -1362,6 +1376,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_Stats_Enabled] = {"stats_enabled", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_Stats_Prune_Period] = {"stats_prune_period", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_Export_Stats] = {"export_stats", &export_stats_operations, S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
Index: bfields/include/linux/sunrpc/svc.h
===================================================================
--- bfields.orig/include/linux/sunrpc/svc.h
+++ bfields/include/linux/sunrpc/svc.h
@@ -291,6 +291,7 @@ struct svc_rqst {
 	struct task_struct	*rq_task;	/* service thread */
 	int			rq_waking;	/* 1 if thread is being woken */
 	struct svc_time		rq_start_time;
+	struct nfsd_stats_hentry *rq_export_stats;
 };
 
 /*

--
Greg
