Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34941 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbbC3SeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:34:14 -0400
Subject: [PATCH v3 05/15] xprtrdma: Prevent infinite loop in
 rpcrdma_ep_create()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Mar 2015 14:34:12 -0400
Message-ID: <20150330183412.7856.55625.stgit@manet.1015granger.net>
In-Reply-To: <20150330182615.7856.61170.stgit@manet.1015granger.net>
References: <20150330182615.7856.61170.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a provider advertizes a zero max_fast_reg_page_list_len, FRWR
depth detection loops forever. Instead of just failing the mount,
try other memory registration modes.

Fixes: 0fc6c4e7bb28 ("xprtrdma: mind the device's max fast . . .")
Reported-by: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Tested-by: Meghana Cheripady <Meghana.Cheripady@Emulex.Com>
Tested-by: Veeresh U. Kokatnur <veereshuk@chelsio.com>
---
 net/sunrpc/xprtrdma/verbs.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 60f3317..99752b5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -618,9 +618,10 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 
 	if (memreg == RPCRDMA_FRMR) {
 		/* Requires both frmr reg and local dma lkey */
-		if ((devattr->device_cap_flags &
+		if (((devattr->device_cap_flags &
 		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
-		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) {
+		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) ||
+		      (devattr->max_fast_reg_page_list_len == 0)) {
 			dprintk("RPC:       %s: FRMR registration "
 				"not supported by HCA\n", __func__);
 			memreg = RPCRDMA_MTHCAFMR;

