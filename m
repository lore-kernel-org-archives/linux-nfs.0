Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34764 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752665AbdFTXgQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jun 2017 19:36:16 -0400
Received: by mail-it0-f67.google.com with SMTP id y134so4643906itc.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jun 2017 16:36:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Make slot allocation more reliable
Date: Tue, 20 Jun 2017 19:35:39 -0400
Message-Id: <20170620233539.22417-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170620233539.22417-4-trond.myklebust@primarydata.com>
References: <20170620233539.22417-1-trond.myklebust@primarydata.com>
 <20170620233539.22417-2-trond.myklebust@primarydata.com>
 <20170620233539.22417-3-trond.myklebust@primarydata.com>
 <20170620233539.22417-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In xprt_alloc_slot(), the spin lock is only needed to provide atomicity
between the atomic_add_unless() failure and the call to xprt_add_backlog().
We do not actually need to hold it across the memory allocation itself.

By dropping the lock, we can use a more resilient GFP_NOFS allocation,
just as we now do in the rest of the RPC client code.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprt.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3e63c5e97ebe..4654a9934269 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1047,13 +1047,15 @@ static bool xprt_throttle_congested(struct rpc_xprt *xprt, struct rpc_task *task
 	return ret;
 }
 
-static struct rpc_rqst *xprt_dynamic_alloc_slot(struct rpc_xprt *xprt, gfp_t gfp_flags)
+static struct rpc_rqst *xprt_dynamic_alloc_slot(struct rpc_xprt *xprt)
 {
 	struct rpc_rqst *req = ERR_PTR(-EAGAIN);
 
 	if (!atomic_add_unless(&xprt->num_reqs, 1, xprt->max_reqs))
 		goto out;
-	req = kzalloc(sizeof(struct rpc_rqst), gfp_flags);
+	spin_unlock(&xprt->reserve_lock);
+	req = kzalloc(sizeof(struct rpc_rqst), GFP_NOFS);
+	spin_lock(&xprt->reserve_lock);
 	if (req != NULL)
 		goto out;
 	atomic_dec(&xprt->num_reqs);
@@ -1081,7 +1083,7 @@ void xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
 		list_del(&req->rq_list);
 		goto out_init_req;
 	}
-	req = xprt_dynamic_alloc_slot(xprt, GFP_NOWAIT|__GFP_NOWARN);
+	req = xprt_dynamic_alloc_slot(xprt);
 	if (!IS_ERR(req))
 		goto out_init_req;
 	switch (PTR_ERR(req)) {
-- 
2.9.4

