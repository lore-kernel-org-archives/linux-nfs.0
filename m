From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 03/20] svc: svc_prep_reply_hdr
Date: Tue, 10 Jul 2007 00:34:26 -0500
Message-ID: <20070710053426.28979.60829.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mm-000743-Hw
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:28 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mp-0003Rm-Ut
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:32 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 8EAAA7C7BD
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:26 -0500 (CDT)
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


Add a sock method that prepares the transport specific header for 
RPC replies. UDP has none, TCP has a 4B record length. This will
allow the RDMA transport to prepare it's variable length reply
header as well.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |    4 ++++
 net/sunrpc/svc.c               |    8 +++++---
 net/sunrpc/svcsock.c           |   17 ++++++++++++++++-
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 72beb7b..fa92f3f 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -27,6 +27,10 @@ struct svc_sock_ops {
 	 * destruction of a svc_sock.
 	 */
 	void			(*sko_free)(struct svc_sock *);
+	/*
+	 * Prepare any transport-specific RPC header.
+	 */
+	int                     (*sko_prep_reply_hdr)(struct svc_rqst *);
 };
 
 /*
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index e673ef9..f852587 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -815,9 +815,11 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_sendfile_ok = 1;
-	/* tcp needs a space for the record length... */
-	if (rqstp->rq_prot == IPPROTO_TCP)
-		svc_putnl(resv, 0);
+
+	/* setup response header. */
+	if (rqstp->rq_sock->sk_ops->sko_prep_reply_hdr &&
+	    rqstp->rq_sock->sk_ops->sko_prep_reply_hdr(rqstp))
+		goto dropit;
 
 	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index da7e5ea..4ff1a62 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1326,12 +1326,27 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+/*
+ * Setup response header. TCP has a 4B record length field.
+ */
+static int
+svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+	struct kvec *resv = &rqstp->rq_res.head[0];
+
+	/* tcp needs a space for the record length... */
+	svc_putnl(resv, 0);
+
+	return 0;
+}
+
 static const struct svc_sock_ops svc_tcp_ops = {
 	.sko_name = "tcp",
 	.sko_recvfrom = svc_tcp_recvfrom,
 	.sko_sendto = svc_tcp_sendto,
 	.sko_detach = svc_tcpip_detach,
-	.sko_free = svc_tcpip_free
+	.sko_free = svc_tcpip_free,
+	.sko_prep_reply_hdr = svc_tcp_prep_reply_hdr
 };
 
 static void

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
