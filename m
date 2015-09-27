Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38730 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038AbbI0HXi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2015 03:23:38 -0400
Received: by wiclk2 with SMTP id lk2so64318317wic.1
        for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2015 00:23:37 -0700 (PDT)
Subject: Re: [PATCH v2 12/26] xprtrdma: Port to new memory registration API
To: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagig@mellanox.com>
References: <1443116094-7969-1-git-send-email-sagig@mellanox.com>
 <1443116094-7969-13-git-send-email-sagig@mellanox.com>
 <9F4BB29C-C399-4B02-9622-D9ED0BBD84BB@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56079974.3010205@dev.mellanox.co.il>
Date: Sun, 27 Sep 2015 10:23:32 +0300
MIME-Version: 1.0
In-Reply-To: <9F4BB29C-C399-4B02-9622-D9ED0BBD84BB@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/25/2015 7:51 PM, Chuck Lever wrote:
>
>> On Sep 24, 2015, at 10:34 AM, Sagi Grimberg <sagig@mellanox.com> wrote:
>>
>> Instead of maintaining a fastreg page list, keep an sg table
>> and convert an array of pages to a sg list. Then call ib_map_mr_sg
>> and construct ib_reg_wr.
>>
>> Note that the next step would be to have NFS work with sg lists
>> as it maps well to sk_frags (see comment from hch
>> http://marc.info/?l=linux-rdma&m=143677002622296&w=2).
>
> Fwiw, you would need to change tcp_sendpages() first.
>
> One more comment below.
>
>
>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>> Acked-by: Christoph Hellwig <hch@lst.de>
>> ---
>> net/sunrpc/xprtrdma/frwr_ops.c  | 113 +++++++++++++++++++++++-----------------
>> net/sunrpc/xprtrdma/xprt_rdma.h |   3 +-
>> 2 files changed, 68 insertions(+), 48 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
>> index 0d2f46f600b6..b80a82149977 100644
>> --- a/net/sunrpc/xprtrdma/frwr_ops.c
>> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
>> @@ -151,9 +151,13 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
>> 	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
>> 	if (IS_ERR(f->fr_mr))
>> 		goto out_mr_err;
>> -	f->fr_pgl = ib_alloc_fast_reg_page_list(device, depth);
>> -	if (IS_ERR(f->fr_pgl))
>> +
>> +	f->sg = kcalloc(depth, sizeof(*f->sg), GFP_KERNEL);
>> +	if (!f->sg)
>> 		goto out_list_err;
>> +
>> +	sg_init_table(f->sg, depth);
>> +
>> 	return 0;
>>
>> out_mr_err:
>> @@ -163,7 +167,7 @@ out_mr_err:
>> 	return rc;
>>
>> out_list_err:
>> -	rc = PTR_ERR(f->fr_pgl);
>> +	rc = -ENOMEM;
>> 	dprintk("RPC:       %s: ib_alloc_fast_reg_page_list status %i\n",
>> 		__func__, rc);
>> 	ib_dereg_mr(f->fr_mr);
>> @@ -179,7 +183,7 @@ __frwr_release(struct rpcrdma_mw *r)
>> 	if (rc)
>> 		dprintk("RPC:       %s: ib_dereg_mr status %i\n",
>> 			__func__, rc);
>> -	ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
>> +	kfree(r->r.frmr.sg);
>> }
>>
>> static int
>> @@ -312,14 +316,11 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>> 	struct rpcrdma_mw *mw;
>> 	struct rpcrdma_frmr *frmr;
>> 	struct ib_mr *mr;
>> -	struct ib_fast_reg_wr fastreg_wr;
>> +	struct ib_reg_wr reg_wr;
>> 	struct ib_send_wr *bad_wr;
>> +	unsigned int dma_nents;
>> 	u8 key;
>> -	int len, pageoff;
>> -	int i, rc;
>> -	int seg_len;
>> -	u64 pa;
>> -	int page_no;
>> +	int i, rc, len, n;
>>
>> 	mw = seg1->rl_mw;
>> 	seg1->rl_mw = NULL;
>> @@ -332,64 +333,81 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>> 	} while (mw->r.frmr.fr_state != FRMR_IS_INVALID);
>> 	frmr = &mw->r.frmr;
>> 	frmr->fr_state = FRMR_IS_VALID;
>> +	mr = frmr->fr_mr;
>>
>> -	pageoff = offset_in_page(seg1->mr_offset);
>> -	seg1->mr_offset -= pageoff;	/* start of page */
>> -	seg1->mr_len += pageoff;
>> -	len = -pageoff;
>> 	if (nsegs > ia->ri_max_frmr_depth)
>> 		nsegs = ia->ri_max_frmr_depth;
>>
>> -	for (page_no = i = 0; i < nsegs;) {
>> -		rpcrdma_map_one(device, seg, direction);
>> -		pa = seg->mr_dma;
>> -		for (seg_len = seg->mr_len; seg_len > 0; seg_len -= PAGE_SIZE) {
>> -			frmr->fr_pgl->page_list[page_no++] = pa;
>> -			pa += PAGE_SIZE;
>> -		}
>> +	for (len = 0, i = 0; i < nsegs;) {
>> +		if (seg->mr_page)
>> +			sg_set_page(&frmr->sg[i],
>> +				    seg->mr_page,
>> +				    seg->mr_len,
>> +				    offset_in_page(seg->mr_offset));
>> +		else
>> +			sg_set_buf(&frmr->sg[i], seg->mr_offset,
>> +				   seg->mr_len);
>> +
>> 		len += seg->mr_len;
>> 		++seg;
>> 		++i;
>> +
>> 		/* Check for holes */
>> 		if ((i < nsegs && offset_in_page(seg->mr_offset)) ||
>> 		    offset_in_page((seg-1)->mr_offset + (seg-1)->mr_len))
>> 			break;
>> 	}
>> +	frmr->sg_nents = i;
>> +
>> +	dma_nents = ib_dma_map_sg(device, frmr->sg, frmr->sg_nents, direction);
>> +	if (!dma_nents) {
>> +		pr_err("RPC:       %s: failed to dma map sg %p sg_nents %d\n",
>> +		       __func__, frmr->sg, frmr->sg_nents);
>> +		return -ENOMEM;
>> +	}
>> +
>> +	n = ib_map_mr_sg(mr, frmr->sg, frmr->sg_nents, PAGE_SIZE);
>> +	if (unlikely(n != frmr->sg_nents)) {
>> +		pr_err("RPC:       %s: failed to map mr %p (%d/%d)\n",
>> +		       __func__, frmr->fr_mr, n, frmr->sg_nents);
>> +		rc = n < 0 ? n : -EINVAL;
>> +		goto out_senderr;
>> +	}
>> +
>> 	dprintk("RPC:       %s: Using frmr %p to map %d segments (%d bytes)\n",
>> -		__func__, mw, i, len);
>> -
>> -	memset(&fastreg_wr, 0, sizeof(fastreg_wr));
>> -	fastreg_wr.wr.wr_id = (unsigned long)(void *)mw;
>> -	fastreg_wr.wr.opcode = IB_WR_FAST_REG_MR;
>> -	fastreg_wr.iova_start = seg1->mr_dma + pageoff;
>> -	fastreg_wr.page_list = frmr->fr_pgl;
>> -	fastreg_wr.page_shift = PAGE_SHIFT;
>> -	fastreg_wr.page_list_len = page_no;
>> -	fastreg_wr.length = len;
>> -	fastreg_wr.access_flags = writing ?
>> -				IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
>> -				IB_ACCESS_REMOTE_READ;
>> -	mr = frmr->fr_mr;
>> +		__func__, mw, frmr->sg_nents, mr->length);
>> +
>> 	key = (u8)(mr->rkey & 0x000000FF);
>> 	ib_update_fast_reg_key(mr, ++key);
>> -	fastreg_wr.rkey = mr->rkey;
>> +
>> +	reg_wr.wr.next = NULL;
>> +	reg_wr.wr.opcode = IB_WR_REG_MR;
>> +	reg_wr.wr.wr_id = (uintptr_t)mw;
>> +	reg_wr.wr.num_sge = 0;
>> +	reg_wr.wr.send_flags = 0;
>> +	reg_wr.mr = mr;
>> +	reg_wr.key = mr->rkey;
>> +	reg_wr.access = writing ?
>> +			IB_ACCESS_REMOTE_WRITE | IB_ACCESS_LOCAL_WRITE :
>> +			IB_ACCESS_REMOTE_READ;
>>
>> 	DECR_CQCOUNT(&r_xprt->rx_ep);
>> -	rc = ib_post_send(ia->ri_id->qp, &fastreg_wr.wr, &bad_wr);
>> +	rc = ib_post_send(ia->ri_id->qp, &reg_wr.wr, &bad_wr);
>> 	if (rc)
>> 		goto out_senderr;
>>
>> +	seg1->mr_dir = direction;
>> 	seg1->rl_mw = mw;
>> 	seg1->mr_rkey = mr->rkey;
>> -	seg1->mr_base = seg1->mr_dma + pageoff;
>> -	seg1->mr_nsegs = i;
>> -	seg1->mr_len = len;
>> -	return i;
>> +	seg1->mr_base = mr->iova;
>> +	seg1->mr_nsegs = frmr->sg_nents;
>> +	seg1->mr_len = mr->length;
>> +
>> +	return frmr->sg_nents;
>>
>> out_senderr:
>> 	dprintk("RPC:       %s: ib_post_send status %i\n", __func__, rc);
>> -	while (i--)
>> -		rpcrdma_unmap_one(device, --seg);
>> +	ib_dma_unmap_sg(device, frmr->sg, frmr->sg_nents, direction);
>> 	__frwr_queue_recovery(mw);
>> 	return rc;
>> }
>> @@ -403,28 +421,29 @@ frwr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>> 	struct rpcrdma_mr_seg *seg1 = seg;
>> 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>> 	struct rpcrdma_mw *mw = seg1->rl_mw;
>> +	struct rpcrdma_frmr *frmr = &mw->r.frmr;
>> 	struct ib_send_wr invalidate_wr, *bad_wr;
>> 	int rc, nsegs = seg->mr_nsegs;
>>
>> 	dprintk("RPC:       %s: FRMR %p\n", __func__, mw);
>>
>> 	seg1->rl_mw = NULL;
>> -	mw->r.frmr.fr_state = FRMR_IS_INVALID;
>> +	frmr->fr_state = FRMR_IS_INVALID;
>>
>> 	memset(&invalidate_wr, 0, sizeof(invalidate_wr));
>> 	invalidate_wr.wr_id = (unsigned long)(void *)mw;
>> 	invalidate_wr.opcode = IB_WR_LOCAL_INV;
>> -	invalidate_wr.ex.invalidate_rkey = mw->r.frmr.fr_mr->rkey;
>> +	invalidate_wr.ex.invalidate_rkey = frmr->fr_mr->rkey;
>> 	DECR_CQCOUNT(&r_xprt->rx_ep);
>>
>> -	while (seg1->mr_nsegs--)
>> -		rpcrdma_unmap_one(ia->ri_device, seg++);
>> 	read_lock(&ia->ri_qplock);
>> 	rc = ib_post_send(ia->ri_id->qp, &invalidate_wr, &bad_wr);
>> 	read_unlock(&ia->ri_qplock);
>> 	if (rc)
>> 		goto out_err;
>>
>> +	ib_dma_unmap_sg(ia->ri_device, frmr->sg, frmr->sg_nents, seg1->mr_dir);
>
> What benefit does moving the DMA unmap after the post_send have?
> Remember that the LOCAL_INV WRs may not have started yet, even after
> the post_send.

It doesn't have a benefit. I can move it back...
