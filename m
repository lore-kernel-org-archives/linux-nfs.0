From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 08/33] svc: Add xpo_prep_reply_hdr
Date: Thu, 27 Sep 2007 00:01:51 -0500
Message-ID: <20070927050151.12677.59462.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVS-0005bS-PR
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:46 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVX-0005Bc-HC
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:51 -0700
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


Some transports add fields to the RPC header for replies, e.g. the TCP
record length. This function is called when preparing the reply header
to allow each transport to add whatever fields it requires.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc.c                |    6 +++---
 net/sunrpc/svcsock.c            |   19 +++++++++++++++++++
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 85d84b2..1cd86fe 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -11,6 +11,7 @@ #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
+	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
 	void		(*xpo_release)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2a4b3c6..ee68117 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -815,9 +815,9 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = 1;
-	/* tcp needs a space for the record length... */
-	if (rqstp->rq_prot == IPPROTO_TCP)
-		svc_putnl(resv, 0);
+
+	/* Setup reply header */
+	rqstp->rq_xprt->xpt_ops.xpo_prep_reply_hdr(rqstp);
 
 	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0db0a26..99f5faf 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -893,12 +893,18 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static void 
+svc_udp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_release = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1350,12 +1356,25 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+/*
+ * Setup response header. TCP has a 4B record length field.
+ */
+static void
+svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+	struct kvec *resv = &rqstp->rq_res.head[0];
+
+	/* tcp needs a space for the record length... */
+	svc_putnl(resv, 0);
+}
+
 static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_release = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 };
 
 static struct svc_xprt_class svc_tcp_class = {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
