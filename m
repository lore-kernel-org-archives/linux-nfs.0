Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752816Ab1GVBmH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 21:42:07 -0400
Subject: Re: [PATCH] RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>, tom@ogc.us,
        tmtalpey@gmail.com
Date: Thu, 21 Jul 2011 21:42:04 -0400
In-Reply-To: <20110721214106.GB3341@fieldses.org>
References: <1311270542-2021-1-git-send-email-steved@redhat.com>
	 <20110721214106.GB3341@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311298924.29521.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-07-21 at 17:41 -0400, J. Bruce Fields wrote: 
> On Thu, Jul 21, 2011 at 01:49:02PM -0400, Steve Dickson wrote:
> > Our performance team has noticed that increasing
> > RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
> > increases throughput when using the RDMA transport.
> 
> The main risk that I can see being that we have on the stack in two
> places:
> 
> 	rpcrdma_register_fmr_external(struct rpcrdma_mr_seg *seg, ...
> 	{
> 		...
> 		u64 physaddrs[RPCRDMA_MAX_DATA_SEGS];
> 
> 	rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg, ...
> 	{
> 		...
> 		struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS]; 
> 
> Where ip_phys_buf is 16 bytes.
> 
> So that's 512 bytes in the first case, 1024 in the second.  This is
> called from rpciod--what are our rules about allocating memory from
> rpciod?

Is that allocated on the stack? We should always try to avoid 1024-byte
allocations on the stack, since that eats up a full 1/8th (or 1/4 in the
case of 4k stacks) of the total stack space.

If, OTOH, that memory is being allocated dynamically, then the rule is
"don't let rpciod sleep".

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

