From: Tom Talpey <tmtalpey@gmail.com>
Subject: [RESEND] [PATCH] XPRTRDMA: fix client rpcrdma FRMR
  registration on mlx4 devices
Date: Thu, 21 May 2009 09:40:56 -0400
Message-ID: <4a1559f7.04c2f10a.6610.ffff8780@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, Vu Pham <vu@mellanox.com>,
	Tom Talpey <tmtalpey@gmail.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f124.google.com ([209.85.221.124]:41030 "EHLO
	mail-qy0-f124.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbZEUNsp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 May 2009 09:48:45 -0400
Received: by qyk30 with SMTP id 30so107933qyk.33
        for <linux-nfs@vger.kernel.org>; Thu, 21 May 2009 06:48:46 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[resending this important connectathon fix - originally sent on 3/25/09, lost?]

mlx4/connectX FRMR requires local write enable together with remote
rdma write enable. This fixes NFS/RDMA operation over the ConnectX
Infiniband HCA in the default memreg mode.

Signed-off-by: Vu Pham <vu@mellanox.com>
Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
---

 net/sunrpc/xprtrdma/verbs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3b21e0c..465aafc 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1495,7 +1495,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
 	frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.length = i << PAGE_SHIFT;
 	frmr_wr.wr.fast_reg.access_flags = (writing ?
-				IB_ACCESS_REMOTE_WRITE : IB_ACCESS_REMOTE_READ);
+				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
+				IB_ACCESS_REMOTE_READ);
 	frmr_wr.wr.fast_reg.rkey = seg1->mr_chunk.rl_mw->r.frmr.fr_mr->rkey;
 	DECR_CQCOUNT(&r_xprt->rx_ep);
 

