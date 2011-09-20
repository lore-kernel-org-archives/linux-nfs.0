Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:39268 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750823Ab1ITPgm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 11:36:42 -0400
Date: Tue, 20 Sep 2011 17:36:41 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: VFS: Busy inodes after unmount + nfs_zap_acl_cache() crash via
 sys_inotify_rm_watch()
Message-ID: <20110920153640.GA16909@janus>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

caught this one on 3.0.4:

 VFS: Busy inodes after unmount of 0:b1. Self-destruct in 5 seconds.  Have a nice day...
 BUG: unable to handle kernel paging request at 6b6b6c13
 IP: [<c11c75ca>] nfs_zap_acl_cache+0x1a/0x60
 *pdpt = 00000000323d0001 *pde = 0000000000000000 
 Oops: 0000 [#1] PREEMPT SMP 
 Modules linked in: vmthrottle [last unloaded: scsi_wait_scan]

 Pid: 4626, comm: gvfsd-trash Not tainted 3.0.4-x264 #1 Dell Inc.                 OptiPlex GX620               /0F8098
 EIP: 0060:[<c11c75ca>] EFLAGS: 00010286 CPU: 1
 EIP is at nfs_zap_acl_cache+0x1a/0x60
 EAX: 6b6b6b6b EBX: ed56cdf0 ECX: 00000000 EDX: ed56cca0
 ESI: ed56cdf0 EDI: cc6eece0 EBP: f23e7f2c ESP: f23e7f24
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
 Process gvfsd-trash (pid: 4626, ti=f23e6000 task=f2332bc0 task.ti=f23e6000)
 Stack:
 ed56cdf0 c17bf7c0 f23e7f38 c11c7638 ed56cdf0 f23e7f44 c11c76e3 ed56cdf0
 f23e7f54 c110d7f1 ed56cdf0 ed56ce04 f23e7f68 c110db62 ed56cdf0 f4b5b674
 f04011e0 f23e7f74 c110dc65 f4b5b660 f23e7f94 c112887a 00000000 ed56cdf0
 Call Trace:
 [<c11c7638>] nfs_clear_inode+0x28/0x50
 [<c11c76e3>] nfs_evict_inode+0x23/0x30
 [<c110d7f1>] evict+0x61/0x130
 [<c110db62>] iput_final+0x92/0x160
 [<c110dc65>] iput+0x35/0x40
 [<c112887a>] fsnotify_destroy_mark+0x11a/0x140
 [<c112990c>] sys_inotify_rm_watch+0x5c/0x90
 [<c17a0a1c>] sysenter_do_call+0x12/0x2c
 [<c17a0000>] ? _raw_spin_trylock+0x10/0x50
 Code: ec 5d c3 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 55 89 e5 83 ec 08 89 74 24 04 89 c6 89 1c 24 8b 40 10 8b 80 e8 01 00 00 
 EIP: [<c11c75ca>] nfs_zap_acl_cache+0x1a/0x60 SS:ESP 0068:f23e7f24
 CR2: 000000006b6b6c13
 ---[ end trace 7ecd000fd19003a9 ]---

-- 
Frank
