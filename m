Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:54155 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJ0PdH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 11:33:07 -0400
Received: by mail-qt0-f169.google.com with SMTP id n61so8877928qte.10
        for <linux-nfs@vger.kernel.org>; Fri, 27 Oct 2017 08:33:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <29611.1509114932@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
 <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com>
 <28791.1509035055@warthog.procyon.org.uk> <CAOssrKdm-znRnR80rxvzH8WVWf=sEkL1EGMzV4c3dyp_FK2-rA@mail.gmail.com>
 <29611.1509114932@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Fri, 27 Oct 2017 17:33:05 +0200
Message-ID: <CAOssrKd2MX0ao7f2X32js=72YmZ0exn4KkwdgrXB9tKY7KiSXg@mail.gmail.com>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock
 creation/configuration context [ver #6]
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding linux-api@vger (I think you should add this Cc for patches
which add/change userspace APIs).

On Fri, Oct 27, 2017 at 4:35 PM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> Also, how about moving calls to vfs_parse_fs_option() into filesystem
>> code?   Even those options are not generic, some filesystem wants
>> this, some that.  It's just a historical accident that those are set
>> with MS_FOO and not "foo".  Filesystems that don't have any option
>> parsing could have a generic version that deals with "ro/rw", the
>> others can handle these options along with the rest.
>
> Ummm...  I don't see how that would work.  vfs_parse_mount_option() (or
> vfs_parse_fs_option() as it will become) is the way into the filesystem from
> write(mfd, "o foo") and also applies the security policy before the filesystem
> gets its hands on the option.
>
> Did you mean vfs_parse_sb_flag_option()?  The point of that function is so
> that the name->flag mapping tables don't have to be replicated in every
> filesystem.

Yes I did mean vfs_parse_sb_flag_option().

Yes, I understand its purpose, but it would be cleaner if all the
option parsing was done in fc->ops->parse_option().

It might be worth introducing the vfs_parse_sb_flag_option(), to be
called from ->parse_option().

>
> Also, filesystems can supply a ->validate() method that rejects any SB_* flags
> they don't want to support, but for legacy purposes we probably can't do that.
>
>> Reset only makes sense in the context of reconfig (fka. remount).
>
> Okay, that makes more sense.
>
>> But lets leave to later if it's not something trivial.
>
> I don't think it is trivial - and it's something that would have to be dealt
> with on an fs-by-fs basis and very well documented.
>
> Btw, how would it affect the LSM?

LSM would have to reject a "reset" if not enough privileges to
*create* a new fs instance, since it essentially requires creating a
new config, which is what is done when creating an fs instance.

>
> Also, how do you propose to use it?  I presume you're not thinking of someone
> talking to the socket with a telnet-like interface.

No.  It would be an command line option for the relevant userspace utility:

  fs-reconfig /mnt/foo --reset "ro"

as opposed to

  fs-reconfig /mnt/foo "ro"

The former would change the options to default + "ro".

The latter would change "rw"->"ro" and leave all other options alone.

>
>> >> 2/a) Shared sb:
>> >> 2/b) Shared sb for legacy mount(2)
>> >
>> > In the new-mount-of-live-sb case, I would validate the context script and
>> > ignore any options that try to change things that can't be changed because
>> > the fs is live.
>>
>> Your sentence seems to imply that we do change those that can be
>> changed.   That's not what legacy does, it ignores *all* options
>> (except rw/ro for which it errors out on mismatch).  I don't think
>> that's a nice behavior, but we definitely need to keep it for legacy.
>>
>> For non-legacy, do we want to extend the "error out on mismatch"
>> behavior to all options, rather than ignoring them?
>
> Actually, we might want to ignore all the options.  That might itself be an
> option, kind of like O_CREAT/O_EXCL.  I think someone suggested this before.

Okay, that makes sense.

>
>> > There's the question of how far you allow a happens-to-share mount to
>> > effect a reconfigure.  Seems a reasonable distinction to say that in your
>> > case 2 you just ignore conflicts but possibly warn or reject in case 3.
>>
>> Not sure I understand why we'd want to ignore conflicts in case 2 and
>> not in 3.   Can we not have consistency (error out on all conflicts)?
>
> I was thinking that if you mount a source that's already mounted, it would do
> a reconfigure instead, but I this is addressed above as "2) shared sb".
>
>> > Except that ext4, f2fs, 9p, ... do take at least some of them.  I'm not
>> > sure whether they ever see them, but without auditing userspace, there's
>> > no way to know.
>>
>> So moving possibly dead code to the level of VFS fixes things how?
>
> It's not dead code.  You can call the mount() syscall directly, and something
> like busybox might well do so.  Normally these are weeded out by userspace.
>
> It's possible, even, in the ext4 case that you might store these options on
> disk in the options string in the superblock.
>
>> Let filesystems deal with that crap and make sure they deal with it
>> only for legacy mount and not for the new, supposedly clean one.
>
> Sorry, how does the new, clean one do it without handling these options?
> There is no MS_* mask passed in, except to fsmount().

The new one certainly should.

>
>> Making it generic also possibly breaks uABI by allowing an option that
>> was rejected previously for some other fs.
>
> That's not a particularly serious break, I wouldn't've thought.  Further, the
> set of options that a filesystem will take evolves over time, and what was
> rejected yesterday might be accepted today.
>
> All the UAPI SB_* options can be passed in to mount(2) from userspace, and
> filesystems all just ignore them if they don't want to support them as far as
> I know.  If this is the case, I don't see a problem with letting generic code
> parse these common options.

Ignoring unknown flags/options is generally a bad idea.

Thanks,
Miklos
