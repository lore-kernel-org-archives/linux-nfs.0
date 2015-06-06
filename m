Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:35872 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbbFFNuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jun 2015 09:50:24 -0400
Message-ID: <5572F7BE.2070300@gmail.com>
Date: Sat, 06 Jun 2015 21:38:06 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>, kinglongmee@gmail.com
Subject: Re: [PATCH 5/5] nfsd: allows user un-mounting filesystem where nfsd
 exports base on
References: <5561E7E4.50604@gmail.com> <5561E9FA.4050808@gmail.com> <20150605150213.GV7232@ZenIV.linux.org.uk> <20150606022158.GZ7232@ZenIV.linux.org.uk>
In-Reply-To: <20150606022158.GZ7232@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/6/2015 10:21 AM, Al Viro wrote:
> On Fri, Jun 05, 2015 at 04:02:13PM +0100, Al Viro wrote:
>> On Sun, May 24, 2015 at 11:10:50PM +0800, Kinglong Mee wrote:
>>> --- a/fs/nfsd/export.c
>>> +++ b/fs/nfsd/export.c
>>> @@ -43,9 +43,9 @@ static void expkey_put(struct kref *ref)
>>>  
>>>  	if (test_bit(CACHE_VALID, &key->h.flags) &&
>>>  	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
>>> -		path_put(&key->ek_path);
>>> +		path_put_unpin(&key->ek_path, &key->ek_pin);
>>>  	auth_domain_put(key->ek_client);
>>> -	kfree(key);
>>> +	kfree_rcu(key, rcu_head);
>>>  }
>>
>> That looks wrong.  OK, so you want umount() to proceed; fine, no problem
>> with that.  However, what happens if the final mntput() hits while you
>> are just approaching that path_put_unpin()?  ->kill() will be triggered,
>> and it would bloody better
>> 	a) make sure that expkey_put() is called for that key if it hadn't
>> already been done and
>> 	b) do not return until such expkey_put() completes.  Including the
>> ones that might have been already entered by the time we'd got to ->kill().

You are right.
Sorry for my fault, the above patch misses caring the race.

>>
>> Am I missing something subtle here?
> 
> Having looked through that code...  It *is* wrong.  Note that the normal
> approach is to have pin_remove() called via pin_kill(), directly or triggered
> from group_pin_kill() and/or cleanup_mnt() on the mount it's attached to.
> pin_remove() should never be called outside of ->kill() callbacks.  It should
> be called at the point where you are OK with fs being shut down.

Thank you very much for your comments.
I will try to using fs_pin as the restrict.

> 
> The fundamental reason why it's broken is different, though - you *can't*
> grab a reference if all you've got is a pin.  By the time the callback is
> called, the mount in question is already irretrievably committed to being
> killed.  There's one hell of a wide window between the point of no return
> and the point where you are notified of anything, and that's by design -
> you might very well have had several mounts doomed by a syscall and they
> all get through cleanup_mnt() just before return to userland.  One by one.
> So between the point where this puppy is doomed and the call of your callback
> there might have been several filesystems going through shutdown, with tons
> of IO, waiting for remote servers, etc.
> 
> We could add a primitive that would _try_ to grab a reference - that can
> be done (lock_mount_hash(), check if it has MNT_DOOMED or MNT_SYNC_UMOUNT,
> fail if it does, otherwise mnt_add_count(mnt, 1) and succeed, doing
> unlock_mount_hash() on both exit paths).  HOWEVER, you'll need to think
> very carefully where to use that primitive - unlike mntget() it _can_
> fail and lock_mount_hash() can inflict quite a bit of cacheline pingpong
> if used heavily.

Do you mean adding a new feature?

> 
> Could you give details on lifecycle of those objects, including the stages
> at which we might try to grab references?  Combination of such primitive with
> a pin (doing just "NULL the references to vfsmount/dentry, do dput() on
> what that dentry used to be and call pin_remove()") might work, if the
> lifecycle is good enough.

NFSD has two caches named expkey and export which are managed by sunrpc cache
fundamental. I will only explain export following for expkey is similar as export.

struct cache_head {
	struct kref     ref;
	... ... 
};
struct svc_export {
	struct cache_head       h;
	struct path             ex_path;
	... ...
};

1. svc_export has a reference, will be freed when the reference is decreased to zero.
2. ex_path must be put when freed (Want change mntget to fs_pin for ex_path's vfsmnt).
3. With fs_pin, there are two logic (one is the normal logic, the other is pin_kill)
   which can cause free svc_export.
4. The reference of the normal logic is zero, but the pin_kill logic is not zero.
   the second logic will decrease the reference indirectly, if decrease to zero, 
   umount will go though the normal logic's code, at last frees the svc_export;
   if not zero, umount must don't free the svc_export.

I try to solve the window as,
struct svc_export {
	struct cache_head       h;
	struct path             ex_path;
	... ...
	struct fs_pin           ex_pin;
        struct rcu_head         rcu_head;

        /* For cache_put and fs umounting window */
        struct completion       ex_done;
        struct work_struct      ex_work;
};

1. ex_done is for umount waiting the reference is decreased to zero.
2. ex_work is for umount decrease the reference indirectly.
3. The normal logic don't free the svc_export, calls complete() and
   go though pin_kill() logic as,
   (svc_export_put will be called when reference is decreased to zero)
   
   static void svc_export_put(struct kref *ref)
   {
          struct svc_export *exp = container_of(ref, struct svc_export, h.ref);

          rcu_read_lock();
          complete(&exp->ex_done);
          pin_kill(&exp->ex_pin);
   }

4. pin_kill() logic will schedules to decrease the reference though ex_work,
   and at last path_put_unpin and destroy the svc_export.

   static void export_pin_kill(struct fs_pin *pin)
   {
          struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);

          if (!completion_done(&exp->ex_done)) {
                  schedule_work(&exp->ex_work);
                  wait_for_completion(&exp->ex_done);
          }
          path_put_unpin(&exp->ex_path, &exp->ex_pin);
          svc_export_destroy(exp);
   }

The full patches will be sent later. Thanks again.

thanks,
Kinglong Mee
