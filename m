From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/24] SUNRPC: Sanity check incoming UDP datagram lengths
	properly
Date: Mon, 14 Apr 2008 12:27:23 -0400
Message-ID: <20080414162723.12741.35500.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:49652 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759698AbYDNQ1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:27:50 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: ensure svc_udp_recvfrom() is getting at least a full UDP header
to avoid potential negative intermediate values.

A similar sanity check is already used in the RPC client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d077071..de29e7f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -431,6 +431,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	} buffer;
 	struct cmsghdr *cmh = &buffer.hdr;
 	int		err, len;
+	unsigned int	bytes;
 	struct msghdr msg = {
 		.msg_name = svc_addr(rqstp),
 		.msg_control = cmh,
@@ -484,8 +485,13 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	 */
 	svc_xprt_received(&svsk->sk_xprt);
 
-	len  = skb->len - sizeof(struct udphdr);
-	rqstp->rq_arg.len = len;
+	if (skb->len < sizeof(struct udphdr)) {
+		dprintk("svc: bad UDP datagram length: %u\n", skb->len);
+		skb_free_datagram(svsk->sk_sk, skb);
+		return 0;
+	}
+	bytes = skb->len - sizeof(struct udphdr);
+	rqstp->rq_arg.len = bytes;
 
 	rqstp->rq_prot = IPPROTO_UDP;
 
@@ -515,7 +521,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* we can use it in-place */
 		rqstp->rq_arg.head[0].iov_base = skb->data +
 			sizeof(struct udphdr);
-		rqstp->rq_arg.head[0].iov_len = len;
+		rqstp->rq_arg.head[0].iov_len = bytes;
 		if (skb_checksum_complete(skb)) {
 			skb_free_datagram(svsk->sk_sk, skb);
 			return 0;
@@ -524,12 +530,12 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 
 	rqstp->rq_arg.page_base = 0;
-	if (len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = len;
+	if (bytes <= rqstp->rq_arg.head[0].iov_len) {
+		rqstp->rq_arg.head[0].iov_len = bytes;
 		rqstp->rq_arg.page_len = 0;
 		rqstp->rq_respages = rqstp->rq_pages+1;
 	} else {
-		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
+		rqstp->rq_arg.page_len = bytes - rqstp->rq_arg.head[0].iov_len;
 		rqstp->rq_respages = rqstp->rq_pages + 1 +
 			DIV_ROUND_UP(rqstp->rq_arg.page_len, PAGE_SIZE);
 	}
@@ -537,7 +543,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;
 
-	return len;
+	return bytes;
 }
 
 static int

