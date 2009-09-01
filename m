From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: lock dependency warning
Date: Tue, 1 Sep 2009 18:11:55 -0400
Message-ID: <20090901221155.GA30521@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39610 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755230AbZIAWLx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 18:11:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm getting this, running connectathon tests on a kernel which includes your
latest nfs-for-2.6.32.  Is it new?

--b.

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.31-rc8-00162-gf7fcab6 #321
-------------------------------------------------------
bigfile/3763 is trying to acquire lock:
 (&sb->s_type->i_mutex_key#11){+.+.+.}, at: [<c11cd5f2>] nfs_revalidate_mapping+0x92/0xd0

but task is already holding lock:
 (&mm->mmap_sem){++++++}, at: [<c100640e>] sys_mmap2+0x8e/0xc0

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&mm->mmap_sem){++++++}:
       [<c1051476>] __lock_acquire+0xef6/0x1710
       [<c1051d5f>] lock_acquire+0xcf/0xf0
       [<c10951cb>] might_fault+0x8b/0xb0
       [<c13cb5f7>] copy_to_user+0x37/0x70
       [<c10bb059>] filldir64+0xa9/0xf0
       [<c11c7f82>] nfs_do_filldir+0x1e2/0x5b0
       [<c11c871e>] nfs_readdir+0x3ce/0x910
       [<c10bb2f5>] vfs_readdir+0x95/0xb0
       [<c10bb37e>] sys_getdents64+0x6e/0xc0
       [<c1002f49>] syscall_call+0x7/0xb
       [<ffffffff>] 0xffffffff

-> #0 (&sb->s_type->i_mutex_key#11){+.+.+.}:
       [<c10515ab>] __lock_acquire+0x102b/0x1710
       [<c1051d5f>] lock_acquire+0xcf/0xf0
       [<c17292ed>] mutex_lock_nested+0x5d/0x310
       [<c11cd5f2>] nfs_revalidate_mapping+0x92/0xd0
       [<c11ca5c8>] nfs_file_mmap+0x48/0x80
       [<c109c436>] mmap_region+0x2b6/0x430
       [<c109c7fd>] do_mmap_pgoff+0x24d/0x350
       [<c100642d>] sys_mmap2+0xad/0xc0
       [<c1002f49>] syscall_call+0x7/0xb
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by bigfile/3763:
 #0:  (&mm->mmap_sem){++++++}, at: [<c100640e>] sys_mmap2+0x8e/0xc0

stack backtrace:
Pid: 3763, comm: bigfile Not tainted 2.6.31-rc8-00162-gf7fcab6 #321
Call Trace:
 [<c1727d29>] ? printk+0x1d/0x1f
 [<c10500ac>] print_circular_bug_tail+0xbc/0xc0
 [<c10515ab>] __lock_acquire+0x102b/0x1710
 [<c11cd5f2>] ? nfs_revalidate_mapping+0x92/0xd0
 [<c1051d5f>] lock_acquire+0xcf/0xf0
 [<c11cd5f2>] ? nfs_revalidate_mapping+0x92/0xd0
 [<c11cd5f2>] ? nfs_revalidate_mapping+0x92/0xd0
 [<c17292ed>] mutex_lock_nested+0x5d/0x310
 [<c11cd5f2>] ? nfs_revalidate_mapping+0x92/0xd0
 [<c11f26f0>] ? nfs_have_delegation+0x0/0xc0
 [<c11cd5f2>] nfs_revalidate_mapping+0x92/0xd0
 [<c11ca5c8>] nfs_file_mmap+0x48/0x80
 [<c109c436>] mmap_region+0x2b6/0x430
 [<c109c7fd>] do_mmap_pgoff+0x24d/0x350
 [<c100642d>] sys_mmap2+0xad/0xc0
 [<c1002f49>] syscall_call+0x7/0xb

