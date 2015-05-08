Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbbEHPPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 11:15:06 -0400
Date: Fri, 8 May 2015 11:14:59 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFS: report more appropriate block size for directories.
Message-ID: <20150508151459.GA63078@tonberry.usersys.redhat.com>
References: <20150508131040.140bf570@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150508131040.140bf570@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 May 2015, NeilBrown wrote:

> 
> In glibc 2.21 (and several previous), a call to opendir() will
> result in a 32K (BUFSIZ*4) buffer being allocated and passed to
> getdents.
> 
> However a call to fdopendir() results in an 'fstat' request to
> determine block size and a matching buffer allocated for subsequent
> use with getdents.  This will typically be 1M.
> 
> The first getdents call on an NFS directory will always use
> READDIR_PLUS (or NFSv4 equivalent) if available.  Subsequent getdents
> calls only use this more expensive version if some 'stat' requests are
> made between the getdents calls.
> 
> For this reason it is good to keep at least that first getdents call
> relatively short.  When fdopendir() and readdir() is used on a large
> directory, it takes approximately 32 times as long to complete as
> using "opendir".  Current versions of 'find' use fdopendir() and
> demonstrate this slowness.
> 
> 'stat' on a directory currently returns the 'wsize'.  This number has
> no meaning on directories.
> Actual READDIR requests are limited to ->dtsize, which itself is
> capped at 4 pages, coincidently the same as BUFSIZ*4.
> So this is a meaningful number to use as the blocksize on directories,
> and has the effect of making 'find' on large directories go a lot
> faster.

Would it make sense to do something similar for regular files too?
fopen() does a similar buffer allocation unless the application
overrides the buffer size via setbuffer()/setvbuf().  That can then
result in fseek() reading a lot of unnecessary data over the wire.

Prior to commit ba52de1 (inode-diet: Eliminate i_blksize from the inode
structure), a stat() over nfs would return the page size in st_blksize,
and for some workloads it does make a difference.  For instance, I have
a customer running gdb in an diskless environment.  On a stock kernel
where a stat() over nfs returns the wsize in st_blksize, their job takes
~19 minutes... on a test kernel where a stat() over nfs returns the page
size instead, that same job takes ~13 minutes.  I hadn't sent a patch
yet because I'm still trying to account for a few extra minutes of
run time elsewhere...

-Scott
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 96f2d55781fb..f8aebf59383f 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -678,6 +678,8 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
>  	if (!err) {
>  		generic_fillattr(inode, stat);
>  		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
> +		if (S_ISDIR(inode->i_mode))
> +			stat->blksize = NFS_SERVER(inode)->dtsize;
>  	}
>  out:
>  	trace_nfs_getattr_exit(inode, err);
