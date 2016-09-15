Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35325 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751731AbcIOO5m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 10:57:42 -0400
Subject: [PATCH v3 20/22] xprtrmda: Report address of frmr, not mw
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 15 Sep 2016 10:57:40 -0400
Message-ID: <20160915145740.11080.38297.stgit@manet.1015granger.net>
In-Reply-To: <20160915143440.11080.89241.stgit@manet.1015granger.net>
References: <20160915143440.11080.89241.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tie frwr debugging messages together by always reporting the address
of the frwr.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e82d5cf..ad70a87 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -163,7 +163,7 @@ __frwr_reset_mr(struct rpcrdma_ia *ia, struct rpcrdma_mw *r)
 		return PTR_ERR(f->fr_mr);
 	}
 
-	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, r);
+	dprintk("RPC:       %s: recovered FRMR %p\n", __func__, f);
 	f->fr_state = FRMR_IS_INVALID;
 	return 0;
 }
@@ -397,7 +397,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 		goto out_mapmr_err;
 
 	dprintk("RPC:       %s: Using frmr %p to map %u segments (%u bytes)\n",
-		__func__, mw, mw->mw_nents, mr->length);
+		__func__, frmr, mw->mw_nents, mr->length);
 
 	key = (u8)(mr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(mr, ++key);
@@ -450,6 +450,8 @@ __frwr_prepare_linv_wr(struct rpcrdma_mw *mw)
 	struct rpcrdma_frmr *f = &mw->frmr;
 	struct ib_send_wr *invalidate_wr;
 
+	dprintk("RPC:       %s: invalidating frmr %p\n", __func__, f);
+
 	f->fr_state = FRMR_IS_INVALID;
 	invalidate_wr = &f->fr_invwr;
 
@@ -532,6 +534,8 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 */
 unmap:
 	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+		dprintk("RPC:       %s: unmapping frmr %p\n",
+			__func__, &mw->frmr);
 		list_del_init(&mw->mw_list);
 		ib_dma_unmap_sg(ia->ri_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);

