From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: null dereference on boot in nfs code
Date: Thu, 20 Aug 2009 18:38:37 -0400
Message-ID: <20090820223837.GF2451@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38784 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbZHTWif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 18:38:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boot of a kvm guest to a kernel including your latest for-2.6.32 is getting the
following.  (Also includes some stuff of mine which I wouldn't expect to be
relevant, but you never know.)

--b.

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<c10ae4c4>] sget+0x74/0x410
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
last sysfs file: 
Modules linked in:

Pid: 1, comm: swapper Not tainted (2.6.31-rc6-00109-g7de6644 #282) 
EIP: 0060:[<c10ae4c4>] EFLAGS: 00010286 CPU: 0
EIP is at sget+0x74/0x410
EAX: c1a0f440 EBX: fffffefc ECX: c10adc90 EDX: 00000000
ESI: 00000000 EDI: 00000000 EBP: c7867e50 ESP: c7867e24
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 1, ti=c7866000 task=c7864020 task.ti=c7866000)
Stack:
 c10a884f c10c4cab c10adca0 c10adc90 c1a0f440 c1a0f458 c1a0f460 c1a0f468
<0> c7817258 c21348bc 00000000 c7867e6c c10aed3f 00000000 00000000 c7817258
<0> c21348bc c1a0f440 c7867e7c c16d8181 c16d8a70 c7817258 c7867ea4 c10aeb4e
Call Trace:
 [<c10a884f>] ? __kmalloc_track_caller+0x1bf/0x240
 [<c10c4cab>] ? alloc_vfsmnt+0x8b/0x130
 [<c10adca0>] ? set_anon_super+0x0/0xf0
 [<c10adc90>] ? compare_single+0x0/0x10
 [<c10aed3f>] ? get_sb_single+0x2f/0xb0
 [<c16d8181>] ? rpc_get_sb+0x21/0x30
 [<c16d8a70>] ? rpc_fill_super+0x0/0xc0
 [<c10aeb4e>] ? vfs_kern_mount+0x5e/0x120
 [<c10c8c00>] ? simple_pin_fs+0x80/0xc0
 [<c16d978c>] ? rpc_get_mount+0x1c/0x30
 [<c11db48b>] ? nfs_cache_register+0x1b/0x90
 [<c10a00a3>] ? map_vm_area+0x33/0x50
 [<c10c2ef8>] ? register_filesystem+0x48/0x80
 [<c10c2f18>] ? register_filesystem+0x68/0x80
 [<c1a30e30>] ? init_nfs_fs+0x0/0x154
 [<c11daf82>] ? nfs_dns_resolver_init+0x12/0x20
 [<c1a30e3c>] ? init_nfs_fs+0xc/0x154
 [<c1a30d53>] ? init_iso9660_fs+0x4a/0x69
 [<c11bf1e0>] ? init_once+0x0/0x20
 [<c100111f>] ? do_one_initcall+0x2f/0x150
 [<c10f7b00>] ? proc_create_data+0x80/0xb0
 [<c1063072>] ? register_irq_proc+0x92/0xb0
 [<c1a204c5>] ? kernel_init+0x9e/0xf5
 [<c1a20427>] ? kernel_init+0x0/0xf5
 [<c100361b>] ? kernel_thread_helper+0x7/0x10
Code: 8b 45 e4 8b 50 18 eb 1d 8d b4 26 00 00 00 00 8b 55 08 89 d8 ff 55 e0 85 c0 0f 85 50 02 00 00 8b 93 04 01 00 00 8d 9a fc fe ff ff <8b> 83 04 01 00 00 0f 18 00 90 39 55 e8 75 d5 85 f6 0f 85 06 03 
EIP: [<c10ae4c4>] sget+0x74/0x410 SS:ESP 0068:c7867e24
CR2: 0000000000000000
