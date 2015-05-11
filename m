Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:33212 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbbEKSEP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 14:04:15 -0400
Subject: [PATCH v2 12/16] xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 May 2015 14:04:12 -0400
Message-ID: <20150511180412.31263.53368.stgit@manet.1015granger.net>
In-Reply-To: <20150511174401.31263.79596.stgit@manet.1015granger.net>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This field is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
---
 include/linux/sunrpc/xprtrdma.h |    3 ++-
 net/sunrpc/xprtrdma/verbs.c     |    3 ---
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index c984c85..b176130 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -56,7 +56,8 @@
 
 #define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
 
-/* memory registration strategies */
+/* Memory registration strategies, by number.
+ * This is part of a kernel / user space API. Do not remove. */
 enum rpcrdma_memreg {
 	RPCRDMA_BOUNCEBUFFERS = 0,
 	RPCRDMA_REGISTER,
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index db9303a..cc1a526 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -665,9 +665,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	dprintk("RPC:       %s: memory registration strategy is '%s'\n",
 		__func__, ia->ri_ops->ro_displayname);
 
-	/* Else will do memory reg/dereg for each chunk */
-	ia->ri_memreg_strategy = memreg;
-
 	rwlock_init(&ia->ri_qplock);
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index f19376d..3ecee38 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -70,7 +70,6 @@ struct rpcrdma_ia {
 	int			ri_have_dma_lkey;
 	struct completion	ri_done;
 	int			ri_async_rc;
-	enum rpcrdma_memreg	ri_memreg_strategy;
 	unsigned int		ri_max_frmr_depth;
 	struct ib_device_attr	ri_devattr;
 	struct ib_qp_attr	ri_qp_attr;

