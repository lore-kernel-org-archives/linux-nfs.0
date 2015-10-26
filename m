Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37378 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbbJZV6g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2015 17:58:36 -0400
Date: Mon, 26 Oct 2015 17:58:36 -0400
To: Daniel J Blueman <daniel@quora.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS locking issues with 3.18.22
Message-ID: <20151026215836.GB9232@fieldses.org>
References: <CAMVG2stjz9LCvNVcnNZy9PxmOZ3wOwxr_o5Ee-ZrfNCgaFj0SA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMVG2stjz9LCvNVcnNZy9PxmOZ3wOwxr_o5Ee-ZrfNCgaFj0SA@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 24, 2015 at 03:10:52PM +0200, Daniel J Blueman wrote:
> I just wanted to report consistent server hanging I see when running
> blogbench on a NFS4 linux client (Ubuntu 15.04) running stock 4.2.4
> against a NFS4 server running stock 3.18.22 (Ubuntu Server 12.04) [1].
> 
> Thanks,
>   Daniel
> 
> -- [1]
> 

What was in the logs just before this?  Are there any earlier crashes?

It's possible this is something we've fixed since 3.18, but I can't
think of anything off the top of my head.

--b.

> [1664738.168693] Modules linked in: nfsd nfs_acl auth_rpcgss nfs
> fscache lockd sunrpc grace intel_rapl x86_pkg_temp_thermal
> intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul
> ghash_clmulni_intel aesni_intel ablk_helper joydev cryptd lrw gf128mul
> psmouse glue_helper aes_x86_64 video serio_raw bonding 8250_fintek
> mac_hid shpchp lpc_ich ie31200_edac edac_core lp parport hid_generic
> usbhid hid bcache btrfs raid10 raid456 async_raid6_recov async_pq
> raid6_pq async_xor e1000e ahci xor libahci async_memcpy async_tx ptp
> pps_core raid1 raid0 multipath linear
> [1664738.168693] CPU: 0 PID: 1649 Comm: nfsd Tainted: G      D W    L
> 3.18.22-031822-generic #201510031227
> [1664738.168694] Hardware name: Supermicro X9SCL/X9SCM/X9SCL/X9SCM,
> BIOS 2.0b 09/17/2012
> [1664738.168694] task: ffff8800c9865000 ti: ffff880401a84000 task.ti:
> ffff880401a84000
> [1664738.168696] RIP: 0010:[<ffffffff81788422>]  [<ffffffff81788422>]
> _raw_spin_lock+0x32/0x50
> [1664738.168696] RSP: 0018:ffff880401a87cb8  EFLAGS: 00000202
> [1664738.168696] RAX: 0000000000001e80 RBX: ffffffff810a8ac9 RCX:
> 000000000000bb86
> [1664738.168696] RDX: 000000000000bb8a RSI: 000000000000bb8a RDI:
> ffff88041594b530
> [1664738.168697] RBP: ffff880401a87cb8 R08: ffff880128279780 R09:
> ffff88041f001b00
> [1664738.168697] R10: ffffffffc06ab7cc R11: ffff880417cdb080 R12:
> ffffffff810a1f68
> [1664738.168698] R13: ffff880401a87c28 R14: ffff8800c9866468 R15:
> ffff88042fc13380
> [1664738.168698] FS:  0000000000000000(0000) GS:ffff88042fc00000(0000)
> knlGS:0000000000000000
> [1664738.168698] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [1664738.168699] CR2: 0000000000e99f9c CR3: 0000000001c16000 CR4:
> 00000000001407f0
> [1664738.168699] Stack:
> [1664738.168700]  ffff880401a87d48 ffffffffc06af222 ffffffffc05e5e70
> ffff880336b5f700
> [1664738.168700]  ffff880401a87d38 ffffffffc05ecf76 ffff880401a87d18
> 0000000000000708
> [1664738.168701]  ffff880417cda068 ffff880128279780 ffff88021648e020
> 0000000000000008
> [1664738.168701] Call Trace:
> [1664738.168705]  [<ffffffffc06af222>] nfsd4_sequence+0xb2/0x6b0 [nfsd]
> [1664738.168709]  [<ffffffffc05e5e70>] ?
> svcauth_unix_domain_release+0x30/0x30 [sunrpc]
> [1664738.168714]  [<ffffffffc05ecf76>] ? cache_check+0x106/0x3d0 [sunrpc]
> [1664738.168717]  [<ffffffffc06a0904>] nfsd4_proc_compound+0x4d4/0x7f0 [nfsd]
> [1664738.168719]  [<ffffffffc068ce23>] nfsd_dispatch+0xc3/0x210 [nfsd]
> [1664738.168723]  [<ffffffffc05e39f2>] ?
> svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
> [1664738.168727]  [<ffffffffc05e2940>] svc_process_common+0x440/0x6d0 [sunrpc]
> [1664738.168731]  [<ffffffffc05e2cd7>] svc_process+0x107/0x170 [sunrpc]
> [1664738.168733]  [<ffffffffc068c7a7>] nfsd+0xf7/0x160 [nfsd]
> [1664738.168735]  [<ffffffffc068c6b0>] ? nfsd_destroy+0x80/0x80 [nfsd]
> [1664738.168736]  [<ffffffff81090219>] kthread+0xc9/0xe0
> [1664738.168737]  [<ffffffff81090150>] ? kthread_create_on_node+0x180/0x180
> [1664738.168738]  [<ffffffff81788a58>] ret_from_fork+0x58/0x90
> [1664738.168739]  [<ffffffff81090150>] ? kthread_create_on_node+0x180/0x180
> [1664738.168746] Code: 89 e5 b8 00 00 02 00 f0 0f c1 07 89 c2 c1 ea 10
> 66 39 c2 75 02 5d c3 83 e2 fe 0f b7 f2 b8 00 80 00 00 eb 0c 0f 1f 44
> 00 00 f3 90 <83> e8 01 74 0a 0f b7 0f 66 39 ca 75 f1 5d c3 0f 1f 80 00
> 00 00
> [1664738.469283] Modules linked in: nfsd nfs_acl auth_rpcgss nfs
> fscache lockd sunrpc grace intel_rapl x86_pkg_temp_thermal
> intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul
> ghash_clmulni_intel aesni_intel ablk_helper joydev cryptd lrw gf128mul
> psmouse glue_helper aes_x86_64 video serio_raw bonding 8250_fintek
> mac_hid shpchp lpc_ich ie31200_edac edac_core lp parport hid_generic
> usbhid hid bcache btrfs raid10 raid456 async_raid6_recov async_pq
> raid6_pq async_xor e1000e ahci xor libahci async_memcpy async_tx ptp
> pps_core raid1 raid0 multipath linear
> [1664738.522625] CPU: 1 PID: 1651 Comm: nfsd Tainted: G      D W    L
> 3.18.22-031822-generic #201510031227
> [1664738.532099] Hardware name: Supermicro X9SCL/X9SCM/X9SCL/X9SCM,
> BIOS 2.0b 09/17/2012
> [1664738.540002] task: ffff8800c9861400 ti: ffff88040147c000 task.ti:
> ffff88040147c000
> [1664738.547735] RIP: 0010:[<ffffffff81788427>]  [<ffffffff81788427>]
> _raw_spin_lock+0x37/0x50
> [1664738.556218] RSP: 0018:ffff88040147fcb8  EFLAGS: 00000206
> [1664738.561763] RAX: 00000000000077c9 RBX: ffffffff810a8ac9 RCX:
> 000000000000bb86
> [1664738.569147] RDX: 000000000000bb88 RSI: 000000000000bb88 RDI:
> ffff88041594b530
> [1664738.576534] RBP: ffff88040147fcb8 R08: ffff88030bd3a080 R09:
> ffff88041f001b00
> [1664738.583921] R10: ffffffffc06ab7cc R11: ffff880036d54080 R12:
> ffffffff810a1f68
> [1664738.591305] R13: ffff88040147fc28 R14: ffff880418b0ee68 R15:
> ffff88042fc93380
> [1664738.598694] FS:  0000000000000000(0000) GS:ffff88042fc80000(0000)
> knlGS:0000000000000000
> [1664738.607035] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [1664738.613020] CR2: 00007f9589d5aad0 CR3: 0000000001c16000 CR4:
> 00000000001407e0
> [1664738.620406] Stack:
> [1664738.622647]  ffff88040147fd48 ffffffffc06af222 ffffffffc05e5e70
> ffff880336b5f700
> [1664738.630509]  ffff88040147fd38 ffffffffc05ecf76 ffff88040147fd18
> 0000000000000708
> [1664738.638379]  ffff880036d55068 ffff88030bd3a080 ffff8801e617a020
> 0000000000000008
> [1664738.646245] Call Trace:
> [1664738.648926]  [<ffffffffc06af222>] nfsd4_sequence+0xb2/0x6b0 [nfsd]
> [1664738.655347]  [<ffffffffc05e5e70>] ?
> svcauth_unix_domain_release+0x30/0x30 [sunrpc]
> [1664738.663174]  [<ffffffffc05ecf76>] ? cache_check+0x106/0x3d0 [sunrpc]
> [1664738.669770]  [<ffffffffc06a0904>] nfsd4_proc_compound+0x4d4/0x7f0 [nfsd]
> [1664738.676703]  [<ffffffffc068ce23>] nfsd_dispatch+0xc3/0x210 [nfsd]
> [1664738.683032]  [<ffffffffc05e39f2>] ?
> svc_tcp_adjust_wspace+0x12/0x30 [sunrpc]
> [1664738.697460]  [<ffffffffc05e2940>] svc_process_common+0x440/0x6d0 [sunrpc]
> [1664738.704489]  [<ffffffffc05e2cd7>] svc_process+0x107/0x170 [sunrpc]
> [1664738.710908]  [<ffffffffc068c7a7>] nfsd+0xf7/0x160 [nfsd]
> [1664738.716453]  [<ffffffffc068c6b0>] ? nfsd_destroy+0x80/0x80 [nfsd]
> [1664738.722779]  [<ffffffff81090219>] kthread+0xc9/0xe0
> [1664738.727891]  [<ffffffff81090150>] ? kthread_create_on_node+0x180/0x180
> [1664738.734653]  [<ffffffff81788a58>] ret_from_fork+0x58/0x90
> [1664738.740285]  [<ffffffff81090150>] ? kthread_create_on_node+0x180/0x180
> [1664738.747048] Code: 02 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 c2 75 02
> 5d c3 83 e2 fe 0f b7 f2 b8 00 80 00 00 eb 0c 0f 1f 44 00 00 f3 90 83
> e8 01 74 0a <0f> b7 0f 66 39 ca 75 f1 5d c3 0f 1f 80 00 00 00 00 eb da
> 66 0f
> -- 
> Daniel J Blueman
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
