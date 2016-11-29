Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35801 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934002AbcK2QFl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 11:05:41 -0500
Subject: [PATCH v3 10/10] svcrdma: Further clean-up of
 svc_rdma_get_inv_rkey()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 11:05:39 -0500
Message-ID: <20161129160539.4477.11449.stgit@klimt.1015granger.net>
In-Reply-To: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
References: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
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

