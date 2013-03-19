Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f49.google.com ([209.85.219.49]:48987 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161Ab3CSNL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 09:11:56 -0400
Received: by mail-oa0-f49.google.com with SMTP id j6so408331oag.8
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 06:11:56 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/6] nfsd: add new reply_cache_stats file in nfsdfs
Date: Tue, 19 Mar 2013 09:11:44 -0400
Message-Id: <1363698706-22036-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
References: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For presenting statistics relating to duplicate reply cache.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/cache.h    |  1 +
 fs/nfsd/nfscache.c | 25 +++++++++++++++++++++++++
 fs/nfsd/nfsctl.c   |  9 +++++++++
 3 files changed, 35 insertions(+)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 87fd141..d5c5b3e 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -82,6 +82,7 @@ int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
+int	nfsd_reply_cache_stats_open(struct inode *, struct file *);
 
 #ifdef CONFIG_NFSD_V4
 void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 1f45b33..fd81ca7 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -556,3 +556,28 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
 	vec->iov_len += data->iov_len;
 	return 1;
 }
+
+/*
+ * Note that fields may be added, removed or reordered in the future. Programs
+ * scraping this file for info should test the labels to ensure they're
+ * getting the correct field.
+ */
+static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
+{
+	spin_lock(&cache_lock);
+	seq_printf(m, "max entries:           %u\n", max_drc_entries);
+	seq_printf(m, "num entries:           %u\n", num_drc_entries);
+	seq_printf(m, "hash buckets:          %u\n", HASHSIZE);
+	seq_printf(m, "mem usage:             %u\n", drc_mem_usage);
+	seq_printf(m, "cache hits:            %u\n", nfsdstats.rchits);
+	seq_printf(m, "cache misses:          %u\n", nfsdstats.rcmisses);
+	seq_printf(m, "not cached:            %u\n", nfsdstats.rcnocache);
+	seq_printf(m, "payload misses:        %u\n", payload_misses);
+	spin_unlock(&cache_lock);
+	return 0;
+}
+
+int nfsd_reply_cache_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, nfsd_reply_cache_stats_show, NULL);
+}
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f33455b..a830f33 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -35,6 +35,7 @@ enum {
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Pool_Stats,
+	NFSD_Reply_Cache_Stats,
 	NFSD_Versions,
 	NFSD_Ports,
 	NFSD_MaxBlkSize,
@@ -212,6 +213,13 @@ static const struct file_operations pool_stats_operations = {
 	.owner		= THIS_MODULE,
 };
 
+static struct file_operations reply_cache_stats_operations = {
+	.open		= nfsd_reply_cache_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 /*----------------------------------------------------------------------------*/
 /*
  * payload - write methods
@@ -1047,6 +1055,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Stats] = {"pool_stats", &pool_stats_operations, S_IRUGO},
+		[NFSD_Reply_Cache_Stats] = {"reply_cache_stats", &reply_cache_stats_operations, S_IRUGO},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
-- 
1.7.11.7

