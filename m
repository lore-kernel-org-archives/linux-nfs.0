Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-08.prod.phx3.secureserver.net ([173.201.193.109]:44422
	"EHLO p3plsmtpa08-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753005AbbKXMgh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 07:36:37 -0500
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
To: Christoph Hellwig <hch@infradead.org>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com> <20151124065225.GB29141@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, Sagi Grimberg <sagig@mellanox.com>,
        santosh.shilimkar@oracle.com
From: Tom Talpey <tom@talpey.com>
Message-ID: <565459D2.9010600@talpey.com>
Date: Tue, 24 Nov 2015 07:36:34 -0500
MIME-Version: 1.0
In-Reply-To: <20151124065225.GB29141@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/24/2015 1:52 AM, Christoph Hellwig wrote:
> On Mon, Nov 23, 2015 at 07:57:42PM -0500, Tom Talpey wrote:
>> On 11/23/2015 5:14 PM, Chuck Lever wrote:
>>> FMR's ro_unmap method is already synchronous because ib_unmap_fmr()
>>> is a synchronous verb. However, some improvements can be made here.
>>
>> I thought FMR support was about to be removed in the core.
>
> Seems like everyone would love to kill it, but no one dares to do
> it just yet.  Reasons to keep FMRs:
>
>   - mthca doesn't support FRs but haven't been staged out
>   - RDS only supports FRMs for the IB transports (it does support FRs for
>     an entirely separate iWarp transports.  I'd love to know why we can't
>     just use that iWarp transport for IB as well).
>   - mlx4 hardware might be slower with FRs than FRMs (Or mentioned this
>     in reply to the iSER remote invalidation series).

Ok, let me add then.

Reasons to kill FMRs:

   - FMRs are UNSAFE. They protect on page boundaries, not byte,
     therefore a length error on an operation can corrupt data
     outside the i/o buffer remotely. To say nothing of maliciousness.

   - FMRs are SLOWER. The supposed performance improvement of FMR
     comes from the "mempool" that is often placed in front of them.
     These pools cache remotely registered regions, in the hope of
     reusing them without having to invalidate in between. See the
     first bullet for the ramifications of that.

   - FMRs are SYNCHRONOUS. The FMR verbs make direct calls into the
     verbs which block and/or do not return control to the caller
     promptly as do work queue operations. The processor spends
     more time servicing the device, typically at raised irq.

   - FMRs are PROPRIETARY. Only one vendor supports them, only one
     of their NICs has no decent alternative, and that NIC is
     functionally obsolete.

If storage stacks continue to support them, I personally feel it
is critical to carefully document the risks to customer data as
part of shipping the code.

Tom.
