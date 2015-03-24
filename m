Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38571 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbbCXUbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 16:31:09 -0400
Subject: [PATCH v2 04/15] xprtrdma: Byte-align FRWR registration
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 24 Mar 2015 16:31:06 -0400
Message-ID: <20150324203106.2311.97894.stgit@manet.1015granger.net>
In-Reply-To: <20150324201849.2311.53599.stgit@manet.1015granger.net>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA transport's FRWR registration logic registers whole
pages. This means areas in the first and last pages that are not
involved in the RDMA I/O are needlessly exposed to the server.

Buffered I/O is typically page-aligned, so not a problem there. But
for direct I/O, which can be byte-aligned, and for reply chunks,
which are nearly always smaller than a page, the transport could
expose memory outside the I/O buffer.

FRWR allows byte-aligned memory registration, so let's use it as
it was intended.

Reported-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1aa55b7..60f3317 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1924,23 +1924,19 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
 			break;
 	}
-	dprintk("RPC:       %s: Using frmr %p to map %d segments\n",
-		__func__, mw, i);
+	dprintk("RPC:       %s: Using frmr %p to map %d segments (%d bytes)\n",
+		__func__, mw, i, len);
 
 	frmr->fr_state = FRMR_IS_VALID;
 
 	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
 	fastreg_wr.wr_id = (unsigned long)(void *)mw;
 	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
-	fastreg_wr.wr.fast_reg.iova_start = seg1->mr_dma;
+	fastreg_wr.wr.fast_reg.iova_start = seg1->mr_dma + pageoff;
 	fastreg_wr.wr.fast_reg.page_list = frmr->fr_pgl;
 	fastreg_wr.wr.fast_reg.page_list_len = page_no;
 	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
-	fastreg_wr.wr.fast_reg.length = page_no << PAGE_SHIFT;
-	if (fastreg_wr.wr.fast_reg.length < len) {
-		rc = -EIO;
-		goto out_err;
-	}
+	fastreg_wr.wr.fast_reg.length = len;
 
 	/* Bump the key */
 	key = (u8)(mr->rkey & 0x000000FF);

