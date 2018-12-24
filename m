Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2ED39C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 069BA2176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:45:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725446AbeLXLpI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:45:08 -0500
Received: from relay.sw.ru ([185.231.240.75]:50640 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725268AbeLXLpI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:45:08 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOfR-0004ZN-FU; Mon, 24 Dec 2018 14:45:05 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 03/10] sunrpc: replace svc_serv->sv_bc_xprt by boolean flag
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <3105562e-fbac-432d-f95a-7f87c5a2551a@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:45:04 +0300
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

svc_serv-> sv_bc_xprt is netns-unsafe and cannot be used as pointer.
To prevent its misuse in future it is replaced by new boolean flag.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/callback.c                        |  8 +++++---
 include/linux/sunrpc/bc_xprt.h           | 10 ++++------
 include/linux/sunrpc/svc.h               |  2 +-
 net/sunrpc/svcsock.c                     |  2 --
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  1 -
 5 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 509dc5adeb8f..6dd04774aedc 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -206,11 +206,13 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 		goto err_bind;
 	}
 
-	ret = -EPROTONOSUPPORT;
+	ret = 0;
 	if (!IS_ENABLED(CONFIG_NFS_V4_1) || minorversion == 0)
 		ret = nfs4_callback_up_net(serv, net);
-	else if (xprt->ops->bc_up)
-		ret = xprt->ops->bc_up(serv, net);
+	else if (xprt->ops->bc_setup)
+		serv->sv_bc_enabled = true;
+	else
+		ret = -EPROTONOSUPPORT;
 
 	if (ret < 0) {
 		printk(KERN_ERR "NFS: callback service start failed\n");
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
index fdb6b317d974..e52385340b3b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -109,7 +109,7 @@ struct svc_serv {
 	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
 	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
 						 * entries in the svc_cb_list */
-	struct svc_xprt		*sv_bc_xprt;	/* callback on fore channel */
+	bool			sv_bc_enabled;	/* service uses backchannel */
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 };
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 793149ba1bda..8ce181ecb627 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1623,8 +1623,6 @@ static struct svc_xprt *svc_bc_create_socket(struct svc_serv *serv,
 	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 
-	serv->sv_bc_xprt = xprt;
-
 	return xprt;
 }
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 2f7ec8912f49..d410e6f34f44 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -136,7 +136,6 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
 
 	svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
 	set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
-	serv->sv_bc_xprt = xprt;
 
 	dprintk("svcrdma: %s(%p)\n", __func__, xprt);
 	return xprt;
-- 
2.17.1

