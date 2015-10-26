Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43552 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbbJZDpl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Oct 2015 23:45:41 -0400
Date: Sun, 25 Oct 2015 20:45:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
Subject: Re: [PATCH v7 0/4] VFS: In-kernel copy system call
Message-ID: <20151026034540.GB9945@infradead.org>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20151024165237.GA6436@zzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151024165237.GA6436@zzz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 24, 2015 at 11:52:37AM -0500, Eric Biggers wrote:
> A few comments:
> 
> >       if (!(file_in->f_mode & FMODE_READ) ||
> >           !(file_out->f_mode & FMODE_WRITE) ||
> >           (file_out->f_flags & O_APPEND) ||
> >           !file_out->f_op)
> >               return -EBADF;
> 
> Isn't 'f_op' always non-NULL?

Yes, its is.

> If the destination file cannot be append-only, shouldn't this be documented?

Yes.

> >	if (inode_in->i_sb != inode_out->i_sb ||
> >		file_in->f_path.mnt != file_out->f_path.mnt)
> >		return -EXDEV;
> 
> Doesn't the same mount already imply the same superblock?

It does.

> > /*
> >  * copy_file_range() differs from regular file read and write in that it
> >  * specifically allows return partial success.  When it does so is up to
> >  * the copy_file_range method.
> >  */
> 
> What does this mean?  I thought that read() and write() can also return
> partial success.

The syscalls are allow to return short from the standards perspective,
but if you actually do that for regualr fiels hell will break loose as
applications don't expect it.  That's why we can't actually ever do it.

> Should FMODE_PREAD or FMODE_PWRITE access be checked if the user specifies their
> own 'off_in' or 'off_out', respectively?

Maybe.

> What is supposed to happen if the user passes provides a file descriptor to a
> non-regular file, such as a block device or char device?

If they implement the proper method I see no reason why we can't support
it.  For block device we only have one file_ops instance and mapping
that to the bio-level XCOPY abstraction that's been posted a couple of
times would seem sensible.  For character devices that's entirely up to
the driver.

> If the 'in' file has fewer than 'len' bytes remaining until EOF, what is the
> expected behavior?  It looks like the btrfs implementation has different
> behavior from the pagecache implementation.

Good question.  I'd say failure is the right way to handle a mismatching
length.

> It appears the btrfs implementation has alignment restrictions --- where is this
> documented and how will users know what alignment to use?

For actual clones we're limited to the file system block size (NFS adds
an extra attribute for the clone block size), but for regaulr copies we
probably should fall back to the dumb implementation if we don't match
it.

> Are copies within the same file permitted and can the ranges overlap?  The man
> page doesn't say.

For clones we defintively want to support it, but for copies I'd be
tempted to say no.  Does anyone else have an opinion?

> It looks like the initial patch defines __NR_copy_file_range for the ARM
> architecture but doesn't actually hook that system call up for ARM; why is that?

Looks like that should be dropped.  I really wish we had a way to just
wire up syscalls everywhere.
