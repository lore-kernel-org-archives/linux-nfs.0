Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35690 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412AbbKQLxc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:32 -0500
Received: by qgec40 with SMTP id c40so3391317qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:31 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 13/38] nfsd: keep some rudimentary stats on nfsd_file cache
Date: Tue, 17 Nov 2015 06:52:35 -0500
Message-Id: <1447761180-4250-14-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Per chain count and max length, protected by the per-chain spinlock.
When the file is read, we walk the array of buckets and fetch the
count from each.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/filecache.h |  1 +
 fs/nfsd/nfsctl.c    | 10 ++++++++++
 3 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index f6c4480c5d78..f6adccc6f740 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -11,6 +11,7 @@
 #include <linux/sched.h>
 #include <linux/list_lru.h>
 #include <linux/fsnotify_backend.h>
+#include <linux/seq_file.h>
 
 #include "vfs.h"
 #include "nfsd.h"
@@ -30,8 +31,12 @@
 struct nfsd_fcache_bucket {
 	struct hlist_head	nfb_head;
 	spinlock_t		nfb_lock;
+	unsigned int		nfb_count;
+	unsigned int		nfb_maxcount;
 };
 
+static DEFINE_PER_CPU(unsigned long, nfsd_file_cache_hits);
+
 static struct kmem_cache		*nfsd_file_slab;
 static struct kmem_cache		*nfsd_file_mark_slab;
 static struct nfsd_fcache_bucket	*nfsd_file_hashtbl;
@@ -172,6 +177,7 @@ nfsd_file_unhash(struct nfsd_file *nf)
 
 	trace_nfsd_file_unhash(nf);
 	if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
+		--nfsd_file_hashtbl[nf->nf_hashval].nfb_count;
 		clear_bit(NFSD_FILE_HASHED, &nf->nf_flags);
 		hlist_del_rcu(&nf->nf_node);
 		list_lru_del(&nfsd_file_lru, &nf->nf_lru);
@@ -562,8 +568,10 @@ retry:
 	rcu_read_lock();
 	nf = nfsd_file_find_locked(inode, may_flags, hashval);
 	rcu_read_unlock();
-	if (nf)
+	if (nf) {
+		this_cpu_inc(nfsd_file_cache_hits);
 		goto wait_for_construction;
+	}
 
 	if (!new) {
 		new = nfsd_file_alloc(inode, may_flags, hashval);
@@ -584,11 +592,15 @@ retry:
 		list_lru_add(&nfsd_file_lru, &new->nf_lru);
 		hlist_add_head_rcu(&new->nf_node,
 				&nfsd_file_hashtbl[hashval].nfb_head);
+		++nfsd_file_hashtbl[hashval].nfb_count;
+		nfsd_file_hashtbl[hashval].nfb_maxcount = max(nfsd_file_hashtbl[hashval].nfb_maxcount,
+				nfsd_file_hashtbl[hashval].nfb_count);
 		spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
 		nf = new;
 		new = NULL;
 		goto open_file;
 	}
+	this_cpu_inc(nfsd_file_cache_hits);
 	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
 
 wait_for_construction:
@@ -666,3 +678,41 @@ open_file:
 	wake_up_bit(&nf->nf_flags, NFSD_FILE_PENDING);
 	goto out;
 }
+
+/*
+ * Note that fields may be added, removed or reordered in the future. Programs
+ * scraping this file for info should test the labels to ensure they're
+ * getting the correct field.
+ */
+static int nfsd_file_cache_stats_show(struct seq_file *m, void *v)
+{
+	unsigned int i, count = 0, longest = 0;
+	unsigned long hits = 0;
+
+	/*
+	 * No need for spinlocks here since we're not terribly interested in
+	 * accuracy. We do take the nfsd_mutex simply to ensure that we
+	 * don't end up racing with server shutdown
+	 */
+	mutex_lock(&nfsd_mutex);
+	if (nfsd_file_hashtbl) {
+		for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
+			count += nfsd_file_hashtbl[i].nfb_count;
+			longest = max(longest, nfsd_file_hashtbl[i].nfb_count);
+		}
+	}
+	mutex_unlock(&nfsd_mutex);
+
+	for_each_possible_cpu(i)
+		hits += per_cpu(nfsd_file_cache_hits, i);
+
+	seq_printf(m, "total entries: %u\n", count);
+	seq_printf(m, "longest chain: %u\n", longest);
+	seq_printf(m, "cache hits:    %lu\n", hits);
+	return 0;
+}
+
+int nfsd_file_cache_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, nfsd_file_cache_stats_show, NULL);
+}
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index a045c7fe3655..756aea5431da 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -40,4 +40,5 @@ struct nfsd_file *nfsd_file_get(struct nfsd_file *nf);
 void nfsd_file_close_inode_sync(struct inode *inode);
 __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  unsigned int may_flags, struct nfsd_file **nfp);
+int	nfsd_file_cache_stats_open(struct inode *, struct file *);
 #endif /* _FS_NFSD_FILECACHE_H */
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9690cb4dd588..eff44a277f70 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -22,6 +22,7 @@
 #include "state.h"
 #include "netns.h"
 #include "pnfs.h"
+#include "filecache.h"
 
 /*
  *	We have a single directory with several nodes in it.
@@ -36,6 +37,7 @@ enum {
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Pool_Stats,
+	NFSD_File_Cache_Stats,
 	NFSD_Reply_Cache_Stats,
 	NFSD_Versions,
 	NFSD_Ports,
@@ -220,6 +222,13 @@ static const struct file_operations pool_stats_operations = {
 	.owner		= THIS_MODULE,
 };
 
+static struct file_operations file_cache_stats_operations = {
+	.open		= nfsd_file_cache_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static struct file_operations reply_cache_stats_operations = {
 	.open		= nfsd_reply_cache_stats_open,
 	.read		= seq_read,
@@ -1138,6 +1147,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Stats] = {"pool_stats", &pool_stats_operations, S_IRUGO},
+		[NFSD_File_Cache_Stats] = {"file_cache_stats", &file_cache_stats_operations, S_IRUGO},
 		[NFSD_Reply_Cache_Stats] = {"reply_cache_stats", &reply_cache_stats_operations, S_IRUGO},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
-- 
2.4.3

