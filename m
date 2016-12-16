Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35009 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753265AbcLPQs1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Dec 2016 11:48:27 -0500
Received: by mail-it0-f65.google.com with SMTP id b123so3216120itb.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Dec 2016 08:48:27 -0800 (PST)
Subject: [PATCH v1] NFS: Detect unreachable NFS/RDMA servers more reliably
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 16 Dec 2016 11:48:25 -0500
Message-ID: <20161216164108.7060.93683.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current NFS clients rely on connection loss to determine when to
retransmit. In particular, for protocols like NFSv4, clients no
longer rely on RPC timeouts to drive retransmission: NFSv4 servers
are required to terminate a connection when they need  a client to
retransmit pending RPCs.

When a server is no longer reachable, either because it has crashed
or because the network path has broken, the server cannot actively
terminate a connection. Thus NFS clients depend on transport-level
keepalive to determine when a connection must be replaced and
pending RPCs retransmitted.

However, RDMA RC connections do not have a native keepalive
mechanism. If an NFS/RDMA server crashes after a client has sent
RPCs successfully (an RC ACK has been received for all OTW RDMA
requests), there is no way for the client to know the connection is
moribund.

In addition, new RDMA requests are subject to the RPC-over-RDMA
credit limit. If the client has consumed all granted credits with
NFS traffic, it is not allowed to send another RDMA request until
the server replies. Thus it has no way to send a true keepalive when
the workload has already consumed all credits with pending RPCs.

To address this, we reserve one RPC-over-RDMA credit that may be
used only for an NFS NULL. A periodic RPC ping is done on transports
whenever there are outstanding RPCs.

The purpose of this ping is to drive traffic regularly on each
connection to force the transport layer to disconnect it if it is no
longer viable. Some RDMA operations are fully offloaded to the HCA,
and can be successful even if the remote host has crashed. Thus an
operation that requires that the server is responsive is used for
the ping.

This implementation re-uses existing generic RPC infrastructure to
form each NULL Call. An rpc_clnt context must be available to start
an RPC. Thus a generic keepalive mechanism is introduced so that
both an rpc_clnt and an rpc_xprt is available to perform the ping.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Before sending this for internal testing, I'd like to hear comments
on this approach. It's a little more churn than I had hoped for.


 fs/nfs/nfs4client.c             |    1 
 include/linux/sunrpc/clnt.h     |    2 +
 include/linux/sunrpc/sched.h    |    3 +
 include/linux/sunrpc/xprt.h     |    1 
 net/sunrpc/clnt.c               |  101 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c              |   19 +++++++
 net/sunrpc/xprt.c               |    5 ++
 net/sunrpc/xprtrdma/rpc_rdma.c  |    4 +-
 net/sunrpc/xprtrdma/transport.c |   13 +++++
 9 files changed, 148 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 074ac71..c5f5ce8 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -378,6 +378,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 		error = nfs_create_rpc_client(clp, cl_init, RPC_AUTH_UNIX);
 	if (error < 0)
 		goto error;
+	rpc_schedule_keepalive(clp->cl_rpcclient);
 
 	/* If no clientaddr= option was specified, find a usable cb address */
 	if (ip_addr == NULL) {
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 85cc819..443a955 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -69,6 +69,7 @@ struct rpc_clnt {
 	struct dentry		*cl_debugfs;	/* debugfs directory */
 #endif
 	struct rpc_xprt_iter	cl_xpi;
+	struct delayed_work	cl_ka_worker;
 };
 
 /*
@@ -187,6 +188,7 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
+void		rpc_schedule_keepalive(struct rpc_clnt *clnt);
 
 int 		rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
 			int (*fn)(struct rpc_clnt *, struct rpc_xprt *, void *),
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7ba040c..fd5d7ca 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -127,6 +127,7 @@ struct rpc_task_setup {
 #define RPC_TASK_TIMEOUT	0x1000		/* fail with ETIMEDOUT on timeout */
 #define RPC_TASK_NOCONNECT	0x2000		/* return ENOTCONN if not connected */
 #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/* wait forever for a reply */
+#define RPC_TASK_PRIORITY	0x8000		/* skip congestion control */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
@@ -135,6 +136,7 @@ struct rpc_task_setup {
 #define RPC_IS_SOFT(t)		((t)->tk_flags & (RPC_TASK_SOFT|RPC_TASK_TIMEOUT))
 #define RPC_IS_SOFTCONN(t)	((t)->tk_flags & RPC_TASK_SOFTCONN)
 #define RPC_WAS_SENT(t)		((t)->tk_flags & RPC_TASK_SENT)
+#define RPC_HAS_PRIORITY(t)	((t)->tk_flags & RPC_TASK_PRIORITY)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
@@ -238,6 +240,7 @@ struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
 					bool (*)(struct rpc_task *, void *),
 					void *);
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
+bool		rpc_wait_queue_is_active(struct rpc_wait_queue *queue);
 void		rpc_delay(struct rpc_task *, unsigned long);
 int		rpc_malloc(struct rpc_task *);
 void		rpc_free(struct rpc_task *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a5da60b..603cd67 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -222,6 +222,7 @@ struct rpc_xprt {
 	unsigned long		last_used,
 				idle_timeout,
 				max_reconnect_timeout;
+	bool			keepalive;
 
 	/*
 	 * Send stuff
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 62a4827..ff46c79 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -79,6 +79,7 @@
 static __be32	*rpc_encode_header(struct rpc_task *task);
 static __be32	*rpc_verify_header(struct rpc_task *task);
 static int	rpc_ping(struct rpc_clnt *clnt);
+static void rpc_clnt_keepalive(struct work_struct *work);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
 {
@@ -413,6 +414,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	rpc_clnt_set_transport(clnt, xprt, timeout);
 	xprt_iter_init(&clnt->cl_xpi, xps);
 	xprt_switch_put(xps);
+	INIT_DELAYED_WORK(&clnt->cl_ka_worker, rpc_clnt_keepalive);
 
 	clnt->cl_rtt = &clnt->cl_rtt_default;
 	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
@@ -871,6 +873,7 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
 			rcu_dereference(clnt->cl_xprt)->servername);
 	if (clnt->cl_parent != clnt)
 		parent = clnt->cl_parent;
+	cancel_delayed_work_sync(&clnt->cl_ka_worker);
 	rpc_clnt_debugfs_unregister(clnt);
 	rpc_clnt_remove_pipedir(clnt);
 	rpc_unregister_client(clnt);
@@ -2782,6 +2785,104 @@ bool rpc_clnt_xprt_switch_has_addr(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_xprt_switch_has_addr);
 
+struct rpc_keepalive_calldata {
+	struct rpc_xprt		*xprt;
+};
+
+static void rpc_keepalive_done(struct rpc_task *task, void *calldata)
+{
+	struct rpc_keepalive_calldata *data = calldata;
+
+	dprintk("RPC:       %s: keepalive ping on xprt %p, status %d\n",
+		__func__, data->xprt, task->tk_status);
+
+	if (task->tk_status)
+		xprt_force_disconnect(data->xprt);
+}
+
+static void rpc_keepalive_release(void *calldata)
+{
+	struct rpc_keepalive_calldata *data = calldata;
+
+	data->xprt->keepalive = true;
+	xprt_put(data->xprt);
+	kfree(data);
+}
+
+static const struct rpc_call_ops rpc_keepalive_call_ops = {
+	.rpc_call_done		= rpc_keepalive_done,
+	.rpc_release		= rpc_keepalive_release,
+};
+
+static int rpc_xprt_keepalive(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
+			      void *unused)
+{
+	struct rpc_keepalive_calldata *data;
+	struct rpc_cred *cred;
+	struct rpc_task *task;
+
+	if (!xprt->keepalive)
+		goto out;
+	if (!xprt_connected(xprt))
+		goto out;
+
+	/* When there are no pending RPCs, squelch keepalive so that a
+	 * truly idle connection can be auto-closed.
+	 */
+	if (!rpc_wait_queue_is_active(&xprt->pending))
+		goto out;
+
+	dprintk("RPC:       %s: sending keepalive ping on xprt %p\n",
+		__func__, xprt);
+
+	data = kmalloc(sizeof(*data), GFP_NOFS);
+	if (!data)
+		goto out;
+	data->xprt = xprt_get(xprt);
+
+	/* Send only one keepalive ping at a time.
+	 */
+	xprt->keepalive = false;
+
+	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
+	task = rpc_call_null_helper(clnt, xprt, cred,
+				    RPC_TASK_SOFT |
+				    RPC_TASK_ASYNC |
+				    RPC_TASK_PRIORITY,
+				    &rpc_keepalive_call_ops,
+				    data);
+
+	put_rpccred(cred);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
+out:
+	return 0;
+}
+
+static void rpc_clnt_keepalive(struct work_struct *work)
+{
+	struct rpc_clnt *clnt = container_of(work, struct rpc_clnt,
+					     cl_ka_worker.work);
+
+	rpc_clnt_iterate_for_each_xprt(clnt, rpc_xprt_keepalive, NULL);
+	rpc_schedule_keepalive(clnt);
+}
+
+/**
+ * rpc_schedule_keepalive - Start keepalive heartbeat
+ * @clnt: rpc_clnt with transports that might need keepalive
+ *
+ * For transport classes that do not have a native keepalive mechanism,
+ * detect dead transports as quickly as possible. An RPC NULL is used
+ * as the ping.
+ */
+void rpc_schedule_keepalive(struct rpc_clnt *clnt)
+{
+	schedule_delayed_work(&clnt->cl_ka_worker,
+			      clnt->cl_timeout->to_initval >> 1);
+}
+EXPORT_SYMBOL_GPL(rpc_schedule_keepalive);
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static void rpc_show_header(void)
 {
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 5db68b3..bb98a9f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -635,6 +635,25 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 }
 EXPORT_SYMBOL_GPL(rpc_wake_up_status);
 
+/**
+ * rpc_wait_queue_is_active - check if there are queue waiters
+ * @queue: rpc_wait_queue on which the tasks are sleeping
+ *
+ * Grabs queue->lock
+ */
+bool rpc_wait_queue_is_active(struct rpc_wait_queue *queue)
+{
+	struct list_head *head;
+	bool result;
+
+	spin_lock_bh(&queue->lock);
+	head = &queue->tasks[queue->maxpriority];
+	result = !list_empty(head);
+	spin_unlock_bh(&queue->lock);
+
+	return result;
+}
+
 static void __rpc_queue_timer_fn(unsigned long ptr)
 {
 	struct rpc_wait_queue *queue = (struct rpc_wait_queue *)ptr;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 685e6d2..941949c 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -392,6 +392,10 @@ static inline void xprt_release_write(struct rpc_xprt *xprt, struct rpc_task *ta
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
+	if (RPC_HAS_PRIORITY(task)) {
+		req->rq_cong = 0;
+		return 1;
+	}
 	if (req->rq_cong)
 		return 1;
 	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd = %lu\n",
@@ -1328,6 +1332,7 @@ static void xprt_init(struct rpc_xprt *xprt, struct net *net)
 	xprt->last_used = jiffies;
 	xprt->cwnd = RPC_INITCWND;
 	xprt->bind_index = 0;
+	xprt->keepalive = false;
 
 	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
 	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c52e0f2..9631fcf 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1083,7 +1083,9 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	spin_lock_bh(&xprt->transport_lock);
 	cwnd = xprt->cwnd;
-	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) << RPC_CWNDSHIFT;
+	/* Reserve one credit for keepalive ping */
+	xprt->cwnd = atomic_read(&r_xprt->rx_buf.rb_credits) - 1;
+	xprt->cwnd <<= RPC_CWNDSHIFT;
 	if (xprt->cwnd > cwnd)
 		xprt_release_rqst_cong(rqst->rq_task);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 534c178..cb6e67b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -312,6 +312,18 @@
 	module_put(THIS_MODULE);
 }
 
+static bool
+rpcrdma_need_keepalive(struct rpcrdma_xprt *r_xprt)
+{
+	struct rdma_cm_id *id = r_xprt->rx_ia.ri_id;
+
+	/* RDMA RC on InfiniBand has no native keepalive
+	 * mechanism. iWARP runs on a lower layer that
+	 * already provides keepalive.
+	 */
+	return !rdma_protocol_iwarp(id->device, id->port_num);
+}
+
 static const struct rpc_timeout xprt_rdma_default_timeout = {
 	.to_initval = 60 * HZ,
 	.to_maxval = 60 * HZ,
@@ -433,6 +445,7 @@
 	xprt->max_payload = new_xprt->rx_ia.ri_ops->ro_maxpages(new_xprt);
 	if (xprt->max_payload == 0)
 		goto out4;
+	xprt->keepalive = rpcrdma_need_keepalive(new_xprt);
 	xprt->max_payload <<= PAGE_SHIFT;
 	dprintk("RPC:       %s: transport data payload maximum: %zu bytes\n",
 		__func__, xprt->max_payload);

