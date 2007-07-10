From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 18/20] svc: Add sko_defer routine
Date: Tue, 10 Jul 2007 00:34:58 -0500
Message-ID: <20070710053458.28979.81203.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88NI-00076Y-U4
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:35:02 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88NL-0004xg-Ij
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:35:04 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 28C247C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:58 -0500 (CDT)
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


The RDMA transport includes an ONCRDMA header that precedes the RPC 
message. This header needs to be saved in addition to the RPC message 
itself. The RPC transport uses page swapping to implement copy avoidance.
These transport dependencies are hidden in the sko_defer routine allowing
the bulk of the deferral processing to remain in transport independent 
code.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    4 ++++
 net/sunrpc/svcsock.c           |   11 +++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 5c272db..b815f36 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -52,6 +52,9 @@ struct svc_sock_ops {
 	 */
 	int			(*sko_accept)(struct svc_sock *svsk);
 
+	/* RPC defer routine. */
+	struct cache_deferred_req *(*sko_defer)(struct cache_req *req);
+
 	/* Transport list link */
 	struct list_head	sko_list;
 };
@@ -139,6 +142,7 @@ void		svc_sock_add_connection(struct svc
 void		svc_sock_add_listener(struct svc_sock *);
 /* Add an initialised connectionless svc_sock to the server */
 void		svc_sock_add_connectionless(struct svc_sock *);
+void 		svc_revisit(struct cache_deferred_req *dreq, int too_many);
 
 /*
  * svc_makesock socket characteristics
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 6bd6169..b0e1b61 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -986,7 +986,8 @@ static struct svc_sock_ops svc_udp_ops =
 	.sko_detach = svc_tcpip_detach,
 	.sko_free = svc_tcpip_free,
 	.sko_has_wspace = svc_udp_has_wspace,
-	.sko_max_payload = RPCSVC_MAXPAYLOAD_UDP
+	.sko_max_payload = RPCSVC_MAXPAYLOAD_UDP,
+	.sko_defer = svc_defer
 };
 
 static void
@@ -1457,7 +1458,8 @@ static struct svc_sock_ops svc_tcp_ops =
 	.sko_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.sko_has_wspace = svc_tcp_has_wspace,
 	.sko_max_payload = RPCSVC_MAXPAYLOAD_TCP,
-	.sko_accept = svc_tcp_accept
+	.sko_accept = svc_tcp_accept,
+	.sko_defer = svc_defer
 };
 
 void init_svc_xprt(void) 
@@ -1650,7 +1652,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	clear_bit(SK_OLD, &svsk->sk_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
-	rqstp->rq_chandle.defer = svc_defer;
+	rqstp->rq_chandle.defer = svsk->sk_ops->sko_defer;
 
 	if (serv->sv_stats)
 		serv->sv_stats->netcnt++;
@@ -2114,7 +2116,7 @@ int svc_create_svcsock(struct svc_serv *
  * Handle defer and revisit of requests
  */
 
-static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
+void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 {
 	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
 	struct svc_sock *svsk;
@@ -2134,6 +2136,7 @@ static void svc_revisit(struct cache_def
 	svc_sock_enqueue(svsk);
 	svc_sock_put(svsk);
 }
+EXPORT_SYMBOL(svc_revisit);
 
 static struct cache_deferred_req *
 svc_defer(struct cache_req *req)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
