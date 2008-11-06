From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 06 Nov 2008 13:49:56 -0500
Message-ID: <1225997396.387.30.camel@heimdal.trondhjem.org>
References: <200811061034.06486.asid@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Alex Sidorenko <asid@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35487 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbYKFSuB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2008 13:50:01 -0500
In-Reply-To: <200811061034.06486.asid@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-11-06 at 10:34 -0500, Alex Sidorenko wrote:
> I understand the reasoning behind that. From application point of view, NFS 
> file/directory should behave the same as on local FS. If we have queued many 
> writes, without this patch stat() will return incorrect results, both for 
> mtime and file length. Some applications may depend on stat() results being 
> correct.
> 
> At the same time, the fact that we have to wait forever while copying big 
> files and doing 'ls -l' on that directory (or on the file being written) is 
> not very good either (two HP customers have complained about this after 
> migrating from RHEL4 to RHEL5).

In order to relax that requirement, we'd have to introduce some
mechanism for the application to notify the filesystem that they don't
care about strictly correct c/mtimes. As you noted above, returning
incorrect mtimes may trip up some applications (backup applications, and
mail readers are a couple of business critical cases that come to mind).

> The problem is still there in 2.6.27. I am not sure what can be done to both 
> reduce the stat() delay and guarantee reasonable stat() results. 
> 
> It is interesting that with 'noac' stat() returns much faster (just 1-3s 
> delay).

That would be because 'noac' enforces synchronous writes. If you don't
care about the degraded write performance, you can do the same thing
without all the extra getattr clutter that noac introduces, by simply
mounting with -osync.

Cheers
  Trond

