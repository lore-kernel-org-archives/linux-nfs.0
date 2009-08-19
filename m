From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/32] SUNRPC: Move procfs-specific stuff out of the
 generic sunrpc cache code
Date: Wed, 19 Aug 2009 19:38:47 -0400
Message-ID: <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
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
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754133AbZHSXlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:41:01 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7YN028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:49 -0700 (PDT)
In-Reply-To: <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/cache.h |   11 ++-
 net/sunrpc/cache.c           |  319 +++++++++++++++++++++++++-----------------
 2 files changed, 199 insertions(+), 131 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 23ee259..8e5bf30 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -59,6 +59,11 @@ struct cache_head {
 
 #define	CACHE_NEW_EXPIRY 120	/* keep new things pending confirmation for 120 seconds */
 
+struct cache_detail_procfs {
+	struct proc_dir_entry	*proc_ent;
+	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
+};
+
 struct cache_detail {
 	struct module *		owner;
 	int			hash_size;
@@ -98,12 +103,14 @@ struct cache_detail {
 
 	/* fields for communication over channel */
 	struct list_head	queue;
-	struct proc_dir_entry	*proc_ent;
-	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
 
 	atomic_t		readers;		/* how many time is /chennel open */
 	time_t			last_close;		/* if no readers, when did last close */
 	time_t			last_warn;		/* when we last warned about no readers */
+
+	union {
+		struct cache_detail_procfs procfs;
+	} u;
 };
 
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index e438352..1cd82ed 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -291,69 +291,9 @@ static DEFINE_SPINLOCK(cache_list_lock);
 static struct cache_detail *current_detail;
 static int current_index;
 
-static const struct file_operations cache_file_operations;
-static const struct file_operations content_file_operations;
-static const struct file_operations cache_flush_operations;
-
 static void do_cache_clean(struct work_struct *work);
 static DECLARE_DELAYED_WORK(cache_cleaner, do_cache_clean);
 
-static void remove_cache_proc_entries(struct cache_detail *cd)
-{
-	if (cd->proc_ent == NULL)
-		return;
-	if (cd->flush_ent)
-		remove_proc_entry("flush", cd->proc_ent);
-	if (cd->channel_ent)
-		remove_proc_entry("channel", cd->proc_ent);
-	if (cd->content_ent)
-		remove_proc_entry("content", cd->proc_ent);
-	cd->proc_ent = NULL;
-	remove_proc_entry(cd->name, proc_net_rpc);
-}
-
-#ifdef CONFIG_PROC_FS
-static int create_cache_proc_entries(struct cache_detail *cd)
-{
-	struct proc_dir_entry *p;
-
-	cd->proc_ent = proc_mkdir(cd->name, proc_net_rpc);
-	if (cd->proc_ent == NULL)
-		goto out_nomem;
-	cd->channel_ent = cd->content_ent = NULL;
-
-	p = proc_create_data("flush", S_IFREG|S_IRUSR|S_IWUSR,
-			     cd->proc_ent, &cache_flush_operations, cd);
-	cd->flush_ent = p;
-	if (p == NULL)
-		goto out_nomem;
-
-	if (cd->cache_upcall || cd->cache_parse) {
-		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
-				     cd->proc_ent, &cache_file_operations, cd);
-		cd->channel_ent = p;
-		if (p == NULL)
-			goto out_nomem;
-	}
-	if (cd->cache_show) {
-		p = proc_create_data("content", S_IFREG|S_IRUSR|S_IWUSR,
-				cd->proc_ent, &content_file_operations, cd);
-		cd->content_ent = p;
-		if (p == NULL)
-			goto out_nomem;
-	}
-	return 0;
-out_nomem:
-	remove_cache_proc_entries(cd);
-	return -ENOMEM;
-}
-#else /* CONFIG_PROC_FS */
-static int create_cache_proc_entries(struct cache_detail *cd)
-{
-	return 0;
-}
-#endif
-
 static void sunrpc_init_cache_detail(struct cache_detail *cd)
 {
 	rwlock_init(&cd->hash_lock);
@@ -395,25 +335,6 @@ out:
 	printk(KERN_ERR "nfsd: failed to unregister %s cache\n", cd->name);
 }
 
-int cache_register(struct cache_detail *cd)
-{
-	int ret;
-
-	sunrpc_init_cache_detail(cd);
-	ret = create_cache_proc_entries(cd);
-	if (ret)
-		sunrpc_destroy_cache_detail(cd);
-	return ret;
-}
-EXPORT_SYMBOL_GPL(cache_register);
-
-void cache_unregister(struct cache_detail *cd)
-{
-	remove_cache_proc_entries(cd);
-	sunrpc_destroy_cache_detail(cd);
-}
-EXPORT_SYMBOL_GPL(cache_unregister);
-
 /* clean cache tries to find something to clean
  * and cleans it.
  * It returns 1 if it cleaned something,
@@ -704,13 +625,12 @@ struct cache_reader {
 	int			offset;	/* if non-0, we have a refcnt on next request */
 };
 
-static ssize_t
-cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
+static ssize_t cache_read(struct file *filp, char __user *buf, size_t count,
+			  loff_t *ppos, struct cache_detail *cd)
 {
 	struct cache_reader *rp = filp->private_data;
 	struct cache_request *rq;
 	struct inode *inode = filp->f_path.dentry->d_inode;
-	struct cache_detail *cd = PDE(inode)->data;
 	int err;
 
 	if (count == 0)
@@ -834,13 +754,12 @@ out_slow:
 	return cache_slow_downcall(buf, count, cd);
 }
 
-static ssize_t
-cache_write(struct file *filp, const char __user *buf, size_t count,
-	    loff_t *ppos)
+static ssize_t cache_write(struct file *filp, const char __user *buf,
+			   size_t count, loff_t *ppos,
+			   struct cache_detail *cd)
 {
 	struct address_space *mapping = filp->f_mapping;
 	struct inode *inode = filp->f_path.dentry->d_inode;
-	struct cache_detail *cd = PDE(inode)->data;
 	ssize_t ret = -EINVAL;
 
 	if (!cd->cache_parse)
@@ -855,13 +774,12 @@ out:
 
 static DECLARE_WAIT_QUEUE_HEAD(queue_wait);
 
-static unsigned int
-cache_poll(struct file *filp, poll_table *wait)
+static unsigned int cache_poll(struct file *filp, poll_table *wait,
+			       struct cache_detail *cd)
 {
 	unsigned int mask;
 	struct cache_reader *rp = filp->private_data;
 	struct cache_queue *cq;
-	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 
 	poll_wait(filp, &queue_wait, wait);
 
@@ -883,14 +801,13 @@ cache_poll(struct file *filp, poll_table *wait)
 	return mask;
 }
 
-static int
-cache_ioctl(struct inode *ino, struct file *filp,
-	    unsigned int cmd, unsigned long arg)
+static int cache_ioctl(struct inode *ino, struct file *filp,
+		       unsigned int cmd, unsigned long arg,
+		       struct cache_detail *cd)
 {
 	int len = 0;
 	struct cache_reader *rp = filp->private_data;
 	struct cache_queue *cq;
-	struct cache_detail *cd = PDE(ino)->data;
 
 	if (cmd != FIONREAD || !rp)
 		return -EINVAL;
@@ -913,15 +830,13 @@ cache_ioctl(struct inode *ino, struct file *filp,
 	return put_user(len, (int __user *)arg);
 }
 
-static int
-cache_open(struct inode *inode, struct file *filp)
+static int cache_open(struct inode *inode, struct file *filp,
+		      struct cache_detail *cd)
 {
 	struct cache_reader *rp = NULL;
 
 	nonseekable_open(inode, filp);
 	if (filp->f_mode & FMODE_READ) {
-		struct cache_detail *cd = PDE(inode)->data;
-
 		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
 		if (!rp)
 			return -ENOMEM;
@@ -936,11 +851,10 @@ cache_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
-static int
-cache_release(struct inode *inode, struct file *filp)
+static int cache_release(struct inode *inode, struct file *filp,
+			 struct cache_detail *cd)
 {
 	struct cache_reader *rp = filp->private_data;
-	struct cache_detail *cd = PDE(inode)->data;
 
 	if (rp) {
 		spin_lock(&queue_lock);
@@ -969,18 +883,6 @@ cache_release(struct inode *inode, struct file *filp)
 
 
 
-static const struct file_operations cache_file_operations = {
-	.owner		= THIS_MODULE,
-	.llseek		= no_llseek,
-	.read		= cache_read,
-	.write		= cache_write,
-	.poll		= cache_poll,
-	.ioctl		= cache_ioctl, /* for FIONREAD */
-	.open		= cache_open,
-	.release	= cache_release,
-};
-
-
 static void queue_loose(struct cache_detail *detail, struct cache_head *ch)
 {
 	struct cache_queue *cq;
@@ -1307,10 +1209,10 @@ static const struct seq_operations cache_content_op = {
 	.show	= c_show,
 };
 
-static int content_open(struct inode *inode, struct file *file)
+static int content_open(struct inode *inode, struct file *file,
+			struct cache_detail *cd)
 {
 	struct handle *han;
-	struct cache_detail *cd = PDE(inode)->data;
 
 	han = __seq_open_private(file, &cache_content_op, sizeof(*han));
 	if (han == NULL)
@@ -1320,17 +1222,10 @@ static int content_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static const struct file_operations content_file_operations = {
-	.open		= content_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= seq_release_private,
-};
-
 static ssize_t read_flush(struct file *file, char __user *buf,
-			    size_t count, loff_t *ppos)
+			  size_t count, loff_t *ppos,
+			  struct cache_detail *cd)
 {
-	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
 	char tbuf[20];
 	unsigned long p = *ppos;
 	size_t len;
@@ -1348,10 +1243,10 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 	return len;
 }
 
-static ssize_t write_flush(struct file * file, const char __user * buf,
-			     size_t count, loff_t *ppos)
+static ssize_t write_flush(struct file *file, const char __user *buf,
+			   size_t count, loff_t *ppos,
+			   struct cache_detail *cd)
 {
-	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
 	char tbuf[20];
 	char *ep;
 	long flushtime;
@@ -1372,8 +1267,174 @@ static ssize_t write_flush(struct file * file, const char __user * buf,
 	return count;
 }
 
-static const struct file_operations cache_flush_operations = {
+static ssize_t cache_read_procfs(struct file *filp, char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+
+	return cache_read(filp, buf, count, ppos, cd);
+}
+
+static ssize_t cache_write_procfs(struct file *filp, const char __user *buf,
+				  size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+
+	return cache_write(filp, buf, count, ppos, cd);
+}
+
+static unsigned int cache_poll_procfs(struct file *filp, poll_table *wait)
+{
+	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+
+	return cache_poll(filp, wait, cd);
+}
+
+static int cache_ioctl_procfs(struct inode *inode, struct file *filp,
+			      unsigned int cmd, unsigned long arg)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return cache_ioctl(inode, filp, cmd, arg, cd);
+}
+
+static int cache_open_procfs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return cache_open(inode, filp, cd);
+}
+
+static int cache_release_procfs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return cache_release(inode, filp, cd);
+}
+
+static const struct file_operations cache_file_operations_procfs = {
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.read		= cache_read_procfs,
+	.write		= cache_write_procfs,
+	.poll		= cache_poll_procfs,
+	.ioctl		= cache_ioctl_procfs, /* for FIONREAD */
+	.open		= cache_open_procfs,
+	.release	= cache_release_procfs,
+};
+
+static int content_open_procfs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = PDE(inode)->data;
+
+	return content_open(inode, filp, cd);
+}
+
+static const struct file_operations content_file_operations_procfs = {
+	.open		= content_open_procfs,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+static ssize_t read_flush_procfs(struct file *filp, char __user *buf,
+			    size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+
+	return read_flush(filp, buf, count, ppos, cd);
+}
+
+static ssize_t write_flush_procfs(struct file *filp,
+				  const char __user *buf,
+				  size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+
+	return write_flush(filp, buf, count, ppos, cd);
+}
+
+static const struct file_operations cache_flush_operations_procfs = {
 	.open		= nonseekable_open,
-	.read		= read_flush,
-	.write		= write_flush,
+	.read		= read_flush_procfs,
+	.write		= write_flush_procfs,
 };
+
+static void remove_cache_proc_entries(struct cache_detail *cd)
+{
+	if (cd->u.procfs.proc_ent == NULL)
+		return;
+	if (cd->u.procfs.flush_ent)
+		remove_proc_entry("flush", cd->u.procfs.proc_ent);
+	if (cd->u.procfs.channel_ent)
+		remove_proc_entry("channel", cd->u.procfs.proc_ent);
+	if (cd->u.procfs.content_ent)
+		remove_proc_entry("content", cd->u.procfs.proc_ent);
+	cd->u.procfs.proc_ent = NULL;
+	remove_proc_entry(cd->name, proc_net_rpc);
+}
+
+#ifdef CONFIG_PROC_FS
+static int create_cache_proc_entries(struct cache_detail *cd)
+{
+	struct proc_dir_entry *p;
+
+	cd->u.procfs.proc_ent = proc_mkdir(cd->name, proc_net_rpc);
+	if (cd->u.procfs.proc_ent == NULL)
+		goto out_nomem;
+	cd->u.procfs.channel_ent = NULL;
+	cd->u.procfs.content_ent = NULL;
+
+	p = proc_create_data("flush", S_IFREG|S_IRUSR|S_IWUSR,
+			     cd->u.procfs.proc_ent,
+			     &cache_flush_operations_procfs, cd);
+	cd->u.procfs.flush_ent = p;
+	if (p == NULL)
+		goto out_nomem;
+
+	if (cd->cache_upcall || cd->cache_parse) {
+		p = proc_create_data("channel", S_IFREG|S_IRUSR|S_IWUSR,
+				     cd->u.procfs.proc_ent,
+				     &cache_file_operations_procfs, cd);
+		cd->u.procfs.channel_ent = p;
+		if (p == NULL)
+			goto out_nomem;
+	}
+	if (cd->cache_show) {
+		p = proc_create_data("content", S_IFREG|S_IRUSR|S_IWUSR,
+				cd->u.procfs.proc_ent,
+				&content_file_operations_procfs, cd);
+		cd->u.procfs.content_ent = p;
+		if (p == NULL)
+			goto out_nomem;
+	}
+	return 0;
+out_nomem:
+	remove_cache_proc_entries(cd);
+	return -ENOMEM;
+}
+#else /* CONFIG_PROC_FS */
+static int create_cache_proc_entries(struct cache_detail *cd)
+{
+	return 0;
+}
+#endif
+
+int cache_register(struct cache_detail *cd)
+{
+	int ret;
+
+	sunrpc_init_cache_detail(cd);
+	ret = create_cache_proc_entries(cd);
+	if (ret)
+		sunrpc_destroy_cache_detail(cd);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(cache_register);
+
+void cache_unregister(struct cache_detail *cd)
+{
+	remove_cache_proc_entries(cd);
+	sunrpc_destroy_cache_detail(cd);
+}
+EXPORT_SYMBOL_GPL(cache_unregister);
-- 
1.6.0.4
