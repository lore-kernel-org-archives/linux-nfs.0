From: Wu Fengguang <fengguang.wu@intel.com>
Subject: NFS: possible circular locking  i_mutex <> mmap_sem
Date: Thu, 18 Jun 2009 10:32:08 +0800
Message-ID: <20090618023208.GA28572@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38492 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbZFRCcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 22:32:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I got a lockdep warning on a stress testing a nfsroot desktop.
The bits puzzled me is how come the page_fault() happens in
generic_file_buffered_write()?

Thanks,
Fengguang

[ 2638.515865] =======================================================
[ 2638.519743] [ INFO: possible circular locking dependency detected ]
[ 2638.519743] 2.6.30-rc8-mm1 #307
[ 2638.519743] -------------------------------------------------------
[ 2638.519743] firefox-bin/3399 is trying to acquire lock:
[ 2638.519743]  (&mm->mmap_sem){++++++}, at: [<ffffffff81548471>] do_page_fault+0x301/0x330
[ 2638.519743]
[ 2638.519743] but task is already holding lock:
[ 2638.519743]  (&sb->s_type->i_mutex_key#6){+.+.+.}, at: [<ffffffff810c2bd2>] generic_file_aio_write+0x52/0xd0
[ 2638.519743]
[ 2638.519743] which lock already depends on the new lock.
[ 2638.519743]
[ 2638.519743]
[ 2638.519743] the existing dependency chain (in reverse order) is:
[ 2638.519743]
[ 2638.519743] -> #1 (&sb->s_type->i_mutex_key#6){+.+.+.}:
[ 2638.519743]        [<ffffffff8107c066>] __lock_acquire+0x12b6/0x1b40
[ 2638.519743]        [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
[ 2638.519743]        [<ffffffff8154328e>] mutex_lock_nested+0x5e/0x390
[ 2638.519743]        [<ffffffff811be15c>] nfs_revalidate_mapping+0xac/0x110    ==> takes i_mutex in nfs_invalidate_mapping()
[ 2638.519743]        [<ffffffff811bba25>] nfs_file_mmap+0x55/0x80
[ 2638.519743]        [<ffffffff810e2bb7>] mmap_region+0x427/0x600
[ 2638.519743]        [<ffffffff810e305e>] do_mmap_pgoff+0x2ce/0x3f0
[ 2638.519743]        [<ffffffff81010c26>] sys_mmap+0x106/0x130                 ==> takes mmap_sem
[ 2638.519743]        [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[ 2638.519743]        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2638.519743]
[ 2638.519743] -> #0 (&mm->mmap_sem){++++++}:
[ 2638.519743]        [<ffffffff8107c206>] __lock_acquire+0x1456/0x1b40
[ 2638.519743]        [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
[ 2638.519743]        [<ffffffff81543d3b>] down_read+0x4b/0x80
[ 2638.519743]        [<ffffffff81548471>] do_page_fault+0x301/0x330            ==> takes mmap_sem
[ 2638.519743]        [<ffffffff81545b55>] page_fault+0x25/0x30
[ 2638.519743]        [<ffffffff810c1970>] generic_file_buffered_write+0x100/0x320
[ 2638.519743]        [<ffffffff810c202d>] __generic_file_aio_write_nolock+0x25d/0x450
[ 2638.519743]        [<ffffffff810c2be9>] generic_file_aio_write+0x69/0xd0     ==> takes i_mutex
[ 2638.519743]        [<ffffffff811bbd36>] nfs_file_write+0x136/0x230
[ 2638.519743]        [<ffffffff810fc991>] do_sync_write+0xf1/0x140
[ 2638.519743]        [<ffffffff810fd59b>] vfs_write+0xcb/0x1a0
[ 2638.519743]        [<ffffffff810fd760>] sys_write+0x50/0x90
[ 2638.519743]        [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
[ 2638.519743]        [<ffffffffffffffff>] 0xffffffffffffffff
[ 2638.519743]
[ 2638.519743] other info that might help us debug this:
[ 2638.519743]
[ 2638.519743] 1 lock held by firefox-bin/3399:
[ 2638.519743]  #0:  (&sb->s_type->i_mutex_key#6){+.+.+.}, at: [<ffffffff810c2bd2>] generic_file_aio_write+0x52/0xd0
[ 2638.519743]
[ 2638.519743] stack backtrace:
[ 2638.519743] Pid: 3399, comm: firefox-bin Not tainted 2.6.30-rc8-mm1 #307
[ 2638.519743] Call Trace:
[ 2638.519743]  [<ffffffff8107a83e>] print_circular_bug_tail+0xde/0xe0
[ 2638.519743]  [<ffffffff8107c206>] __lock_acquire+0x1456/0x1b40
[ 2638.519743]  [<ffffffff8107b1ed>] ? __lock_acquire+0x43d/0x1b40
[ 2638.519743]  [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
[ 2638.519743]  [<ffffffff81548471>] ? do_page_fault+0x301/0x330
[ 2638.519743]  [<ffffffff81543d3b>] down_read+0x4b/0x80
[ 2638.519743]  [<ffffffff81548471>] ? do_page_fault+0x301/0x330
[ 2638.519743]  [<ffffffff81064165>] ? search_exception_tables+0x25/0x50
[ 2638.519743]  [<ffffffff81548471>] do_page_fault+0x301/0x330
[ 2638.519743]  [<ffffffff81545b55>] page_fault+0x25/0x30
[ 2638.519743]  [<ffffffff810bf919>] ? iov_iter_fault_in_readable+0x49/0x60
[ 2638.519743]  [<ffffffff810c1970>] generic_file_buffered_write+0x100/0x320
[ 2638.519743]  [<ffffffff810c202d>] __generic_file_aio_write_nolock+0x25d/0x450
[ 2638.519743]  [<ffffffff810c2bd2>] ? generic_file_aio_write+0x52/0xd0
[ 2638.519743]  [<ffffffff810c2be9>] generic_file_aio_write+0x69/0xd0
[ 2638.519743]  [<ffffffff811bbd36>] nfs_file_write+0x136/0x230
[ 2638.519743]  [<ffffffff810fc991>] do_sync_write+0xf1/0x140
[ 2638.519743]  [<ffffffff8154506f>] ? _spin_unlock_irqrestore+0x3f/0x70
[ 2638.519743]  [<ffffffff81066ae0>] ? autoremove_wake_function+0x0/0x40
[ 2638.519743]  [<ffffffff810127f0>] ? native_sched_clock+0x20/0x80
[ 2638.519743]  [<ffffffff81012859>] ? sched_clock+0x9/0x10
[ 2638.519743]  [<ffffffff81077c85>] ? lock_release_holdtime+0x35/0x1c0
[ 2638.519743]  [<ffffffff810fd59b>] vfs_write+0xcb/0x1a0
[ 2638.519743]  [<ffffffff810fd760>] sys_write+0x50/0x90
[ 2638.519743]  [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b

