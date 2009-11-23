From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 2/6] sunrpc: Clean never used include files
Date: Mon, 23 Nov 2009 17:58:54 +0200
Message-ID: <1258991934-25364-1-git-send-email-bharrosh@panasas.com>
References: <4B0AB039.6020608@panasas.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.M
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42289 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753107AbZKWP6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2009 10:58:53 -0500
In-Reply-To: <4B0AB039.6020608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove include of two headers never used by this file.
Doing so exposed a missing #include <linux/types.h> in
include/linux/sunrpc/rpc_rdma.h.

I did not see any other users dependency but if exist they
should be fixed since these headers are totally irrelevant
to here.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/sunrpc/debug.h    |    3 ---
 include/linux/sunrpc/rpc_rdma.h |    2 ++
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 10709cb..c2786f2 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -28,9 +28,6 @@
 
 #ifdef __KERNEL__
 
-#include <linux/timer.h>
-#include <linux/workqueue.h>
-
 /*
  * Enable RPC debugging/profiling.
  */
diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index 87b895d..b78f16b 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -40,6 +40,8 @@
 #ifndef _LINUX_SUNRPC_RPC_RDMA_H
 #define _LINUX_SUNRPC_RPC_RDMA_H
 
+#include <linux/types.h>
+
 struct rpcrdma_segment {
 	__be32 rs_handle;	/* Registered memory handle */
 	__be32 rs_length;	/* Length of the chunk in bytes */
-- 
1.6.5.2

