Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:51179 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041AbbEFQUV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 12:20:21 -0400
Date: Wed, 6 May 2015 10:20:05 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Steve French <smfrench@gmail.com>
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
Message-ID: <20150506162005.GA11331@obsidianresearch.com>
References: <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
 <20150505172540.GA19442@infradead.org>
 <55490886.4070502@talpey.com>
 <20150505191012.GA21164@infradead.org>
 <55492ED3.7000507@talpey.com>
 <20150505210627.GA5941@infradead.org>
 <554936E5.80607@talpey.com>
 <20150505223855.GA7696@obsidianresearch.com>
 <55495D41.5090502@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55495D41.5090502@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 08:16:01PM -0400, Tom Talpey wrote:

> >The specific use-case of a RDMA to/from a logical linear region broken
> >up into HW pages is incredibly kernel specific, and very friendly to
> >hardware support.
> >
> >Heck, on modern systems 100% of these requirements can be solved just
> >by using the IOMMU. No need for the HCA at all. (HCA may be more
> >performant, of course)
> 
> I don't agree on "100%", because IOMMUs don't have the same protection
> attributes as RDMA adapters (local R, local W, remote R, remote W).

No, you do get protection - the IOMMU isn't the only resource, it would
still have to be combined with several pre-setup MR's that have the
proper protection attributes. You'd map the page list into the address
space that is covered by a MR that has the protection attributes
needed.

> Also they don't support handles for page lists quite like
> STags/RMRs, so they require additional (R)DMA scatter/gather. But, I
> agree with your point that they translate addresses just great.

??? the entire point of using the IOMMU in a context like this is to
linearize the page list into DMA'able address. How could you ever need
to scatter/gather when your memory is linear?

> >'post outbound rdma send/write of page region'
> 
> A bunch of writes followed by a send is a common sequence, but not
> very complex (I think).

So, I wasn't clear, I mean a general API that can post a SEND or RDMA
WRITE using a logically linear page list as the data source.

So this results in one of:
 1) A SEND with a gather list
 2) A SEND with a temporary linearized MR
 3) A series of RDMA WRITE with gather lists
 4) A RDMA WRITE with a temporary linearized MR

Picking one depends on the performance of the HCA and the various
features it supports. Even just the really simple options of #1 and #3
become a bit more complex when you want to take advantage of
transparent huge pages to reduce gather list length.

For instance, deciding when to trade off 3 vs 4 is going to be very
driver specific..

> >'prepare inbound rdma write of page region'
> 
> This is memory registration, with remote writability. That's what
> the rpcrdma_register_external() API in xprtrdma/verbs.c does. It
> takes a private rpcrdma structure, but it supports multiple memreg
> strategies and pretty much does what you expect. I'm sure someone
> could abstract it upward.

Right, most likely an implementation would just pull the NFS code into
the core, I think it is the broadest version we have?

> >'complete X'
> 
> This is trickier - invalidation has many interesting error cases.
> But, on a sunny day with the breeze at our backs, sure.

I don't mean send+invalidate, this is the 'free' for the 'alloc' the
above APIs might need (ie the temporary MR). You can't fail to free
the MR - that would be an insane API :)

> If Linux upper layers considered adopting a similar approach by
> carefully inserting RDMA operations conditionally, it can make
> the lower layer's job much more efficient. And, efficiency is speed.
> And in the end, the API throughout the stack will be simpler.

No idea for Linux. It seems to me most of the use cases we are talking
about here not actually assuming a socket, NFS-RDMA, SRP, iSER, Lustre
are all explicitly driving verbs and explicity working with pages
lists for their high speed side.

Does that mean we are already doing what you are talking about?

Jason
