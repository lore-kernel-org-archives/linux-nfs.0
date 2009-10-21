From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH version2] sunrpc: Clean never used include files
Date: Wed, 21 Oct 2009 15:26:26 +0200
Message-ID: <4ADF0C02.4030900@panasas.com>
References: <4ADEC1EF.8040107@panasas.com> <1256112711-25728-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:11235 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753269AbZJUN01 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 09:26:27 -0400
In-Reply-To: <1256112711-25728-1-git-send-email-bharrosh@panasas.com>
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
1.6.2.1


