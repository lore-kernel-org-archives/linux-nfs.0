From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [NFS] [PATCH] mmap corruption
Date: Mon, 7 Apr 2003 10:00:52 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030407140052.GA1471@RedHat.com>
References: <3E8DDB13.9020009@RedHat.com> <shsistt7wip.fsf@charged.uio.no> <20030405164741.GA6450@RedHat.com> <16016.7633.982870.860147@charged.uio.no>
Reply-To: SteveD@RedHat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <16016.7633.982870.860147@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

On Sun, Apr 06, 2003 at 02:30:09PM +0200, Trond Myklebust wrote:
> >>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:
>      > /*
>      > * Every time either npages or ncommit had a value and the file
>      > size is
>      > * immediately changed (with in a microsecond or two) by another
>      > * truncation, followed by a mmap read, the file would be
>      > 	   corrupted.
>      > 	 */
>      > 	if (NFS_I(inode)->npages || NFS_I(inode)->ncommit ||
>      > 	NFS_I(inode)->ndirty) {
>      > 		printk("nfs_notify_change: fid %Ld npages %d ncommit
>      > 		%d ndirty %d\n", NFS_FILEID(inode),
>      > 		NFS_I(inode)->npages, ncommit, NFS_I(inode)->ndirty);
>      > 	}
>      > }
> 
> My point is that nfs_wb_all() is supposed to ensure that
> NFS_I(inode)->ncommit, and/or NFS_I(inode)->ndirty are both
> zero. i.e. you can have pending reads (in which case
> NFS_I(inode)->npages != 0), but *no* pending writes.
> 
> Was this the case?

OK, I understand your point.  And Yes, ndirty and ncommit 
always seem to be zero when nfs_wb_all() returns. Only
when npages != 0 is when I get the corruption.

I didn't realize that npages != 0 meant there are only pending 
reads *not* pending writes... Thanks for that clarification....

SteveD.
