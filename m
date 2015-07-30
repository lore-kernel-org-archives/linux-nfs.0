Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35194 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbG3NSP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:18:15 -0400
Message-ID: <55BA2404.3000200@gmail.com>
Date: Thu, 30 Jul 2015 21:17:56 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 4/9 v8] fs: New helper legitimize_mntget() for getting
 a legitimize mnt
References: <55B5A012.1030006@gmail.com>	<55B5A0B0.7060604@gmail.com> <20150729120604.4512c2e5@noble>
In-Reply-To: <20150729120604.4512c2e5@noble>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/29/2015 10:06, NeilBrown wrote:
> On Mon, 27 Jul 2015 11:08:32 +0800 Kinglong Mee <kinglongmee@gmail.com>
> wrote:
> 
>> New helper legitimize_mntget for getting a mnt without setting
>> MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED, otherwise return NULL.
>>
>> v8, same as v6
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/namespace.c        | 19 +++++++++++++++++++
>>  include/linux/mount.h |  1 +
>>  2 files changed, 20 insertions(+)
>>
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index 2b8aa15..842cf57 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -1153,6 +1153,25 @@ struct vfsmount *mntget(struct vfsmount *mnt)
>>  }
>>  EXPORT_SYMBOL(mntget);
>>  
>> +struct vfsmount *legitimize_mntget(struct vfsmount *vfsmnt)
>> +{
>> +	struct mount *mnt;
>> +
>> +	if (vfsmnt == NULL)
>> +		return NULL;
>> +
>> +	read_seqlock_excl(&mount_lock);
>> +	mnt = real_mount(vfsmnt);
>> +	if (vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED))
>> +		vfsmnt = NULL;
>> +	else
>> +		mnt_add_count(mnt, 1);
>> +	read_sequnlock_excl(&mount_lock);
>> +
>> +	return vfsmnt;
>> +}
>> +EXPORT_SYMBOL(legitimize_mntget);
>> +
>>  struct vfsmount *mnt_clone_internal(struct path *path)
>>  {
>>  	struct mount *p;
>> diff --git a/include/linux/mount.h b/include/linux/mount.h
>> index f822c3c..8ae9dc0 100644
>> --- a/include/linux/mount.h
>> +++ b/include/linux/mount.h
>> @@ -79,6 +79,7 @@ extern void mnt_drop_write(struct vfsmount *mnt);
>>  extern void mnt_drop_write_file(struct file *file);
>>  extern void mntput(struct vfsmount *mnt);
>>  extern struct vfsmount *mntget(struct vfsmount *mnt);
>> +extern struct vfsmount *legitimize_mntget(struct vfsmount *vfsmnt);
>>  extern struct vfsmount *mnt_clone_internal(struct path *path);
>>  extern int __mnt_is_readonly(struct vfsmount *mnt);
>>  
> 
> It is unfortunate that we seem to have to take the mount_lock global
> lock on every nfs request.  I wonder if we can avoid that....
> 
> What if we did:
> 
>   seq = 0;
> retry:
>   read_seqbegin_or_lock(&mount_lock, &seq);
>   if (vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED))
>       vfsmnt = NULL;
>   else if (need_seqretry(&mount_lock, seq);
>       goto retry;
>   else {
> 	mnt_add_count(&mnt, 1);
>         if (need_seqretry(&mount_lock, seq) ||
> 	    vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT |
>                                  MNT_DOOMED)) {
>              mnt_add_count(&mnt, -1);
>              goto retry;
>         }
>    }
>    done_seqretry(&mount_lock, seq);

I don't really understand the seqlock, I will have a check about it.

> 
> 
> Is there any risk from having a temporarily elevated mnt_count there?
> I can't see one, but there is clearly some complexity in managing that
> count.

Yes, it's more complex than the above patch.
But, if it can avoid taking the mount_lock every nfs request, I'd like it.
I will test it later.

thanks,
Kinglong Mee
