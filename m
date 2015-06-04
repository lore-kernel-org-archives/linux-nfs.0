Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36530 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbbFDV04 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 17:26:56 -0400
Received: by igbpi8 with SMTP id pi8so1208347igb.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 14:26:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] SUNRPC: Fix a memory leak in the backchannel code
Date: Thu,  4 Jun 2015 17:26:48 -0400
Message-Id: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

req->rq_private_buf isn't initialised when xprt_setup_backchannel calls
xprt_free_allocation.

Fixes: fb7a0b9addbdb ("nfs41: New backchannel helper routines")
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/backchannel_rqst.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 9dd0ea8db463..28504dfd3dad 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -60,7 +60,7 @@ static void xprt_free_allocation(struct rpc_rqst *req)
 
 	dprintk("RPC:        free allocations for req= %p\n", req);
 	WARN_ON_ONCE(test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
-	xbufp = &req->rq_private_buf;
+	xbufp = &req->rq_rcv_buf;
 	free_page((unsigned long)xbufp->head[0].iov_base);
 	xbufp = &req->rq_snd_buf;
 	free_page((unsigned long)xbufp->head[0].iov_base);
-- 
2.4.2

