Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41674 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318Ab0H0QJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Aug 2010 12:09:29 -0400
Date: Fri, 27 Aug 2010 12:09:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Artem.Bityutskiy@nokia.com, Jens Axboe <jaxboe@fusionio.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: hang in writeback code on nfsv4 mount
Message-ID: <20100827160912.GA18790@fieldses.org>
References: <20100825023425.GA24591@fieldses.org>
 <1282889595.2763.14.camel@localhost>
 <1282901780.12016.54.camel@localhost>
 <4C77B873.8010306@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C77B873.8010306@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 27, 2010 at 09:06:59AM -0400, Bryan Schumaker wrote:
>  The patch fixed my unmount hang.

For me, after applying the patch to the latest upstream, the behavior is
still the same: a hang on mount; blocked-task warning and sysrq-t dump
follow.

--b.

INFO: task mount.nfs4:4314 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mount.nfs4    D 0000000000000000  2880  4314   4313 0x00000000
 ffff88001ed6da28 0000000000000046 ffff88001ed6dfd8 ffff88001ed6dfd8
 ffff88001ed6c000 ffff88001ed6c000 ffff88001ed6c000 ffff88001e5003a0
 ffff88001ed6dfd8 ffff88001e5003a8 ffff88001ed6c000 ffff88001ed6dfd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff8106a31c>] ? mark_held_locks+0x6c/0xa0
 [<ffffffff819639a0>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff8195fc80>] wait_for_common+0x120/0x190
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff8195fdcd>] wait_for_completion+0x1d/0x20
 [<ffffffff810595fa>] kthread_stop+0x4a/0x150
 [<ffffffff81061a60>] ? thaw_process+0x70/0x80
 [<ffffffff810cc68a>] bdi_unregister+0x10a/0x1a0
 [<ffffffff81229dc9>] nfs_put_super+0x19/0x20
 [<ffffffff810ee8c4>] generic_shutdown_super+0x54/0xe0
 [<ffffffff810ee9b6>] kill_anon_super+0x16/0x60
 [<ffffffff8122d3b9>] nfs4_kill_super+0x39/0x90
 [<ffffffff810eda45>] deactivate_locked_super+0x45/0x60
 [<ffffffff810edfb9>] deactivate_super+0x49/0x70
 [<ffffffff81108294>] mntput_no_expire+0x84/0xe0
 [<ffffffff811084ef>] release_mounts+0x9f/0xc0
 [<ffffffff81108575>] put_mnt_ns+0x65/0x80
 [<ffffffff8122cc56>] nfs_follow_remote_path+0x1e6/0x420
 [<ffffffff8122cfbf>] nfs4_try_mount+0x6f/0xd0
 [<ffffffff8122d0c2>] nfs4_get_sb+0xa2/0x360
 [<ffffffff810edcb8>] vfs_kern_mount+0x88/0x1f0
 [<ffffffff810ede92>] do_kern_mount+0x52/0x130
 [<ffffffff81963d9a>] ? _lock_kernel+0x6a/0x170
 [<ffffffff81108e9e>] do_mount+0x26e/0x7f0
 [<ffffffff81106b3a>] ? copy_mount_options+0xea/0x190
 [<ffffffff811094b8>] sys_mount+0x98/0xf0
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
1 lock held by mount.nfs4/4314:
 #0:  (&type->s_umount_key#24){+.+...}, at: [<ffffffff810edfb1>] deactivate_super+0x41/0x70

---

SysRq : Show State
  task                        PC stack   pid father
init          S 0000000000000000  4024     1      0 0x00000000
 ffff88001f4bd8f8 0000000000000046 ffff88001f4bdfd8 ffff88001f4bdfd8
 ffff88001f4bc000 ffff88001f4bc000 ffff88001f4bc000 ffff88001f4ba3a0
 ffff88001f4bdfd8 ffff88001f4ba3a8 ffff88001f4bc000 ffff88001f4bdfd8
Call Trace:
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81059ca6>] ? add_wait_queue+0x46/0x60
 [<ffffffff810fe474>] ? __pollwait+0x74/0xf0
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce3e3>] ? might_fault+0xc3/0xd0
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
kthreadd      S 0000000000000000  6072     2      0 0x00000000
 ffff88001f4c1f10 0000000000000046 ffff88001f4c1fd8 ffff88001f4c1fd8
 ffff88001f4c0000 ffff88001f4c0000 ffff88001f4c0000 ffff88001f4be3e0
 ffff88001f4c1fd8 ffff88001f4be3e8 ffff88001f4c0000 ffff88001f4c1fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff810595a6>] kthreadd+0xf6/0x100
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff810594b0>] ? kthreadd+0x0/0x100
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ksoftirqd/0   S 0000000000000000  6600     3      2 0x00000000
 ffff88001f4c7e80 0000000000000046 ffff88001f4c7fd8 ffff88001f4c7fd8
 ffff88001f4c6000 ffff88001f4c6000 ffff88001f4c6000 ffff88001f4c43a0
 ffff88001f4c7fd8 ffff88001f4c43a8 ffff88001f4c6000 ffff88001f4c7fd8
Call Trace:
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8103f427>] run_ksoftirqd+0x117/0x190
 [<ffffffff8103f310>] ? run_ksoftirqd+0x0/0x190
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kworker/0:0   S 0000000000000000  6248     4      2 0x00000000
 ffff88001f4cbe30 0000000000000046 ffff88001f4cbfd8 ffff88001f4cbfd8
 ffff88001f4ca000 ffff88001f4ca000 ffff88001f4ca000 ffff88001f4c83e0
 ffff88001f4cbfd8 ffff88001f4c83e8 ffff88001f4ca000 ffff88001f4cbfd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81055458>] worker_thread+0x1f8/0x390
 [<ffffffff81055260>] ? worker_thread+0x0/0x390
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kworker/u:0   S 0000000000000000  3928     5      2 0x00000000
 ffff88001f4ede30 0000000000000046 ffff88001f4edfd8 ffff88001f4edfd8
 ffff88001f4ec000 ffff88001f4ec000 ffff88001f4ec000 ffff88001f4ea3a0
 ffff88001f4edfd8 ffff88001f4ea3a8 ffff88001f4ec000 ffff88001f4edfd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81055458>] worker_thread+0x1f8/0x390
 [<ffffffff81055260>] ? worker_thread+0x0/0x390
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
khelper       S 0000000000000000  6840     6      2 0x00000000
 ffff88001f4f3e30 0000000000000046 ffff88001f4f3fd8 ffff88001f4f3fd8
 ffff88001f4f2000 ffff88001f4f2000 ffff88001f4f2000 ffff88001f4f03e0
 ffff88001f4f3fd8 ffff88001f4f03e8 ffff88001f4f2000 ffff88001f4f3fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kworker/u:1   S 0000000000000000  5672     7      2 0x00000000
 ffff88001f4f9e30 0000000000000046 ffff88001f4f9fd8 ffff88001f4f9fd8
 ffff88001f4f8000 ffff88001f4f8000 ffff88001f4f8000 ffff88001f4f63a0
 ffff88001f4f9fd8 ffff88001f4f63a8 ffff88001f4f8000 ffff88001f4f9fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81055458>] worker_thread+0x1f8/0x390
 [<ffffffff81055260>] ? worker_thread+0x0/0x390
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
sync_supers   S 0000000000000000  6968   266      2 0x00000000
 ffff88001f55be90 0000000000000046 ffff88001f55bfd8 ffff88001f55bfd8
 ffff88001f55a000 ffff88001f55a000 ffff88001f55a000 ffff88001f5583e0
 ffff88001f55bfd8 ffff88001f5583e8 ffff88001f55a000 ffff88001f55bfd8
Call Trace:
 [<ffffffff810cc1c0>] ? bdi_sync_supers+0x0/0x50
 [<ffffffff810cc1f4>] bdi_sync_supers+0x34/0x50
 [<ffffffff810cc1c0>] ? bdi_sync_supers+0x0/0x50
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
bdi-default   S 0000000000000000  6312   268      2 0x00000000
 ffff88001f589d30 0000000000000046 ffff88001f589fd8 ffff88001f589fd8
 ffff88001f588000 ffff88001f588000 ffff88001f588000 ffff88001f51c3e0
 ffff88001f589fd8 ffff88001f51c3e8 ffff88001f588000 ffff88001f589fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff819608b5>] schedule_timeout+0x175/0x2e0
 [<ffffffff81048900>] ? process_timeout+0x0/0x10
 [<ffffffff810ccec2>] bdi_forker_thread+0x212/0x4d0
 [<ffffffff810cccb0>] ? bdi_forker_thread+0x0/0x4d0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kblockd       S 0000000000000000  6840   270      2 0x00000000
 ffff88001f5c7e30 0000000000000046 ffff88001f5c7fd8 ffff88001f5c7fd8
 ffff88001f5c6000 ffff88001f5c6000 ffff88001f5c6000 ffff88001f5143e0
 ffff88001f5c7fd8 ffff88001f5143e8 ffff88001f5c6000 ffff88001f5c7fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kacpid        S 0000000000000000  6840   272      2 0x00000000
 ffff88001f5c5e30 0000000000000046 ffff88001f5c5fd8 ffff88001f5c5fd8
 ffff88001f5c4000 ffff88001f5c4000 ffff88001f5c4000 ffff88001f5543a0
 ffff88001f5c5fd8 ffff88001f5543a8 ffff88001f5c4000 ffff88001f5c5fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kacpi_notify  S 0000000000000000  6840   273      2 0x00000000
 ffff88001f557e30 0000000000000046 ffff88001f557fd8 ffff88001f557fd8
 ffff88001f556000 ffff88001f556000 ffff88001f556000 ffff88001f55c3a0
 ffff88001f557fd8 ffff88001f55c3a8 ffff88001f556000 ffff88001f557fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kacpi_hotplug S 0000000000000000  6840   274      2 0x00000000
 ffff88001f55fe30 0000000000000046 ffff88001f55ffd8 ffff88001f55ffd8
 ffff88001f55e000 ffff88001f55e000 ffff88001f55e000 ffff88001f5a03e0
 ffff88001f55ffd8 ffff88001f5a03e8 ffff88001f55e000 ffff88001f55ffd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ata_sff       S 0000000000000000  6840   346      2 0x00000000
 ffff88001f603e30 0000000000000046 ffff88001f603fd8 ffff88001f603fd8
 ffff88001f602000 ffff88001f602000 ffff88001f602000 ffff88001f5b03a0
 ffff88001f603fd8 ffff88001f5b03a8 ffff88001f602000 ffff88001f603fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
khubd         S 0000000000000000  3416   352      2 0x00000000
 ffff88001f631d50 0000000000000046 ffff88001f631fd8 ffff88001f631fd8
 ffff88001f630000 ffff88001f630000 ffff88001f630000 ffff88001f5ae3e0
 ffff88001f631fd8 ffff88001f5ae3e8 ffff88001f630000 ffff88001f631fd8
Call Trace:
 [<ffffffff81059c2d>] ? prepare_to_wait+0x4d/0x80
 [<ffffffff81725fda>] hub_thread+0xdfa/0x1180
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff817251e0>] ? hub_thread+0x0/0x1180
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kseriod       S 0000000000000000  5176   355      2 0x00000000
 ffff88001f63fe20 0000000000000046 ffff88001f63ffd8 ffff88001f63ffd8
 ffff88001f63e000 ffff88001f63e000 ffff88001f63e000 ffff88001f63c3a0
 ffff88001f63ffd8 ffff88001f63c3a8 ffff88001f63e000 ffff88001f63ffd8
Call Trace:
 [<ffffffff81059c2d>] ? prepare_to_wait+0x4d/0x80
 [<ffffffff817516df>] serio_thread+0x32f/0x360
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff817513b0>] ? serio_thread+0x0/0x360
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
khpsbpkt      S 0000000000000000  6768   453      2 0x00000000
 ffff88001f667e70 0000000000000046 ffff88001f667fd8 ffff88001f667fd8
 ffff88001f666000 ffff88001f666000 ffff88001f666000 ffff88001f6643a0
 ffff88001f667fd8 ffff88001f6643a8 ffff88001f666000 ffff88001f667fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff816f6d7a>] hpsbpkt_thread+0x13a/0x140
 [<ffffffff816f6c40>] ? hpsbpkt_thread+0x0/0x140
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
rpciod        S 0000000000000000  6840   461      2 0x00000000
 ffff88001f67de30 0000000000000046 ffff88001f67dfd8 ffff88001f67dfd8
 ffff88001f67c000 ffff88001f67c000 ffff88001f67c000 ffff88001f6843a0
 ffff88001f67dfd8 ffff88001f6843a8 ffff88001f67c000 ffff88001f67dfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kworker/0:1   S 0000000000000000  4824   462      2 0x00000000
 ffff88001f625e30 0000000000000046 ffff88001f625fd8 ffff88001f625fd8
 ffff88001f624000 ffff88001f624000 ffff88001f624000 ffff88001f6803e0
 ffff88001f625fd8 ffff88001f6803e8 ffff88001f624000 ffff88001f625fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81055458>] worker_thread+0x1f8/0x390
 [<ffffffff81055260>] ? worker_thread+0x0/0x390
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
khungtaskd    S 0000000000000000  5936   484      2 0x00000000
 ffff88001f723d90 0000000000000046 ffff88001f723fd8 ffff88001f723fd8
 ffff88001f722000 ffff88001f722000 ffff88001f722000 ffff88001e5ea3a0
 ffff88001f723fd8 ffff88001e5ea3a8 ffff88001f722000 ffff88001f723fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff819608b5>] schedule_timeout+0x175/0x2e0
 [<ffffffff81048900>] ? process_timeout+0x0/0x10
 [<ffffffff81960a7d>] schedule_timeout_interruptible+0x1d/0x20
 [<ffffffff8108707a>] watchdog+0x5a/0x300
 [<ffffffff8108709e>] ? watchdog+0x7e/0x300
 [<ffffffff81087020>] ? watchdog+0x0/0x300
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kswapd0       S 0000000000000000  6288   485      2 0x00000000
 ffff88001f711de0 0000000000000046 ffff88001f711fd8 ffff88001f711fd8
 ffff88001f710000 ffff88001f710000 ffff88001f710000 ffff88001e5e63e0
 ffff88001f711fd8 ffff88001e5e63e8 ffff88001f710000 ffff88001f711fd8
Call Trace:
 [<ffffffff81059c2d>] ? prepare_to_wait+0x4d/0x80
 [<ffffffff810c45a4>] kswapd+0x304/0x420
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff810c42a0>] ? kswapd+0x0/0x420
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
fsnotify_mark S 0000000000000000  6312   486      2 0x00000000
 ffff88001f715e20 0000000000000046 ffff88001f715fd8 ffff88001f715fd8
 ffff88001f714000 ffff88001f714000 ffff88001f714000 ffff88001e5e23a0
 ffff88001f715fd8 ffff88001e5e23a8 ffff88001f714000 ffff88001f715fd8
Call Trace:
 [<ffffffff81059c2d>] ? prepare_to_wait+0x4d/0x80
 [<ffffffff81123561>] fsnotify_mark_destroy+0x151/0x190
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81123410>] ? fsnotify_mark_destroy+0x0/0x190
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
aio           S 0000000000000000  6840   487      2 0x00000000
 ffff88001f719e30 0000000000000046 ffff88001f719fd8 ffff88001f719fd8
 ffff88001f718000 ffff88001f718000 ffff88001f718000 ffff88001e5de3e0
 ffff88001f719fd8 ffff88001e5de3e8 ffff88001f718000 ffff88001f719fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
nfsiod        S 0000000000000000  6840   491      2 0x00000000
 ffff88001e5cbe30 0000000000000046 ffff88001e5cbfd8 ffff88001e5cbfd8
 ffff88001e5ca000 ffff88001e5ca000 ffff88001e5ca000 ffff88001f70c3e0
 ffff88001e5cbfd8 ffff88001f70c3e8 ffff88001e5ca000 ffff88001e5cbfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
jfsIO         S 0000000000000000  6800   492      2 0x00000000
 ffff88001f913e90 0000000000000046 ffff88001f913fd8 ffff88001f913fd8
 ffff88001f912000 ffff88001f912000 ffff88001f912000 ffff88001f6983a0
 ffff88001f913fd8 ffff88001f6983a8 ffff88001f912000 ffff88001f913fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff812b7750>] ? jfsIOWait+0x0/0xc0
 [<ffffffff812b7800>] jfsIOWait+0xb0/0xc0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
jfsCommit     S 0000000000000000  6656   493      2 0x00000000
 ffff88001f915e30 0000000000000046 ffff88001f915fd8 ffff88001f915fd8
 ffff88001f914000 ffff88001f914000 ffff88001f914000 ffff88001f7083a0
 ffff88001f915fd8 ffff88001f7083a8 ffff88001f914000 ffff88001f915fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff812bc7c7>] jfs_lazycommit+0x267/0x290
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff812bc560>] ? jfs_lazycommit+0x0/0x290
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
jfsSync       S 0000000000000000  6768   494      2 0x00000000
 ffff88001f919e70 0000000000000046 ffff88001f919fd8 ffff88001f919fd8
 ffff88001f918000 ffff88001f918000 ffff88001f918000 ffff88001f6cc3e0
 ffff88001f919fd8 ffff88001f6cc3e8 ffff88001f918000 ffff88001f919fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff812bc3e8>] jfs_sync+0x228/0x240
 [<ffffffff812bc1c0>] ? jfs_sync+0x0/0x240
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
xfs_mru_cache S 0000000000000000  6840   495      2 0x00000000
 ffff88001f6a1e30 0000000000000046 ffff88001f6a1fd8 ffff88001f6a1fd8
 ffff88001f6a0000 ffff88001f6a0000 ffff88001f6a0000 ffff88001f6703a0
 ffff88001f6a1fd8 ffff88001f6703a8 ffff88001f6a0000 ffff88001f6a1fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
xfslogd       S 0000000000000000  6840   496      2 0x00000000
 ffff88001f71de30 0000000000000046 ffff88001f71dfd8 ffff88001f71dfd8
 ffff88001f71c000 ffff88001f71c000 ffff88001f71c000 ffff88001f6783e0
 ffff88001f71dfd8 ffff88001f6783e8 ffff88001f71c000 ffff88001f71dfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
xfsdatad      S 0000000000000000  6840   497      2 0x00000000
 ffff88001f91be30 0000000000000046 ffff88001f91bfd8 ffff88001f91bfd8
 ffff88001f91a000 ffff88001f91a000 ffff88001f91a000 ffff88001e5da3a0
 ffff88001f91bfd8 ffff88001e5da3a8 ffff88001f91a000 ffff88001f91bfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
xfsconvertd   S 0000000000000000  6840   498      2 0x00000000
 ffff88001f91de30 0000000000000046 ffff88001f91dfd8 ffff88001f91dfd8
 ffff88001f91c000 ffff88001f91c000 ffff88001f91c000 ffff88001f68c3a0
 ffff88001f91dfd8 ffff88001f68c3a8 ffff88001f91c000 ffff88001f91dfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ocfs2_wq      S 0000000000000000  6840   499      2 0x00000000
 ffff88001f91fe30 0000000000000046 ffff88001f91ffd8 ffff88001f91ffd8
 ffff88001f91e000 ffff88001f91e000 ffff88001f91e000 ffff88001f6a83e0
 ffff88001f91ffd8 ffff88001f6a83e8 ffff88001f91e000 ffff88001f91ffd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
o2quot        S 0000000000000000  6840   500      2 0x00000000
 ffff88001f923e30 0000000000000046 ffff88001f923fd8 ffff88001f923fd8
 ffff88001f922000 ffff88001f922000 ffff88001f922000 ffff88001f7003e0
 ffff88001f923fd8 ffff88001f7003e8 ffff88001f922000 ffff88001f923fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
user_dlm      S 0000000000000000  6840   502      2 0x00000000
 ffff88001f92be30 0000000000000046 ffff88001f92bfd8 ffff88001f92bfd8
 ffff88001f92a000 ffff88001f92a000 ffff88001f92a000 ffff88001f9283a0
 ffff88001f92bfd8 ffff88001f9283a8 ffff88001f92a000 ffff88001f92bfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
crypto        S 0000000000000000  6840   505      2 0x00000000
 ffff88001f945e30 0000000000000046 ffff88001f945fd8 ffff88001f945fd8
 ffff88001f944000 ffff88001f944000 ffff88001f944000 ffff88001f9423e0
 ffff88001f945fd8 ffff88001f9423e8 ffff88001f944000 ffff88001f945fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
vballoon      S 0000000000000000  6576   573      2 0x00000000
 ffff88001f9e1df0 0000000000000046 ffff88001f9e1fd8 ffff88001f9e1fd8
 ffff88001f9e0000 ffff88001f9e0000 ffff88001f9e0000 ffff88001f9ea3e0
 ffff88001f9e1fd8 ffff88001f9ea3e8 ffff88001f9e0000 ffff88001f9e1fd8
Call Trace:
 [<ffffffff8155d850>] ? vp_get+0x50/0x70
 [<ffffffff8155ed90>] balloon+0x320/0x3f0
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8155ea70>] ? balloon+0x0/0x3f0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
scsi_eh_0     S 0000000000000000  5688  1169      2 0x00000000
 ffff88001fbd7e20 0000000000000046 ffff88001fbd7fd8 ffff88001fbd7fd8
 ffff88001fbd6000 ffff88001fbd6000 ffff88001fbd6000 ffff88001fb8e3e0
 ffff88001fbd7fd8 ffff88001fb8e3e8 ffff88001fbd6000 ffff88001fbd7fd8
Call Trace:
 [<ffffffff81684967>] scsi_error_handler+0x97/0x610
 [<ffffffff816848d0>] ? scsi_error_handler+0x0/0x610
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
scsi_eh_1     S 0000000000000000  5000  1172      2 0x00000000
 ffff88001fbefe20 0000000000000046 ffff88001fbeffd8 ffff88001fbeffd8
 ffff88001fbee000 ffff88001fbee000 ffff88001fbee000 ffff88001fbec3e0
 ffff88001fbeffd8 ffff88001fbec3e8 ffff88001fbee000 ffff88001fbeffd8
Call Trace:
 [<ffffffff81684967>] scsi_error_handler+0x97/0x610
 [<ffffffff816848d0>] ? scsi_error_handler+0x0/0x610
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kpsmoused     S 0000000000000000  6840  1222      2 0x00000000
 ffff88001fba1e30 0000000000000046 ffff88001fba1fd8 ffff88001fba1fd8
 ffff88001fba0000 ffff88001fba0000 ffff88001fba0000 ffff88001f9de3a0
 ffff88001fba1fd8 ffff88001f9de3a8 ffff88001fba0000 ffff88001fba1fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kstriped      S 0000000000000000  6840  1230      2 0x00000000
 ffff88001fbf5e30 0000000000000046 ffff88001fbf5fd8 ffff88001fbf5fd8
 ffff88001fbf4000 ffff88001fbf4000 ffff88001fbf4000 ffff88001fb6a3a0
 ffff88001fbf5fd8 ffff88001fb6a3a8 ffff88001fbf4000 ffff88001fbf5fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kmpathd       S 0000000000000000  6840  1232      2 0x00000000
 ffff88001fb23e30 0000000000000046 ffff88001fb23fd8 ffff88001fb23fd8
 ffff88001fb22000 ffff88001fb22000 ffff88001fb22000 ffff88001e1223a0
 ffff88001fb23fd8 ffff88001e1223a8 ffff88001fb22000 ffff88001fb23fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kmpath_handle S 0000000000000000  6840  1233      2 0x00000000
 ffff88001f9d5e30 0000000000000046 ffff88001f9d5fd8 ffff88001f9d5fd8
 ffff88001f9d4000 ffff88001f9d4000 ffff88001f9d4000 ffff88001e1263e0
 ffff88001f9d5fd8 ffff88001e1263e8 ffff88001f9d4000 ffff88001f9d5fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ksnapd        S 0000000000000000  6840  1234      2 0x00000000
 ffff88001f9cbe30 0000000000000046 ffff88001f9cbfd8 ffff88001f9cbfd8
 ffff88001f9ca000 ffff88001f9ca000 ffff88001f9ca000 ffff88001fbf63a0
 ffff88001f9cbfd8 ffff88001fbf63a8 ffff88001f9ca000 ffff88001f9cbfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
edac-poller   S 0000000000000000  6840  1237      2 0x00000000
 ffff88001f9dde30 0000000000000046 ffff88001f9ddfd8 ffff88001f9ddfd8
 ffff88001f9dc000 ffff88001f9dc000 ffff88001f9dc000 ffff88001f9d63e0
 ffff88001f9ddfd8 ffff88001f9d63e8 ffff88001f9dc000 ffff88001f9ddfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ib_mcast      S 0000000000000000  6840  1239      2 0x00000000
 ffff88001fb95e30 0000000000000046 ffff88001fb95fd8 ffff88001fb95fd8
 ffff88001fb94000 ffff88001fb94000 ffff88001fb94000 ffff88001fb663e0
 ffff88001fb95fd8 ffff88001fb663e8 ffff88001fb94000 ffff88001fb95fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ib_cm         S 0000000000000000  6840  1241      2 0x00000000
 ffff88001fbe1e30 0000000000000046 ffff88001fbe1fd8 ffff88001fbe1fd8
 ffff88001fbe0000 ffff88001fbe0000 ffff88001fbe0000 ffff88001fb963e0
 ffff88001fbe1fd8 ffff88001fb963e8 ffff88001fbe0000 ffff88001fbe1fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
iw_cm_wq      S 0000000000000000  6840  1242      2 0x00000000
 ffff88001e133e30 0000000000000046 ffff88001e133fd8 ffff88001e133fd8
 ffff88001e132000 ffff88001e132000 ffff88001e132000 ffff88001fb9c3a0
 ffff88001e133fd8 ffff88001fb9c3a8 ffff88001e132000 ffff88001e133fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ib_addr       S 0000000000000000  6840  1243      2 0x00000000
 ffff88001e135e30 0000000000000046 ffff88001e135fd8 ffff88001e135fd8
 ffff88001e134000 ffff88001e134000 ffff88001e134000 ffff88001fbf23e0
 ffff88001e135fd8 ffff88001fbf23e8 ffff88001e134000 ffff88001e135fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
rdma_cm       S 0000000000000000  6840  1244      2 0x00000000
 ffff88001e13be30 0000000000000046 ffff88001e13bfd8 ffff88001e13bfd8
 ffff88001e13a000 ffff88001e13a000 ffff88001e13a000 ffff88001e1383e0
 ffff88001e13bfd8 ffff88001e1383e8 ffff88001e13a000 ffff88001e13bfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
usbhid_resume S 0000000000000000  6840  1273      2 0x00000000
 ffff88001e199e30 0000000000000046 ffff88001e199fd8 ffff88001e199fd8
 ffff88001e198000 ffff88001e198000 ffff88001e198000 ffff88001e1963a0
 ffff88001e199fd8 ffff88001e1963a8 ffff88001e198000 ffff88001e199fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kdmflush      S 0000000000000000  6840  2899      2 0x00000000
 ffff88001d967e30 0000000000000046 ffff88001d967fd8 ffff88001d967fd8
 ffff88001d966000 ffff88001d966000 ffff88001d966000 ffff88001d98c3e0
 ffff88001d967fd8 ffff88001d98c3e8 ffff88001d966000 ffff88001d967fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
kdmflush      S 0000000000000000  6840  2909      2 0x00000000
 ffff88001d9b7e30 0000000000000046 ffff88001d9b7fd8 ffff88001d9b7fd8
 ffff88001d9b6000 ffff88001d9b6000 ffff88001d9b6000 ffff88001d9883a0
 ffff88001d9b7fd8 ffff88001d9883a8 ffff88001d9b6000 ffff88001d9b7fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8196933c>] ? kprobe_flush_task+0xbc/0xe0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
jbd2/dm-0-8   S 0000000000000000  4752  2919      2 0x00000000
 ffff88001d8e9e30 0000000000000046 ffff88001d8e9fd8 ffff88001d8e9fd8
 ffff88001d8e8000 ffff88001d8e8000 ffff88001d8e8000 ffff88001d9983a0
 ffff88001d8e9fd8 ffff88001d9983a8 ffff88001d8e8000 ffff88001d8e9fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8120b434>] kjournald2+0x284/0x3b0
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8120b1b0>] ? kjournald2+0x0/0x3b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ext4-dio-unwr S 0000000000000000  6840  2920      2 0x00000000
 ffff88001d97de30 0000000000000046 ffff88001d97dfd8 ffff88001d97dfd8
 ffff88001d97c000 ffff88001d97c000 ffff88001d97c000 ffff88001d9943e0
 ffff88001d97dfd8 ffff88001d9943e8 ffff88001d97c000 ffff88001d97dfd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
udevd         S 0000000000000000  5552  2990      1 0x00000000
 ffff88001f70fa68 0000000000000046 ffff88001f70ffd8 ffff88001f70ffd8
 ffff88001f70e000 ffff88001f70e000 ffff88001f70e000 ffff88001fb923a0
 ffff88001f70ffd8 ffff88001fb923a8 ffff88001f70e000 ffff88001f70ffd8
Call Trace:
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81963a85>] ? _raw_spin_unlock+0x35/0x60
 [<ffffffff818b28bf>] ? unix_peer_get+0x3f/0x50
 [<ffffffff818b3410>] ? unix_dgram_poll+0x110/0x1b0
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fd257>] do_sys_poll+0x467/0x530
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8106a64d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81121ccd>] ? fsnotify+0x7d/0x340
 [<ffffffff8182cf2a>] ? sockfd_lookup_light+0x2a/0x90
 [<ffffffff8182d833>] ? sys_recvfrom+0xb3/0x120
 [<ffffffff81002508>] ? sysret_check+0x26/0x60
 [<ffffffff810fd51c>] sys_poll+0x7c/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
jbd2/vda1-8   S 0000000000000000  6824  3258      2 0x00000000
 ffff88001f673e30 0000000000000046 ffff88001f673fd8 ffff88001f673fd8
 ffff88001f672000 ffff88001f672000 ffff88001f672000 ffff88001e1923e0
 ffff88001f673fd8 ffff88001e1923e8 ffff88001f672000 ffff88001f673fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8120b434>] kjournald2+0x284/0x3b0
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8120b1b0>] ? kjournald2+0x0/0x3b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
ext4-dio-unwr S 0000000000000000  6840  3259      2 0x00000000
 ffff88001d965e30 0000000000000046 ffff88001d965fd8 ffff88001d965fd8
 ffff88001d964000 ffff88001d964000 ffff88001d964000 ffff88001eb163e0
 ffff88001d965fd8 ffff88001eb163e8 ffff88001d964000 ffff88001d965fd8
Call Trace:
 [<ffffffff81031ce9>] ? set_user_nice+0xc9/0x140
 [<ffffffff81055202>] rescuer_thread+0x152/0x1b0
 [<ffffffff810550b0>] ? rescuer_thread+0x0/0x1b0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
udevd         S 0000000000000000  5184  3323   2990 0x00000000
 ffff88001ea0da18 0000000000000046 ffff88001ea0dfd8 ffff88001ea0dfd8
 ffff88001ea0c000 ffff88001ea0c000 ffff88001ea0c000 ffff88001e9b03a0
 ffff88001ea0dfd8 ffff88001e9b03a8 ffff88001ea0c000 ffff88001ea0dfd8
Call Trace:
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81059ca6>] ? add_wait_queue+0x46/0x60
 [<ffffffff810fe474>] ? __pollwait+0x74/0xf0
 [<ffffffff8102c717>] ? wakeup_preempt_entity+0x47/0x50
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fd257>] do_sys_poll+0x467/0x530
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff81963a12>] ? _raw_spin_unlock_irqrestore+0x42/0x80
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff818309f6>] ? sock_def_readable+0x96/0xe0
 [<ffffffff81830960>] ? sock_def_readable+0x0/0xe0
 [<ffffffff81963a85>] ? _raw_spin_unlock+0x35/0x60
 [<ffffffff818b5681>] ? unix_dgram_sendmsg+0x5b1/0x660
 [<ffffffff8182d472>] ? sys_sendmsg+0x172/0x290
 [<ffffffff8104a5e3>] ? sigprocmask+0x43/0x100
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff819639a0>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff819639ab>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffff810fd36c>] sys_ppoll+0x4c/0x180
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
udevd         S 0000000000000000  5184  3324   2990 0x00000000
 ffff88001e985a18 0000000000000046 ffff88001e985fd8 ffff88001e985fd8
 ffff88001e984000 ffff88001e984000 ffff88001e984000 ffff88001eac03e0
 ffff88001e985fd8 ffff88001eac03e8 ffff88001e984000 ffff88001e985fd8
Call Trace:
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81059ca6>] ? add_wait_queue+0x46/0x60
 [<ffffffff810fe474>] ? __pollwait+0x74/0xf0
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fd257>] do_sys_poll+0x467/0x530
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810b4420>] ? find_get_page+0x0/0x180
 [<ffffffff81830a2d>] ? sock_def_readable+0xcd/0xe0
 [<ffffffff81830960>] ? sock_def_readable+0x0/0xe0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff810ceb58>] ? __do_fault+0x138/0x4e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff810d0e0a>] ? handle_mm_fault+0x17a/0x830
 [<ffffffff8104a5e3>] ? sigprocmask+0x43/0x100
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff819639a0>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff819639ab>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffff810fd36c>] sys_ppoll+0x4c/0x180
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
flush-252:0   S 0000000000000000  4136  3456      2 0x00000000
 ffff88001e49bd80 0000000000000046 ffff88001e49bfd8 ffff88001e49bfd8
 ffff88001e49a000 ffff88001e49a000 ffff88001e49a000 ffff88001eb5a3e0
 ffff88001e49bfd8 ffff88001eb5a3e8 ffff88001e49a000 ffff88001e49bfd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff819608b5>] schedule_timeout+0x175/0x2e0
 [<ffffffff81048900>] ? process_timeout+0x0/0x10
 [<ffffffff811109f3>] bdi_writeback_thread+0x193/0x2f0
 [<ffffffff81110860>] ? bdi_writeback_thread+0x0/0x2f0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
rsyslogd      S 0000000000000000  5248  3520      1 0x00000000
 ffff88001ee1b8f8 0000000000000046 ffff88001ee1bfd8 ffff88001ee1bfd8
 ffff88001ee1a000 ffff88001ee1a000 ffff88001ee1a000 ffff88001d9163e0
 ffff88001ee1bfd8 ffff88001d9163e8 ffff88001ee1a000 ffff88001ee1bfd8
Call Trace:
 [<ffffffff81961dcf>] schedule_hrtimeout_range_clock+0xaf/0x140
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810d1377>] ? handle_mm_fault+0x6e7/0x830
 [<ffffffff810d12b3>] ? handle_mm_fault+0x623/0x830
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff8106bf79>] ? __lock_acquire+0x399/0x1bc0
 [<ffffffff810b8ea3>] ? __rmqueue+0xd3/0x4f0
 [<ffffffff8106bf79>] ? __lock_acquire+0x399/0x1bc0
 [<ffffffff810b4420>] ? find_get_page+0x0/0x180
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff810ceb58>] ? __do_fault+0x138/0x4e0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff81063776>] ? ktime_get_ts+0xa6/0xe0
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rsyslogd      S 0000000000000000  5184  3522      1 0x00000000
 ffff88001eb158f8 0000000000000046 ffff88001eb15fd8 ffff88001eb15fd8
 ffff88001eb14000 ffff88001eb14000 ffff88001eb14000 ffff88001ed203e0
 ffff88001eb15fd8 ffff88001ed203e8 ffff88001eb14000 ffff88001eb15fd8
Call Trace:
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81963a85>] ? _raw_spin_unlock+0x35/0x60
 [<ffffffff818b28bf>] ? unix_peer_get+0x3f/0x50
 [<ffffffff818b3410>] ? unix_dgram_poll+0x110/0x1b0
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff814ebc8d>] ? rb_insert_color+0x9d/0x160
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81032530>] ? finish_task_switch.clone.3+0x0/0xd0
 [<ffffffff819639a0>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff819639ab>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81032530>] ? finish_task_switch.clone.3+0x0/0xd0
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rsyslogd      S 0000000000000000  6296  3523      1 0x00000000
 ffff88001d8dfe08 0000000000000046 ffff88001d8dffd8 ffff88001d8dffd8
 ffff88001d8de000 ffff88001d8de000 ffff88001d8de000 ffff88001e1403e0
 ffff88001d8dffd8 ffff88001e1403e8 ffff88001d8de000 ffff88001d8dffd8
Call Trace:
 [<ffffffff81059c2d>] ? prepare_to_wait+0x4d/0x80
 [<ffffffff8103a901>] do_syslog+0x491/0x510
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff811489d0>] ? kmsg_read+0x0/0x70
 [<ffffffff81148a07>] kmsg_read+0x37/0x70
 [<ffffffff8113dd35>] proc_reg_read+0x85/0xc0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rsyslogd      S 0000000000000000  5648  4401      1 0x00000000
 ffff88001e9c9c28 0000000000000046 ffff88001e9c9fd8 ffff88001e9c9fd8
 ffff88001e9c8000 ffff88001e9c8000 ffff88001e9c8000 ffff88001f9563e0
 ffff88001e9c9fd8 ffff88001f9563e8 ffff88001e9c8000 ffff88001e9c9fd8
Call Trace:
 [<ffffffff8106f3c2>] futex_wait_queue_me+0xc2/0x100
 [<ffffffff810707ef>] futex_wait+0x1df/0x350
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81071b21>] do_futex+0x121/0xb20
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff8107259b>] sys_futex+0x7b/0x180
 [<ffffffff8106a500>] ? trace_hardirqs_on_caller+0x50/0x190
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rpcbind       S 0000000000000000  5184  3531      1 0x00000000
 ffff88001f587a68 0000000000000046 ffff88001f587fd8 ffff88001f587fd8
 ffff88001f586000 ffff88001f586000 ffff88001f586000 ffff88001f7343e0
 ffff88001f587fd8 ffff88001f7343e8 ffff88001f586000 ffff88001f587fd8
Call Trace:
 [<ffffffff81961dcf>] schedule_hrtimeout_range_clock+0xaf/0x140
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81838a7a>] ? datagram_poll+0xea/0x100
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fd257>] do_sys_poll+0x467/0x530
 [<ffffffff81840230>] ? dev_queue_xmit+0x0/0x680
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff814f772f>] ? debug_check_no_obj_freed+0x18f/0x210
 [<ffffffff810e5a56>] ? kfree_debugcheck+0x16/0x40
 [<ffffffff810e603d>] ? kmem_cache_free+0xcd/0x190
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff810fe975>] ? __d_free+0x45/0x60
 [<ffffffff810fe9e8>] ? d_free+0x58/0x60
 [<ffffffff810feb4c>] ? d_kill+0x4c/0x60
 [<ffffffff81063776>] ? ktime_get_ts+0xa6/0xe0
 [<ffffffff810fccad>] ? poll_select_set_timeout+0x8d/0xa0
 [<ffffffff810fd51c>] sys_poll+0x7c/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rpc.statd     S 0000000000000000  5248  3544      1 0x00000000
 ffff88001e4998f8 0000000000000046 ffff88001e499fd8 ffff88001e499fd8
 ffff88001e498000 ffff88001e498000 ffff88001e498000 ffff88001e9923e0
 ffff88001e499fd8 ffff88001e9923e8 ffff88001e498000 ffff88001e499fd8
Call Trace:
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81059ca6>] ? add_wait_queue+0x46/0x60
 [<ffffffff810fe474>] ? __pollwait+0x74/0xf0
 [<ffffffff81838a7a>] ? datagram_poll+0xea/0x100
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff8105e3a3>] ? up_read+0x23/0x40
 [<ffffffff81966ea0>] ? do_page_fault+0x190/0x4e0
 [<ffffffff810fe9e8>] ? d_free+0x58/0x60
 [<ffffffff810feb4c>] ? d_kill+0x4c/0x60
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mdadm         S 0000000000000000  5336  3562      1 0x00000000
 ffff88001eadf8f8 0000000000000046 ffff88001eadffd8 ffff88001eadffd8
 ffff88001eade000 ffff88001eade000 ffff88001eade000 ffff88001ea463a0
 ffff88001eadffd8 ffff88001ea463a8 ffff88001eade000 ffff88001eadffd8
Call Trace:
 [<ffffffff81961dcf>] schedule_hrtimeout_range_clock+0xaf/0x140
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8113d88b>] ? pde_users_dec+0x4b/0x60
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff810badef>] ? get_page_from_freelist+0x2ff/0x690
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810b4420>] ? find_get_page+0x0/0x180
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff81063776>] ? ktime_get_ts+0xa6/0xe0
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rpc.gssd      S 0000000000000000  5552  3606      1 0x00000000
 ffff88001edf3a68 0000000000000046 ffff88001edf3fd8 ffff88001edf3fd8
 ffff88001edf2000 ffff88001edf2000 ffff88001edf2000 ffff88001da683e0
 ffff88001edf3fd8 ffff88001da683e8 ffff88001edf2000 ffff88001edf3fd8
Call Trace:
 [<ffffffff81961dcf>] schedule_hrtimeout_range_clock+0xaf/0x140
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fd257>] do_sys_poll+0x467/0x530
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810ff312>] ? d_rehash+0x32/0x60
 [<ffffffff8110114c>] ? d_alloc+0x14c/0x1f0
 [<ffffffff8108b563>] ? __call_rcu+0xc3/0x180
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff810f5d21>] ? path_put+0x31/0x40
 [<ffffffff814f7628>] ? debug_check_no_obj_freed+0x88/0x210
 [<ffffffff810f9d9b>] ? do_filp_open+0x11b/0x690
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff810fd51c>] sys_poll+0x7c/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
rpc.svcgssd   S 0000000000000000  5248  3640      1 0x00000000
 ffff88001e409a68 0000000000000046 ffff88001e409fd8 ffff88001e409fd8
 ffff88001e408000 ffff88001e408000 ffff88001e408000 ffff88001e1463e0
 ffff88001e409fd8 ffff88001e1463e8 ffff88001e408000 ffff88001e409fd8
Call Trace:
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81963a85>] ? _raw_spin_unlock+0x35/0x60
 [<ffffffff8113d88b>] ? pde_users_dec+0x4b/0x60
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fd257>] do_sys_poll+0x467/0x530
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff810ceb58>] ? __do_fault+0x138/0x4e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff810b483b>] ? unlock_page+0x2b/0x40
 [<ffffffff810cede1>] ? __do_fault+0x3c1/0x4e0
 [<ffffffff810d0e0a>] ? handle_mm_fault+0x17a/0x830
 [<ffffffff8105e3a3>] ? up_read+0x23/0x40
 [<ffffffff81966ea0>] ? do_page_fault+0x190/0x4e0
 [<ffffffff810e5a56>] ? kfree_debugcheck+0x16/0x40
 [<ffffffff810e603d>] ? kmem_cache_free+0xcd/0x190
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff8106a64d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8196406b>] ? retint_swapgs+0xe/0x13
 [<ffffffff810fd51c>] sys_poll+0x7c/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
sshd          S 0000000000000000  5184  3650      1 0x00000000
 ffff88001e1a38f8 0000000000000046 ffff88001e1a3fd8 ffff88001e1a3fd8
 ffff88001e1a2000 ffff88001e1a2000 ffff88001e1a2000 ffff88001ebfe3a0
 ffff88001e1a3fd8 ffff88001ebfe3a8 ffff88001e1a2000 ffff88001e1a3fd8
Call Trace:
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81059ca6>] ? add_wait_queue+0x46/0x60
 [<ffffffff810fe474>] ? __pollwait+0x74/0xf0
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff81963a12>] ? _raw_spin_unlock_irqrestore+0x42/0x80
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff8106a64d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff810fe975>] ? __d_free+0x45/0x60
 [<ffffffff810fe9e8>] ? d_free+0x58/0x60
 [<ffffffff810feb4c>] ? d_kill+0x4c/0x60
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
ntpd          S 0000000000000000  5056  3658      1 0x00000000
 ffff88001eb5d8f8 0000000000000046 ffff88001eb5dfd8 ffff88001eb5dfd8
 ffff88001eb5c000 ffff88001eb5c000 ffff88001eb5c000 ffff88001da043e0
 ffff88001eb5dfd8 ffff88001da043e8 ffff88001eb5c000 ffff88001eb5dfd8
Call Trace:
 [<ffffffff81961dcf>] schedule_hrtimeout_range_clock+0xaf/0x140
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81838a7a>] ? datagram_poll+0xea/0x100
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff81838938>] ? verify_iovec+0x88/0xe0
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff81063776>] ? ktime_get_ts+0xa6/0xe0
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
sendmail      S 0000000000000000  5184  3674      1 0x00000000
 ffff88001eb278f8 0000000000000046 ffff88001eb27fd8 ffff88001eb27fd8
 ffff88001eb26000 ffff88001eb26000 ffff88001eb26000 ffff88001eab63a0
 ffff88001eb27fd8 ffff88001eab63a8 ffff88001eb26000 ffff88001eb27fd8
Call Trace:
 [<ffffffff81961dcf>] schedule_hrtimeout_range_clock+0xaf/0x140
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8106a64d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8110abe1>] ? seq_open+0x91/0x140
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff81063776>] ? ktime_get_ts+0xa6/0xe0
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
sendmail      S 0000000000000000  5296  3682      1 0x00000000
 ffff88001eab9f68 0000000000000046 ffff88001eab9fd8 ffff88001eab9fd8
 ffff88001eab8000 ffff88001eab8000 ffff88001eab8000 ffff88001ed983a0
 ffff88001eab9fd8 ffff88001ed983a8 ffff88001eab8000 ffff88001eab9fd8
Call Trace:
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8104a22d>] sys_pause+0x1d/0x30
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
crond         S 0000000000000000  5296  3691      1 0x00000000
 ffff88001d93fe78 0000000000000046 ffff88001d93ffd8 ffff88001d93ffd8
 ffff88001d93e000 ffff88001d93e000 ffff88001d93e000 ffff88001f7aa3e0
 ffff88001d93ffd8 ffff88001f7aa3e8 ffff88001d93e000 ffff88001d93ffd8
Call Trace:
 [<ffffffff81961c5c>] do_nanosleep+0x8c/0xc0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff8105dfde>] hrtimer_nanosleep+0xae/0x150
 [<ffffffff8105d310>] ? hrtimer_wakeup+0x0/0x30
 [<ffffffff8105e104>] sys_nanosleep+0x84/0x90
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mingetty      S 0000000000000000  5040  3704      1 0x00000000
 ffff88001e2a1ce8 0000000000000046 ffff88001e2a1fd8 ffff88001e2a1fd8
 ffff88001e2a0000 ffff88001e2a0000 ffff88001e2a0000 ffff88001e14e3a0
 ffff88001e2a1fd8 ffff88001e14e3a8 ffff88001e2a0000 ffff88001e2a1fd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff815673a9>] n_tty_read+0x589/0x950
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff81561be6>] tty_read+0xa6/0xf0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mingetty      S 0000000000000000  4976  3706      1 0x00000000
 ffff88001e891ce8 0000000000000046 ffff88001e891fd8 ffff88001e891fd8
 ffff88001e890000 ffff88001e890000 ffff88001e890000 ffff88001ea2c3e0
 ffff88001e891fd8 ffff88001ea2c3e8 ffff88001e890000 ffff88001e891fd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff815673a9>] n_tty_read+0x589/0x950
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff81561be6>] tty_read+0xa6/0xf0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mingetty      S 0000000000000000  5392  3708      1 0x00000000
 ffff88001eba7ce8 0000000000000046 ffff88001eba7fd8 ffff88001eba7fd8
 ffff88001eba6000 ffff88001eba6000 ffff88001eba6000 ffff88001eaac3a0
 ffff88001eba7fd8 ffff88001eaac3a8 ffff88001eba6000 ffff88001eba7fd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff815673a9>] n_tty_read+0x589/0x950
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff81561be6>] tty_read+0xa6/0xf0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mingetty      S 0000000000000000  5392  3710      1 0x00000000
 ffff88001e8abce8 0000000000000046 ffff88001e8abfd8 ffff88001e8abfd8
 ffff88001e8aa000 ffff88001e8aa000 ffff88001e8aa000 ffff88001ecf83e0
 ffff88001e8abfd8 ffff88001ecf83e8 ffff88001e8aa000 ffff88001e8abfd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff815673a9>] n_tty_read+0x589/0x950
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff81561be6>] tty_read+0xa6/0xf0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mingetty      S 0000000000000000  5392  3712      1 0x00000000
 ffff88001e8adce8 0000000000000046 ffff88001e8adfd8 ffff88001e8adfd8
 ffff88001e8ac000 ffff88001e8ac000 ffff88001e8ac000 ffff88001ebd63e0
 ffff88001e8adfd8 ffff88001ebd63e8 ffff88001e8ac000 ffff88001e8adfd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff815673a9>] n_tty_read+0x589/0x950
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff81561be6>] tty_read+0xa6/0xf0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mingetty      S 0000000000000000  5392  3714      1 0x00000000
 ffff88001ea85ce8 0000000000000046 ffff88001ea85fd8 ffff88001ea85fd8
 ffff88001ea84000 ffff88001ea84000 ffff88001ea84000 ffff88001eb443a0
 ffff88001ea85fd8 ffff88001eb443a8 ffff88001ea84000 ffff88001ea85fd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff815673a9>] n_tty_read+0x589/0x950
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff81561be6>] tty_read+0xa6/0xf0
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
sshd          S 0000000000000000  5152  3742   3650 0x00000000
 ffff88001e9818f8 0000000000000046 ffff88001e981fd8 ffff88001e981fd8
 ffff88001e980000 ffff88001e980000 ffff88001e980000 ffff88001e13c3e0
 ffff88001e981fd8 ffff88001e13c3e8 ffff88001e980000 ffff88001e981fd8
Call Trace:
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff81059ca6>] ? add_wait_queue+0x46/0x60
 [<ffffffff810fe474>] ? __pollwait+0x74/0xf0
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8196395e>] ? _raw_spin_unlock_bh+0x3e/0x50
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8105e8c1>] ? __srcu_read_unlock+0x41/0x70
 [<ffffffff81121e39>] ? fsnotify+0x1e9/0x340
 [<ffffffff81121ccd>] ? fsnotify+0x7d/0x340
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
bash          S 0000000000000000  5216  3750   3742 0x00000000
 ffff88001f6afe78 0000000000000046 ffff88001f6affd8 ffff88001f6affd8
 ffff88001f6ae000 ffff88001f6ae000 ffff88001f6ae000 ffff88001e8b43a0
 ffff88001f6affd8 ffff88001e8b43a8 ffff88001f6ae000 ffff88001f6affd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8103c916>] do_wait+0x1c6/0x280
 [<ffffffff8103ca72>] sys_wait4+0xa2/0x100
 [<ffffffff8103adc0>] ? child_wait_callback+0x0/0x70
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
lease_tests   S 0000000000000000  5968  4309      1 0x00000000
 ffff88001e26bcd8 0000000000000046 ffff88001e26bfd8 ffff88001e26bfd8
 ffff88001e26a000 ffff88001e26a000 ffff88001e26a000 ffff88001e8d63a0
 ffff88001e26bfd8 ffff88001e8d63a8 ffff88001e26a000 ffff88001e26bfd8
Call Trace:
 [<ffffffff810f477a>] pipe_wait+0x5a/0x80
 [<ffffffff81059940>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff810f5235>] pipe_read+0x3b5/0x4a0
 [<ffffffff810eaf1a>] do_sync_read+0xda/0x120
 [<ffffffff810ff4aa>] ? dput+0xaa/0x160
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff814961ca>] ? security_file_permission+0x6a/0x80
 [<ffffffff810ebb94>] vfs_read+0xc4/0x170
 [<ffffffff810ebd31>] sys_read+0x51/0x80
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mount         S 0000000000000000  5056  4313   3750 0x00000000
 ffff88001edf1e78 0000000000000046 ffff88001edf1fd8 ffff88001edf1fd8
 ffff88001edf0000 ffff88001edf0000 ffff88001edf0000 ffff88001ed583a0
 ffff88001edf1fd8 ffff88001ed583a8 ffff88001edf0000 ffff88001edf1fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8103c916>] do_wait+0x1c6/0x280
 [<ffffffff8103ca72>] sys_wait4+0xa2/0x100
 [<ffffffff8103adc0>] ? child_wait_callback+0x0/0x70
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
mount.nfs4    D 0000000000000000  2880  4314   4313 0x00000000
 ffff88001ed6da28 0000000000000046 ffff88001ed6dfd8 ffff88001ed6dfd8
 ffff88001ed6c000 ffff88001ed6c000 ffff88001ed6c000 ffff88001e5003a0
 ffff88001ed6dfd8 ffff88001e5003a8 ffff88001ed6c000 ffff88001ed6dfd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff8106a31c>] ? mark_held_locks+0x6c/0xa0
 [<ffffffff819639a0>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff8195fc80>] wait_for_common+0x120/0x190
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff8195fdcd>] wait_for_completion+0x1d/0x20
 [<ffffffff810595fa>] kthread_stop+0x4a/0x150
 [<ffffffff81061a60>] ? thaw_process+0x70/0x80
 [<ffffffff810cc68a>] bdi_unregister+0x10a/0x1a0
 [<ffffffff81229dc9>] nfs_put_super+0x19/0x20
 [<ffffffff810ee8c4>] generic_shutdown_super+0x54/0xe0
 [<ffffffff810ee9b6>] kill_anon_super+0x16/0x60
 [<ffffffff8122d3b9>] nfs4_kill_super+0x39/0x90
 [<ffffffff810eda45>] deactivate_locked_super+0x45/0x60
 [<ffffffff810edfb9>] deactivate_super+0x49/0x70
 [<ffffffff81108294>] mntput_no_expire+0x84/0xe0
 [<ffffffff811084ef>] release_mounts+0x9f/0xc0
 [<ffffffff81108575>] put_mnt_ns+0x65/0x80
 [<ffffffff8122cc56>] nfs_follow_remote_path+0x1e6/0x420
 [<ffffffff8122cfbf>] nfs4_try_mount+0x6f/0xd0
 [<ffffffff8122d0c2>] nfs4_get_sb+0xa2/0x360
 [<ffffffff810edcb8>] vfs_kern_mount+0x88/0x1f0
 [<ffffffff810ede92>] do_kern_mount+0x52/0x130
 [<ffffffff81963d9a>] ? _lock_kernel+0x6a/0x170
 [<ffffffff81108e9e>] do_mount+0x26e/0x7f0
 [<ffffffff81106b3a>] ? copy_mount_options+0xea/0x190
 [<ffffffff811094b8>] sys_mount+0x98/0xf0
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
nfsv4.0-svc   S 0000000000000000  6592  4315      2 0x00000000
 ffff88001f7a1d50 0000000000000046 ffff88001f7a1fd8 ffff88001f7a1fd8
 ffff88001f7a0000 ffff88001f7a0000 ffff88001f7a0000 ffff88001ed5a3e0
 ffff88001f7a1fd8 ffff88001ed5a3e8 ffff88001f7a0000 ffff88001f7a1fd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff8103fba3>] ? local_bh_enable_ip+0x83/0x110
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff81910d7f>] ? svc_recv+0x5bf/0x8a0
 [<ffffffff8106a64d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8103fba3>] ? local_bh_enable_ip+0x83/0x110
 [<ffffffff81910d88>] svc_recv+0x5c8/0x8a0
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff812556b0>] ? nfs4_callback_svc+0x0/0xb0
 [<ffffffff812556f2>] nfs4_callback_svc+0x42/0xb0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
flush-0:19    S 0000000000000000  6280  4316      2 0x00000000
 ffff88001d8f5e20 0000000000000046 ffff88001d8f5fd8 ffff88001d8f5fd8
 ffff88001d8f4000 ffff88001d8f4000 ffff88001d8f4000 ffff88001e8c43e0
 ffff88001d8f5fd8 ffff88001e8c43e8 ffff88001d8f4000 ffff88001d8f5fd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff811109b9>] bdi_writeback_thread+0x159/0x2f0
 [<ffffffff81110860>] ? bdi_writeback_thread+0x0/0x2f0
 [<ffffffff810594a6>] kthread+0x96/0xa0
 [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810325ab>] ? finish_task_switch.clone.3+0x7b/0xd0
 [<ffffffff8196407e>] ? restore_args+0x0/0x30
 [<ffffffff81059410>] ? kthread+0x0/0xa0
 [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
anacron       S 0000000000000000  5248  4381      1 0x00000000
 ffff88001e46ff38 0000000000000046 ffff88001e46ffd8 ffff88001e46ffd8
 ffff88001e46e000 ffff88001e46e000 ffff88001e46e000 ffff88001f9483a0
 ffff88001e46ffd8 ffff88001f9483a8 ffff88001e46e000 ffff88001e46ffd8
Call Trace:
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8104a4f8>] sys_rt_sigsuspend+0xb8/0xe0
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
sshd          S 0000000000000000  5152  4433   3650 0x00000000
 ffff88001e1a98f8 0000000000000046 ffff88001e1a9fd8 ffff88001e1a9fd8
 ffff88001e1a8000 ffff88001e1a8000 ffff88001e1a8000 ffff88001d8c63a0
 ffff88001e1a9fd8 ffff88001d8c63a8 ffff88001e1a8000 ffff88001e1a9fd8
Call Trace:
 [<ffffffff81961e3d>] schedule_hrtimeout_range_clock+0x11d/0x140
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff8106a64d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff81961e73>] schedule_hrtimeout_range+0x13/0x20
 [<ffffffff810fccf8>] poll_schedule_timeout+0x38/0x60
 [<ffffffff810fdbfd>] do_select+0x5ed/0x720
 [<ffffffff810fd610>] ? do_select+0x0/0x720
 [<ffffffff810fe400>] ? __pollwait+0x0/0xf0
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff810fe4f0>] ? pollwake+0x0/0x60
 [<ffffffff8106d9c8>] ? lock_release_non_nested+0xa8/0x330
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810ce39a>] ? might_fault+0x7a/0xd0
 [<ffffffff810fdf97>] core_sys_select+0x267/0x3b0
 [<ffffffff810fdd78>] ? core_sys_select+0x48/0x3b0
 [<ffffffff8102fb52>] ? __wake_up+0x32/0x70
 [<ffffffff81030611>] ? get_parent_ip+0x11/0x50
 [<ffffffff8196728d>] ? sub_preempt_count+0x9d/0xd0
 [<ffffffff8105e8c1>] ? __srcu_read_unlock+0x41/0x70
 [<ffffffff81121e39>] ? fsnotify+0x1e9/0x340
 [<ffffffff81121ccd>] ? fsnotify+0x7d/0x340
 [<ffffffff8156ae1e>] ? tty_ldisc_deref+0xe/0x10
 [<ffffffff810fe337>] sys_select+0x47/0x110
 [<ffffffff81962e69>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
bash          R  running task     5008  4441   4433 0x00000000
 ffff88001e8cfad8 ffffffff81039743 ffffffff8208d355 ffffffff819671fe
 ffff88001e8cfb08 ffffffff8208d355 ffff88001e8cfb78 ffffffff81039cdc
 ffff88001e8cfb88 0000000000000092 ffff88001e8cfbe8 0000000000000092
Call Trace:
 [<ffffffff81039743>] ? release_console_sem+0x1f3/0x230
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff81039cdc>] ? vprintk+0x26c/0x4d0
 [<ffffffff814eec6f>] ? string+0x4f/0xf0
 [<ffffffff814eec6f>] ? string+0x4f/0xf0
 [<ffffffff8195f915>] ? printk+0x68/0x6a
 [<ffffffff8195f915>] ? printk+0x68/0x6a
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff81075410>] ? is_module_text_address+0x30/0x60
 [<ffffffff81056878>] ? __kernel_text_address+0x58/0x80
 [<ffffffff81005b15>] ? print_context_stack+0x85/0x140
 [<ffffffff81004a4c>] ? dump_trace+0x18c/0x390
 [<ffffffff8100589c>] show_trace_log_lvl+0x5c/0x80
 [<ffffffff81004511>] show_stack_log_lvl+0xc1/0x1b0
 [<ffffffff8100583c>] show_stack+0x1c/0x20
 [<ffffffff810306fc>] sched_show_task+0xac/0x110
 [<ffffffff81035d8b>] show_state_filter+0x7b/0xd0
 [<ffffffff8157c2d0>] sysrq_handle_showstate+0x10/0x20
 [<ffffffff8157c731>] __handle_sysrq+0x131/0x1a0
 [<ffffffff8157c7a0>] ? write_sysrq_trigger+0x0/0x50
 [<ffffffff8157c7ee>] write_sysrq_trigger+0x4e/0x50
 [<ffffffff8113dc75>] proc_reg_write+0x85/0xc0
 [<ffffffff810eb8f7>] vfs_write+0xc7/0x170
 [<ffffffff810eba91>] sys_write+0x51/0x90
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
Sched Debug Version: v0.09, 2.6.36-rc2-00238-g0e8f983 #11
now at 828420.724224 msecs
  .jiffies                                 : 4295099271
  .sysctl_sched_latency                    : 6.000000
  .sysctl_sched_min_granularity            : 2.000000
  .sysctl_sched_wakeup_granularity         : 1.000000
  .sysctl_sched_child_runs_first           : 0
  .sysctl_sched_features                   : 15471
  .sysctl_sched_tunable_scaling            : 1 (logaritmic)

cpu#0, 2394.006 MHz
  .nr_running                    : 2
  .load                          : 2048
  .nr_switches                   : 51559
  .nr_load_updates               : 206975
  .nr_uninterruptible            : 1
  .next_balance                  : 0.000000
  .curr->pid                     : 4441
  .clock                         : 828415.137767
  .cpu_load[0]                   : 0
  .cpu_load[1]                   : 0
  .cpu_load[2]                   : 0
  .cpu_load[3]                   : 0
  .cpu_load[4]                   : 0
  .yld_count                     : 1741
  .sched_switch                  : 0
  .sched_count                   : 142628
  .sched_goidle                  : 93415
  .ttwu_count                    : 0
  .ttwu_local                    : 0
  .bkl_count                     : 192

cfs_rq[0]:
  .exec_clock                    : 17547.448581
  .MIN_vruntime                  : 16937.936514
  .min_vruntime                  : 16937.933504
  .max_vruntime                  : 16937.936514
  .spread                        : 0.000000
  .spread0                       : 0.000000
  .nr_running                    : 2
  .load                          : 2048
  .nr_spread_over                : 12

rt_rq[0]:
  .rt_nr_running                 : 0
  .rt_throttled                  : 0
  .rt_time                       : 0.000000
  .rt_runtime                    : 950.000000

runnable tasks:
            task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
----------------------------------------------------------------------------------------------------------
R           bash  4441     16934.933504        33   120     16934.933504        22.132725      3682.649290


Showing all locks held in the system:
1 lock held by mingetty/3704:
 #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff815672fe>] n_tty_read+0x4de/0x950
1 lock held by mingetty/3706:
 #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff815672fe>] n_tty_read+0x4de/0x950
1 lock held by mingetty/3708:
 #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff815672fe>] n_tty_read+0x4de/0x950
1 lock held by mingetty/3710:
 #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff815672fe>] n_tty_read+0x4de/0x950
1 lock held by mingetty/3712:
 #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff815672fe>] n_tty_read+0x4de/0x950
1 lock held by mingetty/3714:
 #0:  (&tty->atomic_read_lock){+.+...}, at: [<ffffffff815672fe>] n_tty_read+0x4de/0x950
1 lock held by mount.nfs4/4314:
 #0:  (&type->s_umount_key#24){+.+...}, at: [<ffffffff810edfb1>] deactivate_super+0x41/0x70
2 locks held by bash/4441:
 #0:  (sysrq_key_table_lock){......}, at: [<ffffffff8157c635>] __handle_sysrq+0x35/0x1a0
 #1:  (tasklist_lock){.+.+..}, at: [<ffffffff8106988e>] debug_show_all_locks+0x3e/0x1c0

=============================================

INFO: task mount.nfs4:4314 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mount.nfs4    D 0000000000000000  2880  4314   4313 0x00000000
 ffff88001ed6da28 0000000000000046 ffff88001ed6dfd8 ffff88001ed6dfd8
 ffff88001ed6c000 ffff88001ed6c000 ffff88001ed6c000 ffff88001e5003a0
 ffff88001ed6dfd8 ffff88001e5003a8 ffff88001ed6c000 ffff88001ed6dfd8
Call Trace:
 [<ffffffff8196090d>] schedule_timeout+0x1cd/0x2e0
 [<ffffffff8106a31c>] ? mark_held_locks+0x6c/0xa0
 [<ffffffff819639a0>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff8106a5fd>] ? trace_hardirqs_on_caller+0x14d/0x190
 [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
 [<ffffffff8195fc80>] wait_for_common+0x120/0x190
 [<ffffffff81033c70>] ? default_wake_function+0x0/0x20
 [<ffffffff8195fdcd>] wait_for_completion+0x1d/0x20
 [<ffffffff810595fa>] kthread_stop+0x4a/0x150
 [<ffffffff81061a60>] ? thaw_process+0x70/0x80
 [<ffffffff810cc68a>] bdi_unregister+0x10a/0x1a0
 [<ffffffff81229dc9>] nfs_put_super+0x19/0x20
 [<ffffffff810ee8c4>] generic_shutdown_super+0x54/0xe0
 [<ffffffff810ee9b6>] kill_anon_super+0x16/0x60
 [<ffffffff8122d3b9>] nfs4_kill_super+0x39/0x90
 [<ffffffff810eda45>] deactivate_locked_super+0x45/0x60
 [<ffffffff810edfb9>] deactivate_super+0x49/0x70
 [<ffffffff81108294>] mntput_no_expire+0x84/0xe0
 [<ffffffff811084ef>] release_mounts+0x9f/0xc0
 [<ffffffff81108575>] put_mnt_ns+0x65/0x80
 [<ffffffff8122cc56>] nfs_follow_remote_path+0x1e6/0x420
 [<ffffffff8122cfbf>] nfs4_try_mount+0x6f/0xd0
 [<ffffffff8122d0c2>] nfs4_get_sb+0xa2/0x360
 [<ffffffff810edcb8>] vfs_kern_mount+0x88/0x1f0
 [<ffffffff810ede92>] do_kern_mount+0x52/0x130
 [<ffffffff81963d9a>] ? _lock_kernel+0x6a/0x170
 [<ffffffff81108e9e>] do_mount+0x26e/0x7f0
 [<ffffffff81106b3a>] ? copy_mount_options+0xea/0x190
 [<ffffffff811094b8>] sys_mount+0x98/0xf0
 [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
1 lock held by mount.nfs4/4314:
 #0:  (&type->s_umount_key#24){+.+...}, at: [<ffffffff810edfb1>] deactivate_super+0x41/0x70
