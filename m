Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:53624 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031408AbeCSSXU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2018 14:23:20 -0400
Subject: [PATCH] xprtrdma: Fix corner cases when handling device removal
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org
Date: Mon, 19 Mar 2018 14:23:16 -0400
Message-ID: <20180319182316.3060.7675.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Michal Kalderon has found some corner cases around device unload
with active NFS mounts that I didn't have the imagination to test
when xprtrdma device removal was added last year.

- The ULP device removal handler is responsible for deallocating
  the PD. That wasn't clear to me initially, and my own testing
  suggested it was not necessary, but that is incorrect.

- The transport destruction path can no longer assume that there
  is a valid ID.

- When destroying a transport, ensure that ib_free_cq() is not
  invoked on a CQ that was already released.

Reported-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Fixes: bebd031866ca ("xprtrdma: Support unplugging an HCA from ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org
---
 net/sunrpc/xprtrdma/verbs.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fe518b3..5e3afed 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -250,7 +250,6 @@
 		wait_for_completion(&ia->ri_remove_done);
 
 		ia->ri_id = NULL;
-		ia->ri_pd = NULL;
 		ia->ri_device = NULL;
 		/* Return 1 to ensure the core destroys the id. */
 		return 1;
@@ -448,7 +447,9 @@
 		ia->ri_id->qp = NULL;
 	}
 	ib_free_cq(ep->rep_attr.recv_cq);
+	ep->rep_attr.recv_cq = NULL;
 	ib_free_cq(ep->rep_attr.send_cq);
+	ep->rep_attr.send_cq = NULL;
 
 	/* The ULP is responsible for ensuring all DMA
 	 * mappings and MRs are gone.
@@ -461,6 +462,8 @@
 		rpcrdma_dma_unmap_regbuf(req->rl_recvbuf);
 	}
 	rpcrdma_mrs_destroy(buf);
+	ib_dealloc_pd(ia->ri_pd);
+	ia->ri_pd = NULL;
 
 	/* Allow waiters to continue */
 	complete(&ia->ri_remove_done);
@@ -628,14 +631,16 @@
 {
 	cancel_delayed_work_sync(&ep->rep_connect_worker);
 
-	if (ia->ri_id->qp) {
+	if (ia->ri_id && ia->ri_id->qp) {
 		rpcrdma_ep_disconnect(ep, ia);
 		rdma_destroy_qp(ia->ri_id);
 		ia->ri_id->qp = NULL;
 	}
 
-	ib_free_cq(ep->rep_attr.recv_cq);
-	ib_free_cq(ep->rep_attr.send_cq);
+	if (ep->rep_attr.recv_cq)
+		ib_free_cq(ep->rep_attr.recv_cq);
+	if (ep->rep_attr.send_cq)
+		ib_free_cq(ep->rep_attr.send_cq);
 }
 
 /* Re-establish a connection after a device removal event.

