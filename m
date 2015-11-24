Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59485 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbbKXGw2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 01:52:28 -0500
Date: Mon, 23 Nov 2015 22:52:26 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Talpey <tom@talpey.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, Sagi Grimberg <sagig@mellanox.com>,
        santosh.shilimkar@oracle.com
Subject: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
Message-ID: <20151124065225.GB29141@infradead.org>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5653B606.3070700@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2015 at 07:57:42PM -0500, Tom Talpey wrote:
> On 11/23/2015 5:14 PM, Chuck Lever wrote:
> >FMR's ro_unmap method is already synchronous because ib_unmap_fmr()
> >is a synchronous verb. However, some improvements can be made here.
> 
> I thought FMR support was about to be removed in the core.

Seems like everyone would love to kill it, but no one dares to do
it just yet.  Reasons to keep FMRs:

 - mthca doesn't support FRs but haven't been staged out
 - RDS only supports FRMs for the IB transports (it does support FRs for
   an entirely separate iWarp transports.  I'd love to know why we can't
   just use that iWarp transport for IB as well).
 - mlx4 hardware might be slower with FRs than FRMs (Or mentioned this
   in reply to the iSER remote invalidation series).

So at lest for 4.5 we're unlikely to be able to get rid of it alone
due to the RDS issue.  We'll then need performance numbers for mlx4,
and figure out how much we care about mthca.
