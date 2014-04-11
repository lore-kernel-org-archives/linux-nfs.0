Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:43388 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbaDKTLU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2014 15:11:20 -0400
Message-ID: <53483E4E.9070607@opengridcomputing.com>
Date: Fri, 11 Apr 2014 14:11:10 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH] xprtrdma: mind the device's max fast register page list
 depth
References: <20140410151325.28724.92004.stgit@build.ogc.int> <577860CA-7ECC-4353-AED9-16C17A2B918D@oracle.com>
In-Reply-To: <577860CA-7ECC-4353-AED9-16C17A2B918D@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/11/2014 1:34 PM, Chuck Lever wrote:
> Hi Steve-
>
> I reviewed and successfully tested this patch with mlx4 using FRMR and MTHCAFMR.
> A couple of cosmetic notes are below:
>
>
> On Apr 10, 2014, at 11:13 AM, Steve Wise <swise@opengridcomputing.com> wrote:
>
>> Some rdma devices don't support a fast register page list depth of
>> at least RPCRDMA_MAX_DATA_SEGS.  So xprtrdma needs to chunk its fast
>> register regions according to the minimum of the device max supported
>> depth or RPCRDMA_MAX_DATA_SEGS.
>>
>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>> ---
>>
>> net/sunrpc/xprtrdma/rpc_rdma.c  |    2 -
>> net/sunrpc/xprtrdma/verbs.c     |   64 ++++++++++++++++++++++++++++-----------
>> net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>> 3 files changed, 47 insertions(+), 20 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
>> index 96ead52..14d7634 100644
>> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
>> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
>> @@ -249,8 +249,6 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
>> 	req->rl_nchunks = nchunks;
>>
>> 	BUG_ON(nchunks == 0);
> I don’t see a path through rpcrdma_create_chunks() where nchunks can be 0 here. If you
> agree, can you remove the above BUG_ON as well, if you re-submit a new version of this
> patch?

Sure.

>> -	BUG_ON((r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_FRMR)
>> -	       && (nchunks > 3));
>>
>> 	/*
>> 	 * finish off header. If write, marshal discrim and nchunks.
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 93726560..c08f193 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -539,6 +539,11 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
>> 				__func__);
>> 			memreg = RPCRDMA_REGISTER;
>> #endif
>> +		} else {
>> +			/* Mind the ia limit on FRMR page list depth */
>> +			ia->ri_max_frmr_depth = min_t(unsigned int,
>> +				RPCRDMA_MAX_DATA_SEGS,
>> +				devattr.max_fast_reg_page_list_len);
>> 		}
>> 		break;
>> 	}
>> @@ -659,24 +664,42 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>> 	ep->rep_attr.srq = NULL;
>> 	ep->rep_attr.cap.max_send_wr = cdata->max_requests;
>> 	switch (ia->ri_memreg_strategy) {
>> -	case RPCRDMA_FRMR:
>> +	case RPCRDMA_FRMR: {
>> +		int depth = 7;
>> +
>> 		/* Add room for frmr register and invalidate WRs.
>> 		 * 1. FRMR reg WR for head
>> 		 * 2. FRMR invalidate WR for head
>> -		 * 3. FRMR reg WR for pagelist
>> -		 * 4. FRMR invalidate WR for pagelist
>> +		 * 3. N FRMR reg WRs for pagelist
>> +		 * 4. N FRMR invalidate WRs for pagelist
>> 		 * 5. FRMR reg WR for tail
>> 		 * 6. FRMR invalidate WR for tail
>> 		 * 7. The RDMA_SEND WR
>> 		 */
>> -		ep->rep_attr.cap.max_send_wr *= 7;
>> +
>> +		/* Calculate N if the device max FRMR depth is smaller than
>> +		 * RPCRDMA_MAX_DATA_SEGS.
>> +		 */
>> +		if (ia->ri_max_frmr_depth < RPCRDMA_MAX_DATA_SEGS) {
>> +			int delta = RPCRDMA_MAX_DATA_SEGS -
>> +				    ia->ri_max_frmr_depth;
>> +
>> +			do {
>> +				depth += 2; /* FRMR reg + invalidate */
>> +				delta -= ia->ri_max_frmr_depth;
>> +			} while (delta > 0);
>> +
>> +		}
>> +		ep->rep_attr.cap.max_send_wr *= depth;
>> 		if (ep->rep_attr.cap.max_send_wr > devattr.max_qp_wr) {
>> -			cdata->max_requests = devattr.max_qp_wr / 7;
>> +			cdata->max_requests = devattr.max_qp_wr / depth;
>> 			if (!cdata->max_requests)
>> 				return -EINVAL;
>> -			ep->rep_attr.cap.max_send_wr = cdata->max_requests * 7;
>> +			ep->rep_attr.cap.max_send_wr = cdata->max_requests *
>> +						       depth;
>> 		}
>> 		break;
>> +	}
>> 	case RPCRDMA_MEMWINDOWS_ASYNC:
>> 	case RPCRDMA_MEMWINDOWS:
>> 		/* Add room for mw_binds+unbinds - overkill! */
>> @@ -1043,16 +1066,16 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
>> 	case RPCRDMA_FRMR:
>> 		for (i = buf->rb_max_requests * RPCRDMA_MAX_SEGS; i; i--) {
>> 			r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(ia->ri_pd,
>> -							 RPCRDMA_MAX_SEGS);
>> +						ia->ri_max_frmr_depth);
>> 			if (IS_ERR(r->r.frmr.fr_mr)) {
>> 				rc = PTR_ERR(r->r.frmr.fr_mr);
>> 				dprintk("RPC:       %s: ib_alloc_fast_reg_mr"
>> 					" failed %i\n", __func__, rc);
>> 				goto out;
>> 			}
>> -			r->r.frmr.fr_pgl =
>> -				ib_alloc_fast_reg_page_list(ia->ri_id->device,
>> -							    RPCRDMA_MAX_SEGS);
>> +			r->r.frmr.fr_pgl = ib_alloc_fast_reg_page_list(
>> +						ia->ri_id->device,
>> +						ia->ri_max_frmr_depth);
>> 			if (IS_ERR(r->r.frmr.fr_pgl)) {
>> 				rc = PTR_ERR(r->r.frmr.fr_pgl);
>> 				dprintk("RPC:       %s: "
>> @@ -1498,8 +1521,8 @@ rpcrdma_register_frmr_external(struct rpcrdma_mr_seg *seg,
>> 	seg1->mr_offset -= pageoff;	/* start of page */
>> 	seg1->mr_len += pageoff;
>> 	len = -pageoff;
>> -	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>> -		*nsegs = RPCRDMA_MAX_DATA_SEGS;
>> +	if (*nsegs > ia->ri_max_frmr_depth)
>> +		*nsegs = ia->ri_max_frmr_depth;
>> 	for (page_no = i = 0; i < *nsegs;) {
>> 		rpcrdma_map_one(ia, seg, writing);
>> 		pa = seg->mr_dma;
>> @@ -1796,6 +1819,7 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
>> {
>> 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>> 	int rc = 0;
>> +	int tmp_nsegs = nsegs;
> I don’t understand what the changes to rpcrdma_register_external() do. As a test, I reverted
> these, and the patch behaves the same. Am I missing something?

I mistakenly thought rpcrdma_register_external() was changing the 
callers nsegs variable.  But since its passed by value and not 
reference, that's not possible.  I'll remove this and retest, then send 
out V2 of the patch with the BUG_ON() removed as well.


Thanks,

Steve.

