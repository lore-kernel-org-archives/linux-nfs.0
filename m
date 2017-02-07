Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44240 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755431AbdBGWei (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 17:34:38 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 1/7] svcrdma: Another sendto chunk list parsing update
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170207194252.GA28088@infradead.org>
Date: Tue, 7 Feb 2017 15:30:58 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C65F013C-84A2-456D-A0C0-04444D3C4D58@oracle.com>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net> <20170207165815.14422.77348.stgit@klimt.1015granger.net> <20170207194252.GA28088@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 7, 2017, at 2:42 PM, Christoph Hellwig <hch@infradead.org> wrote:
> 
>> 	/* Prepare the SGE for the RPCRDMA Header */
>> 	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
>> -	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
>> +	ctxt->sge[0].length =
>> +	    svc_rdma_xdr_get_reply_hdr_len((__be32 *)rdma_resp);
> 
> That case is pretty ugly, but given that it'll go away soon it's
> probably fine for now.

Yes, the type cast will be replaced.


> Otherwise this look good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Bruce, I assume you will pick up the extra Reviewed-by tags
if I don't have to send another version of this series.


--
Chuck Lever



