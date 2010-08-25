From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: hang in writeback code on nfsv4 mount
Date: Wed, 25 Aug 2010 11:25:44 -0400
Message-ID: <4C7535F8.6010901@netapp.com>
References: <20100825023425.GA24591@fieldses.org> <1282717945.24044.187.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <jaxboe@fusionio.com>
To: dedekind1@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14966 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397Ab0HYP0E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Aug 2010 11:26:04 -0400
In-Reply-To: <1282717945.24044.187.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing this too.  I am able to mount without a problem and the hang occurs during unmount. 

-Bryan

On 08/25/2010 02:32 AM, Artem Bityutskiy wrote:
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
> I've tried both v2.6.36-rc2 and commit
> 253c34e9b10c30d3064be654b5b78fbc1a8b1896 [1] - and I can mount an NFS
> share with no problems:
> 
> sudo mount -t nfs4 sauron:/home/dedekind/ /mnt/sauron_home/
> 
> works fine. Any hints about how to reproduce this are welcome.
> 
> I'll try to look at the code and figure out why this could happen.
> 
> So, does the mount at some point succeed? Or it is blocked forever? And
> sysrq-t output would be useful to look at as well.
> 
> Also, it is strange that 'sys_mount()' involves 'nfs4_kill_super()' - is
> this normal or this is an error path?
> 
> [1]: the kernel tree does not compile on this commit, and I applied
> patch on top to solve the compilation issue:
> 387ac089361fbe5ef287e6950c5c40f6b18e5c55 "block: fix missing export of
> blk_types.h"
> 

