Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:65361 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbbAMQDj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:03:39 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 08/10] svcrdma: Support RDMA_NOMSG requests
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:03:37 -0500
Message-ID: <20150113160336.8118.32990.stgit@klimt.1015granger.net>
In-Reply-To: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
References: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the Linux server can not decode RDMA_NOMSG type requests.
Operations whose length exceeds the fixed size of RDMA SEND buffers,
like large NFSv4 CREATE(NF4LNK) operations, must be conveyed via
RDMA_NOMSG.

For an RDMA_MSG type request, the client sends the RPC/RDMA, RPC
headers, and some or all of the NFS arguments via RDMA SEND.

For an RDMA_NOMSG type request, the client sends just the RPC/RDMA
header via RDMA SEND. The request's read list contains elements for
the entire RPC message, including the RPC header.

NFSD expects the RPC/RMDA header and RPC header to be contiguous in
page zero of the XDR buffer. Add logic in the RDMA READ path to make
the read list contents land where the server prefers, when the
incoming message is a type RDMA_NOMSG message.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h         |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   39 +++++++++++++++++++++++++++++--
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index f161e30..c343a94 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -79,6 +79,7 @@ struct svc_rdma_op_ctxt {
 	enum ib_wr_opcode wr_op;
 	enum ib_wc_status wc_status;
 	u32 byte_len;
+	u32 position;
 	struct svcxprt_rdma *xprt;
 	unsigned long flags;
 	enum dma_data_direction direction;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index a67dd1a..36cf51a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -60,6 +60,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 			       struct svc_rdma_op_ctxt *ctxt,
 			       u32 byte_count)
 {
+	struct rpcrdma_msg *rmsgp;
 	struct page *page;
 	u32 bc;
 	int sge_no;
@@ -82,7 +83,14 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	/* If data remains, store it in the pagelist */
 	rqstp->rq_arg.page_len = bc;
 	rqstp->rq_arg.page_base = 0;
-	rqstp->rq_arg.pages = &rqstp->rq_pages[1];
+
+	/* RDMA_NOMSG: RDMA READ data should land just after RDMA RECV data */
+	rmsgp = (struct rpcrdma_msg *)rqstp->rq_arg.head[0].iov_base;
+	if (be32_to_cpu(rmsgp->rm_type) == RDMA_NOMSG)
+		rqstp->rq_arg.pages = &rqstp->rq_pages[0];
+	else
+		rqstp->rq_arg.pages = &rqstp->rq_pages[1];
+
 	sge_no = 1;
 	while (bc && sge_no < ctxt->count) {
 		page = ctxt->pages[sge_no];
@@ -383,7 +391,6 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	 */
 	head->arg.head[0] = rqstp->rq_arg.head[0];
 	head->arg.tail[0] = rqstp->rq_arg.tail[0];
-	head->arg.pages = &head->pages[head->count];
 	head->hdr_count = head->count;
 	head->arg.page_base = 0;
 	head->arg.page_len = 0;
@@ -393,9 +400,17 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
 	position = be32_to_cpu(ch->rc_position);
 
+	/* RDMA_NOMSG: RDMA READ data should land just after RDMA RECV data */
+	if (position == 0) {
+		head->arg.pages = &head->pages[0];
+		page_offset = head->byte_len;
+	} else {
+		head->arg.pages = &head->pages[head->count];
+		page_offset = 0;
+	}
+
 	ret = 0;
 	page_no = 0;
-	page_offset = 0;
 	for (; ch->rc_discrim != xdr_zero; ch++) {
 		if (be32_to_cpu(ch->rc_position) != position)
 			goto err;
@@ -418,7 +433,10 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 			head->arg.buflen += ret;
 		}
 	}
+
 	ret = 1;
+	head->position = position;
+
  err:
 	/* Detach arg pages. svc_recv will replenish them */
 	for (page_no = 0;
@@ -465,6 +483,21 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 		put_page(rqstp->rq_pages[page_no]);
 		rqstp->rq_pages[page_no] = head->pages[page_no];
 	}
+
+	/* Adjustments made for RDMA_NOMSG type requests */
+	if (head->position == 0) {
+		if (head->arg.len <= head->sge[0].length) {
+			head->arg.head[0].iov_len = head->arg.len -
+							head->byte_len;
+			head->arg.page_len = 0;
+		} else {
+			head->arg.head[0].iov_len = head->sge[0].length -
+								head->byte_len;
+			head->arg.page_len = head->arg.len -
+						head->sge[0].length;
+		}
+	}
+
 	/* Point rq_arg.pages past header */
 	rdma_fix_xdr_pad(&head->arg);
 	rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];

