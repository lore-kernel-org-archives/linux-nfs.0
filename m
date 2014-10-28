Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:57036 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbaJ1SYd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 14:24:33 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1060889qcy.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2014 11:24:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] sunrpc: add tracepoints in xs_tcp_data_recv
Date: Tue, 28 Oct 2014 14:24:14 -0400
Message-Id: <1414520654-1606-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
References: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints inside the main loop on xs_tcp_data_recv that allow
us to keep an eye on what's happening during each phase of it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/xprtsock.h | 59 +++++++++++++++++++++++++++++++++++++++
 include/trace/events/sunrpc.h   | 44 ++++++++++++++++++++++++++++-
 net/sunrpc/xprtsock.c           | 61 ++---------------------------------------
 3 files changed, 104 insertions(+), 60 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 1ad36cc25b2e..7591788e9fbf 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -17,6 +17,65 @@ void		cleanup_socket_xprt(void);
 #define RPC_DEF_MIN_RESVPORT	(665U)
 #define RPC_DEF_MAX_RESVPORT	(1023U)
 
+struct sock_xprt {
+	struct rpc_xprt		xprt;
+
+	/*
+	 * Network layer
+	 */
+	struct socket *		sock;
+	struct sock *		inet;
+
+	/*
+	 * State of TCP reply receive
+	 */
+	__be32			tcp_fraghdr,
+				tcp_xid,
+				tcp_calldir;
+
+	u32			tcp_offset,
+				tcp_reclen;
+
+	unsigned long		tcp_copied,
+				tcp_flags;
+
+	/*
+	 * Connection of transports
+	 */
+	struct delayed_work	connect_worker;
+	struct sockaddr_storage	srcaddr;
+	unsigned short		srcport;
+
+	/*
+	 * UDP socket buffer size parameters
+	 */
+	size_t			rcvsize,
+				sndsize;
+
+	/*
+	 * Saved socket callback addresses
+	 */
+	void			(*old_data_ready)(struct sock *);
+	void			(*old_state_change)(struct sock *);
+	void			(*old_write_space)(struct sock *);
+	void			(*old_error_report)(struct sock *);
+};
+
+/*
+ * TCP receive state flags
+ */
+#define TCP_RCV_LAST_FRAG	(1UL << 0)
+#define TCP_RCV_COPY_FRAGHDR	(1UL << 1)
+#define TCP_RCV_COPY_XID	(1UL << 2)
+#define TCP_RCV_COPY_DATA	(1UL << 3)
+#define TCP_RCV_READ_CALLDIR	(1UL << 4)
+#define TCP_RCV_COPY_CALLDIR	(1UL << 5)
+
+/*
+ * TCP RPC flags
+ */
+#define TCP_RPC_REPLY		(1UL << 6)
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SUNRPC_XPRTSOCK_H */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 5edb16bcd836..171ca4ff6d99 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -7,6 +7,7 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <net/tcp_states.h>
 #include <linux/net.h>
 #include <linux/tracepoint.h>
@@ -326,7 +327,7 @@ DECLARE_EVENT_CLASS(rpc_xprt_event,
 		__assign_str(port, xprt->address_strings[RPC_DISPLAY_PORT]);
 	),
 
-	TP_printk("peer=%s/%s xid=0x%x status=%d", __get_str(addr),
+	TP_printk("peer=[%s]:%s xid=0x%x status=%d", __get_str(addr),
 			__get_str(port), be32_to_cpu(__entry->xid),
 			__entry->status)
 );
@@ -370,6 +371,47 @@ TRACE_EVENT(xs_tcp_data_ready,
 			__get_str(port), __entry->err, __entry->total)
 );
 
+#define rpc_show_sock_xprt_flags(flags) \
+	__print_flags(flags, "|", \
+		{ TCP_RCV_LAST_FRAG, "TCP_RCV_LAST_FRAG" }, \
+		{ TCP_RCV_COPY_FRAGHDR, "TCP_RCV_COPY_FRAGHDR" }, \
+		{ TCP_RCV_COPY_XID, "TCP_RCV_COPY_XID" }, \
+		{ TCP_RCV_COPY_DATA, "TCP_RCV_COPY_DATA" }, \
+		{ TCP_RCV_READ_CALLDIR, "TCP_RCV_READ_CALLDIR" }, \
+		{ TCP_RCV_COPY_CALLDIR, "TCP_RCV_COPY_CALLDIR" }, \
+		{ TCP_RPC_REPLY, "TCP_RPC_REPLY" })
+
+TRACE_EVENT(xs_tcp_data_recv,
+	TP_PROTO(struct sock_xprt *xs),
+
+	TP_ARGS(xs),
+
+	TP_STRUCT__entry(
+		__string(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR])
+		__string(port, xs->xprt.address_strings[RPC_DISPLAY_PORT])
+		__field(__be32, xid)
+		__field(unsigned long, flags)
+		__field(unsigned long, copied)
+		__field(unsigned int, reclen)
+		__field(unsigned long, offset)
+	),
+
+	TP_fast_assign(
+		__assign_str(addr, xs->xprt.address_strings[RPC_DISPLAY_ADDR]);
+		__assign_str(port, xs->xprt.address_strings[RPC_DISPLAY_PORT]);
+		__entry->xid = xs->tcp_xid;
+		__entry->flags = xs->tcp_flags;
+		__entry->copied = xs->tcp_copied;
+		__entry->reclen = xs->tcp_reclen;
+		__entry->offset = xs->tcp_offset;
+	),
+
+	TP_printk("peer=[%s]:%s xid=0x%x flags=%s copied=%lu reclen=%u offset=%lu",
+			__get_str(addr), __get_str(port), be32_to_cpu(__entry->xid),
+			rpc_show_sock_xprt_flags(__entry->flags),
+			__entry->copied, __entry->reclen, __entry->offset)
+);
+
 TRACE_EVENT(svc_recv,
 	TP_PROTO(struct svc_rqst *rqst, int status),
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b63e26272dc2..31c015196a29 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -216,65 +216,6 @@ static inline void xs_pktdump(char *msg, u32 *packet, unsigned int count)
 }
 #endif
 
-struct sock_xprt {
-	struct rpc_xprt		xprt;
-
-	/*
-	 * Network layer
-	 */
-	struct socket *		sock;
-	struct sock *		inet;
-
-	/*
-	 * State of TCP reply receive
-	 */
-	__be32			tcp_fraghdr,
-				tcp_xid,
-				tcp_calldir;
-
-	u32			tcp_offset,
-				tcp_reclen;
-
-	unsigned long		tcp_copied,
-				tcp_flags;
-
-	/*
-	 * Connection of transports
-	 */
-	struct delayed_work	connect_worker;
-	struct sockaddr_storage	srcaddr;
-	unsigned short		srcport;
-
-	/*
-	 * UDP socket buffer size parameters
-	 */
-	size_t			rcvsize,
-				sndsize;
-
-	/*
-	 * Saved socket callback addresses
-	 */
-	void			(*old_data_ready)(struct sock *);
-	void			(*old_state_change)(struct sock *);
-	void			(*old_write_space)(struct sock *);
-	void			(*old_error_report)(struct sock *);
-};
-
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
-/*
- * TCP RPC flags
- */
-#define TCP_RPC_REPLY		(1UL << 6)
-
 static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
 {
 	return (struct rpc_xprt *) sk->sk_user_data;
@@ -1415,6 +1356,7 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 
 	dprintk("RPC:       xs_tcp_data_recv started\n");
 	do {
+		trace_xs_tcp_data_recv(transport);
 		/* Read in a new fragment marker if necessary */
 		/* Can we ever really expect to get completely empty fragments? */
 		if (transport->tcp_flags & TCP_RCV_COPY_FRAGHDR) {
@@ -1439,6 +1381,7 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 		/* Skip over any trailing bytes on short reads */
 		xs_tcp_read_discard(transport, &desc);
 	} while (desc.count);
+	trace_xs_tcp_data_recv(transport);
 	dprintk("RPC:       xs_tcp_data_recv done\n");
 	return len - desc.count;
 }
-- 
1.9.3

