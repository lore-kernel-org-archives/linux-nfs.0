Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:51187 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaKZTpA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 14:45:00 -0500
Received: by mail-qg0-f46.google.com with SMTP id z107so2539737qgd.33
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 11:44:59 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/5] sunrpc: add a debugfs rpc_xprt directory with an info file in it
Date: Wed, 26 Nov 2014 14:44:44 -0500
Message-Id: <1417031084-17576-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
References: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
 <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new directory heirarchy under the debugfs sunrpc/ directory:

    sunrpc/
        rpc_xprt/
            <xprt id>/

Within that directory, we can put files that give info about the
xprts. We do have the (minor) problem that there is no succinct,
unique identifier for rpc_xprts. So we generate them synthetically
with a static atomic_t counter.

For now, this directory just holds an "info" file, but we may add
other files to it in the future.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/debug.h |  15 ++++++
 include/linux/sunrpc/xprt.h  |   3 ++
 net/sunrpc/debugfs.c         | 115 ++++++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprt.c            |   8 +++
 4 files changed, 134 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 835339707094..c57d8ea0716c 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -55,6 +55,7 @@ extern unsigned int		nlm_debug;
  */
 
 struct rpc_clnt;
+struct rpc_xprt;
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 void		rpc_register_sysctl(void);
@@ -63,6 +64,8 @@ int		sunrpc_debugfs_init(void);
 void		sunrpc_debugfs_exit(void);
 int		rpc_clnt_debugfs_register(struct rpc_clnt *);
 void		rpc_clnt_debugfs_unregister(struct rpc_clnt *);
+int		rpc_xprt_debugfs_register(struct rpc_xprt *);
+void		rpc_xprt_debugfs_unregister(struct rpc_xprt *);
 #else
 static inline int
 sunrpc_debugfs_init(void)
@@ -87,6 +90,18 @@ rpc_clnt_debugfs_unregister(struct rpc_clnt *clnt)
 {
 	return;
 }
+
+static inline int
+rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
+{
+	return 0;
+}
+
+static inline void
+rpc_xprt_debugfs_unregister(struct rpc_xprt *xprt)
+{
+	return;
+}
 #endif
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index cf391eef2e6d..9d27ac45b909 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -239,6 +239,9 @@ struct rpc_xprt {
 	struct net		*xprt_net;
 	const char		*servername;
 	const char		*address_strings[RPC_DISPLAY_MAX];
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+	struct dentry		*debugfs;		/* debugfs directory */
+#endif
 };
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 3d7745683ca3..e811f390f9f6 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -11,6 +11,7 @@
 
 static struct dentry *topdir;
 static struct dentry *rpc_clnt_dir;
+static struct dentry *rpc_xprt_dir;
 
 struct rpc_clnt_iter {
 	struct rpc_clnt	*clnt;
@@ -131,8 +132,8 @@ static const struct file_operations tasks_fops = {
 int
 rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 {
-	int len;
-	char name[9]; /* 8 for hex digits + NULL terminator */
+	int len, err;
+	char name[24]; /* enough for "../../rpc_xprt/ + 8 hex digits + NULL */
 
 	/* Already registered? */
 	if (clnt->cl_debugfs)
@@ -148,14 +149,28 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 		return -ENOMEM;
 
 	/* make tasks file */
+	err = -ENOMEM;
 	if (!debugfs_create_file("tasks", S_IFREG | S_IRUSR, clnt->cl_debugfs,
-				 clnt, &tasks_fops)) {
-		debugfs_remove_recursive(clnt->cl_debugfs);
-		clnt->cl_debugfs = NULL;
-		return -ENOMEM;
-	}
+				 clnt, &tasks_fops))
+		goto out_err;
+
+	err = -EINVAL;
+	rcu_read_lock();
+	len = snprintf(name, sizeof(name), "../../rpc_xprt/%s",
+			rcu_dereference(clnt->cl_xprt)->debugfs->d_name.name);
+	rcu_read_unlock();
+	if (len >= sizeof(name))
+		goto out_err;
+
+	err = -ENOMEM;
+	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
+		goto out_err;
 
 	return 0;
+out_err:
+	debugfs_remove_recursive(clnt->cl_debugfs);
+	clnt->cl_debugfs = NULL;
+	return err;
 }
 
 void
@@ -165,6 +180,88 @@ rpc_clnt_debugfs_unregister(struct rpc_clnt *clnt)
 	clnt->cl_debugfs = NULL;
 }
 
+static int
+xprt_info_show(struct seq_file *f, void *v)
+{
+	struct rpc_xprt *xprt = f->private;
+
+	seq_printf(f, "netid: %s\n", xprt->address_strings[RPC_DISPLAY_NETID]);
+	seq_printf(f, "addr:  %s\n", xprt->address_strings[RPC_DISPLAY_ADDR]);
+	seq_printf(f, "port:  %s\n", xprt->address_strings[RPC_DISPLAY_PORT]);
+	seq_printf(f, "state: 0x%lx\n", xprt->state);
+	return 0;
+}
+
+static int
+xprt_info_open(struct inode *inode, struct file *filp)
+{
+	int ret;
+	struct rpc_xprt *xprt = inode->i_private;
+
+	ret = single_open(filp, xprt_info_show, xprt);
+
+	if (!ret) {
+		if (!xprt_get(xprt)) {
+			single_release(inode, filp);
+			ret = -EINVAL;
+		}
+	}
+	return ret;
+}
+
+static int
+xprt_info_release(struct inode *inode, struct file *filp)
+{
+	struct rpc_xprt *xprt = inode->i_private;
+
+	xprt_put(xprt);
+	return single_release(inode, filp);
+}
+
+static const struct file_operations xprt_info_fops = {
+	.owner		= THIS_MODULE,
+	.open		= xprt_info_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= xprt_info_release,
+};
+
+int
+rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
+{
+	int len, id;
+	static atomic_t	cur_id;
+	char		name[9]; /* 8 hex digits + NULL term */
+
+	id = (unsigned int)atomic_inc_return(&cur_id);
+
+	len = snprintf(name, sizeof(name), "%x", id);
+	if (len >= sizeof(name))
+		return -EINVAL;
+
+	/* make the per-client dir */
+	xprt->debugfs = debugfs_create_dir(name, rpc_xprt_dir);
+	if (!xprt->debugfs)
+		return -ENOMEM;
+
+	/* make tasks file */
+	if (!debugfs_create_file("info", S_IFREG | S_IRUSR, xprt->debugfs,
+				 xprt, &xprt_info_fops)) {
+		debugfs_remove_recursive(xprt->debugfs);
+		xprt->debugfs = NULL;
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void
+rpc_xprt_debugfs_unregister(struct rpc_xprt *xprt)
+{
+	debugfs_remove_recursive(xprt->debugfs);
+	xprt->debugfs = NULL;
+}
+
 void __exit
 sunrpc_debugfs_exit(void)
 {
@@ -182,6 +279,10 @@ sunrpc_debugfs_init(void)
 	if (!rpc_clnt_dir)
 		goto out_remove;
 
+	rpc_xprt_dir = debugfs_create_dir("rpc_xprt", topdir);
+	if (!rpc_xprt_dir)
+		goto out_remove;
+
 	return 0;
 out_remove:
 	debugfs_remove_recursive(topdir);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 894d071426b2..ebbefad21a37 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1303,6 +1303,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
  */
 struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 {
+	int err;
 	struct rpc_xprt	*xprt;
 	struct xprt_class *t;
 
@@ -1343,6 +1344,12 @@ found:
 		return ERR_PTR(-ENOMEM);
 	}
 
+	err = rpc_xprt_debugfs_register(xprt);
+	if (err) {
+		xprt_destroy(xprt);
+		return ERR_PTR(err);
+	}
+
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
 			xprt->max_reqs);
 out:
@@ -1359,6 +1366,7 @@ static void xprt_destroy(struct rpc_xprt *xprt)
 	dprintk("RPC:       destroying transport %p\n", xprt);
 	del_timer_sync(&xprt->timer);
 
+	rpc_xprt_debugfs_unregister(xprt);
 	rpc_destroy_wait_queue(&xprt->binding);
 	rpc_destroy_wait_queue(&xprt->pending);
 	rpc_destroy_wait_queue(&xprt->sending);
-- 
2.1.0

