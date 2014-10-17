Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.windriver.com ([147.11.1.11]:60968 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbaJQRvB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 13:51:01 -0400
Message-ID: <544156FE.7070905@windriver.com>
Date: Fri, 17 Oct 2014 11:50:54 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        <linux-ext4@vger.kernel.org>, <tytso@mit.edu>,
        <adilger.kernel@dilger.ca>, <linux-rt-users@vger.kernel.org>
Subject: Hang writing to nfs-mounted filesystem from client, all nfsd tasks
 on server blocked in D
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We've run into an odd bug and I'm looking for some advice on how to 
proceed.  Please excuse the cross-posting, I wasn't sure where this 
belongs.  Any guidance would be greatly appreciated.

The problem we're seeing is that by copying a large (10GB) file to an 
nfs-mounted directory we can cause all the nfsd threads to hang in D 
state on the server.

Background:

We've got a couple of systems running 3.4.97, with the "rt120" patch for 
CONFIG_PREEMPT_RT.  On the server we've got an nfs-exported ext4 
filesystem, on top of drbd (used for mirroring over the network via 
protocol C), on top of LVM (simple vg on top of pv, nothing fancy), on 
top of a SATA SSD.

Stuff we've ruled out:

With the above system within 1-3 iterations of copying the file we can 
cause a hang.  If we switch to spinning SATA disks we were unable to 
trigger the problem.  However, if we run within virtualbox with virtual 
PIIX4 IDE disks then we can reproduce the problem.  This seems to point 
to a timing issue as opposed to a hardware issue.

We've confirmed that we can reproduce the problem with drbd out of the 
picture (NFS-exported ext4 on LVM on virtual disks in virtualbox) but it 
takes longer than with the drbd disks.

We've confirmed that we can reproduce the problem with both "deadline" 
and "noop" I/O schedulers.


Stuff still to try:

We're working on setting up a minimal test-case with both the RT and 
standard kernels.  As it stands there are a lot of other components 
running that make it harder to rebuild with different kernel options.


Details:

These are the processes we saw stuck in disk sleep:

$ ps aux | grep D
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1797  4.2  0.0      0     0 ?        D    19:46   9:51 [nfsd]
root      1798  4.2  0.0      0     0 ?        D    19:46   9:54 [nfsd]
root      1799  4.2  0.0      0     0 ?        D    19:46   9:54 [nfsd]
root      1800  4.2  0.0      0     0 ?        D    19:46   9:52 [nfsd]
root      1801  4.2  0.0      0     0 ?        D    19:46   9:53 [nfsd]
root      1802  4.2  0.0      0     0 ?        D    19:46   9:52 [nfsd]
root      1803  4.2  0.0      0     0 ?        D    19:46   9:52 [nfsd]
root      1804  4.2  0.0      0     0 ?        D    19:46   9:52 [nfsd]
root      5305  0.0  0.0      0     0 ?        D    19:49   0:03 
[jbd2/drbd3-8]
root      5634  0.0  0.0      0     0 ?        D    19:49   0:05 
[flush-147:3]

Most of the nfsd threads are stuck waiting for the mutex on an inode in 
order to do a write to the disk. For example, the traceback for pid 1797 
[nfsd]:

[<ffffffff8110fd46>] generic_file_aio_write+0x56/0xe0
[<ffffffff8120591f>] ext4_file_write+0xbf/0x250
[<ffffffff811689ab>] do_sync_readv_writev+0xdb/0x120
[<ffffffff81168c94>] do_readv_writev+0xd4/0x1d0
[<ffffffff81168dcc>] vfs_writev+0x3c/0x50
[<ffffffffa01701b8>] nfsd_vfs_write.isra.12+0xf8/0x2e0 [nfsd]
[<ffffffffa0172888>] nfsd_write+0xf8/0x110 [nfsd]
[<ffffffffa0178b5f>] nfsd3_proc_write+0x9f/0xe0 [nfsd]
[<ffffffffa016cade>] nfsd_dispatch+0xbe/0x1c0 [nfsd]
[<ffffffff81871679>] svc_process+0x499/0x790
[<ffffffffa016c125>] nfsd+0xc5/0x1a0 [nfsd]
[<ffffffff810609bb>] kthread+0xdb/0xe0
[<ffffffff8193b904>] kernel_thread_helper+0x4/0x10

Where generic_file_aio_write() is calling mutex_lock(&inode->i_mutex).

Looking through the other tracebacks, it appears that pid 1803 [nfsd] 
probably has this mutex. Also, looking at the block_start in 
/proc/1803/sched (, it appears that this was the first process to block:

se.statistics.block_start          :      13948189.066634

Its traceback looks like this:
[<ffffffff8125dc55>] jbd2_log_wait_commit+0xc5/0x150
[<ffffffff8125f628>] jbd2_complete_transaction+0xb8/0xd0
[<ffffffff81205dcd>] ext4_sync_file+0x1fd/0x4b0
[<ffffffff81197ad5>] generic_write_sync+0x55/0x70
[<ffffffff8110fdb6>] generic_file_aio_write+0xc6/0xe0
[<ffffffff8120591f>] ext4_file_write+0xbf/0x250
[<ffffffff811689ab>] do_sync_readv_writev+0xdb/0x120
[<ffffffff81168c94>] do_readv_writev+0xd4/0x1d0
[<ffffffff81168dcc>] vfs_writev+0x3c/0x50
[<ffffffffa01701b8>] nfsd_vfs_write.isra.12+0xf8/0x2e0 [nfsd]
[<ffffffffa0172888>] nfsd_write+0xf8/0x110 [nfsd]
[<ffffffffa0178b5f>] nfsd3_proc_write+0x9f/0xe0 [nfsd]
[<ffffffffa016cade>] nfsd_dispatch+0xbe/0x1c0 [nfsd]
[<ffffffff81871679>] svc_process+0x499/0x790
[<ffffffffa016c125>] nfsd+0xc5/0x1a0 [nfsd]
[<ffffffff810609bb>] kthread+0xdb/0xe0
[<ffffffff8193b904>] kernel_thread_helper+0x4/0x10

The inode-i_mutex seems to be taken in ext4_sync_file() before the call 
to jbd2_complete_transaction().

It looks like jbd2_log_wait_commit() has just called schedule() in 
wait_event() in the code below:

while (tid_gt(tid, journal->j_commit_sequence)) {
	jbd_debug(1, "JBD2: want %d, j_commit_sequence=%d\n",
		tid, journal->j_commit_sequence);
	wake_up(&journal->j_wait_commit);
	read_unlock(&journal->j_state_lock);
	wait_event(journal->j_wait_done_commit,
		!tid_gt(tid, journal->j_commit_sequence));
	read_lock(&journal->j_state_lock);
}


The kjournald2 thread (pid 5305) blocks significantly later:
se.statistics.block_start          :      13953712.751778

Here is the traceback:
[<ffffffff8110e3ae>] sleep_on_page+0xe/0x20
[<ffffffff8110e5b8>] wait_on_page_bit+0x78/0x80
[<ffffffff8110e81c>] filemap_fdatawait_range+0x10c/0x1b0
[<ffffffff8110e8eb>] filemap_fdatawait+0x2b/0x30
[<ffffffff8125832c>] jbd2_journal_commit_transaction+0x8dc/0x1a70
	This calls journal_finish_inode_data_buffers which calls
	filemap_fdatawait()
[<ffffffff8125ddaf>] kjournald2+0xbf/0x280
[<ffffffff810609bb>] kthread+0xdb/0xe0
[<ffffffff8193b904>] kernel_thread_helper+0x4/0x10

It is stuck in jbd2_journal_commit_transaction, apparently waiting for 
inodes to be written to disk? I'm not sure what would be preventing that 
from happening.


One of the nfsd processes is stuck in a different spot:
root      1804     2  3 Oct15 ?        00:09:52 [nfsd]

This is the second process to block:
se.statistics.block_start          :      13948189.759783

And the traceback:
[<ffffffff81256f85>] do_get_write_access+0x2b5/0x4e0
[<ffffffff81257300>] jbd2_journal_get_write_access+0x30/0x50
[<ffffffff8123848e>] __ext4_journal_get_write_access+0x3e/0x80
[<ffffffff8123efaf>] ext4_mb_mark_diskspace_used+0xff/0x530
[<ffffffff8124074f>] ext4_mb_new_blocks+0x1ef/0x5f0
[<ffffffff812361d5>] ext4_ext_map_blocks+0xc05/0x1e60
[<ffffffff8120ae15>] ext4_map_blocks+0x1c5/0x270
[<ffffffff8120f0dc>] mpage_da_map_and_submit+0xac/0x4c0
[<ffffffff8120fd5e>] ext4_da_writepages+0x36e/0x720
[<ffffffff8111a5f4>] do_writepages+0x24/0x40
[<ffffffff8110f5db>] __filemap_fdatawrite_range+0x5b/0x60
[<ffffffff8110f6ea>] filemap_write_and_wait_range+0x5a/0x80
[<ffffffff81205c48>] ext4_sync_file+0x78/0x4b0
[<ffffffff81197ad5>] generic_write_sync+0x55/0x70
[<ffffffff8110fdb6>] generic_file_aio_write+0xc6/0xe0
[<ffffffff8120591f>] ext4_file_write+0xbf/0x250
[<ffffffff811689ab>] do_sync_readv_writev+0xdb/0x120
[<ffffffff81168c94>] do_readv_writev+0xd4/0x1d0
[<ffffffff81168dcc>] vfs_writev+0x3c/0x50
[<ffffffffa01701b8>] nfsd_vfs_write.isra.12+0xf8/0x2e0 [nfsd]
[<ffffffffa0172888>] nfsd_write+0xf8/0x110 [nfsd]
[<ffffffffa0178b5f>] nfsd3_proc_write+0x9f/0xe0 [nfsd]
[<ffffffffa016cade>] nfsd_dispatch+0xbe/0x1c0 [nfsd]
[<ffffffff81871679>] svc_process+0x499/0x790
[<ffffffffa016c125>] nfsd+0xc5/0x1a0 [nfsd]
[<ffffffff810609bb>] kthread+0xdb/0xe0
[<ffffffff8193b904>] kernel_thread_helper+0x4/0x10

I'm pretty sure it called schedule() below in the code from 
do_get_write_access():
if (jh->b_jlist == BJ_Shadow) {
	DEFINE_WAIT_BIT(wait, &bh->b_state, BH_Unshadow);
	wait_queue_head_t *wqh;
	wqh = bit_waitqueue(&bh->b_state, BH_Unshadow);
	JBUFFER_TRACE(jh, "on shadow: sleep");
	jbd_unlock_bh_state(bh);
	/* commit wakes up all shadow buffers after IO */
	for ( ; ; ) {
		prepare_to_wait(wqh, &wait.wait,
		TASK_UNINTERRUPTIBLE);
		if (jh->b_jlist != BJ_Shadow)
			break;
		schedule();
	}
	finish_wait(wqh, &wait.wait);
	goto repeat;
}


And finally, there is a flush stuck as well:
root      5634     2  0 Oct15 ?        00:00:05 [flush-147:3]

This is the third process to block:
se.statistics.block_start          :      13948189.814929

And the traceback:
[<ffffffff8109cd0c>] rt_down_read+0x2c/0x40
[<ffffffff8120ac91>] ext4_map_blocks+0x41/0x270
[<ffffffff8120f0dc>] mpage_da_map_and_submit+0xac/0x4c0
[<ffffffff8120f9c9>] write_cache_pages_da+0x3f9/0x420
[<ffffffff8120fd30>] ext4_da_writepages+0x340/0x720
[<ffffffff8111a5f4>] do_writepages+0x24/0x40
[<ffffffff81191b71>] writeback_single_inode+0x181/0x4b0
[<ffffffff811922a2>] writeback_sb_inodes+0x1b2/0x290
[<ffffffff8119241e>] __writeback_inodes_wb+0x9e/0xd0
[<ffffffff811928e3>] wb_writeback+0x223/0x3f0
[<ffffffff81192b4f>] wb_check_old_data_flush+0x9f/0xb0
[<ffffffff8119403f>] wb_do_writeback+0x12f/0x250
[<ffffffff811941f4>] bdi_writeback_thread+0x94/0x320
[<ffffffff810609bb>] kthread+0xdb/0xe0
[<ffffffff8193b904>] kernel_thread_helper+0x4/0x10

