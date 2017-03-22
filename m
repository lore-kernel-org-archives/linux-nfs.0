Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35585 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934283AbdCVNHh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 09:07:37 -0400
Subject: Re: [PATCH v1 02/14] svcrdma: Add svc_rdma_map_reply_hdr()
To: Chuck Lever <chuck.lever@oracle.com>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
 <20170316155242.4482.64809.stgit@klimt.1015granger.net>
 <f5000e25-6ca1-fc24-35c0-6089cf50923c@grimberg.me>
 <A18F9D5E-09BA-4268-9AA6-3E5866101F76@oracle.com>
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <c70544b7-1dfd-65fb-c18f-823085084c20@grimberg.me>
Date: Wed, 22 Mar 2017 15:07:07 +0200
MIME-Version: 1.0
In-Reply-To: <A18F9D5E-09BA-4268-9AA6-3E5866101F76@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> I can't think of any. The only time this code changes is
> when overhauls like this happens.
>
> I don't mind putting the out_unmap label back.

Your call...

>> btw, I'm assuming svc_rdma_unmap_dma() is the opposite of
>> svc_rdma_map_reply_hdr() ?
>
> svc_rdma_map_reply_hdr() DMA-maps the transport header buffer.
>
> svc_rdma_unmap_dma() DMA-unmaps everything associated with
> the ctxt.

a bit non trivial, but ok I guess...
