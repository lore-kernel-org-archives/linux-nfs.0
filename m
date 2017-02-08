Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44560 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbdBHRF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Feb 2017 12:05:26 -0500
Date: Wed, 8 Feb 2017 11:57:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 1/7] svcrdma: Another sendto chunk list parsing update
Message-ID: <20170208165700.GB16064@fieldses.org>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
 <20170207165815.14422.77348.stgit@klimt.1015granger.net>
 <20170207194252.GA28088@infradead.org>
 <C65F013C-84A2-456D-A0C0-04444D3C4D58@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C65F013C-84A2-456D-A0C0-04444D3C4D58@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 07, 2017 at 03:30:58PM -0500, Chuck Lever wrote:
> 
> > On Feb 7, 2017, at 2:42 PM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> >> 	/* Prepare the SGE for the RPCRDMA Header */
> >> 	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
> >> -	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
> >> +	ctxt->sge[0].length =
> >> +	    svc_rdma_xdr_get_reply_hdr_len((__be32 *)rdma_resp);
> > 
> > That case is pretty ugly, but given that it'll go away soon it's
> > probably fine for now.
> 
> Yes, the type cast will be replaced.
> 
> 
> > Otherwise this look good:
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Bruce, I assume you will pick up the extra Reviewed-by tags
> if I don't have to send another version of this series.

Yep, will do.

Thanks to you and Christoph.

--b.
