Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36378 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757229AbbLAWsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2015 17:48:33 -0500
MIME-Version: 1.0
In-Reply-To: <1448563859-21922-1-git-send-email-hch@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
From: Steve French <smfrench@gmail.com>
Date: Tue, 1 Dec 2015 16:48:12 -0600
Message-ID: <CAH2r5muW6=v6tx3BwXSYMgn7EZgzVANniebsxfwpdq9Y=0VcuA@mail.gmail.com>
Subject: Re: vfs: move btrfs clone ioctls to common code
To: Christoph Hellwig <hch@lst.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Peng Tao <tao.peng@primarydata.com>,
        Jeffrey Layton <jeff.layton@primarydata.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the new API is there a way to distinguish between the two copy
offload behaviors:

1) FSCTL_DUPLICATE_EXTENTS (where the server file system increments a
refcount on blocks in the range)
and
2) FSCTL_COPYCHUNK (where the server does a server side copy of the
requested range, but does not necessarily use reflink, although in the
case of Samba on btrfs it implements it this way).  In this case NTFS
will usually make a copy of the range requested rather than linking
the ranges.

For the former cifs uses (used prior to this patc) the btrfs ioctl,
for the latter it has a private ioctl (CIFS_IOC_COPYCHUNK_FILE).  For
the former the files have to be on the same share (export) for the
latter it just requires that the files be on the same server, and in
common cases (drag an drop in the file explorer on the desktop) the
source and target files would be on different mounts to the same
server.

There is an unimplemented (in cifs.ko) whole file clone operation
(copy-on-write file with a network API similar to the hardlink) but it
looks like it is no longer supported by newer servers, perhaps because
there is more interest in the ODX mechanism for duplicating files ala
https://msdn.microsoft.com/en-us/library/windows/desktop/hh848056(v=vs.85).aspx
across server farms for managing virtualization images.   I need to
add the ODX copy offload mechanism to cifs.ko but presumably it would
behave more like FSCTL_COPYCHUNK (ie not do a reflink of the blocks)

The performance improvements from server side copy offload is huge
whether or not reflink is done - so allowing the cp command (or common
user space commands ala robocopy which already does this in Windows)
to do fast copy is particularly important for network file systems.

On Thu, Nov 26, 2015 at 12:50 PM, Christoph Hellwig <hch@lst.de> wrote:
> This patch set moves the existing btrfs clone ioctls that other file
> system have started to implement to common code, and allows the NFS
> server to export this functionality to remote systems.
>
> This work is based originally on my NFS CLONE prototype, which reused
> code from Anna Schumaker's NFS COPY prototype, as well as various
> updates from Peng Tao to this code.
>
> The patches are also available as a git branch and on gitweb:
>
>         git://git.infradead.org/users/hch/pnfs.git clone-for-viro
>         http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone-for-viro
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks,

Steve
