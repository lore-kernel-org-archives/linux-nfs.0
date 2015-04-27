Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35744 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247AbbD0MLz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2015 08:11:55 -0400
Received: by pdbqd1 with SMTP id qd1so126641255pdb.2
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2015 05:11:55 -0700 (PDT)
Message-ID: <553E2784.6020906@gmail.com>
Date: Mon, 27 Apr 2015 20:11:48 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
References: <553663B7.7030506@gmail.com>	<20150421215417.GE13782@fieldses.org>	<553781E2.1000900@gmail.com>	<20150422150703.GA1247@fieldses.org>	<20150423094431.1a8aa68b@notabene.brown>	<5538EB18.7080802@gmail.com> <20150424130045.6bbdb2f9@notabene.brown>
In-Reply-To: <20150424130045.6bbdb2f9@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/24/2015 11:00 AM, NeilBrown wrote:
> On Thu, 23 Apr 2015 20:52:40 +0800 Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> On 4/23/2015 7:44 AM, NeilBrown wrote:
>>> On Wed, 22 Apr 2015 11:07:03 -0400 "J. Bruce Fields" <bfields@fieldses.org>
>>> wrote:
>>>>> Reference of dentry/mnt is like a cache, avoids re-finding of them,
>>>>> it is necessary to store them in svc_export.
>>>>>
>>>>> Neil points out another way of 'fs_pin', I will check that.
>>>>
>>>> Yes, that'd be interesting.  On a very quick look--I don't understand
>>>> what it's meant to do at all.  But if it does provide a way to get a
>>>> callback on umount, that'd certainly be interesting....
>>>
>>> Yeah, on a quick look it isn't really obvious at all.
>>>
>>> But I didn't read the code.  I read
>>>  https://lwn.net/Articles/636730/
>>>
>>> which says:
>>>
>>>     In its place is a mechanism by which an object can be added to a vfsmount
>>>     structure (which represents a mounted filesystem); that object supports 
>>>     only one method: kill(). These "pin" objects hang around until the final
>>>     reference to the vfsmount goes away, at which point each one's kill() function
>>>     is called. It thus is a clean mechanism for performing cleanup when a filesystem
>>>     goes away.
>>>
>>> This is used to close "BSD process accounting" files on umount, and sound
>>> like the perfect interface for flushing things from the sunrpc cache on
>>> umount.
>>
>> I have review those codes in fs/fs_pin.c and kernel/acct.c.
>> 'fs_pin' is used to fix the race between file->f_path.mnt for acct
>> and umount, file->f_path.mnt just holds the reference of vfsmount
>> but not keep busy, umount will check the reference and return busy.
>>
>> The logical is same as sunrpc cache for exports.
>>
>> Before commit 3064c3563b ("death to mnt_pinned"), acct uses a hack
>> method, acct get a pin to vfsmount and then put the reference,
>> so umount finds no other reference and callback those pins in vfsmount,
>> at last umount success.
>>
>> After that commit, besides pin to original vfsmount and put the reference
>> of the original vfsmount, acct clone the vfsmount storing in file->f_path.mnt.
>>
>> The different between those two methods is the value of file->f_path.mnt,
>> the first one, it contains the original vfsmnt without reference,
>> the second one, contains a cloned vfsmnt with reference.
>>
>> I have test the first method, pins to vfsmount for all exports cache,
>> nfsd can work but sometimes will delay or hang at rpc.mountd's calling
>> of name_to_handle_at, I can't find the reason.
> 
> A kernel stack trace of exactly where it is hanging would help a lot.

Witch adding fs_pin to exports, it seems there is a mutex race between
nfsd and rpc.mountd for locking parent inode.

Apr 27 19:57:03 ntest kernel: rpc.mountd      D ffff88006ac5fc28     0  1152      1 0x00000000
Apr 27 19:57:03 ntest kernel: ffff88006ac5fc28 ffff880068c38970 ffff880068c3de60 ffff88006ac5fc08
Apr 27 19:57:03 ntest kernel: ffff88006ac60000 ffff880035ecf694 ffff880068c3de60 00000000ffffffff
Apr 27 19:57:03 ntest kernel: ffff880035ecf698 ffff88006ac5fc48 ffffffff8177ffd7 0000000000000000
Apr 27 19:57:03 ntest kernel: Call Trace:
Apr 27 19:57:03 ntest kernel: [<ffffffff8177ffd7>] schedule+0x37/0x90
Apr 27 19:57:03 ntest kernel: [<ffffffff8178031e>] schedule_preempt_disabled+0xe/0x10
Apr 27 19:57:03 ntest kernel: [<ffffffff81781e92>] __mutex_lock_slowpath+0xb2/0x120
Apr 27 19:57:03 ntest kernel: [<ffffffff81781f23>] mutex_lock+0x23/0x40
Apr 27 19:57:03 ntest kernel: [<ffffffff81230714>] lookup_slow+0x34/0xc0
Apr 27 19:57:03 ntest kernel: [<ffffffff812358ee>] path_lookupat+0x89e/0xc60
Apr 27 19:57:03 ntest kernel: [<ffffffff81205192>] ? kmem_cache_alloc+0x1e2/0x260
Apr 27 19:57:03 ntest kernel: [<ffffffff812367a6>] ? getname_flags+0x56/0x200
Apr 27 19:57:03 ntest kernel: [<ffffffff81235cd7>] filename_lookup+0x27/0xc0
Apr 27 19:57:03 ntest kernel: [<ffffffff81237b53>] user_path_at_empty+0x63/0xd0
Apr 27 19:57:03 ntest kernel: [<ffffffff8121d722>] ? put_object+0x32/0x60
Apr 27 19:57:03 ntest kernel: [<ffffffff8121d94d>] ? delete_object_full+0x2d/0x40
Apr 27 19:57:03 ntest kernel: [<ffffffff8123e273>] ? dput+0x33/0x230
Apr 27 19:57:03 ntest kernel: [<ffffffff81237bd1>] user_path_at+0x11/0x20
Apr 27 19:57:03 ntest kernel: [<ffffffff81286489>] SyS_name_to_handle_at+0x59/0x200
Apr 27 19:57:03 ntest kernel: [<ffffffff81783f6e>] system_call_fastpath+0x12/0x71
Apr 27 19:57:03 ntest kernel: nfsd            S ffff88006e92b708     0  1170      2 0x00000000
Apr 27 19:57:03 ntest kernel: ffff88006e92b708 ffffffff81c12480 ffff88006acbcb80 ffff88006e92b758
Apr 27 19:57:03 ntest kernel: ffff88006e92c000 ffffffff82290040 ffff88006e92b758 ffffffff82290040
Apr 27 19:57:03 ntest kernel: 00000000fffffff5 ffff88006e92b728 ffffffff8177ffd7 0000000100043a09
Apr 27 19:57:03 ntest kernel: Call Trace:
Apr 27 19:57:03 ntest kernel: [<ffffffff8177ffd7>] schedule+0x37/0x90
Apr 27 19:57:03 ntest kernel: [<ffffffff81782e97>] schedule_timeout+0x117/0x230
Apr 27 19:57:03 ntest kernel: [<ffffffff8110b240>] ? internal_add_timer+0xb0/0xb0
Apr 27 19:57:03 ntest kernel: [<ffffffff81780ff3>] wait_for_completion_interruptible_timeout+0xf3/0x150
Apr 27 19:57:03 ntest kernel: [<ffffffff810cb090>] ? wake_up_state+0x20/0x20
Apr 27 19:57:03 ntest kernel: [<ffffffffa01350cc>] cache_wait_req.isra.10+0x9c/0x110 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0134760>] ? sunrpc_init_cache_detail+0xc0/0xc0 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0135c54>] cache_check+0x1d4/0x380 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffff8133248c>] ? inode_doinit_with_dentry+0x48c/0x6a0
Apr 27 19:57:03 ntest kernel: [<ffffffffa045e132>] exp_get_by_name+0x82/0xb0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffff81776d0a>] ? kmemleak_free+0x3a/0xa0
Apr 27 19:57:03 ntest kernel: [<ffffffff81332210>] ? inode_doinit_with_dentry+0x210/0x6a0
Apr 27 19:57:03 ntest kernel: [<ffffffff813326bc>] ? selinux_d_instantiate+0x1c/0x20
Apr 27 19:57:03 ntest kernel: [<ffffffff8123def7>] ? _d_rehash+0x37/0x40
Apr 27 19:57:03 ntest kernel: [<ffffffff8123f776>] ? d_splice_alias+0xa6/0x2d0
Apr 27 19:57:03 ntest kernel: [<ffffffff812be90b>] ? ext4_lookup+0xdb/0x160
Apr 27 19:57:03 ntest kernel: [<ffffffffa0460114>] rqst_exp_get_by_name+0x64/0x140 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045a8f6>] nfsd_cross_mnt+0x76/0x1b0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0475300>] nfsd4_encode_dirent+0x160/0x3d0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa04751a0>] ? nfsd4_encode_getattr+0x40/0x40 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045c631>] nfsd_readdir+0x1c1/0x2a0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045a1e0>] ? nfsd_direct_splice_actor+0x20/0x20 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa046bd70>] nfsd4_encode_readdir+0x120/0x220 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa047573d>] nfsd4_encode_operation+0x7d/0x190 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa046a51d>] nfsd4_proc_compound+0x24d/0x6f0 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0455f83>] nfsd_dispatch+0xc3/0x220 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa012a01b>] svc_process_common+0x43b/0x690 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa012b133>] svc_process+0x103/0x1b0 [sunrpc]
Apr 27 19:57:03 ntest kernel: [<ffffffffa045596f>] nfsd+0xff/0x170 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffffa0455870>] ? nfsd_destroy+0x80/0x80 [nfsd]
Apr 27 19:57:03 ntest kernel: [<ffffffff810bd378>] kthread+0xd8/0xf0
Apr 27 19:57:03 ntest kernel: [<ffffffff810bd2a0>] ? kthread_worker_fn+0x180/0x180
Apr 27 19:57:03 ntest kernel: [<ffffffff81784362>] ret_from_fork+0x42/0x70
Apr 27 19:57:03 ntest kernel: [<ffffffff810bd2a0>] ? kthread_worker_fn+0x180/0x180

>>
>> Also test the second method, there are many problem caused by the cloned
>> vfsmount, mnt_clone_internal() change mnt_root values to the path dentry.
>>
>> Those cases are tested for all exports cache, but, I think nfsd should
>> put the reference of vfsmount when finding exports upcall fail.
>> The success exports cache should also take it.
>>
>> The following is a draft of the first method.
> 
> I think the first method sounds a lot better than the second.
> 
>>
>> thanks,
>> Kinglong Mee
>>
>> ----------------------------------------------------------------------
>> diff --git a/fs/fs_pin.c b/fs/fs_pin.c
>> index 611b540..553e8b1 100644
>> --- a/fs/fs_pin.c
>> +++ b/fs/fs_pin.c
>> @@ -17,6 +17,7 @@ void pin_remove(struct fs_pin *pin)
>>  	wake_up_locked(&pin->wait);
>>  	spin_unlock_irq(&pin->wait.lock);
>>  }
>> +EXPORT_SYMBOL(pin_remove);
>>  
>>  void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head *p)
>>  {
>> @@ -26,11 +27,13 @@ void pin_insert_group(struct fs_pin *pin, struct vfsmount *m, struct hlist_head
>>  	hlist_add_head(&pin->m_list, &real_mount(m)->mnt_pins);
>>  	spin_unlock(&pin_lock);
>>  }
>> +EXPORT_SYMBOL(pin_insert_group);
>>  
>>  void pin_insert(struct fs_pin *pin, struct vfsmount *m)
>>  {
>>  	pin_insert_group(pin, m, &m->mnt_sb->s_pins);
>>  }
>> +EXPORT_SYMBOL(pin_insert);
>>  
>>  void pin_kill(struct fs_pin *p)
>>  {
>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>> index c3e3b6e..3e3df8c 100644
>> --- a/fs/nfsd/export.c
>> +++ b/fs/nfsd/export.c
>> @@ -309,7 +309,7 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
>>  static void svc_export_put(struct kref *ref)
>>  {
>>  	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
>> -	path_put(&exp->ex_path);
>> +	pin_remove(&exp->ex_pin);
>>  	auth_domain_put(exp->ex_client);
>>  	nfsd4_fslocs_free(&exp->ex_fslocs);
>>  	kfree(exp->ex_uuid);
>> @@ -695,15 +695,26 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
>>  		orig->ex_path.mnt == new->ex_path.mnt;
>>  }
>>  
>> +static void export_pin_kill(struct fs_pin *pin)
>> +{
>> +	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
>> +
>> +	write_lock(&exp->cd->hash_lock);
>> +	cache_mark_expired(&exp->h);
>> +	pin_remove(pin);
>> +	write_unlock(&exp->cd->hash_lock);
>> +}
> 
> I think you need to add some sort of delay here.  The svc_export entry might
> still be in active use by an nfsd thread and you need to wait for that to
> complete.
> 
> I think you need to wait for the refcnt to drop to '1'.  Maybe create a
> global wait_queue to wait for that.
> 
> Actually... svc_expkey contains a reference to a 'path' too, so you need to
> use pinning to purge those when the filesystem is unmounted.
> 
> Oh.. and you don't want to call 'pin_remove' from export_pin_kill().  It is
> called from svc_export_put() and calling from both could be problematic.
> 
> Hmmm...  Ahhhh.
> 
> If you get export_pin_kill to only call cache_mark_expired() (maybe move the
> locking into that function) and *not* call pin_remove(), then the pin will
> remain on the list and ->done will be -1.
> So mnt_pin_kill will loop around and this time pin_kill() will wait for
> p->done to be set.
> So we really need that thing to be removed from cache promptly.  I don't
> think we can wait for the next time cache_clean will be run.  We could
> call cache_flush, but I think I'd rather remove just that one entry.
> 
> Also.... this requires that the pin (and the struct containing it) be freed
> using RCU.
> 
> So:
>  - add an rcu_head to svc_export and svc_expkey
>  - use rcu_kfree to free both those objects
>  - write a 'cache_force_expire()' which sets the expiry time, and then
>    removes the entry from the cache.
>  - Use pin_insert_group rather then mntget for both svc_export and svc_expkey
>  - have the 'kill' functions for both call cache_force_expire(), but *not*
>    pin_remove

Thanks very much for your comment in great detail.
I will send a patch after fix the above race and basic tests. 

thanks,
Kinglong Mee

> 
>> +
>>  static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
>>  {
>>  	struct svc_export *new = container_of(cnew, struct svc_export, h);
>>  	struct svc_export *item = container_of(citem, struct svc_export, h);
>>  
>> +	init_fs_pin(&new->ex_pin, export_pin_kill);
>>  	kref_get(&item->ex_client->ref);
>>  	new->ex_client = item->ex_client;
>>  	new->ex_path = item->ex_path;
>> -	path_get(&item->ex_path);
>> +	pin_insert_group(&new->ex_pin, new->ex_path.mnt, NULL);
> 
> This doesn't look right.  path_get does a 'mntget()' and a 'dget()'.
> You are replacing 'mntget()' with 'pin_insert_group()', but I think you still
> need the dget().
> 
> Similarly you need a dput() up where you removed path_put().
> 
> 
> Thanks for working on this!
> 
> NeilBrown
> 
> 
> 
>>  	new->ex_fslocs.locations = NULL;
>>  	new->ex_fslocs.locations_count = 0;
>>  	new->ex_fslocs.migrated = 0;
>> diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
>> index 1f52bfc..718a27e 100644
>> --- a/fs/nfsd/export.h
>> +++ b/fs/nfsd/export.h
>> @@ -4,6 +4,7 @@
>>  #ifndef NFSD_EXPORT_H
>>  #define NFSD_EXPORT_H
>>  
>> +#include <linux/fs_pin.h>
>>  #include <linux/sunrpc/cache.h>
>>  #include <uapi/linux/nfsd/export.h>
>>  
>> @@ -49,6 +50,7 @@ struct svc_export {
>>  	struct auth_domain *	ex_client;
>>  	int			ex_flags;
>>  	struct path		ex_path;
>> +	struct fs_pin		ex_pin;
>>  	kuid_t			ex_anon_uid;
>>  	kgid_t			ex_anon_gid;
>>  	int			ex_fsid;
>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>> index 437ddb6..6936684 100644
>> --- a/include/linux/sunrpc/cache.h
>> +++ b/include/linux/sunrpc/cache.h
>> @@ -206,6 +206,11 @@ static inline int cache_is_expired(struct cache_detail *detail, struct cache_hea
>>  		(detail->flush_time > h->last_refresh);
>>  }
>>  
>> +static inline void cache_mark_expired(struct cache_head *h)
>> +{
>> +	h->expiry_time = seconds_since_boot() - 1;
>> +}
>> +
>>  extern int cache_check(struct cache_detail *detail,
>>  		       struct cache_head *h, struct cache_req *rqstp);
>>  extern void cache_flush(void);
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
