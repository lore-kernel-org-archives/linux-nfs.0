From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Use GFP_NOFS in nfs_direct_req_alloc
Date: Tue, 08 Sep 2009 21:37:13 -0400
Message-ID: <1252460233.5092.12.camel@heimdal.trondhjem.org>
References: <20090908220230.7590.69833.stgit@matisse.1015granger.net>
	 <1252449178.8099.64.camel@heimdal.trondhjem.org>
	 <931F30AB-DC64-4A02-A96C-FABF0DD4059A@oracle.com>
	 <1252451130.8099.81.camel@heimdal.trondhjem.org>
	 <91BC2823-945F-4E23-A3E1-3CE1456C05DC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5079 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339AbZIIBiI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 21:38:08 -0400
In-Reply-To: <91BC2823-945F-4E23-A3E1-3CE1456C05DC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-08 at 21:01 -0400, Chuck Lever wrote:
> On Sep 8, 2009, at 7:05 PM, Trond Myklebust wrote:
> > On Tue, 2009-09-08 at 18:43 -0400, Chuck Lever wrote:
> >> On Sep 8, 2009, at 6:32 PM, Trond Myklebust wrote:
> >>> On Tue, 2009-09-08 at 18:05 -0400, Chuck Lever wrote:
> >>>> Don't dive into memory reclaim in the NFS direct I/O paths,  
> >>>> otherwise
> >>>> we can deadlock.
> >>>>
> >>>> Reported by: Wengang Wang <wen.gang.wang@oracle.com>
> >>>> Fix-suggested-by: Zach Brown <zach.brown@oracle.com>
> >>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>>
> >>> Wait... What??? How does an O_DIRECT read or write allocation  
> >>> deadlock
> >>> with memory reclaim? Both the read and the write path call
> >>> nfs_direct_req_alloc() before they pin any user pages in memory.
> >>
> >> This may be an issue only for loopback mounts where the backing  
> >> device
> >> is an NFS O_DIRECT file.  This type of deadlock may not be able to
> >> happen in upstream kernels at this point.
> >
> > I don't see how that makes any difference whatsoever. If the backing
> > device is a non-O_DIRECT file, then you have GFP_KERNEL allocation of
> > the pages.
> >
> > Anything that calls down into a filesystem on a read() or write() path
> > had better not assume that it won't block.
> 
> Basically we're treating an O_DIRECT file just like a block device.   
> If the block I/O path blocks when a kernel file system calls in to do  
> a memory reclaim, we're in dutch.

Without a lot more changelog context that explains what you are wanting
to do, why it is relevant to NFS (and O_DIRECT in particular), and why
you can't work around it in other ways (PF_MEMALLOC comes to mind), I'm
not at all interested in applying this patch.

> >> Even so, it makes sense for this allocation to be consistent with
> >> similar allocations in the other NFS I/O paths.
> >
> > I don't buy the 'symmetry' argument. The reason for the GFP_NOFS in  
> > the
> > nfs_writedata_alloc() is that you have a deadlock when the VM calls
> > ->writepages() in order to reclaim memory.
> > That is not the case here, and so this is not a symmetrical case.
> 
> That is precisely the case here, in fact.  The upper file system is  
> attempting to reclaim memory in the same kernel where the NFS client  
> is trying to allocate with GFP_KERNEL.

That's the "upper file system"'s problem, not ours... Stacking
filesystems causes issues. Screwing over the existing users of the
underlying filesystem is not a fix for those issues...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
