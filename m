From: Greg Banks <gnb@sgi.com>
Subject: [patch 24/29] knfsd: remove the program field from struct svc_stat
Date: Wed, 01 Apr 2009 07:28:24 +1100
Message-ID: <20090331202946.875714000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22578 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761518AbZCaVCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the `program' field from the svc_stat structure.  This field
is an anachronism dating from the days when each svc_serv could
only support a single svc_program, and doesn't make sense anymore.
Change the arguments of svc_proc_register() and svc_seq_show() to
remove the uses of svc_stat.program.

This is a preliminary step towards making the NFS server statistics
be gathered per-CPU.

Signed-off-by: Greg Banks <gnb@sgi.com>
Reviewed-by: David Chinner <dgc@sgi.com>
Reviewed-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

 fs/nfsd/nfssvc.c             |    4 +---
 fs/nfsd/stats.c              |    9 ++++-----
 include/linux/sunrpc/stats.h |   12 ++++++------
 net/sunrpc/stats.c           |   11 +++++++----
 4 files changed, 18 insertions(+), 18 deletions(-)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -56,9 +56,7 @@ static inline void nfsd_stats_prefetch(n
 
 
 struct nfsd_stats	nfsdstats;
-struct svc_stat		nfsd_svcstats = {
-	.program	= &nfsd_program,
-};
+struct svc_stat		nfsd_svcstats;
 
 nfsd_stats_hash_t nfsd_export_stats_hash;
 nfsd_stats_hash_t nfsd_client_stats_hash;
@@ -95,7 +93,8 @@ static int nfsd_proc_show(struct seq_fil
 	seq_putc(seq, '\n');
 	
 	/* show my rpc info */
-	svc_seq_show(seq, &nfsd_svcstats);
+	if (nfsd_serv)
+		svc_seq_show(seq, nfsd_serv);
 
 #ifdef CONFIG_NFSD_V4
 	/* Show count for individual nfsv4 operations */
@@ -713,7 +712,7 @@ int nfsd_stats_open(struct file *file, n
 void
 nfsd_stat_init(void)
 {
-	svc_proc_register(&nfsd_svcstats, &nfsd_proc_fops);
+	svc_proc_register("nfsd", &nfsd_proc_fops);
 
 	nfsd_stats_hash_init(&nfsd_export_stats_hash, "export");
 	nfsd_stats_hash_init(&nfsd_client_stats_hash, "client");
Index: bfields/include/linux/sunrpc/stats.h
===================================================================
--- bfields.orig/include/linux/sunrpc/stats.h
+++ bfields/include/linux/sunrpc/stats.h
@@ -26,8 +26,6 @@ struct rpc_stat {
 };
 
 struct svc_stat {
-	struct svc_program *	program;
-
 	unsigned int		netcnt,
 				netudpcnt,
 				nettcpcnt,
@@ -44,16 +42,18 @@ void			rpc_proc_exit(void);
 void			rpc_modcount(struct inode *, int);
 #endif
 
+struct svc_serv;    /* forward declare to shut up compiler */
+
 #ifdef CONFIG_PROC_FS
 struct proc_dir_entry *	rpc_proc_register(struct rpc_stat *);
 void			rpc_proc_unregister(const char *);
 void			rpc_proc_zero(struct rpc_program *);
-struct proc_dir_entry *	svc_proc_register(struct svc_stat *,
+struct proc_dir_entry *	svc_proc_register(const char *,
 					  const struct file_operations *);
 void			svc_proc_unregister(const char *);
 
 void			svc_seq_show(struct seq_file *,
-				     const struct svc_stat *);
+				     const struct svc_serv *);
 
 extern struct proc_dir_entry	*proc_net_rpc;
 
@@ -63,12 +63,12 @@ static inline struct proc_dir_entry *rpc
 static inline void rpc_proc_unregister(const char *p) {}
 static inline void rpc_proc_zero(struct rpc_program *p) {}
 
-static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s,
+static inline struct proc_dir_entry *svc_proc_register(const char *s,
 						       const struct file_operations *f) { return NULL; }
 static inline void svc_proc_unregister(const char *p) {}
 
 static inline void svc_seq_show(struct seq_file *seq,
-				const struct svc_stat *st) {}
+				const struct svc_serv *) {}
 
 #define proc_net_rpc NULL
 
Index: bfields/net/sunrpc/stats.c
===================================================================
--- bfields.orig/net/sunrpc/stats.c
+++ bfields/net/sunrpc/stats.c
@@ -77,8 +77,11 @@ static const struct file_operations rpc_
 /*
  * Get RPC server stats
  */
-void svc_seq_show(struct seq_file *seq, const struct svc_stat *statp) {
-	const struct svc_program *prog = statp->program;
+void svc_seq_show(struct seq_file *seq, const struct svc_serv *serv)
+{
+	/* TODO: report call counts from the non-primary programs */
+	const struct svc_program *prog = serv->sv_program;
+	struct svc_stat *statp = serv->sv_stats;
 	const struct svc_procedure *proc;
 	const struct svc_version *vers;
 	unsigned int i, j;
@@ -245,9 +248,9 @@ rpc_proc_unregister(const char *name)
 EXPORT_SYMBOL_GPL(rpc_proc_unregister);
 
 struct proc_dir_entry *
-svc_proc_register(struct svc_stat *statp, const struct file_operations *fops)
+svc_proc_register(const char *name, const struct file_operations *fops)
 {
-	return do_register(statp->program->pg_name, statp, fops);
+	return do_register(name, NULL, fops);
 }
 EXPORT_SYMBOL_GPL(svc_proc_register);
 
Index: bfields/fs/nfsd/nfssvc.c
===================================================================
--- bfields.orig/fs/nfsd/nfssvc.c
+++ bfields/fs/nfsd/nfssvc.c
@@ -88,9 +88,7 @@ static struct svc_program	nfsd_acl_progr
 	.pg_authenticate	= &svc_set_client,
 };
 
-static struct svc_stat	nfsd_acl_svcstats = {
-	.program	= &nfsd_acl_program,
-};
+static struct svc_stat	nfsd_acl_svcstats;
 #endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
 
 static struct svc_version *	nfsd_version[] = {

--
Greg
