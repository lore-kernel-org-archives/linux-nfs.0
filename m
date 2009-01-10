Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42413 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976AbZAJS60 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Jan 2009 13:58:26 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1LLj2P-00081C-PV
	for linux-nfs@vger.kernel.org; Sat, 10 Jan 2009 13:58:25 -0500
Date: Sat, 10 Jan 2009 13:58:25 -0500
To: linux-nfs@vger.kernel.org
Subject: replay demonstration patches
Message-ID: <20090110185825.GB30459@fieldses.org>
Content-Type: multipart/mixed; boundary="wRRV7LY7NUeQGEoC"
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Just sorting through random stuff sitting in my kernel repository:

This is for your amusement only (not to be applied): I wanted to produce
traces showing the effect of the reply cache on the server's response to
replays.  After applying these patches:

	echo 1 >/proc/fs/nfsd/drop_rename

will drop the next NFSv3 rename seen by the server, and

	echo 1 >/proc/fs/nfsd/disable_reply_cache

will turn off the reply cache.

--b.

--wRRV7LY7NUeQGEoC
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-nfsd-allow-dropping-renames.patch"

>From e28638551f1b28e09b87498bdb9b2c2401a14a68 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Fri, 14 Nov 2008 09:28:21 -0500
Subject: [PATCH] nfsd: allow dropping renames

Drop the first NFSv3 rename seen; just to produce a packet trace
demonstrating dropped request and replay.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   17 +++++++++++++++++
 fs/nfsd/nfssvc.c |    7 +++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e3f9783..3bc957c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -63,6 +63,7 @@ enum {
 	NFSD_Versions,
 	NFSD_Ports,
 	NFSD_MaxBlkSize,
+	NFSD_DropRename,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -89,6 +90,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
 static ssize_t write_ports(struct file *file, char *buf, size_t size);
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
+static ssize_t write_droprename(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
@@ -113,6 +115,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Versions] = write_versions,
 	[NFSD_Ports] = write_ports,
 	[NFSD_MaxBlkSize] = write_maxblksize,
+	[NFSD_DropRename] = write_droprename,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
@@ -727,6 +730,19 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 	return sprintf(buf, "%d\n", nfsd_max_blksize);
 }
 
+int drop_rename_count;
+
+static ssize_t write_droprename(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	if (size > 0) {
+		int rv = get_int(&mesg, &drop_rename_count);
+		if (rv)
+			return rv;
+	}
+	return sprintf(buf, "%d\n", drop_rename_count);
+}
+
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
@@ -826,6 +842,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_DropRename] = {"drop_rename", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 07e4f5d..49f24a8 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -503,6 +503,8 @@ static __be32 map_new_errors(u32 vers, __be32 nfserr)
 	return nfserr;
 }
 
+extern int drop_rename_count;
+
 int
 nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 {
@@ -572,5 +574,10 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 
 	/* Store reply in cache. */
 	nfsd_cache_update(rqstp, proc->pc_cachetype, statp + 1);
+	if (drop_rename_count &&
+		rqstp->rq_vers == 3 && rqstp->rq_proc == NFS3PROC_RENAME) {
+		drop_rename_count--;
+		return 0;
+	}
 	return 1;
 }
-- 
1.5.5.rc1


--wRRV7LY7NUeQGEoC
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0002-nfsd-allow-disabling-reply-cache.patch"

>From 25978a41777434d3f15014f614e4fbaca9c28978 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Fri, 14 Nov 2008 10:44:42 -0500
Subject: [PATCH] nfsd: allow disabling reply cache

For demonstration purposes.
---
 fs/nfsd/nfscache.c |    2 +-
 fs/nfsd/nfsctl.c   |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 5bfc2ac..d4bece7 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -33,7 +33,7 @@
 
 static struct hlist_head *	hash_list;
 static struct list_head 	lru_head;
-static int			cache_disabled = 1;
+extern int			cache_disabled;
 
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 3bc957c..63b4f36 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -64,6 +64,7 @@ enum {
 	NFSD_Ports,
 	NFSD_MaxBlkSize,
 	NFSD_DropRename,
+	NFSD_DisableReplyCache,
 	/*
 	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
 	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -91,6 +92,7 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size);
 static ssize_t write_ports(struct file *file, char *buf, size_t size);
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
 static ssize_t write_droprename(struct file *file, char *buf, size_t size);
+static ssize_t write_disable_reply_cache(struct file *file, char *buf, size_t size);
 #ifdef CONFIG_NFSD_V4
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
@@ -116,6 +118,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Ports] = write_ports,
 	[NFSD_MaxBlkSize] = write_maxblksize,
 	[NFSD_DropRename] = write_droprename,
+	[NFSD_DisableReplyCache] = write_disable_reply_cache,
 #ifdef CONFIG_NFSD_V4
 	[NFSD_Leasetime] = write_leasetime,
 	[NFSD_RecoveryDir] = write_recoverydir,
@@ -743,6 +746,19 @@ static ssize_t write_droprename(struct file *file, char *buf, size_t size)
 	return sprintf(buf, "%d\n", drop_rename_count);
 }
 
+int cache_disabled = 1;
+
+static ssize_t write_disable_reply_cache(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	if (size > 0) {
+		int rv = get_int(&mesg, &cache_disabled);
+		if (rv)
+			return rv;
+	}
+	return sprintf(buf, "%d\n", cache_disabled);
+}
+
 #ifdef CONFIG_NFSD_V4
 extern time_t nfs4_leasetime(void);
 
@@ -843,6 +859,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
 		[NFSD_DropRename] = {"drop_rename", &transaction_ops, S_IWUSR|S_IRUGO},
+		[NFSD_DisableReplyCache] = {"disable_reply_cache", &transaction_ops, S_IWUSR|S_IRUGO},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
-- 
1.5.5.rc1


--wRRV7LY7NUeQGEoC--
