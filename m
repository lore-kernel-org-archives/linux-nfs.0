From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: [2.6.33-rc3] NFS4 and dentry issues...
Date: Sat, 9 Jan 2010 14:32:46 +0000
Message-ID: <6278d2221001090632m7fdd77qc73c203840a2a78e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:35634 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753986Ab0AIOcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jan 2010 09:32:48 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When synchronising files (unison, like a two way rsync) over an NFS4
mount (server with 2.6.32.2) on a client running 2.6.33-rc3 (also
-rc2), I ran into dcache issues [1].

I've been unable to consistently reproduce this for bisecting, and
filesystem benchmarks via NFS on tmpfs over localhost fails to
reproduce it either.

What additional information may be useful?

client is 2.6.33-rc3 amd64, /proc/mounts:
x1:/ /net nfs4 rw,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,acregmin=30,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.10.2,addr=192.168.10.250
0 0

server is 2.6.32.3 amd64, exportfs -v:
/store        	192.168.10.0/24(rw,async,wdelay,insecure,no_root_squash,no_subtree_check,fsid=0)

Thanks,
  Daniel

--- [1]

kernel BUG at /home/kernel-ppa/mainline/build/fs/dcache.c:1869!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/virtual/block/ram9/uevent
CPU 5
Pid: 31525, comm: unison-2.27.57- Tainted: G        W
2.6.33-020633rc3-generic #020633rc3 0KM426/Studio 1557
RIP: 0010:[<ffffffff8113f3ac>]  [<ffffffff8113f3ac>]
d_materialise_unique+0x18c/0x190
RSP: 0000:ffff880099fcba28  EFLAGS: 00010206
RAX: ffff88009beb6c00 RBX: ffff88009bf0c0a0 RCX: ffff88009beb6c40
RDX: ffff88009beb6b80 RSI: ffff88009beb6caa RDI: ffffffff81a28800
RBP: ffff880099fcba58 R08: ffff88009bf0c0d0 R09: ffff88009bf0c0d0
R10: 00000000e68b3169 R11: ffff8800735e5180 R12: ffff88009beb6c0
R13: ffff88009bf0a900 R14: ffff8800735e5180 R15: ffff88009bf0c0a0
FS:  00007f463ed40790(0000) GS:ffff880028340000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f28cd23d000 CR3: 0000000099fda000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process unison-2.27.57- (pid: 31525, threadinfo ffff880099fca000, task
ffff880131a1db80)
Stack:
 0000000199fcba48 ffff88009bf0c0a0 ffff8800735e5180 ffff88009bf0a900
<0> ffff880099fcba78 ffff880099fcbb38 ffff880099fcbbf8 ffffffffa020f4ab
<0> 0000000000000000 ffff88009beb6780 ffff81a000027e7f 000005dc00000001
Call Trace:
 [<ffffffffa020f4ab>] nfs_lookup+0x15b/0x1d0 [nfs]
 [<ffffffff810e4c32>] ? mempool_free_slab+0x12/0x20
 [<ffffffff8153b729>] ? _raw_spin_lock+0x9/0x10
 [<ffffffffa020fd1e>] nfs_atomic_lookup+0xde/0x120 [nfs]
 [<ffffffff81134f07>] do_lookup+0x1b7/0x240
 [<ffffffff811364e7>] link_path_walk+0x6e7/0xc70
 [<ffffffffa02152e1>] ? nfs_refresh_inode+0x51/0x70 [nfs]
 [<ffffffff81136acc>] path_walk+0x5c/0xc0
 [<ffffffff81136c7b>] do_path_lookup+0x5b/0xc0
 [<ffffffff811385ee>] user_path_at+0x4e/0x90
 [<ffffffff8153b729>] ? _raw_spin_lock+0x9/0x10
 [<ffffffff8112e57b>] ? cp_new_stat+0xfb/0x120
 [<ffffffff8112e7ac>] vfs_fstatat+0x4c/0x70
 [<ffffffff8112e839>] vfs_lstat+0x19/0x20
 [<ffffffff8112e85f>] sys_newlstat+0x1f/0x50
 [<ffffffff81009ec2>] system_call_fastpath+0x16/0x1b
Code: ec e9 0d ff ff ff 4c 89 e7 4c 89 fe 45 31 e4 e8 ab e1 0e 00 e9
2b ff ff ff 0f 0b eb fe 48 c7 c7 00 88 a2 81 e8 d6 10 > 0b eb fe 55 48
89 e5 48 83 ec 10 48 89 1c 24 4c 89 64 24 08
RIP  [<ffffffff8113f3ac>] d_materialise_unique+0x18c/0x190
 RSP <ffff880099fcba28>
---[ end trace 5ed2e330c2528614 ]---
-- 
Daniel J Blueman
