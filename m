From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 23/30] SUNRPC: Handle socket errors correctly
Date: Wed, 11 Mar 2009 14:41:09 -0400
Message-ID: <20090311184109.5578.20263.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753998AbZCKSpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:15 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj5jM022182
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:12 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we pick up and handle socket errors as they occur.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5e8198b..879af6f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1208,23 +1208,20 @@ static void xs_tcp_state_change(struct sock *sk)
 }
 
 /**
- * xs_tcp_error_report - callback mainly for catching RST events
+ * xs_error_report - callback mainly for catching socket errors
  * @sk: socket
  */
-static void xs_tcp_error_report(struct sock *sk)
+static void xs_error_report(struct sock *sk)
 {
 	struct rpc_xprt *xprt;
 
 	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_err != ECONNRESET || sk->sk_state != TCP_ESTABLISHED)
-		goto out;
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
 	dprintk("RPC:       %s client %p...\n"
 			"RPC:       error %d\n",
 			__func__, xprt, sk->sk_err);
-
-	xprt_force_disconnect(xprt);
+	xprt_wake_pending_tasks(xprt, -EAGAIN);
 out:
 	read_unlock(&sk->sk_callback_lock);
 }
@@ -1509,6 +1506,7 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_user_data = xprt;
 		sk->sk_data_ready = xs_udp_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
+		sk->sk_error_report = xs_error_report;
 		sk->sk_no_check = UDP_CSUM_NORCV;
 		sk->sk_allocation = GFP_ATOMIC;
 
@@ -1656,7 +1654,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_data_ready = xs_tcp_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
-		sk->sk_error_report = xs_tcp_error_report;
+		sk->sk_error_report = xs_error_report;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		/* socket options */

