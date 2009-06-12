From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 07/14] SQUASHME: Rename variable
Date: Thu, 11 Jun 2009 22:54:13 -0700
Message-ID: <1244786060-2200-8-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39089 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869AbZFLF6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:10 -0400
In-Reply-To: <1244786060-2200-7-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: Add backchannel processing support to RPC state machine]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/xprt.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a8c6e8c..23c623b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1002,11 +1002,14 @@ void xprt_release(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
-	int prealloc;
+	int is_bc_request;
 
 	if (!(req = task->tk_rqstp))
 		return;
-	prealloc = bc_prealloc(req);	/* Preallocated backchannel request? */
+
+	/* Preallocated backchannel request? */
+	is_bc_request = bc_prealloc(req);
+
 	xprt = req->rq_xprt;
 	rpc_count_iostats(task);
 	spin_lock_bh(&xprt->transport_lock);
@@ -1030,7 +1033,7 @@ void xprt_release(struct rpc_task *task)
 	 * Early exit if this is a backchannel preallocated request.
 	 * There is no need to have it added to the RPC slot list.
 	 */
-	if (prealloc)
+	if (is_bc_request)
 		return;
 
 	memset(req, 0, sizeof(*req));	/* mark unused */
-- 
1.5.4.3

