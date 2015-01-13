Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:64286 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbbAMQ0I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:26:08 -0500
Subject: [PATCH v2 10/20] xprtrdma: Free the pd if ib_query_qp() fails
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Jan 2015 11:26:06 -0500
Message-ID: <20150113162606.14086.7193.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If ib_query_qp() fails or the memory registration mode isn't
supported, don't leak the PD. An orphaned IB/core resource will
cause IB module removal to hang.

Fixes: bd7ed1d13304 ("RPC/RDMA: check selected memory registration ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c61bb61..aa012a3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -614,7 +614,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	if (rc) {
 		dprintk("RPC:       %s: ib_query_device failed %d\n",
 			__func__, rc);
-		goto out2;
+		goto out3;
 	}
 
 	if (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
@@ -672,14 +672,14 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 				"phys register failed with %lX\n",
 				__func__, PTR_ERR(ia->ri_bind_mem));
 			rc = -ENOMEM;
-			goto out2;
+			goto out3;
 		}
 		break;
 	default:
 		printk(KERN_ERR "RPC: Unsupported memory "
 				"registration mode: %d\n", memreg);
 		rc = -ENOMEM;
-		goto out2;
+		goto out3;
 	}
 	dprintk("RPC:       %s: memory registration strategy is %d\n",
 		__func__, memreg);
@@ -689,6 +689,10 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 
 	rwlock_init(&ia->ri_qplock);
 	return 0;
+
+out3:
+	ib_dealloc_pd(ia->ri_pd);
+	ia->ri_pd = NULL;
 out2:
 	rdma_destroy_id(ia->ri_id);
 	ia->ri_id = NULL;

