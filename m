Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62314 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaEMSWP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 May 2014 14:22:15 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V2 RFC 2/3] svcrdma: Recvfrom changes
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20140506174632.18208.28160.stgit@build.ogc.int>
Date: Tue, 13 May 2014 14:22:03 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
Message-Id: <F997E138-FB04-4149-811D-CE68608E8D6B@gmail.com>
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506174632.18208.28160.stgit@build.ogc.int>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Some random review comments, see below.


On May 6, 2014, at 1:46 PM, Steve Wise <swise@opengridcomputing.com> wrote:

> From: Tom Tucker <tom@opengridcomputing.com>
> 
> Based on device support, RDMA read target sgls are fast-registered,
> or composed using the local dma lkey or a dma_mr lkey.  A given NFS
> Write chunk list will be split into a set of rdma reads based on the
> limitations of the device.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> 
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |  633 +++++++++++++------------------
> 1 files changed, 259 insertions(+), 374 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 8d904e4..1c4c285 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -1,4 +1,5 @@
> /*
> + * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
>  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
>  *
>  * This software is available to you under a choice of one of two
> @@ -69,7 +70,8 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
> 
> 	/* Set up the XDR head */
> 	rqstp->rq_arg.head[0].iov_base = page_address(page);
> -	rqstp->rq_arg.head[0].iov_len = min(byte_count, ctxt->sge[0].length);
> +	rqstp->rq_arg.head[0].iov_len =
> +		min_t(size_t, byte_count, ctxt->sge[0].length);
> 	rqstp->rq_arg.len = byte_count;
> 	rqstp->rq_arg.buflen = byte_count;
> 
> @@ -85,7 +87,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
> 		page = ctxt->pages[sge_no];
> 		put_page(rqstp->rq_pages[sge_no]);
> 		rqstp->rq_pages[sge_no] = page;
> -		bc -= min(bc, ctxt->sge[sge_no].length);
> +		bc -= min_t(u32, bc, ctxt->sge[sge_no].length);
> 		rqstp->rq_arg.buflen += ctxt->sge[sge_no].length;
> 		sge_no++;
> 	}
> @@ -113,291 +115,249 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
> 	rqstp->rq_arg.tail[0].iov_len = 0;
> }
> 
> -/* Encode a read-chunk-list as an array of IB SGE
> - *
> - * Assumptions:
> - * - chunk[0]->position points to pages[0] at an offset of 0
> - * - pages[] is not physically or virtually contiguous and consists of
> - *   PAGE_SIZE elements.
> - *
> - * Output:
> - * - sge array pointing into pages[] array.
> - * - chunk_sge array specifying sge index and count for each
> - *   chunk in the read list
> - *
> - */
> -static int map_read_chunks(struct svcxprt_rdma *xprt,
> -			   struct svc_rqst *rqstp,
> -			   struct svc_rdma_op_ctxt *head,
> -			   struct rpcrdma_msg *rmsgp,
> -			   struct svc_rdma_req_map *rpl_map,
> -			   struct svc_rdma_req_map *chl_map,
> -			   int ch_count,
> -			   int byte_count)
> +static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
> {
> -	int sge_no;
> -	int sge_bytes;
> -	int page_off;
> -	int page_no;
> -	int ch_bytes;
> -	int ch_no;
> -	struct rpcrdma_read_chunk *ch;
> +	if (rdma_node_get_transport(xprt->sc_cm_id->device->node_type) ==
> +	     RDMA_TRANSPORT_IWARP)
> +		return 1;
> +	else
> +		return min_t(int, sge_count, xprt->sc_max_sge);
> +}
> 
> -	sge_no = 0;
> -	page_no = 0;
> -	page_off = 0;
> -	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
> -	ch_no = 0;
> -	ch_bytes = ntohl(ch->rc_target.rs_length);
> -	head->arg.head[0] = rqstp->rq_arg.head[0];
> -	head->arg.tail[0] = rqstp->rq_arg.tail[0];
> -	head->arg.pages = &head->pages[head->count];
> -	head->hdr_count = head->count; /* save count of hdr pages */
> -	head->arg.page_base = 0;
> -	head->arg.page_len = ch_bytes;
> -	head->arg.len = rqstp->rq_arg.len + ch_bytes;
> -	head->arg.buflen = rqstp->rq_arg.buflen + ch_bytes;
> -	head->count++;
> -	chl_map->ch[0].start = 0;
> -	while (byte_count) {
> -		rpl_map->sge[sge_no].iov_base =
> -			page_address(rqstp->rq_arg.pages[page_no]) + page_off;
> -		sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
> -		rpl_map->sge[sge_no].iov_len = sge_bytes;
> -		/*
> -		 * Don't bump head->count here because the same page
> -		 * may be used by multiple SGE.
> -		 */
> -		head->arg.pages[page_no] = rqstp->rq_arg.pages[page_no];
> -		rqstp->rq_respages = &rqstp->rq_arg.pages[page_no+1];
> +typedef int (*rdma_reader_fn)(struct svcxprt_rdma *xprt,
> +			      struct svc_rqst *rqstp,
> +			      struct svc_rdma_op_ctxt *head,
> +			      int *page_no,
> +			      u32 *page_offset,
> +			      u32 rs_handle,
> +			      u32 rs_length,
> +			      u64 rs_offset,
> +			      int last);
> +
> +/* Issue an RDMA_READ using the local lkey to map the data sink */
> +static int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> +			       struct svc_rqst *rqstp,
> +			       struct svc_rdma_op_ctxt *head,
> +			       int *page_no,
> +			       u32 *page_offset,
> +			       u32 rs_handle,
> +			       u32 rs_length,
> +			       u64 rs_offset,
> +			       int last)
> +{
> +	struct ib_send_wr read_wr;
> +	int pages_needed = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
> +	struct svc_rdma_op_ctxt *ctxt = svc_rdma_get_context(xprt);
> +	int ret, read, pno;
> +	u32 pg_off = *page_offset;
> +	u32 pg_no = *page_no;
> +
> +	ctxt->direction = DMA_FROM_DEVICE;
> +	ctxt->read_hdr = head;
> +	pages_needed =
> +		min_t(int, pages_needed, rdma_read_max_sge(xprt, pages_needed));
> +	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
> +
> +	for (pno = 0; pno < pages_needed; pno++) {
> +		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
> +
> +		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
> +		head->arg.page_len += len;
> +		head->arg.len += len;
> +		head->count++;
> +		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no+1];
> 		rqstp->rq_next_page = rqstp->rq_respages + 1;
> +		ctxt->sge[pno].addr =
> +			ib_dma_map_page(xprt->sc_cm_id->device,
> +					head->arg.pages[pg_no], pg_off,
> +					PAGE_SIZE - pg_off,
> +					DMA_FROM_DEVICE);
> +		ret = ib_dma_mapping_error(xprt->sc_cm_id->device,
> +					   ctxt->sge[pno].addr);
> +		if (ret)
> +			goto err;
> +		atomic_inc(&xprt->sc_dma_used);
> 
> -		byte_count -= sge_bytes;
> -		ch_bytes -= sge_bytes;
> -		sge_no++;
> -		/*
> -		 * If all bytes for this chunk have been mapped to an
> -		 * SGE, move to the next SGE
> -		 */
> -		if (ch_bytes == 0) {
> -			chl_map->ch[ch_no].count =
> -				sge_no - chl_map->ch[ch_no].start;
> -			ch_no++;
> -			ch++;
> -			chl_map->ch[ch_no].start = sge_no;
> -			ch_bytes = ntohl(ch->rc_target.rs_length);
> -			/* If bytes remaining account for next chunk */
> -			if (byte_count) {
> -				head->arg.page_len += ch_bytes;
> -				head->arg.len += ch_bytes;
> -				head->arg.buflen += ch_bytes;
> -			}
> -		}
> -		/*
> -		 * If this SGE consumed all of the page, move to the
> -		 * next page
> -		 */
> -		if ((sge_bytes + page_off) == PAGE_SIZE) {
> -			page_no++;
> -			page_off = 0;
> -			/*
> -			 * If there are still bytes left to map, bump
> -			 * the page count
> -			 */
> -			if (byte_count)
> -				head->count++;
> -		} else
> -			page_off += sge_bytes;
> +		/* The lkey here is either a local dma lkey or a dma_mr lkey */
> +		ctxt->sge[pno].lkey = xprt->sc_dma_lkey;
> +		ctxt->sge[pno].length = len;
> +		ctxt->count++;
> +
> +		pg_no++;
> +		pg_off = 0;
> +		rs_length -= len;
> +	}
> +
> +	if (last && rs_length == 0)
> +		set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> +	else
> +		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> +
> +	memset(&read_wr, 0, sizeof(read_wr));
> +	read_wr.wr_id = (unsigned long)ctxt;
> +	read_wr.opcode = IB_WR_RDMA_READ;
> +	ctxt->wr_op = read_wr.opcode;
> +	read_wr.send_flags = IB_SEND_SIGNALED;
> +	read_wr.wr.rdma.rkey = rs_handle;
> +	read_wr.wr.rdma.remote_addr = rs_offset;
> +	read_wr.sg_list = ctxt->sge;
> +	read_wr.num_sge = pages_needed;
> +
> +	ret = svc_rdma_send(xprt, &read_wr);
> +	if (ret) {
> +		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
> +		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> +		goto err;
> 	}
> -	BUG_ON(byte_count != 0);
> -	return sge_no;
> +	*page_no = pg_no;
> +	*page_offset = pg_off;
> +	ret = read;
> +	atomic_inc(&rdma_stat_read);
> +	return ret;
> + err:
> +	svc_rdma_unmap_dma(ctxt);
> +	svc_rdma_put_context(ctxt, 0);
> +	return ret;
> }
> 
> -/* Map a read-chunk-list to an XDR and fast register the page-list.
> - *
> - * Assumptions:
> - * - chunk[0]	position points to pages[0] at an offset of 0
> - * - pages[]	will be made physically contiguous by creating a one-off memory
> - *		region using the fastreg verb.
> - * - byte_count is # of bytes in read-chunk-list
> - * - ch_count	is # of chunks in read-chunk-list
> - *
> - * Output:
> - * - sge array pointing into pages[] array.
> - * - chunk_sge array specifying sge index and count for each
> - *   chunk in the read list
> - */
> -static int fast_reg_read_chunks(struct svcxprt_rdma *xprt,
> +/* Issue an RDMA_READ using an FRMR to map the data sink */
> +static int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> 				struct svc_rqst *rqstp,
> 				struct svc_rdma_op_ctxt *head,
> -				struct rpcrdma_msg *rmsgp,
> -				struct svc_rdma_req_map *rpl_map,
> -				struct svc_rdma_req_map *chl_map,
> -				int ch_count,
> -				int byte_count)
> +				int *page_no,
> +				u32 *page_offset,
> +				u32 rs_handle,
> +				u32 rs_length,
> +				u64 rs_offset,
> +				int last)
> {
> -	int page_no;
> -	int ch_no;
> -	u32 offset;
> -	struct rpcrdma_read_chunk *ch;
> -	struct svc_rdma_fastreg_mr *frmr;
> -	int ret = 0;
> +	struct ib_send_wr read_wr;
> +	struct ib_send_wr inv_wr;
> +	struct ib_send_wr fastreg_wr;
> +	u8 key;
> +	int pages_needed = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
> +	struct svc_rdma_op_ctxt *ctxt = svc_rdma_get_context(xprt);
> +	struct svc_rdma_fastreg_mr *frmr = svc_rdma_get_frmr(xprt);
> +	int ret, read, pno;
> +	u32 pg_off = *page_offset;
> +	u32 pg_no = *page_no;
> 
> -	frmr = svc_rdma_get_frmr(xprt);
> 	if (IS_ERR(frmr))
> 		return -ENOMEM;
> 
> -	head->frmr = frmr;
> -	head->arg.head[0] = rqstp->rq_arg.head[0];
> -	head->arg.tail[0] = rqstp->rq_arg.tail[0];
> -	head->arg.pages = &head->pages[head->count];
> -	head->hdr_count = head->count; /* save count of hdr pages */
> -	head->arg.page_base = 0;
> -	head->arg.page_len = byte_count;
> -	head->arg.len = rqstp->rq_arg.len + byte_count;
> -	head->arg.buflen = rqstp->rq_arg.buflen + byte_count;
> +	ctxt->direction = DMA_FROM_DEVICE;
> +	ctxt->frmr = frmr;
> +	pages_needed = min_t(int, pages_needed, xprt->sc_frmr_pg_list_len);
> +	read = min_t(int, pages_needed << PAGE_SHIFT, rs_length);
> 
> -	/* Fast register the page list */
> -	frmr->kva = page_address(rqstp->rq_arg.pages[0]);
> +	frmr->kva = page_address(rqstp->rq_arg.pages[pg_no]);
> 	frmr->direction = DMA_FROM_DEVICE;
> 	frmr->access_flags = (IB_ACCESS_LOCAL_WRITE|IB_ACCESS_REMOTE_WRITE);
> -	frmr->map_len = byte_count;
> -	frmr->page_list_len = PAGE_ALIGN(byte_count) >> PAGE_SHIFT;
> -	for (page_no = 0; page_no < frmr->page_list_len; page_no++) {
> -		frmr->page_list->page_list[page_no] =
> +	frmr->map_len = pages_needed << PAGE_SHIFT;
> +	frmr->page_list_len = pages_needed;
> +
> +	for (pno = 0; pno < pages_needed; pno++) {
> +		int len = min_t(int, rs_length, PAGE_SIZE - pg_off);
> +
> +		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
> +		head->arg.page_len += len;
> +		head->arg.len += len;
> +		head->count++;
> +		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no+1];
> +		rqstp->rq_next_page = rqstp->rq_respages + 1;
> +		frmr->page_list->page_list[pno] =
> 			ib_dma_map_page(xprt->sc_cm_id->device,
> -					rqstp->rq_arg.pages[page_no], 0,
> +					head->arg.pages[pg_no], 0,
> 					PAGE_SIZE, DMA_FROM_DEVICE);
> -		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
> -					 frmr->page_list->page_list[page_no]))
> -			goto fatal_err;
> +		ret = ib_dma_mapping_error(xprt->sc_cm_id->device,
> +					   frmr->page_list->page_list[pno]);
> +		if (ret)
> +			goto err;
> 		atomic_inc(&xprt->sc_dma_used);
> -		head->arg.pages[page_no] = rqstp->rq_arg.pages[page_no];
> +		pg_no++;
> +		pg_off = 0;
> 	}
> -	head->count += page_no;
> 
> -	/* rq_respages points one past arg pages */
> -	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> -	rqstp->rq_next_page = rqstp->rq_respages + 1;
> +	if (last && read == rs_length)
> +		set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> +	else
> +		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> 
> -	/* Create the reply and chunk maps */
> -	offset = 0;
> -	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
> -	for (ch_no = 0; ch_no < ch_count; ch_no++) {
> -		int len = ntohl(ch->rc_target.rs_length);
> -		rpl_map->sge[ch_no].iov_base = frmr->kva + offset;
> -		rpl_map->sge[ch_no].iov_len = len;
> -		chl_map->ch[ch_no].count = 1;
> -		chl_map->ch[ch_no].start = ch_no;
> -		offset += len;
> -		ch++;
> +	/* Bump the key */
> +	key = (u8)(frmr->mr->lkey & 0x000000FF);
> +	ib_update_fast_reg_key(frmr->mr, ++key);
> +
> +	ctxt->sge[0].addr = (unsigned long)frmr->kva;
> +	ctxt->sge[0].lkey = frmr->mr->lkey;
> +	ctxt->sge[0].length = read;
> +	ctxt->count = 1;
> +	ctxt->read_hdr = head;
> +
> +	/* Prepare FASTREG WR */
> +	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
> +	fastreg_wr.opcode = IB_WR_FAST_REG_MR;
> +	fastreg_wr.send_flags = IB_SEND_SIGNALED;
> +	fastreg_wr.wr.fast_reg.iova_start = (unsigned long)frmr->kva;
> +	fastreg_wr.wr.fast_reg.page_list = frmr->page_list;
> +	fastreg_wr.wr.fast_reg.page_list_len = frmr->page_list_len;
> +	fastreg_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
> +	fastreg_wr.wr.fast_reg.length = frmr->map_len;
> +	fastreg_wr.wr.fast_reg.access_flags = frmr->access_flags;
> +	fastreg_wr.wr.fast_reg.rkey = frmr->mr->lkey;
> +	fastreg_wr.next = &read_wr;
> +
> +	/* Prepare RDMA_READ */
> +	memset(&read_wr, 0, sizeof(read_wr));
> +	read_wr.send_flags = IB_SEND_SIGNALED;
> +	read_wr.wr.rdma.rkey = rs_handle;
> +	read_wr.wr.rdma.remote_addr = rs_offset;
> +	read_wr.sg_list = ctxt->sge;
> +	read_wr.num_sge = 1;
> +	if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_READ_W_INV) {
> +		read_wr.opcode = IB_WR_RDMA_READ_WITH_INV;
> +		read_wr.wr_id = (unsigned long)ctxt;
> +		read_wr.ex.invalidate_rkey = ctxt->frmr->mr->lkey;
> +	} else {
> +		read_wr.opcode = IB_WR_RDMA_READ;
> +		read_wr.next = &inv_wr;
> +		/* Prepare invalidate */
> +		memset(&inv_wr, 0, sizeof(inv_wr));
> +		inv_wr.wr_id = (unsigned long)ctxt;
> +		inv_wr.opcode = IB_WR_LOCAL_INV;
> +		inv_wr.send_flags = IB_SEND_SIGNALED;
> +		inv_wr.ex.invalidate_rkey = frmr->mr->lkey;
> 	}
> -
> -	ret = svc_rdma_fastreg(xprt, frmr);
> -	if (ret)
> -		goto fatal_err;
> -
> -	return ch_no;
> -
> - fatal_err:
> -	printk("svcrdma: error fast registering xdr for xprt %p", xprt);
> -	svc_rdma_put_frmr(xprt, frmr);
> -	return -EIO;
> -}
> -
> -static int rdma_set_ctxt_sge(struct svcxprt_rdma *xprt,
> -			     struct svc_rdma_op_ctxt *ctxt,
> -			     struct svc_rdma_fastreg_mr *frmr,
> -			     struct kvec *vec,
> -			     u64 *sgl_offset,
> -			     int count)
> -{
> -	int i;
> -	unsigned long off;
> -
> -	ctxt->count = count;
> -	ctxt->direction = DMA_FROM_DEVICE;
> -	for (i = 0; i < count; i++) {
> -		ctxt->sge[i].length = 0; /* in case map fails */
> -		if (!frmr) {
> -			BUG_ON(!virt_to_page(vec[i].iov_base));
> -			off = (unsigned long)vec[i].iov_base & ~PAGE_MASK;
> -			ctxt->sge[i].addr =
> -				ib_dma_map_page(xprt->sc_cm_id->device,
> -						virt_to_page(vec[i].iov_base),
> -						off,
> -						vec[i].iov_len,
> -						DMA_FROM_DEVICE);
> -			if (ib_dma_mapping_error(xprt->sc_cm_id->device,
> -						 ctxt->sge[i].addr))
> -				return -EINVAL;
> -			ctxt->sge[i].lkey = xprt->sc_dma_lkey;
> -			atomic_inc(&xprt->sc_dma_used);
> -		} else {
> -			ctxt->sge[i].addr = (unsigned long)vec[i].iov_base;
> -			ctxt->sge[i].lkey = frmr->mr->lkey;
> -		}
> -		ctxt->sge[i].length = vec[i].iov_len;
> -		*sgl_offset = *sgl_offset + vec[i].iov_len;
> +	ctxt->wr_op = read_wr.opcode;
> +
> +	/* Post the chain */
> +	ret = svc_rdma_send(xprt, &fastreg_wr);
> +	if (ret) {
> +		pr_err("svcrdma: Error %d posting RDMA_READ\n", ret);
> +		set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> +		goto err;
> 	}
> -	return 0;
> -}
> -
> -static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
> -{
> -	if ((rdma_node_get_transport(xprt->sc_cm_id->device->node_type) ==
> -	     RDMA_TRANSPORT_IWARP) &&
> -	    sge_count > 1)
> -		return 1;
> -	else
> -		return min_t(int, sge_count, xprt->sc_max_sge);
> +	*page_no = pg_no;
> +	*page_offset = pg_off;
> +	ret = read;
> +	atomic_inc(&rdma_stat_read);
> +	return ret;
> + err:
> +	svc_rdma_unmap_dma(ctxt);
> +	svc_rdma_put_context(ctxt, 0);
> +	svc_rdma_put_frmr(xprt, frmr);
> +	return ret;
> }
> 
> -/*
> - * Use RDMA_READ to read data from the advertised client buffer into the
> - * XDR stream starting at rq_arg.head[0].iov_base.
> - * Each chunk in the array
> - * contains the following fields:
> - * discrim      - '1', This isn't used for data placement
> - * position     - The xdr stream offset (the same for every chunk)
> - * handle       - RMR for client memory region
> - * length       - data transfer length
> - * offset       - 64 bit tagged offset in remote memory region
> - *
> - * On our side, we need to read into a pagelist. The first page immediately
> - * follows the RPC header.
> - *
> - * This function returns:
> - * 0 - No error and no read-list found.
> - *
> - * 1 - Successful read-list processing. The data is not yet in
> - * the pagelist and therefore the RPC request must be deferred. The
> - * I/O completion will enqueue the transport again and
> - * svc_rdma_recvfrom will complete the request.
> - *
> - * <0 - Error processing/posting read-list.
> - *
> - * NOTE: The ctxt must not be touched after the last WR has been posted
> - * because the I/O completion processing may occur on another
> - * processor and free / modify the context. Ne touche pas!
> - */
> -static int rdma_read_xdr(struct svcxprt_rdma *xprt,
> -			 struct rpcrdma_msg *rmsgp,
> -			 struct svc_rqst *rqstp,
> -			 struct svc_rdma_op_ctxt *hdr_ctxt)
> +static int rdma_read_chunks(struct svcxprt_rdma *xprt,
> +			    struct rpcrdma_msg *rmsgp,
> +			    struct svc_rqst *rqstp,
> +			    struct svc_rdma_op_ctxt *head)
> {
> -	struct ib_send_wr read_wr;
> -	struct ib_send_wr inv_wr;
> -	int err = 0;
> -	int ch_no;
> -	int ch_count;
> -	int byte_count;
> -	int sge_count;
> -	u64 sgl_offset;
> +	int page_no, ch_count, ret;
> 	struct rpcrdma_read_chunk *ch;
> -	struct svc_rdma_op_ctxt *ctxt = NULL;
> -	struct svc_rdma_req_map *rpl_map;
> -	struct svc_rdma_req_map *chl_map;
> +	u32 page_offset, byte_count;
> +	u64 rs_offset;
> +	rdma_reader_fn reader;
> 
> 	/* If no read list is present, return 0 */
> 	ch = svc_rdma_get_read_chunk(rmsgp);
> @@ -408,122 +368,53 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
> 	if (ch_count > RPCSVC_MAXPAGES)
> 		return -EINVAL;

I’m not sure what this ^^^ ch_count check is doing, but maybe I haven’t had
enough caffeine this morning. Shouldn’t this code be comparing the segment
count, not the chunk count, with MAXPAGES?


> 
> -	/* Allocate temporary reply and chunk maps */
> -	rpl_map = svc_rdma_get_req_map();
> -	chl_map = svc_rdma_get_req_map();
> -
> -	if (!xprt->sc_frmr_pg_list_len)
> -		sge_count = map_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
> -					    rpl_map, chl_map, ch_count,
> -					    byte_count);
> -	else
> -		sge_count = fast_reg_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
> -						 rpl_map, chl_map, ch_count,
> -						 byte_count);
> -	if (sge_count < 0) {
> -		err = -EIO;
> -		goto out;
> -	}
> -
> -	sgl_offset = 0;
> -	ch_no = 0;
> +	/* The request is completed when the RDMA_READs complete. The
> +	 * head context keeps all the pages that comprise the
> +	 * request.
> +	 */
> +	head->arg.head[0] = rqstp->rq_arg.head[0];
> +	head->arg.tail[0] = rqstp->rq_arg.tail[0];
> +	head->arg.pages = &head->pages[head->count];
> +	head->hdr_count = head->count;
> +	head->arg.page_base = 0;
> +	head->arg.page_len = 0;
> +	head->arg.len = rqstp->rq_arg.len;
> +	head->arg.buflen = rqstp->rq_arg.buflen + PAGE_SIZE;
> 
> +	page_no = 0; page_offset = 0;
> 	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
> -	     ch->rc_discrim != 0; ch++, ch_no++) {
> -		u64 rs_offset;
> -next_sge:
> -		ctxt = svc_rdma_get_context(xprt);
> -		ctxt->direction = DMA_FROM_DEVICE;
> -		ctxt->frmr = hdr_ctxt->frmr;
> -		ctxt->read_hdr = NULL;
> -		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> -		clear_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
> +	     ch->rc_discrim != 0; ch++) {


As I understand it, this loop is iterating over the items in the RPC
header’s read chunk list.

RFC 5667 section 4 says 

"The server MUST ignore any Read list for other NFS procedures, as well
as additional Read list entries beyond the first in the list."

But rdma_read_chunks() still expects multiple chunks in the incoming list.
Should this code follow the RFC and process only the first chunk in
each RPC header, or did I misunderstand the RFC text?

I’m not sure how the RPC layer should enforce the requirement to ignore
chunks for particular classes of NFS requests. But seems like valid
NFS/RDMA requests will have only zero or one item in each chunk list.


The ramification of this change:

The Linux client sends an extra chunk which is a zero pad to satisfy XDR
alignment. This results in an extra RDMA READ on the wire for a payload
that is never more than 3 bytes of zeros.

Section 3.7 of RFC 5666 states:

"If in turn, no data remains to be decoded from the inline portion, then
the receiver MUST conclude that roundup is present, and therefore it
advances the XDR decode position to that indicated by the next chunk (if
any).  In this way, roundup is passed without ever actually transferring
additional XDR bytes.”

Later, it states:

"Senders SHOULD therefore avoid encoding individual RDMA Read Chunks for
roundup whenever possible.”

The Solaris NFS/RDMA server does not require this extra chunk, but Linux
appears to need it. When I enable pad optimization on the Linux client,
it works fine with the Solaris server. But the first NFS WRITE with an
odd length against the Linux server causes connection loss and the client
workload hangs.

At some point I’d like to permanently enable this optimization on the
Linux client. You can try this out with:

 sudo echo 1 > /proc/sys/sunrpc/rdma_pad_optimize

The default contents of this file leave pad optimization disabled, for
compatibility with the current Linux NFS/RDMA server.

So rdma_read_chunks() needs to handle the implicit XDR length round-up.
That’s probably not hard.

What I’m asking is:

Do you agree the server should be changed to comply with section 4 of 5667?

Should you change now in this patch, or do you want me to write a patch
for it once the refactoring patch has been accepted?



> 
> -		/* Prepare READ WR */
> -		memset(&read_wr, 0, sizeof read_wr);
> -		read_wr.wr_id = (unsigned long)ctxt;
> -		read_wr.opcode = IB_WR_RDMA_READ;
> -		ctxt->wr_op = read_wr.opcode;
> -		read_wr.send_flags = IB_SEND_SIGNALED;
> -		read_wr.wr.rdma.rkey = ntohl(ch->rc_target.rs_handle);
> 		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
> 				 &rs_offset);
> -		read_wr.wr.rdma.remote_addr = rs_offset + sgl_offset;
> -		read_wr.sg_list = ctxt->sge;
> -		read_wr.num_sge =
> -			rdma_read_max_sge(xprt, chl_map->ch[ch_no].count);
> -		err = rdma_set_ctxt_sge(xprt, ctxt, hdr_ctxt->frmr,
> -					&rpl_map->sge[chl_map->ch[ch_no].start],
> -					&sgl_offset,
> -					read_wr.num_sge);
> -		if (err) {
> -			svc_rdma_unmap_dma(ctxt);
> -			svc_rdma_put_context(ctxt, 0);
> -			goto out;
> -		}
> -		if (((ch+1)->rc_discrim == 0) &&
> -		    (read_wr.num_sge == chl_map->ch[ch_no].count)) {
> -			/*
> -			 * Mark the last RDMA_READ with a bit to
> -			 * indicate all RPC data has been fetched from
> -			 * the client and the RPC needs to be enqueued.
> -			 */
> -			set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> -			if (hdr_ctxt->frmr) {
> -				set_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
> -				/*
> -				 * Invalidate the local MR used to map the data
> -				 * sink.
> -				 */
> -				if (xprt->sc_dev_caps &
> -				    SVCRDMA_DEVCAP_READ_W_INV) {
> -					read_wr.opcode =
> -						IB_WR_RDMA_READ_WITH_INV;
> -					ctxt->wr_op = read_wr.opcode;
> -					read_wr.ex.invalidate_rkey =
> -						ctxt->frmr->mr->lkey;
> -				} else {
> -					/* Prepare INVALIDATE WR */
> -					memset(&inv_wr, 0, sizeof inv_wr);
> -					inv_wr.opcode = IB_WR_LOCAL_INV;
> -					inv_wr.send_flags = IB_SEND_SIGNALED;
> -					inv_wr.ex.invalidate_rkey =
> -						hdr_ctxt->frmr->mr->lkey;
> -					read_wr.next = &inv_wr;
> -				}
> -			}
> -			ctxt->read_hdr = hdr_ctxt;
> -		}
> -		/* Post the read */
> -		err = svc_rdma_send(xprt, &read_wr);
> -		if (err) {
> -			printk(KERN_ERR "svcrdma: Error %d posting RDMA_READ\n",
> -			       err);
> -			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> -			svc_rdma_unmap_dma(ctxt);
> -			svc_rdma_put_context(ctxt, 0);
> -			goto out;
> +		byte_count = ntohl(ch->rc_target.rs_length);
> +
> +		/* Use FRMR if supported */
> +		if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)
> +			reader = rdma_read_chunk_frmr;
> +		else
> +			reader = rdma_read_chunk_lcl;

The reader function is invariant across iterations of the for() loop.
In fact, it is invariant for all incoming requests on an xprt, isn’t it?

Can svc_rdma_create() plant that function pointer in the xprt?


> +		while (byte_count > 0) {
> +			ret = reader(xprt, rqstp, head,
> +				     &page_no, &page_offset,
> +				     ntohl(ch->rc_target.rs_handle),
> +				     byte_count, rs_offset,
> +				     ((ch+1)->rc_discrim == 0) /* last */
> +				     );
> +			if (ret < 0)
> +				goto err;
> +			byte_count -= ret;
> +			rs_offset += ret;
> 		}
> -		atomic_inc(&rdma_stat_read);
> -
> -		if (read_wr.num_sge < chl_map->ch[ch_no].count) {
> -			chl_map->ch[ch_no].count -= read_wr.num_sge;
> -			chl_map->ch[ch_no].start += read_wr.num_sge;
> -			goto next_sge;
> -		}
> -		sgl_offset = 0;
> -		err = 1;
> 	}
> -
> - out:
> -	svc_rdma_put_req_map(rpl_map);
> -	svc_rdma_put_req_map(chl_map);
> -
> +	ret = 1;
> + err:
> 	/* Detach arg pages. svc_recv will replenish them */
> -	for (ch_no = 0; &rqstp->rq_pages[ch_no] < rqstp->rq_respages; ch_no++)
> -		rqstp->rq_pages[ch_no] = NULL;
> +	for (page_no = 0;
> +	     &rqstp->rq_pages[page_no] < rqstp->rq_respages; page_no++)
> +		rqstp->rq_pages[page_no] = NULL;
> 
> -	return err;
> +	return ret;
> }
> 
> static int rdma_read_complete(struct svc_rqst *rqstp,
> @@ -595,13 +486,9 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
> 				  struct svc_rdma_op_ctxt,
> 				  dto_q);
> 		list_del_init(&ctxt->dto_q);
> -	}
> -	if (ctxt) {
> 		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
> 		return rdma_read_complete(rqstp, ctxt);
> -	}
> -
> -	if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
> +	} else if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
> 		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
> 				  struct svc_rdma_op_ctxt,
> 				  dto_q);
> @@ -621,7 +508,6 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
> 		if (test_bit(XPT_CLOSE, &xprt->xpt_flags))
> 			goto close_out;
> 
> -		BUG_ON(ret);
> 		goto out;
> 	}
> 	dprintk("svcrdma: processing ctxt=%p on xprt=%p, rqstp=%p, status=%d\n",
> @@ -644,12 +530,11 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
> 	}
> 
> 	/* Read read-list data. */
> -	ret = rdma_read_xdr(rdma_xprt, rmsgp, rqstp, ctxt);
> +	ret = rdma_read_chunks(rdma_xprt, rmsgp, rqstp, ctxt);
> 	if (ret > 0) {
> 		/* read-list posted, defer until data received from client. */
> 		goto defer;
> -	}
> -	if (ret < 0) {
> +	} else if (ret < 0) {
> 		/* Post of read-list failed, free context. */
> 		svc_rdma_put_context(ctxt, 1);
> 		return 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chucklever@gmail.com



