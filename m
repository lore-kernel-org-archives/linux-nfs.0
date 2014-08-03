Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:50498 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaHCRDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:20 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so5995412qac.30
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:19 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/11] SUNRPC: Do not override wspace tests in svc_handle_xprt
Date: Sun,  3 Aug 2014 13:03:06 -0400
Message-Id: <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already determined that there was enough wspace when we
called svc_xprt_enqueue.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 32647b2a6a34..b731077b6a30 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -744,7 +744,7 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 			svc_add_new_temp_xprt(serv, newxpt);
 		else
 			module_put(xprt->xpt_class->xcl_owner);
-	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
+	} else {
 		/* XPT_DATA|XPT_DEFERRED case: */
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
 			rqstp, rqstp->rq_pool->sp_id, xprt,
-- 
1.9.3

