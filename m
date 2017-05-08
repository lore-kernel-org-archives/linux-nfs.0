Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37460 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdEHIZ4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 May 2017 04:25:56 -0400
Received: by mail-wm0-f43.google.com with SMTP id m123so56057314wma.0
        for <linux-nfs@vger.kernel.org>; Mon, 08 May 2017 01:25:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <22958.1493999242@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <CAOssrKdHn5SpxEXBZ5EQvCF9E8JTiMqJo+M3OKPXUHYXGeqMGg@mail.gmail.com> <22958.1493999242@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Mon, 8 May 2017 10:25:53 +0200
Message-ID: <CAOssrKeNeUcGKf=65utr3ZDbEr86+FmjevUkvpNgJnSMp5D6Og@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 5, 2017 at 5:47 PM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> I'd argue with some design decisions here.  One of the motivations for
>> doing the mount API overhaul is to create clear distinction between
>> separate functions like:
>>
>>  - creating filesystem instance (aka superblock)
>>
>>  - attaching filesystem instance into mount tree
>>
>>  - reconfiguring superblock
>>
>>  - changing mount properties
>
> I definitely agree that keeping a separation between vfsmount manipulation
> (add, bind, move, ...) and superblock manipulation (create, remount) is a good
> idea.
>
> However, creating new superblocks and remounting superblocks have a lot in
> common, including the option parsing.  Note also that existing code is
> somewhat lazy about rejecting parameters that can't be changed with a remount
> and will ignore some attempted changes.  We have to retain this behaviour, at
> least for the normal mount() system call.
>
> Note that one of the main reasons I'm working on this is namespace
> propagation, particularly with respect to automounts.
>
>> This patchset achieves this partly, but the separation is far from
>> crisp clear...  First of all why is fsopen() creating a "mount
>> context"?  It's suppsed to create a "superblock creation context".
>
> I've no particular objection to renaming struct mount_context to something
> else, but it also needs to handle remount because of the commonality.

Definitely agree about having the same object handle filesystem
creation and filesystem reconfiguration.  And yeah, I think naming
does have to be changed, simply because the old way of doing things is
so ingrained in everything in this area.

> Further, once you've created a superblock, what are you going to do with it
> other than mount it?  I suppose you could statfs it and we could add other
> superblock manipulation functions, but this is normally done by opening the
> device directly (at least for bdev-based superblocks).

It surely makes sense to mount it, but that does not mean we need to
blur the boundary.

>> And indeed, there are mount flags and root path in there, which are
>> definitely not necessary for creating a super block.
>
> Erm, that's not strictly true.
>
> Some filesystems (eg. nfs, ocfs2, lustre) want to know about certain MNT_xxx
> flags, such as MNT_NOATIME and MNT_READONLY.

So sometimes filesystems have access to mount flags that tell about
the mount that the operation was done through (the only relevant op is
getattr(), right?).

But that doesn't mean the filesystem has any business looking at the
mount flags that the initial mount will be created with (it definitely
does not).

> Further, the root path might be necessary for the mount - see NFS for example.
> What I was thinking of, say for NFS, is splitting the source name up front,
> so:
>
>         my.nfs.org:/my/home/dir
>
> into:
>
>         mc->device = "my.nfs.org";
>         mc->root_path = "/my/home/dir";
>
> and then having the VFS handle the root walk rather than doing it inside NFS.
> This facility could then become available to other filesystems potentially.

Ah, I see what you are saying:  we don't have the infrastructure
currently in the VFS to handle NFS subdir mounts, but want to
introduce this in the interface now (because NFS *can* handle it), so
that when we will have the VFS infrastructure we can silently switch
to it.

> However, with the case on NFS, you may need to hand the root path off to a
> mount server.

Hmm... IMO the right way to do this would be to move the NFS subdir
code first to the VFS and then introduce the new interface with the
correct semantics (i.e. subdir is handled on mount not on superblock
creation).

I haven't looked at what NFS is doing, but subdir mounts should be
just like plain bind mounts, no?  The special thing here is that we
need to do that bind mount before the filesystem is initially mounted.
But that can be done by

 - first doing an kernel-internal mount
 - doing the pathwalk on that (which can trigger more internal mounts)
 - attaching the found source to the target mountpoint
 - finally discarding the kernel internal mount tree

>> Is there a good reason why these mount specific properties leaked into
>> the object created by fsopen()?
>
> Answered above.  I'm okay with removing remove root_path from the context for
> the moment.  It's something that can be revisited later.
>
> We also might need to remove usage of MNT_xxx flags from filesystems.

There is no MNT_xxx flag usage in superblock creation, because
mnt_flags are not passed to filesystems and the relevant MS_xxx ones
are cleared from the flags that *are* passed to the fs.

MS_RDONLY is special, because it's a mount flag as well as a
superblock flag.  No problem there, with the new interface it will be
possible to set them separately (e.g. ro on sb and rw on mnt or vice
versa).

>> But that shouldn't be observable on either the old or the new userspace
>> interfaces.
>
> Almost a fair point - but it can be observed by pushing in more than a page's
> worth of options.  What I have now for NFS will still work with
> fsopen()/write()/fsmount() whereas mount() won't.

Alright, lets just stay, that everything that works now should work
the same way on the old as well as the new interfaces.

Thanks,
Miklos
