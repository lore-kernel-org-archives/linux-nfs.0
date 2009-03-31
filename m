From: Greg Banks <gnb@sgi.com>
Subject: [patch 05/29] knfsd: Infrastructure for providing stats to userspace
Date: Wed, 01 Apr 2009 07:28:05 +1100
Message-ID: <20090331202939.751001000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22570 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754094AbZCaVCe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added iteration and seq_file infrastructure to allow implementing
a /proc file which exports all the entries in a stats hashtable as
text to userspace.  Function nfsd_stats_open() is called in the /proc
file's open method and handles all the subsequent details.

Like all RPC statistics, the format is designed to be easy to parse
in shell scripts and C code.  Counter values are presented in text
form, grouped into lines which start with a two-letter keyword.
For example, the line "by 2680 487656" shows that 2680 bytes of NFS
calls have been received and 487656 bytes of replies have been sent.
The special "nm" keyword starts a new entry and shows it's internal
name, e.g. "nm 192.168.67.45" in the per-client statistics file will
begin the entry for the client whose IP address is 192.168.67.45.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/stats.c            |  173 ++++++++++++++++++++++++++++++++++
 include/linux/nfsd/stats.h |   11 ++
 2 files changed, 184 insertions(+)

Index: bfields/fs/nfsd/stats.c
===================================================================
--- bfields.orig/fs/nfsd/stats.c
+++ bfields/fs/nfsd/stats.c
@@ -426,6 +426,179 @@ void nfsd_stats_post(struct svc_rqst *rq
 }
 
 
+static nfsd_stats_hentry_t *nfsd_stats_hiter_first(nfsd_stats_hiter_t *itr)
+{
+	for (itr->bucket = 0 ;
+	     itr->bucket < itr->sh->sh_size ;
+	     itr->bucket++) {
+		struct hlist_head *hh = &itr->sh->sh_hash[itr->bucket];
+		if (hh->first != NULL)
+			return hentry_from_hnode(hh->first);
+	}
+	return NULL;
+}
+
+static nfsd_stats_hentry_t *nfsd_stats_hiter_next(nfsd_stats_hiter_t *itr,
+						  nfsd_stats_hentry_t *se)
+{
+	struct hlist_head *hh;
+
+	for (;;) {
+		if (se->se_node.next != NULL)
+			return hentry_from_hnode(se->se_node.next);
+		if (++itr->bucket >= itr->sh->sh_size)
+			return NULL;	/* finished iterating */
+		hh = &itr->sh->sh_hash[itr->bucket];
+		if (hh->first != NULL)
+			return hentry_from_hnode(hh->first);
+	}
+}
+
+static nfsd_stats_hentry_t *nfsd_stats_hiter_seek(nfsd_stats_hiter_t *itr,
+						  loff_t pos)
+{
+	nfsd_stats_hentry_t *se;
+
+	for (se = nfsd_stats_hiter_first(itr) ;
+	     se != NULL ;
+	     se = nfsd_stats_hiter_next(itr, se)) {
+		if (!--pos)
+			return se;
+	}
+	return NULL;
+}
+
+static void *nfsd_stats_start(struct seq_file *m, loff_t *pos)
+{
+	nfsd_stats_hiter_t *itr = m->private;
+
+	dprintk("nfsd_stats_start, *pos=%d\n", (int)*pos);
+	down_read(&itr->sh->sh_sem);
+
+	if (!*pos)
+		return SEQ_START_TOKEN;
+
+	return nfsd_stats_hiter_seek(itr, *pos);
+}
+
+static void *nfsd_stats_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	nfsd_stats_hiter_t *itr = m->private;
+	nfsd_stats_hentry_t *se = p;
+
+	dprintk("nfsd_stats_next, *pos=%llu bucket=%d\n", *pos, itr->bucket);
+
+	if (p == SEQ_START_TOKEN)
+		se = nfsd_stats_hiter_first(itr);
+	else
+		se = nfsd_stats_hiter_next(itr, se);
+	++*pos;
+	return se;
+}
+
+static void nfsd_stats_stop(struct seq_file *m, void *p)
+{
+	nfsd_stats_hiter_t *itr = m->private;
+
+	up_read(&itr->sh->sh_sem);
+}
+
+static int nfsd_stats_show(struct seq_file *m, void *p)
+{
+	nfsd_stats_hentry_t *se = p;
+	struct nfsd_op_stats *os = &se->se_data;
+	int i;
+
+	if (p == SEQ_START_TOKEN) {
+		seq_puts(m, "# Version 1.0\n");
+		return 0;
+	}
+
+	dprintk("nfsd_stats_show %s\n",  se->se_name);
+
+	seq_puts(m, "nm ");
+	seq_escape(m, se->se_name, " \t\n\\");
+	seq_printf(m, "\n");
+
+	/* histogram of operations */
+	seq_puts(m, "op");
+	for (i = 0 ; i < NFSD_STATS_OP_NUM ; i++)
+		seq_printf(m, " %lu", os->os_ops[i]);
+	seq_putc(m, '\n');
+
+	/* bytes in and out */
+	seq_printf(m, "by %lu %lu\n", os->os_bytes_in, os->os_bytes_out);
+
+	/* histogram of read sizes */
+	seq_puts(m, "rs");
+	for (i = 0 ; i < NFSD_STATS_SIZE_NUM ; i++)
+		seq_printf(m, " %lu", os->os_read_sizes[i]);
+	seq_putc(m, '\n');
+
+	/* histogram of write sizes */
+	seq_puts(m, "ws");
+	for (i = 0 ; i < NFSD_STATS_SIZE_NUM ; i++)
+		seq_printf(m, " %lu", os->os_write_sizes[i]);
+	seq_putc(m, '\n');
+
+	/* counts of operations by transport */
+	seq_printf(m, "tr udp %lu\n",
+		   os->os_transports[NFSD_STATS_TRANSPORT_UDP]);
+	seq_printf(m, "tr tcp %lu\n",
+		   os->os_transports[NFSD_STATS_TRANSPORT_TCP]);
+#if defined(CONFIG_NFSD_RDMA) || defined(CONFIG_NFSD_RDMA_MODULE)
+	seq_printf(m, "tr rdma %lu\n",
+		   os->os_transports[NFSD_STATS_TRANSPORT_RDMA]);
+#endif
+
+	/* counts of operations by version */
+	seq_printf(m, "ve 2 %lu\n",
+		   os->os_versions[NFSD_STATS_VERSION_V2]);
+	seq_printf(m, "ve 3 %lu\n",
+		   os->os_versions[NFSD_STATS_VERSION_V3]);
+	seq_printf(m, "ve 4 %lu\n",
+		   os->os_versions[NFSD_STATS_VERSION_V4]);
+
+	/* histogram of service times */
+	seq_puts(m, "st");
+	for (i = 0 ; i < NFSD_STATS_SVCTIME_NUM ; i++)
+		seq_printf(m, " %lu", os->os_service_times[i]);
+	seq_putc(m, '\n');
+
+	return 0;
+}
+
+static struct seq_operations nfsd_stats_seq_ops = {
+	.start	= nfsd_stats_start,
+	.next	= nfsd_stats_next,
+	.stop	= nfsd_stats_stop,
+	.show	= nfsd_stats_show,
+};
+
+int nfsd_stats_open(struct file *file, nfsd_stats_hash_t *sh)
+{
+	int err;
+	nfsd_stats_hiter_t *itr;
+
+	if (sh->sh_hash == NULL)
+		return -ENOENT;
+
+	if ((itr = kmalloc(sizeof(*itr), GFP_KERNEL)) == NULL)
+		return -ENOMEM;
+
+	if ((err = seq_open(file, &nfsd_stats_seq_ops))) {
+		kfree(itr);
+		return err;
+	}
+
+	itr->sh = sh;
+	itr->bucket = 0;
+	((struct seq_file *) file->private_data)->private = itr;
+
+	return 0;
+}
+
+
 void
 nfsd_stat_init(void)
 {
Index: bfields/include/linux/nfsd/stats.h
===================================================================
--- bfields.orig/include/linux/nfsd/stats.h
+++ bfields/include/linux/nfsd/stats.h
@@ -100,6 +100,7 @@ struct nfsd_op_stats {
 
 typedef struct nfsd_stats_hash		nfsd_stats_hash_t;
 typedef struct nfsd_stats_hentry	nfsd_stats_hentry_t;
+typedef struct nfsd_stats_hiter		nfsd_stats_hiter_t;
 
 /* Entry in the export and client stats hashtables */
 struct nfsd_stats_hentry {
@@ -125,6 +126,13 @@ struct nfsd_stats_hash {
 	struct timer_list	sh_prune_timer;
 };
 
+/* Hashtable iteration state used during seq_file traversal */
+struct nfsd_stats_hiter {
+	nfsd_stats_hash_t *sh;
+	int bucket;
+};
+
+
 extern struct nfsd_stats	nfsdstats;
 extern struct svc_stat		nfsd_svcstats;
 
@@ -192,6 +200,9 @@ void nfsd_stats_pre(struct svc_rqst *rqs
 /* nfsd calls this after servicing a request */
 void nfsd_stats_post(struct svc_rqst *rqstp);
 
+/* open the hash for a seq_file pass to userspace */
+int nfsd_stats_open(struct file *file, nfsd_stats_hash_t *sh);
+
 
 
 

--
Greg
