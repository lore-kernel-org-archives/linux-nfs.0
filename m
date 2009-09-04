From: Jiri Slaby <jirislaby@gmail.com>
Subject: mount.nfs oops [was: mmotm 2009-09-03-16-35 uploaded]
Date: Fri, 04 Sep 2009 22:54:12 +0200
Message-ID: <4AA17E74.8060100@gmail.com>
References: <200909032340.n83Ne6E6004708@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:19173 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933855AbZIDUyO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 16:54:14 -0400
In-Reply-To: <200909032340.n83Ne6E6004708-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2009 01:40 AM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2009-09-03-16-35 has been uploaded to

Hi, I got an oops while mounting an nfs:
BUG: unable to handle kernel NULL pointer dereference at 000000000000001d
IP: [<ffffffffa003924f>] rpcauth_lookupcred+0x4f/0xc0 [sunrpc]
PGD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/virtual/net/tun0/statistics/collisions
CPU 1
Modules linked in: nfs lockd auth_rpcgss sunrpc ath5k ath
Pid: 3660, comm: mount.nfs Tainted: G        W  2.6.31-rc8-mm1_64 #762
To Be Filled By O.E.M.
RIP: 0010:[<ffffffffa003924f>]  [<ffffffffa003924f>]
rpcauth_lookupcred+0x4f/0xc0 [sunrpc]
RSP: 0018:ffff8801294bb808  EFLAGS: 00010246
RAX: ffff88011bb6f0c0 RBX: 0000000000000001 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8801294bb808 RDI: ffffffffa005ed20
RBP: ffff8801294bb848 R08: ffffea0006429770 R09: ffff880132d29f40
R10: 0000000000000020 R11: 0000000000000001 R12: ffffffffa005ed20
R13: 0000000000000000 R14: 0000000000000002 R15: ffff88011ba0ec80
FS:  00007f42aad656f0(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000000001d CR3: 000000010e81f000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process mount.nfs (pid: 3660, threadinfo ffff8801294ba000, task
ffff88011bb6f0c0)
Stack:
 0000000000000000 0000000000000000 0000000000000000 0000001000000010
<0> ffff88011ba0e910 ffff8801c9e22b40 ffffffffa005ed20 0000000000000080
<0> ffff8801294bb888 ffffffffa0039363 ffff8801294bb8d8 0000000000000000
Call Trace:
 [<ffffffffa0039363>] rpcauth_bindcred+0xa3/0x100 [sunrpc]
 [<ffffffffa0037429>] rpc_new_task+0x119/0x1e0 [sunrpc]
 [<ffffffffa0030cf9>] rpc_run_task+0x19/0x80 [sunrpc]
 [<ffffffffa0040a4c>] rpcb_getport_async+0x36c/0x590 [sunrpc]
 [<ffffffffa002f20a>] call_bind+0x5a/0x90 [sunrpc]
 [<ffffffffa0037ee2>] __rpc_execute+0xb2/0x2c0 [sunrpc]
 [<ffffffffa0038184>] rpc_execute+0x94/0xb0 [sunrpc]
 [<ffffffffa0030d1b>] rpc_run_task+0x3b/0x80 [sunrpc]
 [<ffffffffa0030e5d>] rpc_call_sync+0x3d/0x60 [sunrpc]
 [<ffffffffa0030ece>] rpc_ping+0x4e/0x70 [sunrpc]
 [<ffffffffa00319ed>] rpc_create+0x45d/0x590 [sunrpc]
 [<ffffffff811747cb>] ? match_token+0x1fb/0x220
 [<ffffffffa00a9803>] nfs_mount+0xd3/0x1c0 [nfs]
 [<ffffffff810a2fd2>] ? kstrndup+0x52/0x70
 [<ffffffffa00a0268>] nfs_get_sb+0x818/0xa00 [nfs]
 [<ffffffff810c53b8>] vfs_kern_mount+0x58/0xf0
 [<ffffffff810c54bd>] do_kern_mount+0x4d/0x130
 [<ffffffff810ddea8>] do_mount+0x2c8/0x820
 [<ffffffff810dbce8>] ? copy_mount_options+0xe8/0x190
 [<ffffffff810de493>] sys_mount+0x93/0xe0
 [<ffffffff8100be2b>] system_call_fastpath+0x16/0x1b
Code: 05 4e ae 02 00 10 48 8b 98 40 03 00 00 75 6c 48 c7 45 c0 00 00 00
00 48 c7 45 c8 00 00 00 00 48 c7 45 d0 00 00 00 00 48 8d 75 c0 <8b> 43
1c 89 45 c0 8b 43 20 89 45 c4 48 8b 43 50 f0 ff 00 48 89
RIP  [<ffffffffa003924f>] rpcauth_lookupcred+0x4f/0xc0 [sunrpc]
 RSP <ffff8801294bb808>
CR2: 000000000000001d
---[ end trace 73264e95657dec66 ]---
