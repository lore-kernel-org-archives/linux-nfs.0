Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vs1-f65.google.com ([209.85.217.65]:39074 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727549AbeJTBMJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 21:12:09 -0400
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <CAOQ4uxjN8-SsGN6M0fL-NM1X5EmxXPD7UEYjimiAOh95WoT5oA@mail.gmail.com>
 <CAN-5tyEbLSHxj=9xdba1CTai9Vu7hyrf9-EpW0gKQqJ1Z1m-3Q@mail.gmail.com>
In-Reply-To: <CAN-5tyEbLSHxj=9xdba1CTai9Vu7hyrf9-EpW0gKQqJ1Z1m-3Q@mail.gmail.com>
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date: Fri, 19 Oct 2018 13:04:59 -0400
Message-ID: <CAN-5tyEN9PNjP0ErPiDFjFnN8hLYe=U4DJTjhWC-47uE7JTbHg@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To: Amir Goldstein <amir73il@gmail.com>
Cc: linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 12:24 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> On Fri, Oct 19, 2018 at 11:55 AM Amir Goldstein <amir73il@gmail.com> wrote:
> >
> > On Fri, Oct 19, 2018 at 6:30 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > Allow copy_file_range to copy between different superblocks but only
> > > of the same file system types. This feature was of interest to CIFS
> > > as well as NFS.
> > >
> > > This feature is needed by NFSv4.2 to perform file copy operation on
> > > the same server or file copy between different NFSv4.2 servers.
> > >
> > > If a file system's fileoperations copy_file_range operation prohibits
> > > cross-device copies, fall back to do_splice_direct. This would be
> > > needed for the NFS (destination) server side implementation of the
> > > file copy and currently for CIFS.
> > >
> > > Besides NFS, there is only 1 implementor of the copy_file_range FS
> > > operation -- CIFS. CIFS assumes incoming file descriptors are both
> > > CIFS but it will check if they are coming from different servers and
> > > return error code to fall back to do_splice_direct.
> > >
> > > NFS will allow for copies between different NFS servers.
> > >
> > > Adding to the vfs.txt documentation to explicitly warn about allowing
> > > for different superblocks of the same file type to be passed into the
> > > copy_file_range for the future users of copy_file_range method.
> > >
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  Documentation/filesystems/vfs.txt |  4 +++-
> > >  fs/read_write.c                   | 13 ++++++-------
> > >  2 files changed, 9 insertions(+), 8 deletions(-)
> > >
> > > diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> > > index a6c6a8a..5e520de 100644
> > > --- a/Documentation/filesystems/vfs.txt
> > > +++ b/Documentation/filesystems/vfs.txt
> > > @@ -958,7 +958,9 @@ otherwise noted.
> > >
> > >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> > >
> > > -  copy_file_range: called by the copy_file_range(2) system call.
> > > +  copy_file_range: called by copy_file_range(2) system call. This method
> > > +                  works on two file descriptors that might reside on
> > > +                  different superblocks of the same type of file system.
> > >
> > >    clone_file_range: called by the ioctl(2) system call for FICLONERANGE and
> > >         FICLONE commands.
> > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > index c60790f..474e740 100644
> > > --- a/fs/read_write.c
> > > +++ b/fs/read_write.c
> > > @@ -1578,10 +1578,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > >             (file_out->f_flags & O_APPEND))
> > >                 return -EBADF;
> > >
> > > -       /* this could be relaxed once a method supports cross-fs copies */
> > > -       if (inode_in->i_sb != inode_out->i_sb)
> > > -               return -EXDEV;
> > > -
> >
> > You need to hoist this limitation to  clone_file_range() syscall, because
> > you are not allowed to change user facing behavior.
> > Maybe you can later add a uapi flag for copy_file_range() to explicitly allow
> > for cross-sb copy?
>
> Sure I can do that.
>
> > Maybe you can add the flag now for internal use  - only nfsv4 will pass that
> > flag to the vfs helper and system call will verify that flags == 0.
>
> Not only NFS wants it CIFS want it too.

Can you please elaborate on what do you mean "internal use only"?
nfsv4 doesn't call copy_file_range(), a user land application (such as
glibc cp, or whatever does a system call for the copy_file_range()) is
the one calling and doing a copy between two different server (ie
superblocks). Thus the system call can't keep the check "flags == 0".

I can (maybe?) add user level flags that copy_file_range() system call
will pass, I will have to remove the "flags == 0" check and then I can
add a check if such a flag is passed, then skip the check for the
cross device check in copy_file_range().

Is this what's desired?
>
> >
> > Thanks,
> > Amir.
