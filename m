Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E8D8C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:25:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 55FBF20874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:25:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388244AbeLQQZG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:25:06 -0500
Received: from relay.sw.ru ([185.231.240.75]:51830 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388148AbeLQQZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 11:25:06 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gYvhW-00010I-DY; Mon, 17 Dec 2018 19:25:02 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 2/4] nfs: remove sv_bc_enabled using in svc_is_backchannel()
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
Message-ID: <7b17745f-478b-affa-de7c-98d70a5431cb@virtuozzo.com>
Date:   Mon, 17 Dec 2018 19:25:01 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

serv->sv_bc_xprt cannot be used as pointer,
serv is global structure, but sv_bc_xprt is assigned per-netnamespace

The only user of this field is svc_is_backchannel() where it is used
not as pointer but as mark of backchannel-compatible servers. 

Convert netns-unsafe xprt pointer to simple boolean mark,
Hope it helps to prevent misuse of sv_bc_xpr in future. 

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 include/linux/sunrpc/bc_xprt.h           | 10 ++++------
 include/linux/sunrpc/svc.h               |  2 +-
 net/sunrpc/svcsock.c                     |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 +-
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 28721cf73ec3..4e8c773d02be 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -47,11 +47,9 @@ void xprt_free_bc_rqst(struct rpc_rqst *req);
 /*
  * Determine if a shared backchannel is in use
  */
-static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
+static inline bool svc_is_backchannel(const struct svc_rqst *rqstp)
 {
-	if (rqstp->rq_server->sv_bc_xprt)
-		return 1;
-	return 0;
+	return rqstp->rq_server->sv_bc_enabled;
 }
 #else /* CONFIG_SUNRPC_BACKCHANNEL */
 static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
@@ -60,9 +58,9 @@ static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
 	return 0;
 }
 
-static inline int svc_is_backchannel(const struct svc_rqst *rqstp)
+static inline bool svc_is_backchannel(const struct svc_rqst *rqstp)
 {
-	return 0;
+	return false;
 }
 
 static inline void xprt_free_bc_request(struct rpc_rqst *req)
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 73e130a840ce..bf21609160c1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -109,7 +109,7 @@ struct svc_serv {
 	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
 	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
 						 * entries in the svc_cb_list */
-	struct svc_xprt		*sv_bc_xprt;	/* callback on fore channel */
+	bool			sv_bc_enabled;	/* server uses backchannel */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 };
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 986f3ed7d1a2..5a6b3ba555c7 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1623,7 +1623,7 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 
-	serv->sv_bc_xprt = xprt;
+	serv->sv_bc_enabled = true;
 
 	return xprt;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 2f7ec8912f49..88694048d5c0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -136,7 +136,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
 
 	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
 	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
-	serv->sv_bc_xprt = xprt;
+	serv->sv_bc_enabled = true;
 
 	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
 	return xprt;
-- 
2.17.1

