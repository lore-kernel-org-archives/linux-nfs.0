From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/05] svcrdma: Refactor RDMA_WRITE dma mapping logic
Date: Sun, 25 May 2008 15:05:36 -0400
Message-ID: <20080525190536.GF8094@fieldses.org>
References: <12111560011694-git-send-email-tom@opengridcomputing.com> <12111560022506-git-send-email-tom@opengridcomputing.com> <1211156002624-git-send-email-tom@opengridcomputing.com> <20080521004608.GL8177@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757482AbYEYTFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 25 May 2008 15:05:37 -0400
In-Reply-To: <20080521004608.GL8177@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm also still curious about this:

On Tue, May 20, 2008 at 08:46:08PM -0400, bfields wrote:
> On Sun, May 18, 2008 at 07:13:18PM -0500, Tom Tucker wrote:
> > @@ -181,14 +170,20 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
> >  
> >  	/* Copy the remaining SGE */
> >  	while (bc != 0 && xdr_sge_no < sge_count) {
> > -		sge[sge_no].addr = xdr_sge[xdr_sge_no].addr + sge_off;
> >  		sge[sge_no].lkey = xdr_sge[xdr_sge_no].lkey;
> >  		sge_bytes = min((size_t)bc,
> >  				(size_t)(xdr_sge[xdr_sge_no].length-sge_off));
> >  		sge[sge_no].length = sge_bytes;
> > -
> > +		sge[sge_no].addr =
> > +			ib_dma_map_single(xprt->sc_cm_id->device,
> > +					  (void *)
> > +					  xdr_sge[xdr_sge_no].addr + sge_off,
> > +					  sge_bytes, DMA_TO_DEVICE);
> > +		if (dma_mapping_error(sge[sge_no].addr))
> > +			return -EINVAL;
> 
> And then here we're casting the u64 back to a void *.  Also, we're
> adding sge_off to the input, instead of to the result.  Is it true that
> that
> 
> 	ib_dma_map_single(., x + sge_off, ., .)
> 
> and
> 
> 	ib_dma_map_single(., x, ., .) + sge_off
> 
> always have the same result?
> 
> --b.
