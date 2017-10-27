Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:48194 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751834AbdJ0JYW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 05:24:22 -0400
Received: by mail-qk0-f173.google.com with SMTP id d67so7575959qkg.5
        for <linux-nfs@vger.kernel.org>; Fri, 27 Oct 2017 02:24:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28791.1509035055@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
 <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com> <28791.1509035055@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Fri, 27 Oct 2017 11:24:21 +0200
Message-ID: <CAOssrKdm-znRnR80rxvzH8WVWf=sEkL1EGMzV4c3dyp_FK2-rA@mail.gmail.com>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock
 creation/configuration context [ver #6]
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 26, 2017 at 6:24 PM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> > +/**
>> > + * vfs_parse_mount_option - Add a single mount option to a superblock config
>>
>> Mount options are those that refer to the mount
>> (nosuid,nodev,noatime,etc..); this function is not parsing those,
>> AFAICT.
>
> I'd quibble that those are "mountpoint" options, not "mount" options.  Mount
> options are the options you can pass to mount and are a mixed bag.  But fair
> enough, it's probably worth avoiding such terminology where we can.
>
>> How about vfs_parse_fs_option()?
>
> Sure.  Can we please not rename it again?

I promise ;)

Also, how about moving calls to vfs_parse_fs_option() into filesystem
code?   Even those options are not generic, some filesystem wants
this, some that.  It's just a historical accident that those are set
with MS_FOO and not "foo".  Filesystems that don't have any option
parsing could have a generic version that deals with "ro/rw", the
others can handle these options along with the rest.

>
>> We probably also need a "reset" type of option that clears all bits
>> and is also passed onto the filesystem's parsing routine so it can
>> reset all options as well.
>
> Reset what?  To what?  To a blank slate?  To the state on the medium?  What if
> it's a netfs?
>
> This operation isn't well defined and I'm not sure it's useful because:
>
>  (1) Unless we can preload options from some source, the starting context is
>      blank, so why do you need a reset on a new mount?

Reset only makes sense in the context of reconfig (fka. remount).

>  (2) We need to find out what state the options are currently in.  Reset today
>      doesn't necessarily mean the same as reset tomorrow.
>
>  (3) Not all options are simple on/off switches.  Some of them are multistate,
>      some are strings/numbers that have non-zero defaults and some have
>      dependencies on other options.
>
>  (4) Not all options can be simply reset to "0", particularly if the
>      filesystem is live.  Take an option that points to a network server or a
>      separate journalling device for example.

I'd think reset restores the state to a default.  Default state is
what a new fs instance without any specified options starts out with.
Yes it's different today and different tomorrow.  Yes, some options
are not binary.   Yes, some options are not mutable on a live
filesystem.  Regardless of those, I think it makes sense to allow a
reconfig that results in a configuration that would have been reached
by setting the same options on a new mount.  I.e. have a "replace
configuration"  as well as a "change bits of current configuration"
mode.

But lets leave to later if it's not something trivial.

>> 1/a) New sb:
>> 1/b) New sb for legacy mount(2)
>
> Looking at this in terms of ext4, I would make the parser create an "option
> change" script prior to loading the superblock.  The reason for that with ext4
> is that ext4 stores an additional option string that must be parsed and
> applied first - except that we potentially need some of the mount-supplied
> options to be able to mount the fs.
>
> So in the new-mount-of-new-sb case, I would actually create two scripts, one
> for the options written to the context fd, then one for the on-disk script,
> then validate the context and then apply them both atomically.

Agree.

>
>> 2/a) Shared sb:
>> 2/b) Shared sb for legacy mount(2)
>
> In the new-mount-of-live-sb case, I would validate the context script and
> ignore any options that try to change things that can't be changed because the
> fs is live.

Your sentence seems to imply that we do change those that can be
changed.   That's not what legacy does, it ignores *all* options
(except rw/ro for which it errors out on mismatch).  I don't think
that's a nice behavior, but we definitely need to keep it for legacy.

For non-legacy, do we want to extend the "error out on mismatch"
behavior to all options, rather than ignoring them?

> It might be nice to report them also, but that requires a mechanism to do so.
>
>> 3/a) Reconfig
>> 3/b) Reconfig for legacy mount(2) (i.e. MS_REMOUNT)
>
> In the reconfigure case, I only need to create one script, validate it and
> then apply it atomically (well, as atomically as possible, given the fs is
> actually live at this point).

Yep.

>
> There's the question of how far you allow a happens-to-share mount to effect a
> reconfigure.  Seems a reasonable distinction to say that in your case 2 you
> just ignore conflicts but possibly warn or reject in case 3.

Not sure I understand why we'd want to ignore conflicts in case 2 and
not in 3.   Can we not have consistency (error out on all conflicts)?

>> > +int generic_parse_monolithic(struct fs_context *ctx, void *data)
>> > +{
>> > +       char *options = data, *p;
>> > +       int ret;
>> > +
>> > +       if (!options)
>> > +               return 0;
>> > +
>> > +       while ((p = strsep(&options, ",")) != NULL) {
>> > +               if (*p) {
>> > +                       ret = vfs_parse_mount_option(ctx, p);
>>
>> Monolithic option block is the legacy thing.
>
> Yes, I know.
>
>> It shouldn't be parsing the common flags.  It should instead be treating
>> them as forbidden (although it probably doesn't really matter, since no
>> filesystem will accept these anyway).
>
> Except that ext4, f2fs, 9p, ... do take at least some of them.  I'm not sure
> whether they ever see them, but without auditing userspace, there's no way to
> know.

So moving possibly dead code to the level of VFS fixes things how?

Let filesystems deal with that crap and make sure they deal with it
only for legacy mount and not for the new, supposedly clean one.
Making it generic also possibly breaks uABI by allowing an option that
was rejected previously for some other fs.

>
>> So probably best to expand vfs_parse_mount_option() here and skip the
>> sb flag parsing part.
>
> You need to prove they are never seen here :-/
>
>> > + * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)
>>
>> I'm confused: MS_REMOUNT in sb_flags and FS_CONTEXT_FOR_REMOUNT in purpose?
>>
>> I hope that's just a stale comment, sb_flags should really be just the
>> superblock flags and not any op flags.
>
> Yeah - that's stale.
>
>> Also, can FS_CONTEXT_FOR_REMOUNT be renamed to ..._RECONFIG?
>
> If you really want ;-)

Yes.  I think clean naming results in clean concepts in one's head,
which results in clean interfaces.  Which is *the* purpose of this
exercise.

Thanks,
Miklos
