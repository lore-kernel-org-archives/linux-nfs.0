Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087AbbFDQqF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 12:46:05 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        asias.hejun@gmail.com, netdev@vger.kernel.org,
        Daniel Berrange <berrange@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [RFC 04/10] SUNRPC: extract xs_stream_reset_state()
Date: Thu,  4 Jun 2015 17:45:47 +0100
Message-Id: <1433436353-6761-5-git-send-email-stefanha@redhat.com>
In-Reply-To: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
References: <1433436353-6761-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Extract a function to reset the record fragment parser.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/xprtsock.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 06fde0e..9fa63f7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1431,6 +1431,28 @@ out:
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
@@ -1454,16 +1476,7 @@ static void xs_tcp_state_change(struct sock *sk)
 	case TCP_ESTABLISHED:
 		spin_lock(&xprt->transport_lock);
 		if (!xprt_test_and_set_connected(xprt)) {
-			struct sock_xprt *transport = container_of(xprt,
-					struct sock_xprt, xprt);
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
 
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
-- 
2.4.2

