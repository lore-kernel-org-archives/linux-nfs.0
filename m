From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: gfs2/pnfs stall
Date: Wed, 12 May 2010 12:03:30 +0100
Message-ID: <1273662210.2884.29.camel@localhost>
References: <20100511201541.GA23321@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753007Ab0ELK7J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 06:59:09 -0400
In-Reply-To: <20100511201541.GA23321@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Tue, 2010-05-11 at 16:15 -0400, J. Bruce Fields wrote:
> Olga ran across the following while running an iozone test (from the
> Windows pnfs client) to a pnfs/gfs2 server built from 2.6.34-rc5-pnfs
> commit 1ea22c6e65028535ecb62a4e00cf706fc6446b77.
> 
> Any ideas?
> 
It might well be the issue which we've been chasing down recently. Bob
has proposed some patches which I've just pushed into the GFS2 -nmw tree
this morning (and there is one that was pushed in a little while back
too).

We'd need a set of glock dumps to be certain, but it does look as if it
might be that,

Steve.


> --b.
> 
> NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> NFSD: starting 90-second grace period
> INFO: task nfsd:2727 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd          D ffffff8d     0  2727      2 0x00000080
>  ea1e99c8 00000046 f83eadf9 ffffff8d c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  eaabdbec c0a4cfc0 c0a4cfc0 0cadd1af 00000061 00000000 00000061 eaabd940
>  c044d910 ea1e9a00 00000000 ea1e9a08 ea1e99d0 f85ad45a ea1e99ec c07809f9
> Call Trace:
>  [<f83eadf9>] ? request_lock+0x7b/0x88 [dlm]
>  [<c044d910>] ? prepare_to_wait+0x53/0x5a
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85b0eb0>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85b1790>] gfs2_inode_lookup+0x16c/0x1d8 [gfs2]
>  [<f85b0ea9>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<f85c09e8>] try_rgrp_unlink+0xbc/0xdc [gfs2]
>  [<f85c1094>] gfs2_inplace_reserve_i+0x200/0x513 [gfs2]
>  [<f85aec39>] ? gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85bf895>] ? gfs2_alloc_get+0x19/0x55 [gfs2]
>  [<f85b62c2>] gfs2_write_begin+0x1e9/0x3ad [gfs2]
>  [<f85ade1f>] ? gfs2_glock_put+0xca/0xe7 [gfs2]
>  [<c049babf>] generic_file_buffered_write+0xba/0x1bf
>  [<c049d21d>] __generic_file_aio_write+0x255/0x286
>  [<c049f910>] ? free_one_page+0x4c/0x59
>  [<c049d2aa>] generic_file_aio_write+0x5c/0xa3
>  [<f85b7bb3>] gfs2_file_aio_write+0x58/0x62 [gfs2]
>  [<c04da5c4>] ? d_obtain_alias+0xe6/0xee
>  [<f85b6def>] ? gfs2_get_dentry+0x12a/0x14c [gfs2]
>  [<c04c30b0>] ? kmem_cache_free+0x6e/0xa4
>  [<c04cb58e>] do_sync_readv_writev+0x89/0xbc
>  [<c056b115>] ? security_file_permission+0x14/0x16
>  [<c04cb7f2>] ? rw_verify_area+0x9d/0xc0
>  [<c04cc1b4>] do_readv_writev+0x82/0xe4
>  [<f85b7b5b>] ? gfs2_file_aio_write+0x0/0x62 [gfs2]
>  [<c056b381>] ? security_task_setgroups+0x14/0x16
>  [<c04538ed>] ? set_groups+0x19/0x15b
>  [<c04c3913>] ? __kmalloc+0x101/0x10d
>  [<c0453af2>] ? groups_alloc+0x35/0xa6
>  [<c04cc251>] vfs_writev+0x3b/0x49
>  [<f851a151>] nfsd_vfs_write+0xdc/0x29a [nfsd]
>  [<c047c772>] ? rcu_start_gp+0x150/0x155
>  [<f851aabb>] nfsd_write+0x54/0xb2 [nfsd]
>  [<f8522f59>] nfsd4_write+0xf2/0x127 [nfsd]
>  [<f8523d38>] nfsd4_proc_compound+0x1b6/0x359 [nfsd]
>  [<f8522e67>] ? nfsd4_write+0x0/0x127 [nfsd]
>  [<f8516312>] nfsd_dispatch+0xd6/0x1a2 [nfsd]
>  [<f844676c>] svc_process_common+0x26f/0x458 [sunrpc]
>  [<f8446b24>] svc_process+0xe3/0xf6 [sunrpc]
>  [<f85167cb>] nfsd+0xdb/0x11a [nfsd]
>  [<f85166f0>] ? nfsd+0x0/0x11a [nfsd]
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task flush-8:16:2779 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> flush-8:16    D e2329b00     0  2779      2 0x00000080
>  ea335d94 00000046 00000000 e2329b00 c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  e9cfc26c c0a4cfc0 c0a4cfc0 1ae91cfc 00000069 00000000 00000069 e9cfbfc0
>  00000001 ea335dcc 00000000 ea335dd4 ea335d9c f85ad45a ea335db8 c07809f9
> Call Trace:
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85c19b7>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85c20f4>] gfs2_write_inode+0x4a/0x10c [gfs2]
>  [<f85c19b0>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<c04e2238>] writeback_single_inode+0xef/0x1a4
>  [<c04e27fb>] writeback_inodes_wb+0x2b4/0x35f
>  [<c04e299c>] wb_writeback+0xf6/0x155
>  [<c0780828>] ? schedule_timeout+0x8b/0xb2
>  [<c04e2ba5>] wb_do_writeback+0x11e/0x12d
>  [<c04e2be1>] bdi_writeback_task+0x2d/0x89
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c04abc30>] bdi_start_fn+0x50/0x9d
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task nfsd:2727 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd          D ffffff8d     0  2727      2 0x00000080
>  ea1e99c8 00000046 f83eadf9 ffffff8d c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  eaabdbec c0a4cfc0 c0a4cfc0 0cadd1af 00000061 00000000 00000061 eaabd940
>  c044d910 ea1e9a00 00000000 ea1e9a08 ea1e99d0 f85ad45a ea1e99ec c07809f9
> Call Trace:
>  [<f83eadf9>] ? request_lock+0x7b/0x88 [dlm]
>  [<c044d910>] ? prepare_to_wait+0x53/0x5a
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85b0eb0>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85b1790>] gfs2_inode_lookup+0x16c/0x1d8 [gfs2]
>  [<f85b0ea9>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<f85c09e8>] try_rgrp_unlink+0xbc/0xdc [gfs2]
>  [<f85c1094>] gfs2_inplace_reserve_i+0x200/0x513 [gfs2]
>  [<f85aec39>] ? gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85bf895>] ? gfs2_alloc_get+0x19/0x55 [gfs2]
>  [<f85b62c2>] gfs2_write_begin+0x1e9/0x3ad [gfs2]
>  [<f85ade1f>] ? gfs2_glock_put+0xca/0xe7 [gfs2]
>  [<c049babf>] generic_file_buffered_write+0xba/0x1bf
>  [<c049d21d>] __generic_file_aio_write+0x255/0x286
>  [<c049f910>] ? free_one_page+0x4c/0x59
>  [<c049d2aa>] generic_file_aio_write+0x5c/0xa3
>  [<f85b7bb3>] gfs2_file_aio_write+0x58/0x62 [gfs2]
>  [<c04da5c4>] ? d_obtain_alias+0xe6/0xee
>  [<f85b6def>] ? gfs2_get_dentry+0x12a/0x14c [gfs2]
>  [<c04c30b0>] ? kmem_cache_free+0x6e/0xa4
>  [<c04cb58e>] do_sync_readv_writev+0x89/0xbc
>  [<c056b115>] ? security_file_permission+0x14/0x16
>  [<c04cb7f2>] ? rw_verify_area+0x9d/0xc0
>  [<c04cc1b4>] do_readv_writev+0x82/0xe4
>  [<f85b7b5b>] ? gfs2_file_aio_write+0x0/0x62 [gfs2]
>  [<c056b381>] ? security_task_setgroups+0x14/0x16
>  [<c04538ed>] ? set_groups+0x19/0x15b
>  [<c04c3913>] ? __kmalloc+0x101/0x10d
>  [<c0453af2>] ? groups_alloc+0x35/0xa6
>  [<c04cc251>] vfs_writev+0x3b/0x49
>  [<f851a151>] nfsd_vfs_write+0xdc/0x29a [nfsd]
>  [<c047c772>] ? rcu_start_gp+0x150/0x155
>  [<f851aabb>] nfsd_write+0x54/0xb2 [nfsd]
>  [<f8522f59>] nfsd4_write+0xf2/0x127 [nfsd]
>  [<f8523d38>] nfsd4_proc_compound+0x1b6/0x359 [nfsd]
>  [<f8522e67>] ? nfsd4_write+0x0/0x127 [nfsd]
>  [<f8516312>] nfsd_dispatch+0xd6/0x1a2 [nfsd]
>  [<f844676c>] svc_process_common+0x26f/0x458 [sunrpc]
>  [<f8446b24>] svc_process+0xe3/0xf6 [sunrpc]
>  [<f85167cb>] nfsd+0xdb/0x11a [nfsd]
>  [<f85166f0>] ? nfsd+0x0/0x11a [nfsd]
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task flush-8:16:2779 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> flush-8:16    D e2329b00     0  2779      2 0x00000080
>  ea335d94 00000046 00000000 e2329b00 c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  e9cfc26c c0a4cfc0 c0a4cfc0 1ae91cfc 00000069 00000000 00000069 e9cfbfc0
>  00000001 ea335dcc 00000000 ea335dd4 ea335d9c f85ad45a ea335db8 c07809f9
> Call Trace:
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85c19b7>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85c20f4>] gfs2_write_inode+0x4a/0x10c [gfs2]
>  [<f85c19b0>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<c04e2238>] writeback_single_inode+0xef/0x1a4
>  [<c04e27fb>] writeback_inodes_wb+0x2b4/0x35f
>  [<c04e299c>] wb_writeback+0xf6/0x155
>  [<c0780828>] ? schedule_timeout+0x8b/0xb2
>  [<c04e2ba5>] wb_do_writeback+0x11e/0x12d
>  [<c04e2be1>] bdi_writeback_task+0x2d/0x89
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c04abc30>] bdi_start_fn+0x50/0x9d
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task nfsd:2727 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd          D ffffff8d     0  2727      2 0x00000080
>  ea1e99c8 00000046 f83eadf9 ffffff8d c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  eaabdbec c0a4cfc0 c0a4cfc0 0cadd1af 00000061 00000000 00000061 eaabd940
>  c044d910 ea1e9a00 00000000 ea1e9a08 ea1e99d0 f85ad45a ea1e99ec c07809f9
> Call Trace:
>  [<f83eadf9>] ? request_lock+0x7b/0x88 [dlm]
>  [<c044d910>] ? prepare_to_wait+0x53/0x5a
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85b0eb0>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85b1790>] gfs2_inode_lookup+0x16c/0x1d8 [gfs2]
>  [<f85b0ea9>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<f85c09e8>] try_rgrp_unlink+0xbc/0xdc [gfs2]
>  [<f85c1094>] gfs2_inplace_reserve_i+0x200/0x513 [gfs2]
>  [<f85aec39>] ? gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85bf895>] ? gfs2_alloc_get+0x19/0x55 [gfs2]
>  [<f85b62c2>] gfs2_write_begin+0x1e9/0x3ad [gfs2]
>  [<f85ade1f>] ? gfs2_glock_put+0xca/0xe7 [gfs2]
>  [<c049babf>] generic_file_buffered_write+0xba/0x1bf
>  [<c049d21d>] __generic_file_aio_write+0x255/0x286
>  [<c049f910>] ? free_one_page+0x4c/0x59
>  [<c049d2aa>] generic_file_aio_write+0x5c/0xa3
>  [<f85b7bb3>] gfs2_file_aio_write+0x58/0x62 [gfs2]
>  [<c04da5c4>] ? d_obtain_alias+0xe6/0xee
>  [<f85b6def>] ? gfs2_get_dentry+0x12a/0x14c [gfs2]
>  [<c04c30b0>] ? kmem_cache_free+0x6e/0xa4
>  [<c04cb58e>] do_sync_readv_writev+0x89/0xbc
>  [<c056b115>] ? security_file_permission+0x14/0x16
>  [<c04cb7f2>] ? rw_verify_area+0x9d/0xc0
>  [<c04cc1b4>] do_readv_writev+0x82/0xe4
>  [<f85b7b5b>] ? gfs2_file_aio_write+0x0/0x62 [gfs2]
>  [<c056b381>] ? security_task_setgroups+0x14/0x16
>  [<c04538ed>] ? set_groups+0x19/0x15b
>  [<c04c3913>] ? __kmalloc+0x101/0x10d
>  [<c0453af2>] ? groups_alloc+0x35/0xa6
>  [<c04cc251>] vfs_writev+0x3b/0x49
>  [<f851a151>] nfsd_vfs_write+0xdc/0x29a [nfsd]
>  [<c047c772>] ? rcu_start_gp+0x150/0x155
>  [<f851aabb>] nfsd_write+0x54/0xb2 [nfsd]
>  [<f8522f59>] nfsd4_write+0xf2/0x127 [nfsd]
>  [<f8523d38>] nfsd4_proc_compound+0x1b6/0x359 [nfsd]
>  [<f8522e67>] ? nfsd4_write+0x0/0x127 [nfsd]
>  [<f8516312>] nfsd_dispatch+0xd6/0x1a2 [nfsd]
>  [<f844676c>] svc_process_common+0x26f/0x458 [sunrpc]
>  [<f8446b24>] svc_process+0xe3/0xf6 [sunrpc]
>  [<f85167cb>] nfsd+0xdb/0x11a [nfsd]
>  [<f85166f0>] ? nfsd+0x0/0x11a [nfsd]
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task flush-8:16:2779 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> flush-8:16    D e2329b00     0  2779      2 0x00000080
>  ea335d94 00000046 00000000 e2329b00 c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  e9cfc26c c0a4cfc0 c0a4cfc0 1ae91cfc 00000069 00000000 00000069 e9cfbfc0
>  00000001 ea335dcc 00000000 ea335dd4 ea335d9c f85ad45a ea335db8 c07809f9
> Call Trace:
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85c19b7>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85c20f4>] gfs2_write_inode+0x4a/0x10c [gfs2]
>  [<f85c19b0>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<c04e2238>] writeback_single_inode+0xef/0x1a4
>  [<c04e27fb>] writeback_inodes_wb+0x2b4/0x35f
>  [<c04e299c>] wb_writeback+0xf6/0x155
>  [<c0780828>] ? schedule_timeout+0x8b/0xb2
>  [<c04e2ba5>] wb_do_writeback+0x11e/0x12d
>  [<c04e2be1>] bdi_writeback_task+0x2d/0x89
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c04abc30>] bdi_start_fn+0x50/0x9d
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task nfsd:2727 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd          D ffffff8d     0  2727      2 0x00000080
>  ea1e99c8 00000046 f83eadf9 ffffff8d c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  eaabdbec c0a4cfc0 c0a4cfc0 0cadd1af 00000061 00000000 00000061 eaabd940
>  c044d910 ea1e9a00 00000000 ea1e9a08 ea1e99d0 f85ad45a ea1e99ec c07809f9
> Call Trace:
>  [<f83eadf9>] ? request_lock+0x7b/0x88 [dlm]
>  [<c044d910>] ? prepare_to_wait+0x53/0x5a
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85b0eb0>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85b1790>] gfs2_inode_lookup+0x16c/0x1d8 [gfs2]
>  [<f85b0ea9>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<f85c09e8>] try_rgrp_unlink+0xbc/0xdc [gfs2]
>  [<f85c1094>] gfs2_inplace_reserve_i+0x200/0x513 [gfs2]
>  [<f85aec39>] ? gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85bf895>] ? gfs2_alloc_get+0x19/0x55 [gfs2]
>  [<f85b62c2>] gfs2_write_begin+0x1e9/0x3ad [gfs2]
>  [<f85ade1f>] ? gfs2_glock_put+0xca/0xe7 [gfs2]
>  [<c049babf>] generic_file_buffered_write+0xba/0x1bf
>  [<c049d21d>] __generic_file_aio_write+0x255/0x286
>  [<c049f910>] ? free_one_page+0x4c/0x59
>  [<c049d2aa>] generic_file_aio_write+0x5c/0xa3
>  [<f85b7bb3>] gfs2_file_aio_write+0x58/0x62 [gfs2]
>  [<c04da5c4>] ? d_obtain_alias+0xe6/0xee
>  [<f85b6def>] ? gfs2_get_dentry+0x12a/0x14c [gfs2]
>  [<c04c30b0>] ? kmem_cache_free+0x6e/0xa4
>  [<c04cb58e>] do_sync_readv_writev+0x89/0xbc
>  [<c056b115>] ? security_file_permission+0x14/0x16
>  [<c04cb7f2>] ? rw_verify_area+0x9d/0xc0
>  [<c04cc1b4>] do_readv_writev+0x82/0xe4
>  [<f85b7b5b>] ? gfs2_file_aio_write+0x0/0x62 [gfs2]
>  [<c056b381>] ? security_task_setgroups+0x14/0x16
>  [<c04538ed>] ? set_groups+0x19/0x15b
>  [<c04c3913>] ? __kmalloc+0x101/0x10d
>  [<c0453af2>] ? groups_alloc+0x35/0xa6
>  [<c04cc251>] vfs_writev+0x3b/0x49
>  [<f851a151>] nfsd_vfs_write+0xdc/0x29a [nfsd]
>  [<c047c772>] ? rcu_start_gp+0x150/0x155
>  [<f851aabb>] nfsd_write+0x54/0xb2 [nfsd]
>  [<f8522f59>] nfsd4_write+0xf2/0x127 [nfsd]
>  [<f8523d38>] nfsd4_proc_compound+0x1b6/0x359 [nfsd]
>  [<f8522e67>] ? nfsd4_write+0x0/0x127 [nfsd]
>  [<f8516312>] nfsd_dispatch+0xd6/0x1a2 [nfsd]
>  [<f844676c>] svc_process_common+0x26f/0x458 [sunrpc]
>  [<f8446b24>] svc_process+0xe3/0xf6 [sunrpc]
>  [<f85167cb>] nfsd+0xdb/0x11a [nfsd]
>  [<f85166f0>] ? nfsd+0x0/0x11a [nfsd]
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task flush-8:16:2779 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> flush-8:16    D e2329b00     0  2779      2 0x00000080
>  ea335d94 00000046 00000000 e2329b00 c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  e9cfc26c c0a4cfc0 c0a4cfc0 1ae91cfc 00000069 00000000 00000069 e9cfbfc0
>  00000001 ea335dcc 00000000 ea335dd4 ea335d9c f85ad45a ea335db8 c07809f9
> Call Trace:
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85c19b7>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85c20f4>] gfs2_write_inode+0x4a/0x10c [gfs2]
>  [<f85c19b0>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<c04e2238>] writeback_single_inode+0xef/0x1a4
>  [<c04e27fb>] writeback_inodes_wb+0x2b4/0x35f
>  [<c04e299c>] wb_writeback+0xf6/0x155
>  [<c0780828>] ? schedule_timeout+0x8b/0xb2
>  [<c04e2ba5>] wb_do_writeback+0x11e/0x12d
>  [<c04e2be1>] bdi_writeback_task+0x2d/0x89
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c04abc30>] bdi_start_fn+0x50/0x9d
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task nfsd:2727 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd          D ffffff8d     0  2727      2 0x00000080
>  ea1e99c8 00000046 f83eadf9 ffffff8d c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  eaabdbec c0a4cfc0 c0a4cfc0 0cadd1af 00000061 00000000 00000061 eaabd940
>  c044d910 ea1e9a00 00000000 ea1e9a08 ea1e99d0 f85ad45a ea1e99ec c07809f9
> Call Trace:
>  [<f83eadf9>] ? request_lock+0x7b/0x88 [dlm]
>  [<c044d910>] ? prepare_to_wait+0x53/0x5a
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85b0eb0>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85b1790>] gfs2_inode_lookup+0x16c/0x1d8 [gfs2]
>  [<f85b0ea9>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<f85c09e8>] try_rgrp_unlink+0xbc/0xdc [gfs2]
>  [<f85c1094>] gfs2_inplace_reserve_i+0x200/0x513 [gfs2]
>  [<f85aec39>] ? gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85bf895>] ? gfs2_alloc_get+0x19/0x55 [gfs2]
>  [<f85b62c2>] gfs2_write_begin+0x1e9/0x3ad [gfs2]
>  [<f85ade1f>] ? gfs2_glock_put+0xca/0xe7 [gfs2]
>  [<c049babf>] generic_file_buffered_write+0xba/0x1bf
>  [<c049d21d>] __generic_file_aio_write+0x255/0x286
>  [<c049f910>] ? free_one_page+0x4c/0x59
>  [<c049d2aa>] generic_file_aio_write+0x5c/0xa3
>  [<f85b7bb3>] gfs2_file_aio_write+0x58/0x62 [gfs2]
>  [<c04da5c4>] ? d_obtain_alias+0xe6/0xee
>  [<f85b6def>] ? gfs2_get_dentry+0x12a/0x14c [gfs2]
>  [<c04c30b0>] ? kmem_cache_free+0x6e/0xa4
>  [<c04cb58e>] do_sync_readv_writev+0x89/0xbc
>  [<c056b115>] ? security_file_permission+0x14/0x16
>  [<c04cb7f2>] ? rw_verify_area+0x9d/0xc0
>  [<c04cc1b4>] do_readv_writev+0x82/0xe4
>  [<f85b7b5b>] ? gfs2_file_aio_write+0x0/0x62 [gfs2]
>  [<c056b381>] ? security_task_setgroups+0x14/0x16
>  [<c04538ed>] ? set_groups+0x19/0x15b
>  [<c04c3913>] ? __kmalloc+0x101/0x10d
>  [<c0453af2>] ? groups_alloc+0x35/0xa6
>  [<c04cc251>] vfs_writev+0x3b/0x49
>  [<f851a151>] nfsd_vfs_write+0xdc/0x29a [nfsd]
>  [<c047c772>] ? rcu_start_gp+0x150/0x155
>  [<f851aabb>] nfsd_write+0x54/0xb2 [nfsd]
>  [<f8522f59>] nfsd4_write+0xf2/0x127 [nfsd]
>  [<f8523d38>] nfsd4_proc_compound+0x1b6/0x359 [nfsd]
>  [<f8522e67>] ? nfsd4_write+0x0/0x127 [nfsd]
>  [<f8516312>] nfsd_dispatch+0xd6/0x1a2 [nfsd]
>  [<f844676c>] svc_process_common+0x26f/0x458 [sunrpc]
>  [<f8446b24>] svc_process+0xe3/0xf6 [sunrpc]
>  [<f85167cb>] nfsd+0xdb/0x11a [nfsd]
>  [<f85166f0>] ? nfsd+0x0/0x11a [nfsd]
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> INFO: task flush-8:16:2779 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> flush-8:16    D e2329b00     0  2779      2 0x00000080
>  ea335d94 00000046 00000000 e2329b00 c0a4cfc0 c0a4cfc0 c0a4cfc0 c0a4cfc0
>  e9cfc26c c0a4cfc0 c0a4cfc0 1ae91cfc 00000069 00000000 00000069 e9cfbfc0
>  00000001 ea335dcc 00000000 ea335dd4 ea335d9c f85ad45a ea335db8 c07809f9
> Call Trace:
>  [<f85ad45a>] gfs2_glock_holder_wait+0xd/0x11 [gfs2]
>  [<c07809f9>] __wait_on_bit+0x39/0x60
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<f85ad44d>] ? gfs2_glock_holder_wait+0x0/0x11 [gfs2]
>  [<c0780ac0>] out_of_line_wait_on_bit+0xa0/0xa8
>  [<c044d72d>] ? wake_bit_function+0x0/0x3c
>  [<f85aebbe>] wait_on_bit.clone.1+0x1c/0x28 [gfs2]
>  [<f85aec39>] gfs2_glock_wait+0x33/0x39 [gfs2]
>  [<f85aeeaf>] gfs2_glock_nq+0x270/0x278 [gfs2]
>  [<f85c19b7>] gfs2_glock_nq_init+0x1a/0x31 [gfs2]
>  [<f85c20f4>] gfs2_write_inode+0x4a/0x10c [gfs2]
>  [<f85c19b0>] ? gfs2_glock_nq_init+0x13/0x31 [gfs2]
>  [<c04e2238>] writeback_single_inode+0xef/0x1a4
>  [<c04e27fb>] writeback_inodes_wb+0x2b4/0x35f
>  [<c04e299c>] wb_writeback+0xf6/0x155
>  [<c0780828>] ? schedule_timeout+0x8b/0xb2
>  [<c04e2ba5>] wb_do_writeback+0x11e/0x12d
>  [<c04e2be1>] bdi_writeback_task+0x2d/0x89
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c04abc30>] bdi_start_fn+0x50/0x9d
>  [<c04abbe0>] ? bdi_start_fn+0x0/0x9d
>  [<c044d38d>] kthread+0x64/0x69
>  [<c044d329>] ? kthread+0x0/0x69
>  [<c040387e>] kernel_thread_helper+0x6/0x10
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


