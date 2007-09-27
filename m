From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 04/33] svc: Add a max payload value to the transport
Date: Thu, 27 Sep 2007 00:01:43 -0500
Message-ID: <20070927050142.12677.65077.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVP-0005bC-LL
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:43 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVU-0005Ay-Bd
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:48 -0700
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


The svc_max_payload function currently looks at the socket type
to determine the max payload. Add a max payload value to svc_xprt_class
so it can be returned directly. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 ++
 net/sunrpc/svc.c                |    4 +---
 net/sunrpc/svc_xprt.c           |    1 +
 net/sunrpc/svcsock.c            |    2 ++
 4 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index a9a3afe..827f0fe 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -17,11 +17,13 @@ struct svc_xprt_class {
 	struct module		*xcl_owner;
 	struct svc_xprt_ops	*xcl_ops;
 	struct list_head	xcl_list;
+	u32			xcl_max_payload;
 };
 
 struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	struct svc_xprt_ops	xpt_ops;
+	u32			xpt_max_payload;
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 55ea6df..2a4b3c6 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1034,10 +1034,8 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = RPCSVC_MAXPAYLOAD_TCP;
+	int max = rqstp->rq_xprt->xpt_max_payload;
 
-	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
-		max = RPCSVC_MAXPAYLOAD_UDP;
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
 	return max;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f868192..6151db5 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -90,5 +90,6 @@ void svc_xprt_init(struct svc_xprt_class
 {
 	xpt->xpt_class = xcl;
 	xpt->xpt_ops = *xcl->xcl_ops;
+	xpt->xpt_max_payload = xcl->xcl_max_payload;
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2a56697..dd5c6fb 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -905,6 +905,7 @@ static struct svc_xprt_ops svc_udp_ops =
 static struct svc_xprt_class svc_udp_class = {
 	.xcl_name = "udp",
 	.xcl_ops = &svc_udp_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
 
 static void
@@ -1358,6 +1359,7 @@ static struct svc_xprt_ops svc_tcp_ops =
 static struct svc_xprt_class svc_tcp_class = {
 	.xcl_name = "tcp",
 	.xcl_ops = &svc_tcp_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
 void svc_init_xprt_sock(void) 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
