Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:9848 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab1GUNSw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 09:18:52 -0400
Subject: Re: [PATCH 09/10] nfs: use sk fragment destructors to delay I/O
 completion until page is released by network stack.
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1310738489.4381.20.camel@lade.trondhjem.org>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
	 <1310728031-19569-9-git-send-email-ian.campbell@citrix.com>
	 <1310738489.4381.20.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Jul 2011 14:18:50 +0100
Message-ID: <1311254330.32010.151.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-15 at 15:01 +0100, Trond Myklebust wrote:
> On Fri, 2011-07-15 at 12:07 +0100, Ian Campbell wrote: 
> > Thos prevents an issue where an ACK is delayed, a retransmit is queued (either
> > at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> > wire. If this happens then the write() system call and the userspace process
> > can continue potentially modifying the data before the retransmission occurs.
> > 
> > NB: this only covers the O_DIRECT write() case. I expect other cases to need
> > handling as well.
> 
> That is why this belongs entirely in the RPC layer, and really should
> not touch the NFS layer.
> If you move your callback to the RPC layer and have it notify the
> rpc_task when the pages have been sent, then it should be possible to
> achieve the same thing.
> 
> IOW: Add an extra state machine step after call_decode() which checks if
> all the page data has been transmitted and if not, puts the rpc_task on
> a wait queue, and has it wait for the fragment destructor callback
> before calling rpc_exit_task().
> 
> Cheers

Is this the sort of thing? I wasn't sure where best to put the
destructor data structure to get the right lifecycle and ended up
putting it in the struct rpc_rqst and initialising it at
xprt_request_init time.

I changed everywhere which currently transitions to rpc_exit_task to
transition to a new "call_complete" task, blocking on the pending wait
queue. The SKB destructor wakes that queue and call_complete then
transitions to rpc_exit_task.

Several of the locations already block on that wait queue so I simply
remove the wake up in those cases (since it will happen in the SKB frag
destructor). Since we call unref at these points (to drop the initial
refcount) in the common case we will be woken from the pending wait
queue before we even sleep on it.

Thanks,
Ian.

>From 49d7d53d065bf0963fd4bb70405f4f1972f618c4 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 11 Jul 2011 14:43:24 +0100
Subject: [PATCH] sunrpc: use SKB fragment destructors to delay completion until page is released by network stack.

This prevents an issue where an ACK is delayed, a retransmit is queued (either
at the RPC or TCP level) and the ACK arrives before the retransmission hits the
wire. If this happens to an NFS WRITE RPC then the write() system call
completes and the userspace process can continue, potentially modifying data
referenced by the retransmission before the retransmission occurs.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 include/linux/sunrpc/xdr.h  |    2 ++
 include/linux/sunrpc/xprt.h |    5 ++++-
 net/sunrpc/clnt.c           |   28 +++++++++++++++++++++++-----
 net/sunrpc/svcsock.c        |    2 +-
 net/sunrpc/xprt.c           |   13 +++++++++++++
 net/sunrpc/xprtsock.c       |    2 +-
 6 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index a20970e..172f81e 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -16,6 +16,7 @@
 #include <asm/byteorder.h>
 #include <asm/unaligned.h>
 #include <linux/scatterlist.h>
+#include <linux/skbuff.h>
 
 /*
  * Buffer adjustment
@@ -57,6 +58,7 @@ struct xdr_buf {
 			tail[1];	/* Appended after page data */
 
 	struct page **	pages;		/* Array of contiguous pages */
+	struct skb_frag_destructor *destructor;
 	unsigned int	page_base,	/* Start of page data */
 			page_len,	/* Length of page data */
 			flags;		/* Flags for data disposition */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 81cce3b..0de6bc3 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -91,7 +91,10 @@ struct rpc_rqst {
 						/* A cookie used to track the
 						   state of the transport
 						   connection */
-	
+	struct skb_frag_destructor destructor;	/* SKB paged fragment
+						 * destructor for
+						 * transmitted pages*/
+
 	/*
 	 * Partial send handling
 	 */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8c91415..0c85acb 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -61,6 +61,7 @@ static void	call_reserve(struct rpc_task *task);
 static void	call_reserveresult(struct rpc_task *task);
 static void	call_allocate(struct rpc_task *task);
 static void	call_decode(struct rpc_task *task);
+static void	call_complete(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
 static void	call_transmit(struct rpc_task *task);
@@ -1114,6 +1115,8 @@ rpc_xdr_encode(struct rpc_task *task)
 			 (char *)req->rq_buffer + req->rq_callsize,
 			 req->rq_rcvsize);
 
+	req->rq_snd_buf.destructor = &req->destructor;
+
 	p = rpc_encode_header(task);
 	if (p == NULL) {
 		printk(KERN_INFO "RPC: couldn't encode RPC header, exit EIO\n");
@@ -1277,6 +1280,7 @@ call_connect_status(struct rpc_task *task)
 static void
 call_transmit(struct rpc_task *task)
 {
+	struct rpc_rqst *req = task->tk_rqstp;
 	dprint_status(task);
 
 	task->tk_action = call_status;
@@ -1310,8 +1314,8 @@ call_transmit(struct rpc_task *task)
 	call_transmit_status(task);
 	if (rpc_reply_expected(task))
 		return;
-	task->tk_action = rpc_exit_task;
-	rpc_wake_up_queued_task(&task->tk_xprt->pending, task);
+	task->tk_action = call_complete;
+	skb_frag_destructor_unref(&req->destructor);
 }
 
 /*
@@ -1384,7 +1388,8 @@ call_bc_transmit(struct rpc_task *task)
 		return;
 	}
 
-	task->tk_action = rpc_exit_task;
+	task->tk_action = call_complete;
+	skb_frag_destructor_unref(&req->destructor);
 	if (task->tk_status < 0) {
 		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
 			"error: %d\n", task->tk_status);
@@ -1424,7 +1429,6 @@ call_bc_transmit(struct rpc_task *task)
 			"error: %d\n", task->tk_status);
 		break;
 	}
-	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
 }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -1591,12 +1595,14 @@ call_decode(struct rpc_task *task)
 		return;
 	}
 
-	task->tk_action = rpc_exit_task;
+	task->tk_action = call_complete;
 
 	if (decode) {
 		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
 						      task->tk_msg.rpc_resp);
 	}
+	rpc_sleep_on(&req->rq_xprt->pending, task, NULL);
+	skb_frag_destructor_unref(&req->destructor);
 	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
 			task->tk_status);
 	return;
@@ -1611,6 +1617,18 @@ out_retry:
 	}
 }
 
+/*
+ * 8.	Wait for pages to be released by the network stack.
+ */
+static void
+call_complete(struct rpc_task *task)
+{
+	struct rpc_rqst	*req = task->tk_rqstp;
+	dprintk("RPC: %5u call_complete result %d\n", task->tk_pid, task->tk_status);
+	task->tk_action = rpc_exit_task;
+	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
+}
+
 static __be32 *
 rpc_encode_header(struct rpc_task *task)
 {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a80b1d3..40c2420 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -194,7 +194,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	while (pglen > 0) {
 		if (slen == size)
 			flags = 0;
-		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
+		result = kernel_sendpage(sock, *ppage, xdr->destructor, base, size, flags);
 		if (result > 0)
 			len += result;
 		if (result != size)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce5eb68..62f52a3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1017,6 +1017,16 @@ static inline void xprt_init_xid(struct rpc_xprt *xprt)
 	xprt->xid = net_random();
 }
 
+static int xprt_complete_skb_pages(void *calldata)
+{
+	struct rpc_task *task = calldata;
+	struct rpc_rqst	*req = task->tk_rqstp;
+
+	dprintk("RPC: %5u completing skb pages\n", task->tk_pid);
+	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
+	return 0;
+}
+
 static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
@@ -1028,6 +1038,9 @@ static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
 	req->rq_xid     = xprt_alloc_xid(xprt);
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
+	atomic_set(&req->destructor.ref, 1);
+	req->destructor.destroy = &xprt_complete_skb_pages;
+	req->destructor.data = task;
 	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
 			req, ntohl(req->rq_xid));
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d027621..ca1643b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -397,7 +397,7 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 		remainder -= len;
 		if (remainder != 0 || more)
 			flags |= MSG_MORE;
-		err = sock->ops->sendpage(sock, *ppage, NULL, base, len, flags);
+		err = sock->ops->sendpage(sock, *ppage, xdr->destructor, base, len, flags);
 		if (remainder == 0 || err != len)
 			break;
 		sent += err;
-- 
1.7.2.5



