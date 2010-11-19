Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24562 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889Ab0KSP1p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 10:27:45 -0500
Subject: Re: [PATCH] SQUASHME: pnfs: move synchronize_rcu out side of spin_lock
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <4CE55FFE.5070607@panasas.com>
Date: Fri, 19 Nov 2010 10:27:29 -0500
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Message-Id: <78D70EF0-5A5B-4FE0-9093-7E4B0CC32ED8@netapp.com>
References: <1290015704-6221-1-git-send-email-bhalevy@panasas.com> <4CE51FBA.6060806@panasas.com> <4CE55FFE.5070607@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 18, 2010, at 12:18 PM, Benny Halevy wrote:

> On 2010-11-18 14:44, Boaz Harrosh wrote:
>> On 11/17/2010 07:41 PM, Benny Halevy wrote:
>>> squash into 4a28356  pnfs: CB_NOTIFY_DEVICEID
>>> 
>>> We currently call pnfs_unhash_deviceid under spin_lock c->dc_lock
>>> But pnfs_unhash_deviceid calls synchronize_rcu which may sched.
>>> This resulted in the following BUG with the cthon tests:
>>> 
>>> Nov 17 18:54:56 tl1 kernel: BUG: spinlock wrong CPU on CPU#1, test5/2170
>>> Nov 17 18:54:56 tl1 kernel: lock: ffff880070559ff0, .magic: dead4ead, .owner: test5/2170, .owner_cpu: 0
>>> Nov 17 18:54:56 tl1 kernel: Pid: 2170, comm: test5 Not tainted 2.6.37-rc2-pnfs #167
>>> Nov 17 18:54:56 tl1 kernel: Call Trace:
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff8122cfc5>] spin_bug+0x9c/0xa3
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff8122d042>] do_raw_spin_unlock+0x76/0x8d
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff814534ea>] _raw_spin_unlock+0x2b/0x30
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffffa03c62fc>] pnfs_put_deviceid+0x59/0x64 [nfs]
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffffa0018551>] filelayout_free_lseg+0x5a/0x6f [nfs_layout_nfsv41_files]
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffffa03c6ea8>] pnfs_free_lseg_list+0x4e/0x8b [nfs]
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffffa03c85a4>] _pnfs_return_layout+0xe3/0x213 [nfs]
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffffa039bcb2>] nfs4_evict_inode+0x41/0x74 [nfs]
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff8112cab6>] evict+0x27/0x97
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff8112d051>] iput+0x20c/0x243
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff8112476c>] do_unlinkat+0x11c/0x16f
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff81118750>] ? fsnotify_modify+0x66/0x6e
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff81452cbe>] ? lockdep_sys_exit_thunk+0x35/0x67
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff810a0b51>] ? audit_syscall_entry+0x11e/0x14a
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff811247d5>] sys_unlink+0x16/0x18
>>> Nov 17 18:54:56 tl1 kernel: [<ffffffff8100acf2>] system_call_fastpath+0x16/0x1b
>>> 
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> fs/nfs/pnfs.c |    5 ++---
>>> 1 files changed, 2 insertions(+), 3 deletions(-)
>>> 
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 559fcce..39c7d9f 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1651,7 +1651,6 @@ pnfs_unhash_deviceid(struct pnfs_deviceid_cache *c,
>>> 	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
>>> 		if (!memcmp(&d->de_id, id, sizeof(*id))) {
>>> 			hlist_del_rcu(&d->de_node);
>>> -			synchronize_rcu();
>>> 			return d;
>>> 		}
>>> 
>>> @@ -1672,7 +1671,7 @@ pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
>>> 
>>> 	pnfs_unhash_deviceid(c, &devid->de_id);
>>> 	spin_unlock(&c->dc_lock);
>>> -
>>> +	synchronize_rcu();
>>> 	c->dc_free_callback(devid);
>>> }
>>> EXPORT_SYMBOL_GPL(pnfs_put_deviceid);
>>> @@ -1686,7 +1685,7 @@ pnfs_delete_deviceid(struct pnfs_deviceid_cache *c,
>>> 	spin_lock(&c->dc_lock);
>>> 	devid = pnfs_unhash_deviceid(c, id);
>>> 	spin_unlock(&c->dc_lock);
>>> -
>>> +	synchronize_rcu();
>>> 	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
>>> 	if (atomic_dec_and_test(&devid->de_ref))
>>> 		c->dc_free_callback(devid);
>> 
>> OK, so I don't like this fix because before we only synchronize_rcu()
>> after an actual hlist_del_rcu. 
>> 
>> If we look at the two callers
>> 
>>  ()
>> 	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
>> 		return;
>> 
>> 	pnfs_unhash_deviceid(c, &devid->de_id);
>> 	spin_unlock(&c->dc_lock);
>> 
>>  pnfs_delete_deviceid
>>  	spin_lock(&c->dc_lock);
>>  	devid = pnfs_unhash_deviceid(c, id);
>>  	spin_unlock(&c->dc_lock);
>> 
>> 
>> The pnfs_put_deviceid does an atomic_dec_and_lock so not to race with
>> pnfs_find_get_deviceid. But in pnfs_find_get_deviceid we do atomic_inc_not_zero
>> so we don't need that we can change pnfs_put_deviceid to just atomic_dec_and_test
>> and then take the lock inside pnfs_unhash_deviceid, and remove from callers.
>> Some thing like below. (Untested, only compiled)
> 
> OK, that makes sense, BUT
> If pnfs_find_get_deviceid can see de_ref==0 it's racing with pnfs_put_deviceid
> which is about to free the structure - i.e. pnfs_find_get_deviceid may cause
> use after free bugs.
> So I'm confused if the current scheme works at all.
> 
> Andy, it seems to me this optimization is a bit premature
> and we'd be better off reverting to using simple spin locks rather the
> rcu locks, certainly until we have a good testing infrastructure
> for cb_notifydeviceid.  I'm not sure how much we're saving anyhow.

from rfc5661
   NOTIFY4_DEVICEID_DELETE
      Deletes a device ID from the mappings.  This notification MUST NOT
      be sent if the client has a layout that refers to the device ID.
      In other words, if the server is sending a delete device ID
      notification, one of the following is true for layouts associated
      with the layout type:

      *  The client never had a layout referring to that device ID.

      *  The client has returned all layouts referring to that device
         ID.

      *  The server has revoked all layouts referring to that device ID.

In our current implementation, when the client has no layout segments referencing a device ID, it has been removed. So, what is gained by using NOTIFY_DEVICEID_DELETE?

I see NOTIFY_DEVICEID4_CHANGE as useful. But I would treat it as an error case - very unlikely to happen. When it does happen, all I/0  using the deviceID needs to be drained, and new i/o stopped with associated rpc tasks put to sleep.  Same for LAYOUTGETs. Then the state manager should be run to remap the deviceid,  then wake up the rpc tasks. When only the state manager can access the deviceid list, this problem goes away.

The current code - nfs4_callback_devicenotify - tries to remove the deviceid from the list. What it should be doing is checking to make sure that the deviceid is already gone, because the client is not supposed to be holding any layouts that reference it.

-->Andy

> 
> Benny
> 
>> 
>> ---
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 61310c7..5d4e14d 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1598,16 +1598,21 @@ pnfs_unhash_deviceid(struct pnfs_deviceid_cache *c,
>> {
>> 	struct pnfs_deviceid_node *d;
>> 	struct hlist_node *n;
>> -	long h = nfs4_deviceid_hash(id);
>> +	long h;
>> +
>> +	spin_lock(&c->dc_lock);
>> +	h = nfs4_deviceid_hash(id);
>> 
>> 	dprintk("%s hash %ld\n", __func__, h);
>> 	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
>> 		if (!memcmp(&d->de_id, id, sizeof(*id))) {
>> 			hlist_del_rcu(&d->de_node);
>> +			spin_unlock(&c->dc_lock);
>> 			synchronize_rcu();
>> 			return d;
>> 		}
>> 
>> +	spin_unlock(&c->dc_lock);
>> 	return NULL;
>> }
>> 
>> @@ -1620,11 +1625,10 @@ pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
>> 		  struct pnfs_deviceid_node *devid)
>> {
>> 	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
>> -	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
>> +	if (!atomic_dec_and_test(&devid->de_ref))
>> 		return;
>> 
>> 	pnfs_unhash_deviceid(c, &devid->de_id);
>> -	spin_unlock(&c->dc_lock);
>> 
>> 	c->dc_free_callback(devid);
>> }
>> @@ -1636,9 +1640,7 @@ pnfs_delete_deviceid(struct pnfs_deviceid_cache *c,
>> {
>> 	struct pnfs_deviceid_node *devid;
>> 
>> -	spin_lock(&c->dc_lock);
>> 	devid = pnfs_unhash_deviceid(c, id);
>> -	spin_unlock(&c->dc_lock);
>> 
>> 	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
>> 	if (atomic_dec_and_test(&devid->de_ref))
>> 
>> 

