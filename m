Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:43645 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223AbaAVPca convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2014 10:32:30 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar20so7057184iec.10
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jan 2014 07:32:30 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] pnfs: fix BUG in filelayout_recover_commit_reqs
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <48F6DCEE-41D4-485A-9A77-22448028EABF@primarydata.com>
Date: Wed, 22 Jan 2014 10:32:35 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <C3DA9DB9-7547-44CC-979C-0D3B6FB64651@primarydata.com>
References: <1390335693-12004-1-git-send-email-dros@primarydata.com> <429FC150-5092-415D-A411-1F4A35EAAB58@primarydata.com> <48F6DCEE-41D4-485A-9A77-22448028EABF@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 22, 2014, at 10:29 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 22, 2014, at 7:19, Weston Andros Adamson <dros@primarydata.com> wrote:
> 
>> This might actually need a CC stable, although I’m not sure of the scope. It seems like it’s been this way for a while.
>> 
> 
> I’m assuming that if/when people hit it, they will ping us and ask for a push to stable: I’m just not sure how many people are hitting it at this point.

Agreed.

-drosf

> 
> Cheers
>  Trond
> 
>> -dros
>> 
>> On Jan 21, 2014, at 3:21 PM, Weston Andros Adamson <dros@primarydata.com> wrote:
>> 
>>> cond_resched_lock(cinfo->lock) is called everywhere else while holding
>>> the cinfo->lock spinlock.  Not holding this lock while calling
>>> transfer_commit_list in filelayout_recover_commit_reqs causes the BUG
>>> below.
>>> 
>>> It's true that we can't hold this lock while calling pnfs_put_lseg,
>>> because that might try to lock the inode lock - which might be the
>>> same lock as cinfo->lock.
>>> 
>>> To reproduce, mount a 2 DS pynfs server and run an O_DIRECT command
>>> that crosses a stripe boundary and is not page aligned, such as:
>>> 
>>> dd if=/dev/zero of=/mnt/f bs=17000 count=1 oflag=direct
>>> 
>>> BUG: sleeping function called from invalid context at linux/fs/nfs/nfs4filelayout.c:1161
>>> in_atomic(): 0, irqs_disabled(): 0, pid: 27, name: kworker/0:1
>>> 2 locks held by kworker/0:1/27:
>>> #0:  (events){.+.+.+}, at: [<ffffffff810501d7>] process_one_work+0x175/0x3a5
>>> #1:  ((&dreq->work)){+.+...}, at: [<ffffffff810501d7>] process_one_work+0x175/0x3a5
>>> CPU: 0 PID: 27 Comm: kworker/0:1 Not tainted 3.13.0-rc3-branch-dros_testing+ #21
>>> Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
>>> Workqueue: events nfs_direct_write_schedule_work [nfs]
>>> 0000000000000000 ffff88007a39bbb8 ffffffff81491256 ffff88007b87a130  ffff88007a39bbd8 ffffffff8105f103 ffff880079614000 ffff880079617d40  ffff88007a39bc20 ffffffffa011603e ffff880078988b98 0000000000000000
>>> Call Trace:
>>> [<ffffffff81491256>] dump_stack+0x4d/0x66
>>> [<ffffffff8105f103>] __might_sleep+0x100/0x105
>>> [<ffffffffa011603e>] transfer_commit_list+0x94/0xf1 [nfs_layout_nfsv41_files]
>>> [<ffffffffa01160d6>] filelayout_recover_commit_reqs+0x3b/0x68 [nfs_layout_nfsv41_files]
>>> [<ffffffffa00ba53a>] nfs_direct_write_reschedule+0x9f/0x1d6 [nfs]
>>> [<ffffffff810705df>] ? mark_lock+0x1df/0x224
>>> [<ffffffff8106e617>] ? trace_hardirqs_off_caller+0x37/0xa4
>>> [<ffffffff8106e691>] ? trace_hardirqs_off+0xd/0xf
>>> [<ffffffffa00ba8f8>] nfs_direct_write_schedule_work+0x9d/0xb7 [nfs]
>>> [<ffffffff810501d7>] ? process_one_work+0x175/0x3a5
>>> [<ffffffff81050258>] process_one_work+0x1f6/0x3a5
>>> [<ffffffff810501d7>] ? process_one_work+0x175/0x3a5
>>> [<ffffffff8105187e>] worker_thread+0x149/0x1f5
>>> [<ffffffff81051735>] ? rescuer_thread+0x28d/0x28d
>>> [<ffffffff81056d74>] kthread+0xd2/0xda
>>> [<ffffffff81056ca2>] ? __kthread_parkme+0x61/0x61
>>> [<ffffffff8149e66c>] ret_from_fork+0x7c/0xb0
>>> [<ffffffff81056ca2>] ? __kthread_parkme+0x61/0x61
>>> 
>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>> ---
>>> 
>>> I'm pretty sure this is the correct approach - it certainly fixes the BUG
>>> for me.
>>> 
>>> fs/nfs/nfs4filelayout.c | 8 ++++----
>>> 1 file changed, 4 insertions(+), 4 deletions(-)
>>> 
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index 0a93e79..03fd8be 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -1216,17 +1216,17 @@ static void filelayout_recover_commit_reqs(struct list_head *dst,
>>> 	struct pnfs_commit_bucket *b;
>>> 	int i;
>>> 
>>> -	/* NOTE cinfo->lock is NOT held, relying on fact that this is
>>> -	 * only called on single thread per dreq.
>>> -	 * Can't take the lock because need to do pnfs_put_lseg
>>> -	 */
>>> +	spin_lock(cinfo->lock);
>>> 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
>>> 		if (transfer_commit_list(&b->written, dst, cinfo, 0)) {
>>> +			spin_unlock(cinfo->lock);
>>> 			pnfs_put_lseg(b->wlseg);
>>> 			b->wlseg = NULL;
>>> +			spin_lock(cinfo->lock);
>>> 		}
>>> 	}
>>> 	cinfo->ds->nwritten = 0;
>>> +	spin_unlock(cinfo->lock);
>>> }
>>> 
>>> static unsigned int
>>> -- 
>>> 1.8.3.4 (Apple Git-47)
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> Trond Myklebust
> Linux NFS client maintainer

