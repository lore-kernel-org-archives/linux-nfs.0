Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:33335 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbdFIICd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jun 2017 04:02:33 -0400
Received: by mail-qt0-f170.google.com with SMTP id u12so67612468qth.0
        for <linux-nfs@vger.kernel.org>; Fri, 09 Jun 2017 01:02:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <19326.1496994530@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
 <20170530145043.GG6365@ZenIV.linux.org.uk> <19326.1496994530@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Fri, 9 Jun 2017 10:02:31 +0200
Message-ID: <CAOssrKepiJtMdwTbri7_kvNg-2oZifNtAu4bxf8Qmd=hCJLxgA@mail.gmail.com>
Subject: Re: Some filesystems set MNT_* flags in superblock->s_flags
To: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 9, 2017 at 9:48 AM, David Howells <dhowells@redhat.com> wrote:
> Al Viro <viro@ZenIV.linux.org.uk> wrote:
>
>>       * what the hell is ms_flags thing doing in __vfs_new_sb_config()?
>> It's a really vile mix of unrelated flags and operations we had in existing
>> mount(2) ABI.  With MS_KERNMOUNT thrown into that loo^Wmix.  Sure, we need
>> to parse the garbage fed to mount(2).  And we need to pass that garbage to
>> "legacy" types as well, but let's not inflict it upon the new mechanisms.
>
> Hmmm...  Some ->remount_fs() operations attempt to alter the MS_* flags that
> correspond to MNT_* flags.  Coda, for example:
>
>         static int coda_remount(struct super_block *sb, int *flags, char *data)
>         {
>                 sync_filesystem(sb);
>                 *flags |= MS_NOATIME;
>                 return 0;
>         }
>
> But this is quashed in do_remount_sb:
>
>         sb->s_flags = (sb->s_flags & ~MS_RMT_MASK) | (flags & MS_RMT_MASK);
>
> And others set them directly in s_flags, v9fs_fill_super() for example sets
> MS_NOATIME:
>
>         sb->s_flags |= MS_ACTIVE | MS_DIRSYNC | MS_NOATIME;
>
> I'm guessing things like this should be got rid of, but does there need to be
> a way to inform mount() that these should be set on the vfsmount?

Looks like MS_NOATIME is used in two *completely* separate roles:

  - passed to mount(2) to set MNT_NOATIME
  - set on sb->s_flags by filesystem to prevent atime modification

Btw. the second role can also be achieved by setting S_NOATIME on
inode, so this role of MS_NOATIME looks like being superfluous.

Thanks,
Miklos
