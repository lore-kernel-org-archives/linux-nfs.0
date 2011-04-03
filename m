Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:46980 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab1DCPMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Apr 2011 11:12:34 -0400
Date: Sun, 3 Apr 2011 11:12:29 -0400
From: Jim Rees <rees@umich.edu>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: client hang in lock_flocks()
Message-ID: <20110403151229.GA13399@merit.edu>
References: <20110331165258.GA3048@merit.edu>
 <BANLkTinFftt0OiLYmY3cipXTtx1uTYoJPg@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BANLkTinFftt0OiLYmY3cipXTtx1uTYoJPg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peng Tao wrote:

  Would you please send the complete trace log, or maybe open a bugzilla
  entry and attach it there?

Here is everything that was reported to me.  I can ask for rpc info and a
tcpdump if that would be useful.

Note that the second set of traces seems to be a different problem but I've
included it in case they are related.

Mar 24 17:21:08 r38-13-78 kernel: INFO: task iozone:2657 blocked for more than 120 seconds.
Mar 24 17:21:08 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 24 17:21:08 r38-13-78 kernel: iozone          D ffff88024ac55f70     0  2657      1 0x00000080
Mar 24 17:21:08 r38-13-78 kernel: ffff88024cc65c50 0000000000000082 0000000000000000 0000000000000000
Mar 24 17:21:08 r38-13-78 kernel: ffff88024cc64010 ffff88024cc65fd8 00000000000136c0 ffff88024ac55bc0
Mar 24 17:21:08 r38-13-78 kernel: ffff88024ac55f78 ffff88024ac55f70 00000000000136c0 00000000000136c0
Mar 24 17:21:08 r38-13-78 kernel: Call Trace:
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff81139c1d>] ? lock_flocks+0x10/0x12
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8143e287>] rwsem_down_failed_common+0xd3/0x105
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8143e2e0>] rwsem_down_read_failed+0x12/0x14
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8120a5b4>] call_rwsem_down_read_failed+0x14/0x30
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8143d9c7>] ? down_read+0x32/0x36
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffffa03ddca6>] nfs4_proc_lock+0x224/0x342 [nfs]
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffffa03c39cb>] do_setlk+0x61/0xd5 [nfs]
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffffa03c3c66>] nfs_lock+0x170/0x17f [nfs]
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8113b4dc>] vfs_lock_file+0x24/0x38
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8113b823>] fcntl_setlk+0x15e/0x2a6
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff811058bb>] ? fsnotify_access+0x5d/0x65
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff81112dc6>] sys_fcntl+0x30e/0x4af
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8143eed0>] ? do_device_not_available+0x9/0xb
Mar 24 17:21:08 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
Mar 24 17:23:08 r38-13-78 kernel: INFO: task iozone:2657 blocked for more than 120 seconds.
Mar 24 17:23:08 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 24 17:23:08 r38-13-78 kernel: iozone          D ffff88024ac55f70     0  2657      1 0x00000080
Mar 24 17:23:08 r38-13-78 kernel: ffff88024cc65c50 0000000000000082 0000000000000000 0000000000000000
Mar 24 17:23:08 r38-13-78 kernel: ffff88024cc64010 ffff88024cc65fd8 00000000000136c0 ffff88024ac55bc0
Mar 24 17:23:08 r38-13-78 kernel: ffff88024ac55f78 ffff88024ac55f70 00000000000136c0 00000000000136c0
Mar 24 17:23:08 r38-13-78 kernel: Call Trace:
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff81139c1d>] ? lock_flocks+0x10/0x12
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8143e287>] rwsem_down_failed_common+0xd3/0x105
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8143e2e0>] rwsem_down_read_failed+0x12/0x14
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8120a5b4>] call_rwsem_down_read_failed+0x14/0x30
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8143d9c7>] ? down_read+0x32/0x36
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffffa03ddca6>] nfs4_proc_lock+0x224/0x342 [nfs]
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffffa03c39cb>] do_setlk+0x61/0xd5 [nfs]
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffffa03c3c66>] nfs_lock+0x170/0x17f [nfs]
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8113b4dc>] vfs_lock_file+0x24/0x38
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8113b823>] fcntl_setlk+0x15e/0x2a6
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff811058bb>] ? fsnotify_access+0x5d/0x65
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff81112dc6>] sys_fcntl+0x30e/0x4af
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8143eed0>] ? do_device_not_available+0x9/0xb
Mar 24 17:23:08 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
Mar 24 17:25:08 r38-13-78 kernel: INFO: task iozone:2657 blocked for more than 120 seconds.
Mar 24 17:25:08 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 24 17:25:08 r38-13-78 kernel: iozone          D ffff88024ac55f70     0  2657      1 0x00000080
Mar 24 17:25:08 r38-13-78 kernel: ffff88024cc65c50 0000000000000082 0000000000000000 0000000000000000
Mar 24 17:25:08 r38-13-78 kernel: ffff88024cc64010 ffff88024cc65fd8 00000000000136c0 ffff88024ac55bc0
Mar 24 17:25:08 r38-13-78 kernel: ffff88024ac55f78 ffff88024ac55f70 00000000000136c0 00000000000136c0
Mar 24 17:25:08 r38-13-78 kernel: Call Trace:
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff81139c1d>] ? lock_flocks+0x10/0x12
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8143e287>] rwsem_down_failed_common+0xd3/0x105
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8143e2e0>] rwsem_down_read_failed+0x12/0x14
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8120a5b4>] call_rwsem_down_read_failed+0x14/0x30
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8143d9c7>] ? down_read+0x32/0x36
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffffa03ddca6>] nfs4_proc_lock+0x224/0x342 [nfs]
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffffa03c39cb>] do_setlk+0x61/0xd5 [nfs]
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffffa03c3c66>] nfs_lock+0x170/0x17f [nfs]
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8113b4dc>] vfs_lock_file+0x24/0x38
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8113b823>] fcntl_setlk+0x15e/0x2a6
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff811058bb>] ? fsnotify_access+0x5d/0x65
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff81112dc6>] sys_fcntl+0x30e/0x4af
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8143eed0>] ? do_device_not_available+0x9/0xb
Mar 24 17:25:08 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b

************************** 

Mar 24 17:48:18 r38-13-78 kernel: INFO: task iozone:2718 blocked for more than 120 seconds.
Mar 24 17:48:18 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 24 17:48:18 r38-13-78 kernel: iozone          D ffff88024b72b190     0  2718      1 0x00000080
Mar 24 17:48:18 r38-13-78 kernel: ffff88024b8cfb08 0000000000000082 ffff88024b8cfa88 ffffffffa03f4d00
Mar 24 17:48:18 r38-13-78 kernel: ffff88024b8ce010 ffff88024b8cffd8 00000000000136c0 ffff88024b72ade0
Mar 24 17:48:18 r38-13-78 kernel: ffff88024b72b198 ffff88024b72b190 00000000000136c0 00000000000136c0
Mar 24 17:48:18 r38-13-78 kernel: Call Trace:
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c0fab>] ? sync_page+0x0/0x48
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff8143cd96>] io_schedule+0x6b/0xae
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c0fef>] sync_page+0x44/0x48
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff8143d2e3>] __wait_on_bit+0x43/0x76
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c114b>] wait_on_page_bit+0x6d/0x74
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff81067d3b>] ? wake_bit_function+0x0/0x2e
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c95f0>] ? pagevec_lookup_tag+0x20/0x29
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c145d>] filemap_fdatawait_range+0x9f/0x179
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c15e3>] filemap_write_and_wait_range+0x3e/0x51
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff81126f65>] vfs_fsync_range+0x30/0x75
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff81126fe6>] generic_write_sync+0x3c/0x3e
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810c1a53>] generic_file_aio_write+0x83/0xa1
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffffa03c6ef4>] nfs_file_write+0xd4/0x169 [nfs]
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff81105c26>] do_sync_write+0xc6/0x103
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff81067d02>] ? wake_up_bit+0x20/0x25
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff810f88cd>] ? slab_pre_alloc_hook+0x28/0x2c
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff811c800a>] ? security_file_permission+0x29/0x2e
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff811065b6>] vfs_write+0xa9/0x105
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff811066cb>] sys_write+0x45/0x6c
Mar 24 17:48:18 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
Mar 24 17:49:44 r38-13-78 ntpd[1161]: 0.0.0.0 c612 02 freq_set kernel 37.872 PPM
Mar 24 17:49:44 r38-13-78 ntpd[1161]: 0.0.0.0 c615 05 clock_sync
Mar 24 17:50:18 r38-13-78 kernel: INFO: task iozone:2718 blocked for more than 120 seconds.
Mar 24 17:50:18 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 24 17:50:18 r38-13-78 kernel: iozone          D ffff88024b72b190     0  2718      1 0x00000080
Mar 24 17:50:18 r38-13-78 kernel: ffff88024b8cfb08 0000000000000082 ffff88024b8cfa88 ffffffffa03f4d00
Mar 24 17:50:18 r38-13-78 kernel: ffff88024b8ce010 ffff88024b8cffd8 00000000000136c0 ffff88024b72ade0
Mar 24 17:50:18 r38-13-78 kernel: ffff88024b72b198 ffff88024b72b190 00000000000136c0 00000000000136c0
Mar 24 17:50:18 r38-13-78 kernel: Call Trace:
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c0fab>] ? sync_page+0x0/0x48
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff8143cd96>] io_schedule+0x6b/0xae
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c0fef>] sync_page+0x44/0x48
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff8143d2e3>] __wait_on_bit+0x43/0x76
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c114b>] wait_on_page_bit+0x6d/0x74
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff81067d3b>] ? wake_bit_function+0x0/0x2e
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c95f0>] ? pagevec_lookup_tag+0x20/0x29
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c145d>] filemap_fdatawait_range+0x9f/0x179
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c15e3>] filemap_write_and_wait_range+0x3e/0x51
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff81126f65>] vfs_fsync_range+0x30/0x75
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff81126fe6>] generic_write_sync+0x3c/0x3e
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810c1a53>] generic_file_aio_write+0x83/0xa1
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffffa03c6ef4>] nfs_file_write+0xd4/0x169 [nfs]
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff81105c26>] do_sync_write+0xc6/0x103
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff81067d02>] ? wake_up_bit+0x20/0x25
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff810f88cd>] ? slab_pre_alloc_hook+0x28/0x2c
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff811c800a>] ? security_file_permission+0x29/0x2e
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff811065b6>] vfs_write+0xa9/0x105
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff811066cb>] sys_write+0x45/0x6c
Mar 24 17:50:18 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
Mar 24 17:52:18 r38-13-78 kernel: INFO: task iozone:2718 blocked for more than 120 seconds.
Mar 24 17:52:18 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 24 17:52:18 r38-13-78 kernel: iozone          D ffff88024b72b190     0  2718      1 0x00000080
Mar 24 17:52:18 r38-13-78 kernel: ffff88024b8cfb08 0000000000000082 ffff88024b8cfa88 ffffffffa03f4d00
Mar 24 17:52:18 r38-13-78 kernel: ffff88024b8ce010 ffff88024b8cffd8 00000000000136c0 ffff88024b72ade0
Mar 24 17:52:18 r38-13-78 kernel: ffff88024b72b198 ffff88024b72b190 00000000000136c0 00000000000136c0
Mar 24 17:52:18 r38-13-78 kernel: Call Trace:
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c0fab>] ? sync_page+0x0/0x48
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff8143cd96>] io_schedule+0x6b/0xae
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c0fef>] sync_page+0x44/0x48
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff8143d2e3>] __wait_on_bit+0x43/0x76
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c114b>] wait_on_page_bit+0x6d/0x74
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff81067d3b>] ? wake_bit_function+0x0/0x2e
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c95f0>] ? pagevec_lookup_tag+0x20/0x29
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c145d>] filemap_fdatawait_range+0x9f/0x179
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c15e3>] filemap_write_and_wait_range+0x3e/0x51
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff81126f65>] vfs_fsync_range+0x30/0x75
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff81126fe6>] generic_write_sync+0x3c/0x3e
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810c1a53>] generic_file_aio_write+0x83/0xa1
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffffa03c6ef4>] nfs_file_write+0xd4/0x169 [nfs]
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff81105c26>] do_sync_write+0xc6/0x103
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff81067d02>] ? wake_up_bit+0x20/0x25
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff810f88cd>] ? slab_pre_alloc_hook+0x28/0x2c
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff811c800a>] ? security_file_permission+0x29/0x2e
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff811065b6>] vfs_write+0xa9/0x105
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff811066cb>] sys_write+0x45/0x6c
Mar 24 17:52:18 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b

**************************

Mar 30 23:47:07 r38-13-78 xinetd[1144]: START: shell pid=2604 from=::ffff:10.244.76.80
Mar 30 23:47:07 r38-13-78 rshd[2606]: root@r38-15-80 as root: cmd='/opt/iozone/bin/iozone -+s -t 1 -r 4 -s 4 -+c r38-15-80 '
Mar 30 23:47:07 r38-13-78 xinetd[1144]: EXIT: shell status=0 pid=2604 duration=0(sec)
Mar 30 23:47:12 r38-13-78 xinetd[1144]: START: shell pid=2625 from=::ffff:10.244.76.80
Mar 30 23:47:12 r38-13-78 rshd[2626]: root@r38-15-80 as root: cmd='/opt/iozone/bin/iozone -+s -t 1 -r 4 -s 4 -+c r38-15-80 '
Mar 30 23:47:12 r38-13-78 xinetd[1144]: EXIT: shell status=0 pid=2625 duration=0(sec)
Mar 30 23:47:49 r38-13-78 xinetd[1144]: START: shell pid=2648 from=::ffff:10.244.76.80
Mar 30 23:47:49 r38-13-78 rshd[2649]: root@r38-15-80 as root: cmd='/opt/iozone/bin/iozone -+s -t 1 -r 4 -s 4 -+c r38-15-80 '
Mar 30 23:47:49 r38-13-78 xinetd[1144]: EXIT: shell status=0 pid=2648 duration=0(sec)
Mar 30 23:47:54 r38-13-78 xinetd[1144]: START: shell pid=2669 from=::ffff:10.244.76.80
Mar 30 23:47:54 r38-13-78 rshd[2670]: root@r38-15-80 as root: cmd='/opt/iozone/bin/iozone -+s -t 1 -r 4 -s 4 -+c r38-15-80 '
Mar 30 23:47:54 r38-13-78 xinetd[1144]: EXIT: shell status=0 pid=2669 duration=0(sec)
Mar 30 23:51:26 r38-13-78 kernel: INFO: task iozone:2666 blocked for more than 120 seconds.
Mar 30 23:51:26 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 30 23:51:26 r38-13-78 kernel: iozone          D ffff88024cdf1aa0     0  2666      1 0x00000080
Mar 30 23:51:26 r38-13-78 kernel: ffff880246be7c50 0000000000000082 0000000000000000 0000000000000000
Mar 30 23:51:26 r38-13-78 kernel: ffff880246be6010 ffff880246be7fd8 00000000000136c0 ffff88024cdf16f0
Mar 30 23:51:26 r38-13-78 kernel: ffff88024cdf1aa8 ffff88024cdf1aa0 00000000000136c0 00000000000136c0
Mar 30 23:51:26 r38-13-78 kernel: Call Trace:
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8113978a>] ? lock_flocks+0x10/0x12
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8143dc37>] rwsem_down_failed_common+0xd3/0x105
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8143dc90>] rwsem_down_read_failed+0x12/0x14
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff81209f54>] call_rwsem_down_read_failed+0x14/0x30
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8143d377>] ? down_read+0x32/0x36
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffffa03dbd20>] nfs4_proc_lock+0x224/0x342 [nfs]
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffffa03c19af>] do_setlk+0x61/0xd5 [nfs]
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffffa03c1c4a>] nfs_lock+0x170/0x17f [nfs]
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8113af72>] vfs_lock_file+0x24/0x38
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8113b2b9>] fcntl_setlk+0x15e/0x2a6
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff811056d7>] ? fsnotify_access+0x5d/0x65
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff81112ad6>] sys_fcntl+0x30e/0x4af
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8143e890>] ? do_device_not_available+0x9/0xb
Mar 30 23:51:26 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
Mar 30 23:52:54 r38-13-78 ntpd[1153]: 0.0.0.0 c612 02 freq_set kernel 37.606 PPM
Mar 30 23:52:54 r38-13-78 ntpd[1153]: 0.0.0.0 c615 05 clock_sync
Mar 30 23:53:26 r38-13-78 kernel: INFO: task iozone:2666 blocked for more than 120 seconds.
Mar 30 23:53:26 r38-13-78 kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Mar 30 23:53:26 r38-13-78 kernel: iozone          D ffff88024cdf1aa0     0  2666      1 0x00000080
Mar 30 23:53:26 r38-13-78 kernel: ffff880246be7c50 0000000000000082 0000000000000000 0000000000000000
Mar 30 23:53:26 r38-13-78 kernel: ffff880246be6010 ffff880246be7fd8 00000000000136c0 ffff88024cdf16f0
Mar 30 23:53:26 r38-13-78 kernel: ffff88024cdf1aa8 ffff88024cdf1aa0 00000000000136c0 00000000000136c0
Mar 30 23:53:26 r38-13-78 kernel: Call Trace:
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8113978a>] ? lock_flocks+0x10/0x12
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8143dc37>] rwsem_down_failed_common+0xd3/0x105
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8143dc90>] rwsem_down_read_failed+0x12/0x14
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff81209f54>] call_rwsem_down_read_failed+0x14/0x30
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8143d377>] ? down_read+0x32/0x36
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffffa03dbd20>] nfs4_proc_lock+0x224/0x342 [nfs]
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffffa03c19af>] do_setlk+0x61/0xd5 [nfs]
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffffa03c1c4a>] nfs_lock+0x170/0x17f [nfs]
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8113af72>] vfs_lock_file+0x24/0x38
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8113b2b9>] fcntl_setlk+0x15e/0x2a6
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff811056d7>] ? fsnotify_access+0x5d/0x65
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff81112ad6>] sys_fcntl+0x30e/0x4af
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8143e890>] ? do_device_not_available+0x9/0xb
Mar 30 23:53:26 r38-13-78 kernel: [<ffffffff8100aa52>] system_call_fastpath+0x16/0x1b
Mar 30 23:55:26 r38-13-78 kernel: INFO: task iozone:2666 blocked for more than 120 seconds.
