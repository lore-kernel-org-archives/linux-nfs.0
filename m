From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH,RFC 01/09] svcrdma: Add Fast Reg MR Data Types
Date: Wed, 13 Aug 2008 11:07:08 -0500
Message-ID: <48A306AC.80800@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:53408 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbYHMQHI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 12:07:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Add data types to track Fast Reg Memory Regions. The core data type is
svc_rdma_fastreg_mr that associates a device MR with a host kva and page
list. A field is added to the WR context to keep track of the FRMR
used to map the local memory for an RPC.

An FRMR list and spin lock are added to the transport instance to keep
track of all FRMR allocated for the transport. Also added are device
capability flags to indicate what the memory registration
capabilities are for the underlying device and whether or not fast
memory registration is supported.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 include/linux/sunrpc/svc_rdma.h |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index dc05b54..295ebbc 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -72,6 +72,7 @@ extern atomic_t rdma_stat_sq_prod;
  */
 struct svc_rdma_op_ctxt {
 	struct svc_rdma_op_ctxt *read_hdr;
+	struct svc_rdma_fastreg_mr *frmr;
 	int hdr_count;
 	struct xdr_buf arg;
 	struct list_head dto_q;
@@ -103,16 +104,35 @@ struct svc_rdma_chunk_sge {
 	int start;		/* sge no for this chunk */
 	int count;		/* sge count for this chunk */
 };
+struct svc_rdma_fastreg_mr {
+	struct ib_mr *mr;
+	void *kva;
+	struct ib_fast_reg_page_list *page_list;
+	int page_list_len;
+	unsigned long access_flags;
+	unsigned long map_len;
+	enum dma_data_direction direction;
+	struct list_head frmr_list;
+};
 struct svc_rdma_req_map {
+	struct svc_rdma_fastreg_mr *frmr;
 	unsigned long count;
 	union {
 		struct kvec sge[RPCSVC_MAXPAGES];
 		struct svc_rdma_chunk_sge ch[RPCSVC_MAXPAGES];
 	};
 };
-
+#define RDMACTXT_F_FAST_UNREG	1
 #define RDMACTXT_F_LAST_CTXT	2
 
+enum svcrdma_dev_cap {		     	/* device supports: */
+	SVCRDMA_DEVCAP_FAST_REG = 1, 	/*	- fast mr registration */
+	SVCRDMA_DEVCAP_READ_W_INV = 2, 	/*	- read w/ invalidate */
+	SVCRDMA_DEVCAP_LCL_DMA_MR = 4,	/*	- lcl dma lkey */
+	SVCRDMA_DEVCAP_LCL_WR_REQ = 8,	/*	- data sink requires remote */
+					/*	  write */
+};
+
 struct svcxprt_rdma {
 	struct svc_xprt      sc_xprt;		/* SVC transport structure */
 	struct rdma_cm_id    *sc_cm_id;		/* RDMA connection id */
@@ -136,6 +156,11 @@ struct svcxprt_rdma {
 	struct ib_cq         *sc_rq_cq;
 	struct ib_cq         *sc_sq_cq;
 	struct ib_mr         *sc_phys_mr;	/* MR for server memory */
+	enum svcrdma_dev_cap sc_dev_caps;	/* distilled device caps */
+	u32		     sc_dma_lkey;	/* local dma key */
+	unsigned int	     sc_frmr_pg_list_len;
+	struct list_head     sc_frmr_q;
+	spinlock_t	     sc_frmr_q_lock;
 
 	spinlock_t	     sc_lock;		/* transport lock */
 

