From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 04/40] svc: Add a max payload value to the transport
Date: Sun, 30 Dec 2007 21:07:21 -0600
Message-ID: <20071231030721.8430.58735.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41475 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752218AbXLaDHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:21 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The svc_max_payload function currently looks at the socket type
to determine the max payload. Add a max payload value to svc_xprt_class
so it can be returned directly. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc.c                |    4 +---
 net/sunrpc/svcsock.c            |    2 ++
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index fe8e787..187dc4e 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -17,6 +17,7 @@ struct svc_xprt_class {
 	struct module		*xcl_owner;
 	struct svc_xprt_ops	*xcl_ops;
 	struct list_head	xcl_list;
+	u32			xcl_max_payload;
 };
 
 struct svc_xprt {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a4a6bf7..ea3fa86 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1054,10 +1054,8 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = RPCSVC_MAXPAYLOAD_TCP;
+	u32 max = rqstp->rq_xprt->xpt_class->xcl_max_payload;
 
-	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
-		max = RPCSVC_MAXPAYLOAD_UDP;
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
 	return max;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 54f1b3d..c507f6f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -906,6 +906,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 static struct svc_xprt_class svc_udp_class = {
 	.xcl_name = "udp",
 	.xcl_ops = &svc_udp_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
 
 static void
@@ -1359,6 +1360,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 static struct svc_xprt_class svc_tcp_class = {
 	.xcl_name = "tcp",
 	.xcl_ops = &svc_tcp_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
 void svc_init_xprt_sock(void)
