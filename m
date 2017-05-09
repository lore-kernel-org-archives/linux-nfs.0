Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:34679 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752586AbdEILEn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 07:04:43 -0400
Received: by mail-qt0-f177.google.com with SMTP id j29so72484313qtj.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 04:04:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15607.1494322345@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
 <15607.1494322345@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 9 May 2017 13:04:40 +0200
Message-ID: <CAOssrKcsUthwpnVg=JZaW-8caCVvO12kT0vyzkR2MQaXgAzrCQ@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 9, 2017 at 11:32 AM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> Forget remount, it's a historical remnant.
>
> I don't think it can't be set aside so lightly.  Within the kernel, the option
> parsing should share as much code as possible between new superblock config,
> old new mount and old remount.

Lets make things clear:  VFS didn't do any option parsing for
mount(2), it was all in filesystem's fstype->mount() and
s_op->remount_fs() operations.  What the VFS did do is filter out the
junk from MS_xxx options and pass only the relevant ones to the
filesystem creation functions, which was mount_fs() and
do_remount_sb().   Note how those functions are in super.c and don't
have a vfsmount argument.

So I propose introducing a third way of parsing arguments, which a
filesystem may implement via sb_config_ops (or whatever we want to
call it) that allows it to parse options into its internal structures
and have it be passed to superblock creation and superblock
reconfiguration ops (which also need to be new ones, that thake the
parsed options in the sb_config structure instead of as a comma
delimited string).  With the fsopen() API the generic code (possibly
via helpers called from fs code) would need to parse the "MS_xxx" type
options now, and the infrastructure for that is new, since previously
those options were parsed in userland instead of in the kernel.

There would be no duplication as filesystems would either implement
the old option parsing or the new one.

Also we could have various helpers that do most of the dirty work of
option parsing, allowing easy migration of filesystems.   In the end
the old method taking the unparsed options can go away.

And, as you say, the option parsing would be shared between old "new
mount", old "remount" and new sb config.  And it would be shared for
the unmigrated fs case as well as the migrated fs case.

And we are still only taking about sb config, not a word about mount
attributes; they should be irrelevant to any of this API shuffling and
new API additions.

> The 'trickiest' function we need to support is MS_RDONLY flipping.  That one
> affects both the mount and the superblock.  I think all the rest only affect
> one side or the other.
>
> Given that a superblock can be mounted in multiple places, do we need to count
> the number of read-only mounts that are holding a particular superblock and
> only flip the superblock when they're all read-only?

Nothing special going on here.  If sb is ro then adding a rw mount
should either fail or automatically go ro.  I think just erroring out
is the better of the two.


> Or do you advocate replacing "mount -o remount,[ro|rw]" with a pair of
> operations - one to flip the mount and the other to flip the superblock?

Yes, definitely.  That's exactly what users have been asking for
(there's even a bugzilla somewhere I don't remember)

Thanks
Miklos
