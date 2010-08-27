From: Jens Axboe <jaxboe@fusionio.com>
Subject: Re: hang in writeback code on nfsv4 mount
Date: Fri, 27 Aug 2010 09:12:13 +0200
Message-ID: <4C77654D.3080303@fusionio.com>
References: <20100825023425.GA24591@fieldses.org> <1282889595.2763.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>,
	Christoph Hellwig <hch@lst.de>
To: "Artem.Bityutskiy@nokia.com" <Artem.Bityutskiy@nokia.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 0122700014.0.fullrate.dk ([95.166.99.235]:36130 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089Ab0H0HMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Aug 2010 03:12:15 -0400
In-Reply-To: <1282889595.2763.14.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-08-27 08:13, Artem Bityutskiy wrote:
> On Wed, 2010-08-25 at 04:34 +0200, ext J. Bruce Fields wrote:
>> As of 253c34e9b10c30d3064be654b5b78fbc1a8b1896 "writeback: prevent
>> unnecessary bdi threads wakeups", any nfs mount hangs for me.  Is this a
>> known issue?
>>
>> --b.
>>
>> INFO: task mount.nfs4:3812 blocked for more than 120 seconds.
>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> mount.nfs4    D 0000000000000000  2880  3812   3811 0x00000000
>>  ffff88001ed25a28 0000000000000046 ffff88001ed25fd8 ffff88001ed25fd8
>>  ffff88001ed24000 ffff88001ed24000 ffff88001ed24000 ffff88001f9503a0
>>  ffff88001ed25fd8 ffff88001f9503a8 ffff88001ed24000 ffff88001ed25fd8
>> Call Trace:
>>  [<ffffffff819608dd>] schedule_timeout+0x1cd/0x2e0
>>  [<ffffffff8106a23c>] ? mark_held_locks+0x6c/0xa0
>>  [<ffffffff81963970>] ? _raw_spin_unlock_irq+0x30/0x60
>>  [<ffffffff8106a51d>] ? trace_hardirqs_on_caller+0x14d/0x190
>>  [<ffffffff819671fe>] ? sub_preempt_count+0xe/0xd0
>>  [<ffffffff8195fc50>] wait_for_common+0x120/0x190
>>  [<ffffffff81033bb0>] ? default_wake_function+0x0/0x20
>>  [<ffffffff8195fd9d>] wait_for_completion+0x1d/0x20
>>  [<ffffffff8105951a>] kthread_stop+0x4a/0x150
>>  [<ffffffff81061980>] ? thaw_process+0x70/0x80
>>  [<ffffffff810cc5aa>] bdi_unregister+0x10a/0x1a0
>>  [<ffffffff81229cd9>] nfs_put_super+0x19/0x20
>>  [<ffffffff810ee7d4>] generic_shutdown_super+0x54/0xe0
>>  [<ffffffff810ee8c6>] kill_anon_super+0x16/0x60
>>  [<ffffffff8122d2c9>] nfs4_kill_super+0x39/0x90
>>  [<ffffffff810ed955>] deactivate_locked_super+0x45/0x60
>>  [<ffffffff810edec9>] deactivate_super+0x49/0x70
>>  [<ffffffff811081a4>] mntput_no_expire+0x84/0xe0
>>  [<ffffffff811083ff>] release_mounts+0x9f/0xc0
>>  [<ffffffff81108485>] put_mnt_ns+0x65/0x80
>>  [<ffffffff8122cb66>] nfs_follow_remote_path+0x1e6/0x420
>>  [<ffffffff8122cecf>] nfs4_try_mount+0x6f/0xd0
>>  [<ffffffff8122cfd2>] nfs4_get_sb+0xa2/0x360
>>  [<ffffffff810edbc8>] vfs_kern_mount+0x88/0x1f0
>>  [<ffffffff810edda2>] do_kern_mount+0x52/0x130
>>  [<ffffffff81963d6a>] ? _lock_kernel+0x6a/0x170
>>  [<ffffffff81108dae>] do_mount+0x26e/0x7f0
>>  [<ffffffff81106a4a>] ? copy_mount_options+0xea/0x190
>>  [<ffffffff811093c8>] sys_mount+0x98/0xf0
>>  [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
>> 1 lock held by mount.nfs4/3812:
>>  #0:  (&type->s_umount_key#24){+.+...}, at: [<ffffffff810edec1>] deactivate_super+0x41/0x70
> 
> Bruce, I can reproduce this by doing mount/fsstress/unmount, but it
> takes few hours for me. I added few printks and tried to reproduce this
> issue, but hit another issue. I am not sure the root cause for your
> issue is the same or not, but here is the bugfix anyway.
> 
> Too bad I have to fly and cannot continue investigating. But I'll start
> this again as soon as I can.
> 
> Jens, please, consider taking this to 2.6.36.

Thanks, applied!

-- 
Jens Axboe

