Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:39362 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbbGIWxW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2015 18:53:22 -0400
Date: Thu, 9 Jul 2015 16:53:06 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Doug Ledford <dledford@redhat.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150709225306.GA30741@obsidianresearch.com>
References: <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
 <20150709000337.GE16812@obsidianresearch.com>
 <559EF332.7060103@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559EF332.7060103@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2015 at 06:18:26PM -0400, Doug Ledford wrote:

> A lot of this discussion is interesting and has gone off in an area that
> I think is worth pursuing in the long run.  However, in the short run,
> this patch was a minor cleanup/simplification patch.  These discussions
> are moving into complete redesigns and rearchitecting.  Steve, I'm OK
> with the cleanup and would prefer that it stay separate from these
> larger issues.

So, I was originally of the view the flags change was fine.

But when I realized that it basically hides a
ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) behind an opaque API:

 rdma_get_dma_mr(RDMA_MRR_READ_DEST)

I changed my mind.

For iWarp the above creates a rkey that can RDMA WRITE to any place in
system memory. If a remote guesses that rkey your system is totally
compromised. So it is insecure, and contrary to the advice in RFC5042.

Seeing rdma_get_dma_mr(RDMA_MRR_READ_DEST) added all over the code
base terrifies me, because it is utterly wrong, and looks harmless.

The mistep, is that enabling iSER for iWarp is not just this trivial
change:

-	device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE);
+	mr_roles = RDMA_MRR_RECV | RDMA_MRR_SEND | RDMA_MRR_WRITE_SOURCE |
+		   RDMA_MRR_READ_DEST;
+	device->mr = rdma_get_dma_mr(device->pd, mr_roles, 0);

But, it must also follow the path of NFS and use FRMR on iWarp for
RDMA READ lkeys. This is the real quirk of iWarp, not that the MR
flags are slightly different.
