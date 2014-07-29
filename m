Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:57836 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353AbaG2V0P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 17:26:15 -0400
Subject: [PATCH v5 21/21] xprtrdma: Handle additional connection events
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Jul 2014 17:26:12 -0400
Message-ID: <20140729212612.2812.48389.stgit@manet.1015granger.net>
In-Reply-To: <20140729211534.2812.3128.stgit@manet.1015granger.net>
References: <20140729211534.2812.3128.stgit@manet.1015granger.net>
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
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/verbs.c |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 699e62d..0b2e255 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -326,8 +326,16 @@ static const char * const conn[] = {
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
@@ -385,23 +393,18 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
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
 		atomic_set(&rpcx_to_rdmax(ep->rep_xprt)->rx_buf.rb_credits, 1);
 		dprintk("RPC:       %s: %sconnected\n",
 					__func__, connstate > 0 ? "" : "dis");
 		ep->rep_connected = connstate;
 		ep->rep_func(ep);
 		wake_up_all(&ep->rep_connect_wait);
-		break;
+		/*FALLTHROUGH*/
 	default:
-		dprintk("RPC:       %s: unexpected CM event %d\n",
-			__func__, event->event);
+		dprintk("RPC:       %s: %pI4:%u (ep 0x%p): %s\n",
+			__func__, &addr->sin_addr.s_addr,
+			ntohs(addr->sin_port), ep,
+			CONNECTION_MSG(event->event));
 		break;
 	}
 

