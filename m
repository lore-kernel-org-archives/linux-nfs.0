Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35720 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946429AbcBRRap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:30:45 -0500
Subject: [PATCH v2 06/12] xprtrdma: Do not wait if ib_post_send() fails
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:30:43 -0500
Message-ID: <20160218173043.14009.19155.stgit@manet.1015granger.net>
In-Reply-To: <20160218172449.14009.47311.stgit@manet.1015granger.net>
References: <20160218172449.14009.47311.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If ib_post_send() in ro_unmap_sync() fails, the WRs have not been
posted, no completions will fire, and wait_for_completion() will
wait forever. Skip the wait in that case.

To ensure the MRs are invalid, disconnect.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e165673..ecb005f 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -520,14 +520,18 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 * unless ri_id->qp is a valid pointer.
 	 */
 	rc = ib_post_send(ia->ri_id->qp, invalidate_wrs, &bad_wr);
-	if (rc)
+	if (rc) {
 		pr_warn("%s: ib_post_send failed %i\n", __func__, rc);
+		rdma_disconnect(ia->ri_id);
+		goto unmap;
+	}
 
 	wait_for_completion(&f->fr_linv_done);
 
 	/* ORDER: Now DMA unmap all of the req's MRs, and return
 	 * them to the free MW list.
 	 */
+unmap:
 	for (i = 0, nchunks = req->rl_nchunks; nchunks; nchunks--) {
 		seg = &req->rl_segments[i];
 

