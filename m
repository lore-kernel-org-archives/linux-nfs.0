From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 07/20] svc: centralise close handling
Date: Mon, 20 Aug 2007 11:23:36 -0500
Message-ID: <20070820162336.15224.39616.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2W-0006Ns-5k
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:40 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2a-0003xF-4p
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:44 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 65E427C79C
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:36 -0500 (CDT)
In-Reply-To: <20070820162000.15224.65524.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Centralise the handling of the SK_CLOSE bit so that future
server transport implementations will be easier to
write correctly. The xpt_recvfrom method does not 
need to check for SK_CLOSE anymore, that's handled in 
core code.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8fad53d..5c3a794 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -756,11 +756,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1158,11 +1153,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1406,8 +1396,10 @@ svc_tcp_init(struct svc_sock *svsk)
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 		set_bit(SK_DATA, &svsk->sk_flags);
-		if (sk->sk_state != TCP_ESTABLISHED)
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			/* note: caller calls svc_sock_enqueue() */
 			set_bit(SK_CLOSE, &svsk->sk_flags);
+		}
 	}
 }
 
@@ -1525,10 +1517,16 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	}
 	spin_unlock_bh(&pool->sp_lock);
 
-	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_xprt->xpt_recvfrom(rqstp);
-	dprintk("svc: got len=%d\n", len);
+	len = 0;
+	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
+		dprintk("svc_recv: found SK_CLOSE\n");
+		svc_delete_socket(svsk);
+	} else {
+		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
+			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+		len = svsk->sk_xprt->xpt_recvfrom(rqstp);
+		dprintk("svc: got len=%d\n", len);
+	}
 
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
