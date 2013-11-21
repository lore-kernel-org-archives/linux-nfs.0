Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f41.google.com ([74.125.83.41]:33111 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab3KUHAg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Nov 2013 02:00:36 -0500
Received: by mail-ee0-f41.google.com with SMTP id t10so3299928eei.28
        for <linux-nfs@vger.kernel.org>; Wed, 20 Nov 2013 23:00:35 -0800 (PST)
Message-ID: <528DAF90.6000702@primarydata.com>
Date: Thu, 21 Nov 2013 09:00:32 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: chenditang <chendt.fnst@cn.fujitsu.com>, Benny Halevy <bhalevy@tonian.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfsd-file: cause oops when stop the nfs server
References: <51517A15.3010805@cn.fujitsu.com> <51776397.2050504@cn.fujitsu.com> <5242FA2F.1000302@primarydata.com> <20131120164053.GA16928@infradead.org>
In-Reply-To: <20131120164053.GA16928@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-11-20 18:40, Christoph Hellwig wrote:
> On Wed, Sep 25, 2013 at 10:58:55AM -0400, Benny Halevy wrote:
>> Chenditang, I see that this patch was never subimtted upstream.
>> Is there anything specific to pnfs that causes this bug?
> 
> It's not.  I've just reproduced it without pnfs, by shutting down
> the server after running xfstests over a NFSv4.1 mount.
> 

This should be covered by this patch:
http://git.linux-nfs.org/?p=bfields/linux.git;a=commitdiff;h=e50a26d

>> The fix itself is completely generic
>> and if so can be back-ported to stable since v3.8

So is e50a26d

Benny

>>
>> Thanks,
>>
>> Benny
>>
>> On 2013-04-24 00:46, chenditang wrote:
>>> mount nfs dir in the client, and then restart the NFS service in MDS,
>>> that will cause oops for client_mutex_owner is NULL in the
>>> destroy_client() function.
>>>
>>> kernel BUG at fs/nfsd/nfs4state.c:1130!
>>> invalid opcode: 0000 [#1] SMP
>>> Modules linked in: nfsd(OF) lockd exportfs nfs_acl auth_rpcgss autofs4
>>> dlm sctp libcrc32c configfs sunrpc be2iscsi iscsi_boot_sysfs bnx2i cnic
>>> uio cxgb4i cxgb4 cxgb3i libcxgbi cxgb3 mdio ib_iser rdma_cm ib_cm iw_cm
>>> ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi
>>> scsi_transport_iscsi dm_mirror dm_region_hash dm_log dm_mod ppdev
>>> parport_pc parport microcode pcspkr i2c_piix4 i2c_core e1000 sg ext4(F)
>>> mbcache(F) jbd2(F) sr_mod(F) cdrom(F) sd_mod(F) crc_t10dif(F)
>>> pata_acpi(F) ata_generic(F) ata_piix(F) ahci(F) libahci(F) [last
>>> unloaded: speedstep_lib]
>>> CPU 0
>>> Pid: 2893, comm: nfsd Tainted: GF O 3.8.0-rc4_fl+ #2 innotek GmbH
>>> VirtualBox/VirtualBox
>>> RIP: 0010:[<ffffffffa045a4cf>] [<ffffffffa045a4cf>]
>>> destroy_client+0x2ff/0x330 [nfsd]
>>> RSP: 0018:ffff8800256b9d38 EFLAGS: 00010203
>>> RAX: 0000000000000010 RBX: ffff880025630000 RCX: 0000000000001440
>>> RDX: 00000000000025fc RSI: 0000000000000082 RDI: 0000000000000246
>>> RBP: ffff8800256b9d88 R08: ffffffff81cdfba0 R09: 0000000000007768
>>> R10: 00000000000001b1 R11: 00000000000001b1 R12: ffff880037988400
>>> R13: ffff88003d58ea80 R14: ffffffff81ab2080 R15: 0000000000000000
>>> FS: 0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
>>> CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>> CR2: 00000000006d39d8 CR3: 00000000255be000 CR4: 00000000000006f0
>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Process nfsd (pid: 2893, threadinfo ffff8800256b8000, task ffff88003d58ea80)
>>> Stack:
>>> ffff8800256b9d78 ffff88003d51bdc0 ffff8800256b9d58 ffff880037988400
>>> ffffffff81ab2080 ffff880037988400 0000000000000020 ffffffffa04709b0
>>> ffffffff81ab2080 0000000000000000 ffff8800256b9dc8 ffffffffa045a555
>>> Call Trace:
>>> [<ffffffffa045a555>] nfs4_state_destroy_net+0x55/0x120 [nfsd]
>>> [<ffffffffa045a718>] nfs4_state_shutdown_net+0xf8/0x140 [nfsd]
>>> [<ffffffffa04349b0>] ? nfsd_pool_stats_release+0x50/0x50 [nfsd]
>>> [<ffffffffa0434835>] nfsd_shutdown_net+0x35/0x60 [nfsd]
>>> [<ffffffffa04348ad>] nfsd_last_thread+0x4d/0x80 [nfsd]
>>> [<ffffffffa037f3e5>] svc_shutdown_net+0x35/0x40 [sunrpc]
>>> [<ffffffffa0434935>] nfsd_destroy+0x55/0x80 [nfsd]
>>> [<ffffffffa0434ab4>] nfsd+0x104/0x130 [nfsd]
>>> [<ffffffffa04349b0>] ? nfsd_pool_stats_release+0x50/0x50 [nfsd]
>>> [<ffffffff8107951e>] kthread+0xce/0xe0
>>> [<ffffffff81079450>] ? kthread_freezable_should_stop+0x70/0x70
>>> [<ffffffff8155c56c>] ret_from_fork+0x7c/0xb0
>>> [<ffffffff81079450>] ? kthread_freezable_should_stop+0x70/0x70
>>> Code: 38 d1 e0 48 89 df e8 81 38 d1 e0 e9 2f ff ff ff 0f 1f 40 00 48 c7
>>> c7 72 8a 46 a0 31 c0 e8 86 6b 0f e1 e9 70 fd ff ff 0f 0b eb fe <0f> 0b
>>> eb fe 0f 0b 66 66 2e 0f 1f 84 00 00 00 00 00 eb f3 0f 0b
>>> RIP [<ffffffffa045a4cf>] destroy_client+0x2ff/0x330 [nfsd]
>>> RSP <ffff8800256b9d38>
>>> ---[ end trace c2d9f251eabc7c2d ]---
>>>
>>> Signed-off-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
>>> Reviewed-by: fanchaoting <fanchaoting@cn.fujitsu.com>
>>> ---
>>> fs/nfsd/nfs4state.c | 3 +++
>>> 1 file changed, 3 insertions(+)
>>>
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index 13bc266..40b2348 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -4936,6 +4936,8 @@ nfs4_state_destroy_net(struct net *net)
>>> struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>> struct rb_node *node, *tmp;
>>>
>>> + nfs4_lock_state();
>>> +
>>> for (i = 0; i < CLIENT_HASH_SIZE; i++) {
>>> while (!list_empty(&nn->conf_id_hashtbl[i])) {
>>> clp = list_entry(nn->conf_id_hashtbl[i].next, struct nfs4_client,
>>> cl_idhash);
>>> @@ -4952,6 +4954,7 @@ nfs4_state_destroy_net(struct net *net)
>>> destroy_client(clp);
>>> }
>>>
>>> + nfs4_unlock_state();
>>> kfree(nn->sessionid_hashtbl);
>>> kfree(nn->lockowner_ino_hashtbl);
>>> kfree(nn->ownerstr_hashtbl);
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> ---end quoted text---
> 
