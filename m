Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm1-vm2.access.bullet.mail.bf1.yahoo.com ([216.109.114.73]:60632
	"EHLO nm1-vm2.access.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755481AbbIBRBA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2015 13:01:00 -0400
From: Shawn Starr <shawn.starr@rogers.com>
To: linux-nfs@vger.kernel.org
Subject: [NFSv4.1] Deadlock on writes - RHEL 7.1 kernel - nfs_pageio_doio?
Date: Wed, 02 Sep 2015 12:53:50 -0400
Message-ID: <2535588.ljdrthqrNr@segfault>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello NFS devs,

While this is a CentOS/RHEL kernel: 3.10.0-229.4.2.el7.x86_64 (and old)

I was wondering your take on this deadlock, I cannot reproduce this and it seems to happen in our KVM VM images randomly so far only once. When we configure a VM it does two reboots, first sets up things then a final reboot where we have a fresh bootup with settings in place.


This could be from a cron thats running, but the VMs in question is pretty much idle, CPU skyrockets and they deadlock, can't ssh into them to examine why. We have remote syslog capturing, so I would never see this otherwise.

If anyone has ideas on how I can test this? This has been reported in the CentOS bugtracker by someone else also, I couldn't use their methods for reproduction.

below is the trace from kernel:

Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633104] INFO: task mysqld:2072 blocked for more than 120 seconds.
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633170] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633210] mysqld          D ffff880091813680     0  2072   1321 0x00000000
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633216]  ffff88008c24fad8 0000000000000082 ffff88008c24ffd8 0000000000013680
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633219]  ffff88008c24ffd8 0000000000013680 ffff88008b9fa220 ffff880091813f48
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633221]  ffff88008c24fb60 0000000000000002 ffffffff81156330 ffff88008c24fb50
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633224] Call Trace:
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633276]  [<ffffffff81156330>] ? wait_on_page_read+0x60/0x60
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633284]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633286]  [<ffffffff8115633e>] sleep_on_page+0xe/0x20
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633289]  [<ffffffff816083db>] __wait_on_bit_lock+0x5b/0xc0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633291]  [<ffffffff81156458>] __lock_page+0x78/0xa0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633306]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633310]  [<ffffffff81156d94>] __find_lock_page+0x54/0x70
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633313]  [<ffffffff81157882>] grab_cache_page_write_begin+0x62/0xd0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633338]  [<ffffffffa0340867>] nfs_write_begin+0x77/0x210 [nfs]
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633341]  [<ffffffff811568ae>] generic_file_buffered_write+0x11e/0x290
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633344]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633356]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633365]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633398]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633402]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633407]  [<ffffffff81052aff>] ? kvm_clock_get_cycles+0x1f/0x30
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633410]  [<ffffffff811c78a2>] SyS_pwrite64+0x92/0xc0
Aug 28 13:55:42 rl01-3-v1835 kernel: [74640.633415]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633069] INFO: task mysqld:2072 blocked for more than 120 seconds.
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633127] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633159] mysqld          D ffff880091813680     0  2072   1321 0x00000000
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633165]  ffff88008c24fad8 0000000000000082 ffff88008c24ffd8 0000000000013680
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633168]  ffff88008c24ffd8 0000000000013680 ffff88008b9fa220 ffff880091813f48
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633170]  ffff88008c24fb60 0000000000000002 ffffffff81156330 ffff88008c24fb50
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633172] Call Trace:
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633184]  [<ffffffff81156330>] ? wait_on_page_read+0x60/0x60
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633191]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633195]  [<ffffffff8115633e>] sleep_on_page+0xe/0x20
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633198]  [<ffffffff816083db>] __wait_on_bit_lock+0x5b/0xc0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633200]  [<ffffffff81156458>] __lock_page+0x78/0xa0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633205]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633207]  [<ffffffff81156d94>] __find_lock_page+0x54/0x70
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633210]  [<ffffffff81157882>] grab_cache_page_write_begin+0x62/0xd0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633224]  [<ffffffffa0340867>] nfs_write_begin+0x77/0x210 [nfs]
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633226]  [<ffffffff811568ae>] generic_file_buffered_write+0x11e/0x290
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633230]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633234]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633242]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633246]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633250]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633253]  [<ffffffff81052aff>] ? kvm_clock_get_cycles+0x1f/0x30
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633256]  [<ffffffff811c78a2>] SyS_pwrite64+0x92/0xc0
Aug 28 13:57:42 rl01-3-v1835 kernel: [74760.633259]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633144] INFO: task mysqld:2037 blocked for more than 120 seconds.
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633200] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633211] mysqld          D ffff880091813680     0  2037   1321 0x00000000
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633217]  ffff88008aeafab8 0000000000000082 ffff88008aeaffd8 0000000000013680
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633220]  ffff88008aeaffd8 0000000000013680 ffff88008ba36660 ffff880091813f48
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633222]  ffff880091c5def8 0000000000000002 ffffffffa034a5d0 ffff88008aeafb30
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633225] Call Trace:
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633246]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633255]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633262]  [<ffffffffa034a5de>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633266]  [<ffffffff816082a0>] __wait_on_bit+0x60/0x90
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633272]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633275]  [<ffffffff81608357>] out_of_line_wait_on_bit+0x87/0xb0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633280]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633287]  [<ffffffffa034bb13>] nfs_wait_on_request+0x33/0x40 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633295]  [<ffffffffa0350361>] nfs_updatepage+0x121/0x8a0 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633302]  [<ffffffffa0340c11>] nfs_write_end+0x121/0x350 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633306]  [<ffffffff81156919>] generic_file_buffered_write+0x189/0x290
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633309]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633312]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633318]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633323]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633326]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633329]  [<ffffffff811c76f8>] SyS_write+0x58/0xb0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633333]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633337] INFO: task mysqld:2072 blocked for more than 120 seconds.
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633358] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633370] mysqld          D ffff880091813680     0  2072   1321 0x00000000
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633372]  ffff88008c24fad8 0000000000000082 ffff88008c24ffd8 0000000000013680
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633375]  ffff88008c24ffd8 0000000000013680 ffff88008b9fa220 ffff880091813f48
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633376]  ffff88008c24fb60 0000000000000002 ffffffff81156330 ffff88008c24fb50
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633378] Call Trace:
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633382]  [<ffffffff81156330>] ? wait_on_page_read+0x60/0x60
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633385]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633387]  [<ffffffff8115633e>] sleep_on_page+0xe/0x20
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633389]  [<ffffffff816083db>] __wait_on_bit_lock+0x5b/0xc0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633391]  [<ffffffff81156458>] __lock_page+0x78/0xa0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633394]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633396]  [<ffffffff81156d94>] __find_lock_page+0x54/0x70
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633399]  [<ffffffff81157882>] grab_cache_page_write_begin+0x62/0xd0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633405]  [<ffffffffa0340867>] nfs_write_begin+0x77/0x210 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633407]  [<ffffffff811568ae>] generic_file_buffered_write+0x11e/0x290
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633410]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633413]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633419]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633422]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633425]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633430]  [<ffffffff81052aff>] ? kvm_clock_get_cycles+0x1f/0x30
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633433]  [<ffffffff811c78a2>] SyS_pwrite64+0x92/0xc0
Aug 28 13:59:42 rl01-3-v1835 kernel: [74880.633436]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 834 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 834 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 844 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 844 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 843 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 843 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 842 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 842 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 836 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 836 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 840 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 840 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Created slice user-48.slice.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 838 of user apache.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 838 of user apache.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 841 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 841 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 839 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 839 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 835 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 835 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Starting Session 837 of user root.
Aug 28 14:00:01 rl01-3-v1835 systemd[1]: Started Session 837 of user root.
Aug 28 14:01:01 rl01-3-v1835 systemd[1]: Starting Session 845 of user root.
Aug 28 14:01:01 rl01-3-v1835 systemd[1]: Started Session 845 of user root.
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633059] INFO: task mysqld:2037 blocked for more than 120 seconds.
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633084] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633094] mysqld          D ffff880091813680     0  2037   1321 0x00000000
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633098]  ffff88008aeafab8 0000000000000082 ffff88008aeaffd8 0000000000013680
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633101]  ffff88008aeaffd8 0000000000013680 ffff88008ba36660 ffff880091813f48
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633103]  ffff880091c5def8 0000000000000002 ffffffffa034a5d0 ffff88008aeafb30
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633106] Call Trace:
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633126]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633133]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633140]  [<ffffffffa034a5de>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633143]  [<ffffffff816082a0>] __wait_on_bit+0x60/0x90
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633150]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633153]  [<ffffffff81608357>] out_of_line_wait_on_bit+0x87/0xb0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633157]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633164]  [<ffffffffa034bb13>] nfs_wait_on_request+0x33/0x40 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633172]  [<ffffffffa0350361>] nfs_updatepage+0x121/0x8a0 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633179]  [<ffffffffa0340c11>] nfs_write_end+0x121/0x350 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633183]  [<ffffffff81156919>] generic_file_buffered_write+0x189/0x290
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633186]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633188]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633195]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633199]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633202]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633205]  [<ffffffff811c76f8>] SyS_write+0x58/0xb0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633209]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633212] INFO: task mysqld:2072 blocked for more than 120 seconds.
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633219] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633226] mysqld          D ffff880091813680     0  2072   1321 0x00000000
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633229]  ffff88008c24fad8 0000000000000082 ffff88008c24ffd8 0000000000013680
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633231]  ffff88008c24ffd8 0000000000013680 ffff88008b9fa220 ffff880091813f48
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633233]  ffff88008c24fb60 0000000000000002 ffffffff81156330 ffff88008c24fb50
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633235] Call Trace:
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633238]  [<ffffffff81156330>] ? wait_on_page_read+0x60/0x60
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633261]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633266]  [<ffffffff8115633e>] sleep_on_page+0xe/0x20
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633269]  [<ffffffff816083db>] __wait_on_bit_lock+0x5b/0xc0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633271]  [<ffffffff81156458>] __lock_page+0x78/0xa0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633273]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633275]  [<ffffffff81156d94>] __find_lock_page+0x54/0x70
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633278]  [<ffffffff81157882>] grab_cache_page_write_begin+0x62/0xd0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633284]  [<ffffffffa0340867>] nfs_write_begin+0x77/0x210 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633287]  [<ffffffff811568ae>] generic_file_buffered_write+0x11e/0x290
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633290]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633292]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633298]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633301]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633304]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633308]  [<ffffffff81052aff>] ? kvm_clock_get_cycles+0x1f/0x30
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633311]  [<ffffffff811c78a2>] SyS_pwrite64+0x92/0xc0
Aug 28 14:01:42 rl01-3-v1835 kernel: [75000.633314]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633102] INFO: task mysqld:2037 blocked for more than 120 seconds.
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633169] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633185] mysqld          D ffff880091813680     0  2037   1321 0x00000000
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633192]  ffff88008aeafab8 0000000000000082 ffff88008aeaffd8 0000000000013680
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633197]  ffff88008aeaffd8 0000000000013680 ffff88008ba36660 ffff880091813f48
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633200]  ffff880091c5def8 0000000000000002 ffffffffa034a5d0 ffff88008aeafb30
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633204] Call Trace:
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633231]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633239]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633250]  [<ffffffffa034a5de>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633254]  [<ffffffff816082a0>] __wait_on_bit+0x60/0x90
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633264]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633268]  [<ffffffff81608357>] out_of_line_wait_on_bit+0x87/0xb0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633274]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633286]  [<ffffffffa034bb13>] nfs_wait_on_request+0x33/0x40 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633299]  [<ffffffffa0350361>] nfs_updatepage+0x121/0x8a0 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633309]  [<ffffffffa0340c11>] nfs_write_end+0x121/0x350 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633314]  [<ffffffff81156919>] generic_file_buffered_write+0x189/0x290
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633320]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633324]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633346]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633354]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633359]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633363]  [<ffffffff811c76f8>] SyS_write+0x58/0xb0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633370]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633376] INFO: task mysqld:2072 blocked for more than 120 seconds.
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633390] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633402] mysqld          D ffff880091813680     0  2072   1321 0x00000000
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633411]  ffff88008c24fad8 0000000000000082 ffff88008c24ffd8 0000000000013680
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633414]  ffff88008c24ffd8 0000000000013680 ffff88008b9fa220 ffff880091813f48
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633417]  ffff88008c24fb60 0000000000000002 ffffffff81156330 ffff88008c24fb50
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633421] Call Trace:
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633426]  [<ffffffff81156330>] ? wait_on_page_read+0x60/0x60
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633431]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633434]  [<ffffffff8115633e>] sleep_on_page+0xe/0x20
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633438]  [<ffffffff816083db>] __wait_on_bit_lock+0x5b/0xc0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633441]  [<ffffffff81156458>] __lock_page+0x78/0xa0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633444]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633448]  [<ffffffff81156d94>] __find_lock_page+0x54/0x70
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633451]  [<ffffffff81157882>] grab_cache_page_write_begin+0x62/0xd0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633460]  [<ffffffffa0340867>] nfs_write_begin+0x77/0x210 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633480]  [<ffffffff811568ae>] generic_file_buffered_write+0x11e/0x290
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633485]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633488]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633494]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633498]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633503]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633507]  [<ffffffff81052aff>] ? kvm_clock_get_cycles+0x1f/0x30
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633511]  [<ffffffff811c78a2>] SyS_pwrite64+0x92/0xc0
Aug 28 14:03:42 rl01-3-v1835 kernel: [75120.633515]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 14:05:01 rl01-3-v1835 systemd[1]: Starting Session 847 of user root.
Aug 28 14:05:01 rl01-3-v1835 systemd[1]: Started Session 847 of user root.
Aug 28 14:05:01 rl01-3-v1835 systemd[1]: Starting Session 846 of user root.
Aug 28 14:05:01 rl01-3-v1835 systemd[1]: Started Session 846 of user root.
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633059] INFO: task mysqld:2037 blocked for more than 120 seconds.
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633088] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633100] mysqld          D ffff880091813680     0  2037   1321 0x00000000
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633105]  ffff88008aeafab8 0000000000000082 ffff88008aeaffd8 0000000000013680
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633109]  ffff88008aeaffd8 0000000000013680 ffff88008ba36660 ffff880091813f48
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633111]  ffff880091c5def8 0000000000000002 ffffffffa034a5d0 ffff88008aeafb30
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633113] Call Trace:
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633134]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633142]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633150]  [<ffffffffa034a5de>] nfs_wait_bit_uninterruptible+0xe/0x20 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633153]  [<ffffffff816082a0>] __wait_on_bit+0x60/0x90
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633159]  [<ffffffffa034a5d0>] ? nfs_pageio_doio+0x50/0x50 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633162]  [<ffffffff81608357>] out_of_line_wait_on_bit+0x87/0xb0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633167]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633174]  [<ffffffffa034bb13>] nfs_wait_on_request+0x33/0x40 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633182]  [<ffffffffa0350361>] nfs_updatepage+0x121/0x8a0 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633188]  [<ffffffffa0340c11>] nfs_write_end+0x121/0x350 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633193]  [<ffffffff81156919>] generic_file_buffered_write+0x189/0x290
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633196]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633198]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633204]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633209]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633213]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633216]  [<ffffffff811c76f8>] SyS_write+0x58/0xb0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633219]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633224] INFO: task mysqld:2072 blocked for more than 120 seconds.
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633232] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633240] mysqld          D ffff880091813680     0  2072   1321 0x00000000
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633243]  ffff88008c24fad8 0000000000000082 ffff88008c24ffd8 0000000000013680
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633245]  ffff88008c24ffd8 0000000000013680 ffff88008b9fa220 ffff880091813f48
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633247]  ffff88008c24fb60 0000000000000002 ffffffff81156330 ffff88008c24fb50
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633249] Call Trace:
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633251]  [<ffffffff81156330>] ? wait_on_page_read+0x60/0x60
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633254]  [<ffffffff8160a4dd>] io_schedule+0x9d/0x140
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633256]  [<ffffffff8115633e>] sleep_on_page+0xe/0x20
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633259]  [<ffffffff816083db>] __wait_on_bit_lock+0x5b/0xc0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633261]  [<ffffffff81156458>] __lock_page+0x78/0xa0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633264]  [<ffffffff81098390>] ? autoremove_wake_function+0x40/0x40
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633266]  [<ffffffff81156d94>] __find_lock_page+0x54/0x70
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633268]  [<ffffffff81157882>] grab_cache_page_write_begin+0x62/0xd0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633274]  [<ffffffffa0340867>] nfs_write_begin+0x77/0x210 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633277]  [<ffffffff811568ae>] generic_file_buffered_write+0x11e/0x290
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633279]  [<ffffffff81158a15>] __generic_file_aio_write+0x1d5/0x3e0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633282]  [<ffffffff81158c7d>] generic_file_aio_write+0x5d/0xc0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633288]  [<ffffffffa033fd1b>] nfs_file_write+0xbb/0x1d0 [nfs]
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633291]  [<ffffffff811c650d>] do_sync_write+0x8d/0xd0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633294]  [<ffffffff811c6cad>] vfs_write+0xbd/0x1e0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633297]  [<ffffffff81052aff>] ? kvm_clock_get_cycles+0x1f/0x30
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633300]  [<ffffffff811c78a2>] SyS_pwrite64+0x92/0xc0
Aug 28 14:05:42 rl01-3-v1835 kernel: [75240.633332]  [<ffffffff81614de9>] system_call_fastpath+0x16/0x1b
