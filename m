From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 26/30] nfs: enable swap on NFS
Date: Tue, 13 Jul 2010 06:21:44 -0400
Message-ID: <20100713102144.2835.5915.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 61388a8872071bb5b0015b9f5e3183410a98d949 Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 13:11:13 +0800
Subject: [PATCH 26/30] nfs: enable swap on NFS

Implement all the new swapfile a_ops for NFS. This will set the NFS socket to
SOCK_MEMALLOC and run socket reconnect under PF_MEMALLOC as well as reset
SOCK_MEMALLOC before engaging the protocol ->connect() method.

PF_MEMALLOC should allow the allocation of struct socket and related objects
and the early (re)setting of SOCK_MEMALLOC should allow us to receive the
packets required for the TCP connection buildup.

(swapping continues over a server reset during heavy network traffic)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 fs/nfs/Kconfig              |   10 ++++++
 fs/nfs/file.c               |   18 +++++++++++
 fs/nfs/write.c              |   22 ++++++++++++++
 include/linux/nfs_fs.h      |    2 +
 include/linux/sunrpc/xprt.h |    5 ++-
 mm/page_io.c                |    1 +
 net/sunrpc/Kconfig          |    5 +++
 net/sunrpc/sched.c          |    9 ++++-
 net/sunrpc/xprtsock.c       |   68 +++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 137 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index a43d07e..b022858 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -74,6 +74,16 @@ config NFS_V4
 
 	  If unsure, say N.
 
+config NFS_SWAP
+	bool "Provide swap over NFS support"
+	default n
+	depends on NFS_FS
+	select SUNRPC_SWAP
+	help
+	  This option enables swapon to work on files located on NFS mounts.
+
+	  For more details, see Documentation/network-swap.txt
+
 config NFS_V4_1
 	bool "NFS client support for NFSv4.1 (DEVELOPER ONLY)"
 	depends on NFS_V4 && EXPERIMENTAL
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8f066fe..319c2b3 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -524,6 +524,18 @@ static int nfs_launder_page(struct page *page)
 	return nfs_wb_page(inode, page);
 }
 
+#ifdef CONFIG_NFS_SWAP
+static int nfs_swapon(struct file *file)
+{
+	return xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 1);
+}
+
+static int nfs_swapoff(struct file *file)
+{
+	return xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 0);
+}
+#endif
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -538,6 +550,12 @@ const struct address_space_operations nfs_file_aops = {
 	.migratepage = nfs_migrate_page,
 	.launder_page = nfs_launder_page,
 	.error_remove_page = generic_error_remove_page,
+#ifdef CONFIG_NFS_SWAP
+	.swapon = nfs_swapon,
+	.swapoff = nfs_swapoff,
+	.swap_out = nfs_swap_out,
+	.swap_in = nfs_readpage,
+#endif
 };
 
 /*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0d7ea95..5852b20 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -355,6 +355,28 @@ int nfs_writepage(struct page *page, struct writeback_control *wbc)
 	return ret;
 }
 
+static int nfs_writepage_setup(struct nfs_open_context *ctx, struct page *page,
+		unsigned int offset, unsigned int count);
+
+int nfs_swap_out(struct file *file, struct page *page,
+		 struct writeback_control *wbc)
+{
+	struct nfs_open_context *ctx = nfs_file_open_context(file);
+	int status;
+
+	status = nfs_writepage_setup(ctx, page, 0, nfs_page_length(page));
+	if (status < 0) {
+		nfs_set_pageerror(page);
+		goto out;
+	}
+
+	status = nfs_writepage_locked(page, wbc);
+
+out:
+	unlock_page(page);
+	return status;
+}
+
 static int nfs_writepages_callback(struct page *page, struct writeback_control *wbc, void *data)
 {
 	int ret;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 77c2ae5..fc1bbfb 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -484,6 +484,8 @@ extern int  nfs_writepages(struct address_space *, struct writeback_control *);
 extern int  nfs_flush_incompatible(struct file *file, struct page *page);
 extern int  nfs_updatepage(struct file *, struct page *, unsigned int, unsigned int);
 extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
+extern int  nfs_swap_out(struct file *file, struct page *page,
+			 struct writeback_control *wbc);
 
 /*
  * Try to write back everything synchronously (but check the
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index b514703..ba2330d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -171,7 +171,9 @@ struct rpc_xprt {
 	unsigned int		max_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
-				resvport   : 1; /* use a reserved port */
+				resvport   : 1, /* use a reserved port */
+				swapper    : 1; /* we're swapping over this
+						   transport */
 	unsigned int		bind_index;	/* bind function index */
 
 	/*
@@ -303,6 +305,7 @@ void			xprt_release_rqst_cong(struct rpc_task *task);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
+int			xs_swapper(struct rpc_xprt *xprt, int enable);
 
 /*
  * Reserved bit positions in xprt->state
diff --git a/mm/page_io.c b/mm/page_io.c
index 012b9ef..c8d7d8d 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -94,6 +94,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct bio *bio;
 	int ret = 0, rw = WRITE;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (try_to_free_swap(page)) {
 		unlock_page(page);
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 443c161..521eadb 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -17,6 +17,11 @@ config SUNRPC_XPRT_RDMA
 
 	  If unsure, say N.
 
+config SUNRPC_SWAP
+	def_bool n
+	depends on SUNRPC
+	select NETVM
+
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 4a843b8..6a16dc0 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -742,7 +742,10 @@ static void rpc_async_schedule(struct work_struct *work)
 void *rpc_malloc(struct rpc_task *task, size_t size)
 {
 	struct rpc_buffer *buf;
-	gfp_t gfp = RPC_IS_SWAPPER(task) ? GFP_ATOMIC : GFP_NOWAIT;
+	gfp_t gfp = GFP_NOWAIT;
+
+	if (RPC_IS_SWAPPER(task))
+		gfp |= __GFP_MEMALLOC;
 
 	size += sizeof(struct rpc_buffer);
 	if (size <= RPC_BUFFER_MAXSIZE)
@@ -813,6 +816,8 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 		kref_get(&task->tk_client->cl_kref);
 		if (task->tk_client->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
+		if (task->tk_client->cl_xprt->swapper)
+			task->tk_flags |= RPC_TASK_SWAPPER;
 	}
 
 	if (task->tk_ops->rpc_call_prepare != NULL)
@@ -838,7 +843,7 @@ static void rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *ta
 static struct rpc_task *
 rpc_alloc_task(void)
 {
-	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
+	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOIO);
 }
 
 /*
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 49a62f0..5c8b918 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1631,6 +1631,55 @@ static inline void xs_reclassify_socket6(struct socket *sock)
 }
 #endif
 
+#ifdef CONFIG_SUNRPC_SWAP
+static void xs_set_memalloc(struct rpc_xprt *xprt)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+
+	if (xprt->swapper)
+		sk_set_memalloc(transport->inet);
+}
+
+#define RPC_BUF_RESERVE_PAGES \
+	kmalloc_estimate_objs(sizeof(struct rpc_rqst), GFP_KERNEL, RPC_MAX_SLOT_TABLE)
+#define RPC_RESERVE_PAGES	(RPC_BUF_RESERVE_PAGES + TX_RESERVE_PAGES)
+
+/**
+ * xs_swapper - Tag this transport as being used for swap.
+ * @xprt: transport to tag
+ * @enable: enable/disable
+ *
+ */
+int xs_swapper(struct rpc_xprt *xprt, int enable)
+{
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
+	int err = 0;
+
+	if (enable) {
+		/*
+		 * keep one extra sock reference so the reserve won't dip
+		 * when the socket gets reconnected.
+		 */
+		err = sk_adjust_memalloc(1, RPC_RESERVE_PAGES);
+		if (!err) {
+			xprt->swapper = 1;
+			xs_set_memalloc(xprt);
+		}
+	} else if (xprt->swapper) {
+		xprt->swapper = 0;
+		sk_clear_memalloc(transport->inet);
+		sk_adjust_memalloc(-1, -RPC_RESERVE_PAGES);
+	}
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(xs_swapper);
+#else
+static void xs_set_memalloc(struct rpc_xprt *xprt)
+{
+}
+#endif
+
 static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1655,6 +1704,8 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		transport->sock = sock;
 		transport->inet = sk;
 
+		xs_set_memalloc(xprt);
+
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 	xs_udp_do_set_buffer_size(xprt);
@@ -1672,11 +1723,15 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int err, status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 
@@ -1703,6 +1758,7 @@ static void xs_udp_connect_worker4(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /**
@@ -1717,11 +1773,15 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 		container_of(work, struct sock_xprt, connect_worker.work);
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int err, status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	/* Start by resetting any existing state */
 	xs_reset_transport(transport);
 
@@ -1748,6 +1808,7 @@ static void xs_udp_connect_worker6(struct work_struct *work)
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 /*
@@ -1822,6 +1883,8 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	if (!xprt_bound(xprt))
 		return -ENOTCONN;
 
+	xs_set_memalloc(xprt);
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -1842,11 +1905,15 @@ static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
 			struct sock_xprt *))
 {
 	struct socket *sock = transport->sock;
+	unsigned long pflags = current->flags;
 	int status = -EIO;
 
 	if (xprt->shutdown)
 		goto out;
 
+	if (xprt->swapper)
+		current->flags |= PF_MEMALLOC;
+
 	if (!sock) {
 		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
 		sock = create_sock(xprt, transport);
@@ -1907,6 +1974,7 @@ out_eagain:
 out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
+	tsk_restore_flags(current, pflags, PF_MEMALLOC);
 }
 
 static struct socket *xs_create_tcp_sock4(struct rpc_xprt *xprt,
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
