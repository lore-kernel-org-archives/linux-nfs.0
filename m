Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86C3AC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59A3D2176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725497AbeLXLps (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:45:48 -0500
Received: from relay.sw.ru ([185.231.240.75]:50678 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725268AbeLXLps (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:45:48 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOg6-0004a2-8R; Mon, 24 Dec 2018 14:45:46 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 05/10] sunrpc: remove svc_tcp_bc_class
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <5f4e7c06-2fee-da2e-01ab-b7ff016c1d5c@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:45:46 +0300
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

Remove svc_xprt_class svc_tcp_bc_class and related functions

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/svcsock.c | 101 -------------------------------------------
 1 file changed, 101 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8ce181ecb627..19acf10dfca1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -70,13 +70,6 @@ static void		svc_sock_free(struct svc_xprt *);
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
 					  struct net *, struct sockaddr *,
 					  int, int);
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static struct svc_xprt *svc_bc_create_socket(struct svc_serv *, int,
-					     struct net *, struct sockaddr *,
-					     int, int);
-static void svc_bc_sock_free(struct svc_xprt *xprt);
-#endif /* CONFIG_SUNRPC_BACKCHANNEL */
-
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key svc_key[2];
 static struct lock_class_key svc_slock_key[2];
@@ -1189,58 +1182,6 @@ static struct svc_xprt *svc_tcp_create(struct svc_serv *serv,
 	return svc_create_socket(serv, IPPROTO_TCP, net, sa, salen, flags);
 }
 
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static struct svc_xprt *svc_bc_create_socket(struct svc_serv *, int,
-					     struct net *, struct sockaddr *,
-					     int, int);
-static void svc_bc_sock_free(struct svc_xprt *xprt);
-
-static struct svc_xprt *svc_bc_tcp_create(struct svc_serv *serv,
-				       struct net *net,
-				       struct sockaddr *sa, int salen,
-				       int flags)
-{
-	return svc_bc_create_socket(serv, IPPROTO_TCP, net, sa, salen, flags);
-}
-
-static void svc_bc_tcp_sock_detach(struct svc_xprt *xprt)
-{
-}
-
-static const struct svc_xprt_ops svc_tcp_bc_ops = {
-	.xpo_create = svc_bc_tcp_create,
-	.xpo_detach = svc_bc_tcp_sock_detach,
-	.xpo_free = svc_bc_sock_free,
-	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
-	.xpo_secure_port = svc_sock_secure_port,
-};
-
-static struct svc_xprt_class svc_tcp_bc_class = {
-	.xcl_name = "tcp-bc",
-	.xcl_owner = THIS_MODULE,
-	.xcl_ops = &svc_tcp_bc_ops,
-	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
-};
-
-static void svc_init_bc_xprt_sock(void)
-{
-	svc_reg_xprt_class(&svc_tcp_bc_class);
-}
-
-static void svc_cleanup_bc_xprt_sock(void)
-{
-	svc_unreg_xprt_class(&svc_tcp_bc_class);
-}
-#else /* CONFIG_SUNRPC_BACKCHANNEL */
-static void svc_init_bc_xprt_sock(void)
-{
-}
-
-static void svc_cleanup_bc_xprt_sock(void)
-{
-}
-#endif /* CONFIG_SUNRPC_BACKCHANNEL */
-
 static const struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_create = svc_tcp_create,
 	.xpo_recvfrom = svc_tcp_recvfrom,
@@ -1267,14 +1208,12 @@ void svc_init_xprt_sock(void)
 {
 	svc_reg_xprt_class(&svc_tcp_class);
 	svc_reg_xprt_class(&svc_udp_class);
-	svc_init_bc_xprt_sock();
 }
 
 void svc_cleanup_xprt_sock(void)
 {
 	svc_unreg_xprt_class(&svc_tcp_class);
 	svc_unreg_xprt_class(&svc_udp_class);
-	svc_cleanup_bc_xprt_sock();
 }
 
 static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
@@ -1595,43 +1534,3 @@ static void svc_sock_free(struct svc_xprt *xprt)
 		sock_release(svsk->sk_sock);
 	kfree(svsk);
 }
-
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-/*
- * Create a back channel svc_xprt which shares the fore channel socket.
- */
-static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
-					     int protocol,
-					     struct net *net,
-					     struct sockaddr *sin, int len,
-					     int flags)
-{
-	struct svc_sock *svsk;
-	struct svc_xprt *xprt;
-
-	if (protocol != IPPROTO_TCP) {
-		printk(KERN_WARNING "svc: only TCP sockets"
-			" supported on shared back channel\n");
-		return ERR_PTR(-EINVAL);
-	}
-
-	svsk = kzalloc(sizeof(*svsk), GFP_KERNEL);
-	if (!svsk)
-		return ERR_PTR(-ENOMEM);
-
-	xprt = &svsk->sk_xprt;
-	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
-	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
-
-	return xprt;
-}
-
-/*
- * Free a back channel svc_sock.
- */
-static void svc_bc_sock_free(struct svc_xprt *xprt)
-{
-	if (xprt)
-		kfree(container_of(xprt, struct svc_sock, sk_xprt));
-}
-#endif /* CONFIG_SUNRPC_BACKCHANNEL */
-- 
2.17.1

