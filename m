Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50440 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752654AbbALQ0r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2015 11:26:47 -0500
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>
Cc: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>, <linux-rdma@vger.kernel.org>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net> <20150109192245.4901.89614.stgit@klimt.1015granger.net> <54B2B69E.2010503@dev.mellanox.co.il> <6A78707C-A371-412F-8E9A-24937318A01D@oracle.com> <002201d02e82$08d16070$1a742150$@opengridcomputing.com> <A84D07C5-1879-49ED-A181-6FFC76B4864B@oracle.com>
In-Reply-To: <A84D07C5-1879-49ED-A181-6FFC76B4864B@oracle.com>
Subject: RE: [PATCH v1 06/10] svcrdma: Plant reader function in struct svcxprt_rdma
Date: Mon, 12 Jan 2015 10:26:48 -0600
Message-ID: <006b01d02e84$907f5890$b17e09b0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Monday, January 12, 2015 10:20 AM
> To: Steve Wise
> Cc: Sagi Grimberg; linux-rdma@vger.kernel.org; Linux NFS Mailing List
> Subject: Re: [PATCH v1 06/10] svcrdma: Plant reader function in struct svcxprt_rdma
> 
> 
> On Jan 12, 2015, at 11:08 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
> >
> >
> >> -----Original Message-----
> >> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> >> Sent: Sunday, January 11, 2015 6:41 PM
> >> To: Sagi Grimberg; Steve Wise
> >> Cc: linux-rdma@vger.kernel.org; Linux NFS Mailing List
> >> Subject: Re: [PATCH v1 06/10] svcrdma: Plant reader function in struct svcxprt_rdma
> >>
> >>
> >> On Jan 11, 2015, at 12:45 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> >>
> >>> On 1/9/2015 9:22 PM, Chuck Lever wrote:
> >>>> The RDMA reader function doesn't change once an svcxprt is
> >>>> instantiated. Instead of checking sc_devcap during every incoming
> >>>> RPC, set the reader function once when the connection is accepted.
> >>>
> >>> General question(s),
> >>>
> >>> Any specific reason why to use FRMR in the server side? And why only
> >>> for reads and not writes? Sorry if these are dumb questions...
> >>
> >> Steve Wise presented patches a few months back to add FRMR, he
> >> would have to answer this. Steve has a selection of iWARP adapters
> >> and maybe could provide some idea of performance impact. I have
> >> only CX-[23] here.
> >>
> >
> > The rdma rpc server has always tried to use FRMR for rdma reads as far as I recall.  The patch I submitted refactored the design
in
> > order to make it more efficient and to fix some bugs.   Unlike IB, the iWARP  protocol only allows 1 target/sink SGE in an rdma
read
> > request message, so an FRMR is used to create that single target/sink SGE allowing 1 read to be submitted instead of many.
> 
> How does this work when the client uses PHYSICAL memory registration?

Each page would require a separate rdma read WR.  That is why we use FRMRs. :)

> It can't form a read/write list SGE larger than a page, thus the
> server must emit an RDMA READ or WRITE for each page in the payload.
> 
> Curious, have you tried using iWARP with PHYSICAL MR on the client?
> 

No I haven't. 

> > I
> > believe that the FRMR allows for more efficient IO since w/o it you end up with large SGLs of 4K each and lots of read requests.
> > However, I have no data to back that up.  I would think that the write side (NFS READ) could also benefit from FRMRs too.  It
also
> > could use refactoring, because I believe it still creates an intermediate data structure to hold the write chunks vs just
> > translating them directly into the RDMA SGLs needed for the IO.  See send_write_chunks() and send_write() and how they create a
> > svc_rdma_req_map vector first and then translate that into the SGL needed for the rdma writes.
> >
> >
> >> My next step is to do some performance measurement to see if FRMR
> >> is worth the trouble, at least with the cards on hand.
> >>
> >> I notice that the lcl case does not seem to work with my CX-3 Pro.
> >> Probably a bug I will have to address first.
> >>
> >
> >>
> >>> Sagi.
> >>>
> >>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>>> ---
> >>>>
> >>>> include/linux/sunrpc/svc_rdma.h          |   10 ++++
> >>>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   71 +++++++++++-------------------
> >>>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +
> >>>> 3 files changed, 39 insertions(+), 44 deletions(-)
> >>>>
> >>>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> >>>> index 2280325..f161e30 100644
> >>>> --- a/include/linux/sunrpc/svc_rdma.h
> >>>> +++ b/include/linux/sunrpc/svc_rdma.h
> >>>> @@ -150,6 +150,10 @@ struct svcxprt_rdma {
> >>>> 	struct ib_cq         *sc_rq_cq;
> >>>> 	struct ib_cq         *sc_sq_cq;
> >>>> 	struct ib_mr         *sc_phys_mr;	/* MR for server memory */
> >>>> +	int		     (*sc_reader)(struct svcxprt_rdma *,
> >>>> +					  struct svc_rqst *,
> >>>> +					  struct svc_rdma_op_ctxt *,
> >>>> +					  int *, u32 *, u32, u32, u64, bool);
> >>>> 	u32		     sc_dev_caps;	/* distilled device caps */
> >>>> 	u32		     sc_dma_lkey;	/* local dma key */
> >>>> 	unsigned int	     sc_frmr_pg_list_len;
> >>>> @@ -195,6 +199,12 @@ extern int svc_rdma_xdr_get_reply_hdr_len(struct rpcrdma_msg *);
> >>>>
> >>>> /* svc_rdma_recvfrom.c */
> >>>> extern int svc_rdma_recvfrom(struct svc_rqst *);
> >>>> +extern int rdma_read_chunk_lcl(struct svcxprt_rdma *, struct svc_rqst *,
> >>>> +			       struct svc_rdma_op_ctxt *, int *, u32 *,
> >>>> +			       u32, u32, u64, bool);
> >>>> +extern int rdma_read_chunk_frmr(struct svcxprt_rdma *, struct svc_rqst *,
> >>>> +				struct svc_rdma_op_ctxt *, int *, u32 *,
> >>>> +				u32, u32, u64, bool);
> >>>>
> >>>> /* svc_rdma_sendto.c */
> >>>> extern int svc_rdma_sendto(struct svc_rqst *);
> >>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >>>> index 577f865..c3aebc1 100644
> >>>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >>>> @@ -117,26 +117,16 @@ static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
> >>>> 		return min_t(int, sge_count, xprt->sc_max_sge);
> >>>> }
> >>>>
> >>>> -typedef int (*rdma_reader_fn)(struct svcxprt_rdma *xprt,
> >>>> -			      struct svc_rqst *rqstp,
> >>>> -			      struct svc_rdma_op_ctxt *head,
> >>>> -			      int *page_no,
> >>>> -			      u32 *page_offset,
> >>>> -			      u32 rs_handle,
> >>>> -			      u32 rs_length,
> >>>> -			      u64 rs_offset,
> >>>> -			      int last);
> >>>> -
> >>>> /* Issue an RDMA_READ using the local lkey to map the data sink */
> >>>> -static int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> >>>> -			       struct svc_rqst *rqstp,
> >>>> -			       struct svc_rdma_op_ctxt *head,
> >>>> -			       int *page_no,
> >>>> -			       u32 *page_offset,
> >>>> -			       u32 rs_handle,
> >>>> -			       u32 rs_length,
> >>>> -			       u64 rs_offset,
> >>>> -			       int last)
> >>>> +int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> >>>> +			struct svc_rqst *rqstp,
> >>>> +			struct svc_rdma_op_ctxt *head,
> >>>> +			int *page_no,
> >>>> +			u32 *page_offset,
> >>>> +			u32 rs_handle,
> >>>> +			u32 rs_length,
> >>>> +			u64 rs_offset,
> >>>> +			bool last)
> >>>> {
> >>>> 	struct ib_send_wr read_wr;
> >>>> 	int pages_needed = PAGE_ALIGN(*page_offset + rs_length) >> PAGE_SHIFT;
> >>>> @@ -221,15 +211,15 @@ static int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
> >>>> }
> >>>>
> >>>> /* Issue an RDMA_READ using an FRMR to map the data sink */
> >>>> -static int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> >>>> -				struct svc_rqst *rqstp,
> >>>> -				struct svc_rdma_op_ctxt *head,
> >>>> -				int *page_no,
> >>>> -				u32 *page_offset,
> >>>> -				u32 rs_handle,
> >>>> -				u32 rs_length,
> >>>> -				u64 rs_offset,
> >>>> -				int last)
> >>>> +int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
> >>>> +			 struct svc_rqst *rqstp,
> >>>> +			 struct svc_rdma_op_ctxt *head,
> >>>> +			 int *page_no,
> >>>> +			 u32 *page_offset,
> >>>> +			 u32 rs_handle,
> >>>> +			 u32 rs_length,
> >>>> +			 u64 rs_offset,
> >>>> +			 bool last)
> >>>> {
> >>>> 	struct ib_send_wr read_wr;
> >>>> 	struct ib_send_wr inv_wr;
> >>>> @@ -374,9 +364,9 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
> >>>> {
> >>>> 	int page_no, ret;
> >>>> 	struct rpcrdma_read_chunk *ch;
> >>>> -	u32 page_offset, byte_count;
> >>>> +	u32 handle, page_offset, byte_count;
> >>>> 	u64 rs_offset;
> >>>> -	rdma_reader_fn reader;
> >>>> +	bool last;
> >>>>
> >>>> 	/* If no read list is present, return 0 */
> >>>> 	ch = svc_rdma_get_read_chunk(rmsgp);
> >>>> @@ -399,27 +389,20 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
> >>>> 	head->arg.len = rqstp->rq_arg.len;
> >>>> 	head->arg.buflen = rqstp->rq_arg.buflen;
> >>>>
> >>>> -	/* Use FRMR if supported */
> >>>> -	if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)
> >>>> -		reader = rdma_read_chunk_frmr;
> >>>> -	else
> >>>> -		reader = rdma_read_chunk_lcl;
> >>>> -
> >>>> 	page_no = 0; page_offset = 0;
> >>>> 	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
> >>>> 	     ch->rc_discrim != 0; ch++) {
> >>>> -
> >>>> +		handle = be32_to_cpu(ch->rc_target.rs_handle);
> >>>> +		byte_count = be32_to_cpu(ch->rc_target.rs_length);
> >>>> 		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
> >>>> 				 &rs_offset);
> >>>> -		byte_count = ntohl(ch->rc_target.rs_length);
> >>>>
> >>>> 		while (byte_count > 0) {
> >>>> -			ret = reader(xprt, rqstp, head,
> >>>> -				     &page_no, &page_offset,
> >>>> -				     ntohl(ch->rc_target.rs_handle),
> >>>> -				     byte_count, rs_offset,
> >>>> -				     ((ch+1)->rc_discrim == 0) /* last */
> >>>> -				     );
> >>>> +			last = (ch + 1)->rc_discrim == xdr_zero;
> >>>> +			ret = xprt->sc_reader(xprt, rqstp, head,
> >>>> +					      &page_no, &page_offset,
> >>>> +					      handle, byte_count,
> >>>> +					      rs_offset, last);
> >>>> 			if (ret < 0)
> >>>> 				goto err;
> >>>> 			byte_count -= ret;
> >>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >>>> index f2e059b..f609c1c 100644
> >>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >>>> @@ -974,10 +974,12 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
> >>>> 	 * NB:	iWARP requires remote write access for the data sink
> >>>> 	 *	of an RDMA_READ. IB does not.
> >>>> 	 */
> >>>> +	newxprt->sc_reader = rdma_read_chunk_lcl;
> >>>> 	if (devattr.device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) {
> >>>> 		newxprt->sc_frmr_pg_list_len =
> >>>> 			devattr.max_fast_reg_page_list_len;
> >>>> 		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_FAST_REG;
> >>>> +		newxprt->sc_reader = rdma_read_chunk_frmr;
> >>>> 	}
> >>>>
> >>>> 	/*
> >>>>
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> >>>> the body of a message to majordomo@vger.kernel.org
> >>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>>
> >>>
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >> --
> >> Chuck Lever
> >> chuck[dot]lever[at]oracle[dot]com
> >>
> >
> >
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 


