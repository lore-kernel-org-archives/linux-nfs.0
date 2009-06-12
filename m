From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 09/14] SQUASHME: nfs41: sunrpc: Add RPC direction back into the XDR buffer
Date: Thu, 11 Jun 2009 22:54:15 -0700
Message-ID: <1244786060-2200-10-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276AbZFLF6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:11 -0400
In-Reply-To: <1244786060-2200-9-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: Skip past the RPC call direction]

An earlier nfs41/sunrpc patch incorrectly assumed that all transports will
read the RPC direction and route callbacks or replies to the processing
routines.  This is only currently implemented for TCP, so rpc_verify_header()
needs to continue verifying that it is processing an RPC_REPLY.

Reading and storing the RPC direction is a three step process.

1. xs_tcp_read_calldir() reads the RPC direction, but it will not store it
in the XDR buffer since the 'struct rpc_rqst' is not yet available.

2. The 'struct rpc_rqst' is obtained during the TCP_RCV_COPY_DATA state.
This state need not necessarily be preceeded by the TCP_RCV_READ_CALLDIR.
For example, we may be reading a continuation packet to a large reply.
Therefore, we can't simply obtain the 'struct rpc_rqst' during the
TCP_RCV_READ_CALLDIR state and assume it's available during TCP_RCV_COPY_DATA.

This patch adds a new TCP_RCV_READ_CALLDIR flag to indicate the need to
read the RPC direction.  It then uses TCP_RCV_COPY_CALLDIR to indicate the
RPC direction needs to be saved after the 'struct rpc_rqst' has been allocated.

3. The 'struct rpc_rqst' is obtained by the xs_tcp_read_data() helper
functions.  xs_tcp_read_common() then saves the RPC direction in the XDR
buffer if TCP_RCV_COPY_CALLDIR is set.  This will happen when we're reading
the data immediately after the direction was read.  xs_tcp_read_common()
then clears this flag.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/xprtsock.c |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8ec2600..fe57ebd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -275,12 +275,13 @@ struct sock_xprt {
 #define TCP_RCV_COPY_FRAGHDR	(1UL << 1)
 #define TCP_RCV_COPY_XID	(1UL << 2)
 #define TCP_RCV_COPY_DATA	(1UL << 3)
-#define TCP_RCV_COPY_CALLDIR	(1UL << 4)
+#define TCP_RCV_READ_CALLDIR	(1UL << 4)
+#define TCP_RCV_COPY_CALLDIR	(1UL << 5)
 
 /*
  * TCP RPC flags
  */
-#define TCP_RPC_REPLY		(1UL << 5)
+#define TCP_RPC_REPLY		(1UL << 6)
 
 static inline struct sockaddr *xs_addr(struct rpc_xprt *xprt)
 {
@@ -1002,7 +1003,7 @@ static inline void xs_tcp_read_xid(struct sock_xprt *transport, struct xdr_skb_r
 	if (used != len)
 		return;
 	transport->tcp_flags &= ~TCP_RCV_COPY_XID;
-	transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
+	transport->tcp_flags |= TCP_RCV_READ_CALLDIR;
 	transport->tcp_copied = 4;
 	dprintk("RPC:       reading %s XID %08x\n",
 			(transport->tcp_flags & TCP_RPC_REPLY) ? "reply for"
@@ -1031,9 +1032,13 @@ static inline void xs_tcp_read_calldir(struct sock_xprt *transport,
 	transport->tcp_offset += used;
 	if (used != len)
 		return;
-	transport->tcp_flags &= ~TCP_RCV_COPY_CALLDIR;
+	transport->tcp_flags &= ~TCP_RCV_READ_CALLDIR;
+	transport->tcp_flags |= TCP_RCV_COPY_CALLDIR;
 	transport->tcp_flags |= TCP_RCV_COPY_DATA;
-	transport->tcp_copied += 4;
+	/*
+	 * We don't yet have the XDR buffer, so we will write the calldir
+	 * out after we get the buffer from the 'struct rpc_rqst'
+	 */
 	if (ntohl(calldir) == RPC_REPLY)
 		transport->tcp_flags |= TCP_RPC_REPLY;
 	else
@@ -1055,6 +1060,20 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 	ssize_t r;
 
 	rcvbuf = &req->rq_private_buf;
+
+	if (transport->tcp_flags & TCP_RCV_COPY_CALLDIR) {
+		/*
+		 * Save the RPC direction in the XDR buffer
+		 */
+		__be32	calldir = transport->tcp_flags & TCP_RPC_REPLY ?
+					htonl(RPC_REPLY) : 0;
+
+		memcpy(rcvbuf->head[0].iov_base + transport->tcp_copied,
+			&calldir, sizeof(calldir));
+		transport->tcp_copied += sizeof(calldir);
+		transport->tcp_flags &= ~TCP_RCV_COPY_CALLDIR;
+	}
+
 	len = desc->count;
 	if (len > transport->tcp_reclen - transport->tcp_offset) {
 		struct xdr_skb_reader my_desc;
@@ -1258,7 +1277,7 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 			continue;
 		}
 		/* Read in the call/reply flag */
-		if (transport->tcp_flags & TCP_RCV_COPY_CALLDIR) {
+		if (transport->tcp_flags & TCP_RCV_READ_CALLDIR) {
 			xs_tcp_read_calldir(transport, &desc);
 			continue;
 		}
-- 
1.5.4.3

