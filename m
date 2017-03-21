Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17914 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932865AbdCUSkY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Mar 2017 14:40:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 02/14] svcrdma: Add svc_rdma_map_reply_hdr()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <f5000e25-6ca1-fc24-35c0-6089cf50923c@grimberg.me>
Date: Tue, 21 Mar 2017 14:40:16 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A18F9D5E-09BA-4268-9AA6-3E5866101F76@oracle.com>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net> <20170316155242.4482.64809.stgit@klimt.1015granger.net> <f5000e25-6ca1-fc24-35c0-6089cf50923c@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 21, 2017, at 1:54 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> 	svc_rdma_build_send_wr(ctxt, 1);
>> 	ret = svc_rdma_send(rdma, &ctxt->send_wr);
>> 	if (ret) {
>> +		svc_rdma_unmap_dma(ctxt);
>> +		svc_rdma_put_context(ctxt, 1);
>> 		ret = -EIO;
>> -		goto out_unmap;
>> 	}
> 
> Any specific reason to not go with the goto scheme?

Only one "goto out_unmap" call site is left, and this
isn't a performance critical path.


> Can't this function grow more error paths in the future?

I can't think of any. The only time this code changes is
when overhauls like this happens.

I don't mind putting the out_unmap label back.


> btw, I'm assuming svc_rdma_unmap_dma() is the opposite of
> svc_rdma_map_reply_hdr() ?

svc_rdma_map_reply_hdr() DMA-maps the transport header buffer.

svc_rdma_unmap_dma() DMA-unmaps everything associated with
the ctxt.


--
Chuck Lever



