Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f51.google.com ([209.85.213.51]:36979 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbaGAGtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 02:49:19 -0400
Received: by mail-yh0-f51.google.com with SMTP id f10so5673984yha.38
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 23:49:18 -0700 (PDT)
Received: from localhost ([177.104.48.4])
        by mx.google.com with ESMTPSA id 45sm26352885yhj.32.2014.06.30.23.49.17
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 23:49:17 -0700 (PDT)
Date: Tue, 1 Jul 2014 03:48:08 -0300
From: Silas Silva <silasdb@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: nfsd stucks in 'D' state
Message-ID: <20140701064808.GG27723@auron.ufabc.int.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all.

Looking at the archives, this seems a development mailing list, but
since I don't know better place where put this question, I'll let you
know the problem.

I have an old Debian 6.0 machine that served as a NFS server for a HPC
cluster.  Users started to complain that the machines that accessed the
NFS got really slow (/home, for instance, is NFS-mounted).  After some
investigation I realized that all nfsd process are rapidly going to 'D'
state and rarely coming back.  Some investigation led me to the
hypothesis that it could be a bug in Linux kernel (see [1]).  So, I
decided to update the old kernel (2.6.32-3) to a newer one (3.2.60).

It didn't solve.  Some changes of the nfs mount options, like using the
"soft" option, or tweaking wsize and rsize parameters didn't solve as
well.  After that, I tried to increase the number of nfsd's from 16 to
64.  No way.  All of them stuck to 'D' again

is not a throttle problem in disk.  I/O rates don't go beyond 20 MB/s,
according to iostat.  This is an architecture where 22 computers mount
the same directory (/home) and share information there.  Although a
distributed filesystem is recommended for this case (HPC), according to
our experience NFS suffices for this size of cluster.

For some information, I give you here:

1. output of nfsstat.

2. dmesg with some backtraces.

Thank you!



1. output of nfsstat

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
90589      1          1          0          0

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
57        0% 16334    18% 10186    11% 1513      1% 5442      6% 0         0%
read         write        create       mkdir        symlink      mknod
6         0% 42268    46% 268       0% 2         0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
259       0% 0         0% 279       0% 0         0% 0         0% 70        0%
fsstat       fsinfo       pathconf     commit
29        0% 26        0% 13        0% 13697    15%

Client rpc stats:
calls      retrans    authrefrsh
0          0          0



2. dmesg with some backtraces (you realize that there are some other
processes in 'D', like a sync command I executed and didn't return.
Disk problem?

kjournald       D ffff880610e48dc0     0   790      2 0x00000000
 ffff880610e48dc0 0000000000000046 ffff880600000000 ffff880613d01b80
 0000000000013140 ffff88061257ffd8 ffff88061257ffd8 0000000000013140
 ffff880610e48dc0 0000000000013140 0000000000013140 ffff88061257e010
Call Trace:
 [<ffffffff8101485d>] ? read_tsc+0x5/0x16
 [<ffffffff8111ee09>] ? unmap_underlying_metadata+0x4b/0x4b
 [<ffffffff8132b4cc>] ? io_schedule+0x84/0xc3
 [<ffffffff8111ee12>] ? sleep_on_buffer+0x9/0xd
 [<ffffffff8132b8c7>] ? __wait_on_bit+0x3e/0x6f
 [<ffffffff8132b966>] ? out_of_line_wait_on_bit+0x6e/0x77
 [<ffffffff8111ee09>] ? unmap_underlying_metadata+0x4b/0x4b
 [<ffffffff81062fe7>] ? autoremove_wake_function+0x2a/0x2a
 [<ffffffffa02fbb3e>] ? wait_on_buffer+0xe/0x28 [jbd]
 [<ffffffffa02fc22f>] ? journal_commit_transaction+0x597/0xec8 [jbd]
 [<ffffffff81062fbd>] ? wake_up_bit+0x20/0x20
 [<ffffffff81054bcf>] ? lock_timer_base+0x25/0x49
 [<ffffffffa03001eb>] ? kjournald+0xde/0x220 [jbd]
 [<ffffffff81062fbd>] ? wake_up_bit+0x20/0x20
 [<ffffffffa030010d>] ? commit_timeout+0xa/0xa [jbd]
 [<ffffffffa030010d>] ? commit_timeout+0xa/0xa [jbd]
 [<ffffffff81062b71>] ? kthread+0x7a/0x82
 [<ffffffff8132f234>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81062af7>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff8132f230>] ? gs_change+0x13/0x13
nfsd            D ffff880610f5d280     0  1336      2 0x00000000
 ffff880610f5d280 0000000000000046 0000000000000000 ffff880613d06e00
 0000000000013140 ffff880607aa7fd8 ffff880607aa7fd8 0000000000013140
 ffff880610f5d280 0000000000013140 0000000000013140 ffff880607aa6010
Call Trace:
 [<ffffffff8101485d>] ? read_tsc+0x5/0x16
 [<ffffffff810b9fdd>] ? __lock_page+0x63/0x63
 [<ffffffff8132b4cc>] ? io_schedule+0x84/0xc3
 [<ffffffff8119b6f8>] ? radix_tree_gang_lookup_slot+0x85/0xa9
 [<ffffffff810b9fe6>] ? sleep_on_page+0x9/0xd
 [<ffffffff8132b8c7>] ? __wait_on_bit+0x3e/0x6f
 [<ffffffff810ba194>] ? wait_on_page_bit+0x6a/0x70
 [<ffffffff81062fe7>] ? autoremove_wake_function+0x2a/0x2a
 [<ffffffff810c44eb>] ? truncate_inode_pages_range+0x2c6/0x317
 [<ffffffff810c4581>] ? truncate_pagecache+0x36/0x4c
 [<ffffffffa036e199>] ? ext3_setattr+0x271/0x2c6 [ext3]
 [<ffffffff8110e46d>] ? notify_change+0x1c5/0x296
 [<ffffffffa042ec71>] ? nfsd_setattr+0x296/0x2e0 [nfsd]
 [<ffffffffa043417c>] ? nfsd3_proc_setattr+0x64/0x6e [nfsd]
 [<ffffffffa042a2fe>] ? nfsd_dispatch+0xd9/0x1bb [nfsd]
 [<ffffffffa03a6ea2>] ? svc_process+0x422/0x626 [sunrpc]
 [<ffffffffa042a790>] ? nfsd_svc+0x167/0x167 [nfsd]
 [<ffffffffa042a873>] ? nfsd+0xe3/0x127 [nfsd]
 [<ffffffff81062b71>] ? kthread+0x7a/0x82
 [<ffffffff8132f234>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81062af7>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff8132f230>] ? gs_change+0x13/0x13
nfsd            D ffff880610f5e720     0  1340      2 0x00000000
 ffff880610f5e720 0000000000000046 0000000000000000 ffffffff8160d020
 0000000000013140 ffff8806076b7fd8 ffff8806076b7fd8 0000000000013140
 ffff880610f5e720 0000000000013140 0000000000013140 ffff8806076b6010
Call Trace:
 [<ffffffff810b9fdd>] ? __lock_page+0x63/0x63
 [<ffffffff8132b4cc>] ? io_schedule+0x84/0xc3
 [<ffffffff810b9fe6>] ? sleep_on_page+0x9/0xd
 [<ffffffff8132b8c7>] ? __wait_on_bit+0x3e/0x6f
 [<ffffffffa02fb383>] ? do_get_write_access+0x36d/0x3b4 [jbd]
 [<ffffffff810ba194>] ? wait_on_page_bit+0x6a/0x70
 [<ffffffff81062fe7>] ? autoremove_wake_function+0x2a/0x2a
 [<ffffffff810bb4e6>] ? grab_cache_page_write_begin+0x9f/0xb1
 [<ffffffffa036e928>] ? ext3_write_begin+0xae/0x20e [ext3]
 [<ffffffff810b96cf>] ? generic_file_buffered_write+0x121/0x28e
 [<ffffffff810ba975>] ? __generic_file_aio_write+0x243/0x277
 [<ffffffff810ba9a9>] ? __generic_file_aio_write+0x277/0x277
 [<ffffffff810baa08>] ? generic_file_aio_write+0x5f/0xb3
 [<ffffffff810f9d55>] ? do_sync_readv_writev+0xa3/0xde
 [<ffffffffa042caa6>] ? fh_compose+0x33f/0x33f [nfsd]
 [<ffffffffa00735e5>] ? exportfs_decode_fh+0xc7/0x226 [exportfs]
 [<ffffffffa03adfdb>] ? seconds_since_boot+0x11/0x1a [sunrpc]
 [<ffffffff810f9a3b>] ? copy_from_user+0x18/0x30
 [<ffffffff81165106>] ? security_file_permission+0x18/0x2d
 [<ffffffff810fa3b1>] ? do_readv_writev+0xaf/0x125
 [<ffffffff8113c9a4>] ? dqget+0x2c0/0x31b
 [<ffffffff8113cf00>] ? dquot_initialize+0x6/0xd
 [<ffffffff8113ced3>] ? __dquot_initialize+0x145/0x16c
 [<ffffffff8113beb7>] ? dqput+0x3b/0x1b7
 [<ffffffffa042de88>] ? nfsd_vfs_write+0xc9/0x2b5 [nfsd]
 [<ffffffffa042e38b>] ? nfsd_open+0xfd/0x14d [nfsd]
 [<ffffffffa042e6f3>] ? nfsd_write+0xbb/0xdc [nfsd]
 [<ffffffffa0433e72>] ? nfsd3_proc_write+0xcf/0xea [nfsd]
 [<ffffffffa042a2fe>] ? nfsd_dispatch+0xd9/0x1bb [nfsd]
 [<ffffffffa03a6ea2>] ? svc_process+0x422/0x626 [sunrpc]
 [<ffffffffa042a790>] ? nfsd_svc+0x167/0x167 [nfsd]
 [<ffffffffa042a873>] ? nfsd+0xe3/0x127 [nfsd]
 [<ffffffff81062b71>] ? kthread+0x7a/0x82
 [<ffffffff8132f234>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81062af7>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff8132f230>] ? gs_change+0x13/0x13
nfsd            D ffff880610e4d280     0  1346      2 0x00000000
 ffff880610e4d280 0000000000000046 0000000000000000 ffff880613d06e00
 0000000000013140 ffff880606ce9fd8 ffff880606ce9fd8 0000000000013140
 ffff880610e4d280 0000000000013140 0000000000013140 ffff880606ce8010
Call Trace:
 [<ffffffff810b9fdd>] ? __lock_page+0x63/0x63
 [<ffffffff8132b4cc>] ? io_schedule+0x84/0xc3
 [<ffffffff810b9fe6>] ? sleep_on_page+0x9/0xd
 [<ffffffff8132b8c7>] ? __wait_on_bit+0x3e/0x6f
 [<ffffffffa02fb383>] ? do_get_write_access+0x36d/0x3b4 [jbd]
 [<ffffffff810ba194>] ? wait_on_page_bit+0x6a/0x70
 [<ffffffff81062fe7>] ? autoremove_wake_function+0x2a/0x2a
 [<ffffffff810bb4e6>] ? grab_cache_page_write_begin+0x9f/0xb1
 [<ffffffffa036e928>] ? ext3_write_begin+0xae/0x20e [ext3]
 [<ffffffff810b96cf>] ? generic_file_buffered_write+0x121/0x28e
 [<ffffffff810ba975>] ? __generic_file_aio_write+0x243/0x277
 [<ffffffff810ba9a9>] ? __generic_file_aio_write+0x277/0x277
 [<ffffffff810baa08>] ? generic_file_aio_write+0x5f/0xb3
 [<ffffffff810f9d55>] ? do_sync_readv_writev+0xa3/0xde
 [<ffffffffa042caa6>] ? fh_compose+0x33f/0x33f [nfsd]
 [<ffffffffa00735e5>] ? exportfs_decode_fh+0xc7/0x226 [exportfs]
 [<ffffffffa03adfdb>] ? seconds_since_boot+0x11/0x1a [sunrpc]
 [<ffffffff810f9a3b>] ? copy_from_user+0x18/0x30
 [<ffffffff81165106>] ? security_file_permission+0x18/0x2d
 [<ffffffff810fa3b1>] ? do_readv_writev+0xaf/0x125
 [<ffffffff8113c9a4>] ? dqget+0x2c0/0x31b
 [<ffffffff8113cf00>] ? dquot_initialize+0x6/0xd
 [<ffffffff8113ced3>] ? __dquot_initialize+0x145/0x16c
 [<ffffffff8113beb7>] ? dqput+0x3b/0x1b7
 [<ffffffffa042de88>] ? nfsd_vfs_write+0xc9/0x2b5 [nfsd]
 [<ffffffffa042e38b>] ? nfsd_open+0xfd/0x14d [nfsd]
 [<ffffffffa042e6f3>] ? nfsd_write+0xbb/0xdc [nfsd]
 [<ffffffffa0433e72>] ? nfsd3_proc_write+0xcf/0xea [nfsd]
 [<ffffffffa042a2fe>] ? nfsd_dispatch+0xd9/0x1bb [nfsd]
 [<ffffffffa03a6ea2>] ? svc_process+0x422/0x626 [sunrpc]
 [<ffffffffa042a790>] ? nfsd_svc+0x167/0x167 [nfsd]
 [<ffffffffa042a873>] ? nfsd+0xe3/0x127 [nfsd]
 [<ffffffff81062b71>] ? kthread+0x7a/0x82
 [<ffffffff8132f234>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81062af7>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff8132f230>] ? gs_change+0x13/0x13
sync            D ffff880610a11b80     0  6556   6486 0x00000004
 ffff880610a11b80 0000000000000086 0000000000000000 ffff880613d00000
 0000000000013140 ffff8805f8515fd8 ffff8805f8515fd8 0000000000013140
 ffff880610a11b80 0000000000013140 0000000000013140 ffff8805f8514010
Call Trace:
 [<ffffffff8132b693>] ? schedule_timeout+0x2d/0xd7
 [<ffffffff810f126b>] ? virt_to_head_page+0x9/0x2c
 [<ffffffff810f3712>] ? kmem_cache_free+0x12/0x9e
 [<ffffffff8132b2d9>] ? wait_for_common+0xd1/0x14e
 [<ffffffff81045664>] ? try_to_wake_up+0x191/0x191
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111923d>] ? writeback_inodes_sb_nr+0x7b/0x81
 [<ffffffff8111c8ef>] ? __sync_filesystem+0x53/0x79
 [<ffffffff810fbf1e>] ? iterate_supers+0x5e/0xab
 [<ffffffff8111c956>] ? sys_sync+0x2d/0x58
 [<ffffffff8132d0d2>] ? system_call_fastpath+0x16/0x1b
sync            D ffff880610a11b80     0  6556   6486 0x00000004
 ffff880610a11b80 0000000000000086 0000000000000000 ffff880613d00000
 0000000000013140 ffff8805f8515fd8 ffff8805f8515fd8 0000000000013140
 ffff880610a11b80 0000000000013140 0000000000013140 ffff8805f8514010
Call Trace:
 [<ffffffff8132b693>] ? schedule_timeout+0x2d/0xd7
 [<ffffffff810f126b>] ? virt_to_head_page+0x9/0x2c
 [<ffffffff810f3712>] ? kmem_cache_free+0x12/0x9e
 [<ffffffff8132b2d9>] ? wait_for_common+0xd1/0x14e
 [<ffffffff81045664>] ? try_to_wake_up+0x191/0x191
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111923d>] ? writeback_inodes_sb_nr+0x7b/0x81
 [<ffffffff8111c8ef>] ? __sync_filesystem+0x53/0x79
 [<ffffffff810fbf1e>] ? iterate_supers+0x5e/0xab
 [<ffffffff8111c956>] ? sys_sync+0x2d/0x58
 [<ffffffff8132d0d2>] ? system_call_fastpath+0x16/0x1b
sync            D ffff880610a11b80     0  6556   6486 0x00000004
 ffff880610a11b80 0000000000000086 0000000000000000 ffff880613d00000
 0000000000013140 ffff8805f8515fd8 ffff8805f8515fd8 0000000000013140
 ffff880610a11b80 0000000000013140 0000000000013140 ffff8805f8514010
Call Trace:
 [<ffffffff8132b693>] ? schedule_timeout+0x2d/0xd7
 [<ffffffff810f126b>] ? virt_to_head_page+0x9/0x2c
 [<ffffffff810f3712>] ? kmem_cache_free+0x12/0x9e
 [<ffffffff8132b2d9>] ? wait_for_common+0xd1/0x14e
 [<ffffffff81045664>] ? try_to_wake_up+0x191/0x191
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111923d>] ? writeback_inodes_sb_nr+0x7b/0x81
 [<ffffffff8111c8ef>] ? __sync_filesystem+0x53/0x79
 [<ffffffff810fbf1e>] ? iterate_supers+0x5e/0xab
 [<ffffffff8111c956>] ? sys_sync+0x2d/0x58
 [<ffffffff8132d0d2>] ? system_call_fastpath+0x16/0x1b
kjournald       D ffff880610e48dc0     0   790      2 0x00000000
 ffff880610e48dc0 0000000000000046 ffff880600000000 ffff880613d05280
 0000000000013140 ffff88061257ffd8 ffff88061257ffd8 0000000000013140
 ffff880610e48dc0 0000000000013140 0000000000013140 ffff88061257e010
Call Trace:
 [<ffffffff8101485d>] ? read_tsc+0x5/0x16
 [<ffffffff8111ee09>] ? unmap_underlying_metadata+0x4b/0x4b
 [<ffffffff8132b4cc>] ? io_schedule+0x84/0xc3
 [<ffffffff8111ee12>] ? sleep_on_buffer+0x9/0xd
 [<ffffffff8132b8c7>] ? __wait_on_bit+0x3e/0x6f
 [<ffffffff8132b966>] ? out_of_line_wait_on_bit+0x6e/0x77
 [<ffffffff8111ee09>] ? unmap_underlying_metadata+0x4b/0x4b
 [<ffffffff81062fe7>] ? autoremove_wake_function+0x2a/0x2a
 [<ffffffffa02fbb3e>] ? wait_on_buffer+0xe/0x28 [jbd]
 [<ffffffffa02fc22f>] ? journal_commit_transaction+0x597/0xec8 [jbd]
 [<ffffffff81062fbd>] ? wake_up_bit+0x20/0x20
 [<ffffffff81054bcf>] ? lock_timer_base+0x25/0x49
 [<ffffffffa03001eb>] ? kjournald+0xde/0x220 [jbd]
 [<ffffffff81062fbd>] ? wake_up_bit+0x20/0x20
 [<ffffffffa030010d>] ? commit_timeout+0xa/0xa [jbd]
 [<ffffffffa030010d>] ? commit_timeout+0xa/0xa [jbd]
 [<ffffffff81062b71>] ? kthread+0x7a/0x82
 [<ffffffff8132f234>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81062af7>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff8132f230>] ? gs_change+0x13/0x13
flush-8:16      D ffff8806106e2940     0  1009      2 0x00000000
 ffff8806106e2940 0000000000000046 0000000000000000 ffff880613d01b80
 0000000000013140 ffff88061196bfd8 ffff88061196bfd8 0000000000013140
 ffff8806106e2940 0000000000013140 0000000000013140 ffff88061196a010
Call Trace:
 [<ffffffff8132b4cc>] ? io_schedule+0x84/0xc3
 [<ffffffff81188985>] ? get_request_wait+0x104/0x193
 [<ffffffff81062fbd>] ? wake_up_bit+0x20/0x20
 [<ffffffff81188c78>] ? blk_queue_bio+0x17a/0x27a
 [<ffffffff8111ef7d>] ? T.1002+0x17/0x17
 [<ffffffff81188300>] ? generic_make_request+0x8e/0xcd
 [<ffffffff81188418>] ? submit_bio+0xd9/0xf7
 [<ffffffff8111ef7d>] ? T.1002+0x17/0x17
 [<ffffffff8112153b>] ? bio_alloc_bioset+0x44/0xb5
 [<ffffffff8111dbd0>] ? submit_bh+0xe5/0x105
 [<ffffffff81120267>] ? __block_write_full_page+0x1dd/0x2b5
 [<ffffffff810c0cc5>] ? __writepage+0xa/0x21
 [<ffffffff810c1e27>] ? write_cache_pages+0x226/0x31e
 [<ffffffff810c0cbb>] ? set_page_dirty+0x61/0x61
 [<ffffffff810c1f5d>] ? generic_writepages+0x3e/0x55
 [<ffffffff81118a4f>] ? writeback_single_inode+0x17f/0x362
 [<ffffffff81118efe>] ? writeback_sb_inodes+0x169/0x1ff
 [<ffffffff81119001>] ? __writeback_inodes_wb+0x6d/0xab
 [<ffffffff81119720>] ? wb_writeback+0x128/0x222
 [<ffffffff810c149a>] ? bdi_dirty_limit+0x27/0x81
 [<ffffffff8111989b>] ? wb_do_writeback+0x81/0x1dd
 [<ffffffff8105508b>] ? del_timer_sync+0x34/0x3e
 [<ffffffff81119aba>] ? bdi_writeback_thread+0xc3/0x201
 [<ffffffff811199f7>] ? wb_do_writeback+0x1dd/0x1dd
 [<ffffffff811199f7>] ? wb_do_writeback+0x1dd/0x1dd
 [<ffffffff81062b71>] ? kthread+0x7a/0x82
 [<ffffffff8132f234>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81062af7>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff8132f230>] ? gs_change+0x13/0x13
sync            D ffff880610a11b80     0  6556   6486 0x00000004
 ffff880610a11b80 0000000000000086 0000000000000000 ffff880613d00000
 0000000000013140 ffff8805f8515fd8 ffff8805f8515fd8 0000000000013140
 ffff880610a11b80 0000000000013140 0000000000013140 ffff8805f8514010
Call Trace:
 [<ffffffff8132b693>] ? schedule_timeout+0x2d/0xd7
 [<ffffffff810f126b>] ? virt_to_head_page+0x9/0x2c
 [<ffffffff810f3712>] ? kmem_cache_free+0x12/0x9e
 [<ffffffff8132b2d9>] ? wait_for_common+0xd1/0x14e
 [<ffffffff81045664>] ? try_to_wake_up+0x191/0x191
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111c915>] ? __sync_filesystem+0x79/0x79
 [<ffffffff8111923d>] ? writeback_inodes_sb_nr+0x7b/0x81
 [<ffffffff8111c8ef>] ? __sync_filesystem+0x53/0x79
 [<ffffffff810fbf1e>] ? iterate_supers+0x5e/0xab
 [<ffffffff8111c956>] ? sys_sync+0x2d/0x58
 [<ffffffff8132d0d2>] ? system_call_fastpath+0x16/0x1b
nfsd: peername failed (err 107)!
nfsd: last server has exited, flushing export cache
svc: failed to register lockdv1 RPC service (errno 97).


References:

[1] http://administratosphere.wordpress.com/2011/05/13/linux-kernel-sync-bug/

--
Silas Silva

-- 
Silas Silva
