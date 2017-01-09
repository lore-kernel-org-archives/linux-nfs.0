Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wj0-f169.google.com ([209.85.210.169]:35657 "EHLO
        mail-wj0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdAIDyB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2017 22:54:01 -0500
Received: by mail-wj0-f169.google.com with SMTP id i20so59337991wjn.2
        for <linux-nfs@vger.kernel.org>; Sun, 08 Jan 2017 19:54:01 -0800 (PST)
From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: [PATCH] svcrdma: avoid duplicate dma unmapping during error recovery
Date: Mon,  9 Jan 2017 16:00:44 +0530
Message-Id: <20170109103044.5590-1-sriharsha.basavapatna@broadcom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In rdma_read_chunk_frmr() when ib_post_send() fails, the error code path
invokes ib_dma_unmap_sg() to unmap the sg list. It then invokes
svc_rdma_put_frmr() which in turn tries to unmap the same sg list through
ib_dma_unmap_sg() again. This second unmap is invalid and could lead to
problems when the iova being unmapped is subsequently reused. Remove
the call to unmap in rdma_read_chunk_frmr() and let svc_rdma_put_frmr()
handle it.

Fixes: 412a15c0fe53 ("svcrdma: Port to new memory registration API")
Cc: stable@vger.kernel.org
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 57d35fbb1c28..172b537f8cfc 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -347,8 +347,6 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	atomic_inc(&rdma_stat_read);
 	return ret;
  err:
-	ib_dma_unmap_sg(xprt->sc_cm_id->device,
-			frmr->sg, frmr->sg_nents, frmr->direction);
 	svc_rdma_put_context(ctxt, 0);
 	svc_rdma_put_frmr(xprt, frmr);
 	return ret;
-- 
2.11.0.258.ge05806da9

