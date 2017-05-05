Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35810 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751996AbdEEPrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 May 2017 11:47:24 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKdHn5SpxEXBZ5EQvCF9E8JTiMqJo+M3OKPXUHYXGeqMGg@mail.gmail.com>
References: <CAOssrKdHn5SpxEXBZ5EQvCF9E8JTiMqJo+M3OKPXUHYXGeqMGg@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 05 May 2017 16:47:22 +0100
Message-ID: <22958.1493999242@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> I'd argue with some design decisions here.  One of the motivations for
> doing the mount API overhaul is to create clear distinction between
> separate functions like:
> 
>  - creating filesystem instance (aka superblock)
> 
>  - attaching filesystem instance into mount tree
> 
>  - reconfiguring superblock
> 
>  - changing mount properties

I definitely agree that keeping a separation between vfsmount manipulation
(add, bind, move, ...) and superblock manipulation (create, remount) is a good
idea.

However, creating new superblocks and remounting superblocks have a lot in
common, including the option parsing.  Note also that existing code is
somewhat lazy about rejecting parameters that can't be changed with a remount
and will ignore some attempted changes.  We have to retain this behaviour, at
least for the normal mount() system call.

Note that one of the main reasons I'm working on this is namespace
propagation, particularly with respect to automounts.

> This patchset achieves this partly, but the separation is far from
> crisp clear...  First of all why is fsopen() creating a "mount
> context"?  It's suppsed to create a "superblock creation context".

I've no particular objection to renaming struct mount_context to something
else, but it also needs to handle remount because of the commonality.

Further, once you've created a superblock, what are you going to do with it
other than mount it?  I suppose you could statfs it and we could add other
superblock manipulation functions, but this is normally done by opening the
device directly (at least for bdev-based superblocks).

> And indeed, there are mount flags and root path in there, which are
> definitely not necessary for creating a super block.

Erm, that's not strictly true.

Some filesystems (eg. nfs, ocfs2, lustre) want to know about certain MNT_xxx
flags, such as MNT_NOATIME and MNT_READONLY.

Further, the root path might be necessary for the mount - see NFS for example.
What I was thinking of, say for NFS, is splitting the source name up front,
so:

	my.nfs.org:/my/home/dir

into:

	mc->device = "my.nfs.org";
	mc->root_path = "/my/home/dir";

and then having the VFS handle the root walk rather than doing it inside NFS.
This facility could then become available to other filesystems potentially.

However, with the case on NFS, you may need to hand the root path off to a
mount server.

> Is there a good reason why these mount specific properties leaked into
> the object created by fsopen()?

Answered above.  I'm okay with removing remove root_path from the context for
the moment.  It's something that can be revisited later.

We also might need to remove usage of MNT_xxx flags from filesystems.

> Also I'd expect all context ops to be fully generic first.  I.e. no
> filesystem code needs to be touched to make the new interface work.
> The context would just build the option string and when everything is
> ready (probably need a "commit" command) then it would go off and call
> mount_fs() to create the superblock and attach it to the context.

That should be easy enough to add as a fallback.

> Then, when that works, we could add context ops, so the filesystem can
> do various things along the way, which is the other reason we want
> this.  And in the end it would allow gradual migration to a new
> superblock creation api and phasing out the old one.

I'm not sure the context ops are so easily to add gradually.

> But that shouldn't be observable on either the old or the new userspace
> interfaces.

Almost a fair point - but it can be observed by pushing in more than a page's
worth of options.  What I have now for NFS will still work with
fsopen()/write()/fsmount() whereas mount() won't.

David
