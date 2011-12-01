Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33942 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756199Ab1LATUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 14:20:38 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Ensure we always bump the backlog queue in xprt_free_slot
Date: Thu,  1 Dec 2011 14:20:17 -0500
Message-Id: <1322767217-11539-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1322767217-11539-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1322767217-11539-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whenever we free a slot, we know that the resulting xprt->num_reqs will
be less than xprt->max_reqs, so we know that we can release at least one
backlogged rpc_task.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org [>=3.1]
---
 net/sunrpc/xprt.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f4385e4..c64c0ef 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -995,13 +995,11 @@ out_init_req:
 
 static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
 {
-	if (xprt_dynamic_free_slot(xprt, req))
-		return;
-
-	memset(req, 0, sizeof(*req));	/* mark unused */
-
 	spin_lock(&xprt->reserve_lock);
-	list_add(&req->rq_list, &xprt->free);
+	if (!xprt_dynamic_free_slot(xprt, req)) {
+		memset(req, 0, sizeof(*req));	/* mark unused */
+		list_add(&req->rq_list, &xprt->free);
+	}
 	rpc_wake_up_next(&xprt->backlog);
 	spin_unlock(&xprt->reserve_lock);
 }
-- 
1.7.7.3

