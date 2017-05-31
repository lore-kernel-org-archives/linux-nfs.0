Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:35656 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750985AbdEaHvD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 May 2017 03:51:03 -0400
Received: by mail-qt0-f175.google.com with SMTP id v27so6027015qtg.2
        for <linux-nfs@vger.kernel.org>; Wed, 31 May 2017 00:51:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15403.1496158574@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
 <20170530145043.GG6365@ZenIV.linux.org.uk> <15403.1496158574@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Wed, 31 May 2017 09:51:02 +0200
Message-ID: <CAOssrKewzKn-5=b3n84mP=8EROCP22thcizggQfueh+CqDHKDg@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/23] VFS: Introduce superblock configuration
 context [ver #4]
To: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 30, 2017 at 5:36 PM, David Howells <dhowells@redhat.com> wrote:
> Al Viro <viro@ZenIV.linux.org.uk> wrote:
>
>> Random notes:
>>       * "sb_config" looks rather odd in the current variant; mount_context,
>> perhaps?  Or fs_context, for that matter...  Anyway, that's trivial.
>
> You can argue that one with Miklós.  He argued against mount_context as I had
> it originally.  His point is that the same struct may be used when
> reconfiguring an sb - which isn't exactly a mount operation (even though we do
> it that day today with remount).

I'm fine with fs_context, just leave "mount" out of this.  Mounting is
the act of attaching the root dentry to the mountpoint. fs_context is
used for obtaining the root, but not for mounting itself, hence
mount_context is misleading IMO.

>>       * what the hell is ms_flags thing doing in __vfs_new_sb_config()?
>> It's a really vile mix of unrelated flags and operations we had in existing
>> mount(2) ABI.  With MS_KERNMOUNT thrown into that loo^Wmix.  Sure, we need
>> to parse the garbage fed to mount(2).  And we need to pass that garbage to
>> "legacy" types as well, but let's not inflict it upon the new mechanisms.
>
> I know, but we might get it from mount(2).  I can tamp down the flag mask and
> translate it from MS_*, but the MS_* flags are also stored in the superblock
> (->s_flags).

Good cleanup would be to just introduce a new set of flags for s_flags
and leave MS_* usage solely for the legacy mount(2) interface.

Thanks,
Miklos
