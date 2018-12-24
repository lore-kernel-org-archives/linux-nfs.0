Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E60E9C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE6EA2176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725616AbeLXLp2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:45:28 -0500
Received: from relay.sw.ru ([185.231.240.75]:50660 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725268AbeLXLp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:45:28 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOfl-0004Zh-JT; Mon, 24 Dec 2018 14:45:25 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 04/10] sunrpc: remove unused bc_up operation from
 rpc_xprt_ops
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <8df076d6-1f35-f3f6-9b04-cc3c33ec2e27@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:45:25 +0300
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

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 include/linux/sunrpc/xprt.h       |  1 -
 net/sunrpc/xprtrdma/backchannel.c | 20 --------------------
 net/sunrpc/xprtrdma/transport.c   |  1 -
 net/sunrpc/xprtrdma/xprt_rdma.h   |  1 -
 net/sunrpc/xprtsock.c             | 12 ------------
 5 files changed, 35 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a4ab4f8d9140..ad7e910b119d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -157,7 +157,6 @@ struct rpc_xprt_ops {
 	void		(*inject_disconnect)(struct rpc_xprt *xprt);
 	int		(*bc_setup)(struct rpc_xprt *xprt,
 				    unsigned int min_reqs);
-	int		(*bc_up)(struct svc_serv *serv, struct net *net);
 	size_t		(*bc_maxpayload)(struct rpc_xprt *xprt);
 	void		(*bc_free_rqst)(struct rpc_rqst *rqst);
 	void		(*bc_destroy)(struct rpc_xprt *xprt,
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a3e517..edba0d35776b 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -113,26 +113,6 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 	return -ENOMEM;
 }
 
-/**
- * xprt_rdma_bc_up - Create transport endpoint for backchannel service
- * @serv: server endpoint
- * @net: network namespace
- *
- * The "xprt" is an implied argument: it supplies the name of the
- * backchannel transport class.
- *
- * Returns zero on success, negative errno on failure
- */
-int xprt_rdma_bc_up(struct svc_serv *serv, struct net *net)
-{
-	int ret;
-
-	ret = svc_create_xprt(serv, "rdma-bc", net, PF_INET, 0, 0);
-	if (ret < 0)
-		return ret;
-	return 0;
-}
-
 /**
  * xprt_rdma_bc_maxpayload - Return maximum backchannel message size
  * @xprt: transport
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ae2a83828953..9141068693fa 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -827,7 +827,6 @@ static const struct rpc_xprt_ops xprt_rdma_procs = {
 	.inject_disconnect	= xprt_rdma_inject_disconnect,
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 	.bc_setup		= xprt_rdma_bc_setup,
-	.bc_up			= xprt_rdma_bc_up,
 	.bc_maxpayload		= xprt_rdma_bc_maxpayload,
 	.bc_free_rqst		= xprt_rdma_bc_free_rqst,
 	.bc_destroy		= xprt_rdma_bc_destroy,
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a13ccb643ce0..9218dbebedce 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -661,7 +661,6 @@ void xprt_rdma_cleanup(void);
  */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
-int xprt_rdma_bc_up(struct svc_serv *, struct net *);
 size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *);
 int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
 void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8a5e823e0b33..a51152af8780 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1400,17 +1400,6 @@ static void xs_tcp_force_close(struct rpc_xprt *xprt)
 }
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
-{
-	int ret;
-
-	ret = svc_create_xprt(serv, "tcp-bc", net, PF_INET, 0,
-			      SVC_SOCK_ANONYMOUS);
-	if (ret < 0)
-		return ret;
-	return 0;
-}
-
 static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
 {
 	return PAGE_SIZE;
@@ -2667,7 +2656,6 @@ static const struct rpc_xprt_ops xs_tcp_ops = {
 	.inject_disconnect	= xs_inject_disconnect,
 #ifdef CONFIG_SUNRPC_BACKCHANNEL
 	.bc_setup		= xprt_setup_bc,
-	.bc_up			= xs_tcp_bc_up,
 	.bc_maxpayload		= xs_tcp_bc_maxpayload,
 	.bc_free_rqst		= xprt_free_bc_rqst,
 	.bc_destroy		= xprt_destroy_bc,
-- 
2.17.1

