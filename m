From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 6 Nov 2008 11:40:30 -0500
Message-ID: <8CE896CC-0366-46ED-AF5B-A12956CB4432@oracle.com>
References: <200811061034.06486.asid@hp.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Alex Sidorenko <asid@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47684 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbYKFQq7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2008 11:46:59 -0500
In-Reply-To: <200811061034.06486.asid@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Alex-

On Nov 6, 2008, at Nov 6, 2008, 10:34 AM, Alex Sidorenko wrote:

> Hello,
>
> I am an HP engineer participating in L3 Linux support. Recently we  
> have found
> that current design of nfs_getattr() might create huge delays in  
> stat() on
> the file we are writing to (this is important for big files only,  
> >2Gb).
>
> The problem
> -----------
>
> Assuming that /nfs is an NFS-mounted FS:
>
> 1. In one shell, start
> $ dd if=/dev/zero of=/nfs/dir/big bs=1G count=20
>
> 2. In another shell, start
>
> $ ls -l /nfs/dir
>
> or
>
> $ ls -l /nfs/dir/big
>
> 'ls' does not return until the whole /nfs/dir/big is written.
>
> Analysis
> --------
>
> Kernel 2.6.16 has introduced the following change in nfs_getattr():
>
>
>    NFS: Make stat() return updated mtimes after a write()
>
>    The SuS states that a call to write() will cause mtime to be  
> updated on
>    the file. In order to satisfy that requirement, we need to flush  
> out
>    any cached writes in nfs_getattr().
>    Speed things up slightly by not committing the writes.
>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>
> +	/* Flush out writes to the server in order to update c/mtime */
> +	nfs_sync_inode(inode, 0, 0, FLUSH_WAIT|FLUSH_NOCOMMIT);
>
> Then later:
>
> 2.6.16-rc6:
>
> http://www.linux-nfs.org/Linux-2.6.x/2.6.16-rc6/linux-2.6.16-99-fix_nfs_sync_inode_race.dif
>
> 	/* Flush out writes to the server in order to update c/mtime */
> -	nfs_sync_inode(inode, 0, 0, FLUSH_WAIT|FLUSH_NOCOMMIT);
> +	nfs_sync_inode_wait(inode, 0, 0, FLUSH_NOCOMMIT);
>
>
> I understand the reasoning behind that. From application point of  
> view, NFS
> file/directory should behave the same as on local FS. If we have  
> queued many
> writes, without this patch stat() will return incorrect results,  
> both for
> mtime and file length. Some applications may depend on stat()  
> results being
> correct.
>
> At the same time, the fact that we have to wait forever while  
> copying big
> files and doing 'ls -l' on that directory (or on the file being  
> written) is
> not very good either (two HP customers have complained about this  
> after
> migrating from RHEL4 to RHEL5).
>
> The problem is still there in 2.6.27. I am not sure what can be done  
> to both
> reduce the stat() delay and guarantee reasonable stat() results.

The goal is to meet the POSIX requirement that the mtime of the  
returned stat(2) results must reflect the mtime of the latest  
application write(2) request.  If the client is caching writes, then  
those must be flushed to the server first because only the server  
determines the file's mtime.

If the client limited its write cache to a few dozen megabytes, the  
delay during stat(2) would be nearly unnoticeable.


> It is interesting that with 'noac' stat() returns much faster (just  
> 1-3s
> delay).

That's because "noac" never caches writes on the client.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
