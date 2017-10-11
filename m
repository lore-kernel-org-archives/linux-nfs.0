Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:43301 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757764AbdJKSBi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Oct 2017 14:01:38 -0400
Received: by mail-it0-f65.google.com with SMTP id k70so11181230itk.0
        for <linux-nfs@vger.kernel.org>; Wed, 11 Oct 2017 11:01:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Remove redundant call to cancel_work_sync() in xprt_destroy()
Date: Wed, 11 Oct 2017 14:01:34 -0400
Message-Id: <20171011180134.52476-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We know that the socket autoclose cannot be queued after we've set
the XPRT_LOCKED bit, so the call to cancel_work_sync() is redundant.
In addition, it is causing lockdep to complain about a false ABA
lock dependency.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e741ec2b4d8e..5f12fe145f02 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1464,7 +1464,6 @@ static void xprt_destroy(struct rpc_xprt *xprt)
 	rpc_destroy_wait_queue(&xprt->pending);
 	rpc_destroy_wait_queue(&xprt->sending);
 	rpc_destroy_wait_queue(&xprt->backlog);
-	cancel_work_sync(&xprt->task_cleanup);
 	kfree(xprt->servername);
 	/*
 	 * Tear down transport state and free the rpc_xprt
-- 
2.13.6

