Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-04.prod.phx3.secureserver.net ([173.201.192.233]:46989
	"EHLO p3plsmtpa07-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751014AbbEFAQH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 20:16:07 -0400
Message-ID: <55495D41.5090502@talpey.com>
Date: Tue, 05 May 2015 20:16:01 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Steve French <smfrench@gmail.com>
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net> <20150505154411.GA16729@infradead.org> <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com> <20150505172540.GA19442@infradead.org> <55490886.4070502@talpey.com> <20150505191012.GA21164@infradead.org> <55492ED3.7000507@talpey.com> <20150505210627.GA5941@infradead.org> <554936E5.80607@talpey.com> <20150505223855.GA7696@obsidianresearch.com>
In-Reply-To: <20150505223855.GA7696@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm adding Steve French because I'm about to talk about SMB.

On 5/5/2015 6:38 PM, Jason Gunthorpe wrote:
> On Tue, May 05, 2015 at 05:32:21PM -0400, Tom Talpey wrote:
>
>>> Do you have any information on these attempts and why the failed?  Note
>>> that the only interesting ones would be for in-kernel consumers.
>>> Userspace verbs are another order of magnitude more problems, so they're
>>> not too interesting.
>>
>> Hmm, most of these are userspace API experiences, and I would not be
>> so quick as to dismiss their applicability, or their lessons.
>
> The specific use-case of a RDMA to/from a logical linear region broken
> up into HW pages is incredibly kernel specific, and very friendly to
> hardware support.
>
> Heck, on modern systems 100% of these requirements can be solved just
> by using the IOMMU. No need for the HCA at all. (HCA may be more
> performant, of course)

I don't agree on "100%", because IOMMUs don't have the same protection
attributes as RDMA adapters (local R, local W, remote R, remote W). Also
they don't support handles for page lists quite like STags/RMRs, so they
require additional (R)DMA scatter/gather. But, I agree with your point
that they translate addresses just great.

> This is a huge pain for everyone. ie The Lustre devs were talking
> about how Lustre is not performant on newer HCAs because their code
> doesn't support the new MR scheme.
>
> It makes sense to me to have a dedicated API for this work load:
>
> 'post outbound rdma send/write of page region'

A bunch of writes followed by a send is a common sequence, but not
very complex (I think).

> 'prepare inbound rdma write of page region'

This is memory registration, with remote writability. That's what
the rpcrdma_register_external() API in xprtrdma/verbs.c does. It
takes a private rpcrdma structure, but it supports multiple memreg
strategies and pretty much does what you expect. I'm sure someone
could abstract it upward.

> 'post rdma read, result into page region'

The svcrdma stuff in the NFS RDMA server has this, it's called from
the XDR decoding.

> 'complete X'

This is trickier - invalidation has many interesting error cases.
But, on a sunny day with the breeze at our backs, sure.

> I'd love to see someone propose some patches :)

I'd like to mention something else. Many upper layers basically want
a socket, but memory registration and explicit RDMA break that. There
have been some relatively awful solutions to make it all transparent,
let's not go there.

The RPC/RDMA protocol was designed to tuck underneath RPC and
XDR, so, while not socket-like, it allowed RPC to hide RDMA
from (for example) NFS. NFS therefore did not have to change.
I thought transparency was a good idea at the time.

SMB Direct, in Windows, presents a socket-like interface for messaging
(connection, send/receive, etc), but makes memory registration and
RDMA Read / Write explicit. It's the SMB3 protocol that drives RDMA,
which it does only for SMB_READ and SMB_WRITE. The SMB3 upper layer
knows it's on an RDMA-capable connection, and "sets up" the transfer
by explicitly deciding to do an RDMA, which it does by asking the
SMB Direct driver to register memory. It then gets back one or more
handles, which it sends to the server in the SMB3 layer message.
The server performs the RDMA, and the reply indicates the result.
After which, the SMB3 upper layer explicitly de-registers.

If Linux upper layers considered adopting a similar approach by
carefully inserting RDMA operations conditionally, it can make
the lower layer's job much more efficient. And, efficiency is speed.
And in the end, the API throughout the stack will be simpler.

MHO.

Tom.

