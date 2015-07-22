Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35483 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbbGVVM6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 17:12:58 -0400
Received: by iecri3 with SMTP id ri3so82490799iec.2
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 14:12:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] SUNRPC: xprt_complete_bc_request must also decrement the free slot count
Date: Wed, 22 Jul 2015 17:12:55 -0400
Message-Id: <1437599575-25281-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1437599575-25281-1-git-send-email-trond.myklebust@primarydata.com>
References: <1437599575-25281-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling xprt_complete_bc_request() effectively causes the slot to be allocated,
so it needs to decrement the backchannel free slot count as well.

Fixes: 0d2a970d0ae5 ("SUNRPC: Fix a backchannel race")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/backchannel_rqst.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 5a3b50aec397..6255d141133b 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -336,7 +336,7 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied)
 
 	spin_lock(&xprt->bc_pa_lock);
 	list_del(&req->rq_bc_pa_list);
-	xprt->bc_alloc_count--;
+	xprt_dec_alloc_count(xprt, 1);
 	spin_unlock(&xprt->bc_pa_lock);
 
 	req->rq_private_buf.len = copied;
-- 
2.4.3

