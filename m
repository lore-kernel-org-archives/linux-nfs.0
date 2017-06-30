Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55180 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752369AbdF3NYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:14 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 02/14] SUNRPC: rename "TCP" record parser to "stream" parser
Date: Fri, 30 Jun 2017 14:23:40 +0100
Message-Id: <20170630132352.32133-3-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The TCP record parser is really a RFC 1831 record fragment parser.
There is nothing TCP protocol-specific about parsing record fragments.
The parser can be reused for any SOCK_STREAM socket.

This patch renames functions and fields but xs_stream_data_ready() still
calls tcp_read_sock().  This is addressed in the next patch.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/linux/sunrpc/xprtsock.h |  31 ++---
 include/trace/events/sunrpc.h   |  26 ++--
 net/sunrpc/xprtsock.c           | 262 ++++++++++++++++++++--------------------
 3 files changed, 160 insertions(+), 159 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index c9959d7..6749774 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -27,17 +27,18 @@ struct sock_xprt {
 	struct sock *		inet;
 
 	/*
-	 * State of TCP reply receive
+	 * State of SOCK_STREAM reply receive
 	 */
-	__be32			tcp_fraghdr,
-				tcp_xid,
-				tcp_calldir;
+	__be32			stream_fraghdr,
+				stream_xid,
+				stream_calldir;
 
-	u32			tcp_offset,
-				tcp_reclen;
+	u32			stream_offset,
+				stream_reclen;
+
+	unsigned long		stream_copied,
+				stream_flags;
 
-	unsigned long		tcp_copied,
-				tcp_flags;
 
 	/*
 	 * Connection of transports
@@ -69,17 +70,17 @@ struct sock_xprt {
 /*
  * TCP receive state flags
  */
-#define TCP_RCV_LAST_FRAG	(1UL << 0)
-#define TCP_RCV_COPY_FRAGHDR	(1UL << 1)
-#define TCP_RCV_COPY_XID	(1UL << 2)
-#define TCP_RCV_COPY_DATA	(1UL << 3)
-#define TCP_RCV_READ_CALLDIR	(1UL << 4)
-#define TCP_RCV_COPY_CALLDIR	(1UL << 5)
+#define STREAM_RCV_LAST_FRAG	(1UL << 0)
+#define STREAM_RCV_COPY_FRAGHDR	(1UL << 1)
+#define STREAM_RCV_COPY_XID	(1UL << 2)
+#define STREAM_RCV_COPY_DATA	(1UL << 3)
+#define STREAM_RCV_READ_CALLDIR	(1UL << 4)
+#define STREAM_RCV_COPY_CALLDIR	(1UL << 5)
 
 /*
  * TCP RPC flags
  */
-#define TCP_RPC_REPLY		(1UL << 6)
+#define STREAM_RPC_REPLY	(1UL << 6)
 
 #define XPRT_SOCK_CONNECTING	1U
 #define XPRT_SOCK_DATA_READY	(2)
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 8a707f8..916a30b 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -400,15 +400,15 @@ TRACE_EVENT(xs_tcp_data_ready,
 
 #define rpc_show_sock_xprt_flags(flags) \
 	__print_flags(flags, "|", \
-		{ TCP_RCV_LAST_FRAG, "TCP_RCV_LAST_FRAG" }, \
-		{ TCP_RCV_COPY_FRAGHDR, "TCP_RCV_COPY_FRAGHDR" }, \
-		{ TCP_RCV_COPY_XID, "TCP_RCV_COPY_XID" }, \
-		{ TCP_RCV_COPY_DATA, "TCP_RCV_COPY_DATA" }, \
-		{ TCP_RCV_READ_CALLDIR, "TCP_RCV_READ_CALLDIR" }, \
-		{ TCP_RCV_COPY_CALLDIR, "TCP_RCV_COPY_CALLDIR" }, \
-		{ TCP_RPC_REPLY, "TCP_RPC_REPLY" })
+		{ STREAM_RCV_LAST_FRAG, "STREAM_RCV_LAST_FRAG" }, \
+		{ STREAM_RCV_COPY_FRAGHDR, "STREAM_RCV_COPY_FRAGHDR" }, \
+		{ STREAM_RCV_COPY_XID, "STREAM_RCV_COPY_XID" }, \
+		{ STREAM_RCV_COPY_DATA, "STREAM_RCV_COPY_DATA" }, \
+		{ STREAM_RCV_READ_CALLDIR, "STREAM_RCV_READ_CALLDIR" }, \
+		{ STREAM_RCV_COPY_CALLDIR, "STREAM_RCV_COPY_CALLDIR" }, \
+		{ STREAM_RPC_REPLY, "STREAM_RPC_REPLY" })
 
-TRACE_EVENT(xs_tcp_data_recv,
+TRACE_EVENT(xs_stream_data_recv,
 	TP_PROTO(struct sock_xprt *xs),
 
 	TP_ARGS(xs),
@@ -426,11 +426,11 @@ TRACE_EVENT(xs_tcp_data_recv,
 	TP_fast_assign(
 		__assign_str(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR]);
 		__assign_str(port, xs->xprt.address_strings[RPC_DISPLAY_PORT]);
-		__entry->xid = xs->tcp_xid;
-		__entry->flags = xs->tcp_flags;
-		__entry->copied = xs->tcp_copied;
-		__entry->reclen = xs->tcp_reclen;
-		__entry->offset = xs->tcp_offset;
+		__entry->xid = xs->stream_xid;
+		__entry->flags = xs->stream_flags;
+		__entry->copied = xs->stream_copied;
+		__entry->reclen = xs->stream_reclen;
+		__entry->offset = xs->stream_offset;
 	),
 
 	TP_printk("peer=[%s]:%s xid=0x%x flags=%s copied=%lu reclen=%u offset=%lu",
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d5b54c0..5c21aec 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1141,119 +1141,119 @@ static void xs_tcp_force_close(struct rpc_xprt *xprt)
 	xprt_force_disconnect(xprt);
 }
 
-static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
+static inline void xs_stream_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	size_t len, used;
 	char *p;
 
-	p = ((char *) &transport->tcp_fraghdr) + transport->tcp_offset;
-	len = sizeof(transport->tcp_fraghdr) - transport->tcp_offset;
+	p = ((char *) &transport->stream_fraghdr) + transport->stream_offset;
+	len = sizeof(transport->stream_fraghdr) - transport->stream_offset;
 	used = xdr_skb_read_bits(desc, p, len);
-	transport->tcp_offset += used;
+	transport->stream_offset += used;
 	if (used != len)
 		return;
 
-	transport->tcp_reclen = ntohl(transport->tcp_fraghdr);
-	if (transport->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
-		transport->tcp_flags |= TCP_RCV_LAST_FRAG;
+	transport->stream_reclen = ntohl(transport->stream_fraghdr);
+	if (transport->stream_reclen & RPC_LAST_STREAM_FRAGMENT)
+		transport->stream_flags |= STREAM_RCV_LAST_FRAG;
 	else
-		transport->tcp_flags &= ~TCP_RCV_LAST_FRAG;
-	transport->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
+		transport->stream_flags &= ~STREAM_RCV_LAST_FRAG;
+	transport->stream_reclen &= RPC_FRAGMENT_SIZE_MASK;
 
-	transport->tcp_flags &= ~TCP_RCV_COPY_FRAGHDR;
-	transport->tcp_offset = 0;
+	transport->stream_flags &= ~STREAM_RCV_COPY_FRAGHDR;
+	transport->stream_offset = 0;
 
 	/* Sanity check of the record length */
-	if (unlikely(transport->tcp_reclen < 8)) {
-		dprintk("RPC:       invalid TCP record fragment length\n");
+	if (unlikely(transport->stream_reclen < 8)) {
+		dprintk("RPC:       invalid record fragment length\n");
 		xs_tcp_force_close(xprt);
 		return;
 	}
-	dprintk("RPC:       reading TCP record fragment of length %d\n",
-			transport->tcp_reclen);
+	dprintk("RPC:       reading record fragment of length %d\n",
+			transport->stream_reclen);
 }
 
-static void xs_tcp_check_fraghdr(struct sock_xprt *transport)
+static void xs_stream_check_fraghdr(struct sock_xprt *transport)
 {
-	if (transport->tcp_offset == transport->tcp_reclen) {
-		transport->tcp_flags |= TCP_RCV_COPY_FRAGHDR;
-		transport->tcp_offset = 0;
-		if (transport->tcp_flags & TCP_RCV_LAST_FRAG) {
-			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-			transport->tcp_flags |= TCP_RCV_COPY_XID;
-			transport->tcp_copied = 0;
+	if (transport->stream_offset == transport->stream_reclen) {
+		transport->stream_flags |= STREAM_RCV_COPY_FRAGHDR;
+		transport->stream_offset = 0;
+		if (transport->stream_flags & STREAM_RCV_LAST_FRAG) {
+			transport->stream_flags &= ~STREAM_RCV_COPY_DATA;
+			transport->stream_flags |= STREAM_RCV_COPY_XID;
+			transport->stream_copied = 0;
 		}
 	}
 }
 
-static inline void xs_tcp_read_xid(struct sock_xprt *transport, struct xdr_skb_reader *desc)
+static inline void xs_stream_read_xid(struct sock_xprt *transport, struct xdr_skb_reader *desc)
 {
 	size_t len, used;
 	char *p;
 
-	len = sizeof(transport->tcp_xid) - transport->tcp_offset;
+	len = sizeof(transport->stream_xid) - transport->stream_offset;
 	dprintk("RPC:       reading XID (%zu bytes)\n", len);
-	p = ((char *) &transport->tcp_xid) + transport->tcp_offset;
+	p = ((char *) &transport->stream_xid) + transport->stream_offset;
 	used = xdr_skb_read_bits(desc, p, len);
-	transport->tcp_offset += used;
+	transport->stream_offset += used;
 	if (used != len)
 		return;
-	transport->tcp_flags &= ~TCP_RCV_COPY_XID;
-	transport->tcp_flags |= TCP_RCV_READ_CALLDIR;
-	transport->tcp_copied = 4;
+	transport->stream_flags &= ~STREAM_RCV_COPY_XID;
+	transport->stream_flags |= STREAM_RCV_READ_CALLDIR;
+	transport->stream_copied = 4;
 	dprintk("RPC:       reading %s XID %08x\n",
-			(transport->tcp_flags & TCP_RPC_REPLY) ? "reply for"
+			(transport->stream_flags & STREAM_RPC_REPLY) ? "reply for"
 							      : "request with",
-			ntohl(transport->tcp_xid));
-	xs_tcp_check_fraghdr(transport);
+			ntohl(transport->stream_xid));
+	xs_stream_check_fraghdr(transport);
 }
 
-static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
-				       struct xdr_skb_reader *desc)
+static inline void xs_stream_read_calldir(struct sock_xprt *transport,
+					  struct xdr_skb_reader *desc)
 {
 	size_t len, used;
 	u32 offset;
 	char *p;
 
 	/*
-	 * We want transport->tcp_offset to be 8 at the end of this routine
+	 * We want transport->stream_offset to be 8 at the end of this routine
 	 * (4 bytes for the xid and 4 bytes for the call/reply flag).
 	 * When this function is called for the first time,
-	 * transport->tcp_offset is 4 (after having already read the xid).
+	 * transport->stream_offset is 4 (after having already read the xid).
 	 */
-	offset = transport->tcp_offset - sizeof(transport->tcp_xid);
-	len = sizeof(transport->tcp_calldir) - offset;
+	offset = transport->stream_offset - sizeof(transport->stream_xid);
+	len = sizeof(transport->stream_calldir) - offset;
 	dprintk("RPC:       reading CALL/REPLY flag (%zu bytes)\n", len);
-	p = ((char *) &transport->tcp_calldir) + offset;
+	p = ((char *) &transport->stream_calldir) + offset;
 	used = xdr_skb_read_bits(desc, p, len);
-	transport->tcp_offset += used;
+	transport->stream_offset += used;
 	if (used != len)
 		return;
-	transport->tcp_flags &= ~TCP_RCV_READ_CALLDIR;
+	transport->stream_flags &= ~STREAM_RCV_READ_CALLDIR;
 	/*
 	 * We don't yet have the XDR buffer, so we will write the calldir
 	 * out after we get the buffer from the 'struct rpc_rqst'
 	 */
-	switch (ntohl(transport->tcp_calldir)) {
+	switch (ntohl(transport->stream_calldir)) {
 	case RPC_REPLY:
-		transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
-		transport->tcp_flags |= TCP_RCV_COPY_DATA;
-		transport->tcp_flags |= TCP_RPC_REPLY;
+		transport->stream_flags |= STREAM_RCV_COPY_CALLDIR;
+		transport->stream_flags |= STREAM_RCV_COPY_DATA;
+		transport->stream_flags |= STREAM_RPC_REPLY;
 		break;
 	case RPC_CALL:
-		transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
-		transport->tcp_flags |= TCP_RCV_COPY_DATA;
-		transport->tcp_flags &= ~TCP_RPC_REPLY;
+		transport->stream_flags |= STREAM_RCV_COPY_CALLDIR;
+		transport->stream_flags |= STREAM_RCV_COPY_DATA;
+		transport->stream_flags &= ~STREAM_RPC_REPLY;
 		break;
 	default:
 		dprintk("RPC:       invalid request message type\n");
 		xs_tcp_force_close(&transport->xprt);
 	}
-	xs_tcp_check_fraghdr(transport);
+	xs_stream_check_fraghdr(transport);
 }
 
-static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
+static inline void xs_stream_read_common(struct rpc_xprt *xprt,
 				     struct xdr_skb_reader *desc,
 				     struct rpc_rqst *req)
 {
@@ -1265,97 +1265,97 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 
 	rcvbuf = &req->rq_private_buf;
 
-	if (transport->tcp_flags & TCP_RCV_COPY_CALLDIR) {
+	if (transport->stream_flags & STREAM_RCV_COPY_CALLDIR) {
 		/*
 		 * Save the RPC direction in the XDR buffer
 		 */
-		memcpy(rcvbuf->head[0].iov_base + transport->tcp_copied,
-			&transport->tcp_calldir,
-			sizeof(transport->tcp_calldir));
-		transport->tcp_copied += sizeof(transport->tcp_calldir);
-		transport->tcp_flags &= ~TCP_RCV_COPY_CALLDIR;
+		memcpy(rcvbuf->head[0].iov_base + transport->stream_copied,
+			&transport->stream_calldir,
+			sizeof(transport->stream_calldir));
+		transport->stream_copied += sizeof(transport->stream_calldir);
+		transport->stream_flags &= ~STREAM_RCV_COPY_CALLDIR;
 	}
 
 	len = desc->count;
-	if (len > transport->tcp_reclen - transport->tcp_offset) {
+	if (len > transport->stream_reclen - transport->stream_offset) {
 		struct xdr_skb_reader my_desc;
 
-		len = transport->tcp_reclen - transport->tcp_offset;
+		len = transport->stream_reclen - transport->stream_offset;
 		memcpy(&my_desc, desc, sizeof(my_desc));
 		my_desc.count = len;
-		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
+		r = xdr_partial_copy_from_skb(rcvbuf, transport->stream_copied,
 					  &my_desc, xdr_skb_read_bits);
 		desc->count -= r;
 		desc->offset += r;
 	} else
-		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
+		r = xdr_partial_copy_from_skb(rcvbuf, transport->stream_copied,
 					  desc, xdr_skb_read_bits);
 
 	if (r > 0) {
-		transport->tcp_copied += r;
-		transport->tcp_offset += r;
+		transport->stream_copied += r;
+		transport->stream_offset += r;
 	}
 	if (r != len) {
 		/* Error when copying to the receive buffer,
 		 * usually because we weren't able to allocate
 		 * additional buffer pages. All we can do now
-		 * is turn off TCP_RCV_COPY_DATA, so the request
+		 * is turn off STREAM_RCV_COPY_DATA, so the request
 		 * will not receive any additional updates,
 		 * and time out.
 		 * Any remaining data from this record will
 		 * be discarded.
 		 */
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+		transport->stream_flags &= ~STREAM_RCV_COPY_DATA;
 		dprintk("RPC:       XID %08x truncated request\n",
-				ntohl(transport->tcp_xid));
-		dprintk("RPC:       xprt = %p, tcp_copied = %lu, "
-				"tcp_offset = %u, tcp_reclen = %u\n",
-				xprt, transport->tcp_copied,
-				transport->tcp_offset, transport->tcp_reclen);
+				ntohl(transport->stream_xid));
+		dprintk("RPC:       xprt = %p, stream_copied = %lu, "
+				"stream_offset = %u, stream_reclen = %u\n",
+				xprt, transport->stream_copied,
+				transport->stream_offset, transport->stream_reclen);
 		return;
 	}
 
 	dprintk("RPC:       XID %08x read %zd bytes\n",
-			ntohl(transport->tcp_xid), r);
-	dprintk("RPC:       xprt = %p, tcp_copied = %lu, tcp_offset = %u, "
-			"tcp_reclen = %u\n", xprt, transport->tcp_copied,
-			transport->tcp_offset, transport->tcp_reclen);
+			ntohl(transport->stream_xid), r);
+	dprintk("RPC:       xprt = %p, stream_copied = %lu, stream_offset = %u, "
+			"stream_reclen = %u\n", xprt, transport->stream_copied,
+			transport->stream_offset, transport->stream_reclen);
 
-	if (transport->tcp_copied == req->rq_private_buf.buflen)
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-	else if (transport->tcp_offset == transport->tcp_reclen) {
-		if (transport->tcp_flags & TCP_RCV_LAST_FRAG)
-			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+	if (transport->stream_copied == req->rq_private_buf.buflen)
+		transport->stream_flags &= ~STREAM_RCV_COPY_DATA;
+	else if (transport->stream_offset == transport->stream_reclen) {
+		if (transport->stream_flags & STREAM_RCV_LAST_FRAG)
+			transport->stream_flags &= ~STREAM_RCV_COPY_DATA;
 	}
 }
 
 /*
  * Finds the request corresponding to the RPC xid and invokes the common
- * tcp read code to read the data.
+ * read code to read the data.
  */
-static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
+static inline int xs_stream_read_reply(struct rpc_xprt *xprt,
 				    struct xdr_skb_reader *desc)
 {
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
 
-	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
+	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->stream_xid));
 
 	/* Find and lock the request corresponding to this xid */
 	spin_lock_bh(&xprt->transport_lock);
-	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
+	req = xprt_lookup_rqst(xprt, transport->stream_xid);
 	if (!req) {
 		dprintk("RPC:       XID %08x request not found!\n",
-				ntohl(transport->tcp_xid));
+				ntohl(transport->stream_xid));
 		spin_unlock_bh(&xprt->transport_lock);
 		return -1;
 	}
 
-	xs_tcp_read_common(xprt, desc, req);
+	xs_stream_read_common(xprt, desc, req);
 
-	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
-		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
+	if (!(transport->stream_flags & STREAM_RCV_COPY_DATA))
+		xprt_complete_rqst(req->rq_task, transport->stream_copied);
 
 	spin_unlock_bh(&xprt->transport_lock);
 	return 0;
@@ -1369,7 +1369,7 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
  * If we're unable to obtain the rpc_rqst we schedule the closing of the
  * connection and return -1.
  */
-static int xs_tcp_read_callback(struct rpc_xprt *xprt,
+static int xs_stream_read_callback(struct rpc_xprt *xprt,
 				       struct xdr_skb_reader *desc)
 {
 	struct sock_xprt *transport =
@@ -1378,7 +1378,7 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 
 	/* Look up and lock the request corresponding to the given XID */
 	spin_lock_bh(&xprt->transport_lock);
-	req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
+	req = xprt_lookup_bc_request(xprt, transport->stream_xid);
 	if (req == NULL) {
 		spin_unlock_bh(&xprt->transport_lock);
 		printk(KERN_WARNING "Callback slot table overflowed\n");
@@ -1387,24 +1387,24 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 	}
 
 	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
-	xs_tcp_read_common(xprt, desc, req);
+	xs_stream_read_common(xprt, desc, req);
 
-	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
-		xprt_complete_bc_request(req, transport->tcp_copied);
+	if (!(transport->stream_flags & STREAM_RCV_COPY_DATA))
+		xprt_complete_bc_request(req, transport->stream_copied);
 	spin_unlock_bh(&xprt->transport_lock);
 
 	return 0;
 }
 
-static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
-					struct xdr_skb_reader *desc)
+static inline int _xs_stream_read_data(struct rpc_xprt *xprt,
+				       struct xdr_skb_reader *desc)
 {
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
 
-	return (transport->tcp_flags & TCP_RPC_REPLY) ?
-		xs_tcp_read_reply(xprt, desc) :
-		xs_tcp_read_callback(xprt, desc);
+	return (transport->stream_flags & STREAM_RPC_REPLY) ?
+		xs_stream_read_reply(xprt, desc) :
+		xs_stream_read_callback(xprt, desc);
 }
 
 static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
@@ -1423,10 +1423,10 @@ static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
 	return PAGE_SIZE;
 }
 #else
-static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
-					struct xdr_skb_reader *desc)
+static inline int _xs_stream_read_data(struct rpc_xprt *xprt,
+				       struct xdr_skb_reader *desc)
 {
-	return xs_tcp_read_reply(xprt, desc);
+	return xs_stream_read_reply(xprt, desc);
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
@@ -1434,38 +1434,38 @@ static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
  * Read data off the transport.  This can be either an RPC_CALL or an
  * RPC_REPLY.  Relay the processing to helper functions.
  */
-static void xs_tcp_read_data(struct rpc_xprt *xprt,
-				    struct xdr_skb_reader *desc)
+static void xs_stream_read_data(struct rpc_xprt *xprt,
+				struct xdr_skb_reader *desc)
 {
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
 
-	if (_xs_tcp_read_data(xprt, desc) == 0)
-		xs_tcp_check_fraghdr(transport);
+	if (_xs_stream_read_data(xprt, desc) == 0)
+		xs_stream_check_fraghdr(transport);
 	else {
 		/*
 		 * The transport_lock protects the request handling.
-		 * There's no need to hold it to update the tcp_flags.
+		 * There's no need to hold it to update the stream_flags.
 		 */
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+		transport->stream_flags &= ~STREAM_RCV_COPY_DATA;
 	}
 }
 
-static inline void xs_tcp_read_discard(struct sock_xprt *transport, struct xdr_skb_reader *desc)
+static inline void xs_stream_read_discard(struct sock_xprt *transport, struct xdr_skb_reader *desc)
 {
 	size_t len;
 
-	len = transport->tcp_reclen - transport->tcp_offset;
+	len = transport->stream_reclen - transport->stream_offset;
 	if (len > desc->count)
 		len = desc->count;
 	desc->count -= len;
 	desc->offset += len;
-	transport->tcp_offset += len;
+	transport->stream_offset += len;
 	dprintk("RPC:       discarded %zu bytes\n", len);
-	xs_tcp_check_fraghdr(transport);
+	xs_stream_check_fraghdr(transport);
 }
 
-static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, unsigned int offset, size_t len)
+static int xs_stream_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, unsigned int offset, size_t len)
 {
 	struct rpc_xprt *xprt = rd_desc->arg.data;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
@@ -1475,35 +1475,35 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 		.count	= len,
 	};
 
-	dprintk("RPC:       xs_tcp_data_recv started\n");
+	dprintk("RPC:       %s started\n", __func__);
 	do {
-		trace_xs_tcp_data_recv(transport);
+		trace_xs_stream_data_recv(transport);
 		/* Read in a new fragment marker if necessary */
 		/* Can we ever really expect to get completely empty fragments? */
-		if (transport->tcp_flags & TCP_RCV_COPY_FRAGHDR) {
-			xs_tcp_read_fraghdr(xprt, &desc);
+		if (transport->stream_flags & STREAM_RCV_COPY_FRAGHDR) {
+			xs_stream_read_fraghdr(xprt, &desc);
 			continue;
 		}
 		/* Read in the xid if necessary */
-		if (transport->tcp_flags & TCP_RCV_COPY_XID) {
-			xs_tcp_read_xid(transport, &desc);
+		if (transport->stream_flags & STREAM_RCV_COPY_XID) {
+			xs_stream_read_xid(transport, &desc);
 			continue;
 		}
 		/* Read in the call/reply flag */
-		if (transport->tcp_flags & TCP_RCV_READ_CALLDIR) {
-			xs_tcp_read_calldir(transport, &desc);
+		if (transport->stream_flags & STREAM_RCV_READ_CALLDIR) {
+			xs_stream_read_calldir(transport, &desc);
 			continue;
 		}
 		/* Read in the request data */
-		if (transport->tcp_flags & TCP_RCV_COPY_DATA) {
-			xs_tcp_read_data(xprt, &desc);
+		if (transport->stream_flags & STREAM_RCV_COPY_DATA) {
+			xs_stream_read_data(xprt, &desc);
 			continue;
 		}
 		/* Skip over any trailing bytes on short reads */
-		xs_tcp_read_discard(transport, &desc);
+		xs_stream_read_discard(transport, &desc);
 	} while (desc.count);
-	trace_xs_tcp_data_recv(transport);
-	dprintk("RPC:       xs_tcp_data_recv done\n");
+	trace_xs_stream_data_recv(transport);
+	dprintk("RPC:       %s done\n", __func__);
 	return len - desc.count;
 }
 
@@ -1526,7 +1526,7 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	for (;;) {
 		lock_sock(sk);
-		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+		read = tcp_read_sock(sk, &rd_desc, xs_stream_data_recv);
 		if (read <= 0) {
 			clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 			release_sock(sk);
@@ -1577,12 +1577,12 @@ static void xs_tcp_state_change(struct sock *sk)
 		spin_lock(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
 
-			/* Reset TCP record info */
-			transport->tcp_offset = 0;
-			transport->tcp_reclen = 0;
-			transport->tcp_copied = 0;
-			transport->tcp_flags =
-				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
+			/* Reset stream record info */
+			transport->stream_offset = 0;
+			transport->stream_reclen = 0;
+			transport->stream_copied = 0;
+			transport->stream_flags =
+				STREAM_RCV_COPY_FRAGHDR | STREAM_RCV_COPY_XID;
 			xprt->connect_cookie++;
 			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 			xprt_clear_connecting(xprt);
-- 
2.9.4

