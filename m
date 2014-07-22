Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:63235 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755784AbaGVOxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:53:04 -0400
Subject: [PATCH v4 14/21] xprtrdma: Disable completions for FAST_REG_MR Work
 Requests
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:53:01 -0400
Message-ID: <20140722145301.6010.49629.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of relying on a completion to change the state of an FRMR
to FRMR_IS_VALID, set it in advance. If an error occurs, a completion
will fire anyway and mark the FRMR FRMR_IS_STALE.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/verbs.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 8429869..b36a5dd 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -159,10 +159,7 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 		return;
 	}
 
-	if (wc->opcode == IB_WC_FAST_REG_MR)
-		frmr->r.frmr.fr_state = FRMR_IS_VALID;
-	else if (wc->opcode == IB_WC_LOCAL_INV)
-		frmr->r.frmr.fr_state = FRMR_IS_INVALID;
+	frmr->r.frmr.fr_state = FRMR_IS_INVALID;
 }
 
 static int
@@ -1724,10 +1721,11 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
 		__func__, mw, i);
 
+	frmr->fr_state = FRMR_IS_VALID;
+
 	memset(&frmr_wr, 0, sizeof frmr_wr);
 	frmr_wr.wr_id = (unsigned long)(void *)mw;
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
-	frmr_wr.send_flags = IB_SEND_SIGNALED;
 	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
 	frmr_wr.wr.fast_reg.page_list = frmr->fr_pgl;
 	frmr_wr.wr.fast_reg.page_list_len = page_no;
@@ -1761,6 +1759,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	*nsegs = i;
 	return 0;
 out_err:
+	frmr->fr_state = FRMR_IS_INVALID;
 	while (i--)
 		rpcrdma_unmap_one(ia, --seg);
 	return rc;

