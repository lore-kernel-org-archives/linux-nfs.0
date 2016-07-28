Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932516AbcG1QBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2016 12:01:34 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EB45A13D16
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2016 16:01:33 +0000 (UTC)
Received: from [10.10.60.145] (vpn-60-145.rdu2.redhat.com [10.10.60.145])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u6SG1W0b008932
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2016 12:01:33 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: rmmod nfs popped BUG: unable to handle kernel paging request once..
Date: Thu, 28 Jul 2016 12:03:20 -0400
Message-ID: <DBE30EEE-934A-4A83-8CAF-FCE25059B735@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just popped these on a kernel with lots of printks I was working on.. 
though nothing modified in the rpc code.

I admit to unloading and loading these modules many many times on this 
boot cycle.

Did a 'rmmod blocklayoutdriver nfsv4 nfs', and got this:

[527285.455102] nfs4blocklayout_exit: NFSv4 Block Layout Driver 
Unregistering...
[527285.455929] pnfs_unregister_layoutdriver Deregistering id:5
[527285.456554] pnfs_unregister_layoutdriver Deregistering id:3
[527285.477422] Key type id_resolver unregistered
[527285.477786] Key type id_legacy unregistered
[527286.625331] BUG: unable to handle kernel paging request at 
ffffffffc0216024
[527286.626028] IP: [<ffffffffc01383a3>] call_refresh+0x33/0x60 [sunrpc]
[527286.626628] PGD 1c09067 PUD 1c0b067 PMD 508c6067 PTE 0
[527286.627147] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[527286.627555] Modules linked in: cts(E) rpcsec_gss_krb5(E) 
dns_resolver(E) xfs(E) libcrc32c(E) crc32c_intel(E) virtio_balloon(E) 
nfsd(E) nfs_acl(E) lockd(E) auth_rpcgss(E) grace(E) sunrpc(E) virtio_net 
virtio_scsi virtio_blk cirrus drm_kms_helper ttm drm virtio_pci 
ata_generic virtio_ring pata_acpi virtio [last unloaded: nfs]
[527286.630415] CPU: 0 PID: 29806 Comm: kworker/0:3 Tainted: G           
  E   4.7.0-rc7+ #65
[527286.631130] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.8.2-20150714_191134- 04/01/2014
[527286.631979] Workqueue: rpciod rpc_async_schedule [sunrpc]
[527286.632477] task: ffff8800509d8040 ti: ffff88000b718000 task.ti: 
ffff88000b718000
[527286.633141] RIP: 0010:[<ffffffffc01383a3>]  [<ffffffffc01383a3>] 
call_refresh+0x33/0x60 [sunrpc]
[527286.633939] RSP: 0018:ffff88000b71bd98  EFLAGS: 00010246
[527286.634414] RAX: ffffffffc0216000 RBX: ffff88001a2a2ac0 RCX: 
dead000000000200
[527286.635048] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 
ffff88001a2a2ac0
[527286.635666] RBP: ffff88000b71bda0 R08: ffff88001a2a2b08 R09: 
0000000000000000
[527286.636104] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffffffffc0138370
[527286.636531] R13: ffffffffc0138370 R14: 0000000000000000 R15: 
ffff88001a2a2b00
[527286.636948] FS:  0000000000000000(0000) GS:ffff88007f800000(0000) 
knlGS:0000000000000000
[527286.637420] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[527286.637750] CR2: ffffffffc0216024 CR3: 0000000058fe8000 CR4: 
00000000001406f0
[527286.638156] Stack:
[527286.638280]  ffff88001a2a2ac0 ffff88000b71be08 ffffffffc01441b1 
0001880000000000
[527286.638737]  ffff88001a2a2af0 ffff88007f818080 ffff88007f818080 
0000000000000000
[527286.639192]  0000000041e7793b ffff88001dfba948 ffff88007f817880 
ffff88007f821a00
[527286.639650] Call Trace:
[527286.639803]  [<ffffffffc01441b1>] __rpc_execute+0x91/0x460 [sunrpc]
[527286.640166]  [<ffffffffc0144592>] rpc_async_schedule+0x12/0x20 
[sunrpc]
[527286.640545]  [<ffffffff810bfbbf>] process_one_work+0x15f/0x410
[527286.640881]  [<ffffffff810bfebe>] worker_thread+0x4e/0x480
[527286.641196]  [<ffffffff810bfe70>] ? process_one_work+0x410/0x410
[527286.641540]  [<ffffffff810bfe70>] ? process_one_work+0x410/0x410
[527286.642685]  [<ffffffff810c5858>] kthread+0xd8/0xf0
[527286.643773]  [<ffffffff810a49fa>] ? 
copy_process.part.33+0xada/0x1950
[527286.644945]  [<ffffffff817cc67f>] ret_from_fork+0x1f/0x40
[527286.646193]  [<ffffffff810c5780>] ? kthread_worker_fn+0x170/0x170
[527286.647368] Code: 88 03 00 02 55 48 89 e5 53 48 89 fb 75 29 48 8b 83 
a8 00 00 00 48 c7 43 20 d0 83 13 c0 48 89 df c7 43 04 00 00 00 00 48 8b 
40 58 <83> 40 24 01 e8 e4 fa 00 00 5b 5d c3 0f b7 b7 d8 00 00 00 8b 4f
[527286.650625] RIP  [<ffffffffc01383a3>] call_refresh+0x33/0x60 
[sunrpc]
[527286.651814]  RSP <ffff88000b71bd98>
[527286.652841] CR2: ffffffffc0216024
[527286.655618] ---[ end trace b88f234f4de2dcb0 ]---
[527286.656741] BUG: unable to handle kernel paging request at 
ffffffffffffffd8
[527286.658083] IP: [<ffffffff810c5f10>] kthread_data+0x10/0x20
[527286.659367] PGD 1c09067 PUD 1c0b067 PMD 0
[527286.660589] Oops: 0000 [#2] SMP DEBUG_PAGEALLOC
[527286.661850] Modules linked in: cts(E) rpcsec_gss_krb5(E) 
dns_resolver(E) xfs(E) libcrc32c(E) crc32c_intel(E) virtio_balloon(E) 
nfsd(E) nfs_acl(E) lockd(E) auth_rpcgss(E) grace(E) sunrpc(E) virtio_net 
virtio_scsi virtio_blk cirrus drm_kms_helper ttm drm virtio_pci 
ata_generic virtio_ring pata_acpi virtio [last unloaded: nfs]
[527286.666334] CPU: 0 PID: 29806 Comm: kworker/0:3 Tainted: G      D    
  E   4.7.0-rc7+ #65
[527286.667680] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.8.2-20150714_191134- 04/01/2014
[527286.669132] task: ffff8800509d8040 ti: ffff88000b718000 task.ti: 
ffff88000b718000
[527286.670462] RIP: 0010:[<ffffffff810c5f10>]  [<ffffffff810c5f10>] 
kthread_data+0x10/0x20
[527286.672011] RSP: 0018:ffff88000b71ba48  EFLAGS: 00010002
[527286.673196] RAX: 0000000000000000 RBX: ffff88007f818080 RCX: 
0000000000000000
[527286.674492] RDX: ffff88007f414008 RSI: ffff8800509d80c0 RDI: 
ffff8800509d8040
[527286.675973] RBP: ffff88000b71ba48 R08: ffff8800509d80e8 R09: 
0000000000000000
[527286.677242] R10: 00000000000003ab R11: ffff8800509d80c0 R12: 
0000000000018080
[527286.678476] R13: 0000000000000000 R14: ffff8800509d8040 R15: 
ffff88007f818080
[527286.679676] FS:  0000000000000000(0000) GS:ffff88007f800000(0000) 
knlGS:0000000000000000
[527286.680942] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[527286.682062] CR2: 0000000000000028 CR3: 0000000058fe8000 CR4: 
00000000001406f0
[527286.683260] Stack:
[527286.684205]  ffff88000b71ba58 ffffffff810c095e ffff88000b71baa8 
ffffffff817c7eb8
[527286.685477]  ffff88000b71bac0 ffff8800509d8040 ffff8800509d84d0 
ffff88000b71c000
[527286.686775]  ffff88000b71baf8 ffff88000b71baf8 ffff88000b71b640 
ffff88000b71b640
[527286.688277] Call Trace:
[527286.689225]  [<ffffffff810c095e>] wq_worker_sleeping+0xe/0x90
[527286.690344]  [<ffffffff817c7eb8>] __schedule+0x4c8/0x730
[527286.691429]  [<ffffffff817c8155>] schedule+0x35/0x80
[527286.692483]  [<ffffffff810aa8bd>] do_exit+0x78d/0xb00
[527286.693543]  [<ffffffff810306fc>] oops_end+0x9c/0xd0
[527286.694595]  [<ffffffff81067eaa>] no_context+0x13a/0x380
[527286.695653]  [<ffffffff810e1cc7>] ? find_busiest_group+0x47/0x4c0
[527286.696749]  [<ffffffff81068171>] __bad_area_nosemaphore+0x81/0x1c0
[527286.698089]  [<ffffffff810682c4>] bad_area_nosemaphore+0x14/0x20
[527286.699177]  [<ffffffff81068660>] __do_page_fault+0xc0/0x4d0
[527286.700246]  [<ffffffff81068b33>] trace_do_page_fault+0x43/0x130
[527286.701339]  [<ffffffffc0138370>] ? call_retry_reserve+0x50/0x50 
[sunrpc]
[527286.702485]  [<ffffffffc0138370>] ? call_retry_reserve+0x50/0x50 
[sunrpc]
[527286.703621]  [<ffffffff81062c2a>] do_async_page_fault+0x1a/0xa0
[527286.704840]  [<ffffffff817ce658>] async_page_fault+0x28/0x30
[527286.706029]  [<ffffffffc0138370>] ? call_retry_reserve+0x50/0x50 
[sunrpc]
[527286.707173]  [<ffffffffc0138370>] ? call_retry_reserve+0x50/0x50 
[sunrpc]
[527286.708310]  [<ffffffffc01383a3>] ? call_refresh+0x33/0x60 [sunrpc]
[527286.709376]  [<ffffffff8102c752>] ? __switch_to+0x2a2/0x4c0
[527286.710427]  [<ffffffffc01441b1>] __rpc_execute+0x91/0x460 [sunrpc]
[527286.711494]  [<ffffffffc0144592>] rpc_async_schedule+0x12/0x20 
[sunrpc]
[527286.712569]  [<ffffffff810bfbbf>] process_one_work+0x15f/0x410
[527286.713681]  [<ffffffff810bfebe>] worker_thread+0x4e/0x480
[527286.714878]  [<ffffffff810bfe70>] ? process_one_work+0x410/0x410
[527286.716188]  [<ffffffff810bfe70>] ? process_one_work+0x410/0x410
[527286.717229]  [<ffffffff810c5858>] kthread+0xd8/0xf0
[527286.718205]  [<ffffffff810a49fa>] ? 
copy_process.part.33+0xada/0x1950
[527286.719246]  [<ffffffff817cc67f>] ret_from_fork+0x1f/0x40
[527286.720209]  [<ffffffff810c5780>] ? kthread_worker_fn+0x170/0x170
[527286.721185] Code: cf 48 89 e7 e8 d2 35 70 00 e9 55 ff ff ff e8 b8 05 
fe ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 8b 87 30 05 00 00 55 48 
89 e5 <48> 8b 40 d8 5d c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00
[527286.724315] RIP  [<ffffffff810c5f10>] kthread_data+0x10/0x20
[527286.725260]  RSP <ffff88000b71ba48>
[527286.726070] CR2: ffffffffffffffd8
[527286.726859] ---[ end trace b88f234f4de2dcb1 ]---
