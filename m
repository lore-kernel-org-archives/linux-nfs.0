Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:32973 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbbGTTC4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 15:02:56 -0400
Subject: [PATCH v3 03/15] xprtrdma: Increase default credit limit
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jul 2015 15:02:52 -0400
Message-ID: <20150720190252.10997.85620.stgit@manet.1015granger.net>
In-Reply-To: <20150720185624.10997.51574.stgit@manet.1015granger.net>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for similar increases on NFS/RDMA servers, bump the
advertised credit limit for RPC/RDMA to 128. This allocates some
extra resources, but the client will continue to allow only the
number of RPCs in flight that the server requests via its advertised
credit limit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 include/linux/sunrpc/xprtrdma.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index b176130..b7b279b 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -49,7 +49,7 @@
  * a single chunk type per message is supported currently.
  */
 #define RPCRDMA_MIN_SLOT_TABLE	(2U)
-#define RPCRDMA_DEF_SLOT_TABLE	(32U)
+#define RPCRDMA_DEF_SLOT_TABLE	(128U)
 #define RPCRDMA_MAX_SLOT_TABLE	(256U)
 
 #define RPCRDMA_DEF_INLINE  (1024)	/* default inline max */

