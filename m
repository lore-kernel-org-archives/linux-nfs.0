Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752368AbdF3NYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
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
Subject: [PATCH v3 04/14] SUNRPC: extract xs_stream_reset_state()
Date: Fri, 30 Jun 2017 14:23:42 +0100
Message-Id: <20170630132352.32133-5-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extract a function to reset the record fragment parser.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/xprtsock.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 184e263..fd0c8b1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1552,6 +1552,28 @@ static void xs_stream_data_receive_workfn(struct work_struct *work)
 }
 
 /**
+ * xs_stream_reset_state - reset SOCK_STREAM record parser
+ * @transport: socket transport
+ * @read_sock: tcp_read_sock()-like function
+ *
+ */
+static void xs_stream_reset_state(struct rpc_xprt *xprt,
+				  int (*read_sock)(struct sock *,
+						   read_descriptor_t *,
+						   sk_read_actor_t))
+{
+	struct sock_xprt *transport = container_of(xprt,
+			struct sock_xprt, xprt);
+
+	transport->stream_offset = 0;
+	transport->stream_reclen = 0;
+	transport->stream_copied = 0;
+	transport->stream_flags =
+		STREAM_RCV_COPY_FRAGHDR | STREAM_RCV_COPY_XID;
+	transport->stream_read_sock = read_sock;
+}
+
+/**
  * xs_tcp_state_change - callback to handle TCP socket state changes
  * @sk: socket whose state has changed
  *
@@ -1577,14 +1599,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_ESTABLISHED:
 		spin_lock(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
-
-			/* Reset stream record info */
-			transport->stream_offset = 0;
-			transport->stream_reclen = 0;
-			transport->stream_copied = 0;
-			transport->stream_flags =
-				STREAM_RCV_COPY_FRAGHDR | STREAM_RCV_COPY_XID;
-			transport->stream_read_sock = tcp_read_sock;
+			xs_stream_reset_state(xprt, tcp_read_sock);
 			xprt->connect_cookie++;
 			clear_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 			xprt_clear_connecting(xprt);
-- 
2.9.4

