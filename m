From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 32/32] SUNRPC: cache must take a reference to the cache
 detail's module on open()
Date: Wed, 19 Aug 2009 19:38:55 -0400
Message-ID: <1250725135-14632-33-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-32-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754114AbZHSXlC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:02 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7YP028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:49 -0700 (PDT)
In-Reply-To: <1250725135-14632-32-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise we Oops if the module containing the cache detail is removed
before all cache readers have closed the file.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/cache.c |   80 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 76 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index db7720e..45cdaff 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -836,6 +836,8 @@ static int cache_open(struct inode *inode, struct file *filp,
 {
 	struct cache_reader *rp = NULL;
 
+	if (!cd || !try_module_get(cd->owner))
+		return -EACCES;
 	nonseekable_open(inode, filp);
 	if (filp->f_mode & FMODE_READ) {
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
@@ -879,6 +881,7 @@ static int cache_release(struct inode *inode, struct file *filp,
 		cd->last_close = get_seconds();
 		atomic_dec(&cd->readers);
 	}
+	module_put(cd->owner);
 	return 0;
 }
 
@@ -1215,6 +1218,8 @@ static int content_open(struct inode *inode, struct file *file,
 {
 	struct handle *han;
 
+	if (!cd || !try_module_get(cd->owner))
+		return -EACCES;
 	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
 	if (han == NULL)
 		return -ENOMEM;
@@ -1223,6 +1228,29 @@ static int content_open(struct inode *inode, struct file *file,
 	return 0;
 }
 
+static int content_release(struct inode *inode, struct file *file,
+		struct cache_detail *cd)
+{
+	int ret = seq_release_private(inode, file);
+	module_put(cd->owner);
+	return ret;
+}
+
+static int open_flush(struct inode *inode, struct file *file,
+			struct cache_detail *cd)
+{
+	if (!cd || !try_module_get(cd->owner))
+		return -EACCES;
+	return nonseekable_open(inode, file);
+}
+
+static int release_flush(struct inode *inode, struct file *file,
+			struct cache_detail *cd)
+{
+	module_put(cd->owner);
+	return 0;
+}
+
 static ssize_t read_flush(struct file *file, char __user *buf,
 			  size_t count, loff_t *ppos,
 			  struct cache_detail *cd)
@@ -1331,13 +1359,34 @@ static int content_open_procfs(struct inode *inode, struct file *filp)
 	return content_open(inode, filp, cd);
 }
 
+static int content_release_procfs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return content_release(inode, filp, cd);
+}
+
 static const struct file_operations content_file_operations_procfs = {
 	.open		= content_open_procfs,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= content_release_procfs,
 };
 
+static int open_flush_procfs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return open_flush(inode, filp, cd);
+}
+
+static int release_flush_procfs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return release_flush(inode, filp, cd);
+}
+
 static ssize_t read_flush_procfs(struct file *filp, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
@@ -1356,9 +1405,10 @@ static ssize_t write_flush_procfs(struct file *filp,
 }
 
 static const struct file_operations cache_flush_operations_procfs = {
-	.open		= nonseekable_open,
+	.open		= open_flush_procfs,
 	.read		= read_flush_procfs,
 	.write		= write_flush_procfs,
+	.release	= release_flush_procfs,
 };
 
 static void remove_cache_proc_entries(struct cache_detail *cd)
@@ -1503,13 +1553,34 @@ static int content_open_pipefs(struct inode *inode, struct file *filp)
 	return content_open(inode, filp, cd);
 }
 
+static int content_release_pipefs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return content_release(inode, filp, cd);
+}
+
 const struct file_operations content_file_operations_pipefs = {
 	.open		= content_open_pipefs,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= seq_release_private,
+	.release	= content_release_pipefs,
 };
 
+static int open_flush_pipefs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return open_flush(inode, filp, cd);
+}
+
+static int release_flush_pipefs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return release_flush(inode, filp, cd);
+}
+
 static ssize_t read_flush_pipefs(struct file *filp, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
@@ -1528,9 +1599,10 @@ static ssize_t write_flush_pipefs(struct file *filp,
 }
 
 const struct file_operations cache_flush_operations_pipefs = {
-	.open		= nonseekable_open,
+	.open		= open_flush_pipefs,
 	.read		= read_flush_pipefs,
 	.write		= write_flush_pipefs,
+	.release	= release_flush_pipefs,
 };
 
 int sunrpc_cache_register_pipefs(struct dentry *parent,
-- 
1.6.0.4
