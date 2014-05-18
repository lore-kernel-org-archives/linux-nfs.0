Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:57326 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaERSFY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 May 2014 14:05:24 -0400
Received: by mail-ig0-f176.google.com with SMTP id hl10so2631732igb.3
        for <linux-nfs@vger.kernel.org>; Sun, 18 May 2014 11:05:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix a module reference leak in svc_handle_xprt
Date: Sun, 18 May 2014 14:05:22 -0400
Message-Id: <1400436322-5014-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the accept() call fails, we need to put the module reference.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 06c6ff0cb911..a4acaf2bcf18 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -730,6 +730,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt)
 			svc_add_new_temp_xprt(serv, newxpt);
+		else
+			module_put(xprt->xpt_class->xcl_owner);
 	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
 		/* XPT_DATA|XPT_DEFERRED case: */
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
-- 
1.9.0

