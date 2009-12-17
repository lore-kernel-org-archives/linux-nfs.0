From: Eric Paris <eparis@redhat.com>
Subject: Re: NULL pointer dereference in commit_tree() from Linus' Dec17
 tree
Date: Thu, 17 Dec 2009 15:23:31 -0500
Message-ID: <1261081411.2868.18.camel@localhost>
References: <1261075774.2868.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758240AbZLQUXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 15:23:33 -0500
In-Reply-To: <1261075774.2868.16.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-12-17 at 13:49 -0500, Eric Paris wrote:
> I pulled from Linus Dec16 and didn't have problems.  This is a pull from
> Dec17, plus some of my own patches which I'd be surprised to learn were
> related.  I have an NFS mount in my fstab, I assume this is that being
> mounted on boot.  I'll start a bisect if needed, but maybe someone will
> know what they broke instantly....

For those playing along at home it is commit e9496ff46a20a8592fdc7 and
Al is looking at it.

Now to get my tree up so I can ask you to pull from mine (which is
coming so late because it had some conflicts with Al's and I was waiting
for it to go in)

> 
> [   16.140640] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> [   16.141381] IP: [<ffffffff8114db7f>] commit_tree+0x6f/0x100
> [   16.141381] PGD 0 
> [   16.141381] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [   16.141381] last sysfs file: /sys/module/lockd/initstate
> [   16.141381] CPU 1 
> [   16.141381] Pid: 2413, comm: mount.nfs Not tainted 2.6.32-fanotify #32 /
> [   16.141381] RIP: 0010:[<ffffffff8114db7f>]  [<ffffffff8114db7f>] commit_tree+0x6f/0x100
> [   16.141381] RSP: 0018:ffff88007dfb1798  EFLAGS: 00010246
> [   16.141381] RAX: ffff88007dfb1798 RBX: ffff88007dfb1798 RCX: ffff8800775962e8
> [   16.141381] RDX: ffff88007dfb1730 RSI: ffff8800775962e8 RDI: ffff88007dfb1798
> [   16.141381] RBP: ffff88007dfb17c8 R08: 0000000000000002 R09: 0000000000000000
> [   16.141381] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> [   16.141381] R13: ffff880077596280 R14: ffff88007e6e6280 R15: 0000000000000000
> [   16.141381] FS:  00007f05bdf0b700(0000) GS:ffff880004c00000(0000) knlGS:0000000000000000
> [   16.141381] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   16.141381] CR2: 0000000000000018 CR3: 00000000777d3000 CR4: 00000000000006e0
> [   16.141381] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   16.141381] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   16.141381] Process mount.nfs (pid: 2413, threadinfo ffff88007dfb0000, task ffff88007dc62430)
> [   16.141381] Stack:
> [   16.141381]  ffff8800775962e8 ffff8800775962e8 ffff880077596280 ffff88007e6e6280
> [   16.141381] <0> ffff88007dfb1be8 ffff88007dfb17e8 ffff88007dfb1828 ffffffff8114e13b
> [   16.141381] <0> 0000000000000000 ffff88007c307710 ffff88007dfb17e8 ffff88007dfb17e8
> [   16.141381] Call Trace:
> [   16.141381]  [<ffffffff8114e13b>] attach_recursive_mnt+0x16b/0x170
> [   16.141381]  [<ffffffff8114e22b>] graft_tree+0xeb/0x120
> [   16.141381]  [<ffffffff8114e294>] ? do_add_mount+0x34/0x140
> [   16.141381]  [<ffffffff8114e354>] do_add_mount+0xf4/0x140
> [   16.141381]  [<ffffffffa0270a9a>] nfs_follow_mountpoint+0x14a/0x490 [nfs]
> [   16.141381]  [<ffffffff8102f64e>] ? kvm_clock_read+0x3e/0x70
> [   16.141381]  [<ffffffff81012499>] ? sched_clock+0x9/0x10
> [   16.141381]  [<ffffffff81245ca3>] ? selinux_inode_follow_link+0x83/0xb0
> [   16.141381]  [<ffffffff8113e2d1>] do_follow_link+0x161/0x300
> [   16.141381]  [<ffffffff8113dadb>] link_path_walk+0x3bb/0x670
> [   16.141381]  [<ffffffff8113ddec>] path_walk+0x5c/0xc0
> [   16.141381]  [<ffffffff8113deba>] vfs_path_lookup+0x6a/0xe0
> [   16.141381]  [<ffffffffa0264f45>] nfs_follow_remote_path+0x35/0x110 [nfs]
> [   16.141381]  [<ffffffff810927f0>] ? trace_hardirqs_on_caller+0x120/0x1a0
> [   16.141381]  [<ffffffffa0266235>] ? nfs_do_root_mount+0x85/0xa0 [nfs]
> [   16.141381]  [<ffffffffa0266235>] ? nfs_do_root_mount+0x85/0xa0 [nfs]
> [   16.141381]  [<ffffffffa0266397>] nfs4_try_mount+0x77/0xd0 [nfs]
> [   16.141381]  [<ffffffffa0267336>] nfs_get_sb+0x836/0xd10 [nfs]
> [   16.141381]  [<ffffffff8109287d>] ? trace_hardirqs_on+0xd/0x10
> [   16.141381]  [<ffffffff8114c8e6>] ? alloc_vfsmnt+0xc6/0x1a0
> [   16.141381]  [<ffffffff8113025b>] ? __alloc_percpu+0xb/0x10
> [   16.141381]  [<ffffffff81134d97>] vfs_kern_mount+0x77/0x180
> [   16.141381]  [<ffffffff81134f0e>] do_kern_mount+0x4e/0x110
> [   16.141381]  [<ffffffff8114ea9d>] do_mount+0x51d/0x7e0
> [   16.141381]  [<ffffffff8114d24a>] ? copy_mount_options+0x10a/0x180
> [   16.141381]  [<ffffffff8114edea>] sys_mount+0x8a/0xd0
> [   16.141381]  [<ffffffff8100ae02>] system_call_fastpath+0x16/0x1b
> [   16.141381] Code: 55 d0 48 83 ea 68 eb 0f 4c 89 a2 c0 00 00 00 48 8b 52 68 48 83 ea 68 48 8b 42 68 0f 18 08 48 8d 42 68 48 39 d8 75 e1 48 8b 4d d0 <49> 8b 74 24 18 48 39 c1 74 15 48 8b 16 48 8b 45 d8 48 89 0e 48


