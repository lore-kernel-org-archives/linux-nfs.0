From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "sync" mount option semantics
Date: Wed, 05 Mar 2008 13:13:08 -0500
Message-ID: <1204740788.3356.9.camel@heimdal.trondhjem.org>
References: <9DC7FC7A-41B0-43C6-9759-8DF253C47EEE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:40933 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbYCES3q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 13:29:46 -0500
In-Reply-To: <9DC7FC7A-41B0-43C6-9759-8DF253C47EEE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-03-04 at 18:15 -0500, Chuck Lever wrote:
> Hi Trond-
> 
> I have kind of an academic question.
> 
> When an NFS file system is mounted with the "sync" option, only  
> writes via sys_write appear to be affected.  Writes via mmap or pages  
> dirtied via a loopback device are not affected at all.
> 
> Similarly, O_SYNC only appears to affect sys_write and not mmap or  
> loopback.
> 
> Is this the desired behavior?  If so, why not include cached writes?   
> Should we document this in nfs(5)?

What does it mean to have "synchronous writes with mmap"? I'm not sure
that I really understand your concern: mmap is by its very nature
asynchronous. AFAIK, the only guarantee you have w.r.t. synchronicity is
that msync(MS_SYNC) can only complete once the data is on disk.

So what semantics or guarantees are you saying that we're violating when
we don't use synchronous writes at the NFS level for mmap?

Ditto really for the loopback device. Its semantics are those of a block
device, and so I really don't see what guarantees we're violating by not
using synchronous writes at the NFS level.



