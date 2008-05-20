From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 01/05] svcrdma: Verify read-list fits within
	RPCSVC_MAXPAGES
Date: Mon, 19 May 2008 20:07:52 -0500
Message-ID: <1211245672.31725.111.camel@trinity.ogc.int>
References: <12111560011694-git-send-email-tom@opengridcomputing.com>
	 <12111560022506-git-send-email-tom@opengridcomputing.com>
	 <20080519182003.GC11993@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:47668 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760707AbYETBEV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 21:04:21 -0400
In-Reply-To: <20080519182003.GC11993@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-05-19 at 14:20 -0400, J. Bruce Fields wrote:
> On Sun, May 18, 2008 at 07:13:17PM -0500, Tom Tucker wrote:
> > A RDMA read-list cannot contain more elements than RPCSVC_MAXPAGES or
> > it will overflow the DTO context. Verify this when processing the
> > protocol header.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > 
> > ---
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > index 6b16d8c..06ab484 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > @@ -306,6 +306,8 @@ static int rdma_read_xdr(struct svcxprt_rdma *xprt,
> >  	ch_sge_ary = (struct chunk_sge *)tmp_ch_ctxt->sge;
> >  
> >  	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
> > +	if (ch_count > RPCSVC_MAXPAGES)
> > +		return -EINVAL;
> >  	sge_count = rdma_rcl_to_sge(xprt, rqstp, hdr_ctxt, rmsgp,
> >  				    sge, ch_sge_ary,
> >  				    ch_count, byte_count);
> 
> If the ch_count is just the total number of bytes to be read into this
> request, then don't we also need to know at what offset they're going to
> be inserted?  (Shouldn't there be some check like ch->rc_position +
> ch_count > RPCSVC_MAXPAGES ?)
> 

The ch_count is the number of RPCRDMA chunk elements in the read-list.
It's not a byte count, but a scatter-gather-list length.

I think the local read-list buffer limits should be clamped by
svc_rdma_rcl_chunk_counts, however, see below...

> Also, do we verify somewhere (before calling
> svc_rdma_rcl_chunk_counts()) that rc_discrim is set on the last chunk?
> 

No we don't and a Byzantine client could crash us. The computed
byte_count should also be clamped here. I'll add this to the list --
nice catch.

This kind of check along with a bunch of others should go in
svc_rdma_xdr_decode_req.  I have these things planned for the 2.6.27
time-frame (along with Fast NSMR support). 

Do you think it's more urgent?

Tom

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

