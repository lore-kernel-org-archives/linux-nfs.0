From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 08/40] svc: Add xpo_prep_reply_hdr
Date: Sun, 30 Dec 2007 21:07:29 -0600
Message-ID: <20071231030729.8430.19864.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41491 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752367AbXLaDHa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:30 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Some transports add fields to the RPC header for replies, e.g. the TCP
record length. This function is called when preparing the reply header
to allow each transport to add whatever fields it requires.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc.c                |    6 +++---
 net/sunrpc/svcsock.c            |   17 +++++++++++++++++
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index f032fb6..199cfcb 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -11,6 +11,7 @@
 
 struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
+	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
 	void		(*xpo_release_rqst)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ea3fa86..3cc945d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -839,9 +839,9 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = 1;
-	/* tcp needs a space for the record length... */
-	if (rqstp->rq_prot == IPPROTO_TCP)
-		svc_putnl(resv, 0);
+
+	/* Setup reply header */
+	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
 
 	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 44a729d..492a1dc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -893,12 +893,17 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static void svc_udp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1350,12 +1355,24 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+/*
+ * Setup response header. TCP has a 4B record length field.
+ */
+static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
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
 	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
