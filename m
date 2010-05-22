From: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Subject: NFS, race in writeback?
Date: Sun, 23 May 2010 02:14:08 +0900
Message-ID: <11621.1274548448@jrobl>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I got "task xxx blocked for more than 120 seconds" in 2.6.34 NFS, which
didn't happen in 2.6.33. The four call-traces are attached.

Git bisect told me that "bad" is,

commit ba8b06e67ed7a560b0e7c80091bcadda4f4727a5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Apr 27 18:33:54 2010 -0400

    NFS: Ensure that nfs_wb_page() waits for Pg_writeback to clear
    
    Neil Brown reports that he is seeing the BUG_ON(ret == 0) trigger in
    nfs_page_async_flush. According to the trace in
         https://bugzilla.novell.com/show_bug.cgi?id=599628
    the problem appears to be due to nfs_wb_page() not waiting for the
    PG_writeback flag to clear.
    
    There is a ditto problem in nfs_wb_page_cancel()

I am not sure whether this commit is the root cause or not, but it must
be related at least.
Was the commit insufficient?


J. R. Okajima

----------------------------------------------------------------------

INFO: task flush-0:1207:24945 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
flush-0:1207  D 0000000000000000     0 24945      2 0x00000000
 ffff880000b49c50 0000000000000046 0000000000000001 ffff880000b48000
 ffff880000b49fd8 ffff880000b48000 ffff880000b49fd8 ffff880000b49fd8
 ffff88000f163040 0000000000014d00 0000000000000000 ffff88000f163040
Call Trace:
 [<ffffffff81136f8e>] inode_wait+0xe/0x20
 [<ffffffff81480092>] __wait_on_bit+0x62/0x90
 [<ffffffff81136f80>] ? inode_wait+0x0/0x20
 [<ffffffff81143b83>] inode_wait_for_writeback+0x93/0xc0
 [<ffffffff81074870>] ? wake_bit_function+0x0/0x50
 [<ffffffff81144e21>] wb_writeback+0x191/0x200
 [<ffffffff8114513b>] wb_do_writeback+0x1db/0x1e0
 [<ffffffff81144f90>] ? wb_do_writeback+0x30/0x1e0
 [<ffffffff81145193>] bdi_writeback_task+0x53/0xe0
 [<ffffffff810f6f50>] ? bdi_start_fn+0x0/0x100
 [<ffffffff810f6fd6>] bdi_start_fn+0x86/0x100
 [<ffffffff810f6f50>] ? bdi_start_fn+0x0/0x100
 [<ffffffff81074236>] kthread+0x96/0xb0
 [<ffffffff8100b924>] kernel_thread_helper+0x4/0x10
 [<ffffffff81483494>] ? restore_args+0x0/0x30
 [<ffffffff810741a0>] ? kthread+0x0/0xb0
 [<ffffffff8100b920>] ? kernel_thread_helper+0x0/0x10
no locks held by flush-0:1207/24945.


INFO: task mv:4227 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mv            D 0000000000000000     0  4227  23660 0x00000000
 ffff88000e899b58 0000000000000046 0000000000000001 ffff88000e898000
 ffff88000e899fd8 ffff88000e898000 ffff88000e899fd8 ffff88000e899fd8
 ffff88000d59f040 0000000000014d00 0000000000000000 ffff88000d59f040
Call Trace:
 [<ffffffff81136f8e>] inode_wait+0xe/0x20
 [<ffffffff81480092>] __wait_on_bit+0x62/0x90
 [<ffffffff81136f80>] ? inode_wait+0x0/0x20
 [<ffffffff81143b83>] inode_wait_for_writeback+0x93/0xc0
 [<ffffffff81074870>] ? wake_bit_function+0x0/0x50
 [<ffffffff81143cc8>] writeback_single_inode+0x118/0x360
 [<ffffffff81143f43>] sync_inode+0x33/0x50
 [<ffffffff811de955>] nfs_wb_all+0x45/0x50
 [<ffffffff811cf520>] nfs_rename+0x280/0x310
 [<ffffffff8112b664>] vfs_rename+0x3f4/0x460
 [<ffffffff8120fea5>] ? tomoyo_path_rename+0x35/0x40
 [<ffffffff8112dbb6>] sys_renameat+0x266/0x270
 [<ffffffff810fdff3>] ? handle_mm_fault+0x523/0x8b0
 [<ffffffff81486b29>] ? do_page_fault+0x319/0x600
 [<ffffffff8107a213>] ? up_read+0x23/0x40
 [<ffffffff81483479>] ? retint_swapgs+0x13/0x1b
 [<ffffffff8108ba45>] ? trace_hardirqs_on_caller+0x145/0x190
 [<ffffffff8112dbdb>] sys_rename+0x1b/0x20
 [<ffffffff8100aa82>] system_call_fastpath+0x16/0x1b
3 locks held by mv/4227:
 #0:  (&s->s_vfs_rename_mutex){+.+.+.}, at: [<ffffffff8112a301>] lock_rename+0x41/0xf0
 #1:  (&sb->s_type->i_mutex_key#12/1){+.+.+.}, at: [<ffffffff8112a32a>] lock_rename+0x6a/0xf0
 #2:  (&sb->s_type->i_mutex_key#12/2){+.+.+.}, at: [<ffffffff8112a33f>] lock_rename+0x7f/0xf0


INFO: task dd:4230 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
dd            D 0000000000000001     0  4230  23641 0x00000000
 ffff880010857b28 0000000000000046 0000000000000000 ffff880010856000
 ffff880010857fd8 ffff880010856000 ffff880010857fd8 ffff880010857fd8
 ffff880010507040 0000000000014d00 0000000000000001 ffff880010507040
Call Trace:
 [<ffffffff8147f962>] io_schedule+0x52/0x70
 [<ffffffff810dc66d>] sync_page+0x6d/0xb0
 [<ffffffff8147ff4a>] __wait_on_bit_lock+0x5a/0xb0
 [<ffffffff810dc600>] ? sync_page+0x0/0xb0
 [<ffffffff810dc5d9>] __lock_page+0x69/0x70
 [<ffffffff81074870>] ? wake_bit_function+0x0/0x50
 [<ffffffff810e68a0>] write_cache_pages+0x2c0/0x420
 [<ffffffff811dfd30>] ? nfs_writepages_callback+0x0/0x80
 [<ffffffff811df126>] nfs_writepages+0xd6/0x170
 [<ffffffff811df660>] ? nfs_flush_one+0x0/0x100
 [<ffffffff810e6a54>] do_writepages+0x24/0x40
 [<ffffffff81143d30>] writeback_single_inode+0x180/0x360
 [<ffffffff81143f43>] sync_inode+0x33/0x50
 [<ffffffff811de955>] nfs_wb_all+0x45/0x50
 [<ffffffff811cfb3d>] nfs_do_fsync+0x2d/0x60
 [<ffffffff811cfdf2>] nfs_file_flush+0x82/0xc0
 [<ffffffff8111c0b2>] filp_close+0x42/0x90
 [<ffffffff8111c1be>] sys_close+0xbe/0x160
 [<ffffffff8100aa82>] system_call_fastpath+0x16/0x1b
no locks held by dd/4230.


INFO: task dd:4250 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
dd            D 0000000000000000     0  4250  23590 0x00000000
 ffff88001249b988 0000000000000046 0000000000000001 ffff88001249a000
 ffff88001249bfd8 ffff88001249a000 ffff88001249bfd8 ffff88001249bfd8
 ffff88000da7e040 0000000000014d00 0000000000000000 ffff88000da7e040
Call Trace:
 [<ffffffff81136f8e>] inode_wait+0xe/0x20
 [<ffffffff81480092>] __wait_on_bit+0x62/0x90
 [<ffffffff81136f80>] ? inode_wait+0x0/0x20
 [<ffffffff81143b83>] inode_wait_for_writeback+0x93/0xc0
 [<ffffffff81074870>] ? wake_bit_function+0x0/0x50
 [<ffffffff81143cc8>] writeback_single_inode+0x118/0x360
 [<ffffffff81143f43>] sync_inode+0x33/0x50
 [<ffffffff811dfc36>] nfs_wb_page+0x76/0xc0
 [<ffffffff811dfcc4>] nfs_flush_incompatible+0x44/0x70
 [<ffffffff811cf8b5>] nfs_write_begin+0xb5/0x210
 [<ffffffff810dba50>] generic_file_buffered_write+0x190/0x2e0
 [<ffffffff810df224>] __generic_file_aio_write+0x484/0x540
 [<ffffffff810df344>] ? generic_file_aio_write+0x64/0xd0
 [<ffffffff810df358>] generic_file_aio_write+0x78/0xd0
 [<ffffffff811d07cb>] nfs_file_write+0x10b/0x210
 [<ffffffff8111e6e9>] do_sync_write+0xd9/0x120
 [<ffffffff812070f6>] ? security_file_permission+0x16/0x20
 [<ffffffff8111e93a>] ? rw_verify_area+0xea/0x160
 [<ffffffff8111eac6>] vfs_write+0x116/0x230
 [<ffffffff8111f477>] sys_write+0x57/0xb0
 [<ffffffff8100aa82>] system_call_fastpath+0x16/0x1b
1 lock held by dd/4250:
 #0:  (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff810df344>] generic_file_aio_write+0x64/0xd0
