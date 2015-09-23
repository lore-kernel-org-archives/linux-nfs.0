Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34048 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbIWI1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 04:27:45 -0400
Received: by padhy16 with SMTP id hy16so34556051pad.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 01:27:44 -0700 (PDT)
Subject: Re: [PATCH v2] NFS41: make close wait for layoutreturn
To: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
References: <1442892922-10834-1-git-send-email-tao.peng@primarydata.com>
 <56025A7D.2060207@gmail.com> <56025AE6.6020808@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <56026273.8040707@gmail.com>
Date: Wed, 23 Sep 2015 16:27:31 +0800
MIME-Version: 1.0
In-Reply-To: <56025AE6.6020808@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I find the inode returned from nfs_igrab_and_active is NULL
in _nfs4_proc_delegreturn(),

        data->inode = nfs_igrab_and_active(inode);

So that, NFS_I(inode) causes the panic.

thanks,
Kinglong Mee

On 9/23/2015 15:55, Kinglong Mee wrote:
> On 9/23/2015 15:53, Kinglong Mee wrote:
>> Hi Tao, 
>>
>> I meet a panic with this patch on 4.3.0-rc2 from linus's tree every time,
> 
> The export is ,
> /nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash,crossmnt,pnfs,fsid=0)
> 
> /nfs/pnfs is mounted an XFS filesystem which supports block layout.
> 
> thanks,
> Kinglong Mee 
> 
>>
>> # mount -t nfs nfs-server:/ /mnt  <------ a nfs4.2 mount
>> # cat /mnt/test1
>> # echo sdfsdijfd > /mnt/test2
>> # umount /mnt                     <----- panic here
>>
>> [  391.565636] BUG: unable to handle kernel paging request at ffffffffffffffe0
>> [  391.565667] IP: [<ffffffffa04fc019>] nfs4_delegreturn_prepare+0x19/0x70 [nfsv4]
>> [  391.565696] PGD 1c14067 PUD 1c16067 PMD 0
>> [  391.565711] Oops: 0000 [#1]
>> [  391.565721] Modules linked in: blocklayoutdriver(OE) nfsv4(OE) nfs(OE) fscache(E) xfs libcrc32c btrfs ppdev coretemp crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel nfsd xor raid6_pq vmw_balloon auth_rpcgss nfs_acl lockd parport_pc vmw_vmci parport shpchp i2c_piix4 grace sunrpc vmwgfx drm_kms_helper ttm drm serio_raw mptspi e1000 scsi_transport_spi mptscsih ata_generic mptbase pata_acpi [last unloaded: fscache]
>> [  391.567216] CPU: 0 PID: 498 Comm: kworker/0:1H Tainted: G           OE   4.3.0-rc2+ #257
>> [  391.567672] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
>> [  391.568586] Workqueue: rpciod rpc_async_schedule [sunrpc]
>> [  391.569038] task: ffff8800362bc8c0 ti: ffff880075264000 task.ti: ffff880075264000
>> [  391.569505] RIP: 0010:[<ffffffffa04fc019>]  [<ffffffffa04fc019>] nfs4_delegreturn_prepare+0x19/0x70 [nfsv4]
>> [  391.570441] RSP: 0018:ffff880075267cc0  EFLAGS: 00010282
>> [  391.570910] RAX: ffffffffa052e700 RBX: ffff880041235000 RCX: 0000000000000001
>> [  391.571379] RDX: ffff8800362bcfd0 RSI: ffff880041235000 RDI: 0000000000000000
>> [  391.571833] RBP: ffff880075267cd0 R08: 0000000000000000 R09: 0000000000942000
>> [  391.572332] R10: ffff8800362bc8c0 R11: ffff880075267d78 R12: ffff880069da5600
>> [  391.572739] R13: ffff88007ff49d00 R14: ffffffffa00881b0 R15: ffff880069da5688
>> [  391.573142] FS:  0000000000000000(0000) GS:ffffffff81c29000(0000) knlGS:0000000000000000
>> [  391.573552] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  391.573964] CR2: ffffffffffffffe0 CR3: 0000000041095000 CR4: 00000000001406f0
>> [  391.574413] Stack:
>> [  391.574819]  ffff880069da5600 ffffffffa00881b0 ffff880075267ce0 ffffffffa00881c3
>> [  391.575283]  ffff880075267d48 ffffffffa0089e44 0000000000010000 ffff880069da5670
>> [  391.575711]  0000000000000292 ffffffff810a37fd 0000000100000000 00000000512aefa5
>> [  391.576137] Call Trace:
>> [  391.576560]  [<ffffffffa00881b0>] ? __rpc_atrun+0x20/0x20 [sunrpc]
>> [  391.576996]  [<ffffffffa00881c3>] rpc_prepare_task+0x13/0x20 [sunrpc]
>> [  391.577432]  [<ffffffffa0089e44>] __rpc_execute+0x94/0x3f0 [sunrpc]
>> [  391.577919]  [<ffffffff810a37fd>] ? process_one_work+0x16d/0x4c0
>> [  391.578521]  [<ffffffffa008a1b5>] rpc_async_schedule+0x15/0x20 [sunrpc]
>> [  391.579180]  [<ffffffff810a38ac>] process_one_work+0x21c/0x4c0
>> [  391.579886]  [<ffffffff810a37fd>] ? process_one_work+0x16d/0x4c0
>> [  391.580495]  [<ffffffff810a3b9a>] worker_thread+0x4a/0x440
>> [  391.581051]  [<ffffffff810a3b50>] ? process_one_work+0x4c0/0x4c0
>> [  391.581484]  [<ffffffff810a3b50>] ? process_one_work+0x4c0/0x4c0
>> [  391.581901]  [<ffffffff810a8da5>] kthread+0xf5/0x110
>> [  391.582307]  [<ffffffff810a8cb0>] ? kthread_create_on_node+0x240/0x240
>> [  391.582760]  [<ffffffff8172d01f>] ret_from_fork+0x3f/0x70
>> [  391.583152]  [<ffffffff810a8cb0>] ? kthread_create_on_node+0x240/0x240
>> [  391.583584] Code: f5 75 e6 48 89 df e8 67 2f b8 ff eb dc 0f 1f 44 00 00 0f 1f 44 00 00 55 48 89 e5 41 54 49 89 fc 53 48 8b be d8 01 00 00 48 89 f3 <48> 83 7f e0 00 74 11 4c 89 e6 e8 c8 df 02 00 84 c0 74 05 5b 41
>> [  391.584794] RIP  [<ffffffffa04fc019>] nfs4_delegreturn_prepare+0x19/0x70 [nfsv4]
>> [  391.585186]  RSP <ffff880075267cc0>
>> [  391.585561] CR2: ffffffffffffffe0
>>
>> thanks,
>> Kinglong Mee
>>
>> On 9/22/2015 11:35, Peng Tao wrote:
>>> If we send a layoutreturn asynchronously before close, the close
>>> might reach server first and layoutreturn would fail with BADSTATEID
>>> because there is nothing keeping the layout stateid alive.
>>>
>>> Also do not pretend sending layoutreturn if we are not.
>>>
>>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>>> ---
>>> v2: grab lo refcount when doing ROC
>>>
>>>  fs/nfs/nfs4proc.c | 17 +++++++++++++++++
>>>  fs/nfs/pnfs.c     | 35 +++++++++++++++++++++++++----------
>>>  fs/nfs/pnfs.h     |  7 +++++++
>>>  3 files changed, 49 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 693b903..05f2da4 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -2645,6 +2645,15 @@ out:
>>>  	return err;
>>>  }
>>>  
>>> +static bool
>>> +nfs4_wait_on_layoutreturn(struct inode *inode, struct rpc_task *task)
>>> +{
>>> +	if (!nfs_have_layout(inode))
>>> +		return false;
>>> +
>>> +	return pnfs_wait_on_layoutreturn(inode, task);
>>> +}
>>> +
>>>  struct nfs4_closedata {
>>>  	struct inode *inode;
>>>  	struct nfs4_state *state;
>>> @@ -2763,6 +2772,11 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
>>>  		goto out_no_action;
>>>  	}
>>>  
>>> +	if (nfs4_wait_on_layoutreturn(inode, task)) {
>>> +		nfs_release_seqid(calldata->arg.seqid);
>>> +		goto out_wait;
>>> +	}
>>> +
>>>  	if (calldata->arg.fmode == 0)
>>>  		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
>>>  	if (calldata->roc)
>>> @@ -5308,6 +5322,9 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
>>>  
>>>  	d_data = (struct nfs4_delegreturndata *)data;
>>>  
>>> +	if (nfs4_wait_on_layoutreturn(d_data->inode, task))
>>> +		return;
>>> +
>>>  	if (d_data->roc)
>>>  		pnfs_roc_get_barrier(d_data->inode, &d_data->roc_barrier);
>>>  
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index ba12464..8abe271 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1104,20 +1104,15 @@ bool pnfs_roc(struct inode *ino)
>>>  			mark_lseg_invalid(lseg, &tmp_list);
>>>  			found = true;
>>>  		}
>>> -	/* pnfs_prepare_layoutreturn() grabs lo ref and it will be put
>>> -	 * in pnfs_roc_release(). We don't really send a layoutreturn but
>>> -	 * still want others to view us like we are sending one!
>>> -	 *
>>> -	 * If pnfs_prepare_layoutreturn() fails, it means someone else is doing
>>> -	 * LAYOUTRETURN, so we proceed like there are no layouts to return.
>>> -	 *
>>> -	 * ROC in three conditions:
>>> +	/* ROC in two conditions:
>>>  	 * 1. there are ROC lsegs
>>>  	 * 2. we don't send layoutreturn
>>> -	 * 3. no others are sending layoutreturn
>>>  	 */
>>> -	if (found && !layoutreturn && pnfs_prepare_layoutreturn(lo))
>>> +	if (found && !layoutreturn) {
>>> +		/* lo ref dropped in pnfs_roc_release() */
>>> +		pnfs_get_layout_hdr(lo);
>>>  		roc = true;
>>> +	}
>>>  
>>>  out_noroc:
>>>  	spin_unlock(&ino->i_lock);
>>> @@ -1172,6 +1167,26 @@ void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
>>>  	spin_unlock(&ino->i_lock);
>>>  }
>>>  
>>> +bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
>>> +{
>>> +	struct nfs_inode *nfsi = NFS_I(ino);
>>> +        struct pnfs_layout_hdr *lo;
>>> +        bool sleep = false;
>>> +
>>> +	/* we might not have grabbed lo reference. so need to check under
>>> +	 * i_lock */
>>> +        spin_lock(&ino->i_lock);
>>> +        lo = nfsi->layout;
>>> +        if (lo && test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
>>> +                sleep = true;
>>> +        spin_unlock(&ino->i_lock);
>>> +
>>> +        if (sleep)
>>> +                rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
>>> +
>>> +        return sleep;
>>> +}
>>> +
>>>  /*
>>>   * Compare two layout segments for sorting into layout cache.
>>>   * We want to preferentially return RW over RO layouts, so ensure those
>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>> index 78c9351..d1990e9 100644
>>> --- a/fs/nfs/pnfs.h
>>> +++ b/fs/nfs/pnfs.h
>>> @@ -270,6 +270,7 @@ bool pnfs_roc(struct inode *ino);
>>>  void pnfs_roc_release(struct inode *ino);
>>>  void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>>>  void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier);
>>> +bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task);
>>>  void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
>>>  void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
>>>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>>> @@ -639,6 +640,12 @@ pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
>>>  {
>>>  }
>>>  
>>> +static inline bool
>>> +pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
>>> +{
>>> +	return false;
>>> +}
>>> +
>>>  static inline void set_pnfs_layoutdriver(struct nfs_server *s,
>>>  					 const struct nfs_fh *mntfh, u32 id)
>>>  {
>>>
>>
> 
