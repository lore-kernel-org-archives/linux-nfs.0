From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 7/7] svc: Place type on same line for new API
Date: Tue, 09 Oct 2007 10:37:22 -0500
Message-ID: <20071009153722.18846.31423.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH96-0005fU-LS
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:21 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH98-0000G1-Mm
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:25 -0700
In-Reply-To: <20071009153539.18846.33780.stgit@dell3.ogc.int>
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


The convention is place the type name on the same line as the function
name. The inline directive was also removed to allow the compiler to
elect whether or not to inline.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_xprt.c |   52 +++++++++++++++++--------------------------------
 1 files changed, 18 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 4841c4b..080ecf5 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -121,7 +121,7 @@ int svc_print_xprts(char *buf, int maxle
 	return len;
 }
 
-static inline void svc_xprt_free(struct kref *kref)
+static void svc_xprt_free(struct kref *kref)
 {
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
@@ -209,8 +209,7 @@ EXPORT_SYMBOL_GPL(svc_create_xprt);
  * use as many different threads as we need, and the rest don't pollute
  * the cache.
  */
-static inline void
-svc_thread_enqueue(struct svc_pool *pool, struct svc_rqst *rqstp)
+static void svc_thread_enqueue(struct svc_pool *pool, struct svc_rqst *rqstp)
 {
 	list_add(&rqstp->rq_list, &pool->sp_threads);
 }
@@ -218,8 +217,7 @@ svc_thread_enqueue(struct svc_pool *pool
 /*
  * Dequeue an nfsd thread.  Must have pool->sp_lock held.
  */
-static inline void
-svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
+static void svc_thread_dequeue(struct svc_pool *pool, struct svc_rqst *rqstp)
 {
 	list_del(&rqstp->rq_list);
 }
@@ -229,8 +227,7 @@ svc_thread_dequeue(struct svc_pool *pool
  * processes, wake 'em up.
  *
  */
-void
-svc_xprt_enqueue(struct svc_xprt *xprt)
+void svc_xprt_enqueue(struct svc_xprt *xprt)
 {
 	struct svc_serv	*serv = xprt->xpt_server;
 	struct svc_pool *pool;
@@ -322,8 +319,7 @@ EXPORT_SYMBOL_GPL(svc_xprt_enqueue);
 /*
  * Dequeue the first transport.  Must be called with the pool->sp_lock held.
  */
-static inline struct svc_xprt *
-svc_xprt_dequeue(struct svc_pool *pool)
+static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
 {
 	struct svc_xprt	*xprt;
 
@@ -346,8 +342,7 @@ svc_xprt_dequeue(struct svc_pool *pool)
  * Note: XPT_DATA only gets cleared when a read-attempt finds
  * no (or insufficient) data.
  */
-void
-svc_xprt_received(struct svc_xprt *xprt)
+void svc_xprt_received(struct svc_xprt *xprt)
 {
 	xprt->xpt_pool = NULL;
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
@@ -378,8 +373,7 @@ void svc_reserve(struct svc_rqst *rqstp,
 	}
 }
 
-static void
-svc_xprt_release(struct svc_rqst *rqstp)
+static void svc_xprt_release(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
@@ -411,8 +405,7 @@ svc_xprt_release(struct svc_rqst *rqstp)
  * This really only makes sense for services like lockd
  * which have exactly one thread anyway.
  */
-void
-svc_wake_up(struct svc_serv *serv)
+void svc_wake_up(struct svc_serv *serv)
 {
 	struct svc_rqst	*rqstp;
 	unsigned int i;
@@ -437,8 +430,7 @@ svc_wake_up(struct svc_serv *serv)
 	}
 }
 
-static void
-svc_check_conn_limits(struct svc_serv *serv)
+static void svc_check_conn_limits(struct svc_serv *serv)
 {
 	char	buf[RPC_MAX_ADDRBUFLEN];
 
@@ -485,7 +477,7 @@ svc_check_conn_limits(struct svc_serv *s
 	}
 }
 
-static inline void svc_copy_addr(struct svc_rqst *rqstp, struct svc_xprt *xprt)
+static void svc_copy_addr(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 {
 	struct sockaddr *sin;
 
@@ -513,8 +505,7 @@ static inline void svc_copy_addr(struct 
  * organised not to touch any cachelines in the shared svc_serv
  * structure, only cachelines in the local svc_pool.
  */
-int
-svc_recv(struct svc_rqst *rqstp, long timeout)
+int svc_recv(struct svc_rqst *rqstp, long timeout)
 {
 	struct svc_xprt		*xprt = NULL;
 	struct svc_serv		*serv = rqstp->rq_server;
@@ -661,8 +652,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 /*
  * Drop request
  */
-void
-svc_drop(struct svc_rqst *rqstp)
+void svc_drop(struct svc_rqst *rqstp)
 {
 	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
 	svc_xprt_release(rqstp);
@@ -671,8 +661,7 @@ svc_drop(struct svc_rqst *rqstp)
 /*
  * Return reply to client.
  */
-int
-svc_send(struct svc_rqst *rqstp)
+int svc_send(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt;
 	int		len;
@@ -708,8 +697,7 @@ svc_send(struct svc_rqst *rqstp)
  * Timer function to close old temporary transports, using
  * a mark-and-sweep algorithm.
  */
-static void
-svc_age_temp_xprts(unsigned long closure)
+static void svc_age_temp_xprts(unsigned long closure)
 {
 	struct svc_serv *serv = (struct svc_serv *)closure;
 	struct svc_xprt *xprt;
@@ -761,8 +749,7 @@ svc_age_temp_xprts(unsigned long closure
 /*
  * Remove a dead transport
  */
-void
-svc_delete_xprt(struct svc_xprt *xprt)
+void svc_delete_xprt(struct svc_xprt *xprt)
 {
 	struct svc_serv	*serv;
 
@@ -871,8 +858,7 @@ static void svc_revisit(struct cache_def
  * This code can only handle requests that consist of an xprt-header
  * and rpc-header.
  */
-static struct cache_deferred_req *
-svc_defer(struct cache_req *req)
+static struct cache_deferred_req *svc_defer(struct cache_req *req)
 {
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
 	struct svc_deferred_req *dr;
@@ -971,12 +957,10 @@ struct svc_xprt *svc_find_xprt(struct sv
 		sin = (struct sockaddr_in *)&xprt->xpt_local;
 		if (af && sin->sin_family != af)
 			continue;
-
 		if (port && (sin->sin_port != port))
 			continue;
-
-		break;
+		return xprt;
 	}
-	return xprt;
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(svc_find_xprt);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
