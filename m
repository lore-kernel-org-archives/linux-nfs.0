Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34720 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754068AbcKRPLd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:11:33 -0500
Subject: [PATCH v2 10/10] svcrdma: Further clean-up of
 svc_rdma_get_inv_rkey()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:11:31 -0500
Message-ID: <20161118151130.13658.36018.stgit@klimt.1015granger.net>
In-Reply-To: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
References: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No longer any need for the dprintk().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 30eeab5..ad4d286 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -199,31 +199,22 @@ static u32 svc_rdma_get_inv_rkey(struct rpcrdma_msg *rdma_argp,
 {
 	struct rpcrdma_read_chunk *rd_ary;
 	struct rpcrdma_segment *arg_ch;
-	u32 inv_rkey;
-
-	inv_rkey = 0;
 
 	rd_ary = (struct rpcrdma_read_chunk *)&rdma_argp->rm_body.rm_chunks[0];
-	if (rd_ary->rc_discrim != xdr_zero) {
-		inv_rkey = be32_to_cpu(rd_ary->rc_target.rs_handle);
-		goto out;
-	}
+	if (rd_ary->rc_discrim != xdr_zero)
+		return be32_to_cpu(rd_ary->rc_target.rs_handle);
 
 	if (wr_ary && be32_to_cpu(wr_ary->wc_nchunks)) {
 		arg_ch = &wr_ary->wc_array[0].wc_target;
-		inv_rkey = be32_to_cpu(arg_ch->rs_handle);
-		goto out;
+		return be32_to_cpu(arg_ch->rs_handle);
 	}
 
 	if (rp_ary && be32_to_cpu(rp_ary->wc_nchunks)) {
 		arg_ch = &rp_ary->wc_array[0].wc_target;
-		inv_rkey = be32_to_cpu(arg_ch->rs_handle);
-		goto out;
+		return be32_to_cpu(arg_ch->rs_handle);
 	}
 
-out:
-	dprintk("svcrdma: Send With Invalidate rkey=%08x\n", inv_rkey);
-	return inv_rkey;
+	return 0;
 }
 
 /* Assumptions:

