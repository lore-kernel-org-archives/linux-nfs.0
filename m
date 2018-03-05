Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34177 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUNZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:13:25 -0500
Subject: [PATCH 6/9] SUNRPC: Add a ->free_slot transport callout
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:13:23 -0500
Message-ID: <20180305201323.10904.31929.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor: xprtrdma needs to have better control over when RPCs are
awoken from the backlog queue, so replace xprt_free_slot with a
transport op callout.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h                |    4 ++++
 net/sunrpc/xprt.c                          |    5 +++--
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 +
 net/sunrpc/xprtrdma/transport.c            |    1 +
 net/sunrpc/xprtsock.c                      |    4 ++++
 5 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 9784e28..706eef1 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -127,6 +127,8 @@ struct rpc_xprt_ops {
 	int		(*reserve_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*release_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*alloc_slot)(struct rpc_xprt *xprt, struct rpc_task *task);
+	void		(*free_slot)(struct rpc_xprt *xprt,
+				     struct rpc_rqst *req);
 	void		(*rpcbind)(struct rpc_task *task);
 	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
@@ -329,6 +331,8 @@ struct xprt_class {
 int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
 int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
+void			xprt_free_slot(struct rpc_xprt *xprt,
+				       struct rpc_rqst *req);
 void			xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a394b46..fb3093d 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1186,7 +1186,7 @@ void xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
 }
 EXPORT_SYMBOL_GPL(xprt_lock_and_alloc_slot);
 
-static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
+void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
 	spin_lock(&xprt->reserve_lock);
 	if (!xprt_dynamic_free_slot(xprt, req)) {
@@ -1196,6 +1196,7 @@ static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 	xprt_wake_up_backlog(xprt);
 	spin_unlock(&xprt->reserve_lock);
 }
+EXPORT_SYMBOL_GPL(xprt_free_slot);
 
 static void xprt_free_all_slots(struct rpc_xprt *xprt)
 {
@@ -1375,7 +1376,7 @@ void xprt_release(struct rpc_task *task)
 
 	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
 	if (likely(!bc_prealloc(req)))
-		xprt_free_slot(xprt, req);
+		xprt->ops->free_slot(xprt, req);
 	else
 		xprt_free_bc_request(req);
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index a73632c..1035516 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -273,6 +273,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
 	.alloc_slot		= xprt_alloc_slot,
+	.free_slot		= xprt_free_slot,
 	.release_request	= xprt_release_rqst_cong,
 	.buf_alloc		= xprt_rdma_bc_allocate,
 	.buf_free		= xprt_rdma_bc_free,
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index cc1aad3..40ff91d 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -780,6 +780,7 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong, /* sunrpc/xprt.c */
 	.alloc_slot		= xprt_alloc_slot,
+	.free_slot		= xprt_free_slot,
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def, /* ditto */
 	.timer			= xprt_rdma_timer,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e3c6a3d..2511c21 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2764,6 +2764,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
+	.free_slot		= xprt_free_slot,
 	.rpcbind		= xs_local_rpcbind,
 	.set_port		= xs_local_set_port,
 	.connect		= xs_local_connect,
@@ -2783,6 +2784,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
 	.alloc_slot		= xprt_alloc_slot,
+	.free_slot		= xprt_free_slot,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
@@ -2804,6 +2806,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
 	.alloc_slot		= xprt_lock_and_alloc_slot,
+	.free_slot		= xprt_free_slot,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
@@ -2835,6 +2838,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xprt_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
+	.free_slot		= xprt_free_slot,
 	.buf_alloc		= bc_malloc,
 	.buf_free		= bc_free,
 	.send_request		= bc_send_request,

