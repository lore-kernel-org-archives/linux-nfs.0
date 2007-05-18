From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 12/15] knfsd: RDMA transport recvfrom
Date: Fri, 18 May 2007 12:46:01 -0500
Message-ID: <1179510361.23385.124.camel@trinity.ogc.int>
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
	id 1Hp6Wj-0000z8-8G
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:46:05 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6Wl-0008Lp-6r
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:46:08 -0700
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


This file implements the RDMA transport recvfrom function. The function
de-queues work reqeust completion contexts from an I/O list that it shares
with the I/O tasklet in svc_rdma_transport.c. For ONCRPC RDMA, an RPC may 
not be complete when it is received. Instead, the RDMA header that precedes 
the RPC message informs the transport where to get the RPC data from on 
the client and where to place it in the RPC message before it is delivered 
to the server. The svc_rdma_recvfrom function therefore, parses this RDMA 
header and issues any necessary RDMA operations to fetch the remainder of 
the RPC from the client.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svc_rdma_recvfrom.c |  558 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 558 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svc_rdma_recvfrom.c b/net/sunrpc/svc_rdma_recvfrom.c
new file mode 100644
index 0000000..788daa7
--- /dev/null
+++ b/net/sunrpc/svc_rdma_recvfrom.c
@@ -0,0 +1,558 @@
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
+#include <asm/semaphore.h>
+#include <linux/device.h>
+#include <linux/in.h>
+#include <linux/err.h>
+#include <linux/time.h>
+
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/debug.h>
+#include <linux/sunrpc/rpc_rdma.h>
+#include <linux/mm.h>		/* num_physpages */
+#include <linux/spinlock.h>
+#include <linux/net.h>
+#include <net/sock.h>
+#include <asm/io.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/rdma_cm.h>
+#include <linux/sunrpc/svc_rdma.h>
+#include "svc_rdma_debug.h"
+
+/*
+ * Replace the pages in the rq_argpages array with the pages from the SGE in
+ * the RDMA_RECV completion. The SGL should contain full pages up until the
+ * last one.
+ */
+static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
+			       struct svc_rdma_op_ctxt *ctxt,
+			       u32 byte_count)
+{
+	struct page *page;
+	u32 bc;
+	int sge_no;
+
+	/* Swap the page in the SGE with the page in argpages */
+	page = ctxt->pages[0];
+	put_page(rqstp->rq_pages[0]);
+	rqstp->rq_pages[0] = page;
+
+	/* Set up the XDR head */
+	rqstp->rq_arg.head[0].iov_base = page_address(page);
+	rqstp->rq_arg.head[0].iov_len = min(byte_count, ctxt->sge[0].length);
+	rqstp->rq_arg.len = byte_count;
+	rqstp->rq_arg.buflen = byte_count;
+
+	/* Compute bytes past head in the SGL */
+	bc = byte_count - rqstp->rq_arg.head[0].iov_len;
+
+	/* If data remains, store it in the pagelist */
+	rqstp->rq_arg.page_len = bc;
+	rqstp->rq_arg.page_base = 0;
+	rqstp->rq_arg.pages = &rqstp->rq_pages[1];
+	sge_no = 1;
+	while (bc && sge_no < ctxt->count) {
+		page = ctxt->pages[sge_no];
+		put_page(rqstp->rq_pages[sge_no]);
+		rqstp->rq_pages[sge_no] = page;
+		bc -= min(bc, ctxt->sge[sge_no].length);
+		rqstp->rq_arg.buflen += ctxt->sge[sge_no].length;
+		sge_no ++;
+	}
+	rqstp->rq_respages = &rqstp->rq_pages[sge_no];
+
+	/* We should never run out of SGE because the limit is defined to
+	 * support the max allowed RPC data length
+	 */
+	BUG_ON(bc && (sge_no == ctxt->count));
+	BUG_ON((rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len)
+	       != byte_count);
+	BUG_ON(rqstp->rq_arg.len != byte_count);
+
+	/* If not all pages were used from the SGL, free the remaining ones */
+	while (sge_no < ctxt->count) {
+		page = ctxt->pages[sge_no++];
+		put_page(page);
+	}
+
+	/* Set up tail */
+	rqstp->rq_arg.tail[0].iov_base = NULL;
+	rqstp->rq_arg.tail[0].iov_len = 0;
+}
+
+struct chunk_sge {
+	int start;		/* sge no for this chunk */
+	int count;		/* sge count for this chunk */
+};
+
+/* Encode a read-chunk-list as an array of IB SGE
+ *
+ * Assumptions:
+ * - chunk[0]->position points to pages[0] at an offset of 0
+ * - pages[] is not physically or virtually contigous and consists of
+ *   PAGE_SIZE elements.
+ *
+ * Output:
+ * - sge array pointing into pages[] array.
+ * - chunk_sge array specifying sge index and count for each
+ *   chunk in the read list
+ *
+ */
+static int rdma_rcl_to_sge(struct svcxprt_rdma *xprt,
+			   struct svc_rqst *rqstp,
+			   struct rpcrdma_msg *rmsgp,
+			   struct ib_sge *sge,
+			   struct chunk_sge *ch_sge_ary,
+			   int ch_count,
+			   int byte_count)
+{
+	int sge_no;
+	int sge_bytes;
+	int page_off;
+	int page_no;
+	int ch_bytes;
+	int ch_no;
+	struct rpcrdma_read_chunk *ch;
+
+	sge_no = 0;
+	page_no = 0;
+	page_off = 0;
+	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
+	ch_no = 0;
+	ch_bytes = ch->rc_target.rs_length;
+	ch_sge_ary[0].start = 0;
+	while (byte_count) {
+		sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
+		sge[sge_no].addr =
+			ib_dma_map_page(xprt->sc_cm_id->device,
+					rqstp->rq_arg.pages[page_no],
+					page_off, sge_bytes,
+					DMA_FROM_DEVICE);
+		sge[sge_no].length = sge_bytes;
+		sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
+		rqstp->rq_respages = &rqstp->rq_arg.pages[page_no+1];
+
+		byte_count -= sge_bytes;
+		ch_bytes -= sge_bytes;
+		sge_no ++;
+
+		if (ch_bytes == 0) {
+			ch_sge_ary[ch_no].count =
+				sge_no - ch_sge_ary[ch_no].start;
+			ch_no ++;
+			ch++;
+			ch_sge_ary[ch_no].start = sge_no;
+			ch_bytes = ch->rc_target.rs_length;
+		}
+		if ((sge_bytes + page_off) == PAGE_SIZE) {
+			page_no ++;
+			page_off = 0;
+		} else
+			page_off += sge_bytes;
+	}
+	BUG_ON(byte_count != 0);
+	return sge_no;
+}
+
+static void rdma_set_ctxt_sge(struct svc_rdma_op_ctxt *ctxt,
+			      struct ib_sge *sge,
+			      u64 *sgl_offset,
+			      int count)
+{
+	int i;
+
+	ctxt->count = count;
+	for (i = 0; i < count; i++) {
+		ctxt->sge[i].addr = sge[i].addr;
+		ctxt->sge[i].length = sge[i].length;
+		*sgl_offset = *sgl_offset + sge[i].length;
+	}
+}
+
+static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
+{
+#ifdef RDMA_TRANSPORT_IWARP
+	if ((RDMA_TRANSPORT_IWARP ==
+	     rdma_node_get_transport(xprt->sc_cm_id->
+				     device->node_type))
+	    && sge_count > 1)
+		return 1;
+	else
+#endif
+		return min_t(int, sge_count, xprt->sc_max_sge);
+}
+
+/*
+ * Use RDMA_READ to read data from the advertised client buffer into the
+ * XDR stream starting at rq_arg.head[0].iov_base.
+ * Each chunk in the array
+ * contains the following fields:
+ * discrim      - '1', This isn't used for data placement
+ * position     - The xdr stream offset (the same for every chunk)
+ * handle       - RMR for client memory region
+ * length       - data transfer length
+ * offset       - 64 bit tagged offset in remote memory region
+ *
+ * On our side, we need to read into a pagelist. The first page immediately
+ * follows the RPC header.
+ *
+ */
+static int rdma_read_xdr(struct svcxprt_rdma *xprt,
+			 struct rpcrdma_msg *rmsgp,
+			 struct svc_rqst *rqstp)
+{
+	struct ib_send_wr read_wr;
+	int ret = 0;
+	int ch_no;
+	struct ib_sge *sge;
+	int ch_count;
+	int byte_count;
+	int sge_count;
+	u64 sgl_offset;
+	struct rpcrdma_read_chunk *ch;
+	struct svc_rdma_op_ctxt *ctxt = NULL;
+	struct svc_rdma_op_ctxt *prev_ctxt;
+	struct svc_rdma_op_ctxt *tmp_sge_ctxt;
+	struct svc_rdma_op_ctxt *tmp_ch_ctxt;
+	struct chunk_sge *ch_sge_ary;
+
+	/* If no read list is present, return 0 */
+	ch = svc_rdma_get_read_chunk(rmsgp);
+	if (!ch)
+		return 0;
+
+	/* Allocate temporary contexts to keep SGE */
+	BUG_ON(sizeof(struct ib_sge) < sizeof(struct chunk_sge));
+	tmp_sge_ctxt = svc_rdma_get_context(xprt);
+	sge = tmp_sge_ctxt->sge;
+	tmp_ch_ctxt = svc_rdma_get_context(xprt);
+	ch_sge_ary = (struct chunk_sge*)tmp_ch_ctxt->sge;
+
+	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
+	sge_count = rdma_rcl_to_sge(xprt, rqstp, rmsgp, sge, ch_sge_ary,
+				    ch_count, byte_count);
+	sgl_offset = 0;
+	ch_no = 0;
+	prev_ctxt = NULL;
+	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
+	     ch->rc_discrim != 0; ch++, ch_no++) {
+	next_sge:
+		ctxt = svc_rdma_get_context(xprt);
+		ctxt->direction = DMA_FROM_DEVICE;
+		ctxt->count = 0;
+		ctxt->next = prev_ctxt;
+		clear_bit(RDMACTXT_F_READ_DONE, &ctxt->flags);
+		init_waitqueue_head(&ctxt->read_wait);
+
+		/* Prepare READ WR */
+		memset(&read_wr, 0, sizeof read_wr);
+		ctxt->wr_op = IB_WR_RDMA_READ;
+		read_wr.wr_id = (unsigned long)ctxt;
+		read_wr.opcode = IB_WR_RDMA_READ;
+		read_wr.send_flags = IB_SEND_SIGNALED;
+		read_wr.wr.rdma.rkey = ch->rc_target.rs_handle;
+		read_wr.wr.rdma.remote_addr =
+			get_unaligned(&(ch->rc_target.rs_offset)) +
+			sgl_offset;
+		read_wr.sg_list = &sge[ch_sge_ary[ch_no].start];
+		read_wr.num_sge =
+			rdma_read_max_sge(xprt, ch_sge_ary[ch_no].count);
+		rdma_set_ctxt_sge(ctxt, &sge[ch_sge_ary[ch_no].start],
+				  &sgl_offset,
+				  read_wr.num_sge);
+
+		/* Throttle RDMA_READ to the ORD limit */
+		while (svcrdma_read_throttle) {
+			unsigned long flags;
+			spin_lock_irqsave(&xprt->sc_read_lock, flags);
+			if (atomic_read(&xprt->sc_read_count) < xprt->sc_ord) {
+				atomic_inc(&xprt->sc_read_count);
+				spin_unlock_irqrestore(&xprt->sc_read_lock, flags);
+				break;
+			} else {
+				spin_unlock_irqrestore(&xprt->sc_read_lock, flags);
+				wait_event(xprt->sc_read_wait,
+					   atomic_read(&xprt->sc_read_count) < xprt->sc_ord);
+			}
+		}
+		rdma_stat_read ++;
+		/* Post the read */
+		ret = svc_rdma_send(xprt, &read_wr);
+		if (ret) {
+			printk(KERN_ERR "svcrdma: Error posting send =%d\n", ret);
+			if (svcrdma_read_throttle)
+				atomic_dec(&xprt->sc_read_count);
+			svc_rdma_put_context(ctxt, 0);
+			ctxt = prev_ctxt;
+			ret = -EIO;
+			goto out;
+		}
+
+		prev_ctxt = ctxt;
+		if (read_wr.num_sge < ch_sge_ary[ch_no].count) {
+			ch_sge_ary[ch_no].count -= read_wr.num_sge;
+			ch_sge_ary[ch_no].start += read_wr.num_sge;
+			goto next_sge;
+		}
+		rqstp->rq_arg.page_len += ch->rc_target.rs_length;
+		rqstp->rq_arg.len += ch->rc_target.rs_length;
+		rqstp->rq_arg.buflen += ch->rc_target.rs_length;
+		sgl_offset = 0;
+		ret = 0;
+	}
+
+ out:
+	/* 
+	 * Wait 6 seconds for the last RDMA_READ to complete. If
+	 * the read times out, then we shut the connection
+	 * down. Chances are that the connection is already dead and
+	 * this is why the read did not complete. 
+	 */
+	if (ctxt && (wait_event_timeout(ctxt->read_wait,
+					test_bit(RDMACTXT_F_READ_DONE,
+						 &ctxt->flags),
+					msecs_to_jiffies(6000))==0)) {
+		printk(KERN_ERR
+		       "svcrdma: timeout waiting for RDMA_READ "
+		       "completion ctxt=%p, xprt=%p, test_bit=%d\n",
+		       ctxt, xprt, test_bit(RDMACTXT_F_READ_DONE,
+					    &ctxt->flags));
+		ret = ETIMEDOUT;
+	}
+
+	/* Free the linked list of read contexts */
+	while (ctxt != NULL) {
+		prev_ctxt = ctxt->next;
+		svc_rdma_put_context(ctxt,0);
+		ctxt = prev_ctxt;
+	}
+	if (ret)
+		set_bit(SK_CLOSE, &xprt->sc_xprt.sk_flags);
+
+	svc_rdma_put_context(tmp_sge_ctxt, 0);
+	svc_rdma_put_context(tmp_ch_ctxt, 0);
+	return ret;
+}
+
+static struct svc_deferred_req *
+svc_rdma_deferred_dequeue(struct svc_sock *xprt)
+{
+	struct svc_deferred_req *dr = NULL;
+	spin_lock_bh(&xprt->sk_server->sv_lock);
+	clear_bit(SK_DEFERRED, &xprt->sk_flags);
+	if (!list_empty(&xprt->sk_deferred)) {
+		dr = list_entry(xprt->sk_deferred.next,
+				struct svc_deferred_req,
+				handle.recent);
+		list_del_init(&dr->handle.recent);
+		set_bit(SK_DEFERRED, &xprt->sk_flags);
+	}
+	spin_unlock_bh(&xprt->sk_server->sv_lock);
+	return dr;
+}
+
+static int svc_rdma_deferred_recv(struct svc_rqst *rqstp)
+{
+	struct svc_sock *xprt = rqstp->rq_sock;
+	struct svcxprt_rdma *rdma_xprt = (struct svcxprt_rdma*)xprt;
+	struct svc_rdma_deferred_req *dr =
+		(struct svc_rdma_deferred_req *)rqstp->rq_deferred;
+	void *page_va;
+	int ret;
+	int len;
+
+	/* Rebuild the thread context */
+	rqstp->rq_prot = IPPROTO_MAX;
+	memcpy(&rqstp->rq_addr,
+	       &rdma_xprt->sc_cm_id->route.addr.dst_addr,
+	       sizeof(rqstp->rq_addr));
+	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
+
+	page_va = page_address(dr->arg_page);
+	dprintk("svcrdma: satisfying receive from deferred req=%p\n"
+		"\tpage=%p, page va=%p\n\targ_len=%d\n",
+		dr, dr->arg_page, page_va,
+		dr->arg_len);
+	DBG_DUMP_RDMAHDR(__FUNCTION__, page_va);
+
+	/* Replace page in rq_arg.head */
+	put_page(rqstp->rq_pages[0]);
+	rqstp->rq_pages[0] = dr->arg_page;
+	rqstp->rq_arg.head[0].iov_base = page_address(rqstp->rq_pages[0]);
+	rqstp->rq_arg.head[0].iov_len = dr->arg_len;
+	rqstp->rq_arg.tail[0].iov_base = NULL;
+	rqstp->rq_arg.tail[0].iov_len = 0;
+
+	/* There are no additional pages */
+	rqstp->rq_arg.pages = NULL;
+	rqstp->rq_arg.page_base = 0;
+	rqstp->rq_arg.page_len = 0;
+	rqstp->rq_arg.len = dr->arg_len;
+
+	/* Prep the response pages */
+	rqstp->rq_respages = &rqstp->rq_pages[1];
+
+	len = svc_rdma_xdr_decode_deferred_req(rqstp);
+	DBG_DUMP_XDR(__FUNCTION__, &rqstp->rq_arg);
+
+	ret = rqstp->rq_arg.head[0].iov_len
+		+ rqstp->rq_arg.page_len
+		+ rqstp->rq_arg.tail[0].iov_len;
+
+	rqstp->rq_deferred = NULL;
+	kfree(dr);
+
+	xprt->sk_pool = NULL;
+	BUG_ON(test_bit(SK_BUSY, &xprt->sk_flags)==0);
+	clear_bit(SK_BUSY, &xprt->sk_flags);
+	svc_sock_enqueue(xprt);
+	return ret;
+}
+
+/*
+ * Set up the rqstp thread context to point to the RQ buffer. If necessary,
+ * pull additional data from the client with an RDMA_READ request.
+ *
+ */
+int svc_rdma_recvfrom(struct svc_rqst *rqstp)
+{
+	struct svc_sock *xprt = rqstp->rq_sock;
+	struct svcxprt_rdma *rdma_xprt = (struct svcxprt_rdma*)xprt;
+	struct svc_rdma_op_ctxt *ctxt;
+	struct rpcrdma_msg *rmsgp;
+	int ret = 0;
+	int len;
+	unsigned long flags;
+
+	dprintk("svcrdma: rqstp=%p\n", rqstp);
+	if (unlikely(test_bit(SK_DEFERRED, &xprt->sk_flags)))
+		if ((rqstp->rq_deferred = svc_rdma_deferred_dequeue(xprt)))
+			return svc_rdma_deferred_recv(rqstp);
+
+	spin_lock_irqsave(&rdma_xprt->sc_rq_dto_lock, flags);
+	if(!list_empty(&rdma_xprt->sc_rq_dto_q)) {
+		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
+				  struct svc_rdma_op_ctxt,
+				  dto_q);
+		list_del_init(&ctxt->dto_q);
+		set_bit(SK_DATA, &xprt->sk_flags);
+	} else {
+		rdma_stat_rq_starve ++;
+		clear_bit(SK_DATA, &xprt->sk_flags);
+		ctxt = NULL;
+	}
+	spin_unlock_irqrestore(&rdma_xprt->sc_rq_dto_lock, flags);
+	if (!ctxt) {
+		/* This is the EAGAIN path. The svc_recv routine will
+		 * return -EAGAIN, the nfsd thread will go to call into
+		 * svc_recv again and we shouldn't be on the active
+		 * transport list
+		 */
+		if (test_bit(SK_CLOSE, &xprt->sk_flags))
+			goto close_out;
+
+		xprt->sk_pool = NULL;
+		BUG_ON(ret);
+		BUG_ON(test_bit(SK_BUSY, &xprt->sk_flags)==0);
+		clear_bit(SK_BUSY, &xprt->sk_flags);
+		svc_sock_enqueue(xprt);
+		goto out;
+	}
+	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p, status=%d\n",
+		ctxt, rdma_xprt, rqstp, ctxt->wc_status);
+	BUG_ON(ctxt->wc_status != IB_WC_SUCCESS); 
+	rdma_stat_recv ++;
+
+	/* Kick another thread for the next RPC */
+	xprt->sk_pool = NULL;
+	BUG_ON(test_bit(SK_BUSY, &xprt->sk_flags)==0);
+	clear_bit(SK_BUSY, &xprt->sk_flags);
+	svc_sock_enqueue(xprt);
+
+	/* rqstp struct expects transport to fill in peer address */
+	rqstp->rq_prot = IPPROTO_MAX;
+	memcpy(&rqstp->rq_addr,
+	       &rdma_xprt->sc_cm_id->route.addr.dst_addr,
+	       sizeof(rqstp->rq_addr));
+	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
+
+	/* Build up the XDR from the receive buffers. */
+	rdma_build_arg_xdr(rqstp, ctxt, ctxt->byte_len);
+	svc_rdma_put_context(ctxt, 0);
+
+	/* Decode the RDMA header. */
+	len = svc_rdma_xdr_decode_req(&rmsgp, rqstp);
+	DBG_DUMP_RDMAHDR(__FUNCTION__, page_address(rqstp->rq_pages[0]));
+
+	/* If the request is invalid, reply with an error */
+	if (len < 0) {
+		if (len == -ENOSYS)
+			(void)svc_rdma_send_error(rdma_xprt, rmsgp, ERR_VERS);
+		goto close_out;
+	}
+
+	/* Read read-list data */
+	ret = rdma_read_xdr(rdma_xprt, rmsgp, rqstp);
+	if (ret)
+		goto close_out;
+
+	ret = rqstp->rq_arg.head[0].iov_len
+		+ rqstp->rq_arg.page_len
+		+ rqstp->rq_arg.tail[0].iov_len;
+ out:
+	dprintk("svcrdma: ret = %d, rq_arg.len =%d, "
+		"rq_arg.head[0].iov_base=%p, rq_arg.head[0].iov_len = %zd\n",
+		ret, rqstp->rq_arg.len, 
+		rqstp->rq_arg.head[0].iov_base, 
+		rqstp->rq_arg.head[0].iov_len);
+	return ret;
+
+ close_out:
+	dprintk("svcrdma: transport %p is closing\n", xprt);
+	BUG_ON(test_bit(SK_BUSY, &xprt->sk_flags)==0);
+	clear_bit(SK_BUSY, &xprt->sk_flags);
+	set_bit(SK_CLOSE, &xprt->sk_flags);
+	xprt->sk_delete(xprt);
+
+	return 0;
+}
+


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
