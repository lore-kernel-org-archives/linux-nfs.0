From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 013/112] SUNRPC: Reconnect immediately whenever the server
	isn't refusing it.
Date: Fri, 25 Jan 2008 11:37:26 -0500
Message-ID: <20080125163726.31887.80523.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282AbYAYRAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:00 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsec010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:58 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we've disconnected from the server, rather than the other way round,
then it makes little sense to wait 3 seconds before reconnecting.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5f2bbe6..cf39060 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1126,13 +1126,13 @@ static void xs_tcp_state_change(struct sock *sk)
 			transport->tcp_flags =
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 
-			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 			xprt_wake_pending_tasks(xprt, 0);
 		}
 		spin_unlock_bh(&xprt->transport_lock);
 		break;
 	case TCP_FIN_WAIT1:
 		/* The client initiated a shutdown of the socket */
+		xprt->reestablish_timeout = 0;
 		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
@@ -1143,6 +1143,14 @@ static void xs_tcp_state_change(struct sock *sk)
 		/* The server initiated a shutdown of the socket */
 		set_bit(XPRT_CLOSING, &xprt->state);
 		xprt_force_disconnect(xprt);
+	case TCP_SYN_SENT:
+	case TCP_CLOSING:
+		/*
+		 * If the server closed down the connection, make sure that
+		 * we back off before reconnecting
+		 */
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		break;
 	case TCP_LAST_ACK:
 		smp_mb__before_clear_bit();
