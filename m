From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are truncated by
	the nfs rdma client.
Date: Fri, 24 Apr 2009 14:05:10 -0500
Message-ID: <20090424190510.3134.90405.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: tmtalpey@gmail.com, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:51322 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752627AbZDXTFL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 15:05:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A bad cast causes the iova_start, which in this case is a DMA bus address,
to be truncated on 32b systems.  No cast is needed.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3b21e0c..3a374f5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1489,7 +1489,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	memset(&frmr_wr, 0, sizeof frmr_wr);
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
 	frmr_wr.send_flags = 0;			/* unsignaled */
-	frmr_wr.wr.fast_reg.iova_start = (unsigned long)seg1->mr_dma;
+	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
 	frmr_wr.wr.fast_reg.page_list = seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
 	frmr_wr.wr.fast_reg.page_list_len = i;
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;

