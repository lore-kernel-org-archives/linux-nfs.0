From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfs41: sunrpc: xprt_alloc_bc_request() should not use spin_lock_bh()
Date: Thu, 18 Jun 2009 22:01:24 -0400
Message-ID: <1245376884-3711-2-git-send-email-bhalevy@panasas.com>
References: <1245376884-3711-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from linux-nfs.citi.umich.edu ([141.211.133.37]:58951 "EHLO
	linux-nfs.citi.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbZFSCL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 22:11:56 -0400
In-Reply-To: <1245376884-3711-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

xprt_alloc_bc_request() is always called in soft interrupt context.
Grab the spin_lock instead of the bottom half spin_lock.  Softirqs
do not preempt other softirqs running on the same processor, so there
is no need to disable bottom halves.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/backchannel_rqst.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 5a7d342..553621f 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -211,6 +211,9 @@ EXPORT_SYMBOL(xprt_destroy_backchannel);
  * has been preallocated as well.  Use xprt_alloc_bc_request to allocate
  * to this request.  Use xprt_free_bc_request to return it.
  *
+ * We know that we're called in soft interrupt context, grab the spin_lock
+ * since there is no need to grab the bottom half spin_lock.
+ *
  * Return an available rpc_rqst, otherwise NULL if non are available.
  */
 struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt)
@@ -218,7 +221,7 @@ struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt)
 	struct rpc_rqst *req;
 
 	dprintk("RPC:       allocate a backchannel request\n");
-	spin_lock_bh(&xprt->bc_pa_lock);
+	spin_lock(&xprt->bc_pa_lock);
 	if (!list_empty(&xprt->bc_pa_list)) {
 		req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
 				rq_bc_pa_list);
@@ -226,7 +229,7 @@ struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt)
 	} else {
 		req = NULL;
 	}
-	spin_unlock_bh(&xprt->bc_pa_lock);
+	spin_unlock(&xprt->bc_pa_lock);
 
 	if (req != NULL) {
 		set_bit(RPC_BC_PA_IN_USE, &req->rq_bc_pa_state);
-- 
1.6.3.1

