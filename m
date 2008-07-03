From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 06/11] svcrdma: Remove unneeded spin locks from __svc_rdma_free
Date: Wed,  2 Jul 2008 21:27:38 -0500
Message-ID: <1215052063-7330-7-git-send-email-tom@opengridcomputing.com>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-2-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-3-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-4-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-5-git-send-email-tom@opengridcomputing.com>
 <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48837 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbYGCC1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jul 2008 22:27:45 -0400
In-Reply-To: <1215052063-7330-6-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At the time __svc_rdma_free is called, we are guaranteed that all references
to this transport are gone. There is, therefore, no need to protect the
resource lists with a spin lock.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6fddd58..7647789 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1027,7 +1027,6 @@ static void __svc_rdma_free(struct work_struct *work)
 	 * cm_id because the device ptr is needed to unmap the dma in
 	 * svc_rdma_put_context.
 	 */
-	spin_lock_bh(&rdma->sc_read_complete_lock);
 	while (!list_empty(&rdma->sc_read_complete_q)) {
 		struct svc_rdma_op_ctxt *ctxt;
 		ctxt = list_entry(rdma->sc_read_complete_q.next,
@@ -1036,10 +1035,8 @@ static void __svc_rdma_free(struct work_struct *work)
 		list_del_init(&ctxt->dto_q);
 		svc_rdma_put_context(ctxt, 1);
 	}
-	spin_unlock_bh(&rdma->sc_read_complete_lock);
 
 	/* Destroy queued, but not processed recv completions */
-	spin_lock_bh(&rdma->sc_rq_dto_lock);
 	while (!list_empty(&rdma->sc_rq_dto_q)) {
 		struct svc_rdma_op_ctxt *ctxt;
 		ctxt = list_entry(rdma->sc_rq_dto_q.next,
@@ -1048,7 +1045,6 @@ static void __svc_rdma_free(struct work_struct *work)
 		list_del_init(&ctxt->dto_q);
 		svc_rdma_put_context(ctxt, 1);
 	}
-	spin_unlock_bh(&rdma->sc_rq_dto_lock);
 
 	/* Warn if we leaked a resource or under-referenced */
 	WARN_ON(atomic_read(&rdma->sc_ctxt_used) != 0);
