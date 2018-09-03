Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38756 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTup (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:45 -0400
Received: by mail-io0-f196.google.com with SMTP id y3-v6so691345ioc.5
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:05 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:03 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/27] SUNRPC: Rename TCP receive-specific state variables
Date: Mon,  3 Sep 2018 11:29:15 -0400
Message-Id: <20180903152936.24325-7-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-6-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since we will want to introduce similar TCP state variables for the
transmission of requests, let's rename the existing ones to label
that they are for the receive side.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprtsock.h |  16 +--
 include/trace/events/sunrpc.h   |  10 +-
 net/sunrpc/xprtsock.c           | 178 ++++++++++++++++----------------
 3 files changed, 103 insertions(+), 101 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index ae0f99b9b965..90d5ca8e65f4 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -30,15 +30,17 @@ struct sock_xprt {
 	/*
 	 * State of TCP reply receive
 	 */
-	__be32			tcp_fraghdr,
-				tcp_xid,
-				tcp_calldir;
+	struct {
+		__be32		fraghdr,
+				xid,
+				calldir;
 
-	u32			tcp_offset,
-				tcp_reclen;
+		u32		offset,
+				len;
 
-	unsigned long		tcp_copied,
-				tcp_flags;
+		unsigned long	copied,
+				flags;
+	} recv;
 
 	/*
 	 * Connection of transports
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index bbb08a3ef5cc..0aa347194e0f 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -525,11 +525,11 @@ TRACE_EVENT(xs_tcp_data_recv,
 	TP_fast_assign(
 		__assign_str(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR]);
 		__assign_str(port, xs->xprt.address_strings[RPC_DISPLAY_PORT]);
-		__entry->xid = be32_to_cpu(xs->tcp_xid);
-		__entry->flags = xs->tcp_flags;
-		__entry->copied = xs->tcp_copied;
-		__entry->reclen = xs->tcp_reclen;
-		__entry->offset = xs->tcp_offset;
+		__entry->xid = be32_to_cpu(xs->recv.xid);
+		__entry->flags = xs->recv.flags;
+		__entry->copied = xs->recv.copied;
+		__entry->reclen = xs->recv.len;
+		__entry->offset = xs->recv.offset;
 	),
 
 	TP_printk("peer=[%s]:%s xid=0x%08x flags=%s copied=%lu reclen=%u offset=%lu",
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 6b7539c0466e..cd7d093721ae 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1169,42 +1169,42 @@ static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_rea
 	size_t len, used;
 	char *p;
 
-	p = ((char *) &transport->tcp_fraghdr) + transport->tcp_offset;
-	len = sizeof(transport->tcp_fraghdr) - transport->tcp_offset;
+	p = ((char *) &transport->recv.fraghdr) + transport->recv.offset;
+	len = sizeof(transport->recv.fraghdr) - transport->recv.offset;
 	used = xdr_skb_read_bits(desc, p, len);
-	transport->tcp_offset += used;
+	transport->recv.offset += used;
 	if (used != len)
 		return;
 
-	transport->tcp_reclen = ntohl(transport->tcp_fraghdr);
-	if (transport->tcp_reclen & RPC_LAST_STREAM_FRAGMENT)
-		transport->tcp_flags |= TCP_RCV_LAST_FRAG;
+	transport->recv.len = ntohl(transport->recv.fraghdr);
+	if (transport->recv.len & RPC_LAST_STREAM_FRAGMENT)
+		transport->recv.flags |= TCP_RCV_LAST_FRAG;
 	else
-		transport->tcp_flags &= ~TCP_RCV_LAST_FRAG;
-	transport->tcp_reclen &= RPC_FRAGMENT_SIZE_MASK;
+		transport->recv.flags &= ~TCP_RCV_LAST_FRAG;
+	transport->recv.len &= RPC_FRAGMENT_SIZE_MASK;
 
-	transport->tcp_flags &= ~TCP_RCV_COPY_FRAGHDR;
-	transport->tcp_offset = 0;
+	transport->recv.flags &= ~TCP_RCV_COPY_FRAGHDR;
+	transport->recv.offset = 0;
 
 	/* Sanity check of the record length */
-	if (unlikely(transport->tcp_reclen < 8)) {
+	if (unlikely(transport->recv.len < 8)) {
 		dprintk("RPC:       invalid TCP record fragment length\n");
 		xs_tcp_force_close(xprt);
 		return;
 	}
 	dprintk("RPC:       reading TCP record fragment of length %d\n",
-			transport->tcp_reclen);
+			transport->recv.len);
 }
 
 static void xs_tcp_check_fraghdr(struct sock_xprt *transport)
 {
-	if (transport->tcp_offset == transport->tcp_reclen) {
-		transport->tcp_flags |= TCP_RCV_COPY_FRAGHDR;
-		transport->tcp_offset = 0;
-		if (transport->tcp_flags & TCP_RCV_LAST_FRAG) {
-			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-			transport->tcp_flags |= TCP_RCV_COPY_XID;
-			transport->tcp_copied = 0;
+	if (transport->recv.offset == transport->recv.len) {
+		transport->recv.flags |= TCP_RCV_COPY_FRAGHDR;
+		transport->recv.offset = 0;
+		if (transport->recv.flags & TCP_RCV_LAST_FRAG) {
+			transport->recv.flags &= ~TCP_RCV_COPY_DATA;
+			transport->recv.flags |= TCP_RCV_COPY_XID;
+			transport->recv.copied = 0;
 		}
 	}
 }
@@ -1214,20 +1214,20 @@ static inline void xs_tcp_read_xid(struct sock_xprt *transport, struct xdr_skb_r
 	size_t len, used;
 	char *p;
 
-	len = sizeof(transport->tcp_xid) - transport->tcp_offset;
+	len = sizeof(transport->recv.xid) - transport->recv.offset;
 	dprintk("RPC:       reading XID (%zu bytes)\n", len);
-	p = ((char *) &transport->tcp_xid) + transport->tcp_offset;
+	p = ((char *) &transport->recv.xid) + transport->recv.offset;
 	used = xdr_skb_read_bits(desc, p, len);
-	transport->tcp_offset += used;
+	transport->recv.offset += used;
 	if (used != len)
 		return;
-	transport->tcp_flags &= ~TCP_RCV_COPY_XID;
-	transport->tcp_flags |= TCP_RCV_READ_CALLDIR;
-	transport->tcp_copied = 4;
+	transport->recv.flags &= ~TCP_RCV_COPY_XID;
+	transport->recv.flags |= TCP_RCV_READ_CALLDIR;
+	transport->recv.copied = 4;
 	dprintk("RPC:       reading %s XID %08x\n",
-			(transport->tcp_flags & TCP_RPC_REPLY) ? "reply for"
+			(transport->recv.flags & TCP_RPC_REPLY) ? "reply for"
 							      : "request with",
-			ntohl(transport->tcp_xid));
+			ntohl(transport->recv.xid));
 	xs_tcp_check_fraghdr(transport);
 }
 
@@ -1239,34 +1239,34 @@ static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
 	char *p;
 
 	/*
-	 * We want transport->tcp_offset to be 8 at the end of this routine
+	 * We want transport->recv.offset to be 8 at the end of this routine
 	 * (4 bytes for the xid and 4 bytes for the call/reply flag).
 	 * When this function is called for the first time,
-	 * transport->tcp_offset is 4 (after having already read the xid).
+	 * transport->recv.offset is 4 (after having already read the xid).
 	 */
-	offset = transport->tcp_offset - sizeof(transport->tcp_xid);
-	len = sizeof(transport->tcp_calldir) - offset;
+	offset = transport->recv.offset - sizeof(transport->recv.xid);
+	len = sizeof(transport->recv.calldir) - offset;
 	dprintk("RPC:       reading CALL/REPLY flag (%zu bytes)\n", len);
-	p = ((char *) &transport->tcp_calldir) + offset;
+	p = ((char *) &transport->recv.calldir) + offset;
 	used = xdr_skb_read_bits(desc, p, len);
-	transport->tcp_offset += used;
+	transport->recv.offset += used;
 	if (used != len)
 		return;
-	transport->tcp_flags &= ~TCP_RCV_READ_CALLDIR;
+	transport->recv.flags &= ~TCP_RCV_READ_CALLDIR;
 	/*
 	 * We don't yet have the XDR buffer, so we will write the calldir
 	 * out after we get the buffer from the 'struct rpc_rqst'
 	 */
-	switch (ntohl(transport->tcp_calldir)) {
+	switch (ntohl(transport->recv.calldir)) {
 	case RPC_REPLY:
-		transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
-		transport->tcp_flags |= TCP_RCV_COPY_DATA;
-		transport->tcp_flags |= TCP_RPC_REPLY;
+		transport->recv.flags |= TCP_RCV_COPY_CALLDIR;
+		transport->recv.flags |= TCP_RCV_COPY_DATA;
+		transport->recv.flags |= TCP_RPC_REPLY;
 		break;
 	case RPC_CALL:
-		transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
-		transport->tcp_flags |= TCP_RCV_COPY_DATA;
-		transport->tcp_flags &= ~TCP_RPC_REPLY;
+		transport->recv.flags |= TCP_RCV_COPY_CALLDIR;
+		transport->recv.flags |= TCP_RCV_COPY_DATA;
+		transport->recv.flags &= ~TCP_RPC_REPLY;
 		break;
 	default:
 		dprintk("RPC:       invalid request message type\n");
@@ -1287,21 +1287,21 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 
 	rcvbuf = &req->rq_private_buf;
 
-	if (transport->tcp_flags & TCP_RCV_COPY_CALLDIR) {
+	if (transport->recv.flags & TCP_RCV_COPY_CALLDIR) {
 		/*
 		 * Save the RPC direction in the XDR buffer
 		 */
-		memcpy(rcvbuf->head[0].iov_base + transport->tcp_copied,
-			&transport->tcp_calldir,
-			sizeof(transport->tcp_calldir));
-		transport->tcp_copied += sizeof(transport->tcp_calldir);
-		transport->tcp_flags &= ~TCP_RCV_COPY_CALLDIR;
+		memcpy(rcvbuf->head[0].iov_base + transport->recv.copied,
+			&transport->recv.calldir,
+			sizeof(transport->recv.calldir));
+		transport->recv.copied += sizeof(transport->recv.calldir);
+		transport->recv.flags &= ~TCP_RCV_COPY_CALLDIR;
 	}
 
 	len = desc->count;
-	if (len > transport->tcp_reclen - transport->tcp_offset)
-		desc->count = transport->tcp_reclen - transport->tcp_offset;
-	r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
+	if (len > transport->recv.len - transport->recv.offset)
+		desc->count = transport->recv.len - transport->recv.offset;
+	r = xdr_partial_copy_from_skb(rcvbuf, transport->recv.copied,
 					  desc, xdr_skb_read_bits);
 
 	if (desc->count) {
@@ -1314,31 +1314,31 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 		 * Any remaining data from this record will
 		 * be discarded.
 		 */
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+		transport->recv.flags &= ~TCP_RCV_COPY_DATA;
 		dprintk("RPC:       XID %08x truncated request\n",
-				ntohl(transport->tcp_xid));
-		dprintk("RPC:       xprt = %p, tcp_copied = %lu, "
-				"tcp_offset = %u, tcp_reclen = %u\n",
-				xprt, transport->tcp_copied,
-				transport->tcp_offset, transport->tcp_reclen);
+				ntohl(transport->recv.xid));
+		dprintk("RPC:       xprt = %p, recv.copied = %lu, "
+				"recv.offset = %u, recv.len = %u\n",
+				xprt, transport->recv.copied,
+				transport->recv.offset, transport->recv.len);
 		return;
 	}
 
-	transport->tcp_copied += r;
-	transport->tcp_offset += r;
+	transport->recv.copied += r;
+	transport->recv.offset += r;
 	desc->count = len - r;
 
 	dprintk("RPC:       XID %08x read %zd bytes\n",
-			ntohl(transport->tcp_xid), r);
-	dprintk("RPC:       xprt = %p, tcp_copied = %lu, tcp_offset = %u, "
-			"tcp_reclen = %u\n", xprt, transport->tcp_copied,
-			transport->tcp_offset, transport->tcp_reclen);
-
-	if (transport->tcp_copied == req->rq_private_buf.buflen)
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-	else if (transport->tcp_offset == transport->tcp_reclen) {
-		if (transport->tcp_flags & TCP_RCV_LAST_FRAG)
-			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+			ntohl(transport->recv.xid), r);
+	dprintk("RPC:       xprt = %p, recv.copied = %lu, recv.offset = %u, "
+			"recv.len = %u\n", xprt, transport->recv.copied,
+			transport->recv.offset, transport->recv.len);
+
+	if (transport->recv.copied == req->rq_private_buf.buflen)
+		transport->recv.flags &= ~TCP_RCV_COPY_DATA;
+	else if (transport->recv.offset == transport->recv.len) {
+		if (transport->recv.flags & TCP_RCV_LAST_FRAG)
+			transport->recv.flags &= ~TCP_RCV_COPY_DATA;
 	}
 }
 
@@ -1353,14 +1353,14 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 				container_of(xprt, struct sock_xprt, xprt);
 	struct rpc_rqst *req;
 
-	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->tcp_xid));
+	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->recv.xid));
 
 	/* Find and lock the request corresponding to this xid */
 	spin_lock(&xprt->recv_lock);
-	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
+	req = xprt_lookup_rqst(xprt, transport->recv.xid);
 	if (!req) {
 		dprintk("RPC:       XID %08x request not found!\n",
-				ntohl(transport->tcp_xid));
+				ntohl(transport->recv.xid));
 		spin_unlock(&xprt->recv_lock);
 		return -1;
 	}
@@ -1370,8 +1370,8 @@ static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
 	xs_tcp_read_common(xprt, desc, req);
 
 	spin_lock(&xprt->recv_lock);
-	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
-		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
+	if (!(transport->recv.flags & TCP_RCV_COPY_DATA))
+		xprt_complete_rqst(req->rq_task, transport->recv.copied);
 	xprt_unpin_rqst(req);
 	spin_unlock(&xprt->recv_lock);
 	return 0;
@@ -1393,7 +1393,7 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 	struct rpc_rqst *req;
 
 	/* Look up the request corresponding to the given XID */
-	req = xprt_lookup_bc_request(xprt, transport->tcp_xid);
+	req = xprt_lookup_bc_request(xprt, transport->recv.xid);
 	if (req == NULL) {
 		printk(KERN_WARNING "Callback slot table overflowed\n");
 		xprt_force_disconnect(xprt);
@@ -1403,8 +1403,8 @@ static int xs_tcp_read_callback(struct rpc_xprt *xprt,
 	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
 	xs_tcp_read_common(xprt, desc, req);
 
-	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
-		xprt_complete_bc_request(req, transport->tcp_copied);
+	if (!(transport->recv.flags & TCP_RCV_COPY_DATA))
+		xprt_complete_bc_request(req, transport->recv.copied);
 
 	return 0;
 }
@@ -1415,7 +1415,7 @@ static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
 	struct sock_xprt *transport =
 				container_of(xprt, struct sock_xprt, xprt);
 
-	return (transport->tcp_flags & TCP_RPC_REPLY) ?
+	return (transport->recv.flags & TCP_RPC_REPLY) ?
 		xs_tcp_read_reply(xprt, desc) :
 		xs_tcp_read_callback(xprt, desc);
 }
@@ -1458,9 +1458,9 @@ static void xs_tcp_read_data(struct rpc_xprt *xprt,
 	else {
 		/*
 		 * The transport_lock protects the request handling.
-		 * There's no need to hold it to update the tcp_flags.
+		 * There's no need to hold it to update the recv.flags.
 		 */
-		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+		transport->recv.flags &= ~TCP_RCV_COPY_DATA;
 	}
 }
 
@@ -1468,12 +1468,12 @@ static inline void xs_tcp_read_discard(struct sock_xprt *transport, struct xdr_s
 {
 	size_t len;
 
-	len = transport->tcp_reclen - transport->tcp_offset;
+	len = transport->recv.len - transport->recv.offset;
 	if (len > desc->count)
 		len = desc->count;
 	desc->count -= len;
 	desc->offset += len;
-	transport->tcp_offset += len;
+	transport->recv.offset += len;
 	dprintk("RPC:       discarded %zu bytes\n", len);
 	xs_tcp_check_fraghdr(transport);
 }
@@ -1494,22 +1494,22 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 		trace_xs_tcp_data_recv(transport);
 		/* Read in a new fragment marker if necessary */
 		/* Can we ever really expect to get completely empty fragments? */
-		if (transport->tcp_flags & TCP_RCV_COPY_FRAGHDR) {
+		if (transport->recv.flags & TCP_RCV_COPY_FRAGHDR) {
 			xs_tcp_read_fraghdr(xprt, &desc);
 			continue;
 		}
 		/* Read in the xid if necessary */
-		if (transport->tcp_flags & TCP_RCV_COPY_XID) {
+		if (transport->recv.flags & TCP_RCV_COPY_XID) {
 			xs_tcp_read_xid(transport, &desc);
 			continue;
 		}
 		/* Read in the call/reply flag */
-		if (transport->tcp_flags & TCP_RCV_READ_CALLDIR) {
+		if (transport->recv.flags & TCP_RCV_READ_CALLDIR) {
 			xs_tcp_read_calldir(transport, &desc);
 			continue;
 		}
 		/* Read in the request data */
-		if (transport->tcp_flags & TCP_RCV_COPY_DATA) {
+		if (transport->recv.flags & TCP_RCV_COPY_DATA) {
 			xs_tcp_read_data(xprt, &desc);
 			continue;
 		}
@@ -1602,10 +1602,10 @@ static void xs_tcp_state_change(struct sock *sk)
 		if (!xprt_test_and_set_connected(xprt)) {
 
 			/* Reset TCP record info */
-			transport->tcp_offset = 0;
-			transport->tcp_reclen = 0;
-			transport->tcp_copied = 0;
-			transport->tcp_flags =
+			transport->recv.offset = 0;
+			transport->recv.len = 0;
+			transport->recv.copied = 0;
+			transport->recv.flags =
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 			xprt->connect_cookie++;
 			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
-- 
2.17.1
