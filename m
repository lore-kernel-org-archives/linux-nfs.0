Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14548 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755421Ab2JWOxf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:35 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 10/25] SUNRPC: remove BUG_ON from xprt_destroy_backchannel
Date: Tue, 23 Oct 2012 10:43:34 -0400
Message-Id: <1351003429-18887-11-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If max_reqs is 0, do nothing besides the usual dprintks.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/backchannel_rqst.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 7567bcd..f0fb0dd 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -191,7 +191,9 @@ void xprt_destroy_backchannel(struct rpc_xprt *xprt, unsigned int max_reqs)
 
 	dprintk("RPC:        destroy backchannel transport\n");
 
-	BUG_ON(max_reqs == 0);
+	if (max_reqs == 0)
+		goto out;
+
 	spin_lock_bh(&xprt->bc_pa_lock);
 	xprt_dec_alloc_count(xprt, max_reqs);
 	list_for_each_entry_safe(req, tmp, &xprt->bc_pa_list, rq_bc_pa_list) {
@@ -202,6 +204,7 @@ void xprt_destroy_backchannel(struct rpc_xprt *xprt, unsigned int max_reqs)
 	}
 	spin_unlock_bh(&xprt->bc_pa_lock);
 
+out:
 	dprintk("RPC:        backchannel list empty= %s\n",
 		list_empty(&xprt->bc_pa_list) ? "true" : "false");
 }
-- 
1.7.9.6 (Apple Git-31.1)

