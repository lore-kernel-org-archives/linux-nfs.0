From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [core/kill-the-BKL] nfs3: possible circular locking dependency
Date: Wed, 15 Apr 2009 22:08:01 +0400
Message-ID: <a4423d670904151108h39eb3a5fk36d0e5e623e7388f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:48148 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbZDOSIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 14:08:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

I have pulled core/kill-the-BKL on top of 2.6.30-rc2.

device: '0:18': device_add

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.30-rc2-00057-g30aa902-dirty #5
-------------------------------------------------------
mount.nfs/1740 is trying to acquire lock:
 (kernel_mutex){+.+.+.}, at: [<00000000006f32dc>] lock_kernel+0x28/0x3c

but task is already holding lock:
 (&type->s_umount_key#24/1){+.+.+.}, at: [<00000000004b88a0>] sget+0x228/0x36c

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&type->s_umount_key#24/1){+.+.+.}:
       [<00000000004776d0>] lock_acquire+0x5c/0x74
       [<0000000000469f5c>] down_write_nested+0x38/0x50
       [<00000000004b88a0>] sget+0x228/0x36c
       [<00000000005688fc>] nfs_get_sb+0x80c/0xa7c
       [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
       [<00000000004b7f84>] do_kern_mount+0x30/0xcc
       [<00000000004cf300>] do_mount+0x7c8/0x80c
       [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
       [<0000000000406154>] linux_sparc_syscall32+0x34/0x40

-> #0 (kernel_mutex){+.+.+.}:
       [<00000000004776d0>] lock_acquire+0x5c/0x74
       [<00000000006f0ebc>] mutex_lock_nested+0x48/0x380
       [<00000000006f32dc>] lock_kernel+0x28/0x3c
       [<00000000006d20ec>] rpc_wait_bit_killable+0x64/0x8c
       [<00000000006f0620>] __wait_on_bit+0x64/0xc0
       [<00000000006f06e4>] out_of_line_wait_on_bit+0x68/0x7c
       [<00000000006d2938>] __rpc_execute+0x150/0x2b4
       [<00000000006d2ac0>] rpc_execute+0x24/0x34
       [<00000000006cc338>] rpc_run_task+0x64/0x74
       [<00000000006cc474>] rpc_call_sync+0x58/0x7c
       [<00000000005717b0>] nfs3_rpc_wrapper+0x24/0xa0
       [<0000000000572024>] do_proc_get_root+0x6c/0x10c
       [<00000000005720dc>] nfs3_proc_get_root+0x18/0x5c
       [<000000000056401c>] nfs_get_root+0x34/0x17c
       [<0000000000568adc>] nfs_get_sb+0x9ec/0xa7c
       [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
       [<00000000004b7f84>] do_kern_mount+0x30/0xcc
       [<00000000004cf300>] do_mount+0x7c8/0x80c
       [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
       [<0000000000406154>] linux_sparc_syscall32+0x34/0x40

other info that might help us debug this:

1 lock held by mount.nfs/1740:
 #0:  (&type->s_umount_key#24/1){+.+.+.}, at: [<00000000004b88a0>]
sget+0x228/0x36c

stack backtrace:
Call Trace:
 [00000000004755ac] print_circular_bug_tail+0xfc/0x10c
 [0000000000476e24] __lock_acquire+0x12f0/0x1b40
 [00000000004776d0] lock_acquire+0x5c/0x74
 [00000000006f0ebc] mutex_lock_nested+0x48/0x380
 [00000000006f32dc] lock_kernel+0x28/0x3c
 [00000000006d20ec] rpc_wait_bit_killable+0x64/0x8c
 [00000000006f0620] __wait_on_bit+0x64/0xc0
 [00000000006f06e4] out_of_line_wait_on_bit+0x68/0x7c
 [00000000006d2938] __rpc_execute+0x150/0x2b4
 [00000000006d2ac0] rpc_execute+0x24/0x34
 [00000000006cc338] rpc_run_task+0x64/0x74
 [00000000006cc474] rpc_call_sync+0x58/0x7c
 [00000000005717b0] nfs3_rpc_wrapper+0x24/0xa0
 [0000000000572024] do_proc_get_root+0x6c/0x10c
 [00000000005720dc] nfs3_proc_get_root+0x18/0x5c
 [000000000056401c] nfs_get_root+0x34/0x17c
device: '0:19': device_add
