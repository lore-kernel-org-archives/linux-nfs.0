From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH] XPRTRDMA: fix client rpcrdma FRMR registration on mlx4 devices
Date: Wed, 25 Mar 2009 10:37:21 -0400
Message-ID: <20090325143720.2970.10887.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Vu Pham <vu@mellanox.com>,
	Tom Talpey <tmtalpey@gmail.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:39220
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754368AbZCYOhV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2009 10:37:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 

