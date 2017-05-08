Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33950 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdEHRDo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 May 2017 13:03:44 -0400
MIME-Version: 1.0
In-Reply-To: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
From: Djalal Harouni <tixxdz@gmail.com>
Date: Mon, 8 May 2017 19:03:43 +0200
Message-ID: <CAEiveUdYsVPuhEOjDJYtTN2JaPrEacE7ZeCUp3RhOkugK-ZtHg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
To: David Howells <dhowells@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Miklos Szeredi <mszeredi@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 3, 2017 at 6:04 PM, David Howells <dhowells@redhat.com> wrote:
>
> Here are a set of patches to create a mount context prior to setting up a
> new mount, populating it with the parsed options/binary data and then
> effecting the mount.
>
> This allows namespaces and other information to be conveyed through the
> mount procedure.  It also allows extra error information to be returned
> (so many things can go wrong during a mount that a small integer isn't
> really sufficient to convey the issue).
>
> This also allows Mikl=C3=B3s Szeredi's idea of doing:
>
>         fd =3D fsopen("nfs");
>         write(fd, "option=3Dval", ...);
>         fsmount(fd, "/mnt");


This may help to clear the boundary between what you can do with a
vfsmount (bind) and the filesystem. In containers, orchestration
tools, etc bind mounts are treated in a dynamic way, there is
assumption on github where developers and users expect that they can
dynamically add/move mounts between namespaces, however this won't
work with userns, so maybe this will help... My other suggestions:
Clear documentation and code comments will really help! I posted and
used some UID shifting within VFS layer patches a year ago, and it
seems that they really need something like this... !

I'm not sure where I did read about netlink, but at least it should
count userspace capabilities and namespace privacy/context...

> that he presented at LSF-2017 to be implemented (see the relevant patches
> in the series), to which I can add:
>
>         read(fd, error_buffer, ...);
>
> to read back any error message.  I didn't use netlink as that would make =
it
> depend on CONFIG_NET and would introduce network namespacing issues.
>
> I've implemented mount context handling for procfs and nfs.
>
> Further developments:
>
>  (*) Implement mount context support in more filesystems, ext4 being next
>      on my list.
>
>  (*) Move the walk-from-root stuff that nfs has to generic code so that y=
ou
>      can do something akin to:
>
>         mount /dev/sda1:/foo/bar /mnt
>
>      See nfs_follow_remote_path() and mount_subtree().  This is slightly
>      tricky in NFS as we have to prevent referral loops.
>
>  (*) Move the pid_ns pointer from struct mount_context to struct
>      proc_mount_context as I'm not sure it's necessary for anything other
>      than procfs.

FWIW the RFC "proc: support private proc instances per pidnamespace"
[1] that I have to clean will hide pid_ns under procfs filesystem, so
maybe that's a good reason to move it then get rid of it.

Thanks!


[1] https://lkml.org/lkml/2017/4/25/282

--=20
tixxdz
