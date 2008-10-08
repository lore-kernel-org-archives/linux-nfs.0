From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 02/15] RPC/RDMA: add data types and new FRMR memory
	registration enum.
Date: Wed, 08 Oct 2008 11:47:13 -0400
Message-ID: <20081008154713.1336.41538.stgit@tmt3.nane.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754478AbYJHQWO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:14 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FlDiJ001425
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:47:13 -0400
In-Reply-To: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Internal RPC/RDMA structure updates in preparation for FRMR support.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Tom Talpey <talpey@netapp.com>
---

 net/sunrpc/xprtrdma/xprt_rdma.h |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 4de56b1..55a5d92 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -78,6 +78,7 @@ enum rpcrdma_memreg {
 	RPCRDMA_MEMWINDOWS,
 	RPCRDMA_MEMWINDOWS_ASYNC,
 	RPCRDMA_MTHCAFMR,
+	RPCRDMA_FRMR,
 	RPCRDMA_ALLPHYSICAL,
 	RPCRDMA_LAST
 };
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2427822..05b7898 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -58,6 +58,8 @@ struct rpcrdma_ia {
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
 	struct ib_mr		*ri_bind_mem;
+	u32			ri_dma_lkey;
+	int			ri_have_dma_lkey;
 	struct completion	ri_done;
 	int			ri_async_rc;
 	enum rpcrdma_memreg	ri_memreg_strategy;
@@ -156,6 +158,10 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
 			union {
 				struct ib_mw	*mw;
 				struct ib_fmr	*fmr;
+				struct {
+					struct ib_fast_reg_page_list *fr_pgl;
+					struct ib_mr *fr_mr;
+				} frmr;
 			} r;
 			struct list_head mw_list;
 		} *rl_mw;
@@ -198,7 +204,7 @@ struct rpcrdma_buffer {
 	atomic_t	rb_credits;	/* most recent server credits */
 	unsigned long	rb_cwndscale;	/* cached framework rpc_cwndscale */
 	int		rb_max_requests;/* client max requests */
-	struct list_head rb_mws;	/* optional memory windows/fmrs */
+	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
 	int		rb_send_index;
 	struct rpcrdma_req	**rb_send_bufs;
 	int		rb_recv_index;

