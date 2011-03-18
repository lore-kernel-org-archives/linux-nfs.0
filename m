Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5681 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755764Ab1CRCZJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 22:25:09 -0400
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110318131214.0e2c840a@notabene.brown>
References: <20110216171555.6642c630@notabene.brown>
	 <1300405987.4621.10.camel@lade.trondhjem.org>
	 <20110318120417.435551da@notabene.brown>
	 <1300412966.9671.9.camel@lade.trondhjem.org>
	 <20110318131214.0e2c840a@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 22:25:08 -0400
Message-ID: <1300415108.13476.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-03-18 at 13:12 +1100, NeilBrown wrote:
> On Thu, 17 Mar 2011 21:49:26 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> 
> > However we could adopt the Solaris convention of always starting
> > writebacks with a FILE_SYNC, and then falling back to UNSTABLE for the
> > second rpc call and all subsequent calls...
> > 
> 
> That approach certainly has merit.
> 
> However, as we know from the wbc info whether the write is small and sync -
> which is the only case where I think a STABLE write is needed - I cannot see
> why you don't want to just use that information to guide the choice of
> 'stable' or not ???

By far the most common case we would want to optimise for is the sync at
close() or fsync() when you have written a small file (<= wsize). If we
can't optimise for that case, then the optimisation isn't worth doing at
all.

The point is that in that particular case, the wbc doesn't help you at
all since the limits are set at 0 and LLONG_MAX (see nfs_wb_all(),
write_inode_now(),...)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

