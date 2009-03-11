From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/30] SUNRPC: Ensure we set XPRT_CLOSING only after we've
 sent a tcp FIN...
Date: Wed, 11 Mar 2009 14:41:09 -0400
Message-ID: <20090311184109.5578.12028.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753691AbZCKSpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:14 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj5jK022182
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:12 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...so that we can distinguish between when we need to shutdown and when we
don't. Also remove the call to xs_tcp_shutdown() from xs_tcp_connect(),
since xprt_connect() makes the same test.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1127eb9..cb4bd93 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1180,7 +1180,6 @@ static void xs_tcp_state_change(struct sock *sk)
 		break;
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
-		set_bit(XPRT_CLOSING, &xprt->state);
 		xprt_force_disconnect(xprt);
 	case TCP_SYN_SENT:
 		xprt->connect_cookie++;
@@ -1193,6 +1192,7 @@ static void xs_tcp_state_change(struct sock *sk)
 			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		break;
 	case TCP_LAST_ACK:
+		set_bit(XPRT_CLOSING, &xprt->state);
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_CONNECTED, &xprt->state);
 		smp_mb__after_clear_bit();
@@ -1836,9 +1836,6 @@ static void xs_tcp_connect(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 
-	/* Initiate graceful shutdown of the socket if not already done */
-	if (test_bit(XPRT_CONNECTED, &xprt->state))
-		xs_tcp_shutdown(xprt);
 	/* Exit if we need to wait for socket shutdown to complete */
 	if (test_bit(XPRT_CLOSING, &xprt->state))
 		return;

