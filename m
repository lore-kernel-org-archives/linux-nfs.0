Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f193.google.com ([209.85.215.193]:39792 "EHLO
        mail-pg1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726663AbeJTJqA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Oct 2018 05:46:00 -0400
MIME-Version: 1.0
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com> <CAOQ4uxjN8-SsGN6M0fL-NM1X5EmxXPD7UEYjimiAOh95WoT5oA@mail.gmail.com>
 <CAN-5tyEbLSHxj=9xdba1CTai9Vu7hyrf9-EpW0gKQqJ1Z1m-3Q@mail.gmail.com>
In-Reply-To: <CAN-5tyEbLSHxj=9xdba1CTai9Vu7hyrf9-EpW0gKQqJ1Z1m-3Q@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Fri, 19 Oct 2018 20:37:09 -0500
Message-ID: <CAH2r5mtPtT1NNqT9sm0T2jDf1AMi8Rg4-6R2YsGwa1Zg+yqQwQ@mail.gmail.com>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
To: olga.kornievskaia@gmail.com
Cc: Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, fweimer@redhat.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 19, 2018 at 11:24 AM Olga Kornievskaia
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
<snip>
> > Maybe you can add the flag now for internal use  - only nfsv4 will pass that
> > flag to the vfs helper and system call will verify that flags == 0.
>
> Not only NFS wants it CIFS want it too.

Allowing copy offload across distinct smb3 mounts would be very
helpful for cifs.ko

Yes - note that many servers that cifs.ko (SMB3) has to deal with have
already broadly implemented copy offload (multiple flavors, not just the
'copy chunk' style) and 100s of millions of these systems
(not just Windows and Samba) support them as long as the
source and target of the copy are to the same server.  It is the client side
and lack of tools and to some extent cross-mount copies that is holding it
back from being more widely used.  One reason I have only implemented
two of the copy offload mechanisms for SMB3 ('duplicate extents'
and 'copy chunk') and not the third, the popular 'odx' (T10 style)
copy offload is in
part that the value of the 'odx' style is more when the source and target
are different servers.  Note that this is broadly implemented on servers
even on other Unix (see e.g. Nexenta's description of server impmlementation
of 'odx' style https://www.slideshare.net/gordonross/smb3-offload-data-transfer-odx)
so the client API enhancements would be quickly useful for cifs.ko (SMB3 mounts)
use case.


--
Thanks,

Steve
