Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:46005 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604AbaGVOyE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:54:04 -0400
Subject: [PATCH v4 21/21] xprtrdma: Handle additional connection events
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:54:01 -0400
Message-ID: <20140722145401.6010.63941.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
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
index 721a6fd..6ead5df 100644
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
 

