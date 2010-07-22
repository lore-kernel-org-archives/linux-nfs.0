Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15132 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757995Ab0GVHgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 03:36:31 -0400
Date: Thu, 22 Jul 2010 15:36:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFS commit: sync or async?
Message-ID: <20100722073623.GA24462@localhost>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond,

May I ask you an NFS question? I got a bit puzzled by this call trace. It
happens after stopping the nfsd at server side when the client side is
doing cp over NFSv3:

[49388.040091] cp            D 0000000000000082  2968  2782  28204 0x00000000
[49388.040097]  ffff8800b8587778 0000000000000002 ffff8800b85877f8 00000000001d4e40
[49388.040103]  ffff8800b8587fd8 00000000001d4e40 ffff8800b8587fd8 ffff8800b8ec4700
[49388.040110]  00000000001d4e40 ffff8800b8587fd8 00000000001d4e40 00000000001d4e40
[49388.040116] Call Trace:
[49388.040121]  [<ffffffff810de503>] ? prepare_to_wait+0x73/0xc0
[49388.040127]  [<ffffffff81b32750>] ? rpc_wait_bit_killable+0x0/0x60
[49388.040132]  [<ffffffff81b3277f>] rpc_wait_bit_killable+0x2f/0x60
[49388.040136]  [<ffffffff81babded>] __wait_on_bit+0x8d/0xe0
[49388.040140]  [<ffffffff81b32750>] ? rpc_wait_bit_killable+0x0/0x60
[49388.040144]  [<ffffffff81babec6>] out_of_line_wait_on_bit+0x86/0xa0
[49388.040149]  [<ffffffff810de170>] ? wake_bit_function+0x0/0x70
[49388.040154]  [<ffffffff81b333bf>] __rpc_execute+0x16f/0x3f0
[49388.040158]  [<ffffffff81b3367b>] rpc_execute+0x3b/0x50
[49388.040162]  [<ffffffff81b28d31>] rpc_run_task+0x51/0xc0
[49388.040167]  [<ffffffff81366ad6>] nfs_commit_list+0x1f6/0x3e0
[49388.040172]  [<ffffffff81366de9>] nfs_commit_inode+0x129/0x170
[49388.040176]  [<ffffffff813677fa>] nfs_write_inode+0x7a/0xf0
[49388.040180]  [<ffffffff81239a8b>] writeback_single_inode+0x28b/0x3f0
[49388.040186]  [<ffffffff8123ac08>] writeback_inodes_wb+0x318/0x650
[49388.040191]  [<ffffffff8123b1d2>] writeback_inodes_wbc+0x22/0x30
[49388.040196]  [<ffffffff811a5a00>] balance_dirty_pages_ratelimited_nr+0x400/0x5d0
[49388.040202]  [<ffffffff81196306>] ? iov_iter_copy_from_user_atomic+0xa6/0x1c0
[49388.040207]  [<ffffffff81196898>] generic_file_buffered_write+0x258/0x370
[49388.040213]  [<ffffffff81199b7a>] __generic_file_aio_write+0x2ea/0x5f0
[49388.040218]  [<ffffffff81bad374>] ? mutex_lock_nested+0x394/0x530
[49388.040223]  [<ffffffff81199edf>] ? generic_file_aio_write+0x5f/0x100
[49388.040229]  [<ffffffff81199ef9>] generic_file_aio_write+0x79/0x100
[49388.040235]  [<ffffffff81353f00>] nfs_file_write+0xe0/0x2a0
[49388.040240]  [<ffffffff8120a138>] do_sync_write+0xe8/0x140
[49388.040246]  [<ffffffff811bd7b6>] ? might_fault+0xd6/0xf0
[49388.040251]  [<ffffffff8120b156>] vfs_write+0xb6/0x220
[49388.040255]  [<ffffffff8120b406>] sys_write+0x66/0xb0
[49388.040260]  [<ffffffff8104ab72>] system_call_fastpath+0x16/0x1b

>From simple code review I cannot explain why out_of_line_wait_on_bit()
is called inside __rpc_execute() for a commit request.

nfs_commit_rpcsetup() sets RPC_TASK_ASYNC for task_setup_data.flags,
which is transferred to task->tk_flags in rpc_init_task().
__rpc_execute() should then return on task_is_async=1 and skip the
out_of_line_wait_on_bit() call. However the trace shows that
out_of_line_wait_on_bit() is called. I'm a bit puzzled. I must have
missed something. Is this the expected behavior?

Thanks,
Fengguang
