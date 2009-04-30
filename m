From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 09/39] nfs41: New xs_tcp_read_data()
Date: Fri,  1 May 2009 02:20:33 +0300
Message-ID: <1241133633-590-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1200 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755539AbZD3XUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:20:43 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Handles RPC replies and backchannel callbacks.  Traditionally the NFS
client has expected only RPC replies on its open connections.  With
NFSv4.1, callbacks can arrive over an existing open connection.

This patch refactors the old xs_tcp_read_request() into an RPC reply handler:
xs_tcp_read_reply(), a new backchannel callback handler: xs_tcp_read_callback(),
and a common routine to read the data off the transport: xs_tcp_read_common().
The new xs_tcp_read_callback() queues callback requests onto a queue where
the callback service (a separate thread) is listening for the processing.

This patch incorporates work and suggestions from Rahul Iyer (iyer@netapp.com)
and Benny Halevy (bhalevy@panasas.com).

[nfs41: Keep track of RPC call/reply direction with a flag]
[nfs41: Preallocate rpc_rqst receive buffer for handling callbacks]
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xprtsock.c |  141 ++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 123 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 692b517..403ebda 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -34,6 +34,9 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/file.h>
+#ifdef CONFIG_NFS_V4_1
+#include <linux/sunrpc/bc_xprt.h>
+#endif
 
 #include <net/sock.h>
 #include <net/checksum.h>
@@ -1028,25 +1031,16 @@ static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
 	xs_tcp_check_fraghdr(transport);
 }
 
-static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
+static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
+				     struct xdr_skb_reader *desc,
+				     struct rpc_rqst *req)
 {
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
-	struct rpc_rqst *req;
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *rcvbuf;
 	size_t len;
 	ssize_t r;
 
-	/* Find and lock the request corresponding to this xid */
-	spin_lock(&xprt->transport_lock);
-	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
-	if (!req) {
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-		dprintk("RPC:       XID %08x request not found!\n",
-				ntohl(transport->tcp_xid));
-		spin_unlock(&xprt->transport_lock);
-		return;
-	}
-
 	rcvbuf = &req->rq_private_buf;
 	len = desc->count;
 	if (len > transport->tcp_reclen - transport->tcp_offset) {
@@ -1084,7 +1078,7 @@ static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_rea
 				"tcp_offset = %u, tcp_reclen = %u\n",
 				xprt, transport->tcp_copied,
 				transport->tcp_offset, transport->tcp_reclen);
-		goto out;
+		return;
 	}
 
 	dprintk("RPC:       XID %08x read %Zd bytes\n",
@@ -1100,11 +1094,122 @@ static inline void xs_tcp_read_request(struct rpc_xprt *xprt, struct xdr_skb_rea
 			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
 	}
 
-out:
+	return;
+}
+
+/*
+ * Finds the request corresponding to the RPC xid and invokes the common
+ * tcp read code to read the data.
+ */
+static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
+				    struct xdr_skb_reader *desc)
+{
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+	struct rpc_rqst *req;
+
+	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
+
+	/* Find and lock the request corresponding to this xid */
+	spin_lock(&xprt->transport_lock);
+	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
+	if (!req) {
+		dprintk("RPC:       XID %08x request not found!\n",
+				ntohl(transport->tcp_xid));
+		spin_unlock(&xprt->transport_lock);
+		return -1;
+	}
+
+	xs_tcp_read_common(xprt, desc, req);
+
 	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
 		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
+
 	spin_unlock(&xprt->transport_lock);
-	xs_tcp_check_fraghdr(transport);
+	return 0;
+}
+
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * Obtains an rpc_rqst previously allocated and invokes the common
+ * tcp read code to read the data.  The result is placed in the callback
+ * queue.
+ * If we're unable to obtain the rpc_rqst we schedule the closing of the
+ * connection and return -1.
+ */
+static inline int xs_tcp_read_callback(struct rpc_xprt *xprt,
+				       struct xdr_skb_reader *desc)
+{
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+	struct rpc_rqst *req;
+
+	req = xprt_alloc_bc_request(xprt);
+	if (req == NULL) {
+		/*
+		 * Schedule an autoclose RPC call
+		 */
+		printk(KERN_WARNING "Callback slot table overflowed\n");
+		set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+		if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
+			queue_work(rpciod_workqueue, &xprt->task_cleanup);
+		return -1;
+	}
+
+	req->rq_xid = transport->tcp_xid;
+	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
+	xs_tcp_read_common(xprt, desc, req);
+
+	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
+		struct svc_serv *bc_serv = xprt->bc_serv;
+
+		/*
+		 * Add callback request to callback list.  The callback
+		 * service sleeps on the sv_cb_waitq waiting for new
+		 * requests.  Wake it up after adding enqueing the
+		 * request.
+		 */
+		dprintk("RPC:       add callback request to list\n");
+		spin_lock(&bc_serv->sv_cb_lock);
+		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
+		spin_unlock(&bc_serv->sv_cb_lock);
+		wake_up(&bc_serv->sv_cb_waitq);
+	}
+
+	req->rq_private_buf.len = transport->tcp_copied;
+
+	return 0;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+/*
+ * Read data off the transport.  This can be either an RPC_CALL or an
+ * RPC_REPLY.  Relay the processing to helper functions.
+ */
+static void xs_tcp_read_data(struct rpc_xprt *xprt,
+				    struct xdr_skb_reader *desc)
+{
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+	int status;
+
+#if defined(CONFIG_NFS_V4_1)
+	status = (transport->tcp_flags & TCP_RPC_REPLY) ?
+		xs_tcp_read_reply(xprt, desc) :
+		xs_tcp_read_callback(xprt, desc);
+#else
+	status = xs_tcp_read_reply(xprt, desc);
+#endif /* CONFIG_NFS_V4_1 */
+
+	if (status == 0)
+		xs_tcp_check_fraghdr(transport);
+	else {
+		/*
+		 * The transport_lock protects the request handling.
+		 * There's no need to hold it to update the tcp_flags.
+		 */
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+	}
 }
 
 static inline void xs_tcp_read_discard(struct sock_xprt *transport, struct xdr_skb_reader *desc)
@@ -1151,7 +1256,7 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 		}
 		/* Read in the request data */
 		if (transport->tcp_flags & TCP_RCV_COPY_DATA) {
-			xs_tcp_read_request(xprt, &desc);
+			xs_tcp_read_data(xprt, &desc);
 			continue;
 		}
 		/* Skip over any trailing bytes on short reads */
-- 
1.6.2.1

