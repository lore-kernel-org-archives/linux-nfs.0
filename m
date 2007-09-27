From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 10/33] svc: Move close processing to a single place
Date: Thu, 27 Sep 2007 00:01:55 -0500
Message-ID: <20070927050155.12677.29168.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVc-0005bf-J2
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:56 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVg-0005FU-Uu
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:01 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
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


Close handling was duplicated in the UDP and TCP recvfrom 
methods. This code has been moved to the transport independent
svc_recv function.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1df9933..93c5fb6 100644
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
@@ -1199,11 +1194,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
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
@@ -1589,10 +1579,16 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	}
 	spin_unlock_bh(&pool->sp_lock);
 
-	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
-		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
-	dprintk("svc: got len=%d\n", len);
+	len = 0;
+	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
+		dprintk("svc_recv: found SK_CLOSE\n");
+		svc_delete_socket(svsk);
+	} else {
+		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
+			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
+		len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
+		dprintk("svc: got len=%d\n", len);
+	}
 
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
