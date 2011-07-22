Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39423 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab1GVBzH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 21:55:07 -0400
Date: Thu, 21 Jul 2011 21:55:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>, tom@ogc.us,
        tmtalpey@gmail.com
Subject: Re: [PATCH] RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
Message-ID: <20110722015503.GA4749@fieldses.org>
References: <1311270542-2021-1-git-send-email-steved@redhat.com>
 <20110721214106.GB3341@fieldses.org>
 <1311298924.29521.2.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311298924.29521.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 21, 2011 at 09:42:04PM -0400, Trond Myklebust wrote:
> On Thu, 2011-07-21 at 17:41 -0400, J. Bruce Fields wrote: 
> > On Thu, Jul 21, 2011 at 01:49:02PM -0400, Steve Dickson wrote:
> > > Our performance team has noticed that increasing
> > > RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
> > > increases throughput when using the RDMA transport.
> > 
> > The main risk that I can see being that we have on the stack in two
> > places:
> > 
> > 	rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg, ...
> > 	{
> > 		...
> > 		u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
> > 
> > 	rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg, ...
> > 	{
> > 		...
> > 		struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS]; 
> > 
> > Where ip_phys_buf is 16 bytes.
> > 
> > So that's 512 bytes in the first case, 1024 in the second.  This is
> > called from rpciod--what are our rules about allocating memory from
> > rpciod?
> 
> Is that allocated on the stack? We should always try to avoid 1024-byte
> allocations on the stack, since that eats up a full 1/8th (or 1/4 in the
> case of 4k stacks) of the total stack space.

Right, it's on the stack, so I was wondering what we should do
instead....

> If, OTOH, that memory is being allocated dynamically, then the rule is
> "don't let rpciod sleep".

OK, so, looking around, the buf_alloc methods might provide examples to
follow for dynamic allocation here?

--b.
