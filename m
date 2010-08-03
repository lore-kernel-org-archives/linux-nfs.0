Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:35127 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756737Ab0HCQpC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 12:45:02 -0400
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 1/4] xprtrdma: Do not truncate iova_start values in frmr
	registrations.
To: trond.myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, swise@ogc.us, tom@ogc.us
Date: Tue, 03 Aug 2010 11:45:01 -0500
Message-ID: <20100803164501.2567.8549.stgit@build.ogc.int>
In-Reply-To: <20100803164411.2567.31416.stgit@build.ogc.int>
References: <20100803164411.2567.31416.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Steve Wise <swise@opengridcomputing.com>

A bad cast causes the iova_start, which in this case is a 64b DMA
bus address, to be truncated on 32b systems.  This breaks frmrs on
32b systems.  No cast is needed.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 27015c6..3bdbd9f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1490,7 +1490,7 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	memset(&frmr_wr, 0, sizeof frmr_wr);
 	frmr_wr.opcode = IB_WR_FAST_REG_MR;
 	frmr_wr.send_flags = 0;			/* unsignaled */
-	frmr_wr.wr.fast_reg.iova_start = (unsigned long)seg1->mr_dma;
+	frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
 	frmr_wr.wr.fast_reg.page_list = seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
 	frmr_wr.wr.fast_reg.page_list_len = i;
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;

