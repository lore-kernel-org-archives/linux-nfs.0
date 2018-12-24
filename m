Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D01DCC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A16582176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725863AbeLXLp4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:45:56 -0500
Received: from relay.sw.ru ([185.231.240.75]:50696 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725268AbeLXLp4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:45:56 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOgD-0004aC-Hz; Mon, 24 Dec 2018 14:45:53 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 06/10] sunrpc: remove svc_rdma_bc_class
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <a732a893-07ab-372f-0381-582a36d85b1a@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:45:53 +0300
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

Remove svc_xprt_class svc_rdma_bc_class and related functions.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/xprtrdma/svc_rdma.c           |  6 ---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 57 ------------------------
 2 files changed, 63 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 134bef6a451e..abdb3004a1e3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -235,9 +235,6 @@ void svc_rdma_cleanup(void)
 		unregister_sysctl_table(svcrdma_table_header);
 		svcrdma_table_header = NULL;
 	}
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-	svc_unreg_xprt_class(&svc_rdma_bc_class);
-#endif
 	svc_unreg_xprt_class(&svc_rdma_class);
 }
 
@@ -259,8 +256,5 @@ int svc_rdma_init(void)
 
 	/* Register RDMA with the SVC transport switch */
 	svc_reg_xprt_class(&svc_rdma_class);
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-	svc_reg_xprt_class(&svc_rdma_bc_class);
-#endif
 	return 0;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index d410e6f34f44..085933cc6b3e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -100,63 +100,6 @@ struct svc_xprt_class svc_rdma_class = {
 	.xcl_ident = XPRT_TRANSPORT_RDMA,
 };
 
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *, struct net *,
-					   struct sockaddr *, int, int);
-static void svc_rdma_bc_detach(struct svc_xprt *);
-static void svc_rdma_bc_free(struct svc_xprt *);
-
-static const struct svc_xprt_ops svc_rdma_bc_ops = {
-	.xpo_create = svc_rdma_bc_create,
-	.xpo_detach = svc_rdma_bc_detach,
-	.xpo_free = svc_rdma_bc_free,
-	.xpo_prep_reply_hdr = svc_rdma_prep_reply_hdr,
-	.xpo_secure_port = svc_rdma_secure_port,
-};
-
-struct svc_xprt_class svc_rdma_bc_class = {
-	.xcl_name = "rdma-bc",
-	.xcl_owner = THIS_MODULE,
-	.xcl_ops = &svc_rdma_bc_ops,
-	.xcl_max_payload = (1024 - RPCRDMA_HDRLEN_MIN)
-};
-
-static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
-					   struct net *net,
-					   struct sockaddr *sa, int salen,
-					   int flags)
-{
-	struct svcxprt_rdma *cma_xprt;
-	struct svc_xprt *xprt;
-
-	cma_xprt = svc_rdma_create_xprt(serv, net);
-	if (!cma_xprt)
-		return ERR_PTR(-ENOMEM);
-	xprt = &cma_xprt->sc_xprt;
-
-	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
-	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
-
-	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
-	return xprt;
-}
-
-static void svc_rdma_bc_detach(struct svc_xprt *xprt)
-{
-	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
-}
-
-static void svc_rdma_bc_free(struct svc_xprt *xprt)
-{
-	struct svcxprt_rdma *rdma =
-		container_of(xprt, struct svcxprt_rdma, sc_xprt);
-
-	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
-	if (xprt)
-		kfree(rdma);
-}
-#endif	/* CONFIG_SUNRPC_BACKCHANNEL */
-
 /* QP event handler */
 static void qp_event_handler(struct ib_event *event, void *context)
 {
-- 
2.17.1

