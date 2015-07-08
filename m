Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa06-10.prod.phx3.secureserver.net ([173.201.192.111]:57339
	"EHLO p3plsmtpa06-10.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751979AbbGHVpY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 17:45:24 -0400
Message-ID: <559D983D.6000804@talpey.com>
Date: Wed, 08 Jul 2015 17:38:05 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>
CC: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559A340E.9000000@dev.mellanox.co.il> <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com> <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il> <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com> <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com>
In-Reply-To: <20150708190842.GB11740@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/8/2015 3:08 PM, Jason Gunthorpe wrote:
> The MR stuff was never really designed, the HW people provided some
> capability and the SW side just raw exposed it, thoughtlessly.

Jason, I don't disagree that the API can be improved. I have some
responses to your statements below though.

> Why is code using iWarp calling ib_get_dma_mr with
> RDMA_MRR_READ_DEST/IB_ACCESS_REMOTE_WRITE ? That is insecure.

Because the iWARP protocol requires it, which was very much an
intentional decision. It actually is not insecure, as discussed
in detail in RFC5042. However, it is different from Infiniband.

> Why on earth is NFS using frmr to create RDMA READ lkeys?

Because NFS desires to have a single code path that works for all
transports. In addition, using the IB dma_mr as an lkey means that
large I/O (common with NFS) would require multiple RDMA Read
operations, when the page list exceeded the local scatter/gather
limit of the device.

> I think when you do that, it quickly becomes clear that iWarp's
> problem is not a seemingly minor issue with different flag bits, but
> that iWarp *cannot* use local_dma_lkey as a RDMA READ local buffer.
> Using ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) is an insecure work
> around. So iWarp (and only iWarp) should take the pain of spinning up
> temporary local MRs for RDMA READ.

That is entirely the wrong layer to address this. It would prevent
reuse of MRs, and require upper layers to be aware that this was
the case - which is exactly the opposite of what you are trying
to achieve.

> This should all be hidden under a common API and it shouldn't be
> sprinkled all over the place in NFS, iSER, etc.

Are you arguing that all upper layer storage protocols take a single
common approach to memory registration? That is a very different
discussion.

Tom.
