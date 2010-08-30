Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56081 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756078Ab0H3R5w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 13:57:52 -0400
Date: Mon, 30 Aug 2010 13:57:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: krb5 problems in 2.6.36
Message-ID: <20100830175728.GA18764@fieldses.org>
References: <20100828170953.GB5104@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100828170953.GB5104@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 28, 2010 at 01:09:53PM -0400, J. Bruce Fields wrote:
> As of a17c2153d2e271b0cbacae9bed83b0eaa41db7e1 "SUNRPC: Move the bound
> cred to struct rpc_rqst" the NFS server crashes when using krb5.
> 
> I don't have good errors--I'll get some--but what I've seen suggests
> maybe a use-after-free of an rpc client on rpc_pipefs operations by
> gssd?

Here's an example.

--b.

Aug 30 13:55:07 plink1 kernel: ------------[ cut here ]------------
Aug 30 13:55:07 plink1 kernel: WARNING: at lib/list_debug.c:30 __list_add+0x8f/0xa0()
Aug 30 13:55:07 plink1 kernel: Hardware name: Bochs
Aug 30 13:55:07 plink1 kernel: list_add corruption. prev->next should be next (ffff88001b8db440), but was (null). (prev=ffff88001f7d84b8).
Aug 30 13:55:07 plink1 kernel: Modules linked in: [last unloaded: scsi_wait_scan]
Aug 30 13:55:07 plink1 kernel: Pid: 390, comm: rpciod/0 Not tainted 2.6.35-rc3-00041-g4d019ca #31
Aug 30 13:55:07 plink1 kernel: Call Trace:
Aug 30 13:55:07 plink1 kernel: [<ffffffff81038d5f>] warn_slowpath_common+0x7f/0xc0
Aug 30 13:55:07 plink1 kernel: [<ffffffff81038e56>] warn_slowpath_fmt+0x46/0x50
Aug 30 13:55:07 plink1 kernel: [<ffffffff814f441f>] __list_add+0x8f/0xa0
Aug 30 13:55:07 plink1 kernel: [<ffffffff8190f255>] ? rpc_queue_upcall+0x35/0x110
Aug 30 13:55:07 plink1 kernel: [<ffffffff8190f281>] rpc_queue_upcall+0x61/0x110
Aug 30 13:55:07 plink1 kernel: [<ffffffff81913fcc>] gss_setup_upcall+0x2cc/0x420
Aug 30 13:55:07 plink1 kernel: [<ffffffff819146b3>] gss_refresh+0x93/0x2c0
Aug 30 13:55:07 plink1 kernel: [<ffffffff810682ad>] ? trace_hardirqs_on_caller+0x14d/0x190
Aug 30 13:55:07 plink1 kernel: [<ffffffff819006c8>] rpcauth_refreshcred+0x48/0x1c0
Aug 30 13:55:07 plink1 kernel: [<ffffffff81913cdd>] ? gss_release_msg+0x5d/0x80
Aug 30 13:55:07 plink1 kernel: [<ffffffff818f6143>] call_refresh+0x43/0x70
Aug 30 13:55:07 plink1 kernel: [<ffffffff818ff252>] __rpc_execute+0xa2/0x230
Aug 30 13:55:07 plink1 kernel: [<ffffffff818ff410>] ? rpc_async_schedule+0x0/0x20
Aug 30 13:55:07 plink1 kernel: [<ffffffff818ff425>] rpc_async_schedule+0x15/0x20
Aug 30 13:55:07 plink1 kernel: [<ffffffff81053105>] worker_thread+0x225/0x410
Aug 30 13:55:07 plink1 kernel: [<ffffffff810530b5>] ? worker_thread+0x1d5/0x410
Aug 30 13:55:07 plink1 kernel: [<ffffffff8102f8d1>] ? get_parent_ip+0x11/0x50
Aug 30 13:55:07 plink1 kernel: [<ffffffff810579b0>] ? autoremove_wake_function+0x0/0x40
Aug 30 13:55:07 plink1 kernel: [<ffffffff81052ee0>] ? worker_thread+0x0/0x410
Aug 30 13:55:07 plink1 kernel: [<ffffffff81057516>] kthread+0x96/0xa0
Aug 30 13:55:07 plink1 kernel: [<ffffffff810030b4>] kernel_thread_helper+0x4/0x10
Aug 30 13:55:07 plink1 kernel: [<ffffffff8196587e>] ? restore_args+0x0/0x30
Aug 30 13:55:07 plink1 kernel: [<ffffffff81057480>] ? kthread+0x0/0xa0
Aug 30 13:55:07 plink1 kernel: [<ffffffff810030b0>] ? kernel_thread_helper+0x0/0x10
Aug 30 13:55:07 plink1 kernel: ---[ end trace 71a47b9c9b9b77dc ]---
Aug 30 13:55:07 plink1 kernel: general protection fault: 0000 [#1] PREEMPT
Aug 30 13:55:07 plink1 kernel: last sysfs file: /sys/devices/virtual/block/dm-0/dev
Aug 30 13:55:07 plink1 kernel: CPU 0
Aug 30 13:55:07 plink1 kernel: Modules linked in: [last unloaded: scsi_wait_scan]
Aug 30 13:55:07 plink1 kernel:
Aug 30 13:55:07 plink1 kernel: Pid: 3604, comm: rpc.gssd Tainted: G        W   2.6.35-rc3-00041-g4d019ca #31 /Bochs
Aug 30 13:55:07 plink1 kernel: RIP: 0010:[<ffffffff814f430b>]  [<ffffffff814f430b>] list_del+0x1b/0xa0
Aug 30 13:55:07 plink1 kernel: RSP: 0018:ffff88001d567e28  EFLAGS: 00010246
Aug 30 13:55:07 plink1 kernel: RAX: 6b6b6b6b6b6b6b6b RBX: ffff88001f7fd9f0 RCX: 00000000fffffff5
Aug 30 13:55:07 plink1 kernel: RDX: ffffffff819141a0 RSI: ffff88001d567e88 RDI: ffff88001f7fd9f0
Aug 30 13:55:07 plink1 kernel: RBP: ffff88001d567e38 R08: ffff88001f7fd9f0 R09: 0000000000000000
Aug 30 13:55:07 plink1 kernel: R10: 0000000000000246 R11: 0000000000000299 R12: ffff88001d567e88
Aug 30 13:55:07 plink1 kernel: R13: ffffffff819141a0 R14: ffff88001f7fd9f0 R15: 00000000fffffff5
Aug 30 13:55:07 plink1 kernel: FS:  00007f85d61417c0(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
Aug 30 13:55:07 plink1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Aug 30 13:55:07 plink1 kernel: CR2: 00007f85d614c000 CR3: 000000001e41c000 CR4: 00000000000006f0
Aug 30 13:55:07 plink1 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug 30 13:55:07 plink1 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug 30 13:55:07 plink1 kernel: Process rpc.gssd (pid: 3604, threadinfo ffff88001d566000, task ffff88001ebc0090)
Aug 30 13:55:07 plink1 kernel: Stack:
Aug 30 13:55:07 plink1 kernel: ffff88001b8db128 ffff88001b8db048 ffff88001d567e78 ffffffff8190e860
Aug 30 13:55:07 plink1 kernel: <0> ffff88001b8db0f8 ffff88001b8db048 ffff88001b8db128 ffff88001d567e88
Aug 30 13:55:07 plink1 kernel: <0> ffff88001b8db0f8 ffff88001e245078 ffff88001d567ec8 ffffffff8190eb13
Aug 30 13:55:07 plink1 kernel: Call Trace:
Aug 30 13:55:07 plink1 kernel: [<ffffffff8190e860>] rpc_purge_list+0x40/0x90
Aug 30 13:55:07 plink1 kernel: [<ffffffff8190eb13>] rpc_pipe_release+0x183/0x1a0
Aug 30 13:55:07 plink1 kernel: [<ffffffff810ea2d2>] fput+0x132/0x2c0
Aug 30 13:55:07 plink1 kernel: [<ffffffff810e6ccd>] filp_close+0x5d/0x90
Aug 30 13:55:07 plink1 kernel: [<ffffffff810e6db2>] sys_close+0xb2/0x110
Aug 30 13:55:07 plink1 kernel: [<ffffffff81002498>] system_call_fastpath+0x16/0x1b
Aug 30 13:55:07 plink1 kernel: Code: ff ff 90 90 90 90 90 90 90 90 90 90 90 90 90 90 55 48 89 e5 53 48 89 fb 48 83 ec 08 48 8b 47 08 4c 8b 00 4c 39 c7 75 39 48 8b 03 <4c> 8b 40 08 4c 39 c3 75 4c 48 8b 53 08 48 89 50 08 48 89 02 48
Aug 30 13:55:07 plink1 kernel: RIP  [<ffffffff814f430b>] list_del+0x1b/0xa0
Aug 30 13:55:07 plink1 kernel: RSP <ffff88001d567e28>
Aug 30 13:55:07 plink1 kernel: Slab corruption: size-1024 start=ffff88001f7fd9e8, len=1024
Aug 30 13:55:07 plink1 kernel: Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Aug 30 13:55:07 plink1 kernel: Last user: [<ffffffff81837870>](skb_release_data+0xd0/0xe0)
Aug 30 13:55:07 plink1 kernel: 010: 88 7e 56 1d 00 88 ff ff 6b 6b 6b 6b 6b 6b 6b 6b
Aug 30 13:55:07 plink1 kernel: Prev obj: start=ffff88001f7fd5d0, len=1024
Aug 30 13:55:07 plink1 kernel: Redzone: 0xd84156c5635688c0/0xd84156c5635688c0.
Aug 30 13:55:07 plink1 kernel: Last user: [<ffffffff810f1a1f>](alloc_pipe_info+0x6f/0x1f0)
Aug 30 13:55:07 plink1 kernel: 000: 30 ec 5c 00 00 ea ff ff 00 10 00 00 00 00 00 00
Aug 30 13:55:07 plink1 kernel: 010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
Aug 30 13:55:07 plink1 kernel: ---[ end trace 71a47b9c9b9b77dd ]---

