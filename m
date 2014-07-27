Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.18]:58470 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbaG0JrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Jul 2014 05:47:24 -0400
Received: from [192.168.178.21] ([78.50.176.10]) by mail.gmx.com (mrgmx001)
 with ESMTPSA (Nemesis) id 0LvE2c-1WTiVX1UtW-010MzF for
 <linux-nfs@vger.kernel.org>; Sun, 27 Jul 2014 11:47:21 +0200
Message-ID: <53D4CAA7.2000005@gmx.de>
Date: Sun, 27 Jul 2014 11:47:19 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: fuzz testing a 32 bit UML guest with NFSv4 gave:  BUG kmalloc-256
 (Not tainted): Redzone overwritten
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

with current git kernel version 3.16.0-rc6-00139-g9c55021 I got today from the syslog :


Jul 26 23:40:18 trinity kernel: NFSD: unable to generate recoverydir name (-2).
Jul 26 23:40:18 trinity kernel: NFSD: disabling legacy clientid tracking. Reboot recovery will not function correctly!
Jul 26 23:40:22 trinity kernel: VFS: Warning: trinity-c1 using old stat() call. Recompile your binary.
Jul 26 23:40:23 trinity kernel: warning: process `trinity-c1' used the deprecated sysctl system call with
Jul 26 23:40:23 trinity kernel: VFS: Warning: trinity-c0 using old stat() call. Recompile your binary.
Jul 26 23:40:23 trinity kernel: VFS: Warning: trinity-c1 using old stat() call. Recompile your binary.
Jul 26 23:40:23 trinity kernel: VFS: Warning: trinity-c0 using old stat() call. Recompile your binary.
Jul 26 23:40:23 trinity kernel: trinity-c0 (1704) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.txt.
Jul 26 23:40:23 trinity kernel: VFS: Warning: trinity-c0 using old stat() call. Recompile your binary.
Jul 26 23:40:25 trinity kernel: =============================================================================
Jul 26 23:40:25 trinity kernel: BUG kmalloc-256 (Not tainted): Redzone overwritten
Jul 26 23:40:25 trinity kernel: -----------------------------------------------------------------------------
Jul 26 23:40:25 trinity kernel:
Jul 26 23:40:25 trinity kernel: Disabling lock debugging due to kernel taint
Jul 26 23:40:25 trinity kernel: INFO: 0x82f0e230-0x82f0e233. First byte 0xa0 instead of 0xcc
Jul 26 23:40:25 trinity kernel: INFO: Allocated in nfs_generic_pgio+0x86/0x2d0 age=0 cpu=0 pid=1705
Jul 26 23:40:25 trinity kernel: INFO: Freed in nfs_pgio_data_release+0x33/0x70 age=0 cpu=0 pid=610
Jul 26 23:40:25 trinity kernel: INFO: Slab 0x0b7228c0 objects=13 used=2 fp=0x82f0e000 flags=0x0080
Jul 26 23:40:25 trinity kernel: INFO: Object 0x82f0e130 @offset=304 fp=0x82f0e000
Jul 26 23:40:25 trinity kernel:
Jul 26 23:40:25 trinity kernel: Bytes b4 82f0e120: a9 06 00 00 52 cf ff ff 5a 5a 5a 5a 5a 5a 5a 5a  ....R...ZZZZZZZZ
Jul 26 23:40:25 trinity kernel: Object 82f0e130: e0 d3 6b 0b 80 e3 6b 0b a0 e3 6b 0b c0 e3 6b 0b  ..k...k...k...k.
Jul 26 23:40:25 trinity kernel: Object 82f0e140: e0 e3 6b 0b 80 13 6c 0b a0 13 6c 0b c0 13 6c 0b  ..k...l...l...l.
Jul 26 23:40:25 trinity kernel: Object 82f0e150: e0 13 6c 0b 00 12 6c 0b 20 12 6c 0b 40 12 6c 0b  ..l...l. .l.@.l.
Jul 26 23:40:25 trinity kernel: Object 82f0e160: 60 12 6c 0b 80 12 6c 0b a0 12 6c 0b c0 12 6c 0b  `.l...l...l...l.
Jul 26 23:40:25 trinity kernel: Object 82f0e170: e0 12 6c 0b 00 10 6c 0b 20 10 6c 0b 40 10 6c 0b  ..l...l. .l.@.l.
Jul 26 23:40:25 trinity kernel: Object 82f0e180: 60 10 6c 0b 80 10 6c 0b a0 10 6c 0b c0 10 6c 0b  `.l...l...l...l.
Jul 26 23:40:25 trinity kernel: Object 82f0e190: e0 10 6c 0b 00 11 6c 0b 20 11 6c 0b 40 11 6c 0b  ..l...l. .l.@.l.
Jul 26 23:40:25 trinity kernel: Object 82f0e1a0: 60 11 6c 0b 80 11 6c 0b a0 11 6c 0b 20 a4 70 0b  `.l...l...l. .p.
Jul 26 23:40:25 trinity kernel: Object 82f0e1b0: a0 ca 6f 0b c0 ca 6f 0b e0 ca 6f 0b 00 cb 6f 0b  ..o...o...o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e1c0: 20 cb 6f 0b 40 cb 6f 0b 60 cb 6f 0b 80 cb 6f 0b   .o.@.o.`.o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e1d0: a0 cb 6f 0b c0 cb 6f 0b e0 cb 6f 0b 00 cc 6f 0b  ..o...o...o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e1e0: 20 cc 6f 0b 40 cc 6f 0b 60 cc 6f 0b 80 cc 6f 0b   .o.@.o.`.o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e1f0: a0 cc 6f 0b c0 cc 6f 0b e0 cc 6f 0b 00 cd 6f 0b  ..o...o...o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e200: 20 cd 6f 0b 40 cd 6f 0b 60 cd 6f 0b 80 cd 6f 0b   .o.@.o.`.o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e210: a0 cd 6f 0b c0 cd 6f 0b e0 cd 6f 0b 00 ce 6f 0b  ..o...o...o...o.
Jul 26 23:40:25 trinity kernel: Object 82f0e220: 20 ce 6f 0b 40 ce 6f 0b 60 ce 6f 0b 80 ce 6f 0b   .o.@.o.`.o...o.
Jul 26 23:40:25 trinity kernel: Redzone 82f0e230: a0 ce 6f 0b                                      ..o.
Jul 26 23:40:25 trinity kernel: Padding 82f0e258: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
Jul 26 23:40:25 trinity kernel: CPU: 0 PID: 610 Comm: kworker/0:2 Tainted: G    B         3.16.0-rc6-00139-g9c55021 #85
Jul 26 23:40:25 trinity kernel: Workqueue: nfsiod rpc_async_release
Jul 26 23:40:25 trinity kernel: Stack:
Jul 26 23:40:25 trinity kernel: 085a296b 085a296b 00000003 086c8547 85449c00 00000128 0b7228c0 8572fd68
Jul 26 23:40:25 trinity kernel: 084e6736 00000000 8572fd3c 8572fda0 080ff083 085b1a4f 085b1a63 00000001
Jul 26 23:40:25 trinity kernel: 00000010 00000001 82f0e258 00000008 00000001 82f0e130 82f0e230 0b7228c0
Jul 26 23:40:25 trinity kernel: Call Trace:
Jul 26 23:40:25 trinity kernel: [<084e6736>] dump_stack+0x26/0x28
Jul 26 23:40:25 trinity kernel: [<080ff083>] print_trailer+0x1e3/0x1f0
Jul 26 23:40:25 trinity kernel: [<080ff989>] check_bytes_and_report+0xa9/0x100
Jul 26 23:40:25 trinity kernel: [<080ffa2c>] check_object+0x4c/0x210
Jul 26 23:40:25 trinity kernel: [<084e4599>] free_debug_processing+0xab/0x238
Jul 26 23:40:25 trinity kernel: [<0846870e>] ? rpc_wake_up_first+0x16e/0x190
Jul 26 23:40:25 trinity kernel: [<08496b55>] ? __gettimeofday+0x15/0x30
Jul 26 23:40:25 trinity kernel: [<084e475f>] __slab_free+0x39/0x223
Jul 26 23:40:25 trinity kernel: [<081e1d33>] ? nfs_pgio_data_release+0x33/0x70
Jul 26 23:40:25 trinity kernel: [<0808119c>] ? __local_bh_enable_ip+0x1c/0xa0
Jul 26 23:40:25 trinity kernel: [<08090293>] ? insert_work+0x73/0x90
Jul 26 23:40:25 trinity kernel: [<080729be>] ? set_signals+0x1e/0x40
Jul 26 23:40:25 trinity kernel: [<08101201>] kfree+0x111/0x150
Jul 26 23:40:25 trinity kernel: [<081e1d33>] ? nfs_pgio_data_release+0x33/0x70
Jul 26 23:40:25 trinity kernel: [<081e1d33>] ? nfs_pgio_data_release+0x33/0x70
Jul 26 23:40:25 trinity kernel: [<081e1d33>] nfs_pgio_data_release+0x33/0x70
Jul 26 23:40:25 trinity kernel: [<081e1d93>] nfs_pgio_release+0x23/0x30
Jul 26 23:40:25 trinity kernel: [<08467c80>] rpc_free_task+0x20/0x60
Jul 26 23:40:25 trinity kernel: [<08467cce>] rpc_async_release+0xe/0x10
Jul 26 23:40:25 trinity kernel: [<08090d11>] process_one_work+0x1a1/0x310
Jul 26 23:40:25 trinity kernel: [<084e7e65>] ? schedule+0x55/0x60
Jul 26 23:40:25 trinity kernel: [<0809116a>] worker_thread+0x2ea/0x530
Jul 26 23:40:25 trinity kernel: [<080729be>] ? set_signals+0x1e/0x40
Jul 26 23:40:25 trinity kernel: [<084e7e65>] ? schedule+0x55/0x60
Jul 26 23:40:25 trinity kernel: [<08090e80>] ? worker_thread+0x0/0x530
Jul 26 23:40:25 trinity kernel: [<08096806>] kthread+0xd6/0xe0
Jul 26 23:40:25 trinity kernel: [<0809dd7d>] ? finish_task_switch.isra.56+0x1d/0x70
Jul 26 23:40:25 trinity kernel: [<0806064b>] new_thread_handler+0x6b/0x90
Jul 26 23:40:25 trinity kernel:
Jul 26 23:40:25 trinity kernel: FIX kmalloc-256: Restoring 0x82f0e230-0x82f0e233=0xcc
Jul 26 23:40:25 trinity kernel:
Jul 26 23:40:26 trinity trinity: Detected kernel tainting. Last seed was 412561049


-- 
Toralf

