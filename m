Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:36508 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754602Ab0JGXSl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 19:18:41 -0400
Date: Thu, 7 Oct 2010 18:18:35 -0500
From: Shawn Bohrer <sbohrer@rgmadvisors.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Subject: task blocked for more than 120 seconds.
Message-ID: <20101007231835.GB2657@BohrerMBP.rgmadvisors.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've got some machines with nfs mounted home directories and recently
had the machines lock up with the following output below from the
kernel logs.  This machine was running 2.6.32.21 at the time, and
was locked up for at least 20 minutes before we rebooted.  We've had
this happen to us twice now, so while I haven't tried I believe we can
reproduce it in about a day.

Does anyone have any insight on what may be happening here or any
suggestions for debugging?

Thanks,
Shawn

INFO: task java:24970 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
java          D ffff88189c50e198     0 24970  24239 0x00000000
 ffff88205b7339c8 0000000000000086 0000000000000000 000000005ae2d09c
 0000000000000286 0000000000000030 ffff88205b733988 000000010174a797
 ffff88205acd4a80 ffff88205b733fd8 000000000000e198 ffff88205acd4a80
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff8100c9ce>] ? common_interrupt+0xe/0x13
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff81047774>] ? __enqueue_entity+0x84/0x90
 [<ffffffff8104f7d5>] ? enqueue_task_fair+0x45/0x90
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task java:24982 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
java          D ffff8800283ee198     0 24982  24239 0x00000000
 ffff88104f6339c8 0000000000000086 0000000000000000 00000000ffffff10
 0000000000000286 0000000000000030 0000000000000282 000000010174a681
 ffff88105a592580 ffff88104f633fd8 000000000000e198 ffff88105a592580
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff810ffef9>] ? do_wp_page+0x109/0x7c0
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task hbitimestamp:23184 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
hbitimestamp  D ffff88109c6ae198     0 23184  23175 0x00000000
 ffff880855d179c8 0000000000000086 0000000000000000 000000005bb2d600
 0000000000000282 0000000000000030 0000000000000282 00000001017445ab
 ffff8808577bc640 ffff880855d17fd8 000000000000e198 ffff8808577bc640
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8100cb4e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8141c74e>] ? do_device_not_available+0xe/0x10
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task java:24970 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
java          D ffff88189c50e198     0 24970  24239 0x00000000
 ffff88205b7339c8 0000000000000086 0000000000000000 000000005ae2d09c
 0000000000000286 0000000000000030 ffff88205b733988 000000010174a797
 ffff88205acd4a80 ffff88205b733fd8 000000000000e198 ffff88205acd4a80
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff8100c9ce>] ? common_interrupt+0xe/0x13
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff81047774>] ? __enqueue_entity+0x84/0x90
 [<ffffffff8104f7d5>] ? enqueue_task_fair+0x45/0x90
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task java:24982 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
java          D ffff8800283ee198     0 24982  24239 0x00000000
 ffff88104f6339c8 0000000000000086 0000000000000000 00000000ffffff10
 0000000000000286 0000000000000030 0000000000000282 000000010174a681
 ffff88105a592580 ffff88104f633fd8 000000000000e198 ffff88105a592580
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff810ffef9>] ? do_wp_page+0x109/0x7c0
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task tail:22115 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
tail          D ffff88189c4ee198     0 22115  14494 0x00000000
 ffff88085b95bbd8 0000000000000086 0000000000000000 ffffffffa035d896
 ffff88205be57cc8 ffff88205be57cc8 ffff88205be57cc8 000000010174d70e
 ffff8808564fe400 ffff88085b95bfd8 000000000000e198 ffff8808564fe400
Call Trace:
 [<ffffffffa035d896>] ? __rpc_execute+0xd6/0x2a0 [sunrpc]
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa04037d2>] nfs_sync_mapping_wait+0x122/0x260 [nfs]
 [<ffffffffa0403aa9>] nfs_write_mapping+0x79/0xb0 [nfs]
 [<ffffffffa0403afa>] nfs_wb_nocommit+0x1a/0x20 [nfs]
 [<ffffffffa03f60f8>] nfs_getattr+0x128/0x140 [nfs]
 [<ffffffff811351d1>] vfs_getattr+0x51/0x80
 [<ffffffff8113548f>] vfs_fstat+0x3f/0x60
 [<ffffffff811354d4>] sys_newfstat+0x24/0x40
 [<ffffffff810841a4>] ? sys_nanosleep+0x74/0x80
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task hbitimestamp:23184 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
hbitimestamp  D ffff88109c6ae198     0 23184  23175 0x00000000
 ffff880855d179c8 0000000000000086 0000000000000000 000000005bb2d600
 0000000000000282 0000000000000030 0000000000000282 00000001017445ab
 ffff8808577bc640 ffff880855d17fd8 000000000000e198 ffff8808577bc640
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8100cb4e>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8141c74e>] ? do_device_not_available+0xe/0x10
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task java:24970 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
java          D ffff88189c50e198     0 24970  24239 0x00000000
 ffff88205b7339c8 0000000000000086 0000000000000000 000000005ae2d09c
 0000000000000286 0000000000000030 ffff88205b733988 000000010174a797
 ffff88205acd4a80 ffff88205b733fd8 000000000000e198 ffff88205acd4a80
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff8100c9ce>] ? common_interrupt+0xe/0x13
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff81047774>] ? __enqueue_entity+0x84/0x90
 [<ffffffff8104f7d5>] ? enqueue_task_fair+0x45/0x90
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task java:24982 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
java          D ffff8800283ee198     0 24982  24239 0x00000000
 ffff88104f6339c8 0000000000000086 0000000000000000 00000000ffffff10
 0000000000000286 0000000000000030 0000000000000282 000000010174a681
 ffff88105a592580 ffff88104f633fd8 000000000000e198 ffff88105a592580
Call Trace:
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff81419df3>] io_schedule+0x73/0xc0
 [<ffffffffa03fe02e>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
 [<ffffffff8141a61f>] __wait_on_bit+0x5f/0x90
 [<ffffffffa03fe020>] ? nfs_wait_bit_uninterruptible+0x0/0x20 [nfs]
 [<ffffffff8141a6c8>] out_of_line_wait_on_bit+0x78/0x90
 [<ffffffff8107fe50>] ? wake_bit_function+0x0/0x40
 [<ffffffff810e11ce>] ? find_get_page+0x1e/0xa0
 [<ffffffffa03fe00f>] nfs_wait_on_request+0x2f/0x40 [nfs]
 [<ffffffffa0403d77>] nfs_updatepage+0x107/0x4f0 [nfs]
 [<ffffffffa03f3a6a>] nfs_write_end+0x5a/0x2c0 [nfs]
 [<ffffffff810e0bb4>] generic_file_buffered_write+0x174/0x2a0
 [<ffffffff810e25f0>] __generic_file_aio_write+0x240/0x470
 [<ffffffff810e288f>] generic_file_aio_write+0x6f/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff810ffef9>] ? do_wp_page+0x109/0x7c0
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
INFO: task hbitimestamp:24427 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
hbitimestamp  D ffff88089c40e198     0 24427  24317 0x00000000
 ffff88205a0b3c88 0000000000000082 0000000000000000 0000000000000000
 ffff88205a0b3ca8 ffffffff814196a8 0000000000000000 00000001017777de
 ffff88205a6ec8c0 ffff88205a0b3fd8 000000000000e198 ffff88205a6ec8c0
Call Trace:
 [<ffffffff814196a8>] ? thread_return+0x4e/0x726
 [<ffffffff8141aac1>] __mutex_lock_slowpath+0xf1/0x170
 [<ffffffff8141a9ab>] mutex_lock+0x2b/0x50
 [<ffffffff810e2879>] generic_file_aio_write+0x59/0xe0
 [<ffffffffa03f371a>] nfs_file_write+0xda/0x1e0 [nfs]
 [<ffffffff8112fb7a>] do_sync_write+0xfa/0x140
 [<ffffffff810fcb91>] ? __do_fault+0x3e1/0x4c0
 [<ffffffff8107fe10>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8116a68f>] ? inotify_inode_queue_event+0x2f/0x120
 [<ffffffff811bd246>] ? security_file_permission+0x16/0x20
 [<ffffffff8112fe78>] vfs_write+0xb8/0x1a0
 [<ffffffff81130711>] sys_write+0x51/0x90
 [<ffffffff8141c74e>] ? do_device_not_available+0xe/0x10
 [<ffffffff8100c11b>] system_call_fastpath+0x16/0x1b
