Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11781 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543Ab1CUVCD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2011 17:02:03 -0400
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110318145232.7bbb4216@notabene.brown>
References: <20110216171555.6642c630@notabene.brown>
	 <1300405987.4621.10.camel@lade.trondhjem.org>
	 <20110318120417.435551da@notabene.brown>
	 <1300412966.9671.9.camel@lade.trondhjem.org>
	 <20110318131214.0e2c840a@notabene.brown>
	 <1300415108.13476.6.camel@lade.trondhjem.org>
	 <20110318145232.7bbb4216@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Mar 2011 17:02:00 -0400
Message-ID: <1300741320.13307.50.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-03-18 at 14:52 +1100, NeilBrown wrote:
> On Thu, 17 Mar 2011 22:25:08 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> 
> > On Fri, 2011-03-18 at 13:12 +1100, NeilBrown wrote:
> > > On Thu, 17 Mar 2011 21:49:26 -0400 Trond Myklebust
> > > <Trond.Myklebust@netapp.com> wrote:
> > > 
> > > > However we could adopt the Solaris convention of always starting
> > > > writebacks with a FILE_SYNC, and then falling back to UNSTABLE for the
> > > > second rpc call and all subsequent calls...
> > > > 
> > > 
> > > That approach certainly has merit.
> > > 
> > > However, as we know from the wbc info whether the write is small and sync -
> > > which is the only case where I think a STABLE write is needed - I cannot see
> > > why you don't want to just use that information to guide the choice of
> > > 'stable' or not ???
> > 
> > By far the most common case we would want to optimise for is the sync at
> > close() or fsync() when you have written a small file (<= wsize). If we
> > can't optimise for that case, then the optimisation isn't worth doing at
> > all.
> 
> Fair point.  I hadn't thought of that.
> 
> > 
> > The point is that in that particular case, the wbc doesn't help you at
> > all since the limits are set at 0 and LLONG_MAX (see nfs_wb_all(),
> > write_inode_now(),...)
> > 
> 
> I would be trivial to use min(wbc->range_end, i_size_read(inode)) as the
> upper bound when assessing the size of the range to compare with 'wsize'.
> 
> However that wouldn't address the case of a small append to a large file
> which would also be good to optimise.
> 
> If you can detect the 'first' RPC reliably at the same time that you still
> have access to the wbc information, then:
> 
>  if this is the first request in a writeback, and the difference beween
>   the address of this page, and min(wbc->range_end, i_size_read(inode))
>   is less than wsize, then make it a STABLE write
> 
> might be a heuristic that catches most interesting cases.
> It might be a bit complex though.
> 
> I think we should in general err on the size of not using a STABLE write
> when it might be useful rather than using a STABLE write when it is not
> necessary as, while there a costs each way, I think the cost of incorrectly
> using STABLE would be higher.

How about something like the following (as of yet untested) patch?

Cheers
  Trond

8<-------------------------------------------------------------------------------
