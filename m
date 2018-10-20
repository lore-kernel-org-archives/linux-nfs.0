Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb1-f195.google.com ([209.85.219.195]:45742 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727278AbeJTREP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Oct 2018 13:04:15 -0400
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <20181020040530.GG32577@ZenIV.linux.org.uk>
In-Reply-To: <20181020040530.GG32577@ZenIV.linux.org.uk>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sat, 20 Oct 2018 11:54:21 +0300
Message-ID: <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 20, 2018 at 7:06 AM Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > Allow copy_file_range to copy between different superblocks but only
> > of the same file system types. This feature was of interest to CIFS
> > as well as NFS.
>
> > +     if (file_out->f_op->copy_file_range &&
> > +                     (file_in->f_op->copy_file_range ==
> > +                             file_out->f_op->copy_file_range)) {
>
> That is seriously asking for trouble.  If at some point we add
> a library function usable as ->copy_file_range() instance, this
> will turn into a hard-to-spot problem.
>
> Comparing methods like that is best avoided.  If you want to compare
> fs types, do just that - it's not hard.

Another thing is the commit message claims to:
"Allow copy_file_range to copy between different superblocks but only
of the same file system types"

But what the patch actually does is:
"Allow copy_file_range() syscall to copy between different filesystems
AND allow calling the filesystems' copy_file_range() method
between different superblocks but only of the same file system types"

It's probably OK and quite useful to do the former, but maybe man page
should be fixed to explicitly mention that the copy is expected to work
across filesystems since kernel version XXX (?)

If you don't wish to change cross filesystem type behavior and only
relax cross super block limitation, then you should replace the
same inode->i_sb check above with same inode->i_sb->s_type
check instead of doing the check only for calling the filesystem
copy_file_range() method.

>
> Another potential issue here is the interplay with local filesystems
> using vfs_clone_file_prep_inodes() (or Darrick's series lifting that
> into generic code).  There we assume the same block size on both
> sides; that is automatically true if they live on the same superblock,
> but with your changes it's no longer true.

Heh? I don't see that Darrick's work has anything to do with
copy_file_range(). It only touched vfs_copy_file_range() for
the ->clone_file_range() call, which Olga's patch protects with same sb
check.

Thanks,
Amir.
