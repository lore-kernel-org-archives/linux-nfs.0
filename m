Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39769 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752793AbeEGT2c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:28:32 -0400
Subject: [PATCH v1 19/19] svcrdma: Remove unused svc_rdma_op_ctxt
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:28:31 -0400
Message-ID: <20180507192830.4608.78551.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Eliminate a structure that is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h |   21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 96b14a7..fd78f78 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -71,26 +71,6 @@ enum {
 extern atomic_t rdma_stat_sq_poll;
 extern atomic_t rdma_stat_sq_prod;
 
-/*
- * Contexts are built when an RDMA request is created and are a
- * record of the resources that can be recovered when the request
- * completes.
- */
-struct svc_rdma_op_ctxt {
-	struct list_head list;
-	struct xdr_buf arg;
-	struct ib_cqe cqe;
-	u32 byte_len;
-	struct svcxprt_rdma *xprt;
-	enum dma_data_direction direction;
-	int count;
-	unsigned int mapped_sges;
-	int hdr_count;
-	struct ib_send_wr send_wr;
-	struct ib_sge sge[1 + RPCRDMA_MAX_INLINE_THRESH / PAGE_SIZE];
-	struct page *pages[RPCSVC_MAXPAGES];
-};
-
 struct svcxprt_rdma {
 	struct svc_xprt      sc_xprt;		/* SVC transport structure */
 	struct rdma_cm_id    *sc_cm_id;		/* RDMA connection id */
@@ -111,7 +91,6 @@ struct svcxprt_rdma {
 
 	spinlock_t	     sc_send_lock;
 	struct list_head     sc_send_ctxts;
-	int		     sc_ctxt_used;
 	spinlock_t	     sc_rw_ctxt_lock;
 	struct list_head     sc_rw_ctxts;
 

