Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f51.google.com ([209.85.210.51]:45149 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759964Ab2CGTqz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2012 14:46:55 -0500
Received: by dady9 with SMTP id y9so7751624dad.10
        for <linux-nfs@vger.kernel.org>; Wed, 07 Mar 2012 11:46:54 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 7 Mar 2012 14:41:26 -0500
Message-ID: <CAOO4vO4HRwcQsOm+y7TKzsxaSpALfN5+cj3Y7fKUb1njWhqzQQ@mail.gmail.com>
Subject: new (to us) kernel panic nfsv4 linux 3.0.12
From: Paul Anderson <pha@umich.edu>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following kernel panic occurred on at least 4 compute nodes nearly
simultaneously.  It was during unattended operation, so no clue as to
what the server was doing.

The client node was under very heavy CPU load (12 core plus HT with
50-100 jobs running).  No swapping, unknown I/O but probably low,
except for the set of slurm jobs that stopped in D state probably due
to the kernel panic.

uname -> Linux c09 3.0.12 #1 SMP Wed Nov 30 19:42:40 EST 2011 x86_64 GNU/Linux

Please let me know what additional information I can provide - thanks!

Paul Anderson
University of Michigan

[1411404.724301] nfs4_reclaim_open_state: Lock reclaim failed!
[1412738.175791] nfs4_reclaim_open_state: Lock reclaim failed!
[1412738.175805] general protection fault: 0000 [#1] SMP
[1412738.176036] CPU 3
[1412738.176112] Modules linked in: binfmt_misc ipmi_msghandler
ipt_ULOG x_tables autofs4 mptctl mptbase dlm configfs dm_crypt nfsd
nfs lockd xfs auth_rpcgss n
[1412738.177205]
[1412738.177297] Pid: 10473, comm: 192.168.1.16-ma Not tainted 3.0.12
#1 Dell     C6100       /0D61XP
[1412738.177683] RIP: 0010:[<ffffffffa02a8e00>]  [<ffffffffa02a8e00>]
nfs4_do_reclaim+0x1c0/0x560 [nfs]
[1412738.178074] RSP: 0018:ffff88100e651e00  EFLAGS: 00010287
[1412738.178296] RAX: 0000000000000042 RBX: ffff88080dff5380 RCX:
000000000003ffff
[1412738.178606] RDX: ffff88080dff53a0 RSI: 0000000000000082 RDI:
0000000000000246
[1412738.178917] RBP: ffff88100e651e80 R08: 0000000000000000 R09:
0000000000000000
[1412738.179227] R10: 0000000000000006 R11: 0000000000000000 R12:
ffffffffa02b9c00
[1412738.179537] R13: dead000000100100 R14: ffff88100e762a58 R15:
ffff88100e762a00
[1412738.179848] FS:  0000000000000000(0000) GS:ffff88083fc60000(0000)
knlGS:0000000000000000
[1412738.180192] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1412738.180428] CR2: 0000000001c89068 CR3: 000000100534f000 CR4:
00000000000006e0
[1412738.180739] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[1412738.181049] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[1412738.181360] Process 192.168.1.16-ma (pid: 10473, threadinfo
ffff88100e650000, task ffff8809a7ca8000)
[1412738.181739] Stack:
[1412738.181847]  ffff88080dff53a0 ffff88080dff53c0 ffff8808055cf4b0
ffff8808055cf400
[1412738.182192]  ffff88100e762a50 ffff88054ab0b2b0 ffff8808055cf4f8
ffff88100e762a48
[1412738.182538]  ffffffffa02b9ec8 ffff880ac2296008 ffff88100e651e80
ffff8808055cf4f0
[1412738.182882] Call Trace:
[1412738.183015]  [<ffffffffa02a9424>] nfs4_run_state_manager+0x284/0x420 [nfs]
[1412738.183298]  [<ffffffffa02a91a0>] ? nfs4_do_reclaim+0x560/0x560 [nfs]
[1412738.183562]  [<ffffffff81080a96>] kthread+0x96/0xa0
[1412738.183771]  [<ffffffff815ac124>] kernel_thread_helper+0x4/0x10
[1412738.184927]  [<ffffffff81080a00>] ? kthread_worker_fn+0x190/0x190
[1412738.185177]  [<ffffffff815ac120>] ? gs_change+0x13/0x13
[1412738.185395] Code: 48 74 50 4d 8b 6d 00 4d 85 ed 75 df e8 2a a5 ee
e0 48 8b 7d a8 e8 41 cf dd e0 4c 8b 6b 20 48 8d 53 20 49 39 d5 74 18
0f 1f 40 00
[1412738.186187]  f6 45 18 01 0f 84 6a 03 00 00 4d 8b 6d 00 49 39 d5 75 ec 48
[1412738.186646] RIP  [<ffffffffa02a8e00>] nfs4_do_reclaim+0x1c0/0x560 [nfs]
[1412738.186926]  RSP <ffff88100e651e00>
[1412738.187353] ---[ end trace 4dbb732d1756f6b1 ]---
