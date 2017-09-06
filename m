Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27150 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932280AbdIFOP5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 10:15:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
Date: Wed, 6 Sep 2017 10:15:42 -0400
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net> <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2017, at 7:54 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
>> Hi Jason, Sagi-
> 
> Hey Chuck,
> 
>> As we discussed a few weeks ago, this patch series implements the
>> following:
>> - Send SGEs are now managed via lock-less, wait-free circular queues
>> - Send SGEs referring to page cache pages are DMA unmapped during
>>   Send completion
>> - Send completions are batched to reduce interrupts, but still
>>   provide a periodic heartbeat signal for SQ housekeeping
>> - The circular queue prevents Send Queue overflow
>> The purpose of this change is to address the issue Sagi reported
>> where the HCA continues to retry a delayed Send request _after_ RPC
>> completion, resulting in a DMA error.
> 
> Question, what happens in direct-io for example? Can a mapped buffer be
> reclaimed/free'd before the send completion arrives?

Good Q! RPC completion allows memory containing the arguments and
results to be re-used. IIRC our conclusion was that a retransmitted
Send could expose the wrong argument data on the wire in this case.

Buffer re-use implies that the RPC has completed. Either a matching
RPC Reply was received, or the RPC was terminated via a POSIX signal.

If the client has already received an RPC Reply for this transaction,
a previous transmission of the RPC Call has already executed on the
server, and this retransmission will be ignored. It's only purpose is
to generate an appropriate RDMA ACK.

A re-used buffer might be subsequently used for data that is sensitive,
and the retransmission will expose that data on the wire. To protect
against that, RPC can use a GSS flavor that protects confidentiality
of RPC arguments and results. This would also require RPC-over-RDMA
to use only RDMA Read to convey RPC Call messages. Send would be used
only to convey the chunk lists, never data.

Note that the buffers used to construct RPC Calls are always mapped
and Send uses the local DMA key to post them. These can also be
re-used immediately after RPC completion. The exposure risk there is
of RPC headers and non-data arguments.


--
Chuck Lever



