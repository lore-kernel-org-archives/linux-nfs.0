From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 03/10] rdma: SVCRMDA Header File
Date: Mon, 20 Aug 2007 11:58:07 -0500
Message-ID: <20070820165807.15938.65201.stgit@dell3.ogc.int>
References: <20070820165635.15938.57184.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INAZw-0001zx-VQ
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:13 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INAZx-00051s-Kn
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:14 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id C22717C79E
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:58:07 -0500 (CDT)
In-Reply-To: <20070820165635.15938.57184.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


This file defines the data types used by the SVCRDMA transport module.
The principle data structure is the transport specific extension to 
the svcxprt structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_rdma.h |  261 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 261 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
new file mode 100644
index 0000000..0bad94b
--- /dev/null
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -0,0 +1,261 @@
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
+/* RPC/RDMA parameters */
+extern unsigned int svcrdma_ord;
+extern unsigned int svcrdma_max_requests;
+extern unsigned int svcrdma_max_req_size;
+extern unsigned int rdma_stat_recv;
+extern unsigned int rdma_stat_read;
+extern unsigned int rdma_stat_write;
+extern unsigned int rdma_stat_sq_starve;
+extern unsigned int rdma_stat_rq_starve;
+extern unsigned int rdma_stat_rq_poll;
+extern unsigned int rdma_stat_rq_prod;
+extern unsigned int rdma_stat_sq_poll;
+extern unsigned int rdma_stat_sq_prod;
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
+struct svc_rdma_deferred_req {
+	struct svc_deferred_req req;
+	struct page *arg_page;
+	int arg_len;
+};
+
+struct svcxprt_rdma {
+	struct svc_sock      sc_xprt;	       /* SVC transport structure */
+	struct rdma_cm_id    *sc_cm_id;	       /* RDMA connection id */
+	struct list_head     sc_accept_q;      /* Conn. waiting accept */
+	int                  sc_ord;	       /* RDMA read limit */
+	wait_queue_head_t    sc_read_wait;
+	int                  sc_max_sge;
+
+	int                  sc_sq_depth;      /* Depth of SQ */
+	atomic_t             sc_sq_count;      /* Number of SQ WR on queue */
+
+	int                  sc_max_requests;  /* Depth of RQ */
+	int                  sc_max_req_size;  /* Size of each RQ WR buf */
+
+	struct ib_pd         *sc_pd;
+
+	struct svc_rdma_op_ctxt  *sc_ctxt_head;
+	int		     sc_ctxt_cnt;
+	int		     sc_ctxt_bump;
+	int		     sc_ctxt_max;
+	spinlock_t           sc_ctxt_lock;
+	struct list_head     sc_rq_dto_q;
+	spinlock_t           sc_rq_dto_lock;
+	struct ib_qp         *sc_qp;
+	struct ib_cq         *sc_rq_cq;
+	struct ib_cq         *sc_sq_cq;
+	struct ib_mr         *sc_phys_mr;      /* MR for server memory */
+
+	spinlock_t           sc_lock;
+
+	wait_queue_head_t    sc_send_wait;     /* SQ exhaustion waitlist */
+	int		     sc_flags;
+	struct list_head     sc_dto_q;         /* DTO tasklet I/O pending */
+	struct list_head     sc_read_complete_q;
+	spinlock_t           sc_read_complete_lock;
+};
+/* sc_flags */
+#define RDMAXPRT_RQ_PENDING	1
+#define RDMAXPRT_SQ_PENDING	2
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
+extern void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *, int *, int *);
+extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg**, struct svc_rqst *);
+extern int svc_rdma_xdr_decode_deferred_req(struct svc_rqst *);
+extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma*, struct rpcrdma_msg*,
+				     enum rpcrdma_errcode, u32*);
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
+extern int svc_rdma_recvfrom(struct svc_rqst*);
+
+/* svc_rdma_sendto.c */
+extern int svc_rdma_sendto(struct svc_rqst*);
+
+/* svc_rdma_transport.c */
+extern int svc_rdma_send(struct svcxprt_rdma*, struct ib_send_wr*);
+extern int svc_rdma_send_error(struct svcxprt_rdma*, struct rpcrdma_msg*,
+			       enum rpcrdma_errcode);
+struct page* svc_rdma_get_page(void);
+extern int svc_rdma_post_recv(struct svcxprt_rdma*);
+extern int svc_rdma_create_listen(struct svc_serv*, int, struct sockaddr*);
+extern struct svc_rdma_op_ctxt *svc_rdma_get_context(struct svcxprt_rdma *);
+extern void svc_rdma_put_context(struct svc_rdma_op_ctxt *, int);
+extern void svc_sq_reap(struct svcxprt_rdma*);
+extern void svc_rq_reap(struct svcxprt_rdma*);
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
+			rch ++;
+
+		/* The reply list follows an empty write array located
+		 * at 'rc_position' here. The reply array is at rc_target.
+		 */
+		rp_ary = (struct rpcrdma_write_array*)&rch->rc_target;
+
+		goto found_it;
+	}
+
+	wr_ary = svc_rdma_get_write_array(rmsgp);
+	if (wr_ary) {
+		rp_ary = (struct rpcrdma_write_array*)
+			&wr_ary->wc_array[wr_ary->wc_nchunks].wc_target.rs_length;
+
+		goto found_it;
+	}
+
+	/* No read list, no write list */
+	rp_ary = (struct rpcrdma_write_array*)
+		&rmsgp->rm_body.rm_chunks[2];
+
+ found_it:
+	if (rp_ary->wc_discrim == 0)
+		return NULL;
+
+	return rp_ary;
+}
+#endif

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
