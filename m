From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 18/20] svc: Add xpt_defer transport function
Date: Mon, 20 Aug 2007 11:23:59 -0500
Message-ID: <20070820162359.15224.74970.stgit@dell3.ogc.int>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2t-0006Rx-Qv
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:04 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2x-00047m-8Q
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:24:08 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id D5BCF7C79B
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:59 -0500 (CDT)
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


The RDMA transport includes an ONCRDMA header that precedes the RPC 
message. This header needs to be saved in addition to the RPC message 
itself. The RPC transport uses page swapping to implement copy avoidance.
These transport dependencies are hidden in the xpt_defer routine allowing
the bulk of the deferral processing to remain in transport independent 
code.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    5 +++++
 net/sunrpc/svcsock.c           |    5 +++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index a920e9b..145c82b 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -51,6 +51,10 @@ struct svc_xprt {
 	 * Accept a pending connection, for connection-oriented transports
 	 */
 	int			(*xpt_accept)(struct svc_sock *svsk);
+
+	/* RPC defer routine. */
+	struct cache_deferred_req *(*xpt_defer)(struct cache_req *req);
+
 	/* Transport list link */
 	struct list_head	xpt_list;
 };
@@ -138,6 +142,7 @@ void		svc_sock_add_connection(struct svc
 void		svc_sock_add_listener(struct svc_sock *);
 /* Add an initialised connectionless svc_sock to the server */
 void		svc_sock_add_connectionless(struct svc_sock *);
+void 		svc_revisit(struct cache_deferred_req *dreq, int too_many);
 
 /*
  * svc_makesock socket characteristics
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 03ce7e9..b89c577 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1651,7 +1651,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	clear_bit(SK_OLD, &svsk->sk_flags);
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
-	rqstp->rq_chandle.defer = svc_defer;
+	rqstp->rq_chandle.defer = svsk->sk_xprt->xpt_defer;
 
 	if (serv->sv_stats)
 		serv->sv_stats->netcnt++;
@@ -2116,7 +2116,7 @@ EXPORT_SYMBOL_GPL(svc_create_svcsock);
  * Handle defer and revisit of requests
  */
 
-static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
+void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 {
 	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
 	struct svc_sock *svsk;
@@ -2136,6 +2136,7 @@ static void svc_revisit(struct cache_def
 	svc_sock_enqueue(svsk);
 	svc_sock_put(svsk);
 }
+EXPORT_SYMBOL_GPL(svc_revisit);
 
 static struct cache_deferred_req *
 svc_defer(struct cache_req *req)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
