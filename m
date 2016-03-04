Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33994 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250AbcCDQ1h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 11:27:37 -0500
Subject: [PATCH v3 02/11] xprtrdma: Clean up physical_op_map()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 Mar 2016 11:27:35 -0500
Message-ID: <20160304162735.13590.96884.stgit@oracle120-ib.cthon.org>
In-Reply-To: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

physical_op_unmap{_sync} don't use mr_nsegs, so don't bother to set
it in physical_op_map.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/physical_ops.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
index dbb302e..481b9b6 100644
--- a/net/sunrpc/xprtrdma/physical_ops.c
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -68,7 +68,6 @@ physical_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	rpcrdma_map_one(ia->ri_device, seg, rpcrdma_data_dir(writing));
 	seg->mr_rkey = ia->ri_dma_mr->rkey;
 	seg->mr_base = seg->mr_dma;
-	seg->mr_nsegs = 1;
 	return 1;
 }
 

