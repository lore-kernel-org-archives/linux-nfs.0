From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/5] RPC: Fix the TCP resend semantics for NFSv4
Date: Fri, 20 Apr 2007 16:12:55 -0400
Message-ID: <20070420201255.7897.84317.stgit@heimdal.trondhjem.org>
References: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, Florin Iucha <florin@iucha.net>,
	Adrian Bunk <bunk@stusta.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HezTR-0002oU-9u
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:55 -0700
Received: from dh166.citi.umich.edu ([141.211.133.166]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HezTT-0006pN-Lr
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:55 -0700
In-Reply-To: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Fix a regression due to the patch "NFS: disconnect before retrying NFSv4
requests over TCP"

The assumption made in xprt_transmit() that the condition
	"req->rq_bytes_sent == 0 and request is on the receive list"
should imply that we're dealing with a retransmission is false.
Firstly, it may simply happen that the socket send queue was full
at the time the request was initially sent through xprt_transmit().
Secondly, doing this for each request that was retransmitted implies
that we disconnect and reconnect for _every_ request that happened to
be retransmitted irrespective of whether or not a disconnection has
already occurred.

Fix is to move this logic into the call_status request timeout handler.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |    4 ++++
 net/sunrpc/xprt.c |   10 ----------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6d7221f..396cdbe 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1046,6 +1046,8 @@ call_status(struct rpc_task *task)
 		rpc_delay(task, 3*HZ);
 	case -ETIMEDOUT:
 		task->tk_action = call_timeout;
+		if (task->tk_client->cl_discrtry)
+			xprt_disconnect(task->tk_xprt);
 		break;
 	case -ECONNREFUSED:
 	case -ENOTCONN:
@@ -1169,6 +1171,8 @@ call_decode(struct rpc_task *task)
 out_retry:
 	req->rq_received = req->rq_private_buf.len = 0;
 	task->tk_status = 0;
+	if (task->tk_client->cl_discrtry)
+		xprt_disconnect(task->tk_xprt);
 }
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ee6ffa0..456a145 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -735,16 +735,6 @@ void xprt_transmit(struct rpc_task *task)
 			xprt_reset_majortimeo(req);
 			/* Turn off autodisconnect */
 			del_singleshot_timer_sync(&xprt->timer);
-		} else {
-			/* If all request bytes have been sent,
-			 * then we must be retransmitting this one */
-			if (!req->rq_bytes_sent) {
-				if (task->tk_client->cl_discrtry) {
-					xprt_disconnect(xprt);
-					task->tk_status = -ENOTCONN;
-					return;
-				}
-			}
 		}
 	} else if (!req->rq_bytes_sent)
 		return;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
