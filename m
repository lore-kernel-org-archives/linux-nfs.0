Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:18969 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab0H0GO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 02:14:57 -0400
Subject: Re: hang in writeback code on nfsv4 mount
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
To: "J. Bruce Fields" <bfields@fieldses.org>, Jens Axboe <jaxboe@fusionio.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>, Christoph Hellwig <hch@lst.de>
In-Reply-To: <20100825023425.GA24591@fieldses.org>
References: <20100825023425.GA24591@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 27 Aug 2010 09:13:15 +0300
Message-ID: <1282889595.2763.14.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-25 at 04:34 +0200, ext J. Bruce Fields wrote:
> As of 253c34e9b10c30d3064be654b5b78fbc1a8b1896 "writeback: prevent
> unnecessary bdi threads wakeups", any nfs mount hangs for me.  Is this a
> known issue?
> 
> --b.
> 
> INFO: task mount.nfs4:3812 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> mount.nfs4    D 0000000000000000  2880  3812   3811 0x00000000
>  ffff88001ed25a28 0000000000000046 ffff88001ed25fd8 ffff88001ed25fd8
>  ffff88001ed24000 ffff88001ed24000 ffff88001ed24000 ffff88001f9503a0
>  ffff88001ed25fd8 ffff88001f9503a8 ffff88001ed24000 ffff88001ed25fd8
> Call Trace:
>  [<ffffffff819608dd>] schedule_timeout+0x1cd/0x2e0
>  [<ffffffff8106a23c>] ? mark_held_locks+0x6c/0xa0
>  [<ffffffff81963970>] ? _raw_spin_unlock_irq+0x30/0x60
>  [<ffffffff8106a51d>] ? trace_hardirqs_on_caller+0x14d/0x190
>  [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
>  [<ffffffff8195fc50>] wait_for_common+0x120/0x190
>  [<ffffffff81033bb0>] ? default_wake_function+0x0/0x20
>  [<ffffffff8195fd9d>] wait_for_completion+0x1d/0x20
>  [<ffffffff8105951a>] kthread_stop+0x4a/0x150
>  [<ffffffff81061980>] ? thaw_process+0x70/0x80
>  [<ffffffff810cc5aa>] bdi_unregister+0x10a/0x1a0
>  [<ffffffff81229cd9>] nfs_put_super+0x19/0x20
>  [<ffffffff810ee7d4>] generic_shutdown_super+0x54/0xe0
>  [<ffffffff810ee8c6>] kill_anon_super+0x16/0x60
>  [<ffffffff8122d2c9>] nfs4_kill_super+0x39/0x90
>  [<ffffffff810ed955>] deactivate_locked_super+0x45/0x60
>  [<ffffffff810edec9>] deactivate_super+0x49/0x70
>  [<ffffffff811081a4>] mntput_no_expire+0x84/0xe0
>  [<ffffffff811083ff>] release_mounts+0x9f/0xc0
>  [<ffffffff81108485>] put_mnt_ns+0x65/0x80
>  [<ffffffff8122cb66>] nfs_follow_remote_path+0x1e6/0x420
>  [<ffffffff8122cecf>] nfs4_try_mount+0x6f/0xd0
>  [<ffffffff8122cfd2>] nfs4_get_sb+0xa2/0x360
>  [<ffffffff810edbc8>] vfs_kern_mount+0x88/0x1f0
>  [<ffffffff810edda2>] do_kern_mount+0x52/0x130
>  [<ffffffff81963d6a>] ? _lock_kernel+0x6a/0x170
>  [<ffffffff81108dae>] do_mount+0x26e/0x7f0
>  [<ffffffff81106a4a>] ? copy_mount_options+0xea/0x190
>  [<ffffffff811093c8>] sys_mount+0x98/0xf0
>  [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
> 1 lock held by mount.nfs4/3812:
>  #0:  (&type->s_umount_key#24){+.+...}, at: [<ffffffff810edec1>] deactivate_super+0x41/0x70

Bruce, I can reproduce this by doing mount/fsstress/unmount, but it
takes few hours for me. I added few printks and tried to reproduce this
issue, but hit another issue. I am not sure the root cause for your
issue is the same or not, but here is the bugfix anyway.

Too bad I have to fly and cannot continue investigating. But I'll start
this again as soon as I can.

Jens, please, consider taking this to 2.6.36.

>From aa87b87c8555151bb8e083d0dba3fd68c5b0d811 Mon Sep 17 00:00:00 2001
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Date: Fri, 27 Aug 2010 08:21:18 +0300
Subject: [PATCH] writeback: do not lose wakeup events when forking bdi threads

This patch fixes the following issue:

INFO: task mount.nfs4:1120 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mount.nfs4    D 00000000fffc6a21     0  1120   1119 0x00000000
 ffff880235643948 0000000000000046 ffffffff00000000 ffffffff00000000
 ffff880235643fd8 ffff880235314760 00000000001d44c0 ffff880235643fd8
 00000000001d44c0 00000000001d44c0 00000000001d44c0 00000000001d44c0
Call Trace:
 [<ffffffff813bc747>] schedule_timeout+0x34/0xf1
 [<ffffffff813bc530>] ? wait_for_common+0x3f/0x130
 [<ffffffff8106b50b>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff813bc5c3>] wait_for_common+0xd2/0x130
 [<ffffffff8104159c>] ? default_wake_function+0x0/0xf
 [<ffffffff813beaa0>] ? _raw_spin_unlock+0x26/0x2a
 [<ffffffff813bc6bb>] wait_for_completion+0x18/0x1a
 [<ffffffff81101a03>] sync_inodes_sb+0xca/0x1bc
 [<ffffffff811056a6>] __sync_filesystem+0x47/0x7e
 [<ffffffff81105798>] sync_filesystem+0x47/0x4b
 [<ffffffff810e7ffd>] generic_shutdown_super+0x22/0xd2
 [<ffffffff810e80f8>] kill_anon_super+0x11/0x4f
 [<ffffffffa00d06d7>] nfs4_kill_super+0x3f/0x72 [nfs]
 [<ffffffff810e7b68>] deactivate_locked_super+0x21/0x41
 [<ffffffff810e7fd6>] deactivate_super+0x40/0x45
 [<ffffffff810fc66c>] mntput_no_expire+0xb8/0xed
 [<ffffffff810fc73b>] release_mounts+0x9a/0xb0
 [<ffffffff810fc7bb>] put_mnt_ns+0x6a/0x7b
 [<ffffffffa00d0fb2>] nfs_follow_remote_path+0x19a/0x296 [nfs]
 [<ffffffffa00d11ca>] nfs4_try_mount+0x75/0xaf [nfs]
 [<ffffffffa00d1790>] nfs4_get_sb+0x276/0x2ff [nfs]
 [<ffffffff810e7dba>] vfs_kern_mount+0xb8/0x196
 [<ffffffff810e7ef6>] do_kern_mount+0x48/0xe8
 [<ffffffff810fdf68>] do_mount+0x771/0x7e8
 [<ffffffff810fe062>] sys_mount+0x83/0xbd
 [<ffffffff810089c2>] system_call_fastpath+0x16/0x1b

The reason of this hang was a race condition: when the flusher thread is
forking a bdi thread, we use 'kthread_run()', so we run it _before_ we make it
visible in 'bdi->wb.task'. The bdi thread runs, does all works, and goes sleep.
'bdi->wb.task' is still NULL. And this is a dangerous time window.

If at this time someone queues a work for this bdi, he does not see the bdi
thread and wakes up the forker thread instead! But the forker has already
forked this bdi thread, but just did not make it visible yet!

The result is that we lose the wake up event for this bdi thread and the NFS4
code waits forever.

To fix the problem, we should use 'ktrhead_create()' for creating bdi threads,
then make them visible in 'bdi->wb.task', and only after this wake them up.
This is exactly what this patch does.

Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
---
 mm/backing-dev.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index a9a08d8..a9e0ec2 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -414,8 +414,8 @@ static int bdi_forker_thread(void *ptr)
 		switch (action) {
 		case FORK_THREAD:
 			__set_current_state(TASK_RUNNING);
-			task = kthread_run(bdi_writeback_thread, &bdi->wb, "flush-%s",
-					   dev_name(bdi->dev));
+			task = kthread_create(bdi_writeback_thread, &bdi->wb,
+					      "flush-%s", dev_name(bdi->dev));
 			if (IS_ERR(task)) {
 				/*
 				 * If thread creation fails, force writeout of
@@ -426,10 +426,13 @@ static int bdi_forker_thread(void *ptr)
 				/*
 				 * The spinlock makes sure we do not lose
 				 * wake-ups when racing with 'bdi_queue_work()'.
+				 * And as soon as the bdi thread is visible, we
+				 * can start it.
 				 */
 				spin_lock(&bdi->wb_lock);
 				bdi->wb.task = task;
 				spin_unlock(&bdi->wb_lock);
+				wake_up_process(task);
 			}
 			break;
 
-- 
1.7.1.1


-- 
Best Regards,
Artem Bityutskiy (Артём Битюцкий)

