Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-01.prod.phx3.secureserver.net ([68.178.252.102]:35405
	"EHLO p3plsmtpa11-01.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932072AbbGJN3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 09:29:42 -0400
Message-ID: <559FC710.1050307@talpey.com>
Date: Fri, 10 Jul 2015 09:22:24 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Doug Ledford <dledford@redhat.com>
CC: "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559B9891.8060907@dev.mellanox.co.il> <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com> <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com>
In-Reply-To: <20150709225306.GA30741@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 6:53 PM, Jason Gunthorpe wrote:
> On Thu, Jul 09, 2015 at 06:18:26PM -0400, Doug Ledford wrote:
>
>> A lot of this discussion is interesting and has gone off in an area that
>> I think is worth pursuing in the long run.  However, in the short run,
>> this patch was a minor cleanup/simplification patch.  These discussions
>> are moving into complete redesigns and rearchitecting.  Steve, I'm OK
>> with the cleanup and would prefer that it stay separate from these
>> larger issues.
>
> So, I was originally of the view the flags change was fine.
>
> But when I realized that it basically hides a
> ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) behind an opaque API:
>
>   rdma_get_dma_mr(RDMA_MRR_READ_DEST)
>
> I changed my mind.

Yes, I agree. Creating a writable privileged rmr for the RDMA Read sink
buffer exposes all of physical memory to a simple arithmetic mistake.
This should never be allowed in a production config.

That said, for the use by the NFS/RDMA Server, the risk is significantly
mitigated. The sink MR is never sent to the peer by the NFS upper layer,
it is protected by the connection's PD, and it is enabled only when the
RDMA Read is active. However, the very real risk remains. This should
definitely not be the standard API.

> For iWarp the above creates a rkey that can RDMA WRITE to any place in
> system memory. If a remote guesses that rkey your system is totally
> compromised. So it is insecure, and contrary to the advice in RFC5042.
>
> Seeing rdma_get_dma_mr(RDMA_MRR_READ_DEST) added all over the code
> base terrifies me, because it is utterly wrong, and looks harmless.
>
> The mistep, is that enabling iSER for iWarp is not just this trivial
> change:
>
> -	device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE);
> +	mr_roles = RDMA_MRR_RECV | RDMA_MRR_SEND | RDMA_MRR_WRITE_SOURCE |
> +		   RDMA_MRR_READ_DEST;
> +	device->mr = rdma_get_dma_mr(device->pd, mr_roles, 0);
>

Yep. It's the only safe, correct solution.


 > But, it must also follow the path of NFS and use FRMR on iWarp for
 > RDMA READ lkeys. This is the real quirk of iWarp, not that the MR
 > flags are slightly different.
 >
>  From there, it is a logical wish: If Steve is going to FRMR'ize iSER
> to be acceptable security wise, I'd rather see that work done on in a
> general way. Hence the API discussion.

Well, it's important to realize that NFS already does the Right Thing.
So it isn't actually an urgent issue. There is time to discuss.

Tom.
