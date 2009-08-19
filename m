From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/32] SUNRPC: Add an rpc_pipefs front end for the sunrpc
 cache code
Date: Wed, 19 Aug 2009 19:38:48 -0400
Message-ID: <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
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
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103AbZHSXkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:55 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRV001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:43 -0700 (PDT)
In-Reply-To: <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/cache.h       |   13 ++++
 include/linux/sunrpc/rpc_pipe_fs.h |    8 ++
 net/sunrpc/cache.c                 |  126 ++++++++++++++++++++++++++++++++++++
 net/sunrpc/rpc_pipe.c              |   43 ++++++++++++
 4 files changed, 190 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 8e5bf30..6f52b4d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -64,6 +64,10 @@ struct cache_detail_procfs {
 	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
 };
 
+struct cache_detail_pipefs {
+	struct dentry *dir;
+};
+
 struct cache_detail {
 	struct module *		owner;
 	int			hash_size;
@@ -110,6 +114,7 @@ struct cache_detail {
 
 	union {
 		struct cache_detail_procfs procfs;
+		struct cache_detail_pipefs pipefs;
 	} u;
 };
 
@@ -135,6 +140,10 @@ struct cache_deferred_req {
 };
 
 
+extern const struct file_operations cache_file_operations_pipefs;
+extern const struct file_operations content_file_operations_pipefs;
+extern const struct file_operations cache_flush_operations_pipefs;
+
 extern struct cache_head *
 sunrpc_cache_lookup(struct cache_detail *detail,
 		    struct cache_head *key, int hash);
@@ -186,6 +195,10 @@ extern void cache_purge(struct cache_detail *detail);
 extern int cache_register(struct cache_detail *cd);
 extern void cache_unregister(struct cache_detail *cd);
 
+extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
+					mode_t, struct cache_detail *);
+extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
+
 extern void qword_add(char **bpp, int *lp, char *str);
 extern void qword_addhex(char **bpp, int *lp, char *buf, int blen);
 extern int qword_get(char **bpp, char *dest, int bufsize);
diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 88332ef..a92571a 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -47,6 +47,14 @@ extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
 struct rpc_clnt;
 extern struct dentry *rpc_create_client_dir(struct dentry *, struct qstr *, struct rpc_clnt *);
 extern int rpc_remove_client_dir(struct dentry *);
+
+struct cache_detail;
+extern struct dentry *rpc_create_cache_dir(struct dentry *,
+					   struct qstr *,
+					   mode_t umode,
+					   struct cache_detail *);
+extern void rpc_remove_cache_dir(struct dentry *);
+
 extern struct dentry *rpc_mkpipe(struct dentry *, const char *, void *,
 				 const struct rpc_pipe_ops *, int flags);
 extern int rpc_unlink(struct dentry *);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1cd82ed..db7720e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -32,6 +32,7 @@
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
@@ -1438,3 +1439,128 @@ void cache_unregister(struct cache_detail *cd)
 	sunrpc_destroy_cache_detail(cd);
 }
 EXPORT_SYMBOL_GPL(cache_unregister);
+
+static ssize_t cache_read_pipefs(struct file *filp, char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = RPC_I(filp->f_path.dentry->d_inode)->private;
+
+	return cache_read(filp, buf, count, ppos, cd);
+}
+
+static ssize_t cache_write_pipefs(struct file *filp, const char __user *buf,
+				  size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = RPC_I(filp->f_path.dentry->d_inode)->private;
+
+	return cache_write(filp, buf, count, ppos, cd);
+}
+
+static unsigned int cache_poll_pipefs(struct file *filp, poll_table *wait)
+{
+	struct cache_detail *cd = RPC_I(filp->f_path.dentry->d_inode)->private;
+
+	return cache_poll(filp, wait, cd);
+}
+
+static int cache_ioctl_pipefs(struct inode *inode, struct file *filp,
+			      unsigned int cmd, unsigned long arg)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return cache_ioctl(inode, filp, cmd, arg, cd);
+}
+
+static int cache_open_pipefs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return cache_open(inode, filp, cd);
+}
+
+static int cache_release_pipefs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return cache_release(inode, filp, cd);
+}
+
+const struct file_operations cache_file_operations_pipefs = {
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.read		= cache_read_pipefs,
+	.write		= cache_write_pipefs,
+	.poll		= cache_poll_pipefs,
+	.ioctl		= cache_ioctl_pipefs, /* for FIONREAD */
+	.open		= cache_open_pipefs,
+	.release	= cache_release_pipefs,
+};
+
+static int content_open_pipefs(struct inode *inode, struct file *filp)
+{
+	struct cache_detail *cd = RPC_I(inode)->private;
+
+	return content_open(inode, filp, cd);
+}
+
+const struct file_operations content_file_operations_pipefs = {
+	.open		= content_open_pipefs,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+static ssize_t read_flush_pipefs(struct file *filp, char __user *buf,
+			    size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = RPC_I(filp->f_path.dentry->d_inode)->private;
+
+	return read_flush(filp, buf, count, ppos, cd);
+}
+
+static ssize_t write_flush_pipefs(struct file *filp,
+				  const char __user *buf,
+				  size_t count, loff_t *ppos)
+{
+	struct cache_detail *cd = RPC_I(filp->f_path.dentry->d_inode)->private;
+
+	return write_flush(filp, buf, count, ppos, cd);
+}
+
+const struct file_operations cache_flush_operations_pipefs = {
+	.open		= nonseekable_open,
+	.read		= read_flush_pipefs,
+	.write		= write_flush_pipefs,
+};
+
+int sunrpc_cache_register_pipefs(struct dentry *parent,
+				 const char *name, mode_t umode,
+				 struct cache_detail *cd)
+{
+	struct qstr q;
+	struct dentry *dir;
+	int ret = 0;
+
+	sunrpc_init_cache_detail(cd);
+	q.name = name;
+	q.len = strlen(name);
+	q.hash = full_name_hash(q.name, q.len);
+	dir = rpc_create_cache_dir(parent, &q, umode, cd);
+	if (!IS_ERR(dir))
+		cd->u.pipefs.dir = dir;
+	else {
+		sunrpc_destroy_cache_detail(cd);
+		ret = PTR_ERR(dir);
+	}
+	return ret;
+}
+EXPORT_SYMBOL_GPL(sunrpc_cache_register_pipefs);
+
+void sunrpc_cache_unregister_pipefs(struct cache_detail *cd)
+{
+	rpc_remove_cache_dir(cd->u.pipefs.dir);
+	cd->u.pipefs.dir = NULL;
+	sunrpc_destroy_cache_detail(cd);
+}
+EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
+
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 57e9cd3..8dd8153 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -26,6 +26,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
+#include <linux/sunrpc/cache.h>
 
 static struct vfsmount *rpc_mount __read_mostly;
 static int rpc_mount_count;
@@ -882,6 +883,48 @@ int rpc_remove_client_dir(struct dentry *dentry)
 	return rpc_rmdir_depopulate(dentry, rpc_clntdir_depopulate);
 }
 
+static const struct rpc_filelist cache_pipefs_files[3] = {
+	[0] = {
+		.name = "channel",
+		.i_fop = &cache_file_operations_pipefs,
+		.mode = S_IFIFO|S_IRUSR|S_IWUSR,
+	},
+	[1] = {
+		.name = "content",
+		.i_fop = &content_file_operations_pipefs,
+		.mode = S_IFREG|S_IRUSR,
+	},
+	[2] = {
+		.name = "flush",
+		.i_fop = &cache_flush_operations_pipefs,
+		.mode = S_IFREG|S_IRUSR|S_IWUSR,
+	},
+};
+
+static int rpc_cachedir_populate(struct dentry *dentry, void *private)
+{
+	return rpc_populate(dentry,
+			    cache_pipefs_files, 0, 3,
+			    private);
+}
+
+static void rpc_cachedir_depopulate(struct dentry *dentry)
+{
+	rpc_depopulate(dentry, cache_pipefs_files, 0, 3);
+}
+
+struct dentry *rpc_create_cache_dir(struct dentry *parent, struct qstr *name,
+				    mode_t umode, struct cache_detail *cd)
+{
+	return rpc_mkdir_populate(parent, name, umode, NULL,
+			rpc_cachedir_populate, cd);
+}
+
+void rpc_remove_cache_dir(struct dentry *dentry)
+{
+	rpc_rmdir_depopulate(dentry, rpc_cachedir_depopulate);
+}
+
 /*
  * populate the filesystem
  */
-- 
1.6.0.4
