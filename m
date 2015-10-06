Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38398 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751438AbbJFJse (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Oct 2015 05:48:34 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH rdma-rc] xprtrdma: Don't require LOCAL_DMA_LKEY support for fasterg
Date: Tue,  6 Oct 2015 12:48:09 +0300
Message-Id: <1444124889-8957-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no need to require LOCAL_DMA_LKEY support in order to
use fast registration as the PD allocation makes sure that there
is a local_dma_lkey.

This caused a NULL pointer dereference in mlx5 which removed
the support for LOCAL_DMA_LKEY.

Fixes: bb6c96d72879 ("xprtrdma: Replace global lkey with lkey local to PD")
Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/verbs.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index eb081ad..7efd9ef 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -543,11 +543,8 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	}
 
 	if (memreg == RPCRDMA_FRMR) {
-		/* Requires both frmr reg and local dma lkey */
-		if (((devattr->device_cap_flags &
-		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
-		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) ||
-		      (devattr->max_fast_reg_page_list_len == 0)) {
+		if (!(devattr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) ||
+		    (devattr->max_fast_reg_page_list_len == 0)) {
 			dprintk("RPC:       %s: FRMR registration "
 				"not supported by HCA\n", __func__);
 			memreg = RPCRDMA_MTHCAFMR;
-- 
1.7.1

