Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fold.natur.cuni.cz ([195.113.57.32]:58056 "HELO
	fold.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752822Ab2DFI6I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2012 04:58:08 -0400
Message-ID: <4F7EAE8C.4040908@fold.natur.cuni.cz>
Date: Fri, 06 Apr 2012 10:51:24 +0200
From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: 2.6.32.58: BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000330
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
   I found one of my cluster nodes killed my program. Is this a nfs/rpc issue?
Thanks for clues,
Martin

Apr  6 04:32:13 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:32:13 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 04:49:01 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:49:01 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:49:01 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:49:02 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 04:49:02 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 04:49:02 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 04:49:11 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:49:11 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:49:11 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 04:49:11 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 04:50:01 node010 cron[22755]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons )
Apr  6 04:59:54 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 04:59:54 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 05:00:01 node010 cron[29092]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons )
Apr  6 05:00:01 node010 cron[29093]: (root) CMD (rm -f /var/spool/cron/lastrun/cron.hourly)
Apr  6 05:00:03 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 05:00:03 node010 kernel: nfs: server 192.168.10.100 not responding, still trying
Apr  6 05:00:03 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 05:00:03 node010 kernel: nfs: server 192.168.10.100 OK
Apr  6 05:10:01 node010 cron[28456]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons )
Apr  6 05:20:01 node010 cron[29974]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons )
Apr  6 05:30:01 node010 cron[32569]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons )
Apr  6 05:37:48 node010 kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000330
Apr  6 05:37:48 node010 kernel: IP: [<ffffffff81025448>] do_page_fault+0x20/0x1de
Apr  6 05:37:48 node010 kernel: PGD 106180067 PUD 12c8bc067 PMD 0 
Apr  6 05:37:48 node010 kernel: Oops: 0000 [#1] SMP 
Apr  6 05:37:48 node010 kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host2/uevent
Apr  6 05:37:48 node010 kernel: CPU 0 
Apr  6 05:37:48 node010 kernel: Modules linked in:
Apr  6 05:37:48 node010 kernel: Pid: 22251, comm: SFF_inspector.p Not tainted 2.6.32.58-default #5 MS-7345
Apr  6 05:37:48 node010 kernel: RIP: 0010:[<ffffffff81025448>]  [<ffffffff81025448>] do_page_fault+0x20/0x1de
Apr  6 05:37:48 node010 kernel: RSP: 0000:ffff880129e7df08  EFLAGS: 00010092
Apr  6 05:37:48 node010 kernel: RAX: 00007fbd0c6201a0 RBX: 0000000000000000 RCX: 00000000017771b8
Apr  6 05:37:48 node010 kernel: RDX: 0000000001650aa0 RSI: 0000000000000007 RDI: ffff880129e7df58
Apr  6 05:37:48 node010 kernel: RBP: ffff880129e7df48 R08: 000000000000001f R09: 0000000000000002
Apr  6 05:37:48 node010 kernel: R10: 0000000000000001 R11: 00007fbd0c31c890 R12: 00000000017acad0
Apr  6 05:37:48 node010 kernel: R13: 0000000000000007 R14: ffff880129e7df58 R15: 0000000000000000
Apr  6 05:37:48 node010 kernel: FS:  00007fbd0c85d720(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
Apr  6 05:37:48 node010 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Apr  6 05:37:48 node010 kernel: CR2: 0000000000000330 CR3: 000000012ca52000 CR4: 00000000000006f0
Apr  6 05:37:48 node010 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr  6 05:37:48 node010 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr  6 05:37:48 node010 kernel: Process myprog.py (pid: 22251, threadinfo ffff880129e7c000, task ffff88012e0907f0)
Apr  6 05:37:48 node010 kernel: Stack:
Apr  6 05:37:48 node010 kernel: 0000000000000000 ffff8800c81110a0 ffff8800c8111040 0000000000000000
Apr  6 05:37:48 node010 kernel: <0> 00000000017acad0 0000000001650aa0 00000000018417f0 0000000001841a00
Apr  6 05:37:48 node010 kernel: <0> 00000000017771b8 ffffffff813e16af 0000000001841a00 00000000018417f0
Apr  6 05:37:48 node010 kernel: Call Trace:
Apr  6 05:37:48 node010 kernel: [<ffffffff813e16af>] page_fault+0x1f/0x30
Apr  6 05:37:48 node010 kernel: Code: ec 80 5b 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 41 57 41 56 65 4c 8b 3c 25 00 b5 00 00 41 55 49 89 fe 41 54 49 89 f5 53 48 83 ec 18 <49> 8b 87 30 03 00 00 48 89 45 d0 0f 20 d3 48 83 c0 60 48 89 45 
Apr  6 05:37:48 node010 kernel: RIP  [<ffffffff81025448>] do_page_fault+0x20/0x1de
Apr  6 05:37:48 node010 kernel: RSP <ffff880129e7df08>
Apr  6 05:37:48 node010 kernel: CR2: 0000000000000330
Apr  6 05:37:48 node010 kernel: ---[ end trace 4d2269fd524616a4 ]---
Apr  6 05:37:48 node010 kernel: ------------[ cut here ]------------
Apr  6 05:37:48 node010 kernel: WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0x3c/0x89()
Apr  6 05:37:48 node010 kernel: Hardware name: MS-7345
Apr  6 05:37:48 node010 kernel: Modules linked in:
Apr  6 05:37:48 node010 kernel: Pid: 22251, comm: myprog.py Tainted: G      D    2.6.32.58-default #5
Apr  6 05:37:48 node010 kernel: Call Trace:
Apr  6 05:37:48 node010 kernel: [<ffffffff81041136>] ? local_bh_enable_ip+0x3c/0x89
Apr  6 05:37:48 node010 kernel: [<ffffffff8103c6f9>] warn_slowpath_common+0x77/0xa4
Apr  6 05:37:48 node010 kernel: [<ffffffff8103c735>] warn_slowpath_null+0xf/0x11
Apr  6 05:37:48 node010 kernel: [<ffffffff81041136>] local_bh_enable_ip+0x3c/0x89
Apr  6 05:37:48 node010 kernel: [<ffffffff813e1468>] _spin_unlock_bh+0x10/0x12
Apr  6 05:37:48 node010 kernel: [<ffffffff81395c27>] rpc_sleep_on+0x332/0x341
Apr  6 05:37:48 node010 kernel: [<ffffffff81391285>] xprt_reserve_xprt_cong+0x121/0x13d
Apr  6 05:37:48 node010 kernel: [<ffffffff813909fd>] xprt_prepare_transmit+0x6a/0x89
Apr  6 05:37:48 node010 kernel: [<ffffffff8138eb74>] call_transmit+0x53/0x255
Apr  6 05:37:48 node010 kernel: [<ffffffff81395684>] __rpc_execute+0x7b/0x24c
Apr  6 05:37:48 node010 kernel: [<ffffffff813958da>] rpc_execute+0x85/0x8e
Apr  6 05:37:48 node010 kernel: [<ffffffff8138f632>] rpc_run_task+0x56/0x5e
Apr  6 05:37:48 node010 kernel: [<ffffffff8138f725>] rpc_call_sync+0x3f/0x5d
Apr  6 05:37:48 node010 kernel: [<ffffffff81134eb3>] nfs3_rpc_wrapper+0x2b/0x5d
Apr  6 05:37:48 node010 kernel: [<ffffffff811355e6>] nfs3_proc_getattr+0x5b/0x81
Apr  6 05:37:48 node010 kernel: [<ffffffff811278da>] __nfs_revalidate_inode+0xbd/0x1c9
Apr  6 05:37:48 node010 kernel: [<ffffffff81131f9f>] ? nfs_scan_commit+0x2c/0x56
Apr  6 05:37:48 node010 kernel: [<ffffffff81132d01>] ? nfs_sync_mapping_wait+0x16d/0x22c
Apr  6 05:37:48 node010 kernel: [<ffffffff81127a85>] nfs_revalidate_inode+0x44/0x49
Apr  6 05:37:48 node010 kernel: [<ffffffff81127acc>] nfs_close_context+0x42/0x44
Apr  6 05:37:48 node010 kernel: [<ffffffff81127b54>] __put_nfs_open_context+0x86/0xae
Apr  6 05:37:48 node010 kernel: [<ffffffff81127bfe>] nfs_release+0x82/0x8d
Apr  6 05:37:48 node010 kernel: [<ffffffff81125bd5>] nfs_file_release+0x6c/0x71
Apr  6 05:37:48 node010 kernel: [<ffffffff8109c99e>] __fput+0xf6/0x1b3
Apr  6 05:37:48 node010 kernel: [<ffffffff8109ca73>] fput+0x18/0x1a
Apr  6 05:37:48 node010 kernel: [<ffffffff81099f0c>] filp_close+0x67/0x72
Apr  6 05:37:48 node010 kernel: [<ffffffff8103e04f>] put_files_struct+0x6b/0xc2
Apr  6 05:37:48 node010 kernel: [<ffffffff8103e0ee>] exit_files+0x48/0x50
Apr  6 05:37:48 node010 kernel: [<ffffffff8103f673>] do_exit+0x1d9/0x63f
Apr  6 05:37:48 node010 kernel: [<ffffffff8100f616>] oops_end+0xb3/0xbb
Apr  6 05:37:48 node010 kernel: [<ffffffff81025083>] no_context+0x1ea/0x1f9
Apr  6 05:37:48 node010 kernel: [<ffffffff81025245>] __bad_area_nosemaphore+0x1b3/0x1d9
Apr  6 05:37:48 node010 kernel: [<ffffffff811a9dc4>] ? cpumask_any_but+0x2b/0x38
Apr  6 05:37:48 node010 kernel: [<ffffffff810292e3>] ? flush_tlb_page+0x58/0x76
Apr  6 05:37:48 node010 kernel: [<ffffffff810252bd>] bad_area+0x42/0x4a
Apr  6 05:37:48 node010 kernel: [<ffffffff81025578>] do_page_fault+0x150/0x1de
Apr  6 05:37:48 node010 kernel: [<ffffffff813e16af>] page_fault+0x1f/0x30
Apr  6 05:37:48 node010 kernel: [<ffffffff81025448>] ? do_page_fault+0x20/0x1de
Apr  6 05:37:48 node010 kernel: [<ffffffff810255d7>] ? do_page_fault+0x1af/0x1de
Apr  6 05:37:48 node010 kernel: [<ffffffff813e16af>] page_fault+0x1f/0x30
Apr  6 05:37:48 node010 kernel: ---[ end trace 4d2269fd524616a5 ]---
Apr  6 05:47:09 node010 kernel: myprog.py[20292]: segfault at 0 ip (null) sp 00007fff3694b518 error 14 in python2.7[400000+1000]
Apr  6 05:50:01 node010 cron[28586]: (root) CMD (test -x /usr/sbin/run-crons && /usr/sbin/run-crons )
Apr  6 05:56:02 node010 kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000296
Apr  6 05:56:02 node010 kernel: IP: [<0000000000000296>] 0x296
Apr  6 05:56:02 node010 kernel: PGD cfab6067 PUD c806a067 PMD 0 
Apr  6 05:56:02 node010 kernel: Oops: 0010 [#2] SMP 
Apr  6 05:56:02 node010 kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host2/uevent
Apr  6 05:56:02 node010 kernel: CPU 0 
Apr  6 05:56:02 node010 kernel: Modules linked in:
Apr  6 05:56:02 node010 kernel: Pid: 10918, comm: water Tainted: G      D W  2.6.32.58-default #5 MS-7345
Apr  6 05:56:02 node010 kernel: RIP: 0010:[<0000000000000296>]  [<0000000000000296>] 0x296
Apr  6 05:56:02 node010 kernel: RSP: 0000:ffff880006407e78  EFLAGS: 00010292
Apr  6 05:56:02 node010 kernel: RAX: 0000000000000200 RBX: 0000000000000000 RCX: 0000000000000034
Apr  6 05:56:02 node010 kernel: RDX: 0000000000000000 RSI: ffffea0001747680 RDI: ffff880028007768
Apr  6 05:56:02 node010 kernel: RBP: ffff880006407ef8 R08: 0000000000000000 R09: 0000000000000000
Apr  6 05:56:02 node010 kernel: R10: 0000000000000002 R11: ffff880006407dd8 R12: ffff8800cf958690
Apr  6 05:56:02 node010 kernel: R13: 0000000000000014 R14: 0000000000000000 R15: ffff8800c80ff870
Apr  6 05:56:02 node010 kernel: FS:  00007f32fc32f720(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
Apr  6 05:56:02 node010 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Apr  6 05:56:02 node010 kernel: CR2: 0000000000000296 CR3: 00000000c818e000 CR4: 00000000000006f0
Apr  6 05:56:02 node010 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr  6 05:56:02 node010 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr  6 05:56:02 node010 kernel: Process water (pid: 10918, threadinfo ffff880006406000, task ffff8800cf91b040)
Apr  6 05:56:02 node010 kernel: Stack:
Apr  6 05:56:02 node010 kernel: 0000000000000000 ffff88012b098e30 0000000000000296 00007f32fbed2900
Apr  6 05:56:02 node010 kernel: <0> ffff88012cb19580 ffff8800cfa23ef8 0000000000000690 ffff88012b098e30
Apr  6 05:56:02 node010 kernel: <0> ffff88012b080d78 ffff88012b080d90 ffff880006407ee8 00007f32fbed2900
Apr  6 05:56:02 node010 kernel: Call Trace:
Apr  6 05:56:02 node010 kernel: [<ffffffff810255ef>] do_page_fault+0x1c7/0x1de
Apr  6 05:56:02 node010 kernel: [<ffffffff813e16af>] page_fault+0x1f/0x30
Apr  6 05:56:02 node010 kernel: Code:  Bad RIP value.
Apr  6 05:56:02 node010 kernel: RIP  [<0000000000000296>] 0x296
Apr  6 05:56:02 node010 kernel: RSP <ffff880006407e78>
Apr  6 05:56:02 node010 kernel: CR2: 0000000000000296
Apr  6 05:56:02 node010 kernel: ---[ end trace 4d2269fd524616a6 ]---
