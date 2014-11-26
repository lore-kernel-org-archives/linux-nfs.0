Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:40413 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaKZTo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 14:44:58 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so2532794qcq.25
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 11:44:58 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/5] sunrpc: add debugfs file for displaying client rpc_task queue
Date: Wed, 26 Nov 2014 14:44:43 -0500
Message-Id: <1417031084-17576-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
References: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
 <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible to get a dump of the RPC task queue by writing a value to
/proc/sys/sunrpc/rpc_debug. If you write any value to that file, you get
a dump of the RPC client task list into the log buffer. This is a rather
inconvenient interface however, and makes it hard to get immediate info
about the task queue.

Add a new directory hierarchy under debugfs:

    sunrpc/
        rpc_clnt/
            <clientid>/

Within each clientid directory we create a new "tasks" file that will
dump info similar to what shows up in the log buffer, but with a few
small differences -- we avoid printing raw kernel addresses in favor of
symbolic names and the XID is also displayed.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/clnt.h  |   4 +
 include/linux/sunrpc/debug.h |  31 +++++++
 net/sunrpc/Kconfig           |   1 +
 net/sunrpc/Makefile          |   1 +
 net/sunrpc/clnt.c            |  10 ++-
 net/sunrpc/debugfs.c         | 191 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sunrpc_syms.c     |   8 ++
 7 files changed, 245 insertions(+), 1 deletion(-)
 create mode 100644 net/sunrpc/debugfs.c

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 70736b98c721..d86acc63b25f 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -63,6 +63,9 @@ struct rpc_clnt {
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;
 	const struct rpc_program *cl_program;
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+	struct dentry		*cl_debugfs;	/* debugfs directory */
+#endif
 };
 
 /*
@@ -176,5 +179,6 @@ size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
 
+const char *rpc_proc_name(const struct rpc_task *task);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 43f38ee9668c..835339707094 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -53,9 +53,40 @@ extern unsigned int		nlm_debug;
 /*
  * Sysctl interface for RPC debugging
  */
+
+struct rpc_clnt;
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 void		rpc_register_sysctl(void);
 void		rpc_unregister_sysctl(void);
+int		sunrpc_debugfs_init(void);
+void		sunrpc_debugfs_exit(void);
+int		rpc_clnt_debugfs_register(struct rpc_clnt *);
+void		rpc_clnt_debugfs_unregister(struct rpc_clnt *);
+#else
+static inline int
+sunrpc_debugfs_init(void)
+{
+	return 0;
+}
+
+static inline void
+sunrpc_debugfs_exit(void)
+{
+	return;
+}
+
+static inline int
+rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
+{
+	return 0;
+}
+
+static inline void
+rpc_clnt_debugfs_unregister(struct rpc_clnt *clnt)
+{
+	return;
+}
 #endif
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 0754d0f466d2..fb78117b896c 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -35,6 +35,7 @@ config RPCSEC_GSS_KRB5
 config SUNRPC_DEBUG
 	bool "RPC: Enable dprintk debugging"
 	depends on SUNRPC && SYSCTL
+	select DEBUG_FS
 	help
 	  This option enables a sysctl-based debugging interface
 	  that is be used by the 'rpcdebug' utility to turn on or off
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index e5a7a1cac8f3..15e6f6c23c5d 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -14,6 +14,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    addr.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o \
 	    svc_xprt.o
+sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
 sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o bc_svc.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 36c64ef460cf..05da12a33945 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -305,6 +305,10 @@ static int rpc_client_register(struct rpc_clnt *clnt,
 	struct super_block *pipefs_sb;
 	int err;
 
+	err = rpc_clnt_debugfs_register(clnt);
+	if (err)
+		return err;
+
 	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
 		err = rpc_setup_pipedir(pipefs_sb, clnt);
@@ -331,6 +335,7 @@ err_auth:
 out:
 	if (pipefs_sb)
 		rpc_put_sb_net(net);
+	rpc_clnt_debugfs_unregister(clnt);
 	return err;
 }
 
@@ -670,6 +675,7 @@ int rpc_switch_client_transport(struct rpc_clnt *clnt,
 
 	rpc_unregister_client(clnt);
 	__rpc_clnt_remove_pipedir(clnt);
+	rpc_clnt_debugfs_unregister(clnt);
 
 	/*
 	 * A new transport was created.  "clnt" therefore
@@ -771,6 +777,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 			rcu_dereference(clnt->cl_xprt)->servername);
 	if (clnt->cl_parent != clnt)
 		parent = clnt->cl_parent;
+	rpc_clnt_debugfs_unregister(clnt);
 	rpc_clnt_remove_pipedir(clnt);
 	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
@@ -1397,7 +1404,8 @@ rpc_restart_call(struct rpc_task *task)
 EXPORT_SYMBOL_GPL(rpc_restart_call);
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-static const char *rpc_proc_name(const struct rpc_task *task)
+const char
+*rpc_proc_name(const struct rpc_task *task)
 {
 	const struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
new file mode 100644
index 000000000000..3d7745683ca3
--- /dev/null
+++ b/net/sunrpc/debugfs.c
@@ -0,0 +1,191 @@
+/**
+ * debugfs interface for sunrpc
+ *
+ * (c) 2014 Jeff Layton <jlayton@primarydata.com>
+ */
+
+#include <linux/debugfs.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/clnt.h>
+#include "netns.h"
+
+static struct dentry *topdir;
+static struct dentry *rpc_clnt_dir;
+
+struct rpc_clnt_iter {
+	struct rpc_clnt	*clnt;
+	loff_t		pos;
+};
+
+static int
+tasks_show(struct seq_file *f, void *v)
+{
+	u32 xid = 0;
+	struct rpc_task *task = v;
+	struct rpc_clnt *clnt = task->tk_client;
+	const char *rpc_waitq = "none";
+
+	if (RPC_IS_QUEUED(task))
+		rpc_waitq = rpc_qname(task->tk_waitqueue);
+
+	if (task->tk_rqstp)
+		xid = be32_to_cpu(task->tk_rqstp->rq_xid);
+
+	seq_printf(f, "%5u %04x %6d 0x%x 0x%x %8ld %ps %sv%u %s a:%ps q:%s\n",
+		task->tk_pid, task->tk_flags, task->tk_status,
+		clnt->cl_clid, xid, task->tk_timeout, task->tk_ops,
+		clnt->cl_program->name, clnt->cl_vers, rpc_proc_name(task),
+		task->tk_action, rpc_waitq);
+	return 0;
+}
+
+static void *
+tasks_start(struct seq_file *f, loff_t *ppos)
+	__acquires(&clnt->cl_lock)
+{
+	struct rpc_clnt_iter *iter = f->private;
+	loff_t pos = *ppos;
+	struct rpc_clnt *clnt = iter->clnt;
+	struct rpc_task *task;
+
+	iter->pos = pos + 1;
+	spin_lock(&clnt->cl_lock);
+	list_for_each_entry(task, &clnt->cl_tasks, tk_task)
+		if (pos-- == 0)
+			return task;
+	return NULL;
+}
+
+static void *
+tasks_next(struct seq_file *f, void *v, loff_t *pos)
+{
+	struct rpc_clnt_iter *iter = f->private;
+	struct rpc_clnt *clnt = iter->clnt;
+	struct rpc_task *task = v;
+	struct list_head *next = task->tk_task.next;
+
+	++iter->pos;
+	++*pos;
+
+	/* If there's another task on list, return it */
+	if (next == &clnt->cl_tasks)
+		return NULL;
+	return list_entry(next, struct rpc_task, tk_task);
+}
+
+static void
+tasks_stop(struct seq_file *f, void *v)
+	__releases(&clnt->cl_lock)
+{
+	struct rpc_clnt_iter *iter = f->private;
+	struct rpc_clnt *clnt = iter->clnt;
+
+	spin_unlock(&clnt->cl_lock);
+}
+
+static const struct seq_operations tasks_seq_operations = {
+	.start	= tasks_start,
+	.next	= tasks_next,
+	.stop	= tasks_stop,
+	.show	= tasks_show,
+};
+
+static int tasks_open(struct inode *inode, struct file *filp)
+{
+	int ret = seq_open_private(filp, &tasks_seq_operations,
+					sizeof(struct rpc_clnt_iter));
+
+	if (!ret) {
+		struct seq_file *seq = filp->private_data;
+		struct rpc_clnt_iter *iter = seq->private;
+
+		iter->clnt = inode->i_private;
+
+		if (!atomic_inc_not_zero(&iter->clnt->cl_count)) {
+			seq_release_private(inode, filp);
+			ret = -EINVAL;
+		}
+	}
+
+	return ret;
+}
+
+static int
+tasks_release(struct inode *inode, struct file *filp)
+{
+	struct seq_file *seq = filp->private_data;
+	struct rpc_clnt_iter *iter = seq->private;
+
+	rpc_release_client(iter->clnt);
+	return seq_release_private(inode, filp);
+}
+
+static const struct file_operations tasks_fops = {
+	.owner		= THIS_MODULE,
+	.open		= tasks_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= tasks_release,
+};
+
+int
+rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
+{
+	int len;
+	char name[9]; /* 8 for hex digits + NULL terminator */
+
+	/* Already registered? */
+	if (clnt->cl_debugfs)
+		return 0;
+
+	len = snprintf(name, sizeof(name), "%x", clnt->cl_clid);
+	if (len >= sizeof(name))
+		return -EINVAL;
+
+	/* make the per-client dir */
+	clnt->cl_debugfs = debugfs_create_dir(name, rpc_clnt_dir);
+	if (!clnt->cl_debugfs)
+		return -ENOMEM;
+
+	/* make tasks file */
+	if (!debugfs_create_file("tasks", S_IFREG | S_IRUSR, clnt->cl_debugfs,
+				 clnt, &tasks_fops)) {
+		debugfs_remove_recursive(clnt->cl_debugfs);
+		clnt->cl_debugfs = NULL;
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+void
+rpc_clnt_debugfs_unregister(struct rpc_clnt *clnt)
+{
+	debugfs_remove_recursive(clnt->cl_debugfs);
+	clnt->cl_debugfs = NULL;
+}
+
+void __exit
+sunrpc_debugfs_exit(void)
+{
+	debugfs_remove_recursive(topdir);
+}
+
+int __init
+sunrpc_debugfs_init(void)
+{
+	topdir = debugfs_create_dir("sunrpc", NULL);
+	if (!topdir)
+		goto out;
+
+	rpc_clnt_dir = debugfs_create_dir("rpc_clnt", topdir);
+	if (!rpc_clnt_dir)
+		goto out_remove;
+
+	return 0;
+out_remove:
+	debugfs_remove_recursive(topdir);
+	topdir = NULL;
+out:
+	return -ENOMEM;
+}
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index f632e476ab6c..e37fbed87956 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -97,6 +97,11 @@ init_sunrpc(void)
 	err = register_rpc_pipefs();
 	if (err)
 		goto out4;
+
+	err = sunrpc_debugfs_init();
+	if (err)
+		goto out5;
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	rpc_register_sysctl();
 #endif
@@ -104,6 +109,8 @@ init_sunrpc(void)
 	init_socket_xprt();	/* clnt sock transport */
 	return 0;
 
+out5:
+	unregister_rpc_pipefs();
 out4:
 	unregister_pernet_subsys(&sunrpc_net_ops);
 out3:
@@ -120,6 +127,7 @@ cleanup_sunrpc(void)
 	rpcauth_remove_module();
 	cleanup_socket_xprt();
 	svc_cleanup_xprt_sock();
+	sunrpc_debugfs_exit();
 	unregister_rpc_pipefs();
 	rpc_destroy_mempool();
 	unregister_pernet_subsys(&sunrpc_net_ops);
-- 
2.1.0

