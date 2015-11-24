Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34718 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363AbbKXK7I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 05:59:08 -0500
Received: by wmvv187 with SMTP id v187so203113612wmv.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2015 02:59:07 -0800 (PST)
Subject: Re: [PATCH v1 3/9] xprtrdma: Introduce ro_unmap_sync method
To: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221414.32702.87638.stgit@manet.1015granger.net>
 <20151124064556.GA29141@infradead.org>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sagi Grimberg <sagig@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <565442F5.7080400@dev.mellanox.co.il>
Date: Tue, 24 Nov 2015 12:59:01 +0200
MIME-Version: 1.0
In-Reply-To: <20151124064556.GA29141@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/11/2015 08:45, Christoph Hellwig wrote:
> On Mon, Nov 23, 2015 at 05:14:14PM -0500, Chuck Lever wrote:
>> In the current xprtrdma implementation, some memreg strategies
>> implement ro_unmap synchronously (the MR is knocked down before the
>> method returns) and some asynchonously (the MR will be knocked down
>> and returned to the pool in the background).
>>
>> To guarantee the MR is truly invalid before the RPC consumer is
>> allowed to resume execution, we need an unmap method that is
>> always synchronous, invoked from the RPC/RDMA reply handler.
>>
>> The new method unmaps all MRs for an RPC. The existing ro_unmap
>> method unmaps only one MR at a time.
>
> Do we really want to go down that road?  It seems like we've decided
> in general that while the protocol specs say MR must be unmapped before
> proceeding with the data that is painful enough to ignore this
> requirement.  E.g. iser for example only does the local invalidate
> just before reusing the MR.

It is painful, too painful. The entire value proposition of RDMA is
low-latency and waiting for the extra HW round-trip for a local
invalidation to complete is unacceptable, moreover it adds a huge loads
of extra interrupts and cache-line pollutions.

As I see it, if we don't wait for local-invalidate to complete before
unmap and IO completion (and no one does) then local invalidate before
re-use is only marginally worse. For iSER, remote invalidate solves this 
(patches submitted!) and I'd say we should push for all the
storage standards to include remote invalidate. There is the question
of multi-rkey transactions, which is why I stated in the past that
arbitrary sg registration is important (which will be submitted soon
for ConnectX-4).

Waiting for local invalidate to complete would be a really big
sacrifice for our storage ULPs.
