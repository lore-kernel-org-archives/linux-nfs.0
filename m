Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34809 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbEKSCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:02:38 -0400
Subject: [PATCH v2 02/16] xprtrdma: Warn when there are orphaned IB objects
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:02:35 -0400
Message-ID: <20150511180235.31263.71754.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

WARN during transport destruction if ib_dealloc_pd() fails. This is
a sign that xprtrdma orphaned one or more RDMA API objects at some
point, which can pin lower layer kernel modules and cause shutdown
to hang.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 net/sunrpc/xprtrdma/verbs.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4870d27..51900e6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -702,17 +702,17 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
 		dprintk("RPC:       %s: ib_dereg_mr returned %i\n",
 			__func__, rc);
 	}
+
 	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
 		if (ia->ri_id->qp)
 			rdma_destroy_qp(ia->ri_id);
 		rdma_destroy_id(ia->ri_id);
 		ia->ri_id = NULL;
 	}
-	if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
-		rc = ib_dealloc_pd(ia->ri_pd);
-		dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
-			__func__, rc);
-	}
+
+	/* If the pd is still busy, xprtrdma missed freeing a resource */
+	if (ia->ri_pd && !IS_ERR(ia->ri_pd))
+		WARN_ON(ib_dealloc_pd(ia->ri_pd));
 }
 
 /*

