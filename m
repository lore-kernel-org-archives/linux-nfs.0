Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34816 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbEKSC3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:02:29 -0400
Subject: [PATCH v2 01/16] SUNRPC: Transport fault injection
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:02:25 -0400
Message-ID: <20150511180225.31263.95451.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It has been exceptionally useful to exercise the logic that handles
local immediate errors and RDMA connection loss.  To enable
developers to test this regularly and repeatably, add logic to
simulate connection loss every so often.

Fault injection is disabled by default. It is enabled with

  $ sudo echo xxx > /sys/kernel/debug/sunrpc/inject_fault/disconnect

where "xxx" is a large positive number of transport method calls
before a disconnect. A value of several thousand is usually a good
number that allows reasonable forward progress while still causing a
lot of connection drops.

These hooks are disabled when SUNRPC_DEBUG is turned off.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h     |   19 ++++++++++
 net/sunrpc/clnt.c               |    1 +
 net/sunrpc/debugfs.c            |   77 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprt.c               |    2 +
 net/sunrpc/xprtrdma/transport.c |   13 ++++++-
 net/sunrpc/xprtsock.c           |   10 +++++
 6 files changed, 121 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 8b93ef5..178190a 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -133,6 +133,7 @@ struct rpc_xprt_ops {
 	void		(*close)(struct rpc_xprt *xprt);
 	void		(*destroy)(struct rpc_xprt *xprt);
 	void		(*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
+	void		(*inject_disconnect)(struct rpc_xprt *xprt);
 };
 
 /*
@@ -241,6 +242,7 @@ struct rpc_xprt {
 	const char		*address_strings[RPC_DISPLAY_MAX];
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	struct dentry		*debugfs;		/* debugfs directory */
+	atomic_t		inject_disconnect;
 #endif
 };
 
@@ -431,6 +433,23 @@ static inline int xprt_test_and_set_binding(struct rpc_xprt *xprt)
 	return test_and_set_bit(XPRT_BINDING, &xprt->state);
 }
 
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+extern unsigned int rpc_inject_disconnect;
+static inline void xprt_inject_disconnect(struct rpc_xprt *xprt)
+{
+	if (!rpc_inject_disconnect)
+		return;
+	if (atomic_dec_return(&xprt->inject_disconnect))
+		return;
+	atomic_set(&xprt->inject_disconnect, rpc_inject_disconnect);
+	xprt->ops->inject_disconnect(xprt);
+}
+#else
+static inline void xprt_inject_disconnect(struct rpc_xprt *xprt)
+{
+}
+#endif
+
 #endif /* __KERNEL__*/
 
 #endif /* _LINUX_SUNRPC_XPRT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e6ce151..db4efb6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1614,6 +1614,7 @@ call_allocate(struct rpc_task *task)
 					req->rq_callsize + req->rq_rcvsize);
 	if (req->rq_buffer != NULL)
 		return;
+	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
 
diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 82962f7..7cc1b8a 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -10,9 +10,12 @@
 #include "netns.h"
 
 static struct dentry *topdir;
+static struct dentry *rpc_fault_dir;
 static struct dentry *rpc_clnt_dir;
 static struct dentry *rpc_xprt_dir;
 
+unsigned int rpc_inject_disconnect;
+
 struct rpc_clnt_iter {
 	struct rpc_clnt	*clnt;
 	loff_t		pos;
@@ -257,6 +260,8 @@ rpc_xprt_debugfs_register(struct rpc_xprt *xprt)
 		debugfs_remove_recursive(xprt->debugfs);
 		xprt->debugfs = NULL;
 	}
+
+	atomic_set(&xprt->inject_disconnect, rpc_inject_disconnect);
 }
 
 void
@@ -266,11 +271,78 @@ rpc_xprt_debugfs_unregister(struct rpc_xprt *xprt)
 	xprt->debugfs = NULL;
 }
 
+static int
+fault_open(struct inode *inode, struct file *filp)
+{
+	filp->private_data = kmalloc(128, GFP_KERNEL);
+	if (!filp->private_data)
+		return -ENOMEM;
+	return 0;
+}
+
+static int
+fault_release(struct inode *inode, struct file *filp)
+{
+	kfree(filp->private_data);
+	return 0;
+}
+
+static ssize_t
+fault_disconnect_read(struct file *filp, char __user *user_buf,
+		      size_t len, loff_t *offset)
+{
+	char *buffer = (char *)filp->private_data;
+	size_t size;
+
+	size = sprintf(buffer, "%u\n", rpc_inject_disconnect);
+	return simple_read_from_buffer(user_buf, len, offset, buffer, size);
+}
+
+static ssize_t
+fault_disconnect_write(struct file *filp, const char __user *user_buf,
+		       size_t len, loff_t *offset)
+{
+	char buffer[16];
+
+	len = min(len, sizeof(buffer) - 1);
+	if (copy_from_user(buffer, user_buf, len))
+		return -EFAULT;
+	buffer[len] = '\0';
+	if (kstrtouint(buffer, 10, &rpc_inject_disconnect))
+		return -EINVAL;
+	return len;
+}
+
+static const struct file_operations fault_disconnect_fops = {
+	.owner		= THIS_MODULE,
+	.open		= fault_open,
+	.read		= fault_disconnect_read,
+	.write		= fault_disconnect_write,
+	.release	= fault_release,
+};
+
+static struct dentry *
+inject_fault_dir(struct dentry *topdir)
+{
+	struct dentry *faultdir;
+
+	faultdir = debugfs_create_dir("inject_fault", topdir);
+	if (!faultdir)
+		return NULL;
+
+	if (!debugfs_create_file("disconnect", S_IFREG | S_IRUSR, faultdir,
+				 NULL, &fault_disconnect_fops))
+		return NULL;
+
+	return faultdir;
+}
+
 void __exit
 sunrpc_debugfs_exit(void)
 {
 	debugfs_remove_recursive(topdir);
 	topdir = NULL;
+	rpc_fault_dir = NULL;
 	rpc_clnt_dir = NULL;
 	rpc_xprt_dir = NULL;
 }
@@ -282,6 +354,10 @@ sunrpc_debugfs_init(void)
 	if (!topdir)
 		return;
 
+	rpc_fault_dir = inject_fault_dir(topdir);
+	if (!rpc_fault_dir)
+		goto out_remove;
+
 	rpc_clnt_dir = debugfs_create_dir("rpc_clnt", topdir);
 	if (!rpc_clnt_dir)
 		goto out_remove;
@@ -294,5 +370,6 @@ sunrpc_debugfs_init(void)
 out_remove:
 	debugfs_remove_recursive(topdir);
 	topdir = NULL;
+	rpc_fault_dir = NULL;
 	rpc_clnt_dir = NULL;
 }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1d4fe24..e1fb538 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -967,6 +967,7 @@ void xprt_transmit(struct rpc_task *task)
 		task->tk_status = status;
 		return;
 	}
+	xprt_inject_disconnect(xprt);
 
 	dprintk("RPC: %5u xmit complete\n", task->tk_pid);
 	task->tk_flags |= RPC_TASK_SENT;
@@ -1285,6 +1286,7 @@ void xprt_release(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 	if (req->rq_buffer)
 		xprt->ops->buf_free(req->rq_buffer);
+	xprt_inject_disconnect(xprt);
 	if (req->rq_cred != NULL)
 		put_rpccred(req->rq_cred);
 	task->tk_rqstp = NULL;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 54f23b1..dfcd52e 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -246,6 +246,16 @@ xprt_rdma_connect_worker(struct work_struct *work)
 	xprt_clear_connecting(xprt);
 }
 
+static void
+xprt_rdma_inject_disconnect(struct rpc_xprt *xprt)
+{
+	struct rpcrdma_xprt *r_xprt = container_of(xprt, struct rpcrdma_xprt,
+						   rx_xprt);
+
+	pr_info("rpcrdma: injecting transport disconnect on xprt=%p\n", xprt);
+	rdma_disconnect(r_xprt->rx_ia.ri_id);
+}
+
 /*
  * xprt_rdma_destroy
  *
@@ -700,7 +710,8 @@ static struct rpc_xprt_ops xprt_rdma_procs = {
 	.send_request		= xprt_rdma_send_request,
 	.close			= xprt_rdma_close,
 	.destroy		= xprt_rdma_destroy,
-	.print_stats		= xprt_rdma_print_stats
+	.print_stats		= xprt_rdma_print_stats,
+	.inject_disconnect	= xprt_rdma_inject_disconnect
 };
 
 static struct xprt_class xprt_rdma = {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 66891e3..a0e7138 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -863,6 +863,13 @@ static void xs_close(struct rpc_xprt *xprt)
 	xprt_disconnect_done(xprt);
 }
 
+static void xs_inject_disconnect(struct rpc_xprt *xprt)
+{
+	dprintk("RPC:       injecting transport disconnect on xprt=%p\n",
+		xprt);
+	xprt_disconnect_done(xprt);
+}
+
 static void xs_xprt_free(struct rpc_xprt *xprt)
 {
 	xs_free_peer_addresses(xprt);
@@ -2482,6 +2489,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 	.close			= xs_close,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_udp_print_stats,
+	.inject_disconnect	= xs_inject_disconnect,
 };
 
 static struct rpc_xprt_ops xs_tcp_ops = {
@@ -2498,6 +2506,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.close			= xs_tcp_shutdown,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,
+	.inject_disconnect	= xs_inject_disconnect,
 };
 
 /*
@@ -2515,6 +2524,7 @@ static struct rpc_xprt_ops bc_tcp_ops = {
 	.close			= bc_close,
 	.destroy		= bc_destroy,
 	.print_stats		= xs_tcp_print_stats,
+	.inject_disconnect	= xs_inject_disconnect,
 };
 
 static int xs_init_anyaddr(const int family, struct sockaddr *sap)

