From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 087/100] rdma: SVCRMDA Header File
Date: Fri, 25 Jan 2008 18:17:07 -0500
Message-ID: <1201303040-7779-87-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-80-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-81-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-82-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-83-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-84-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-85-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762186AbYAYXS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:28 -0500
In-Reply-To: <1201303040-7779-86-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

This file defines the data types used by the SVCRDMA transport module.
The principle data structure is the transport specific extension to
the svcxprt structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_rdma.h |  262 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 262 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/sunrpc/svc_rdma.h

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
new file mode 100644
index 0000000..c11bbcc
--- /dev/null
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -0,0 +1,262 @@
+/*
+ * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the BSD-type
+ * license below:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *      Redistributions of source code must retain the above copyright
+ *      notice, this list of conditions and the following disclaimer.
+ *
+ *      Redistributions in binary form must reproduce the above
+ *      copyright notice, this list of conditions and the following
+ *      disclaimer in the documentation and/or other materials provided
+ *      with the distribution.
+ *
+ *      Neither the name of the Network Appliance, Inc. nor the names of
+ *      its contributors may be used to endorse or promote products
+ *      derived from this software without specific prior written
+ *      permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Author: Tom Tucker <tom@opengridcomputing.com>
+ */
+
+#ifndef SVC_RDMA_H
+#define SVC_RDMA_H
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/rpc_rdma.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/rdma_cm.h>
+#define SVCRDMA_DEBUG
+
+/* RPC/RDMA parameters and stats */
+extern unsigned int svcrdma_ord;
+extern unsigned int svcrdma_max_requests;
+extern unsigned int svcrdma_max_req_size;
+
+extern atomic_t rdma_stat_recv;
+extern atomic_t rdma_stat_read;
+extern atomic_t rdma_stat_write;
+extern atomic_t rdma_stat_sq_starve;
+extern atomic_t rdma_stat_rq_starve;
+extern atomic_t rdma_stat_rq_poll;
+extern atomic_t rdma_stat_rq_prod;
+extern atomic_t rdma_stat_sq_poll;
+extern atomic_t rdma_stat_sq_prod;
+
+#define RPCRDMA_VERSION 1
+
+/*
+ * Contexts are built when an RDMA request is created and are a
+ * record of the resources that can be recovered when the request
+ * completes.
+ */
+struct svc_rdma_op_ctxt {
+	struct svc_rdma_op_ctxt *next;
+	struct xdr_buf arg;
+	struct list_head dto_q;
+	enum ib_wr_opcode wr_op;
+	enum ib_wc_status wc_status;
+	u32 byte_len;
+	struct svcxprt_rdma *xprt;
+	unsigned long flags;
+	enum dma_data_direction direction;
+	int count;
+	struct ib_sge sge[RPCSVC_MAXPAGES];
+	struct page *pages[RPCSVC_MAXPAGES];
+};
+
+#define RDMACTXT_F_READ_DONE	1
+#define RDMACTXT_F_LAST_CTXT	2
+
+struct svcxprt_rdma {
+	struct svc_xprt      sc_xprt;		/* SVC transport structure */
+	struct rdma_cm_id    *sc_cm_id;		/* RDMA connection id */
+	struct list_head     sc_accept_q;	/* Conn. waiting accept */
+	int		     sc_ord;		/* RDMA read limit */
+	wait_queue_head_t    sc_read_wait;
+	int                  sc_max_sge;
+
+	int                  sc_sq_depth;	/* Depth of SQ */
+	atomic_t             sc_sq_count;	/* Number of SQ WR on queue */
+
+	int                  sc_max_requests;	/* Depth of RQ */
+	int                  sc_max_req_size;	/* Size of each RQ WR buf */
+
+	struct ib_pd         *sc_pd;
+
+	struct svc_rdma_op_ctxt  *sc_ctxt_head;
+	int		     sc_ctxt_cnt;
+	int		     sc_ctxt_bump;
+	int		     sc_ctxt_max;
+	spinlock_t	     sc_ctxt_lock;
+	struct list_head     sc_rq_dto_q;
+	spinlock_t	     sc_rq_dto_lock;
+	struct ib_qp         *sc_qp;
+	struct ib_cq         *sc_rq_cq;
+	struct ib_cq         *sc_sq_cq;
+	struct ib_mr         *sc_phys_mr;	/* MR for server memory */
+
+	spinlock_t	     sc_lock;		/* transport lock */
+
+	wait_queue_head_t    sc_send_wait;	/* SQ exhaustion waitlist */
+	unsigned long	     sc_flags;
+	struct list_head     sc_dto_q;		/* DTO tasklet I/O pending Q */
+	struct list_head     sc_read_complete_q;
+	spinlock_t           sc_read_complete_lock;
+};
+/* sc_flags */
+#define RDMAXPRT_RQ_PENDING	1
+#define RDMAXPRT_SQ_PENDING	2
+#define RDMAXPRT_CONN_PENDING	3
+
+#define RPCRDMA_LISTEN_BACKLOG  10
+/* The default ORD value is based on two outstanding full-size writes with a
+ * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
+#define RPCRDMA_ORD             (64/4)
+#define RPCRDMA_SQ_DEPTH_MULT   8
+#define RPCRDMA_MAX_THREADS     16
+#define RPCRDMA_MAX_REQUESTS    16
+#define RPCRDMA_MAX_REQ_SIZE    4096
+
+/* svc_rdma_marshal.c */
+extern void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *,
+				      int *, int *);
+extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
+extern int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *);
+extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
+				     struct rpcrdma_msg *,
+				     enum rpcrdma_errcode, u32 *);
+extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
+extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
+extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
+					    u32, u64, u32);
+extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *,
+					     struct rpcrdma_msg *,
+					     struct rpcrdma_msg *,
+					     enum rpcrdma_proc);
+extern int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *);
+
+/* svc_rdma_recvfrom.c */
+extern int svc_rdma_recvfrom(struct svc_rqst *);
+
+/* svc_rdma_sendto.c */
+extern int svc_rdma_sendto(struct svc_rqst *);
+
+/* svc_rdma_transport.c */
+extern int svc_rdma_send(struct svcxprt_rdma *, struct ib_send_wr *);
+extern int svc_rdma_send_error(struct svcxprt_rdma *, struct rpcrdma_msg *,
+			       enum rpcrdma_errcode);
+struct page *svc_rdma_get_page(void);
+extern int svc_rdma_post_recv(struct svcxprt_rdma *);
+extern int svc_rdma_create_listen(struct svc_serv *, int, struct sockaddr *);
+extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
+extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
+extern void svc_sq_reap(struct svcxprt_rdma *);
+extern void svc_rq_reap(struct svcxprt_rdma *);
+extern struct svc_xprt_class svc_rdma_class;
+extern void svc_rdma_prep_reply_hdr(struct svc_rqst *);
+
+/* svc_rdma.c */
+extern int svc_rdma_init(void);
+extern void svc_rdma_cleanup(void);
+
+/*
+ * Returns the address of the first read chunk or <nul> if no read chunk is
+ * present
+ */
+static inline struct rpcrdma_read_chunk *
+svc_rdma_get_read_chunk(struct rpcrdma_msg *rmsgp)
+{
+	struct rpcrdma_read_chunk *ch =
+		(struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
+
+	if (ch->rc_discrim == 0)
+		return NULL;
+
+	return ch;
+}
+
+/*
+ * Returns the address of the first read write array element or <nul> if no
+ * write array list is present
+ */
+static inline struct rpcrdma_write_array *
+svc_rdma_get_write_array(struct rpcrdma_msg *rmsgp)
+{
+	if (rmsgp->rm_body.rm_chunks[0] != 0
+	    || rmsgp->rm_body.rm_chunks[1] == 0)
+		return NULL;
+
+	return (struct rpcrdma_write_array *)&rmsgp->rm_body.rm_chunks[1];
+}
+
+/*
+ * Returns the address of the first reply array element or <nul> if no
+ * reply array is present
+ */
+static inline struct rpcrdma_write_array *
+svc_rdma_get_reply_array(struct rpcrdma_msg *rmsgp)
+{
+	struct rpcrdma_read_chunk *rch;
+	struct rpcrdma_write_array *wr_ary;
+	struct rpcrdma_write_array *rp_ary;
+
+	/* XXX: Need to fix when reply list may occur with read-list and/or
+	 * write list */
+	if (rmsgp->rm_body.rm_chunks[0] != 0 ||
+	    rmsgp->rm_body.rm_chunks[1] != 0)
+		return NULL;
+
+	rch = svc_rdma_get_read_chunk(rmsgp);
+	if (rch) {
+		while (rch->rc_discrim)
+			rch++;
+
+		/* The reply list follows an empty write array located
+		 * at 'rc_position' here. The reply array is at rc_target.
+		 */
+		rp_ary = (struct rpcrdma_write_array *)&rch->rc_target;
+
+		goto found_it;
+	}
+
+	wr_ary = svc_rdma_get_write_array(rmsgp);
+	if (wr_ary) {
+		rp_ary = (struct rpcrdma_write_array *)
+			&wr_ary->
+			wc_array[wr_ary->wc_nchunks].wc_target.rs_length;
+
+		goto found_it;
+	}
+
+	/* No read list, no write list */
+	rp_ary = (struct rpcrdma_write_array *)
+		&rmsgp->rm_body.rm_chunks[2];
+
+ found_it:
+	if (rp_ary->wc_discrim == 0)
+		return NULL;
+
+	return rp_ary;
+}
+#endif
-- 
1.5.4.rc2.60.gb2e62

