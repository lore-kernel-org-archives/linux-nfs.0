Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9968 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753833Ab0IUSnS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Sep 2010 14:43:18 -0400
Message-ID: <4C98FCC3.50803@panasas.com>
Date: Tue, 21 Sep 2010 20:43:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: pnfs-all-latest client crash
References: <20100921164211.GK26473@fieldses.org>
In-Reply-To: <20100921164211.GK26473@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-21 18:42, J. Bruce Fields wrote:
> I get the following on pnfs-all-latest, while doing a non-pnfs 4.1 mount.

Bruce, can you please provide you .config file?
>From the registers value it's possible the calldata is used
after free...

Benny

> 
> --b.
> 
> 
> general protection fault: 0000 [#1] PREEMPT 
> last sysfs file: /sys/devices/virtio-pci/virtio2/net/eth0/broadcast
> CPU 0 
> Modules linked in: [last unloaded: scsi_wait_scan]
> 
> Pid: 393, comm: rpciod/0 Not tainted 2.6.35-rc3-pnfs-00552-gcb432c0 #281 /Bochs
> RIP: 0010:[<ffffffff81232080>]  [<ffffffff81232080>] nfs41_sequence_done+0x130/0x280
> RSP: 0018:ffff88001f74dd00  EFLAGS: 00010202
> RAX: ffff88001c848888 RBX: ffff88001e4a6268 RCX: ffffffff820b4fa8
> RDX: 6b6b6b6b6b6b6b6b RSI: ffff88001e4a6248 RDI: ffff88001e4a6268
> RBP: ffff88001f74dd20 R08: ffffffff82627230 R09: 0000000000000000
> R10: 0000000000000246 R11: 00000000000002f4 R12: 6b6b6b6b6b6b6b6b
> R13: 6b6b6b6b6b6b6c9b R14: 0000000000000000 R15: ffff88001f74dfd8
> FS:  0000000000000000(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fb11ba73000 CR3: 000000001e1cb000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process rpciod/0 (pid: 393, threadinfo ffff88001f74c000, task ffff88001f58a090)
> Stack:
>  ffff88001e4a6248 ffff88001e8fc078 ffff88001dd88988 0000000000000000
> <0> ffff88001f74dd50 ffffffff812327f8 ffff88001f74ddc0 ffff88001e8fc078
> <0> ffff88001e8fc0e8 0000000000000001 ffff88001f74dd70 ffffffff8190cb0c
> Call Trace:
>  [<ffffffff812327f8>] nfs4_reclaim_complete_done+0x38/0xf0
>  [<ffffffff8190cb0c>] rpc_exit_task+0x2c/0x60
>  [<ffffffff8190d322>] __rpc_execute+0xa2/0x270
>  [<ffffffff8190d520>] ? rpc_async_schedule+0x0/0x20
>  [<ffffffff8190d535>] rpc_async_schedule+0x15/0x20
>  [<ffffffff81052f65>] worker_thread+0x225/0x410
>  [<ffffffff81052f15>] ? worker_thread+0x1d5/0x410
>  [<ffffffff8102f891>] ? get_parent_ip+0x11/0x50
>  [<ffffffff81057810>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff81052d40>] ? worker_thread+0x0/0x410
>  [<ffffffff81057376>] kthread+0x96/0xa0
>  [<ffffffff810030b4>] kernel_thread_helper+0x4/0x10
>  [<ffffffff819737fe>] ? restore_args+0x0/0x30
>  [<ffffffff810572e0>] ? kthread+0x0/0xa0
>  [<ffffffff810030b0>] ? kernel_thread_helper+0x0/0x10
> Code: 00 00 e9 21 ff ff ff 0f 1f 40 00 48 8b 03 0f b6 d2 48 c1 e2 02 48 03 90 88 00 00 00 4c 8b a0 30 03 00 00 4d 8d ac 24 30 01 00 00 <83> 02 01 4c 89 ef 4c 8b 73 10 e8 c1 07 74 00 4d 39 b4 24 68 01 
> RIP  [<ffffffff81232080>] nfs41_sequence_done+0x130/0x280
>  RSP <ffff88001f74dd00>
> ---[ end trace d38b2385ab1bfea0 ]---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
