Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:33792 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751864AbdEIIDq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 04:03:46 -0400
Received: by mail-wr0-f173.google.com with SMTP id l9so62736781wre.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 01:03:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <10943.1494284264@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com> <10943.1494284264@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 9 May 2017 10:03:43 +0200
Message-ID: <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 9, 2017 at 12:57 AM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> > + (3) Validate and pre-process the mount context.
>>
>> (3.5) Create super block
>>
>> I think this need to be triggered by something like a "commit" command
>> from userspace.  Basically this is where the options are atomically
>> set on the new (create) or existing (reconfigure) superblock.
>
> Why do you need to expose this step to userspace?  Assuming in the "new" case
> you do, say:
>
>         fd = fsopen("nfs");
>         write(fd, "s foo.bar:/bar", ...);
>         write(fd, "o intr", ...);
>         write(fd, "o fsc", ...);
>         ...
>         write(fd, "c", ...); /* commit operation to get a superblock */
>         fsmount(fd, AT_FDCWD, "/mnt");  /* mount the superblock we just got */
>
> Then the "commit" op is dissimilar to "mount -o remount" since remount may
> alter the superblock parameters *and* the mountpoint parameters, but commit
> can only affect the superblock.

Forget remount, it's a historical remnant.  We need fsreconfig(sb) and
setmntattr(mnt).  They are changing properties of different objects.
Remount is like fcntl(fd, F_SETFL) and fchmod(fd, ...) rolled into
one.   They have nothing in common except the fact that the old
mount(2) API included both in one single operation, and I'm sure that
was a "oh we don't want to introduce a new flag for this, so lets
reuse the old one" sort of design decision.

>
> On the other hand, I could see that you might want to do:
>
>         fd = fsopen("nfs");
>         ...
>         write(fd, "c", ...); /* commit operation to get a superblock */
>         fstatfs(fd, &buf); /* get info about the superblock */
>         fsmount(fd, AT_FDCWD, "/mnt");  /* mount the superblock we just got */
>
>> > + (4) Perform the mount.
>> > +
>> > + (5) Return an error message attached to the mount context.
>>
>> Swap the order of the above.  There's no fs specific actions performed
>> at fsmount() time, and normal errno reporting should be perfectly
>> fine.
>
> There's no reason not to allow error messages to be attached by the actual
> vfsmount creation and insertion - and reasons that one might want to do so.
> Think LSMs, for instance.  We don't look up the mountpoint until this point,
> and so we can't do the security checks on them till this point.  It could make
> it easier to debug problems if we can return a more comprehensive message at
> this point.

I think that's crazy.  We don't return detailed errors for any other
syscall for path lookup, so why would path lookup for mount be
special.

And why would

    fd = open("/foo/bar", O_PATH);
    fsmount(fsfd, fd, NULL);

behave differently from

    fsmount(fsfd, -1, "/foo/bar");

?

>
>> I think reconfigure (don't call it remount, there's no "mounting"
>> going on there)
>
> There's adjustment of the vfsmount structure too; besides, it is called
> MS_REMOUNT in the UAPI and "mount -o remount", so we're somewhat stuck with
> the label whether we like it or not.

Oh, uapi compatibility: they can use the old mount(2) API for that and
introduce saner utils for the new stuff.  I'm sure we don't need to be
100% feature compatible with old  mount(2).

What we need is mount(2) to stay 100% compatible with itself while the
kernel internal APIs are reshuffled.


>> should start out with a context populated with with the current state of the
>> superblock.
>
> Hence why ->fsopen() takes a super_block parameter.
>
>> User can then reset and start over
>
> No, not really.  You cannot reset all options - the source for example,
> probably has to remain the same.  IP addresses on NFS mounts possibly should
> remain the same - though I can see situations where it might be convenient to
> change these.

Well, the current remount API is like that: you give a new set of
options (i.e. reset and replace anything that can be changed and leave
the rest).  Obviously "reset options" wouldn't allow you to change
options that cannot be changed.

>
>> or individually add/remove options.
>
> This is very per-filesystem-type dependent.

So say we have commands like

"o+ foo"
"o- bar"

The generic option parser would just add or remove the option in the
current set of options, and commit would just call ->remount_fs() with
the new set of options.  It would probably not work for the NFS case,
but that's okay, NFS can implement its own option parsing.

>> This should be a good place to allow querying the options as well, as Karel
>> suggested.
>
> I'm not sure it's worth the code unless we allow opening extant mounts and
> querying using this mechanism.

I'm saying we should allow opening an existent superblock and allow
query and change of options.

>> Then when the configuration is finished the changes are committed to the
>> superblock.
>
> You're going a lot beyond remount here.  Remount can, in one go, change some
> options which are superblock-only, some options which are mountpoint-only and
> at least one which crosses both domains.

We'll have s_op->remount_fs() for some time yet, but that's a clean,
super-block only operation.  MS_REMOUNT is a flag from hell, leave
that for mount(2) compatibility and forget it for the new API.

>
>> > + (*) bool mounted
>> > +
>> > +     This is set to true once a mount attempt is made.  This causes an error to
>> > +     be given on subsequent mount attempts with the same context and prevents
>> > +     multiple mount attempts.
>>
>> No point.  A context is mountable if the superblock is non-NULL.
>> Don't even need to have the context committed,
>
> Ummm...  Doesn't that render "commit" unnecessary?

No.   "commit" is a superblock operation.  fsmount() is a mount
operation.    fsmount() should not do anything to the superblock and
"commit" should not do anything to any mount.

>> if not, it would simply mount the sb in the previous state.
>
> You want to be able to open a filesystem fd, create or reference a superblock
> and then mount it several times?

Maybe.  I'm looking at this from the point of view of what objects we
have and what operations we want to do on them.  In that view it makes
no sense that fsmount() changes the state of the fsfd, since it's an
operation done on the mount tree and not on the superblock
configuration context.  The fact that you can do any number of mounts
on the fsfd just falls out from this premise.

Thanks,
Miklos
