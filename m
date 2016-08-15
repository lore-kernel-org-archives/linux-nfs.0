Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33158 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbcHOUu5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:50:57 -0400
Subject: [PATCH v1 05/22] SUNRPC: Separate buffer pointers for RPC Call and
 Reply messages
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:50:55 -0400
Message-ID: <20160815205055.11652.59194.stgit@manet.1015granger.net>
In-Reply-To: <20160815195649.11652.32252.stgit@manet.1015granger.net>
References: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For xprtrdma, the RPC Call and Reply buffers are involved in real
I/O operations.

To start with, the DMA direction of the I/O for a Call is opposite
that of a Reply.

In the current arrangement, the Reply buffer address is on a
four-byte alignment just past the call buffer. Would be friendlier
on some platforms if that was at a DMA cache alignment instead.

Because the current arrangement allocates a single memory region
which contains both buffers, the RPC Reply buffer often contains a
page boundary in it when the Call buffer is large enough (which is
frequent).

It would be a little nicer for setting up DMA operations (and
possible registration of the Reply buffer) if the two buffers were
separated, well-aligned, and contained as few page boundaries as
possible.

Now, I could just pad out the single memory region used for the pair
of buffers. But frequently that would mean a lot of unused space to
ensure the Reply buffer did not have a page boundary.

Add a separate pointer to rpc_rqst that points right to the RPC
Reply buffer. This makes no difference to xprtsock, but it will help
xprtrdma in subsequent patches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprt.h     |    5 +++--
 net/sunrpc/clnt.c               |    2 +-
 net/sunrpc/sched.c              |    2 ++
 net/sunrpc/xprtrdma/transport.c |    2 ++
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 272c108..8e3f292 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -84,8 +84,9 @@ struct rpc_rqst {
 	struct list_head	rq_list;
 
 	__be32			*rq_buffer;	/* Call XDR encode buffer */
-	size_t			rq_callsize,
-				rq_rcvsize;
+	size_t			rq_callsize;
+	__be32			*rq_rbuffer;	/* Reply XDR decode buffer */
+	size_t			rq_rcvsize;
 	size_t			rq_xmit_bytes_sent;	/* total bytes sent */
 	size_t			rq_reply_bytes_recvd;	/* total reply bytes */
 							/* received */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 601b3ca..4c933a8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1768,7 +1768,7 @@ rpc_xdr_encode(struct rpc_task *task)
 		     req->rq_buffer,
 		     req->rq_callsize);
 	xdr_buf_init(&req->rq_rcv_buf,
-		     (__be32 *)((char *)req->rq_buffer + req->rq_callsize),
+		     req->rq_rbuffer,
 		     req->rq_rcvsize);
 
 	p = rpc_encode_header(task);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6690ebc..8ed0c87 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -891,6 +891,8 @@ int rpc_malloc(struct rpc_task *task)
 	dprintk("RPC: %5u allocated buffer of size %zu at %p\n",
 			task->tk_pid, size, buf);
 	rqst->rq_buffer = buf->data;
+	rqst->rq_rbuffer = (__be32 *)((char *)rqst->rq_buffer +
+				      rqst->rq_callsize);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(rpc_malloc);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e7f222f..1f5dc19 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -524,6 +524,8 @@ out:
 	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
+	rqst->rq_rbuffer = (__be32 *)((char *)rqst->rq_buffer +
+				      rqst->rq_rcvsize);
 	return 0;
 
 out_rdmabuf:

