From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 06/20] svc: export svc_sock_enqueue,
	svc_sock_received
Date: Tue, 10 Jul 2007 00:34:32 -0500
Message-ID: <20070710053432.28979.89368.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mt-00074Z-89
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:35 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mw-0004s4-8N
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:38 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id DBF2B7C79E
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:32 -0500 (CDT)
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


Export svc_sock_enqueue() and svc_sock_received() so they
can be used by sunrpc server transport implementations
(even future modular ones).

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    2 ++
 net/sunrpc/svcsock.c           |    7 ++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index ce93b10..9fa4321 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -108,6 +108,8 @@ int		svc_addsock(struct svc_serv *serv,
 			    int fd,
 			    char *name_return,
 			    int *proto);
+void		svc_sock_enqueue(struct svc_sock *svsk);
+void		svc_sock_received(struct svc_sock *svsk);
 
 /*
  * svc_makesock socket characteristics
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1a6a933..f09c4b4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -209,7 +209,7 @@ svc_release_skb(struct svc_rqst *rqstp)
  * processes, wake 'em up.
  *
  */
-static void
+void
 svc_sock_enqueue(struct svc_sock *svsk)
 {
 	struct svc_serv	*serv = svsk->sk_server;
@@ -287,6 +287,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 out_unlock:
 	spin_unlock_bh(&pool->sp_lock);
 }
+EXPORT_SYMBOL(svc_sock_enqueue);
 
 /*
  * Dequeue the first socket.  Must be called with the pool->sp_lock held.
@@ -315,14 +316,14 @@ svc_sock_dequeue(struct svc_pool *pool)
  * Note: SK_DATA only gets cleared when a read-attempt finds
  * no (or insufficient) data.
  */
-static inline void
+void
 svc_sock_received(struct svc_sock *svsk)
 {
 	svsk->sk_pool = NULL;
 	clear_bit(SK_BUSY, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 }
-
+EXPORT_SYMBOL(svc_sock_received);
 
 /**
  * svc_reserve - change the space reserved for the reply to a request.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
