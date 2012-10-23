Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:11983 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745Ab2JWOxO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:14 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 09/25] SUNRPC: remove two BUG_ON asserts
Date: Tue, 23 Oct 2012 10:43:33 -0400
Message-Id: <1351003429-18887-10-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace two BUG_ON() calls checking the RPC_BC_PA_IN_USE flag with
WARN_ON_ONCE().

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/backchannel_rqst.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 5a3d675..7567bcd 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -59,7 +59,7 @@ static void xprt_free_allocation(struct rpc_rqst *req)
 	struct xdr_buf *xbufp;
 
 	dprintk("RPC:        free allocations for req= %p\n", req);
-	BUG_ON(test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
+	WARN_ON_ONCE(test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
 	xbufp = &req->rq_private_buf;
 	free_page((unsigned long)xbufp->head[0].iov_base);
 	xbufp = &req->rq_snd_buf;
@@ -255,7 +255,7 @@ void xprt_free_bc_request(struct rpc_rqst *req)
 	dprintk("RPC:       free backchannel req=%p\n", req);
 
 	smp_mb__before_clear_bit();
-	BUG_ON(!test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
+	WARN_ON_ONCE(!test_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state));
 	clear_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
 	smp_mb__after_clear_bit();
 
-- 
1.7.9.6 (Apple Git-31.1)

