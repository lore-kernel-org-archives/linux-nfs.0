Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:56104 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdJMSQR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Oct 2017 14:16:17 -0400
Received: by mail-it0-f66.google.com with SMTP id l196so11540788itl.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Oct 2017 11:16:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Emre Celebi <emre@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: fix a list corruption issue in xprt_release()
Date: Fri, 13 Oct 2017 14:16:12 -0400
Message-Id: <20171013181612.14176-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We remove the request from the receive list before we call
xprt_wait_on_pinned_rqst(), and so we need to use list_del_init().
Otherwise, we will see list corruption when xprt_complete_rqst()
is called.

Reported-by: Emre Celebi <emre@primarydata.com>
Fixes: ce7c252a8c741 ("SUNRPC: Add a separate spinlock to protect...")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5f12fe145f02..a61c99ff0a39 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1333,7 +1333,7 @@ void xprt_release(struct rpc_task *task)
 		rpc_count_iostats(task, task->tk_client->cl_metrics);
 	spin_lock(&xprt->recv_lock);
 	if (!list_empty(&req->rq_list)) {
-		list_del(&req->rq_list);
+		list_del_init(&req->rq_list);
 		xprt_wait_on_pinned_rqst(req);
 	}
 	spin_unlock(&xprt->recv_lock);
-- 
2.13.6

