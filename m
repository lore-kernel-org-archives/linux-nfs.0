Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35755 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751384AbdEEOfK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 May 2017 10:35:10 -0400
Received: by mail-lf0-f43.google.com with SMTP id j1so4579384lfh.2
        for <linux-nfs@vger.kernel.org>; Fri, 05 May 2017 07:35:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Fri, 5 May 2017 16:35:07 +0200
Message-ID: <CAOssrKdHn5SpxEXBZ5EQvCF9E8JTiMqJo+M3OKPXUHYXGeqMGg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 3, 2017 at 6:04 PM, David Howells <dhowells@redhat.com> wrote:
>
> Here are a set of patches to create a mount context prior to setting up a
> new mount, populating it with the parsed options/binary data and then
> effecting the mount.

Great work, thanks for taking this on.

I'd argue with some design decisions here.  One of the motivations for
doing the mount API overhaul is to create clear distinction between
separate functions like:

 - creating filesystem instance (aka superblock)

 - attaching filesystem instance into mount tree

 - reconfiguring superblock

 - changing mount properties


This patchset achieves this partly, but the separation is far from
crisp clear...  First of all why is fsopen() creating a "mount
context"?  It's suppsed to create a "superblock creation context".
And indeed, there are mount flags and root path in there, which are
definitely not necessary for creating a super block.

Is there a good reason why these mount specific properties leaked into
the object created by fsopen()?

Also I'd expect all context ops to be fully generic first.  I.e. no
filesystem code needs to be touched to make the new interface work.
The context would just build the option string and when everything is
ready (probably need a "commit" command) then it would go off and call
mount_fs() to create the superblock and attach it to the context.

Then, when that works, we could add context ops, so the filesystem can
do various things along the way, which is the other reason we want
this.  And in the end it would allow gradual migration to a new
superblock creation api and phasing out the old one.   But that
shouldn't be observable on either the old or the new userspace
interfaces.


> This allows namespaces and other information to be conveyed through the
> mount procedure.  It also allows extra error information to be returned
> (so many things can go wrong during a mount that a small integer isn't
> really sufficient to convey the issue).
>
> This also allows Miklós Szeredi's idea of doing:
>
>         fd = fsopen("nfs");
>         write(fd, "option=val", ...);
>         fsmount(fd, "/mnt");
>
> that he presented at LSF-2017 to be implemented (see the relevant patches
> in the series), to which I can add:
>
>         read(fd, error_buffer, ...);
>
> to read back any error message.  I didn't use netlink as that would make it
> depend on CONFIG_NET and would introduce network namespacing issues.
>
> I've implemented mount context handling for procfs and nfs.
>
> Further developments:
>
>  (*) Implement mount context support in more filesystems, ext4 being next
>      on my list.
>
>  (*) Move the walk-from-root stuff that nfs has to generic code so that you
>      can do something akin to:
>
>         mount /dev/sda1:/foo/bar /mnt
>
>      See nfs_follow_remote_path() and mount_subtree().  This is slightly
>      tricky in NFS as we have to prevent referral loops.

First we can limit this feature to non-weird (ie. no managed dentries) subtrees.

>
>  (*) Move the pid_ns pointer from struct mount_context to struct
>      proc_mount_context as I'm not sure it's necessary for anything other
>      than procfs.
>
>  (*) Work out how to get at the error message incurred by submounts
>      encountered during nfs_follow_remote_path().
>
>      Should the error message be moved to task_struct and made more
>      general, perhaps retrieved with a prctl() function?
>
>  (*) Clean up/consolidate the security functions.  Possibly add a
>      validation hook to be called at the same time as the mount context
>      validate op.
>
> The patches can be found here also:
>
>         http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=mount-context

Will try to review the actual patches next week.

Thanks,
Miklos
