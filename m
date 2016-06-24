Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36404 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFXO4b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:31 -0400
Received: by mail-io0-f196.google.com with SMTP id s63so16496465ioi.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/10] SUNRPC: Remove unused callback xpo_adjust_wspace()
Date: Fri, 24 Jun 2016 10:55:52 -0400
Message-Id: <1466780152-7154-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-9-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-8-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/svc_xprt.h | 1 -
 net/sunrpc/svc_xprt.c           | 2 --
 2 files changed, 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 555c004de51e..cb6e4037e590 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -25,7 +25,6 @@ struct svc_xprt_ops {
 	void		(*xpo_detach)(struct svc_xprt *);
 	void		(*xpo_free)(struct svc_xprt *);
 	int		(*xpo_secure_port)(struct svc_rqst *);
-	void		(*xpo_adjust_wspace)(struct svc_xprt *);
 };
 
 struct svc_xprt_class {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index cd26d0d9e41f..2503392b95ad 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -515,8 +515,6 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
 		rqstp->rq_reserved = space;
 
-		if (xprt->xpt_ops->xpo_adjust_wspace)
-			xprt->xpt_ops->xpo_adjust_wspace(xprt);
 		svc_xprt_enqueue(xprt);
 	}
 }
-- 
2.7.4

