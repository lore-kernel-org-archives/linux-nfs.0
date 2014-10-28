Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:55030 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbaJ1SZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 14:25:01 -0400
Received: by mail-qc0-f180.google.com with SMTP id o8so1066623qcw.11
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 11:25:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: add debugfs file for displaying client rpc_task queue
Date: Tue, 28 Oct 2014 14:24:55 -0400
Message-Id: <1414520695-1701-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible to get a dump of the RPC task queue by writing a value to
/proc/sys/sunrpc/rpc_debug. If you write any value to that file, you get
a dump of the RPC client task list into the log buffer. This is a rather
inconvenient interface however, and makes it hard to get immediate info
about the task queue.

Add a new file under debugfs that shows similar info. There are some
small differences -- we avoid printing raw kernel addresses in favor of
symbolic names and the XID is also displayed.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/clnt.h  |   1 +
 include/linux/sunrpc/debug.h |  13 ++++
 net/sunrpc/Kconfig           |   1 +
 net/sunrpc/Makefile          |   1 +
 net/sunrpc/clnt.c            |   3 +-
 net/sunrpc/debugfs.c         | 153 +++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sunrpc_syms.c     |   8 +++
 7 files changed, 179 insertions(+), 1 deletion(-)
 create mode 100644 net/sunrpc/debugfs.c

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 70736b98c721..265d40bd3109 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -176,5 +176,6 @@ size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
 
+const char *rpc_proc_name(const struct rpc_task *task);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 9385bd74c860..7c1ef9530087 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -68,6 +68,19 @@ extern unsigned int		nlm_debug;
 #ifdef RPC_DEBUG
 void		rpc_register_sysctl(void);
 void		rpc_unregister_sysctl(void);
+int		sunrpc_debugfs_init(void);
+void		sunrpc_debugfs_exit(void);
+#else
+static inline int
+sunrpc_debugfs_init(void)
+{
+	return 0;
+}
+static inline void
+sunrpc_debugfs_exit(void)
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
index 9acd6ce88db7..5b2e2d3d37c1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1397,7 +1397,8 @@ rpc_restart_call(struct rpc_task *task)
 EXPORT_SYMBOL_GPL(rpc_restart_call);
 
 #ifdef RPC_DEBUG
-static const char *rpc_proc_name(const struct rpc_task *task)
+const char
+*rpc_proc_name(const struct rpc_task *task)
 {
 	const struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
 
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
new file mode 100644
index 000000000000..48769338172e
--- /dev/null
+++ b/net/sunrpc/debugfs.c
@@ -0,0 +1,153 @@
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
+	__acquires(&sn->rpc_client_lock)
+	__acquires(&clnt->cl_lock)
+{
+	loff_t *p = f->private, pos = *ppos;
+	struct rpc_clnt *clnt;
+	struct rpc_task *task;
+	struct sunrpc_net *sn = net_generic(current->nsproxy->net_ns,
+						sunrpc_net_id);
+
+	*p = pos + 1;
+	spin_lock(&sn->rpc_client_lock);
+	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
+		spin_lock(&clnt->cl_lock);
+		list_for_each_entry(task, &clnt->cl_tasks, tk_task)
+			if (pos-- == 0)
+				return task;
+		spin_unlock(&clnt->cl_lock);
+	}
+	return NULL;
+}
+
+static void *
+tasks_next(struct seq_file *f, void *v, loff_t *pos)
+	__releases(&clnt->cl_lock)
+	__acquires(&clnt->cl_lock)
+{
+	loff_t *p = f->private;
+	struct rpc_task *task = v;
+	struct rpc_clnt *clnt = task->tk_client;
+	struct list_head *next = task->tk_task.next;
+	struct sunrpc_net *sn = net_generic(current->nsproxy->net_ns,
+						sunrpc_net_id);
+
+	++*p;
+	++*pos;
+
+	/* If there's another task on list, return it */
+	if (next != &clnt->cl_tasks)
+		return list_entry(next, struct rpc_task, tk_task);
+
+	/* We're finished with this client, move on */
+	spin_unlock(&clnt->cl_lock);
+next_client:
+	next = clnt->cl_clients.next;
+	if (next == &sn->all_clients)
+		return NULL;
+
+	clnt = list_entry(next, struct rpc_clnt, cl_clients);
+	if (list_empty(&clnt->cl_tasks))
+		goto next_client;
+	spin_lock(&clnt->cl_lock);
+	if (list_empty(&clnt->cl_tasks)) {
+		spin_unlock(&clnt->cl_lock);
+		goto next_client;
+	}
+	return list_first_entry(&clnt->cl_tasks, struct rpc_task, tk_task);
+}
+
+static void
+tasks_stop(struct seq_file *f, void *v)
+	__releases(&sn->rpc_client_lock)
+	__releases(&clnt->cl_lock)
+{
+	struct rpc_task *task = v;
+	struct rpc_clnt *clnt;
+	struct sunrpc_net *sn = net_generic(current->nsproxy->net_ns,
+						sunrpc_net_id);
+
+	if (v) {
+		clnt = task->tk_client;
+		spin_unlock(&clnt->cl_lock);
+	}
+	spin_unlock(&sn->rpc_client_lock);
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
+	return seq_open_private(filp, &tasks_seq_operations,
+				sizeof(loff_t));
+}
+
+static const struct file_operations tasks_fops = {
+	.owner		= THIS_MODULE,
+	.open		= tasks_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
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
+		return -ENOMEM;
+
+	if (!debugfs_create_file("client_tasks", S_IFREG | S_IRUSR, topdir,
+					NULL, &tasks_fops)) {
+		debugfs_remove_recursive(topdir);
+		return -ENOMEM;
+	}
+	return 0;
+}
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index cd30120de9e4..32583adf3477 100644
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
 #ifdef RPC_DEBUG
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
1.9.3

