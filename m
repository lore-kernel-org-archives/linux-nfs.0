From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [NFS] [PATCH] mmap corruption
Date: Sat, 5 Apr 2003 11:47:41 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030405164741.GA6450@RedHat.com>
References: <3E8DDB13.9020009@RedHat.com> <shsistt7wip.fsf@charged.uio.no>
Reply-To: SteveD@RedHat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsistt7wip.fsf@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

Hi Trond,

On Sat, Apr 05, 2003 at 12:01:02AM +0200, Trond Myklebust wrote:
> >>>>> " " == Steve Dickson <SteveD@redhat.com> writes:
> 
> That simply doesn't ring true. The nfs_wb_all() immediately after the
> call to filemap_fdatasync() should ensure that *all* scheduled writes
> will flushed out.
> 
Here is my evidence your honor... :-)

1)  Through my debugging I was able to show when (and only when)
the following if statement is true, there would be corruption:

nfs_notify_change(struct dentry *dentry, struct iattr *attr)
{
	/*
	 * beginning code skipped
	 */

	filemap_fdatasync(inode->i_mapping);
	error = nfs_wb_all(inode);
	filemap_fdatawait(inode->i_mapping);
	if (error)
		goto out;

	/*
	 * Every time either npages or ncommit had a value and the file size is
	 * immediately changed (with in a microsecond or two) by another 
	 * truncation, followed by a mmap read, the file would be corrupted.
	 */
	if (NFS_I(inode)->npages || NFS_I(inode)->ncommit || NFS_I(inode)->ndirty) {
		printk("nfs_notify_change: fid %Ld npages %d ncommit %d ndirty %d\n",
		NFS_FILEID(inode), NFS_I(inode)->npages, 
		NFS_I(inode)->ncommit, NFS_I(inode)->ndirty);
	}
}

I was also able to log the fact that the page was being written out (and committed)
by kupdated was after second truncation finished. At first, I was thinking 
there was a problem with the nfs_fattr_obsolete() code (and still might be) 
since this late write/commit is *truly* obsolete. But I just could not figure 
out how to detect this event so I went with avoidance approach. Now, if the 
server supplied the client with valid pre and post attrs, I believe this condition 
could be detected. But I didn't have a server that did that so I could 
not test out my theroy...

2) Without this patch my script that startups 300 process fails within
minutes. With this patch the script runs to completion constistanly...

I rest my case... and the verdict is?

SteveD.
