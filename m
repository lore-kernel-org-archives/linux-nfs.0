From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Use GFP_NOFS in nfs_direct_req_alloc
Date: Tue, 08 Sep 2009 19:05:30 -0400
Message-ID: <1252451130.8099.81.camel@heimdal.trondhjem.org>
References: <20090908220230.7590.69833.stgit@matisse.1015granger.net>
	 <1252449178.8099.64.camel@heimdal.trondhjem.org>
	 <931F30AB-DC64-4A02-A96C-FABF0DD4059A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42356 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752625AbZIHXIE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 19:08:04 -0400
In-Reply-To: <931F30AB-DC64-4A02-A96C-FABF0DD4059A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-08 at 18:43 -0400, Chuck Lever wrote:
> On Sep 8, 2009, at 6:32 PM, Trond Myklebust wrote:
> > On Tue, 2009-09-08 at 18:05 -0400, Chuck Lever wrote:
> >> Don't dive into memory reclaim in the NFS direct I/O paths, otherwise
> >> we can deadlock.
> >>
> >> Reported by: Wengang Wang <wen.gang.wang@oracle.com>
> >> Fix-suggested-by: Zach Brown <zach.brown@oracle.com>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >
> > Wait... What??? How does an O_DIRECT read or write allocation deadlock
> > with memory reclaim? Both the read and the write path call
> > nfs_direct_req_alloc() before they pin any user pages in memory.
> 
> This may be an issue only for loopback mounts where the backing device  
> is an NFS O_DIRECT file.  This type of deadlock may not be able to  
> happen in upstream kernels at this point.

I don't see how that makes any difference whatsoever. If the backing
device is a non-O_DIRECT file, then you have GFP_KERNEL allocation of
the pages.

Anything that calls down into a filesystem on a read() or write() path
had better not assume that it won't block.

> Even so, it makes sense for this allocation to be consistent with  
> similar allocations in the other NFS I/O paths.

I don't buy the 'symmetry' argument. The reason for the GFP_NOFS in the
nfs_writedata_alloc() is that you have a deadlock when the VM calls
->writepages() in order to reclaim memory.
That is not the case here, and so this is not a symmetrical case.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
