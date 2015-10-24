Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34882 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbbJXQwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 12:52:40 -0400
Date: Sat, 24 Oct 2015 11:52:37 -0500
From: Eric Biggers <ebiggers3@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v7 0/4] VFS: In-kernel copy system call
Message-ID: <20151024165237.GA6436@zzz>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A few comments:

>       if (!(file_in->f_mode & FMODE_READ) ||
>           !(file_out->f_mode & FMODE_WRITE) ||
>           (file_out->f_flags & O_APPEND) ||
>           !file_out->f_op)
>               return -EBADF;

Isn't 'f_op' always non-NULL?

If the destination file cannot be append-only, shouldn't this be documented?

>	if (inode_in->i_sb != inode_out->i_sb ||
>		file_in->f_path.mnt != file_out->f_path.mnt)
>		return -EXDEV;

Doesn't the same mount already imply the same superblock?

> /*
>  * copy_file_range() differs from regular file read and write in that it
>  * specifically allows return partial success.  When it does so is up to
>  * the copy_file_range method.
>  */

What does this mean?  I thought that read() and write() can also return partial
success.

>       f_out = fdget(fd_out);
>       if (!f_in.file || !f_out.file) {
>               ret = -EBADF;
>               goto out;
>	}

This looked wrong at first because it may call fdput() on a 'struct fd' that was
not successfully acquired, but it looks like it works currently because of how
the FDPUT_FPUT flag is used.  It may be a good idea to write it the "obvious"
way, though (use separate labels depending on which fdput()s need to happen).


Other questions:

Should FMODE_PREAD or FMODE_PWRITE access be checked if the user specifies their
own 'off_in' or 'off_out', respectively?

What is supposed to happen if the user passes provides a file descriptor to a
non-regular file, such as a block device or char device?

If the 'in' file has fewer than 'len' bytes remaining until EOF, what is the
expected behavior?  It looks like the btrfs implementation has different
behavior from the pagecache implementation.

It appears the btrfs implementation has alignment restrictions --- where is this
documented and how will users know what alignment to use?

Are copies within the same file permitted and can the ranges overlap?  The man
page doesn't say.

It looks like the initial patch defines __NR_copy_file_range for the ARM
architecture but doesn't actually hook that system call up for ARM; why is that?
