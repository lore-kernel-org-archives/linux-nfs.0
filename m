From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC, PATCH 15/15] knfsd: RDMA transport debug macros
Date: Fri, 18 May 2007 12:46:22 -0500
Message-ID: <1179510382.23385.127.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp6XB-00012K-8C
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:46:33 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6X8-0008To-3j
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:46:31 -0700
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


This file implements a set of debug macros for dumping RDMA work
requests, protocol headers, etc... Their utility is hopefully somewhat
short-lived.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_rdma_debug.h |  393 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 393 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc_rdma_debug.h b/net/sunrpc/svc_rdma_debug.h
new file mode 100644
index 0000000..1819af2
--- /dev/null
+++ b/net/sunrpc/svc_rdma_debug.h
@@ -0,0 +1,393 @@
+/*
+ * Copyright (c) 2003-2006 Network Appliance, Inc. All rights reserved.
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
+#ifndef SVC_RDMA_DBG_H
+#define SVC_RDMA_DBG_H
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/rpc_rdma.h>
+#include <asm/unaligned.h>
+
+#ifdef SVCRDMA_DEBUG
+
+#define RPCDBG_FACILITY RPCDBG_RDMA
+
+static inline void DBG_DUMP_RDMAHDR(const char *s, void *va)
+{
+	struct rpcrdma_msg *rmsgp = va;
+	struct rpcrdma_write_array *wr_ary;
+	struct rpcrdma_read_chunk *rd_ch;
+
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	printk("[%s] RPCRDMA Header %p\n", s, rmsgp);
+	printk("\txid       : 0x%08x\n", rmsgp->rm_xid);
+	printk("\tversion   : %d\n", rmsgp->rm_vers);
+	printk("\tcredits   : %d\n", rmsgp->rm_credit);
+	printk("\trdma_type : %d\n", rmsgp->rm_type);
+
+	printk("\tread-list\n");
+	rd_ch = (struct rpcrdma_read_chunk *)
+		&rmsgp->rm_body.rm_chunks[0];
+	if (rd_ch->rc_discrim == 0)
+		printk("\t\t<nul>\n");
+	else {
+		for (;rd_ch->rc_discrim != 0; rd_ch++) {
+			printk("\t\tdiscrim  : %d\n",
+			       rd_ch->rc_discrim);
+			printk("\t\tposition : %d\n",
+			       rd_ch->rc_position);
+			printk("\t\thandle   : 0x%08x\n",
+			       rd_ch->rc_target.rs_handle);
+			printk("\t\tlength   : %d\n",
+			       rd_ch->rc_target.rs_length);
+			printk("\t\toffset   : 0x%016llx\n",
+			       get_unaligned(&(rd_ch->rc_target.rs_offset)));
+		}
+	}
+
+	printk("\twrite-array\n");
+	wr_ary = (struct rpcrdma_write_array*)
+		&rd_ch->rc_position;
+	if (wr_ary->wc_discrim == 0) {
+		printk("\t\t<null>\n");
+		wr_ary = (struct rpcrdma_write_array*)
+			&wr_ary->wc_nchunks;
+	} else {
+		int i;
+
+		printk("\t\tdiscrim  : %d\n", wr_ary->wc_discrim);
+		printk("\t\tnchunks  : %d\n", wr_ary->wc_nchunks);
+		for (i=0; i < wr_ary->wc_nchunks; i++) {
+			printk("\t\t\thandle  : 0x%08x\n",
+			       wr_ary->wc_array[i].wc_target.rs_handle);
+			printk("\t\t\tlength  : %d\n",
+			       wr_ary->wc_array[i].wc_target.rs_length);
+			printk("\t\t\toffset  : 0x%016llx\n",
+			       get_unaligned(&(wr_ary->wc_array[i].wc_target.rs_offset)));
+		}
+		wr_ary = (struct rpcrdma_write_array*)
+			&wr_ary->wc_array[wr_ary->wc_nchunks].wc_target.rs_length;
+	}
+
+	printk("\treply-array\n");
+	if (wr_ary->wc_discrim == 0)
+		printk("\t\t<null>\n");
+	else {
+		int i;
+		printk("\t\tdiscrim  : %d\n", wr_ary->wc_discrim);
+		printk("\t\tnchunks  : %d\n", wr_ary->wc_nchunks);
+		for (i=0; i < wr_ary->wc_nchunks; i++) {
+			printk("\t\t\thandle  : 0x%08x\n",
+			       wr_ary->wc_array[i].wc_target.rs_handle);
+			printk("\t\t\tlength  : %d\n",
+			       wr_ary->wc_array[i].wc_target.rs_length);
+			printk("\t\t\toffset  : 0x%016llx\n",
+			       get_unaligned(&(wr_ary->wc_array[i].wc_target.rs_offset)));
+		}
+	}
+}
+
+static inline void DBG_DUMP_RDMAHDR_NBO(const char *s, void *va)
+{
+	struct rpcrdma_msg *rmsgp = va;
+	struct rpcrdma_write_array *wr_ary;
+	struct rpcrdma_read_chunk *rd_ch;
+
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	printk("[%s] RPCRDMA Header %p\n", s, rmsgp);
+	printk("\txid       : 0x%08x\n", ntohl(rmsgp->rm_xid));
+	printk("\tversion   : %d\n", ntohl(rmsgp->rm_vers));
+	printk("\tcredits   : %d\n", ntohl(rmsgp->rm_credit));
+	printk("\trdma_type : %d\n", ntohl(rmsgp->rm_type));
+
+	printk("\tread-list\n");
+	rd_ch = (struct rpcrdma_read_chunk *)
+		&rmsgp->rm_body.rm_chunks[0];
+	if (rd_ch->rc_discrim == 0)
+		printk("\t\t<nul>\n");
+	else {
+		for (;rd_ch->rc_discrim != 0; rd_ch++) {
+			printk("\t\tdiscrim  : %d\n",
+			       ntohl(rd_ch->rc_discrim));
+			printk("\t\tposition : %d\n",
+			       ntohl(rd_ch->rc_position));
+			printk("\t\thandle   : 0x%08x\n",
+			       ntohl(rd_ch->rc_target.rs_handle));
+			printk("\t\tlength   : %d\n",
+			       ntohl(rd_ch->rc_target.rs_length));
+			printk("\t\toffset   : 0x%016llx\n",
+			       get_unaligned(&(rd_ch->rc_target.rs_offset)));
+		}
+	}
+
+	printk("\twrite-array\n");
+	wr_ary = (struct rpcrdma_write_array*)
+		&rd_ch->rc_position;
+	if (wr_ary->wc_discrim == 0) {
+		printk("\t\t<null>\n");
+		wr_ary = (struct rpcrdma_write_array*)
+			&wr_ary->wc_nchunks;
+	} else {
+		int i;
+
+		printk("\t\tdiscrim  : %d\n", ntohl(wr_ary->wc_discrim));
+		printk("\t\tnchunks  : %d\n", ntohl(wr_ary->wc_nchunks));
+		for (i=0; i < ntohl(wr_ary->wc_nchunks); i++) {
+			printk("\t\t\thandle  : 0x%08x\n",
+			       ntohl(wr_ary->wc_array[i].wc_target.rs_handle));
+			printk("\t\t\tlength  : %d\n",
+			       htonl(wr_ary->wc_array[i].wc_target.rs_length));
+			printk("\t\t\toffset  : 0x%016llx\n",
+			       get_unaligned(&(wr_ary->wc_array[i].wc_target.rs_offset)));
+		}
+		wr_ary = (struct rpcrdma_write_array*)
+			&wr_ary->wc_array[ntohl(wr_ary->wc_nchunks)].wc_target.rs_length;
+	}
+
+	printk("\treply-array\n");
+	if (wr_ary->wc_discrim == 0)
+		printk("\t\t<null>\n");
+	else {
+		int i;
+		printk("\t\tdiscrim  : %d\n", ntohl(wr_ary->wc_discrim));
+		printk("\t\tnchunks  : %d\n", ntohl(wr_ary->wc_nchunks));
+		for (i=0; i < ntohl(wr_ary->wc_nchunks); i++) {
+			printk("\t\t\thandle  : 0x%08x\n",
+			       ntohl(wr_ary->wc_array[i].wc_target.rs_handle));
+			printk("\t\t\tlength  : %d\n",
+			       ntohl(wr_ary->wc_array[i].wc_target.rs_length));
+			printk("\t\t\toffset  : 0x%016llx\n",
+			       get_unaligned(&(wr_ary->wc_array[i].wc_target.rs_offset)));
+		}
+	}
+}
+
+static const char *wc_status_str[] = {
+	"SUCCESS",
+	"LOC_LEN_ERR",
+	"LOC_QP_OP_ERR",
+	"LOC_EEC_OP_ERR",
+	"LOC_PROT_ERR",
+	"WR_FLUSH_ERR",
+	"MW_BIND_ERR",
+	"BAD_RESP_ERR",
+	"LOC_ACCESS_ERR",
+	"REM_INV_REQ_ERR",
+	"REM_ACCESS_ERR",
+	"REM_OP_ERR",
+	"RETRY_EXC_ERR",
+	"RNR_RETRY_EXC_ERR",
+	"LOC_RDD_VIOL_ERR",
+	"REM_INV_RD_REQ_ERR",
+	"REM_ABORT_ERR",
+	"INV_EECN_ERR",
+	"INV_EEC_STATE_ERR",
+	"FATAL_ERR",
+	"RESP_TIMEOUT_ERR",
+	"GENERAL_ERR"
+};
+
+static const char *wc_opcode_str[] = {
+	"SEND",
+	"RDMA_WRITE",
+	"RDMA_READ",
+	"COMP_SWAP",
+	"FETCH_ADD",
+	"BIND_MW",
+	"RECV",
+	"RECV_RDMA_WITH_IMM",
+};
+
+static inline const char *wc_opcode_to_str(int op)
+{
+
+	if (op < 0 || op > 129)
+		return "<trash>";
+	else if (op >= 128)
+		op -= 122;
+	return wc_opcode_str[op];
+}
+
+static inline void DBG_DUMP_WC(const char *s, struct ib_wc *wc)
+{
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	printk("\t[%s] Work Completion:\n", s);
+	printk("\twr_id           : %llx\n", wc->wr_id);
+	printk("\tstatus          : \"%s\"\n", wc_status_str[wc->status]);
+	printk("\topcode          : %s\n", wc_opcode_to_str(wc->opcode));
+	printk("\tvendor_err      : %d\n", wc->vendor_err);
+	printk("\tbyte_len        : %d\n", wc->byte_len);
+	printk("\timm_data        : %d\n", wc->imm_data);
+	printk("\tsrc_qp          : %d\n", wc->src_qp);
+	printk("\twc_flags        : %x\n", wc->wc_flags);
+	printk("\tpkey_index      : %d\n", wc->pkey_index);
+	printk("\tslid            : %d\n", wc->slid);
+	printk("\tsl              : %d\n", wc->sl);
+	printk("\tdlid_path_bits  : %d\n", wc->dlid_path_bits);
+	printk("\tport_num        : %d\n", wc->port_num);
+}
+
+static inline void DBG_DUMP_QP(const char *s,
+			       struct ib_qp *qp, struct ib_qp_init_attr *attr)
+{
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	printk("[%s] QP Attributes\n", s);
+	printk("\tqp                : %p\n", qp);
+	printk("\tevent_handler     : %p\n", attr->event_handler);
+	printk("\tqp_context        : %p\n", attr->qp_context);
+	printk("\tcap.max_send_wr   : %d\n", attr->cap.max_send_wr);
+	printk("\tcap.max_recv_wr   : %d\n", attr->cap.max_recv_wr);
+	printk("\tcap.max_send_sge  : %d\n", attr->cap.max_send_sge);
+	printk("\tcap.max_recv_sge  : %d\n", attr->cap.max_recv_sge);
+	printk("\tsq_sig_type       : %d\n", attr->sq_sig_type);
+	printk("\tqp_type           : %d\n", attr->qp_type);
+	printk("\tsend_cq           : %p\n", attr->send_cq);
+	printk("\trecv_cq           : %p\n", attr->recv_cq);
+}
+
+static inline void DBG_DUMP_XDR(const char *s, struct xdr_buf *xdr)
+{
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	printk("[%s] XDR Description\n", s);
+	printk("\tlen                : %d\n", xdr->len);
+	printk("\tbuflen             : %d\n", xdr->buflen);
+	printk("\thead[0].iov_base   : %p\n", xdr->head[0].iov_base);
+	printk("\thead[0].iov_len    : %zd\n", xdr->head[0].iov_len);
+	printk("\tpage_base          : %d\n", xdr->page_base);
+	printk("\tpage_len           : %d\n", xdr->page_len);
+	printk("\ttail[0].iov_base   : %p\n", xdr->tail[0].iov_base);
+	printk("\ttail[0].iov_len    : %zd\n", xdr->tail[0].iov_len);
+}
+
+static inline void DBG_DUMP_XDR_DATA(const char *s, struct xdr_buf *xdr)
+{
+	u32 i;
+	u32 j;
+	struct kvec *vec = &xdr->head[0];
+	u8* va;
+
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	/* Head */
+	va = vec->iov_base;
+	printk("[%s] IOV Data\n", s);
+	printk("\thead[0].iov_base=%p, head[0].iov_len=%zd\n", va, vec->iov_len);
+	for (i=0; i < vec->iov_len; i+=16) {
+		printk("\t");
+		for (j=0; ((i+j) < vec->iov_len) && (j < 16); j++)
+			printk("%02x ", *va++);
+		printk("\n");
+	}
+
+	/* Pages */
+	printk("\tpage=%p, page_base=%d, page_len=%d\n",
+	       xdr->pages[0], xdr->page_base, xdr->page_len);
+	if (xdr->page_len && xdr->pages[0]) {
+		unsigned long long pa;
+
+		va = page_address(xdr->pages[0]);
+		if (va) {
+			va += xdr->page_base;
+			pa = page_to_phys(xdr->pages[0]);
+			for (i=0; i < min((size_t)256, (size_t)xdr->page_len); i+=16) {
+				printk("%p: ", va);
+				for (j=0;
+				     (i+j) < min((size_t)256, (size_t)xdr->page_len) && j < 16;
+				     j++)
+					printk("%02x ", *va++);
+				printk("\n");
+			}
+		} else
+			printk("page data not mapped!\n");
+	}
+
+	/* tail */
+	vec = &xdr->tail[0];
+	va = vec->iov_base;
+	printk("[%s] IOV Data\n", s);
+	printk("\ttail[0].iov_base=%p, tail[0].iov_len=%zd\n", va, vec->iov_len);
+	for (i=0; i < vec->iov_len; i+=16) {
+		printk("\t");
+		for (j=0; ((i+j) < vec->iov_len) && (j < 16); j++)
+			printk("%02x ", *va++);
+		printk("\n");
+	}
+}
+
+static inline void DBG_DUMP_SGE(const char *s, int count, struct ib_sge *sge)
+{
+	int i;
+
+	if (likely((rpc_debug & RPCDBG_FACILITY)==0))
+		return;
+
+	printk("[%s] SGE Contents, count=%d\n", s, count);
+	for (i=0; i < count; i++) {
+		printk("\tsge[%d].addr   : %llx\n", i, sge->addr);
+		printk("\tsge[%d].length : %d\n", i, sge->length);
+		printk("\tsge[%d].lkey   : %08x\n", i, sge->lkey);
+		sge ++;
+	}
+}
+
+#else
+
+#define DPRINTK(...)
+#define DBG_DUMP_SGE(s,n,e)
+#define DBG_DUMP_QP(s,q,a)
+#define DBG_DUMP_RDMAHDR(s,v)
+#define DBG_DUMP_RDMAHDR_NBO(s,v)
+#define DBG_DUMP_XDR(s,x)
+#define DBG_DUMP_XDR_DATA(s,x)
+#define DBG_DUMP_WC(s, w)
+
+#endif
+#endif


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
