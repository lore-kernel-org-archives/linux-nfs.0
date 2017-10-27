Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58912 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752634AbdJ0Off (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Oct 2017 10:35:35 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKdm-znRnR80rxvzH8WVWf=sEkL1EGMzV4c3dyp_FK2-rA@mail.gmail.com>
References: <CAOssrKdm-znRnR80rxvzH8WVWf=sEkL1EGMzV4c3dyp_FK2-rA@mail.gmail.com> <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk> <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk> <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com> <28791.1509035055@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock creation/configuration context [ver #6]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 27 Oct 2017 15:35:32 +0100
Message-ID: <29611.1509114932@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> Also, how about moving calls to vfs_parse_fs_option() into filesystem
> code?   Even those options are not generic, some filesystem wants
> this, some that.  It's just a historical accident that those are set
> with MS_FOO and not "foo".  Filesystems that don't have any option
> parsing could have a generic version that deals with "ro/rw", the
> others can handle these options along with the rest.

Ummm...  I don't see how that would work.  vfs_parse_mount_option() (or
vfs_parse_fs_option() as it will become) is the way into the filesystem from
write(mfd, "o foo") and also applies the security policy before the filesystem
gets its hands on the option.

Did you mean vfs_parse_sb_flag_option()?  The point of that function is so
that the name->flag mapping tables don't have to be replicated in every
filesystem.

Also, filesystems can supply a ->validate() method that rejects any SB_* flags
they don't want to support, but for legacy purposes we probably can't do that.

> Reset only makes sense in the context of reconfig (fka. remount).

Okay, that makes more sense.

> But lets leave to later if it's not something trivial.

I don't think it is trivial - and it's something that would have to be dealt
with on an fs-by-fs basis and very well documented.

Btw, how would it affect the LSM?

Also, how do you propose to use it?  I presume you're not thinking of someone
talking to the socket with a telnet-like interface.

> >> 2/a) Shared sb:
> >> 2/b) Shared sb for legacy mount(2)
> >
> > In the new-mount-of-live-sb case, I would validate the context script and
> > ignore any options that try to change things that can't be changed because
> > the fs is live.
> 
> Your sentence seems to imply that we do change those that can be
> changed.   That's not what legacy does, it ignores *all* options
> (except rw/ro for which it errors out on mismatch).  I don't think
> that's a nice behavior, but we definitely need to keep it for legacy.
> 
> For non-legacy, do we want to extend the "error out on mismatch"
> behavior to all options, rather than ignoring them?

Actually, we might want to ignore all the options.  That might itself be an
option, kind of like O_CREAT/O_EXCL.  I think someone suggested this before.

> > There's the question of how far you allow a happens-to-share mount to
> > effect a reconfigure.  Seems a reasonable distinction to say that in your
> > case 2 you just ignore conflicts but possibly warn or reject in case 3.
> 
> Not sure I understand why we'd want to ignore conflicts in case 2 and
> not in 3.   Can we not have consistency (error out on all conflicts)?

I was thinking that if you mount a source that's already mounted, it would do
a reconfigure instead, but I this is addressed above as "2) shared sb".

> > Except that ext4, f2fs, 9p, ... do take at least some of them.  I'm not
> > sure whether they ever see them, but without auditing userspace, there's
> > no way to know.
> 
> So moving possibly dead code to the level of VFS fixes things how?

It's not dead code.  You can call the mount() syscall directly, and something
like busybox might well do so.  Normally these are weeded out by userspace.

It's possible, even, in the ext4 case that you might store these options on
disk in the options string in the superblock.

> Let filesystems deal with that crap and make sure they deal with it
> only for legacy mount and not for the new, supposedly clean one.

Sorry, how does the new, clean one do it without handling these options?
There is no MS_* mask passed in, except to fsmount().

> Making it generic also possibly breaks uABI by allowing an option that
> was rejected previously for some other fs.

That's not a particularly serious break, I wouldn't've thought.  Further, the
set of options that a filesystem will take evolves over time, and what was
rejected yesterday might be accepted today.

All the UAPI SB_* options can be passed in to mount(2) from userspace, and
filesystems all just ignore them if they don't want to support them as far as
I know.  If this is the case, I don't see a problem with letting generic code
parse these common options.

David
