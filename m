Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38781 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932270AbdBGUTS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 15:19:18 -0500
Date: Tue, 7 Feb 2017 11:42:52 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/7] svcrdma: Another sendto chunk list parsing update
Message-ID: <20170207194252.GA28088@infradead.org>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
 <20170207165815.14422.77348.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170207165815.14422.77348.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  	/* Prepare the SGE for the RPCRDMA Header */
>  	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
> -	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
> +	ctxt->sge[0].length =
> +	    svc_rdma_xdr_get_reply_hdr_len((__be32 *)rdma_resp);

That case is pretty ugly, but given that it'll go away soon it's
probably fine for now.

Otherwise this look good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
