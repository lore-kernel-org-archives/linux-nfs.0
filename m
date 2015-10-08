Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44313 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbbJHSEE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 14:04:04 -0400
Date: Thu, 8 Oct 2015 14:04:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 00/20] nfsd: open file caching
Message-ID: <20151008180400.GB496@fieldses.org>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
 <20151008164225.GA496@fieldses.org>
 <20151008125529.3f30308e@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151008125529.3f30308e@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 08, 2015 at 12:55:29PM -0400, Jeff Layton wrote:
> My bad...it needs this patch. I'll roll this into the set before the
> next posting.

Oh, good, thanks.

Also, just seen on the server side--not sure what was going on at the
time.

There were a ton of these:

Oct 08 12:35:07 f21-1.fieldses.org kernel: ------------[ cut here ]------------
Oct 08 12:35:07 f21-1.fieldses.org kernel: WARNING: CPU: 1 PID: 584 at lib/list_debug.c:59 __list_del_entry+0x9e/0xc0()
Oct 08 12:35:07 f21-1.fieldses.org kernel: list_del corruption.  prev->next should be ffff88004cb23f80, but was b6a7e8df8948e4eb
Oct 08 12:35:07 f21-1.fieldses.org kernel: Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
Oct 08 12:35:07 f21-1.fieldses.org kernel: CPU: 1 PID: 584 Comm: fsnotify_mark Not tainted 4.3.0-rc3-14186-g7619b8e #322
Oct 08 12:35:07 f21-1.fieldses.org kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
Oct 08 12:35:07 f21-1.fieldses.org kernel:  ffffffff81f62683 ffff880071af3d50 ffffffff8160540c ffff880071af3d98
Oct 08 12:35:07 f21-1.fieldses.org kernel:  ffff880071af3d88 ffffffff81077692 ffff88004cb23f80 ffffffff8109c160
Oct 08 12:35:07 f21-1.fieldses.org kernel:  ffff880071af3e08 ffff880071af3e30 ffff88004cb23f70 ffff880071af3de8
Oct 08 12:35:07 f21-1.fieldses.org kernel: Call Trace:
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8160540c>] dump_stack+0x4e/0x82
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81077692>] warn_slowpath_common+0x82/0xc0
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8109c160>] ?  sort_range+0x20/0x30
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8107771c>] warn_slowpath_fmt+0x4c/0x50
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8162219e>] __list_del_entry+0x9e/0xc0
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff811ef485>] fsnotify_mark_destroy+0x95/0x140
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff810baa10>] ?  wait_woken+0x90/0x90
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff811ef3f0>] ?  fsnotify_put_mark+0x30/0x30
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81098d6f>] kthread+0xef/0x110
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81a767dc>] ?  _raw_spin_unlock_irq+0x2c/0x50
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81a7748f>] ret_from_fork+0x3f/0x70
Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
Oct 08 12:35:07 f21-1.fieldses.org kernel: ---[ end trace 687abd8552e06b32 ]---

Then:

Oct 08 12:41:54 f21-1.fieldses.org kernel: BUG: unable to handle kernel NULL pointer dereference at           (null)
Oct 08 12:41:54 f21-1.fieldses.org kernel: IP: [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel: PGD 0 
Oct 08 12:41:54 f21-1.fieldses.org kernel: Oops: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC 
Oct 08 12:41:54 f21-1.fieldses.org kernel: Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
Oct 08 12:41:54 f21-1.fieldses.org kernel: CPU: 1 PID: 4360 Comm: nfsd Tainted: G    B D W       4.3.0-rc3-14186-g7619b8e #322
Oct 08 12:41:54 f21-1.fieldses.org kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
Oct 08 12:41:54 f21-1.fieldses.org kernel: task: ffff880051ed8040 ti: ffff880051edc000 task.ti: ffff880051edc000
Oct 08 12:41:54 f21-1.fieldses.org kernel: RIP: 0010:[<ffffffff811fcb3f>]  [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel: RSP: 0018:ffff880051edfc98  EFLAGS: 00010246
Oct 08 12:41:54 f21-1.fieldses.org kernel: RAX: 0000000080000000 RBX: 0000000000000002 RCX: ffff880051edfcc8
Oct 08 12:41:54 f21-1.fieldses.org kernel: RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff88004b7d8e40
Oct 08 12:41:54 f21-1.fieldses.org kernel: RBP: ffff880051edfcb8 R08: 0000000000000001 R09: 0000000000000000
Oct 08 12:41:54 f21-1.fieldses.org kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff88004b7d8e40
Oct 08 12:41:54 f21-1.fieldses.org kernel: R13: 0000000000000000 R14: ffff88007c64cf80 R15: ffff880069fa5240
Oct 08 12:41:54 f21-1.fieldses.org kernel: FS:  0000000000000000(0000) GS:ffff88007f900000(0000) knlGS:0000000000000000
Oct 08 12:41:54 f21-1.fieldses.org kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 08 12:41:54 f21-1.fieldses.org kernel: CR2: 0000000000000000 CR3: 000000000220b000 CR4: 00000000000406e0
Oct 08 12:41:54 f21-1.fieldses.org kernel: Stack:
Oct 08 12:41:54 f21-1.fieldses.org kernel:  ffff88006dbf9ea0 ffff880051c59f18 ffff88003ed0ceb0 0000000000000001
Oct 08 12:41:54 f21-1.fieldses.org kernel:  ffff880051edfcd8 ffffffffa00d6816 ffff88006dbf9e98 0000000000000000
Oct 08 12:41:54 f21-1.fieldses.org kernel:  ffff880051edfd20 ffffffffa00e0811 ffffffffa00e05e5 ffff88003ed0ceb0
Oct 08 12:41:54 f21-1.fieldses.org kernel: Call Trace:
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00d6816>] nfs4_put_deleg_lease+0x76/0x90 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00e0811>] nfsd4_delegreturn+0x231/0x240 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00e05e5>] ? nfsd4_delegreturn+0x5/0x240 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00ca63a>] nfsd4_proc_compound+0x38a/0x660 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b4608>] nfsd_dispatch+0xb8/0x200 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00151ff>] svc_process_common+0x40f/0x620 [sunrpc]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa0015557>] svc_process+0x147/0x320 [sunrpc]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b3b71>] nfsd+0x181/0x280 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b39f5>] ? nfsd+0x5/0x280 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b39f0>] ? nfsd_destroy+0x190/0x190 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81098d6f>] kthread+0xef/0x110
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81a767dc>] ? _raw_spin_unlock_irq+0x2c/0x50
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ? kthread_create_on_node+0x200/0x200
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81a7748f>] ret_from_fork+0x3f/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ? kthread_create_on_node+0x200/0x200
Oct 08 12:41:54 f21-1.fieldses.org kernel: Code: ff ff 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 55 41 54 53 49 89 d5 49 89 fc 48 89 f3 48 83 ec 08 48 83 fe 02 <48> 
Oct 08 12:41:54 f21-1.fieldses.org kernel: RIP  [<ffffffff811fcb3f>] vfs_setlease+0x1f/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel:  RSP <ffff880051edfc98>
Oct 08 12:41:54 f21-1.fieldses.org kernel: CR2: 0000000000000000
Oct 08 12:41:54 f21-1.fieldses.org kernel: ---[ end trace 687abd8552e07823 ]---
Oct 08 12:41:54 f21-1.fieldses.org kernel: BUG: sleeping function called from invalid context at include/linux/sched.h:2768
Oct 08 12:41:54 f21-1.fieldses.org kernel: in_atomic(): 0, irqs_disabled(): 1, pid: 4360, name: nfsd
Oct 08 12:41:54 f21-1.fieldses.org kernel: INFO: lockdep is turned off.
Oct 08 12:41:54 f21-1.fieldses.org kernel: irq event stamp: 1107102
Oct 08 12:41:54 f21-1.fieldses.org kernel: hardirqs last  enabled at (1107101): [<ffffffff81a76797>] _raw_spin_unlock_irqrestore+0x57/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel: hardirqs last disabled at (1107102): [<ffffffff81a76607>] _raw_spin_lock_irq+0x17/0x50
Oct 08 12:41:54 f21-1.fieldses.org kernel: softirqs last  enabled at (1107096): [<ffffffff81927075>] release_sock+0x165/0x1b0
Oct 08 12:41:54 f21-1.fieldses.org kernel: softirqs last disabled at (1107094): [<ffffffff81926f44>] release_sock+0x34/0x1b0
Oct 08 12:41:54 f21-1.fieldses.org kernel: CPU: 1 PID: 4360 Comm: nfsd Tainted: G    B D W       4.3.0-rc3-14186-g7619b8e #322
Oct 08 12:41:54 f21-1.fieldses.org kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
Oct 08 12:41:54 f21-1.fieldses.org kernel:  ffff880051ed8040 ffff880051edf9b0 ffffffff8160540c 0000000000000000
Oct 08 12:41:54 f21-1.fieldses.org kernel:  ffff880051edf9d8 ffffffff810a02de ffffffff81f0907b 0000000000000ad0
Oct 08 12:41:54 f21-1.fieldses.org kernel:  0000000000000000 ffff880051edfa00 ffffffff810a0409 ffff880051ed8040
Oct 08 12:41:54 f21-1.fieldses.org kernel: Call Trace:
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff8160540c>] dump_stack+0x4e/0x82
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff810a02de>] ___might_sleep+0x15e/0x240
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff810a0409>] __might_sleep+0x49/0x80
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81087fc4>] exit_signals+0x24/0x120
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff810796a2>] do_exit+0xb2/0xbc0
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff810d2345>] ? kmsg_dump+0x135/0x180
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff810d2232>] ? kmsg_dump+0x22/0x180
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff8100795d>] oops_end+0x6d/0x90
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff810443ea>] no_context+0x13a/0x360
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81583edb>] ? selinux_cred_prepare+0x1b/0x30
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff8104471e>] __bad_area_nosemaphore+0x10e/0x220
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81583edb>] ? selinux_cred_prepare+0x1b/0x30
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81044843>] bad_area_nosemaphore+0x13/0x20
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81044a9c>] __do_page_fault+0x8c/0x490
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81000fc0>] ? trace_hardirqs_off_thunk+0x17/0x19
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81044eac>] do_page_fault+0xc/0x10
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81a78f52>] page_fault+0x22/0x30
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff811fcb3f>] ? vfs_setlease+0x1f/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00d6816>] nfs4_put_deleg_lease+0x76/0x90 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00e0811>] nfsd4_delegreturn+0x231/0x240 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00e05e5>] ? nfsd4_delegreturn+0x5/0x240 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00ca63a>] nfsd4_proc_compound+0x38a/0x660 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b4608>] nfsd_dispatch+0xb8/0x200 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00151ff>] svc_process_common+0x40f/0x620 [sunrpc]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa0015557>] svc_process+0x147/0x320 [sunrpc]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b3b71>] nfsd+0x181/0x280 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b39f5>] ? nfsd+0x5/0x280 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffffa00b39f0>] ? nfsd_destroy+0x190/0x190 [nfsd]
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81098d6f>] kthread+0xef/0x110
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81a767dc>] ? _raw_spin_unlock_irq+0x2c/0x50
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ? kthread_create_on_node+0x200/0x200
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81a7748f>] ret_from_fork+0x3f/0x70
Oct 08 12:41:54 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ? kthread_create_on_node+0x200/0x200
Oct 08 12:41:54 f21-1.fieldses.org kernel: nfsd (4360) used greatest stack depth: 12280 bytes left
Oct 08 12:42:09 f21-1.fieldses.org kernel: general protection fault: 0000 [#3] PREEMPT SMP DEBUG_PAGEALLOC 
Oct 08 12:42:09 f21-1.fieldses.org kernel: Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
Oct 08 12:42:09 f21-1.fieldses.org kernel: CPU: 1 PID: 4361 Comm: nfsd Tainted: G    B D W       4.3.0-rc3-14186-g7619b8e #322
Oct 08 12:42:09 f21-1.fieldses.org kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
Oct 08 12:42:09 f21-1.fieldses.org kernel: task: ffff880051f20080 ti: ffff880051f24000 task.ti: ffff880051f24000
Oct 08 12:42:09 f21-1.fieldses.org kernel: RIP: 0010:[<ffffffffa00c21ce>]  [<ffffffffa00c21ce>] nfsd_file_acquire+0x1ce/0x820 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel: RSP: 0018:ffff880051f27ad0  EFLAGS: 00010202
Oct 08 12:42:09 f21-1.fieldses.org kernel: RAX: 5a5a5a5a5a5a5a5a RBX: ffff88003e9aaf18 RCX: 0000000000000001
Oct 08 12:42:09 f21-1.fieldses.org kernel: RDX: 0000000000000008 RSI: 00000000000003db RDI: ffffffffa00f53c4
Oct 08 12:42:09 f21-1.fieldses.org kernel: RBP: ffff880051f27b40 R08: 0000000000000000 R09: 0000000000000000
Oct 08 12:42:09 f21-1.fieldses.org kernel: R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
Oct 08 12:42:09 f21-1.fieldses.org kernel: R13: 0000000000000000 R14: ffff88003e9aaf50 R15: 0000000000000002
Oct 08 12:42:09 f21-1.fieldses.org kernel: FS:  0000000000000000(0000) GS:ffff88007f900000(0000) knlGS:0000000000000000
Oct 08 12:42:09 f21-1.fieldses.org kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Oct 08 12:42:09 f21-1.fieldses.org kernel: CR2: 00007f8f5903c000 CR3: 000000005d801000 CR4: 00000000000406e0
Oct 08 12:42:09 f21-1.fieldses.org kernel: Stack:
Oct 08 12:42:09 f21-1.fieldses.org kernel:  ffffffffa00c20c9 0000000200000000 0200000000000000 ffff880051f27b78
Oct 08 12:42:09 f21-1.fieldses.org kernel:  ffff880056436e00 ffff880051ed6000 0000000000039720 00000cc400000000
Oct 08 12:42:09 f21-1.fieldses.org kernel:  ffff880040e03c90 ffff88006dbf9e98 0000000000000000 ffff88006dbf9ea0
Oct 08 12:42:09 f21-1.fieldses.org kernel: Call Trace:
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00c20c9>] ? nfsd_file_acquire+0xc9/0x820 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00d7dc1>] nfs4_get_vfs_file+0x2e1/0x3e0 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00ddc9b>] ? nfsd4_process_open2+0x2bb/0x1400 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00ddcb4>] nfsd4_process_open2+0x2d4/0x1400 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00dd9e5>] ? nfsd4_process_open2+0x5/0x1400 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00b888d>] ? fh_verify+0x15d/0x570 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00b986f>] ? nfsd_lookup+0x7f/0x120 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00ca172>] nfsd4_open+0x7e2/0x920 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00c9995>] ? nfsd4_open+0x5/0x920 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00ca63a>] nfsd4_proc_compound+0x38a/0x660 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00b4608>] nfsd_dispatch+0xb8/0x200 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00151ff>] svc_process_common+0x40f/0x620 [sunrpc]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa0015557>] svc_process+0x147/0x320 [sunrpc]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00b3b71>] nfsd+0x181/0x280 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00b39f5>] ? nfsd+0x5/0x280 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffffa00b39f0>] ? nfsd_destroy+0x190/0x190 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffff81098d6f>] kthread+0xef/0x110
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffff81a767dc>] ? _raw_spin_unlock_irq+0x2c/0x50
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ? kthread_create_on_node+0x200/0x200
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffff81a7748f>] ret_from_fork+0x3f/0x70
Oct 08 12:42:09 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ? kthread_create_on_node+0x200/0x200
Oct 08 12:42:09 f21-1.fieldses.org kernel: Code: ff ff 41 f7 c4 00 02 00 00 75 53 44 89 e2 d1 ea 89 d1 48 8b 53 38 83 e1 01 83 e2 04 75 0d 48 8b 53 38 83 e2 08 74 37 84 c9 74 33 <48> 
Oct 08 12:42:09 f21-1.fieldses.org kernel: RIP  [<ffffffffa00c21ce>] nfsd_file_acquire+0x1ce/0x820 [nfsd]
Oct 08 12:42:09 f21-1.fieldses.org kernel:  RSP <ffff880051f27ad0>
Oct 08 12:42:09 f21-1.fieldses.org kernel: ---[ end trace 687abd8552e07824 ]---

--b.
