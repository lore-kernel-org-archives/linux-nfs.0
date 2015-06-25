Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36531 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbFYOO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:14:57 -0400
Message-ID: <558C0CD2.609@gmail.com>
Date: Thu, 25 Jun 2015 22:14:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 3/6 v5] fs_pin: Kill fs_pin under a reference of vfsmnt
References: <5581266C.9080404@gmail.com> <558126FA.8050608@gmail.com> <20150619202916.GE21903@fieldses.org>
In-Reply-To: <20150619202916.GE21903@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/20/2015 4:29 AM, J. Bruce Fields wrote:
> On Wed, Jun 17, 2015 at 03:51:22PM +0800, Kinglong Mee wrote:
>> v5, new patch
> 
> I don't know this code at all.  I'll try to give it a proper review.
> But could you help me by explaining in some detail what this is doing
> and why you're sure it's correct?

Sorry for my misunderstand of your means in version 4.
I have make a new version as, 

When reference of cahce_head increase(>1), grab a reference of mnt once.
and  reference decrease to 1 (==1), drop the reference of mnt.

So after that,
When ref > 1, user cannot umount the filesystem with -EBUSY.
when ref ==1, means cache only reference by nfsd cache,
no other reference. So user can try umount, 
1. before set MNT_UMOUNT (protected by mount_lock), nfsd cache is
   referenced (ref > 1, legitimize_mntget), umount will fail with -EBUSY.
2. after set MNT_UMOUNT, nfsd cache is referenced (ref == 2),
   legitimize_mntget will fail, and set cache to CACHE_NEGATIVE,
   and the reference will be dropped, re-back to 1.
   So, pin_kill can delete the cache and umount success.
3. when umountting, no reference to nfsd cache, 
   pin_kill can delete the cache and umount success.

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/namespace.c | 10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index 1b9e111..3f08a48 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -1049,8 +1049,6 @@ static void cleanup_mnt(struct mount *mnt)
>>  	 * so mnt_get_writers() below is safe.
>>  	 */
>>  	WARN_ON(mnt_get_writers(mnt));
>> -	if (unlikely(mnt->mnt_pins.first))
>> -		mnt_pin_kill(mnt);
>>  	fsnotify_vfsmount_delete(&mnt->mnt);
>>  	dput(mnt->mnt.mnt_root);
>>  	deactivate_super(mnt->mnt.mnt_sb);
>> @@ -1078,6 +1076,7 @@ static DECLARE_DELAYED_WORK(delayed_mntput_work, delayed_mntput);
>>  
>>  static void mntput_no_expire(struct mount *mnt)
>>  {
>> +put_again:
>>  	rcu_read_lock();
>>  	mnt_add_count(mnt, -1);
>>  	if (likely(mnt->mnt_ns)) { /* shouldn't be the last one */
>> @@ -1090,6 +1089,13 @@ static void mntput_no_expire(struct mount *mnt)
>>  		unlock_mount_hash();
>>  		return;
>>  	}
>> +	if (unlikely(mnt->mnt_pins.first)) {
>> +		mnt_add_count(mnt, 1);
>> +		rcu_read_unlock();
>> +		unlock_mount_hash();
>> +		mnt_pin_kill(mnt);
>> +		goto put_again;
>> +	}
>>  	if (unlikely(mnt->mnt.mnt_flags & MNT_DOOMED)) {
>>  		rcu_read_unlock();
>>  		unlock_mount_hash();
>> -- 
>> 2.4.3
> .
> 
