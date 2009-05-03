From: Wu Fengguang <fengguang.wu@intel.com>
Subject: very slow NFS boot on linux-next and -mm
Date: Sun, 3 May 2009 18:54:56 +0800
Message-ID: <20090503105456.GA30449@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56608 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbZECK4C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 May 2009 06:56:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

My NFSROOT box sometimes will get stuck for a dozen seconds during boot.

Here is the stucked process:

[   48.983671] gzip          D 0000000000000000  2880  2976   2966
[   48.983671]  ffff88007b087ae8 0000000000000046 0000000000000000 ffffffff81079c58
[   48.983671]  00000000001d1a00 000000000000cda8 ffff88007b87dc80 ffffffff817934a0
[   48.983671]  ffff88007b87e010 ffff880005bd1a00 000000007b087a98 ffff880005bd1a18
[   48.983671] Call Trace:
[   48.983671]  [<ffffffff81079c58>] ? mark_held_locks+0x68/0x90
[   48.983671]  [<ffffffff810709cd>] ? getnstimeofday+0x9d/0x140
[   48.983671]  [<ffffffff8152cb85>] schedule+0x15/0x50
[   48.983671]  [<ffffffff8152cc28>] io_schedule+0x68/0xb0
[   48.983671]  [<ffffffff810c1935>] sync_page+0x85/0xc0
[   48.983671]  [<ffffffff8152d482>] __wait_on_bit+0x62/0x90
[   48.983671]  [<ffffffff810c18b0>] ? sync_page+0x0/0xc0
[   48.983671]  [<ffffffff810c1c64>] wait_on_page_bit+0x74/0x80
[   48.983671]  [<ffffffff81066490>] ? wake_bit_function+0x0/0x50
[   48.983671]  [<ffffffff810cd5d7>] ? pagevec_lookup_tag+0x27/0x40
[   48.983671]  [<ffffffff810c2906>] wait_on_page_writeback_range+0xc6/0x150
[   48.983671]  [<ffffffff810cb600>] ? do_writepages+0x30/0x50
[   48.983671]  [<ffffffff810c2a29>] ? __filemap_fdatawrite_range+0x59/0x70
[   48.983671]  [<ffffffff810c29be>] filemap_fdatawait+0x2e/0x40
[   48.983671]  [<ffffffff810c3e8d>] filemap_write_and_wait+0x4d/0x60
[   48.983671]  [<ffffffff8118de75>] nfs_setattr+0x135/0x150
[   48.983671]  [<ffffffff81070031>] ? current_kernel_time+0x41/0x70
[   48.983671]  [<ffffffff81079c58>] ? mark_held_locks+0x68/0x90
[   48.983671]  [<ffffffff810512d7>] ? current_fs_time+0x27/0x30
[   48.983671]  [<ffffffff81076dc0>] ? debug_mutex_free_waiter+0x80/0xc0
[   48.983671]  [<ffffffff8111bce1>] notify_change+0x121/0x330
[   48.983671]  [<ffffffff81129993>] utimes_common+0xd3/0x1c0
[   48.983671]  [<ffffffff81129b7c>] do_utimes+0xfc/0x110
[   48.983671]  [<ffffffff81079fad>] ? trace_hardirqs_on_caller+0x16d/0x1c0
[   48.983671]  [<ffffffff81129cbc>] sys_utimensat+0x3c/0xb0
[   48.983671]  [<ffffffff8100c2b2>] system_call_fastpath+0x16/0x1b

The NFSROOT client that got stuck is running latest linux-next, the
server side is running 2.6.30-rc3.

Switching the client kernel to latest -mm makes it very reproducible.
Here is another stack dump:

[  180.399845] udevd         D ffff8800280291e0  3056  1388      1
[  180.399845]  ffff88007bdeb7b8 0000000000000046 ffff88007bdec000 ffff88007bdec7d0
[  180.399845]  ffff88007bdeb718 00000000001d1000 000000000000cd68 ffff88007bdec000
[  180.399845]  ffff88007d3dc000 ffff88007bdec378 0000000100000286 00000000ffff8a5d
[  180.399845] Call Trace:
[  180.399845]  [<ffffffff8107673d>] ? trace_hardirqs_on_caller+0x16d/0x1c0
[  180.399845]  [<ffffffff8107679d>] ? trace_hardirqs_on+0xd/0x10
[  180.399845]  [<ffffffff814e3071>] rpc_wait_bit_killable+0x21/0x40
[  180.399845]  [<ffffffff81549552>] __wait_on_bit+0x62/0x90
[  180.399845]  [<ffffffff814e3050>] ? rpc_wait_bit_killable+0x0/0x40
[  180.399845]  [<ffffffff814e3050>] ? rpc_wait_bit_killable+0x0/0x40
[  180.399845]  [<ffffffff815495f9>] out_of_line_wait_on_bit+0x79/0x90
[  180.399845]  [<ffffffff81063270>] ? wake_bit_function+0x0/0x50
[  180.399845]  [<ffffffff814e3965>] __rpc_execute+0x105/0x2b0
[  180.399845]  [<ffffffff814e3b3d>] rpc_execute+0x2d/0x40
[  180.399845]  [<ffffffff814dc5ea>] rpc_run_task+0x4a/0xc0
[  180.399845]  [<ffffffff814dc772>] rpc_call_sync+0x42/0x70
[  180.399845]  [<ffffffff811c6bdd>] nfs3_rpc_wrapper+0x2d/0x70
[  180.399845]  [<ffffffff811c73af>] nfs3_proc_getattr+0x4f/0x90
[  180.399845]  [<ffffffff811b8e26>] __nfs_revalidate_inode+0xc6/0x220
[  180.399845]  [<ffffffff81012ad0>] ? native_sched_clock+0x20/0x70
[  180.399845]  [<ffffffff81012b29>] ? sched_clock+0x9/0x10
[  180.399845]  [<ffffffff81074405>] ? lock_release_holdtime+0x35/0x1c0
[  180.399845]  [<ffffffff811b33fe>] nfs_lookup_revalidate+0x41e/0x580
[  180.399845]  [<ffffffff81012ad0>] ? native_sched_clock+0x20/0x70
[  180.399845]  [<ffffffff81012ad0>] ? native_sched_clock+0x20/0x70
[  180.399845]  [<ffffffff81012b29>] ? sched_clock+0x9/0x10
[  180.399845]  [<ffffffff81074405>] ? lock_release_holdtime+0x35/0x1c0
[  180.399845]  [<ffffffff81116d42>] ? __d_lookup+0x142/0x210
[  180.399845]  [<ffffffff81116c00>] ? __d_lookup+0x0/0x210
[  180.399845]  [<ffffffff8110bb77>] do_lookup+0x67/0x260
[  180.399845]  [<ffffffff811b60c8>] ? nfs_permission+0x178/0x1e0
[  180.399845]  [<ffffffff8110e3c4>] __link_path_walk+0x9a4/0x1250
[  180.399845]  [<ffffffff81074405>] ? lock_release_holdtime+0x35/0x1c0
[  180.399845]  [<ffffffff8110ee8c>] path_walk+0x5c/0xb0
[  180.399845]  [<ffffffff8110ef43>] do_path_lookup+0x63/0xb0
[  180.399845]  [<ffffffff8110ffeb>] do_filp_open+0xfb/0xb40
[  180.399845]  [<ffffffff81012ad0>] ? native_sched_clock+0x20/0x70
[  180.399845]  [<ffffffff81012b29>] ? sched_clock+0x9/0x10
[  180.399845]  [<ffffffff812777ae>] ? _raw_spin_unlock+0x7e/0xa0
[  180.399845]  [<ffffffff8111b571>] ? alloc_fd+0x131/0x160
[  180.399845]  [<ffffffff810ffa57>] do_sys_open+0x87/0x140
[  180.399845]  [<ffffffff810ffb50>] sys_open+0x20/0x30
[  180.399845]  [<ffffffff8100c072>] system_call_fastpath+0x16/0x1b

I noticed that when udevd is waiting for NFS IO, there is a steady
250K/s network traffic.

Any suggestions on further debugging?

Thanks,
Fengguang
