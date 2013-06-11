Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:52915 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab3FKMSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jun 2013 08:18:01 -0400
MIME-Version: 1.0
In-Reply-To: <20130611080906.5a9d0384@corrin.poochiereds.net>
References: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
	<1366977861-27678-3-git-send-email-piastry@etersoft.ru>
	<20130611080906.5a9d0384@corrin.poochiereds.net>
Date: Tue, 11 Jun 2013 16:18:00 +0400
Message-ID: <CAKywueRn58fouJba8rUwAf78FmNn9kdRDrx+GC36BXdfC-jHLg@mail.gmail.com>
Subject: Re: [PATCH v6 2/7] VFS: Add O_DENYDELETE support for VFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/6/11 Jeff Layton <jlayton@poochiereds.net>:
> On Fri, 26 Apr 2013 16:04:16 +0400
> Pavel Shilovsky <piastry@etersoft.ru> wrote:
>
>> Introduce new LOCK_DELETE flock flag that is suggested to be used
>> internally only to map O_DENYDELETE open flag:
>>
>> !O_DENYDELETE -> LOCK_DELETE | LOCK_MAND.
>>
>> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
>> ---
>>  fs/locks.c                       | 53 +++++++++++++++++++++++++++++++++-------
>>  fs/namei.c                       |  3 +++
>>  include/linux/fs.h               |  6 +++++
>>  include/uapi/asm-generic/fcntl.h |  1 +
>>  4 files changed, 54 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/locks.c b/fs/locks.c
>> index dbc5557..1cc68a9 100644
>> --- a/fs/locks.c
>> +++ b/fs/locks.c
>> @@ -269,7 +269,7 @@ EXPORT_SYMBOL(locks_copy_lock);
>>
>>  static inline int flock_translate_cmd(int cmd) {
>>       if (cmd & LOCK_MAND)
>> -             return cmd & (LOCK_MAND | LOCK_RW);
>> +             return cmd & (LOCK_MAND | LOCK_RW | LOCK_DELETE);
>>       switch (cmd) {
>>       case LOCK_SH:
>>               return F_RDLCK;
>> @@ -614,6 +614,8 @@ deny_flags_to_cmd(unsigned int flags)
>>               cmd |= LOCK_READ;
>>       if (!(flags & O_DENYWRITE))
>>               cmd |= LOCK_WRITE;
>> +     if (!(flags & O_DENYDELETE))
>> +             cmd |= LOCK_DELETE;
>>
>>       return cmd;
>>  }
>> @@ -836,6 +838,31 @@ out:
>>       return error;
>>  }
>>
>> +int
>> +sharelock_may_delete(struct dentry *dentry)
>> +{
>> +     struct file_lock **before;
>> +     int rc = 0;
>> +
>> +     if (!IS_SHARELOCK(dentry->d_inode))
>> +             return rc;
>> +
>> +     lock_flocks();
>> +     for_each_lock(dentry->d_inode, before) {
>> +             struct file_lock *fl = *before;
>> +             if (IS_POSIX(fl))
>> +                     break;
>> +             if (IS_LEASE(fl))
>> +                     continue;
>> +             if (fl->fl_type & LOCK_DELETE)
>> +                     continue;
>
> Are you sure this logic is right? What if I have a normal non-LOCK_MAND
> lock on this file. Won't that prevent me from deleting it with this
> patch?
>

It is a bug, thank you for pointing it out. We need to skip all
non-LOCK_MAND locks here.

--
Best regards,
Pavel Shilovsky.
