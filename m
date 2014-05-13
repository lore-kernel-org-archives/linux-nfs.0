Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36076 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754755AbaEMUhj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 May 2014 16:37:39 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chucklever@gmail.com>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>,
        "'Tom Tucker'" <tom@opengridcomputing.com>
References: <20140506174621.18208.24242.stgit@build.ogc.int> <20140506174632.18208.28160.stgit@build.ogc.int> <F997E138-FB04-4149-811D-CE68608E8D6B@gmail.com>
In-Reply-To: <F997E138-FB04-4149-811D-CE68608E8D6B@gmail.com>
Subject: RE: [PATCH V2 RFC 2/3] svcrdma: Recvfrom changes
Date: Tue, 13 May 2014 15:37:41 -0500
Message-ID: <00f901cf6eeb$2ff1f630$8fd5e290$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Chuck Lever [mailto:chucklever@gmail.com]
> Sent: Tuesday, May 13, 2014 1:22 PM
> To: Steve Wise
> Cc: J. Bruce Fields; Linux NFS Mailing List; linux-rdma@vger.kernel.org; Tom Tucker
> Subject: Re: [PATCH V2 RFC 2/3] svcrdma: Recvfrom changes
> 
> Hi Steve-
> 
> Some random review comments, see below.
> 

<snip>

> > +static int rdma_read_chunks(struct svcxprt_rdma *xprt,
> > +			    struct rpcrdma_msg *rmsgp,
> > +			    struct svc_rqst *rqstp,
> > +			    struct svc_rdma_op_ctxt *head)
> > {
> > -	struct ib_send_wr read_wr;
> > -	struct ib_send_wr inv_wr;
> > -	int err = 0;
> > -	int ch_no;
> > -	int ch_count;
> > -	int byte_count;
> > -	int sge_count;
> > -	u64 sgl_offset;
> > +	int page_no, ch_count, ret;
> > 	struct rpcrdma_read_chunk *ch;
> > -	struct svc_rdma_op_ctxt *ctxt = NULL;
> > -	struct svc_rdma_req_map *rpl_map;
> > -	struct svc_rdma_req_map *chl_map;
> > +	u32 page_offset, byte_count;
> > +	u64 rs_offset;
> > +	rdma_reader_fn reader;
> >
> > 	/* If no read list is present, return 0 */
> > 	ch = svc_rdma_get_read_chunk(rmsgp);
> > @@ -408,122 +368,53 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
> > 	if (ch_count > RPCSVC_MAXPAGES)
> > 		return -EINVAL;
> 
> I'm not sure what this ^^^ ch_count check is doing, but maybe I haven't had
> enough caffeine this morning. Shouldn't this code be comparing the segment
> count, not the chunk count, with MAXPAGES?

Isn't ch_count really the number of chunks in the RPC?  I'm not sure what "segment count"
you are talking about?

> 
> 
> >
> > -	/* Allocate temporary reply and chunk maps */
> > -	rpl_map = svc_rdma_get_req_map();
> > -	chl_map = svc_rdma_get_req_map();
> > -
> > -	if (!xprt->sc_frmr_pg_list_len)
> > -		sge_count = map_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
> > -					    rpl_map, chl_map, ch_count,
> > -					    byte_count);
> > -	else
> > -		sge_count = fast_reg_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
> > -						 rpl_map, chl_map, ch_count,
> > -						 byte_count);
> > -	if (sge_count < 0) {
> > -		err = -EIO;
> > -		goto out;
> > -	}
> > -
> > -	sgl_offset = 0;
> > -	ch_no = 0;
> > +	/* The request is completed when the RDMA_READs complete. The
> > +	 * head context keeps all the pages that comprise the
> > +	 * request.
> > +	 */
> > +	head->arg.head[0] = rqstp->rq_arg.head[0];
> > +	head->arg.tail[0] = rqstp->rq_arg.tail[0];
> > +	head->arg.pages = &head->pages[head->count];
> > +	head->hdr_count = head->count;
> > +	head->arg.page_base = 0;
> > +	head->arg.page_len = 0;
> > +	head->arg.len = rqstp->rq_arg.len;
> > +	head->arg.buflen = rqstp->rq_arg.buflen + PAGE_SIZE;
> >
> > +	page_no = 0; page_offset = 0;
> > 	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
> > -	     ch->rc_discrim != 0; ch++, ch_no++) {
> > -		u64 rs_offset;
> > -next_sge:
> > -		ctxt = svc_rdma_get_context(xprt);
> > -		ctxt->direction = DMA_FROM_DEVICE;
> > -		ctxt->frmr = hdr_ctxt->frmr;
> > -		ctxt->read_hdr = NULL;
> > -		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> > -		clear_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
> > +	     ch->rc_discrim != 0; ch++) {
> 
> 
> As I understand it, this loop is iterating over the items in the RPC
> header's read chunk list.
> 
> RFC 5667 section 4 says
> 
> "The server MUST ignore any Read list for other NFS procedures, as well
> as additional Read list entries beyond the first in the list."
> 

I interpret this to say the server should ignore an RDMA Write list, if present, when
processing an NFS WRITE (because the server emits RDMA Reads to the client in this case).
Similarly, it should ignore an RDMA Read list when processing an NFS READ (which generates
RDMA Writes from the server->client to fulfill the NFS READ). 

> But rdma_read_chunks() still expects multiple chunks in the incoming list.

An RDMA Read list can have multiple chunks, yes?


> Should this code follow the RFC and process only the first chunk in
> each RPC header, or did I misunderstand the RFC text?
> 
> I'm not sure how the RPC layer should enforce the requirement to ignore
> chunks for particular classes of NFS requests. But seems like valid
> NFS/RDMA requests will have only zero or one item in each chunk list.
> 
> 
> The ramification of this change:
> 
> The Linux client sends an extra chunk which is a zero pad to satisfy XDR
> alignment. This results in an extra RDMA READ on the wire for a payload
> that is never more than 3 bytes of zeros.
>

This sounds like a logic bug in the server then.  You see these IOs on the wire?
 
> Section 3.7 of RFC 5666 states:
> 
> "If in turn, no data remains to be decoded from the inline portion, then
> the receiver MUST conclude that roundup is present, and therefore it
> advances the XDR decode position to that indicated by the next chunk (if
> any).  In this way, roundup is passed without ever actually transferring
> additional XDR bytes."
> 
> Later, it states:
> 
> "Senders SHOULD therefore avoid encoding individual RDMA Read Chunks for
> roundup whenever possible."
> 
> The Solaris NFS/RDMA server does not require this extra chunk, but Linux
> appears to need it. When I enable pad optimization on the Linux client,
> it works fine with the Solaris server. But the first NFS WRITE with an
> odd length against the Linux server causes connection loss and the client
> workload hangs.
> 
> At some point I'd like to permanently enable this optimization on the
> Linux client. You can try this out with:
> 
>  sudo echo 1 > /proc/sys/sunrpc/rdma_pad_optimize
> 
> The default contents of this file leave pad optimization disabled, for
> compatibility with the current Linux NFS/RDMA server.
> 
> So rdma_read_chunks() needs to handle the implicit XDR length round-up.
> That's probably not hard.
> 
> What I'm asking is:
> 
> Do you agree the server should be changed to comply with section 4 of 5667?
> 

I think it is complying and you are misinterpreting.  But I could be misinterpreting it
too :)

But we should fix the pad thing.

> Should you change now in this patch, or do you want me to write a patch
> for it once the refactoring patch has been accepted?
> 

I'd like to get this refactoring in and then continue improving it.  Unfortunately, I
think you still see some bug running over mthca, eh?  I haven't debugged that yet.  I plan
to and then resubmit V3 (squashed).


> 
> 
> >
> > -		/* Prepare READ WR */
> > -		memset(&read_wr, 0, sizeof read_wr);
> > -		read_wr.wr_id = (unsigned long)ctxt;
> > -		read_wr.opcode = IB_WR_RDMA_READ;
> > -		ctxt->wr_op = read_wr.opcode;
> > -		read_wr.send_flags = IB_SEND_SIGNALED;
> > -		read_wr.wr.rdma.rkey = ntohl(ch->rc_target.rs_handle);
> > 		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
> > 				 &rs_offset);
> > -		read_wr.wr.rdma.remote_addr = rs_offset + sgl_offset;
> > -		read_wr.sg_list = ctxt->sge;
> > -		read_wr.num_sge =
> > -			rdma_read_max_sge(xprt, chl_map->ch[ch_no].count);
> > -		err = rdma_set_ctxt_sge(xprt, ctxt, hdr_ctxt->frmr,
> > -					&rpl_map->sge[chl_map->ch[ch_no].start],
> > -					&sgl_offset,
> > -					read_wr.num_sge);
> > -		if (err) {
> > -			svc_rdma_unmap_dma(ctxt);
> > -			svc_rdma_put_context(ctxt, 0);
> > -			goto out;
> > -		}
> > -		if (((ch+1)->rc_discrim == 0) &&
> > -		    (read_wr.num_sge == chl_map->ch[ch_no].count)) {
> > -			/*
> > -			 * Mark the last RDMA_READ with a bit to
> > -			 * indicate all RPC data has been fetched from
> > -			 * the client and the RPC needs to be enqueued.
> > -			 */
> > -			set_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
> > -			if (hdr_ctxt->frmr) {
> > -				set_bit(RDMACTXT_F_FAST_UNREG, &ctxt->flags);
> > -				/*
> > -				 * Invalidate the local MR used to map the data
> > -				 * sink.
> > -				 */
> > -				if (xprt->sc_dev_caps &
> > -				    SVCRDMA_DEVCAP_READ_W_INV) {
> > -					read_wr.opcode =
> > -						IB_WR_RDMA_READ_WITH_INV;
> > -					ctxt->wr_op = read_wr.opcode;
> > -					read_wr.ex.invalidate_rkey =
> > -						ctxt->frmr->mr->lkey;
> > -				} else {
> > -					/* Prepare INVALIDATE WR */
> > -					memset(&inv_wr, 0, sizeof inv_wr);
> > -					inv_wr.opcode = IB_WR_LOCAL_INV;
> > -					inv_wr.send_flags = IB_SEND_SIGNALED;
> > -					inv_wr.ex.invalidate_rkey =
> > -						hdr_ctxt->frmr->mr->lkey;
> > -					read_wr.next = &inv_wr;
> > -				}
> > -			}
> > -			ctxt->read_hdr = hdr_ctxt;
> > -		}
> > -		/* Post the read */
> > -		err = svc_rdma_send(xprt, &read_wr);
> > -		if (err) {
> > -			printk(KERN_ERR "svcrdma: Error %d posting RDMA_READ\n",
> > -			       err);
> > -			set_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags);
> > -			svc_rdma_unmap_dma(ctxt);
> > -			svc_rdma_put_context(ctxt, 0);
> > -			goto out;
> > +		byte_count = ntohl(ch->rc_target.rs_length);
> > +
> > +		/* Use FRMR if supported */
> > +		if (xprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)
> > +			reader = rdma_read_chunk_frmr;
> > +		else
> > +			reader = rdma_read_chunk_lcl;
> 
> The reader function is invariant across iterations of the for() loop.
> In fact, it is invariant for all incoming requests on an xprt, isn't it?
> 
> Can svc_rdma_create() plant that function pointer in the xprt?
> 

Yea, that sounds good. 


Thanks for reviewing!

Steve.

