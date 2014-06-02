Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:33689 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754073AbaFBROe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 13:14:34 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH] svcrdma: Fence LOCAL_INV work requests
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Date: Mon, 02 Jun 2014 12:14:33 -0500
Message-ID: <20140602171433.31076.5634.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This applies on top of:

	commit e5a070216356dbcb03607cb264cc3104e17339b3
	Author: Steve Wise <swise@opengridcomputing.com>
	Date:   Wed May 28 15:12:01 2014 -0500

	    svcrdma: refactor marshalling logic

Fencing forces the invalidate to only happen after all subsequent send
work requests have been completed.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 52d9f2c..8f92a61 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -338,7 +338,7 @@ static int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 		memset(&inv_wr, 0, sizeof(inv_wr));
 		inv_wr.wr_id = (unsigned long)ctxt;
 		inv_wr.opcode = IB_WR_LOCAL_INV;
-		inv_wr.send_flags = IB_SEND_SIGNALED;
+		inv_wr.send_flags = IB_SEND_SIGNALED | IB_SEND_FENCE;
 		inv_wr.ex.invalidate_rkey = frmr->mr->lkey;
 	}
 	ctxt->wr_op = read_wr.opcode;

