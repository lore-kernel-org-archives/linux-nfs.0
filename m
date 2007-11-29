From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 10/38] svc: Move close processing to a single place
Date: Thu, 29 Nov 2007 16:40:14 -0600
Message-ID: <20071129224014.14563.53244.stgit@dell3.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48902 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934115AbXK2XDj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:39 -0500
In-Reply-To: <20071129223917.14563.77633.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Close handling was duplicated in the UDP and TCP recvfrom 
methods. This code has been moved to the transport independent
svc_recv function.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b796244..38ecdd1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -792,11 +792,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
-		svc_delete_socket(svsk);
-		return 0;
-	}
-
 	clear_bit(SK_DATA, &svsk->sk_flags);
 	skb = NULL;
 	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
@@ -1197,11 +1192,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 	}
 
-	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
-		svc_delete_socket(svsk);
-		return 0;
-	}
-
 	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
 		svc_tcp_accept(svsk);
 		svc_sock_received(svsk);
@@ -1585,10 +1575,16 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 	}
 	spin_unlock_bh(&pool->sp_lock);
 
-	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
-	dprintk("svc: got len=%d\n", len);
+	len = 0;
+	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
+		dprintk("svc_recv: found SK_CLOSE\n");
+		svc_delete_socket(svsk);
+	} else {
+		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
+			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+		len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
+		dprintk("svc: got len=%d\n", len);
+	}
 
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
