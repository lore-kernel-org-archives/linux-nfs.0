Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:53285 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197AbaBKTnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 14:43:33 -0500
Received: by mail-ig0-f176.google.com with SMTP id j1so9538142iga.3
        for <linux-nfs@vger.kernel.org>; Tue, 11 Feb 2014 11:43:33 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix potential memory scribble in xprt_free_bc_request()
Date: Tue, 11 Feb 2014 14:43:30 -0500
Message-Id: <1392147810-23405-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The call to xprt_free_allocation() will call list_del() on
req->rq_bc_pa_list, which is not attached to a list.
This patch moves the list_del() out of xprt_free_allocation()
and into those callers that need it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/backchannel_rqst.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 890a29912d5a..e860d4f7ed2a 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -64,7 +64,6 @@ static void xprt_free_allocation(struct rpc_rqst *req)
 	free_page((unsigned long)xbufp->head[0].iov_base);
 	xbufp = &req->rq_snd_buf;
 	free_page((unsigned long)xbufp->head[0].iov_base);
-	list_del(&req->rq_bc_pa_list);
 	kfree(req);
 }
 
@@ -168,8 +167,10 @@ out_free:
 	/*
 	 * Memory allocation failed, free the temporary list
 	 */
-	list_for_each_entry_safe(req, tmp, &tmp_list, rq_bc_pa_list)
+	list_for_each_entry_safe(req, tmp, &tmp_list, rq_bc_pa_list) {
+		list_del(&req->rq_bc_pa_list);
 		xprt_free_allocation(req);
+	}
 
 	dprintk("RPC:       setup backchannel transport failed\n");
 	return -ENOMEM;
@@ -198,6 +199,7 @@ void xprt_destroy_backchannel(struct rpc_xprt *xprt, unsigned int max_reqs)
 	xprt_dec_alloc_count(xprt, max_reqs);
 	list_for_each_entry_safe(req, tmp, &xprt->bc_pa_list, rq_bc_pa_list) {
 		dprintk("RPC:        req=%p\n", req);
+		list_del(&req->rq_bc_pa_list);
 		xprt_free_allocation(req);
 		if (--max_reqs == 0)
 			break;
-- 
1.8.5.3

