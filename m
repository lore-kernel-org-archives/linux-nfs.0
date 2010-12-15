Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:33487 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760327Ab0LOBKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 20:10:25 -0500
Date: Tue, 14 Dec 2010 17:10:21 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101215011021.GA24594@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org> <20101208223622.GA3796@hostway.ca> <1291869437.2821.6.camel@heimdal.trondhjem.org> <20101214233843.GB836@hostway.ca>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101214233843.GB836@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Dec 14, 2010 at 03:38:43PM -0800, Simon Kirby wrote:

> I'm just about to try
> 2.6.37-rc5-git3 on there plus your NFS fixes (which Linus seems to have
> half-merged and uploaded as -git3 but not pushed to his public git) 

Ignore this; I was just confusing myself by having the leak fixes already
applied.  Otoh, I got this Oops while trying NFSv4.  I'll check my
merging again.

Do you have a git branch exposed with the "Allow the admin to turn off
NFSv4 uid/gid mapping" patches applied?

Simon-

[   89.312786] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[   89.316758] IP: [<ffffffff8120ed82>] nfs_follow_remote_path+0x212/0x3c0
[   89.316758] PGD 2221c5067 PUD 225324067 PMD 0 
[   89.316758] Oops: 0000 [#1] SMP 
[   89.316758] last sysfs file: /sys/devices/platform/dcdbas/smi_data_buf_phys_addr
[   89.316758] CPU 0 
[   89.316758] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler bnx2
[   89.316758] 
[   89.316758] Pid: 4632, comm: mount.nfs Not tainted 2.6.37-rc5-git3-hw #1 0NH278/PowerEdge 2950
[   89.316758] RIP: 0010:[<ffffffff8120ed82>]  [<ffffffff8120ed82>] nfs_follow_remote_path+0x212/0x3c0
[   89.316758] RSP: 0018:ffff880222073c98  EFLAGS: 00010246
[   89.316758] RAX: ffff880222069a40 RBX: ffff8802222e0000 RCX: 0000000000000003
[   89.316758] RDX: ffff8802222e0000 RSI: 0000000000000002 RDI: 0000000000000000
[   89.316758] RBP: ffff880222073cd8 R08: ffff8800cfc16548 R09: ffffffff81a0c950
[   89.316758] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[   89.316758] R13: 0000000000000000 R14: ffff880226698d00 R15: ffff8802252df180
[   89.316758] FS:  00007f6626f176e0(0000) GS:ffff8800cfc00000(0000) knlGS:0000000000000000
[   89.316758] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   89.316758] CR2: 0000000000000018 CR3: 000000022516d000 CR4: 00000000000006f0
[   89.316758] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   89.316758] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   89.316758] Process mount.nfs (pid: 4632, threadinfo ffff880222072000, task ffff8802222e0000)
[   89.316758] Stack:
[   89.316758]  ffff880226699800 ffff880222007040 ffff880222337f40 0000000026698d00
[   89.316758]  ffff880222007040 0000000000000000 ffff880226699800 ffff880222040c00
[   89.316758]  ffff880222073d08 ffffffff8120f09e 0000000000000000 ffff8802220eea00
[   89.316758] Call Trace:
[   89.316758]  [<ffffffff8120f09e>] nfs4_try_mount+0x9e/0xe0
[   89.316758]  [<ffffffff812100b0>] nfs_get_sb+0x500/0xae0
[   89.316758]  [<ffffffff810e76bb>] ? pcpu_alloc+0x7ab/0x950
[   89.316758]  [<ffffffff81387551>] ? ida_get_new_above+0x151/0x220
[   89.316758]  [<ffffffff810e787b>] ? __alloc_percpu+0xb/0x10
[   89.316758]  [<ffffffff81114d5f>] vfs_kern_mount+0x11f/0x1a0
[   89.316758]  [<ffffffff81114e4e>] do_kern_mount+0x4e/0x110
[   89.316758]  [<ffffffff8112f7a1>] do_mount+0x241/0x870
[   89.316758]  [<ffffffff8112da72>] ? copy_mount_options+0xf2/0x190
[   89.316758]  [<ffffffff8112fe83>] sys_mount+0xb3/0xe0
[   89.316758]  [<ffffffff8100af12>] system_call_fastpath+0x16/0x1b
[   89.316758] Code: 65 48 8b 14 25 40 cc 00 00 eb 0f 66 0f 1f 44 00 00 48 39 57 10 74 14 48 89 c7 48 8b 07 48 81 ff f0 20 9a 81 0f 18 08 75 e8 31 ff <8b> 47 18 83 e8 01 85 c0 89 47 18 0f 84 c5 00 00 00 31 ff fe 05 
[   89.316758] RIP  [<ffffffff8120ed82>] nfs_follow_remote_path+0x212/0x3c0
[   89.316758]  RSP <ffff880222073c98>
[   89.316758] CR2: 0000000000000018
[   89.845673] ---[ end trace 2be6416a581974cc ]---
