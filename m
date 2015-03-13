Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35494 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbbCMVXt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:23:49 -0400
Received: by ieclw3 with SMTP id lw3so127745614iec.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:23:49 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id h19sm2020260igq.10.2015.03.13.14.23.47
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:23:48 -0700 (PDT)
Subject: [PATCH v1 16/16] xprtrdma: Split rb_lock
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:23:46 -0400
Message-ID: <20150313212346.22471.72828.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

/proc/lock_stat showed contention between rpcrdma_buffer_get/put
and the MR allocation functions during I/O intensive workloads.

Now that MRs are no longer allocated in rpcrdma_buffer_get(),
there's no reason the rb_mws list has to be managed using the
same lock as the send/receive buffers. Split that lock. The
new lock does not need to disable interrupts because buffer
get/put is never called in an interrupt context.

struct rpcrdma_buffer is re-arranged to ensure rb_mwlock and
rb_mws is always in a different cacheline than rb_lock and the
buffer pointers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    6 +++---
 net/sunrpc/xprtrdma/frwr_ops.c  |   28 ++++++++++++----------------
 net/sunrpc/xprtrdma/verbs.c     |    5 ++---
 net/sunrpc/xprtrdma/xprt_rdma.h |   16 +++++++++-------
 4 files changed, 26 insertions(+), 29 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 1404f20..00d362d 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -96,6 +96,7 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	struct rpcrdma_mw *r;
 	int i, rc;
 
+	spin_lock_init(&buf->rb_mwlock);
 	INIT_LIST_HEAD(&buf->rb_mws);
 	INIT_LIST_HEAD(&buf->rb_all);
 
@@ -128,9 +129,8 @@ __fmr_get_mw(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_mw *mw = NULL;
-	unsigned long flags;
 
-	spin_lock_irqsave(&buf->rb_lock, flags);
+	spin_lock(&buf->rb_mwlock);
 
 	if (!list_empty(&buf->rb_mws)) {
 		mw = list_entry(buf->rb_mws.next,
@@ -140,7 +140,7 @@ __fmr_get_mw(struct rpcrdma_xprt *r_xprt)
 		pr_err("RPC:       %s: no MWs available\n", __func__);
 	}
 
-	spin_unlock_irqrestore(&buf->rb_lock, flags);
+	spin_unlock(&buf->rb_mwlock);
 	return mw;
 }
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 4494668..7973b94 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -196,6 +196,7 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 	int i;
 
+	spin_lock_init(&buf->rb_mwlock);
 	INIT_LIST_HEAD(&buf->rb_mws);
 	INIT_LIST_HEAD(&buf->rb_all);
 
@@ -228,10 +229,9 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
  * Redo only the ib_post_send().
  */
 static void
-__retry_local_inv(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
+__retry_local_inv(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *r)
 {
-	struct rpcrdma_xprt *r_xprt =
-				container_of(ia, struct rpcrdma_xprt, rx_ia);
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	struct ib_send_wr invalidate_wr, *bad_wr;
 	int rc;
 
@@ -258,30 +258,27 @@ __retry_local_inv(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 		dprintk("RPC:       %s: ib_post_send status %i\n",
 			__func__, rc);
 	}
+
+	rpcrdma_put_mw(r_xprt, r);
 }
 
 static void
-__retry_flushed_linv(struct rpcrdma_buffer *buf, struct list_head *stale)
+__retry_flushed_linv(struct rpcrdma_xprt *r_xprt, struct list_head *stale)
 {
-	struct rpcrdma_ia *ia = rdmab_to_ia(buf);
 	struct list_head *pos;
 	struct rpcrdma_mw *r;
-	unsigned long flags;
 	unsigned count;
 
 	count = 0;
 	list_for_each(pos, stale) {
 		r = list_entry(pos, struct rpcrdma_mw, mw_list);
-		__retry_local_inv(ia, r);
+		list_del_init(&r->mw_list);
+		__retry_local_inv(r_xprt, r);
 		++count;
 	}
 
-	pr_warn("RPC:       %s: adding %u MRs to rb_mws\n",
+	pr_warn("RPC:       %s: added %u MRs to rb_mws\n",
 		__func__, count);
-
-	spin_lock_irqsave(&buf->rb_lock, flags);
-	list_splice_tail(stale, &buf->rb_mws);
-	spin_unlock_irqrestore(&buf->rb_lock, flags);
 }
 
 static struct rpcrdma_mw *
@@ -289,11 +286,10 @@ __frwr_get_mw(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_mw *mw;
-	unsigned long flags;
 	LIST_HEAD(stale);
 	int count;
 
-	spin_lock_irqsave(&buf->rb_lock, flags);
+	spin_lock(&buf->rb_mwlock);
 	count = 0;
 	while (!list_empty(&buf->rb_mws)) {
 		mw = list_entry(buf->rb_mws.next, struct rpcrdma_mw, mw_list);
@@ -308,11 +304,11 @@ __frwr_get_mw(struct rpcrdma_xprt *r_xprt)
 	mw = NULL;
 
 out_unlock:
-	spin_unlock_irqrestore(&buf->rb_lock, flags);
+	spin_unlock(&buf->rb_mwlock);
 	if (!list_empty(&stale)) {
 		dprintk("RPC:       %s: found %d unsuitable MWs\n",
 			__func__, count);
-		__retry_flushed_linv(buf, &stale);
+		__retry_flushed_linv(r_xprt, &stale);
 	}
 	return mw;
 }
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 460c917..d4de417 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1172,15 +1172,14 @@ void
 rpcrdma_put_mw(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mw *mw)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	unsigned long flags;
 
 	if (!list_empty(&mw->mw_list))
 		pr_warn("RPC:       %s: mw %p still on a list!\n",
 			__func__, mw);
 
-	spin_lock_irqsave(&buf->rb_lock, flags);
+	spin_lock(&buf->rb_mwlock);
 	list_add_tail(&mw->mw_list, &buf->rb_mws);
-	spin_unlock_irqrestore(&buf->rb_lock, flags);
+	spin_unlock(&buf->rb_mwlock);
 }
 
 static void
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 10c4fa5..998f188 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -280,15 +280,17 @@ rpcr_to_rdmar(struct rpc_rqst *rqst)
  * One of these is associated with a transport instance
  */
 struct rpcrdma_buffer {
-	spinlock_t	rb_lock;	/* protects indexes */
-	u32		rb_max_requests;/* client max requests */
-	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
-	struct list_head rb_all;
-	int		rb_send_index;
+	spinlock_t		rb_mwlock;
+	struct list_head	rb_mws;
+	struct list_head	rb_all;
+	char			*rb_pool;
+
+	spinlock_t		rb_lock;
+	u32			rb_max_requests;
+	int			rb_send_index;
+	int			rb_recv_index;
 	struct rpcrdma_req	**rb_send_bufs;
-	int		rb_recv_index;
 	struct rpcrdma_rep	**rb_recv_bufs;
-	char		*rb_pool;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
 

