Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5A61C43444
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:46:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9C8B42176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:46:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725268AbeLXLqE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:46:04 -0500
Received: from relay.sw.ru ([185.231.240.75]:50710 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725864AbeLXLqD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:46:03 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOgL-0004aP-GA; Mon, 24 Dec 2018 14:46:01 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 07/10] sunrpc: remove unused xpo_prep_reply_hdr callback
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <a35cdd91-9482-a826-a4df-e7aef23ec8e5@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:46:00 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545648882.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

xpo_prep_reply_hdr are not used now.

It was defined for tcp transport only, however it cannot be
called indirectly, so let's move it to its caller and
remove unused callback.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 include/linux/sunrpc/svc_rdma.h          |  1 -
 include/linux/sunrpc/svc_xprt.h          |  1 -
 net/sunrpc/svc.c                         | 11 +++++++++++
 net/sunrpc/svcsock.c                     | 17 -----------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  4 ----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  1 -
 6 files changed, 11 insertions(+), 24 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index e6e26918504c..cc2f25a10dcf 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -192,7 +192,6 @@ extern int svc_rdma_sendto(struct svc_rqst *);
 extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
 extern void svc_sq_reap(struct svcxprt_rdma *);
 extern void svc_rq_reap(struct svcxprt_rdma *);
-extern void svc_rdma_prep_reply_hdr(struct svc_rqst *);
 
 extern struct svc_xprt_class svc_rdma_class;
 #ifdef CONFIG_SUNRPC_BACKCHANNEL
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 6b7a86c4d6e6..b3f9577e17d6 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -20,7 +20,6 @@ struct svc_xprt_ops {
 	struct svc_xprt	*(*xpo_accept)(struct svc_xprt *);
 	int		(*xpo_has_wspace)(struct svc_xprt *);
 	int		(*xpo_recvfrom)(struct svc_rqst *);
-	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
 	void		(*xpo_release_rqst)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index fb647bc01fc5..1e6701c065f9 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1144,6 +1144,17 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...) {}
 #endif
 
+/*
+ * Setup response header for TCP, it has a 4B record length field.
+ */
+static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+	struct kvec *resv = &rqstp->rq_res.head[0];
+
+	/* tcp needs a space for the record length... */
+	svc_putnl(resv, 0);
+}
+
 /*
  * Common routine for processing the RPC request.
  */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 19acf10dfca1..c7ae1ed5324f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -610,10 +610,6 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
-static void svc_udp_prep_reply_hdr(struct svc_rqst *rqstp)
-{
-}
-
 static int svc_udp_has_wspace(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
@@ -657,7 +653,6 @@ static const struct svc_xprt_ops svc_udp_ops = {
 	.xpo_release_rqst = svc_release_udp_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
-	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 	.xpo_has_wspace = svc_udp_has_wspace,
 	.xpo_accept = svc_udp_accept,
 	.xpo_secure_port = svc_sock_secure_port,
@@ -1163,17 +1158,6 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
-/*
- * Setup response header. TCP has a 4B record length field.
- */
-void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
-{
-	struct kvec *resv = &rqstp->rq_res.head[0];
-
-	/* tcp needs a space for the record length... */
-	svc_putnl(resv, 0);
-}
-
 static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
 				       struct net *net,
 				       struct sockaddr *sa, int salen,
@@ -1189,7 +1173,6 @@ static const struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_tcp_sock_detach,
 	.xpo_free = svc_sock_free,
-	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpo_has_wspace = svc_tcp_has_wspace,
 	.xpo_accept = svc_tcp_accept,
 	.xpo_secure_port = svc_sock_secure_port,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 8602a5f1b515..e8016c428890 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -741,10 +741,6 @@ static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 	return 0;
 }
 
-void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
-{
-}
-
 /**
  * svc_rdma_sendto - Transmit an RPC reply
  * @rqstp: processed RPC request, reply XDR already in ::rq_res
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 085933cc6b3e..924c17d46903 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -85,7 +85,6 @@ static const struct svc_xprt_ops svc_rdma_ops = {
 	.xpo_release_rqst = svc_rdma_release_rqst,
 	.xpo_detach = svc_rdma_detach,
 	.xpo_free = svc_rdma_free,
-	.xpo_prep_reply_hdr = svc_rdma_prep_reply_hdr,
 	.xpo_has_wspace = svc_rdma_has_wspace,
 	.xpo_accept = svc_rdma_accept,
 	.xpo_secure_port = svc_rdma_secure_port,
-- 
2.17.1

