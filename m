Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33124 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932260AbdIFO3M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 10:29:12 -0400
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
 <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
 <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
Date: Wed, 6 Sep 2017 17:29:08 +0300
MIME-Version: 1.0
In-Reply-To: <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> Question, what happens in direct-io for example? Can a mapped buffer be
>> reclaimed/free'd before the send completion arrives?
> 
> Good Q! RPC completion allows memory containing the arguments and
> results to be re-used. IIRC our conclusion was that a retransmitted
> Send could expose the wrong argument data on the wire in this case.
> 
> Buffer re-use implies that the RPC has completed. Either a matching
> RPC Reply was received, or the RPC was terminated via a POSIX signal.
> 
> If the client has already received an RPC Reply for this transaction,
> a previous transmission of the RPC Call has already executed on the
> server, and this retransmission will be ignored. It's only purpose is
> to generate an appropriate RDMA ACK.
> 
> A re-used buffer might be subsequently used for data that is sensitive,
> and the retransmission will expose that data on the wire.

That was where I was going with this...

> To protect
> against that, RPC can use a GSS flavor that protects confidentiality
> of RPC arguments and results. This would also require RPC-over-RDMA
> to use only RDMA Read to convey RPC Call messages. Send would be used
> only to convey the chunk lists, never data.
> 
> Note that the buffers used to construct RPC Calls are always mapped
> and Send uses the local DMA key to post them. These can also be
> re-used immediately after RPC completion. The exposure risk there is
> of RPC headers and non-data arguments.

I see, but how can the user know that that it needs to use RPCSEC_GSS
otherwise nfs/rdma might compromise sensitive data? And is this
a valid constraint? (just asking, you're the expert)
