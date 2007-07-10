From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 07/20] svc: centralise close handling
Date: Tue, 10 Jul 2007 00:34:34 -0500
Message-ID: <20070710053434.28979.66318.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mp-00074F-SH
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:31 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mt-0003S1-5L
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:35 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id F34DD7C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:34 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Centralise the handling of the SK_CLOSE bit to that future
sunrpc server transport implementations will be easier to
write correctly. The sko_recvfrom method does not 
need to check for SK_CLOSE anymore, that's handled in 
core code.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f09c4b4..75fae77 100644
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
-	len = svsk->sk_ops->sko_recvfrom(rqstp);
-	dprintk("svc: got len=%d\n", len);
+	len = 0;
+	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
+		dprintk("svc_recv: found SK_CLOSE\n");
+		svc_delete_socket(svsk);
+	} else {
+		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
+			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+		len = svsk->sk_ops->sko_recvfrom(rqstp);
+		dprintk("svc: got len=%d\n", len);
+	}
 
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
