Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:37316 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728327AbeIQSb6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:58 -0400
Received: by mail-qt0-f193.google.com with SMTP id n6-v6so15133401qtl.4
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:42 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.40
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:40 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching to using iterators
Date: Mon, 17 Sep 2018 09:03:31 -0400
Message-Id: <20180917130335.112832-41-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-40-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most of this code should also be reusable with other socket types.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprtsock.h |  19 +-
 include/trace/events/sunrpc.h   |  15 +-
 net/sunrpc/xprtsock.c           | 694 +++++++++++++++-----------------
 3 files changed, 335 insertions(+), 393 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 005cfb6e7238..458bfe0137f5 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -31,15 +31,16 @@ struct sock_xprt {
 	 * State of TCP reply receive
 	 */
 	struct {
-		__be32		fraghdr,
+		struct {
+			__be32	fraghdr,
 				xid,
 				calldir;
+		} __attribute__((packed));
 
 		u32		offset,
 				len;
 
-		unsigned long	copied,
-				flags;
+		unsigned long	copied;
 	} recv;
 
 	/*
@@ -76,21 +77,9 @@ struct sock_xprt {
 	void			(*old_error_report)(struct sock *);
 };
 
-/*
- * TCP receive state flags
- */
-#define TCP_RCV_LAST_FRAG	(1UL << 0)
-#define TCP_RCV_COPY_FRAGHDR	(1UL << 1)
-#define TCP_RCV_COPY_XID	(1UL << 2)
-#define TCP_RCV_COPY_DATA	(1UL << 3)
-#define TCP_RCV_READ_CALLDIR	(1UL << 4)
-#define TCP_RCV_COPY_CALLDIR	(1UL << 5)
-
 /*
  * TCP RPC flags
  */
-#define TCP_RPC_REPLY		(1UL << 6)
-
 #define XPRT_SOCK_CONNECTING	1U
 #define XPRT_SOCK_DATA_READY	(2)
 #define XPRT_SOCK_UPD_TIMEOUT	(3)
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 0aa347194e0f..19e08d12696c 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -497,16 +497,6 @@ TRACE_EVENT(xs_tcp_data_ready,
 			__get_str(port), __entry->err, __entry->total)
 );
 
-#define rpc_show_sock_xprt_flags(flags) \
-	__print_flags(flags, "|", \
-		{ TCP_RCV_LAST_FRAG, "TCP_RCV_LAST_FRAG" }, \
-		{ TCP_RCV_COPY_FRAGHDR, "TCP_RCV_COPY_FRAGHDR" }, \
-		{ TCP_RCV_COPY_XID, "TCP_RCV_COPY_XID" }, \
-		{ TCP_RCV_COPY_DATA, "TCP_RCV_COPY_DATA" }, \
-		{ TCP_RCV_READ_CALLDIR, "TCP_RCV_READ_CALLDIR" }, \
-		{ TCP_RCV_COPY_CALLDIR, "TCP_RCV_COPY_CALLDIR" }, \
-		{ TCP_RPC_REPLY, "TCP_RPC_REPLY" })
-
 TRACE_EVENT(xs_tcp_data_recv,
 	TP_PROTO(struct sock_xprt *xs),
 
@@ -516,7 +506,6 @@ TRACE_EVENT(xs_tcp_data_recv,
 		__string(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR])
 		__string(port, xs->xprt.address_strings[RPC_DISPLAY_PORT])
 		__field(u32, xid)
-		__field(unsigned long, flags)
 		__field(unsigned long, copied)
 		__field(unsigned int, reclen)
 		__field(unsigned long, offset)
@@ -526,15 +515,13 @@ TRACE_EVENT(xs_tcp_data_recv,
 		__assign_str(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR]);
 		__assign_str(port, xs->xprt.address_strings[RPC_DISPLAY_PORT]);
 		__entry->xid = be32_to_cpu(xs->recv.xid);
-		__entry->flags = xs->recv.flags;
 		__entry->copied = xs->recv.copied;
 		__entry->reclen = xs->recv.len;
 		__entry->offset = xs->recv.offset;
 	),
 
-	TP_printk("peer=[%s]:%s xid=0x%08x flags=%s copied=%lu reclen=%u offset=%lu",
+	TP_printk("peer=[%s]:%s xid=0x%08x copied=%lu reclen=%u offset=%lu",
 			__get_str(addr), __get_str(port), __entry->xid,
-			rpc_show_sock_xprt_flags(__entry->flags),
 			__entry->copied, __entry->reclen, __entry->offset)
 );
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f16406228ead..5269ad98bb08 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -47,13 +47,13 @@
 #include <net/checksum.h>
 #include <net/udp.h>
 #include <net/tcp.h>
+#include <linux/bvec.h>
+#include <linux/uio.h>
 
 #include <trace/events/sunrpc.h>
 
 #include "sunrpc.h"
 
-#define RPC_TCP_READ_CHUNK_SZ	(3*512*1024)
-
 static void xs_close(struct rpc_xprt *xprt);
 static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
 		struct socket *sock);
@@ -325,6 +325,320 @@ static void xs_free_peer_addresses(struct rpc_xprt *xprt)
 		}
 }
 
+static size_t
+xs_alloc_sparse_pages(struct xdr_buf *buf, size_t want, gfp_t gfp)
+{
+	size_t i,n;
+
+	if (!(buf->flags & XDRBUF_SPARSE_PAGES))
+		return want;
+	if (want > buf->page_len)
+		want = buf->page_len;
+	n = (buf->page_base + want + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < n; i++) {
+		if (buf->pages[i])
+			continue;
+		buf->bvec[i].bv_page = buf->pages[i] = alloc_page(gfp);
+		if (!buf->pages[i]) {
+			buf->page_len = (i * PAGE_SIZE) - buf->page_base;
+			return buf->page_len;
+		}
+	}
+	return want;
+}
+
+static ssize_t
+xs_sock_recvmsg(struct socket *sock, struct msghdr *msg, int flags, size_t seek)
+{
+	ssize_t ret;
+	if (seek != 0)
+		iov_iter_advance(&msg->msg_iter, seek);
+	ret = sock_recvmsg(sock, msg, flags);
+	return ret > 0 ? ret + seek : ret;
+}
+
+static ssize_t
+xs_read_kvec(struct socket *sock, struct msghdr *msg, int flags,
+		struct kvec *kvec, size_t count, size_t seek)
+{
+	iov_iter_kvec(&msg->msg_iter, READ | ITER_KVEC, kvec, 1, count);
+	return xs_sock_recvmsg(sock, msg, flags, seek);
+}
+
+static ssize_t
+xs_read_bvec(struct socket *sock, struct msghdr *msg, int flags,
+		struct bio_vec *bvec, unsigned long nr, size_t count,
+		size_t seek)
+{
+	iov_iter_bvec(&msg->msg_iter, READ | ITER_BVEC, bvec, nr, count);
+	return xs_sock_recvmsg(sock, msg, flags, seek);
+}
+
+static ssize_t
+xs_read_discard(struct socket *sock, struct msghdr *msg, int flags,
+		size_t count)
+{
+	struct kvec kvec = { 0 };
+	return xs_read_kvec(sock, msg, flags | MSG_TRUNC, &kvec, count, 0);
+}
+
+static ssize_t
+xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
+		struct xdr_buf *buf, size_t count, size_t seek, size_t *read)
+{
+	size_t want, seek_init = seek, offset = 0;
+	ssize_t ret;
+
+	if (seek < buf->head[0].iov_len) {
+		want = min_t(size_t, count, buf->head[0].iov_len);
+		ret = xs_read_kvec(sock, msg, flags, &buf->head[0], want, seek);
+		if (ret <= 0)
+			goto sock_err;
+		offset += ret;
+		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
+			goto out;
+		if (ret != want)
+			goto eagain;
+		seek = 0;
+	} else {
+		seek -= buf->head[0].iov_len;
+		offset += buf->head[0].iov_len;
+	}
+	if (buf->page_len && seek < buf->page_len) {
+		want = min_t(size_t, count - offset, buf->page_len);
+		want = xs_alloc_sparse_pages(buf, want, GFP_NOWAIT);
+		ret = xs_read_bvec(sock, msg, flags, buf->bvec,
+				xdr_buf_pagecount(buf),
+				want + buf->page_base,
+				seek + buf->page_base);
+		if (ret <= 0)
+			goto sock_err;
+		offset += ret;
+		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
+			goto out;
+		if (ret != want)
+			goto eagain;
+		seek = 0;
+	} else {
+		seek -= buf->page_len;
+		offset += buf->page_len;
+	}
+	if (buf->tail[0].iov_len && seek < buf->tail[0].iov_len) {
+		want = min_t(size_t, count - offset, buf->tail[0].iov_len);
+		ret = xs_read_kvec(sock, msg, flags, &buf->tail[0], want, seek);
+		if (ret <= 0)
+			goto sock_err;
+		offset += ret;
+		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
+			goto out;
+		if (ret != want)
+			goto eagain;
+	} else
+		offset += buf->tail[0].iov_len;
+	ret = -EMSGSIZE;
+	msg->msg_flags |= MSG_TRUNC;
+out:
+	*read = offset - seek_init;
+	return ret;
+eagain:
+	ret = -EAGAIN;
+	goto out;
+sock_err:
+	offset += seek;
+	goto out;
+}
+
+static void
+xs_read_header(struct sock_xprt *transport, struct xdr_buf *buf)
+{
+	if (!transport->recv.copied) {
+		if (buf->head[0].iov_len >= transport->recv.offset)
+			memcpy(buf->head[0].iov_base,
+					&transport->recv.xid,
+					transport->recv.offset);
+		transport->recv.copied = transport->recv.offset;
+	}
+}
+
+static bool
+xs_read_stream_request_done(struct sock_xprt *transport)
+{
+	return transport->recv.fraghdr & cpu_to_be32(RPC_LAST_STREAM_FRAGMENT);
+}
+
+static ssize_t
+xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
+		int flags, struct rpc_rqst *req)
+{
+	struct xdr_buf *buf = &req->rq_private_buf;
+	size_t want, read;
+	ssize_t ret;
+
+	xs_read_header(transport, buf);
+
+	want = transport->recv.len - transport->recv.offset;
+	ret = xs_read_xdr_buf(transport->sock, msg, flags, buf,
+			transport->recv.copied + want, transport->recv.copied,
+			&read);
+	transport->recv.offset += read;
+	transport->recv.copied += read;
+	if (transport->recv.offset == transport->recv.len) {
+		if (xs_read_stream_request_done(transport))
+			msg->msg_flags |= MSG_EOR;
+		return transport->recv.copied;
+	}
+
+	switch (ret) {
+	case -EMSGSIZE:
+		return transport->recv.copied;
+	case 0:
+		return -ESHUTDOWN;
+	default:
+		if (ret < 0)
+			return ret;
+	}
+	return -EAGAIN;
+}
+
+static size_t
+xs_read_stream_headersize(bool isfrag)
+{
+	if (isfrag)
+		return sizeof(__be32);
+	return 3 * sizeof(__be32);
+}
+
+static ssize_t
+xs_read_stream_header(struct sock_xprt *transport, struct msghdr *msg,
+		int flags, size_t want, size_t seek)
+{
+	struct kvec kvec = {
+		.iov_base = &transport->recv.fraghdr,
+		.iov_len = want,
+	};
+	return xs_read_kvec(transport->sock, msg, flags, &kvec, want, seek);
+}
+
+#if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static ssize_t
+xs_read_stream_call(struct sock_xprt *transport, struct msghdr *msg, int flags)
+{
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct rpc_rqst *req;
+	ssize_t ret;
+
+	/* Look up and lock the request corresponding to the given XID */
+	req = xprt_lookup_bc_request(xprt, transport->recv.xid);
+	if (!req) {
+		printk(KERN_WARNING "Callback slot table overflowed\n");
+		return -ESHUTDOWN;
+	}
+
+	ret = xs_read_stream_request(transport, msg, flags, req);
+	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
+		xprt_complete_bc_request(req, ret);
+
+	return ret;
+}
+#else /* CONFIG_SUNRPC_BACKCHANNEL */
+static ssize_t
+xs_read_stream_call(struct sock_xprt *transport, struct msghdr *msg, int flags)
+{
+	return -ESHUTDOWN;
+}
+#endif /* CONFIG_SUNRPC_BACKCHANNEL */
+
+static ssize_t
+xs_read_stream_reply(struct sock_xprt *transport, struct msghdr *msg, int flags)
+{
+	struct rpc_xprt *xprt = &transport->xprt;
+	struct rpc_rqst *req;
+	ssize_t ret = 0;
+
+	/* Look up and lock the request corresponding to the given XID */
+	spin_lock(&xprt->queue_lock);
+	req = xprt_lookup_rqst(xprt, transport->recv.xid);
+	if (!req) {
+		msg->msg_flags |= MSG_TRUNC;
+		goto out;
+	}
+	xprt_pin_rqst(req);
+	spin_unlock(&xprt->queue_lock);
+
+	ret = xs_read_stream_request(transport, msg, flags, req);
+
+	spin_lock(&xprt->queue_lock);
+	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
+		xprt_complete_rqst(req->rq_task, ret);
+	xprt_unpin_rqst(req);
+out:
+	spin_unlock(&xprt->queue_lock);
+	return ret;
+}
+
+static ssize_t
+xs_read_stream(struct sock_xprt *transport, int flags)
+{
+	struct msghdr msg = { 0 };
+	size_t want, read = 0;
+	ssize_t ret = 0;
+
+	if (transport->recv.len == 0) {
+		want = xs_read_stream_headersize(transport->recv.copied != 0);
+		ret = xs_read_stream_header(transport, &msg, flags, want,
+				transport->recv.offset);
+		if (ret <= 0)
+			goto out_err;
+		transport->recv.offset = ret;
+		if (ret != want) {
+			ret = -EAGAIN;
+			goto out_err;
+		}
+		transport->recv.len = be32_to_cpu(transport->recv.fraghdr) &
+			RPC_FRAGMENT_SIZE_MASK;
+		transport->recv.offset -= sizeof(transport->recv.fraghdr);
+		read = ret;
+	}
+
+	switch (be32_to_cpu(transport->recv.calldir)) {
+	case RPC_CALL:
+		ret = xs_read_stream_call(transport, &msg, flags);
+		break;
+	case RPC_REPLY:
+		ret = xs_read_stream_reply(transport, &msg, flags);
+	}
+	if (msg.msg_flags & MSG_TRUNC) {
+		transport->recv.calldir = cpu_to_be32(-1);
+		transport->recv.copied = -1;
+	}
+	if (ret < 0)
+		goto out_err;
+	read += ret;
+	if (transport->recv.offset < transport->recv.len) {
+		ret = xs_read_discard(transport->sock, &msg, flags,
+				transport->recv.len - transport->recv.offset);
+		if (ret <= 0)
+			goto out_err;
+		transport->recv.offset += ret;
+		read += ret;
+	}
+	if (xs_read_stream_request_done(transport)) {
+		trace_xs_tcp_data_recv(transport);
+		transport->recv.copied = 0;
+	}
+	transport->recv.offset = 0;
+	transport->recv.len = 0;
+	return read;
+out_err:
+	switch (ret) {
+	case 0:
+	case -ESHUTDOWN:
+		xprt_force_disconnect(&transport->xprt);
+		return -ESHUTDOWN;
+	}
+	return ret;
+}
+
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
 static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
@@ -484,6 +798,12 @@ static int xs_nospace(struct rpc_rqst *req)
 	return ret;
 }
 
+static void
+xs_stream_prepare_request(struct rpc_rqst *req)
+{
+	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf, GFP_NOIO);
+}
+
 /*
  * Determine if the previous message in the stream was aborted before it
  * could complete transmission.
@@ -1157,263 +1477,7 @@ static void xs_tcp_force_close(struct rpc_xprt *xprt)
 	xprt_force_disconnect(xprt);
 }
 
-static inline void xs_tcp_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
-{
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
-	size_t len, used;
-	char *p;
-
-	p = ((char *) &transport->recv.fraghdr) + transport->recv.offset;
-	len = sizeof(transport->recv.fraghdr) - transport->recv.offset;
-	used = xdr_skb_read_bits(desc, p, len);
-	transport->recv.offset += used;
-	if (used != len)
-		return;
-
-	transport->recv.len = ntohl(transport->recv.fraghdr);
-	if (transport->recv.len & RPC_LAST_STREAM_FRAGMENT)
-		transport->recv.flags |= TCP_RCV_LAST_FRAG;
-	else
-		transport->recv.flags &= ~TCP_RCV_LAST_FRAG;
-	transport->recv.len &= RPC_FRAGMENT_SIZE_MASK;
-
-	transport->recv.flags &= ~TCP_RCV_COPY_FRAGHDR;
-	transport->recv.offset = 0;
-
-	/* Sanity check of the record length */
-	if (unlikely(transport->recv.len < 8)) {
-		dprintk("RPC:       invalid TCP record fragment length\n");
-		xs_tcp_force_close(xprt);
-		return;
-	}
-	dprintk("RPC:       reading TCP record fragment of length %d\n",
-			transport->recv.len);
-}
-
-static void xs_tcp_check_fraghdr(struct sock_xprt *transport)
-{
-	if (transport->recv.offset == transport->recv.len) {
-		transport->recv.flags |= TCP_RCV_COPY_FRAGHDR;
-		transport->recv.offset = 0;
-		if (transport->recv.flags & TCP_RCV_LAST_FRAG) {
-			transport->recv.flags &= ~TCP_RCV_COPY_DATA;
-			transport->recv.flags |= TCP_RCV_COPY_XID;
-			transport->recv.copied = 0;
-		}
-	}
-}
-
-static inline void xs_tcp_read_xid(struct sock_xprt *transport, struct xdr_skb_reader *desc)
-{
-	size_t len, used;
-	char *p;
-
-	len = sizeof(transport->recv.xid) - transport->recv.offset;
-	dprintk("RPC:       reading XID (%zu bytes)\n", len);
-	p = ((char *) &transport->recv.xid) + transport->recv.offset;
-	used = xdr_skb_read_bits(desc, p, len);
-	transport->recv.offset += used;
-	if (used != len)
-		return;
-	transport->recv.flags &= ~TCP_RCV_COPY_XID;
-	transport->recv.flags |= TCP_RCV_READ_CALLDIR;
-	transport->recv.copied = 4;
-	dprintk("RPC:       reading %s XID %08x\n",
-			(transport->recv.flags & TCP_RPC_REPLY) ? "reply for"
-							      : "request with",
-			ntohl(transport->recv.xid));
-	xs_tcp_check_fraghdr(transport);
-}
-
-static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
-				       struct xdr_skb_reader *desc)
-{
-	size_t len, used;
-	u32 offset;
-	char *p;
-
-	/*
-	 * We want transport->recv.offset to be 8 at the end of this routine
-	 * (4 bytes for the xid and 4 bytes for the call/reply flag).
-	 * When this function is called for the first time,
-	 * transport->recv.offset is 4 (after having already read the xid).
-	 */
-	offset = transport->recv.offset - sizeof(transport->recv.xid);
-	len = sizeof(transport->recv.calldir) - offset;
-	dprintk("RPC:       reading CALL/REPLY flag (%zu bytes)\n", len);
-	p = ((char *) &transport->recv.calldir) + offset;
-	used = xdr_skb_read_bits(desc, p, len);
-	transport->recv.offset += used;
-	if (used != len)
-		return;
-	transport->recv.flags &= ~TCP_RCV_READ_CALLDIR;
-	/*
-	 * We don't yet have the XDR buffer, so we will write the calldir
-	 * out after we get the buffer from the 'struct rpc_rqst'
-	 */
-	switch (ntohl(transport->recv.calldir)) {
-	case RPC_REPLY:
-		transport->recv.flags |= TCP_RCV_COPY_CALLDIR;
-		transport->recv.flags |= TCP_RCV_COPY_DATA;
-		transport->recv.flags |= TCP_RPC_REPLY;
-		break;
-	case RPC_CALL:
-		transport->recv.flags |= TCP_RCV_COPY_CALLDIR;
-		transport->recv.flags |= TCP_RCV_COPY_DATA;
-		transport->recv.flags &= ~TCP_RPC_REPLY;
-		break;
-	default:
-		dprintk("RPC:       invalid request message type\n");
-		xs_tcp_force_close(&transport->xprt);
-	}
-	xs_tcp_check_fraghdr(transport);
-}
-
-static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
-				     struct xdr_skb_reader *desc,
-				     struct rpc_rqst *req)
-{
-	struct sock_xprt *transport =
-				container_of(xprt, struct sock_xprt, xprt);
-	struct xdr_buf *rcvbuf;
-	size_t len;
-	ssize_t r;
-
-	rcvbuf = &req->rq_private_buf;
-
-	if (transport->recv.flags & TCP_RCV_COPY_CALLDIR) {
-		/*
-		 * Save the RPC direction in the XDR buffer
-		 */
-		memcpy(rcvbuf->head[0].iov_base + transport->recv.copied,
-			&transport->recv.calldir,
-			sizeof(transport->recv.calldir));
-		transport->recv.copied += sizeof(transport->recv.calldir);
-		transport->recv.flags &= ~TCP_RCV_COPY_CALLDIR;
-	}
-
-	len = desc->count;
-	if (len > transport->recv.len - transport->recv.offset)
-		desc->count = transport->recv.len - transport->recv.offset;
-	r = xdr_partial_copy_from_skb(rcvbuf, transport->recv.copied,
-					  desc, xdr_skb_read_bits);
-
-	if (desc->count) {
-		/* Error when copying to the receive buffer,
-		 * usually because we weren't able to allocate
-		 * additional buffer pages. All we can do now
-		 * is turn off TCP_RCV_COPY_DATA, so the request
-		 * will not receive any additional updates,
-		 * and time out.
-		 * Any remaining data from this record will
-		 * be discarded.
-		 */
-		transport->recv.flags &= ~TCP_RCV_COPY_DATA;
-		dprintk("RPC:       XID %08x truncated request\n",
-				ntohl(transport->recv.xid));
-		dprintk("RPC:       xprt = %p, recv.copied = %lu, "
-				"recv.offset = %u, recv.len = %u\n",
-				xprt, transport->recv.copied,
-				transport->recv.offset, transport->recv.len);
-		return;
-	}
-
-	transport->recv.copied += r;
-	transport->recv.offset += r;
-	desc->count = len - r;
-
-	dprintk("RPC:       XID %08x read %zd bytes\n",
-			ntohl(transport->recv.xid), r);
-	dprintk("RPC:       xprt = %p, recv.copied = %lu, recv.offset = %u, "
-			"recv.len = %u\n", xprt, transport->recv.copied,
-			transport->recv.offset, transport->recv.len);
-
-	if (transport->recv.copied == req->rq_private_buf.buflen)
-		transport->recv.flags &= ~TCP_RCV_COPY_DATA;
-	else if (transport->recv.offset == transport->recv.len) {
-		if (transport->recv.flags & TCP_RCV_LAST_FRAG)
-			transport->recv.flags &= ~TCP_RCV_COPY_DATA;
-	}
-}
-
-/*
- * Finds the request corresponding to the RPC xid and invokes the common
- * tcp read code to read the data.
- */
-static inline int xs_tcp_read_reply(struct rpc_xprt *xprt,
-				    struct xdr_skb_reader *desc)
-{
-	struct sock_xprt *transport =
-				container_of(xprt, struct sock_xprt, xprt);
-	struct rpc_rqst *req;
-
-	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->recv.xid));
-
-	/* Find and lock the request corresponding to this xid */
-	spin_lock(&xprt->queue_lock);
-	req = xprt_lookup_rqst(xprt, transport->recv.xid);
-	if (!req) {
-		dprintk("RPC:       XID %08x request not found!\n",
-				ntohl(transport->recv.xid));
-		spin_unlock(&xprt->queue_lock);
-		return -1;
-	}
-	xprt_pin_rqst(req);
-	spin_unlock(&xprt->queue_lock);
-
-	xs_tcp_read_common(xprt, desc, req);
-
-	spin_lock(&xprt->queue_lock);
-	if (!(transport->recv.flags & TCP_RCV_COPY_DATA))
-		xprt_complete_rqst(req->rq_task, transport->recv.copied);
-	xprt_unpin_rqst(req);
-	spin_unlock(&xprt->queue_lock);
-	return 0;
-}
-
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-/*
- * Obtains an rpc_rqst previously allocated and invokes the common
- * tcp read code to read the data.  The result is placed in the callback
- * queue.
- * If we're unable to obtain the rpc_rqst we schedule the closing of the
- * connection and return -1.
- */
-static int xs_tcp_read_callback(struct rpc_xprt *xprt,
-				       struct xdr_skb_reader *desc)
-{
-	struct sock_xprt *transport =
-				container_of(xprt, struct sock_xprt, xprt);
-	struct rpc_rqst *req;
-
-	/* Look up the request corresponding to the given XID */
-	req = xprt_lookup_bc_request(xprt, transport->recv.xid);
-	if (req == NULL) {
-		printk(KERN_WARNING "Callback slot table overflowed\n");
-		xprt_force_disconnect(xprt);
-		return -1;
-	}
-
-	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
-	xs_tcp_read_common(xprt, desc, req);
-
-	if (!(transport->recv.flags & TCP_RCV_COPY_DATA))
-		xprt_complete_bc_request(req, transport->recv.copied);
-
-	return 0;
-}
-
-static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
-					struct xdr_skb_reader *desc)
-{
-	struct sock_xprt *transport =
-				container_of(xprt, struct sock_xprt, xprt);
-
-	return (transport->recv.flags & TCP_RPC_REPLY) ?
-		xs_tcp_read_reply(xprt, desc) :
-		xs_tcp_read_callback(xprt, desc);
-}
-
 static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
 {
 	int ret;
@@ -1429,106 +1493,14 @@ static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
 {
 	return PAGE_SIZE;
 }
-#else
-static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
-					struct xdr_skb_reader *desc)
-{
-	return xs_tcp_read_reply(xprt, desc);
-}
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-/*
- * Read data off the transport.  This can be either an RPC_CALL or an
- * RPC_REPLY.  Relay the processing to helper functions.
- */
-static void xs_tcp_read_data(struct rpc_xprt *xprt,
-				    struct xdr_skb_reader *desc)
-{
-	struct sock_xprt *transport =
-				container_of(xprt, struct sock_xprt, xprt);
-
-	if (_xs_tcp_read_data(xprt, desc) == 0)
-		xs_tcp_check_fraghdr(transport);
-	else {
-		/*
-		 * The transport_lock protects the request handling.
-		 * There's no need to hold it to update the recv.flags.
-		 */
-		transport->recv.flags &= ~TCP_RCV_COPY_DATA;
-	}
-}
-
-static inline void xs_tcp_read_discard(struct sock_xprt *transport, struct xdr_skb_reader *desc)
-{
-	size_t len;
-
-	len = transport->recv.len - transport->recv.offset;
-	if (len > desc->count)
-		len = desc->count;
-	desc->count -= len;
-	desc->offset += len;
-	transport->recv.offset += len;
-	dprintk("RPC:       discarded %zu bytes\n", len);
-	xs_tcp_check_fraghdr(transport);
-}
-
-static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, unsigned int offset, size_t len)
-{
-	struct rpc_xprt *xprt = rd_desc->arg.data;
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
-	struct xdr_skb_reader desc = {
-		.skb	= skb,
-		.offset	= offset,
-		.count	= len,
-	};
-	size_t ret;
-
-	dprintk("RPC:       xs_tcp_data_recv started\n");
-	do {
-		trace_xs_tcp_data_recv(transport);
-		/* Read in a new fragment marker if necessary */
-		/* Can we ever really expect to get completely empty fragments? */
-		if (transport->recv.flags & TCP_RCV_COPY_FRAGHDR) {
-			xs_tcp_read_fraghdr(xprt, &desc);
-			continue;
-		}
-		/* Read in the xid if necessary */
-		if (transport->recv.flags & TCP_RCV_COPY_XID) {
-			xs_tcp_read_xid(transport, &desc);
-			continue;
-		}
-		/* Read in the call/reply flag */
-		if (transport->recv.flags & TCP_RCV_READ_CALLDIR) {
-			xs_tcp_read_calldir(transport, &desc);
-			continue;
-		}
-		/* Read in the request data */
-		if (transport->recv.flags & TCP_RCV_COPY_DATA) {
-			xs_tcp_read_data(xprt, &desc);
-			continue;
-		}
-		/* Skip over any trailing bytes on short reads */
-		xs_tcp_read_discard(transport, &desc);
-	} while (desc.count);
-	ret = len - desc.count;
-	if (ret < rd_desc->count)
-		rd_desc->count -= ret;
-	else
-		rd_desc->count = 0;
-	trace_xs_tcp_data_recv(transport);
-	dprintk("RPC:       xs_tcp_data_recv done\n");
-	return ret;
-}
-
 static void xs_tcp_data_receive(struct sock_xprt *transport)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct sock *sk;
-	read_descriptor_t rd_desc = {
-		.arg.data = xprt,
-	};
-	unsigned long total = 0;
-	int read = 0;
+	size_t read = 0;
+	ssize_t ret = 0;
 
 restart:
 	mutex_lock(&transport->recv_mutex);
@@ -1536,18 +1508,12 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 	if (sk == NULL)
 		goto out;
 
-	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	for (;;) {
-		rd_desc.count = RPC_TCP_READ_CHUNK_SZ;
-		lock_sock(sk);
-		read = tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
-		if (rd_desc.count != 0 || read < 0) {
-			clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
-			release_sock(sk);
+		clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
+		ret = xs_read_stream(transport, MSG_DONTWAIT | MSG_NOSIGNAL);
+		if (ret < 0)
 			break;
-		}
-		release_sock(sk);
-		total += read;
+		read += ret;
 		if (need_resched()) {
 			mutex_unlock(&transport->recv_mutex);
 			cond_resched();
@@ -1558,7 +1524,7 @@ static void xs_tcp_data_receive(struct sock_xprt *transport)
 		queue_work(xprtiod_workqueue, &transport->recv_worker);
 out:
 	mutex_unlock(&transport->recv_mutex);
-	trace_xs_tcp_data_ready(xprt, read, total);
+	trace_xs_tcp_data_ready(xprt, ret, read);
 }
 
 static void xs_tcp_data_receive_workfn(struct work_struct *work)
@@ -2380,7 +2346,6 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	transport->recv.offset = 0;
 	transport->recv.len = 0;
 	transport->recv.copied = 0;
-	transport->recv.flags = TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 	transport->xmit.offset = 0;
 
 	/* Tell the socket layer to start connecting... */
@@ -2802,6 +2767,7 @@ static const struct rpc_xprt_ops xs_tcp_ops = {
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
+	.prepare_request	= xs_stream_prepare_request,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_tcp_shutdown,
-- 
2.17.1
