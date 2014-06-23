Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34331 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaFWWku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 18:40:50 -0400
Subject: [PATCH v1 13/13] xprtrdma: Handle additional connection events
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Jun 2014 18:40:48 -0400
Message-ID: <20140623224048.1634.23972.stgit@manet.1015granger.net>
In-Reply-To: <20140623223201.1634.83888.stgit@manet.1015granger.net>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 38ca83a5 added RDMA_CM_EVENT_TIMEWAIT_EXIT. But that status
is relevant only for consumers that re-use their QPs on new
connections. xprtrdma creates a fresh QP on reconnection, so that
event should be explicitly ignored.

Squelch the alarming "unexpected CM event" message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index ec98e48..dbd5f22 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -334,8 +334,16 @@ static const char * const conn[] = {
 	"rejected",
 	"established",
 	"disconnected",
-	"device removal"
+	"device removal",
+	"multicast join",
+	"multicast error",
+	"address change",
+	"timewait exit",
 };
+
+#define CONNECTION_MSG(status)						\
+	((status) < ARRAY_SIZE(conn) ?					\
+		conn[(status)] : "unrecognized connection error")
 #endif
 
 static int
@@ -393,13 +401,10 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		connstate = -ENODEV;
 connected:
-		dprintk("RPC:       %s: %s: %pI4:%u (ep 0x%p event 0x%x)\n",
-			__func__,
-			(event->event <= 11) ? conn[event->event] :
-						"unknown connection error",
-			&addr->sin_addr.s_addr,
-			ntohs(addr->sin_port),
-			ep, event->event);
+		dprintk("RPC:       %s: %pI4:%u (ep 0x%p): %s\n",
+			__func__, &addr->sin_addr.s_addr,
+			ntohs(addr->sin_port), ep,
+			CONNECTION_MSG(event->event));
 		atomic_set(&rpcx_to_rdmax(ep->rep_xprt)->rx_buf.rb_credits, 1);
 		dprintk("RPC:       %s: %sconnected\n",
 					__func__, connstate > 0 ? "" : "dis");
@@ -408,8 +413,10 @@ connected:
 		wake_up_all(&ep->rep_connect_wait);
 		break;
 	default:
-		dprintk("RPC:       %s: unexpected CM event %d\n",
-			__func__, event->event);
+		dprintk("RPC:       %s: %pI4:%u (ep 0x%p): %s\n",
+			__func__, &addr->sin_addr.s_addr,
+			ntohs(addr->sin_port), ep,
+			CONNECTION_MSG(event->event));
 		break;
 	}
 

