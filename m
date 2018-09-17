Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f193.google.com ([209.85.222.193]:45169 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728327AbeIQSb4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:56 -0400
Received: by mail-qk1-f193.google.com with SMTP id z125-v6so8893948qkb.12
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:41 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.39
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:39 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 39/44] SUNRPC: Add a bvec array to struct xdr_buf for use with iovec_iter()
Date: Mon, 17 Sep 2018 09:03:30 -0400
Message-Id: <20180917130335.112832-40-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-39-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a bvec array to struct xdr_buf, and have the client allocate it
when we need to receive data into pages.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xdr.h  |  7 +++++++
 include/linux/sunrpc/xprt.h |  2 ++
 net/sunrpc/clnt.c           |  4 +++-
 net/sunrpc/xdr.c            | 34 ++++++++++++++++++++++++++++++++++
 net/sunrpc/xprt.c           | 17 +++++++++++++++++
 5 files changed, 63 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 431829233392..745587132a87 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -18,6 +18,7 @@
 #include <asm/unaligned.h>
 #include <linux/scatterlist.h>
 
+struct bio_vec;
 struct rpc_rqst;
 
 /*
@@ -52,6 +53,7 @@ struct xdr_buf {
 	struct kvec	head[1],	/* RPC header + non-page data */
 			tail[1];	/* Appended after page data */
 
+	struct bio_vec	*bvec;
 	struct page **	pages;		/* Array of pages */
 	unsigned int	page_base,	/* Start of page data */
 			page_len,	/* Length of page data */
@@ -70,6 +72,8 @@ xdr_buf_init(struct xdr_buf *buf, void *start, size_t len)
 	buf->head[0].iov_base = start;
 	buf->head[0].iov_len = len;
 	buf->tail[0].iov_len = 0;
+	buf->bvec = NULL;
+	buf->pages = NULL;
 	buf->page_len = 0;
 	buf->flags = 0;
 	buf->len = 0;
@@ -116,6 +120,9 @@ __be32 *xdr_decode_netobj(__be32 *p, struct xdr_netobj *);
 void	xdr_inline_pages(struct xdr_buf *, unsigned int,
 			 struct page **, unsigned int, unsigned int);
 void	xdr_terminate_string(struct xdr_buf *, const u32);
+size_t	xdr_buf_pagecount(struct xdr_buf *buf);
+int	xdr_alloc_bvec(struct xdr_buf *buf, gfp_t gfp);
+void	xdr_free_bvec(struct xdr_buf *buf);
 
 static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int len)
 {
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 9be399020dab..a4ab4f8d9140 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -141,6 +141,7 @@ struct rpc_xprt_ops {
 	void		(*connect)(struct rpc_xprt *xprt, struct rpc_task *task);
 	int		(*buf_alloc)(struct rpc_task *task);
 	void		(*buf_free)(struct rpc_task *task);
+	void		(*prepare_request)(struct rpc_rqst *req);
 	int		(*send_request)(struct rpc_rqst *req);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
@@ -343,6 +344,7 @@ int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_free_slot(struct rpc_xprt *xprt,
 				       struct rpc_rqst *req);
+void			xprt_request_prepare(struct rpc_rqst *req);
 bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_transmit(struct rpc_task *task);
 void			xprt_request_enqueue_receive(struct rpc_task *task);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 0c4b2e7d791f..ae3b8145da35 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1753,6 +1753,8 @@ rpc_xdr_encode(struct rpc_task *task)
 
 	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
 			task->tk_msg.rpc_argp);
+	if (task->tk_status == 0)
+		xprt_request_prepare(req);
 }
 
 /*
@@ -1768,7 +1770,7 @@ call_encode(struct rpc_task *task)
 	/* Did the encode result in an error condition? */
 	if (task->tk_status != 0) {
 		/* Was the error nonfatal? */
-		if (task->tk_status == -EAGAIN)
+		if (task->tk_status == -EAGAIN || task->tk_status == -ENOMEM)
 			rpc_delay(task, HZ >> 4);
 		else
 			rpc_exit(task, task->tk_status);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 30afbd236656..2bbb8d38d2bf 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -15,6 +15,7 @@
 #include <linux/errno.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/bvec.h>
 
 /*
  * XDR functions for basic NFS types
@@ -128,6 +129,39 @@ xdr_terminate_string(struct xdr_buf *buf, const u32 len)
 }
 EXPORT_SYMBOL_GPL(xdr_terminate_string);
 
+size_t
+xdr_buf_pagecount(struct xdr_buf *buf)
+{
+	if (!buf->page_len)
+		return 0;
+	return (buf->page_base + buf->page_len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+}
+
+int
+xdr_alloc_bvec(struct xdr_buf *buf, gfp_t gfp)
+{
+	size_t i, n = xdr_buf_pagecount(buf);
+
+	if (n != 0 && buf->bvec == NULL) {
+		buf->bvec = kmalloc_array(n, sizeof(buf->bvec[0]), gfp);
+		if (!buf->bvec)
+			return -ENOMEM;
+		for (i = 0; i < n; i++) {
+			buf->bvec[i].bv_page = buf->pages[i];
+			buf->bvec[i].bv_len = PAGE_SIZE;
+			buf->bvec[i].bv_offset = 0;
+		}
+	}
+	return 0;
+}
+
+void
+xdr_free_bvec(struct xdr_buf *buf)
+{
+	kfree(buf->bvec);
+	buf->bvec = NULL;
+}
+
 void
 xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
 		 struct page **pages, unsigned int base, unsigned int len)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d1a67e97e7d3..547519f25878 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1262,6 +1262,22 @@ xprt_request_dequeue_transmit(struct rpc_task *task)
 	spin_unlock(&xprt->queue_lock);
 }
 
+/**
+ * xprt_request_prepare - prepare an encoded request for transport
+ * @req: pointer to rpc_rqst
+ *
+ * Calls into the transport layer to do whatever is needed to prepare
+ * the request for transmission or receive.
+ */
+void
+xprt_request_prepare(struct rpc_rqst *req)
+{
+	struct rpc_xprt *xprt = req->rq_xprt;
+
+	if (xprt->ops->prepare_request)
+		xprt->ops->prepare_request(req);
+}
+
 /**
  * xprt_request_need_retransmit - Test if a task needs retransmission
  * @task: pointer to rpc_task
@@ -1726,6 +1742,7 @@ void xprt_release(struct rpc_task *task)
 	if (req->rq_buffer)
 		xprt->ops->buf_free(task);
 	xprt_inject_disconnect(xprt);
+	xdr_free_bvec(&req->rq_rcv_buf);
 	if (req->rq_cred != NULL)
 		put_rpccred(req->rq_cred);
 	task->tk_rqstp = NULL;
-- 
2.17.1
