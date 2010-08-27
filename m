Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36650 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157Ab0H0V27 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Aug 2010 17:28:59 -0400
Date: Fri, 27 Aug 2010 17:28:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Artem.Bityutskiy@nokia.com
Cc: bjschuma@netapp.com, jaxboe@fusionio.com, linux-nfs@vger.kernel.org,
        trond@netapp.com, hch@lst.de
Subject: [PATCH] Fix lost wake-up shutting down writeback thread
Message-ID: <20100827212842.GC27694@fieldses.org>
References: <20100825023425.GA24591@fieldses.org>
 <1282889595.2763.14.camel@localhost>
 <1282901780.12016.54.camel@localhost>
 <4C77B873.8010306@netapp.com>
 <20100827160912.GA18790@fieldses.org>
 <10B234E0D3A1CA469E00963BF106CA392D0DB78354@NOK-EUMSG-02.mgdnok.nokia.com>
 <20100827210626.GB27694@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100827210626.GB27694@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Setting the task state here may cause us to miss the wake up from
kthread_stop(), so we need to recheck kthread_should_stop() or risk
sleeping forever in the following schedule().

Symptom was an indefinite hang on an NFSv4 mount.  (NFSv4 may create
multiple mounts in a temporary namespace while traversing the mount
path, and since the temporary namespace is immediately destroyed, it may
end up destroying a mount very soon after it was created, possibly
making this race more likely.)

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

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/fs-writeback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

On Fri, Aug 27, 2010 at 05:06:26PM -0400, J. Bruce Fields wrote:
> Maybe the following?

I confirmed that my hang does go away after doing this.

Please apply if you think this makes sense....

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 7d9d06b..81e086d 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -808,7 +808,7 @@ int bdi_writeback_thread(void *data)
 			wb->last_active = jiffies;
 
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (!list_empty(&bdi->work_list)) {
+		if (!list_empty(&bdi->work_list) || kthread_should_stop()) {
 			__set_current_state(TASK_RUNNING);
 			continue;
 		}
-- 
1.7.0.4

