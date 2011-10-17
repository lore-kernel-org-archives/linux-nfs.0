Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:8768 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab1JQP6L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2011 11:58:11 -0400
Received: from g5t0029.atlanta.hp.com (g5t0029.atlanta.hp.com [16.228.8.141])
	by g6t0184.atlanta.hp.com (Postfix) with ESMTP id 9C9ECC0E4
	for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 15:58:10 +0000 (UTC)
Received: from [10.152.0.166] (openvpn.lnx.usa.hp.com [16.125.113.33])
	by g5t0029.atlanta.hp.com (Postfix) with ESMTP id F0C2F200F7
	for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 15:58:09 +0000 (UTC)
Subject: nfs: server 192.168.1.53 not responding, still trying - with
 backtrace
From: Dilip Daya <dilip.daya@hp.com>
Reply-To: dilip.daya@hp.com
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 Oct 2011 11:58:08 -0400
Message-ID: <1318867088.6187.19.camel@pro6455b.example.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm experiencing the following issue:

Environment:
NFS client and server both running kernel: 3.1.0-rc7-amd64

# nfsstat -m
/opt/xorsyst/nfs_test from 192.168.1.53:/opt/xorsyst/nfs_test
 Flags:
rw,relatime,vers=4,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,port=0,timeo=600,retrans=6,sec=sys,clientaddr=192.168.1.52,minorversion=0,local_lock=none,addr=192.168.1.53


root@dl385g5-2:~# cat /var/log/kern.log
Oct 16 16:48:56 dl385g5-2 kernel: [169292.007444] nfs: server
192.168.1.53 not responding, still trying
Oct 16 16:48:56 dl385g5-2 kernel: [169292.023387] nfs: server
192.168.1.53 OK
Oct 16 16:51:00 dl385g5-2 kernel: [169416.418880] nfs: server
192.168.1.53 not responding, still trying
Oct 16 16:51:00 dl385g5-2 kernel: [169416.445781] nfs: server
192.168.1.53 OK
Oct 17 08:56:33 dl385g5-2 kernel: [227349.728181] nfs: server
192.168.1.53 not responding, still trying
Oct 17 08:56:33 dl385g5-2 kernel: [227349.729314] nfs: server
192.168.1.53 not responding, still trying
Oct 17 08:56:33 dl385g5-2 kernel: [227349.730427] nfs: server
192.168.1.53 not responding, still trying
Oct 17 08:56:33 dl385g5-2 kernel: [227349.731753] nfs: server
192.168.1.53 not responding, still trying
Oct 17 08:59:31 dl385g5-2 kernel: [227523.904249] INFO: task
flush-0:20:19406 blocked for more than 120 seconds.
Oct 17 08:59:31 dl385g5-2 kernel: [227523.905508] "echo 0
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 17 08:59:31 dl385g5-2 kernel: [227523.906942] flush-0:20      D
ffff8800033a6fa0     0 19406      2 0x00000000
Oct 17 08:59:31 dl385g5-2 kernel: [227523.908319]  ffff8800033a6fa0
0000000000000046 0000000000000007 ffffffff81062878
Oct 17 08:59:31 dl385g5-2 kernel: [227523.909854]  ffff880087f96340
0000000000012f00 ffff8800b5d21fd8 ffff8800b5d21fd8
Oct 17 08:59:31 dl385g5-2 kernel: [227523.911452]  0000000000012f00
ffff8800033a6fa0 0000000000012f00 0000000000012f00
Oct 17 08:59:31 dl385g5-2 kernel: [227523.913129] Call Trace:
Oct 17 08:59:31 dl385g5-2 kernel: [227523.913757]
[<ffffffff81062878>] ? wake_up_bit+0x10/0x23
Oct 17 08:59:31 dl385g5-2 kernel: [227523.914976]
[<ffffffff81074878>] ? arch_local_irq_save+0x14/0x1d
Oct 17 08:59:31 dl385g5-2 kernel: [227523.916395]
[<ffffffff811109e8>] ? init_special_inode+0x8a/0x8a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.917721]
[<ffffffff811109f1>] ? inode_wait+0x9/0x10
Oct 17 08:59:31 dl385g5-2 kernel: [227523.918911]
[<ffffffff81343f3f>] ? __wait_on_bit+0x3e/0x71
Oct 17 08:59:31 dl385g5-2 kernel: [227523.920217]
[<ffffffff8111bb76>] ? inode_wait_for_writeback+0x96/0xbe
Oct 17 08:59:31 dl385g5-2 kernel: [227523.921699]
[<ffffffff810628b5>] ? autoremove_wake_function+0x2a/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.923166]
[<ffffffff8111c795>] ? wb_writeback+0x1ef/0x21c
Oct 17 08:59:31 dl385g5-2 kernel: [227523.924483]
[<ffffffff8111ce8b>] ? wb_do_writeback+0x186/0x1a2
Oct 17 08:59:31 dl385g5-2 kernel: [227523.925801]
[<ffffffff8111cf2d>] ? bdi_writeback_thread+0x86/0x20a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.927209]
[<ffffffff8111cea7>] ? wb_do_writeback+0x1a2/0x1a2
Oct 17 08:59:31 dl385g5-2 kernel: [227523.928619]
[<ffffffff8111cea7>] ? wb_do_writeback+0x1a2/0x1a2
Oct 17 08:59:31 dl385g5-2 kernel: [227523.929921]
[<ffffffff81062413>] ? kthread+0x7a/0x82
Oct 17 08:59:31 dl385g5-2 kernel: [227523.931075]
[<ffffffff8134bfb4>] ? kernel_thread_helper+0x4/0x10
Oct 17 08:59:31 dl385g5-2 kernel: [227523.932506]
[<ffffffff81062399>] ? kthread_worker_fn+0x149/0x149
Oct 17 08:59:31 dl385g5-2 kernel: [227523.933892]
[<ffffffff8134bfb0>] ? gs_change+0x13/0x13
Oct 17 08:59:31 dl385g5-2 kernel: [227523.935109] INFO: task
fblockio:3979 blocked for more than 120 seconds.
Oct 17 08:59:31 dl385g5-2 kernel: [227523.936605] "echo 0
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 17 08:59:31 dl385g5-2 kernel: [227523.938342] fblockio        D
ffff8800cf42b890     0  3979  16777 0x00000000
Oct 17 08:59:31 dl385g5-2 kernel: [227523.939933]  ffff8800cf42b890
0000000000000082 ffff8800a55c2910 ffff8800a55c2400
Oct 17 08:59:31 dl385g5-2 kernel: [227523.941606]  ffff8800033a6fa0
0000000000012f00 ffff8800b5d71fd8 ffff8800b5d71fd8
Oct 17 08:59:31 dl385g5-2 kernel: [227523.943201]  0000000000012f00
ffff8800cf42b890 0000000000012f00 0000000000012f00
Oct 17 08:59:31 dl385g5-2 kernel: [227523.944953] Call Trace:
Oct 17 08:59:31 dl385g5-2 kernel: [227523.945505]
[<ffffffff8101364e>] ? read_tsc+0x5/0x14
Oct 17 08:59:31 dl385g5-2 kernel: [227523.946660]
[<ffffffff810697f7>] ? timekeeping_get_ns+0xd/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.948005]
[<ffffffff810b82cc>] ? lock_page+0x20/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227523.949206]
[<ffffffff81343adf>] ? io_schedule+0x5b/0x75
Oct 17 08:59:31 dl385g5-2 kernel: [227523.950448]
[<ffffffff811adae2>] ? radix_tree_gang_lookup_slot+0x82/0xa4
Oct 17 08:59:31 dl385g5-2 kernel: [227523.952004]
[<ffffffff810b82d5>] ? sleep_on_page+0x9/0x10
Oct 17 08:59:31 dl385g5-2 kernel: [227523.953245]
[<ffffffff81343e41>] ? __wait_on_bit_lock+0x3c/0x85
Oct 17 08:59:31 dl385g5-2 kernel: [227523.954635]
[<ffffffff810b82a6>] ? __lock_page+0x5d/0x63
Oct 17 08:59:31 dl385g5-2 kernel: [227523.955899]
[<ffffffff810628b5>] ? autoremove_wake_function+0x2a/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.957372]
[<ffffffff810c1f50>] ? lock_page+0x11/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227523.958572]
[<ffffffff810c202a>] ? invalidate_inode_pages2_range+0x78/0x22e
Oct 17 08:59:31 dl385g5-2 kernel: [227523.960178]
[<ffffffffa0465d3e>] ? nfs_revalidate_mapping+0x70/0xfb [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227523.961713]
[<ffffffffa0463eb8>] ? nfs_file_read+0x96/0xd8 [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227523.963081]
[<ffffffff810fe0bb>] ? do_sync_read+0xb1/0xea
Oct 17 08:59:31 dl385g5-2 kernel: [227523.964335]
[<ffffffff8105849b>] ? group_send_sig_info+0x11/0x34
Oct 17 08:59:31 dl385g5-2 kernel: [227523.965735]
[<ffffffff810fe70f>] ? vfs_read+0x9f/0xf2
Oct 17 08:59:31 dl385g5-2 kernel: [227523.966945]
[<ffffffff810fe88b>] ? sys_pread64+0x53/0x6e
Oct 17 08:59:31 dl385g5-2 kernel: [227523.968179]
[<ffffffff81349e52>] ? system_call_fastpath+0x16/0x1b
Oct 17 08:59:31 dl385g5-2 kernel: [227523.969583] INFO: task
fblockio:3747 blocked for more than 120 seconds.
Oct 17 08:59:31 dl385g5-2 kernel: [227523.971060] "echo 0
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 17 08:59:31 dl385g5-2 kernel: [227523.972806] fblockio        D
ffff8800a55c2400     0  3747  16777 0x00000000
Oct 17 08:59:31 dl385g5-2 kernel: [227523.974141]  ffff8800a55c2400
0000000000000086 ffff8800b5c1b3b0 ffff8800b5c1aea0
Oct 17 08:59:31 dl385g5-2 kernel: [227523.975764]  ffff8800b5c1aea0
0000000000012f00 ffff8800b5dc7fd8 ffff8800b5dc7fd8
Oct 17 08:59:31 dl385g5-2 kernel: [227523.977465]  0000000000012f00
ffff8800a55c2400 0000000000012f00 0000000000012f00
Oct 17 08:59:31 dl385g5-2 kernel: [227523.979127] Call Trace:
Oct 17 08:59:31 dl385g5-2 kernel: [227523.979686]
[<ffffffff8101364e>] ? read_tsc+0x5/0x14
Oct 17 08:59:31 dl385g5-2 kernel: [227523.980845]
[<ffffffff810697f7>] ? timekeeping_get_ns+0xd/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.982175]
[<ffffffff810b82cc>] ? lock_page+0x20/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227523.983363]
[<ffffffff81343adf>] ? io_schedule+0x5b/0x75
Oct 17 08:59:31 dl385g5-2 kernel: [227523.984611]
[<ffffffff811adae2>] ? radix_tree_gang_lookup_slot+0x82/0xa4
Oct 17 08:59:31 dl385g5-2 kernel: [227523.986147]
[<ffffffff810b82d5>] ? sleep_on_page+0x9/0x10
Oct 17 08:59:31 dl385g5-2 kernel: [227523.987391]
[<ffffffff81343e41>] ? __wait_on_bit_lock+0x3c/0x85
Oct 17 08:59:31 dl385g5-2 kernel: [227523.988806]
[<ffffffff810b82a6>] ? __lock_page+0x5d/0x63
Oct 17 08:59:31 dl385g5-2 kernel: [227523.990028]
[<ffffffff810628b5>] ? autoremove_wake_function+0x2a/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227523.991506]
[<ffffffff810c1f50>] ? lock_page+0x11/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227523.992655]
[<ffffffff810c202a>] ? invalidate_inode_pages2_range+0x78/0x22e
Oct 17 08:59:31 dl385g5-2 kernel: [227523.994233]
[<ffffffffa0465d3e>] ? nfs_revalidate_mapping+0x70/0xfb [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227523.995796]
[<ffffffffa0463eb8>] ? nfs_file_read+0x96/0xd8 [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227523.997160]
[<ffffffff810fe0bb>] ? do_sync_read+0xb1/0xea
Oct 17 08:59:31 dl385g5-2 kernel: [227523.998421]
[<ffffffff810fe70f>] ? vfs_read+0x9f/0xf2
Oct 17 08:59:31 dl385g5-2 kernel: [227523.999604]
[<ffffffff810fe7a7>] ? sys_read+0x45/0x6b
Oct 17 08:59:31 dl385g5-2 kernel: [227524.000822]
[<ffffffff81349e52>] ? system_call_fastpath+0x16/0x1b
Oct 17 08:59:31 dl385g5-2 kernel: [227524.002210] INFO: task
fblockio:3749 blocked for more than 120 seconds.
Oct 17 08:59:31 dl385g5-2 kernel: [227524.003708] "echo 0
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 17 08:59:31 dl385g5-2 kernel: [227524.005455] fblockio        D
ffff8800b5c1aea0     0  3749  16777 0x00000000
Oct 17 08:59:31 dl385g5-2 kernel: [227524.007043]  ffff8800b5c1aea0
0000000000000086 ffff88012fc95dd0 0000000000000020
Oct 17 08:59:31 dl385g5-2 kernel: [227524.008712]  ffff880124a2d7d0
0000000000012f00 ffff8800a5653fd8 ffff8800a5653fd8
Oct 17 08:59:31 dl385g5-2 kernel: [227524.010308]  0000000000012f00
ffff8800b5c1aea0 0000000000012f00 0000000000012f00
Oct 17 08:59:31 dl385g5-2 kernel: [227524.011923] Call Trace:
Oct 17 08:59:31 dl385g5-2 kernel: [227524.012466]
[<ffffffff8101364e>] ? read_tsc+0x5/0x14
Oct 17 08:59:31 dl385g5-2 kernel: [227524.013630]
[<ffffffff810697f7>] ? timekeeping_get_ns+0xd/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227524.014967]
[<ffffffff810b82cc>] ? lock_page+0x20/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227524.016201]
[<ffffffff81343adf>] ? io_schedule+0x5b/0x75
Oct 17 08:59:31 dl385g5-2 kernel: [227524.017427]
[<ffffffff811adae2>] ? radix_tree_gang_lookup_slot+0x82/0xa4
Oct 17 08:59:31 dl385g5-2 kernel: [227524.018962]
[<ffffffff810b82d5>] ? sleep_on_page+0x9/0x10
Oct 17 08:59:31 dl385g5-2 kernel: [227524.020214]
[<ffffffff81343e41>] ? __wait_on_bit_lock+0x3c/0x85
Oct 17 08:59:31 dl385g5-2 kernel: [227524.021583]
[<ffffffff810b82a6>] ? __lock_page+0x5d/0x63
Oct 17 08:59:31 dl385g5-2 kernel: [227524.022808]
[<ffffffff810628b5>] ? autoremove_wake_function+0x2a/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227524.024302]
[<ffffffff810c1f50>] ? lock_page+0x11/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227524.025502]
[<ffffffff810c202a>] ? invalidate_inode_pages2_range+0x78/0x22e
Oct 17 08:59:31 dl385g5-2 kernel: [227524.027034]
[<ffffffffa0465d3e>] ? nfs_revalidate_mapping+0x70/0xfb [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227524.028633]
[<ffffffffa0463eb8>] ? nfs_file_read+0x96/0xd8 [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227524.030001]
[<ffffffff810fe0bb>] ? do_sync_read+0xb1/0xea
Oct 17 08:59:31 dl385g5-2 kernel: [227524.031261]
[<ffffffff810fe70f>] ? vfs_read+0x9f/0xf2
Oct 17 08:59:31 dl385g5-2 kernel: [227524.032435]
[<ffffffff810fe7a7>] ? sys_read+0x45/0x6b
Oct 17 08:59:31 dl385g5-2 kernel: [227524.033615]
[<ffffffff81349e52>] ? system_call_fastpath+0x16/0x1b
Oct 17 08:59:31 dl385g5-2 kernel: [227524.035009] INFO: task
fblockio:3752 blocked for more than 120 seconds.
Oct 17 08:59:31 dl385g5-2 kernel: [227524.036532] "echo 0
> /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 17 08:59:31 dl385g5-2 kernel: [227524.038269] fblockio        D
ffff8800cf446f20     0  3752  16777 0x00000000
Oct 17 08:59:31 dl385g5-2 kernel: [227524.039951]  ffff8800cf446f20
0000000000000082 ffff88012fff7e00 ffff8800b5f25be8
Oct 17 08:59:31 dl385g5-2 kernel: [227524.041682]  ffff88009e3e58d0
0000000000012f00 ffff8800b5f25fd8 ffff8800b5f25fd8
Oct 17 08:59:31 dl385g5-2 kernel: [227524.043283]  0000000000012f00
ffff8800cf446f20 0000000000012f00 0000000000012f00
Oct 17 08:59:31 dl385g5-2 kernel: [227524.044951] Call Trace:
Oct 17 08:59:31 dl385g5-2 kernel: [227524.045500]
[<ffffffff8101364e>] ? read_tsc+0x5/0x14
Oct 17 08:59:31 dl385g5-2 kernel: [227524.046604]
[<ffffffff810697f7>] ? timekeeping_get_ns+0xd/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227524.052184]
[<ffffffff810b82cc>] ? lock_page+0x20/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227524.053190]
[<ffffffff81343adf>] ? io_schedule+0x5b/0x75
Oct 17 08:59:31 dl385g5-2 kernel: [227524.054136]
[<ffffffff811adae2>] ? radix_tree_gang_lookup_slot+0x82/0xa4
Oct 17 08:59:31 dl385g5-2 kernel: [227524.055288]
[<ffffffff810b82d5>] ? sleep_on_page+0x9/0x10
Oct 17 08:59:31 dl385g5-2 kernel: [227524.056279]
[<ffffffff81343e41>] ? __wait_on_bit_lock+0x3c/0x85
Oct 17 08:59:31 dl385g5-2 kernel: [227524.057341]
[<ffffffff810b82a6>] ? __lock_page+0x5d/0x63
Oct 17 08:59:31 dl385g5-2 kernel: [227524.058303]
[<ffffffff810628b5>] ? autoremove_wake_function+0x2a/0x2a
Oct 17 08:59:31 dl385g5-2 kernel: [227524.059511]
[<ffffffff810c1f50>] ? lock_page+0x11/0x20
Oct 17 08:59:31 dl385g5-2 kernel: [227524.060437]
[<ffffffff810c202a>] ? invalidate_inode_pages2_range+0x78/0x22e
Oct 17 08:59:31 dl385g5-2 kernel: [227524.061687]
[<ffffffffa0465d3e>] ? nfs_revalidate_mapping+0x70/0xfb [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227524.077420]
[<ffffffffa0463eb8>] ? nfs_file_read+0x96/0xd8 [nfs]
Oct 17 08:59:31 dl385g5-2 kernel: [227524.078793]
[<ffffffff810fe0bb>] ? do_sync_read+0xb1/0xea
Oct 17 08:59:31 dl385g5-2 kernel: [227524.080020]
[<ffffffff810fe70f>] ? vfs_read+0x9f/0xf2
Oct 17 08:59:31 dl385g5-2 kernel: [227524.081149]
[<ffffffff810fe7a7>] ? sys_read+0x45/0x6b
Oct 17 08:59:31 dl385g5-2 kernel: [227524.082141]
[<ffffffff81349e52>] ? system_call_fastpath+0x16/0x1b
root@dl385g5-2:~# 


=> Found http://www.spinics.net/lists/linux-nfs/msg24282.html
Not exactly the same backtrace...any assistance would be helpful.


Thanking you'll in advance.
- Dilip Daya.

