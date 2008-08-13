From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH,RFC 01/02] xprtrdma: Add data types to support FRMR
Date: Wed, 13 Aug 2008 11:17:56 -0500
Message-ID: <48A30934.6060802@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Tom Talpey <Thomas.Talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36771 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752021AbYHMQR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 12:17:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add data types to support FRMR and a new memory registration strategy
to use FRMR if available.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  include/linux/sunrpc/xprtrdma.h |    1 +
  net/sunrpc/xprtrdma/xprt_rdma.h |   10 +++++++++-
  2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 4de56b1..98d8e4a 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -79,6 +79,7 @@ enum rpcrdma_memreg {
  	RPCRDMA_MEMWINDOWS_ASYNC,
  	RPCRDMA_MTHCAFMR,
  	RPCRDMA_ALLPHYSICAL,
+	RPCRDMA_FASTREG,
  	RPCRDMA_LAST
  };

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 2427822..1f81dad 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -58,6 +58,7 @@ struct rpcrdma_ia {
  	struct rdma_cm_id 	*ri_id;
  	struct ib_pd		*ri_pd;
  	struct ib_mr		*ri_bind_mem;
+	u32			ri_dma_lkey;
  	struct completion	ri_done;
  	int			ri_async_rc;
  	enum rpcrdma_memreg	ri_memreg_strategy;
@@ -159,6 +160,11 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
  			} r;
  			struct list_head mw_list;
  		} *rl_mw;
+		struct rpcrdma_frmr {
+			struct ib_fast_reg_page_list *fr_pgl;
+			struct ib_mr *fr_mr;
+			struct list_head fr_list;
+		} *rl_fr;
  	} mr_chunk;
  	u64		mr_base;	/* registration result */
  	u32		mr_rkey;	/* registration result */
@@ -198,7 +204,9 @@ struct rpcrdma_buffer {
  	atomic_t	rb_credits;	/* most recent server credits */
  	unsigned long	rb_cwndscale;	/* cached framework rpc_cwndscale */
  	int		rb_max_requests;/* client max requests */
-	struct list_head rb_mws;	/* optional memory windows/fmrs */
+	spinlock_t	rb_frs_lock;	/* protects frs list */
+	struct list_head rb_frs;	/* optional fmrs */
+	struct list_head rb_mws;	/* optional memory windows */
  	int		rb_send_index;
  	struct rpcrdma_req	**rb_send_bufs;
  	int		rb_recv_index;
