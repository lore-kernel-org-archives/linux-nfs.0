Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46814 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751036AbdEHW5q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 18:57:46 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
References: <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 08 May 2017 23:57:44 +0100
Message-ID: <10943.1494284264@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> > + (3) Validate and pre-process the mount context.
> 
> (3.5) Create super block
> 
> I think this need to be triggered by something like a "commit" command
> from userspace.  Basically this is where the options are atomically
> set on the new (create) or existing (reconfigure) superblock.

Why do you need to expose this step to userspace?  Assuming in the "new" case
you do, say:

	fd = fsopen("nfs");
	write(fd, "s foo.bar:/bar", ...);
	write(fd, "o intr", ...);
	write(fd, "o fsc", ...);
	...
	write(fd, "c", ...); /* commit operation to get a superblock */
	fsmount(fd, AT_FDCWD, "/mnt");  /* mount the superblock we just got */

Then the "commit" op is dissimilar to "mount -o remount" since remount may
alter the superblock parameters *and* the mountpoint parameters, but commit
can only affect the superblock.

On the other hand, I could see that you might want to do:

	fd = fsopen("nfs");
	...
	write(fd, "c", ...); /* commit operation to get a superblock */
	fstatfs(fd, &buf); /* get info about the superblock */
	fsmount(fd, AT_FDCWD, "/mnt");  /* mount the superblock we just got */

> > + (4) Perform the mount.
> > +
> > + (5) Return an error message attached to the mount context.
> 
> Swap the order of the above.  There's no fs specific actions performed
> at fsmount() time, and normal errno reporting should be perfectly
> fine.

There's no reason not to allow error messages to be attached by the actual
vfsmount creation and insertion - and reasons that one might want to do so.
Think LSMs, for instance.  We don't look up the mountpoint until this point,
and so we can't do the security checks on them till this point.  It could make
it easier to debug problems if we can return a more comprehensive message at
this point.

> I think reconfigure (don't call it remount, there's no "mounting"
> going on there)

There's adjustment of the vfsmount structure too; besides, it is called
MS_REMOUNT in the UAPI and "mount -o remount", so we're somewhat stuck with
the label whether we like it or not.

> should start out with a context populated with with the current state of the
> superblock.

Hence why ->fsopen() takes a super_block parameter.

> User can then reset and start over

No, not really.  You cannot reset all options - the source for example,
probably has to remain the same.  IP addresses on NFS mounts possibly should
remain the same - though I can see situations where it might be convenient to
change these.

> or individually add/remove options.

This is very per-filesystem-type dependent.

> This should be a good place to allow querying the options as well, as Karel
> suggested.

I'm not sure it's worth the code unless we allow opening extant mounts and
querying using this mechanism.

> Then when the configuration is finished the changes are committed to the
> superblock.

You're going a lot beyond remount here.  Remount can, in one go, change some
options which are superblock-only, some options which are mountpoint-only and
at least one which crosses both domains.

> > + (*) bool mounted
> > +
> > +     This is set to true once a mount attempt is made.  This causes an error to
> > +     be given on subsequent mount attempts with the same context and prevents
> > +     multiple mount attempts.
> 
> No point.  A context is mountable if the superblock is non-NULL.
> Don't even need to have the context committed,

Ummm...  Doesn't that render "commit" unnecessary?

> if not, it would simply mount the sb in the previous state.

You want to be able to open a filesystem fd, create or reference a superblock
and then mount it several times?

> I'd hope some simplifications would fall out from this model.

Not really.  It makes things slightly less simple, particularly with the
"commit" operation that you want.  I'm not sure that sys_mount() and
sys_fsmount() will be able to share as much code.

It also makes the remount process less similar to the mount process because
the "commit" operation doesn't seem useful in the former because remount also
alters the vfsmount.

David
