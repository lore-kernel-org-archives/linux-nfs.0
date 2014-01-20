Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f47.google.com ([209.85.160.47]:63289 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbaATKpD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jan 2014 05:45:03 -0500
MIME-Version: 1.0
In-Reply-To: <20140117181847.6c1f3831@alan.etchedpixels.co.uk>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
	<1389953232-9428-2-git-send-email-piastry@etersoft.ru>
	<20140117181847.6c1f3831@alan.etchedpixels.co.uk>
Date: Mon, 20 Jan 2014 14:45:00 +0400
Message-ID: <CAKywueT=JsTkNC+w-vrN0ftam7F8Eqb8DXJ0w2G4q9vnt0hVNQ@mail.gmail.com>
Subject: Re: [PATCH v7 1/7] VFS: Introduce new O_DENY* open flags
From: Pavel Shilovsky <piastry@etersoft.ru>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014/1/17 One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>:
>> +#define ESHAREDENIED 258     /* File is locked with a sharelock */
>
> Have you prepared C library patches to match this ?

I don't have it for now.

>
> (and why not just use EPERM, it has the meaning you want already)

We need to determine if we have a share reservation error to map it
accurately in file servers and wine.

>
>
>> + * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
>> + * tell us whether the reservation allows other readers and writers.
>> + */
>> +static int
>> +locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
>> +{
>
> Shouldn't this also check for CAP_SYS_DAC or some similar permission so
> that root can override such a mess (eg to fix full disks in an
> emergency) ?

May be it's better to let root an ability to remount the system
without sharelock mount option and then fix an emergency?

>
>
>> +
>> +     /*
>> +      * For sharelock mounts if a file was created but not opened, we need
>> +      * to keep parent i_mutex until we finish the open to prevent races when
>> +      * somebody opens newly created by us file and locks it with a sharelock
>> +      * before we open it.
>> +      */
>> +     if (IS_SHARELOCK(dir->d_inode) && error > 0 && *opened & FILE_CREATED) {
>> +             /* Don't check for write permission, don't truncate */
>> +             open_flag &= ~O_TRUNC;
>> +             will_truncate = false;
>> +             acc_mode = MAY_OPEN;
>> +             path_to_nameidata(path, nd);
>> +
>> +             error = may_open(&nd->path, acc_mode, open_flag);
>> +             if (error) {
>> +                     mutex_unlock(&dir->d_inode->i_mutex);
>> +                     goto out;
>> +             }
>> +             file->f_path.mnt = nd->path.mnt;
>> +             error = finish_open(file, nd->path.dentry, NULL, opened);
>> +             if (error) {
>> +                     mutex_unlock(&dir->d_inode->i_mutex);
>> +                     if (error == -EOPENSTALE)
>> +                             goto stale_open;
>> +                     goto out;
>> +             }
>> +             error = sharelock_lock_file(file);
>> +             mutex_unlock(&dir->d_inode->i_mutex);
>> +             if (error)
>> +                     goto exit_fput;
>> +             goto opened;
>> +     }
>> +
>>       mutex_unlock(&dir->d_inode->i_mutex);
>
> What stops the file system changing mount flags via a remount between
> these two ?

Nothing, but it doesn't bring problems here: if the first IS_SHARELOCK
condition is true, we don't get into the second (see 'goto opened').

>
>>
>>       if (error <= 0) {
>> @@ -3034,6 +3073,18 @@ finish_open_created:
>>                       goto stale_open;
>>               goto out;
>>       }
>> +
>> +     if (IS_SHARELOCK(dir->d_inode)) {
>> +             /*
>> +              * Lock parent i_mutex to prevent races with sharelocks on
>> +              * newly created files.
>> +              */
>> +             mutex_lock(&dir->d_inode->i_mutex);
>> +             error = sharelock_lock_file(file);
>> +             mutex_unlock(&dir->d_inode->i_mutex);
>> +             if (error)
>> +                     goto exit_fput;
>> +     }
>>  opened:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-cifs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Best regards,
Pavel Shilovsky.
