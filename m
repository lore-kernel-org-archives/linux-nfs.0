From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 26/33] svc: Make svc_sock_release svc_xprt_release
Date: Thu, 27 Sep 2007 00:02:29 -0500
Message-ID: <20070927050229.12677.83113.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalWA-0005jV-49
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:30 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWE-0005Vm-Mr
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:35 -0700
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


The svc_sock_release function only touches transport independent fields.
Change the function to manipulate svc_xprt directly instead of the transport
dependent svc_sock structure. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 37978f7..89f345d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -377,9 +377,9 @@ void svc_reserve(struct svc_rqst *rqstp,
 }
 
 static void
-svc_sock_release(struct svc_rqst *rqstp)
+svc_xprt_release(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
 	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
 
@@ -387,7 +387,6 @@ svc_sock_release(struct svc_rqst *rqstp)
 	rqstp->rq_res.page_len = 0;
 	rqstp->rq_res.page_base = 0;
 
-
 	/* Reset response buffer and release
 	 * the reservation.
 	 * But first, check that enough space was reserved
@@ -400,9 +399,9 @@ svc_sock_release(struct svc_rqst *rqstp)
 
 	rqstp->rq_res.head[0].iov_len = 0;
 	svc_reserve(rqstp, 0);
-	rqstp->rq_sock = NULL;
+	rqstp->rq_xprt = NULL;
 
-	svc_xprt_put(&svsk->sk_xprt);
+	svc_xprt_put(xprt);
 }
 
 /*
@@ -1618,7 +1617,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	/* No data, incomplete (TCP) read, or accept() */
 	if (len == 0 || len == -EAGAIN) {
 		rqstp->rq_res.len = 0;
-		svc_sock_release(rqstp);
+		svc_xprt_release(rqstp);
 		return -EAGAIN;
 	}
 	svsk->sk_xprt.xpt_lastrecv = get_seconds();
@@ -1639,7 +1638,7 @@ void
 svc_drop(struct svc_rqst *rqstp)
 {
 	dprintk("svc: socket %p dropped request\n", rqstp->rq_sock);
-	svc_sock_release(rqstp);
+	svc_xprt_release(rqstp);
 }
 
 /*
@@ -1674,7 +1673,7 @@ svc_send(struct svc_rqst *rqstp)
 	else
 		len = xprt->xpt_ops.xpo_sendto(rqstp);
 	mutex_unlock(&xprt->xpt_mutex);
-	svc_sock_release(rqstp);
+	svc_xprt_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
 		return 0;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
