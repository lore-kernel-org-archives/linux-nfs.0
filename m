Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33090 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670AbcF2RwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jun 2016 13:52:15 -0400
Subject: [PATCH v4 01/24] xprtrdma: Remove FMRs from the unmap list after
 unmapping
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 29 Jun 2016 13:52:12 -0400
Message-ID: <20160629175212.15094.42098.stgit@manet.1015granger.net>
In-Reply-To: <20160629173231.15094.52660.stgit@manet.1015granger.net>
References: <20160629173231.15094.52660.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ib_unmap_fmr() takes a list of FMRs to unmap. However, it does not
remove the FMRs from this list as it processes them. Other
ib_unmap_fmr() call sites are careful to remove FMRs from the list
after ib_unmap_fmr() returns.

Since commit 7c7a5390dc6c8 ("xprtrdma: Add ro_unmap_sync method for FMR")
fmr_op_unmap_sync passes more than one FMR to ib_unmap_fmr(), but
it didn't bother to remove the FMRs from that list once the call was
complete.

I've noticed some instability that could be related to list
tangling by the new fmr_op_unmap_sync() logic. In an abundance
of caution, add some defensive logic to clean up properly after
ib_unmap_fmr().

Fixes: 7c7a5390dc6c8 ("xprtrdma: Add ro_unmap_sync method for FMR")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 6326ebe..c748ff6 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -63,9 +63,12 @@ static int
 __fmr_unmap(struct rpcrdma_mw *mw)
 {
 	LIST_HEAD(l);
+	int rc;
 
 	list_add(&mw->fmr.fmr->list, &l);
-	return ib_unmap_fmr(&l);
+	rc = ib_unmap_fmr(&l);
+	list_del_init(&mw->fmr.fmr->list);
+	return rc;
 }
 
 /* Deferred reset of a single FMR. Generate a fresh rkey by
@@ -267,7 +270,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		seg = &req->rl_segments[i];
 		mw = seg->rl_mw;
 
-		list_add(&mw->fmr.fmr->list, &unmap_list);
+		list_add_tail(&mw->fmr.fmr->list, &unmap_list);
 
 		i += seg->mr_nsegs;
 	}
@@ -280,7 +283,9 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 */
 	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
 		seg = &req->rl_segments[i];
+		mw = seg->rl_mw;
 
+		list_del_init(&mw->fmr.fmr->list);
 		__fmr_dma_unmap(r_xprt, seg);
 		rpcrdma_put_mw(r_xprt, seg->rl_mw);
 

