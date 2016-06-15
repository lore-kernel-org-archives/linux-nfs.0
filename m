Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33826 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbcFOT0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 15:26:21 -0400
Date: Wed, 15 Jun 2016 21:26:16 +0200
From: Krzysztof Kozlowski <krzk@kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [BUG] Sleeping in atomic context, nfs_alloc_fattr, next-20160615
Message-ID: <20160615192616.GB19579@kozik-lap>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

My test board (ARM, Exynos5422, Odroid XU3) booted from NFS root (NFS
v4) hit a sleep in a atomic context:

BUG: sleeping function called from invalid context at ../mm/slab.h:395
in_atomic(): 1, irqs_disabled(): 0, pid: 232, name: kworker/u16:0
2 locks held by kworker/u16:0/232:
 #0:  (&sig->cred_guard_mutex){......}, at: [<c042e410>] prepare_bprm_creds+0x28/0x74
 #1:  (rcu_read_lock){......}, at: [<c04f304c>] nfs_permission+0x68/0x23c
CPU: 3 PID: 232 Comm: kworker/u16:0 Not tainted 4.7.0-rc3-next-20160615 #633
Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
[<c0310dd8>] (unwind_backtrace) from [<c030c448>] (show_stack+0x10/0x14)
[<c030c448>] (show_stack) from [<c05b6f8c>] (dump_stack+0x90/0xa4)
[<c05b6f8c>] (dump_stack) from [<c041f77c>] (kmem_cache_alloc+0xe8/0x170)
[<c041f77c>] (kmem_cache_alloc) from [<c04f4ac8>] (nfs_alloc_fattr+0x1c/0x30)
[<c04f4ac8>] (nfs_alloc_fattr) from [<c04f6d38>] (__nfs_revalidate_inode+0x30/0x140)
[<c04f6d38>] (__nfs_revalidate_inode) from [<c04f2f20>] (nfs_do_access+0x220/0x2b8)
[<c04f2f20>] (nfs_do_access) from [<c04f30a8>] (nfs_permission+0xc4/0x23c)
[<c04f30a8>] (nfs_permission) from [<c042d7a0>] (would_dump+0x18/0x2c)
[<c042d7a0>] (would_dump) from [<c0474eec>] (load_elf_binary+0x5a8/0x1258)
[<c0474eec>] (load_elf_binary) from [<c042d8dc>] (search_binary_handler+0x84/0x1c0)
[<c042d8dc>] (search_binary_handler) from [<c042e948>] (do_execveat_common+0x4ec/0x6c8)
[<c042e948>] (do_execveat_common) from [<c042eb48>] (do_execve+0x24/0x2c)
[<c042eb48>] (do_execve) from [<c035741c>] (call_usermodehelper_exec_async+0x128/0x180)
[<c035741c>] (call_usermodehelper_exec_async) from [<c0308078>] (ret_from_fork+0x14/0x3c)
BUG: scheduling while atomic: kworker/u16:0/232/0x00000002
2 locks held by kworker/u16:0/232:
 #0:  (&sig->cred_guard_mutex){......}, at: [<c042e410>] prepare_bprm_creds+0x28/0x74
 #1:  (rcu_read_lock){......}, at: [<c04f304c>] nfs_permission+0x68/0x23c
Modules linked in: ohci_exynos phy_exynos_usb2
CPU: 3 PID: 232 Comm: kworker/u16:0 Not tainted 4.7.0-rc3-next-20160615 #633
Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
[<c0310dd8>] (unwind_backtrace) from [<c030c448>] (show_stack+0x10/0x14)
[<c030c448>] (show_stack) from [<c05b6f8c>] (dump_stack+0x90/0xa4)
[<c05b6f8c>] (dump_stack) from [<c0364cfc>] (__schedule_bug+0x58/0x6c)
[<c0364cfc>] (__schedule_bug) from [<c0bcfd00>] (__schedule+0x49c/0x600)
[<c0bcfd00>] (__schedule) from [<c0bcfeb4>] (schedule+0x50/0xb4)
[<c0bcfeb4>] (schedule) from [<c0bac058>] (rpc_wait_bit_killable+0x28/0xfc)
[<c0bac058>] (rpc_wait_bit_killable) from [<c0bd03c0>] (__wait_on_bit+0x84/0xb8)
[<c0bd03c0>] (__wait_on_bit) from [<c0bd04b8>] (out_of_line_wait_on_bit+0xc4/0xcc)
[<c0bd04b8>] (out_of_line_wait_on_bit) from [<c0baca94>] (__rpc_execute+0x194/0x26c)
[<c0baca94>] (__rpc_execute) from [<c0ba67b4>] (rpc_run_task+0x134/0x14c)
[<c0ba67b4>] (rpc_run_task) from [<c0509010>] (nfs4_call_sync_sequence+0x58/0x78)
[<c0509010>] (nfs4_call_sync_sequence) from [<c050efcc>] (nfs4_proc_getattr+0xb8/0xe0)
[<c050efcc>] (nfs4_proc_getattr) from [<c04f6d94>] (__nfs_revalidate_inode+0x8c/0x140)
[<c04f6d94>] (__nfs_revalidate_inode) from [<c04f2f20>] (nfs_do_access+0x220/0x2b8)
[<c04f2f20>] (nfs_do_access) from [<c04f30a8>] (nfs_permission+0xc4/0x23c)
[<c04f30a8>] (nfs_permission) from [<c042d7a0>] (would_dump+0x18/0x2c)
[<c042d7a0>] (would_dump) from [<c0474eec>] (load_elf_binary+0x5a8/0x1258)
[<c0474eec>] (load_elf_binary) from [<c042d8dc>] (search_binary_handler+0x84/0x1c0)
[<c042d8dc>] (search_binary_handler) from [<c042e948>] (do_execveat_common+0x4ec/0x6c8)
[<c042e948>] (do_execveat_common) from [<c042eb48>] (do_execve+0x24/0x2c)
[<c042eb48>] (do_execve) from [<c035741c>] (call_usermodehelper_exec_async+0x128/0x180)
[<c035741c>] (call_usermodehelper_exec_async) from [<c0308078>] (ret_from_fork+0x14/0x3c)

Full log here:
http://www.krzk.eu/builders/boot-odroid-xu3-multi_v7/builds/1166/steps/Boot%3A%20odroidxu3/logs/serial0

Config: arm/multi_v7_defconfig with following changes:
-e IPV6 -e NFS_V4 -e SENSORS_PWM_FAN -e PWM_SAMSUNG -d
CRYPTO_MANAGER_DISABLE_TESTS -e DMATEST -m CRYPTO_TEST -e
SCHED_STACK_END_CHECK -e DEBUG_LOCK_ALLOC -e DEBUG_ATOMIC_SLEEP -e
DEBUG_LIST -e DEBUG_SECTION_MISMATCH

I hope that information might be useful. Please let me know if you need
more details (I didn't bisect this...).

Best regards,
Krzysztof
