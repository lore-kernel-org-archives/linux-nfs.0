Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.windriver.com ([147.11.146.13]:60764 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaJRRFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2014 13:05:53 -0400
Message-ID: <54429DE4.2040504@windriver.com>
Date: Sat, 18 Oct 2014 11:05:40 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        <linux-ext4@vger.kernel.org>, <tytso@mit.edu>,
        <adilger.kernel@dilger.ca>, <linux-rt-users@vger.kernel.org>
Subject: Re: Hang writing to nfs-mounted filesystem from client -- expected
 code path?
References: <544156FE.7070905@windriver.com>
In-Reply-To: <544156FE.7070905@windriver.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2014 11:50 AM, Chris Friesen wrote:
> Looking through the other tracebacks, it appears that pid 1803 [nfsd]
> probably has this mutex. Also, looking at the block_start in
> /proc/1803/sched (, it appears that this was the first process to block:
>
> se.statistics.block_start          :      13948189.066634
>
> Its traceback looks like this:
> [<ffffffff8125dc55>] jbd2_log_wait_commit+0xc5/0x150
> [<ffffffff8125f628>] jbd2_complete_transaction+0xb8/0xd0
> [<ffffffff81205dcd>] ext4_sync_file+0x1fd/0x4b0
> [<ffffffff81197ad5>] generic_write_sync+0x55/0x70
> [<ffffffff8110fdb6>] generic_file_aio_write+0xc6/0xe0
> [<ffffffff8120591f>] ext4_file_write+0xbf/0x250
> [<ffffffff811689ab>] do_sync_readv_writev+0xdb/0x120
> [<ffffffff81168c94>] do_readv_writev+0xd4/0x1d0
> [<ffffffff81168dcc>] vfs_writev+0x3c/0x50
> [<ffffffffa01701b8>] nfsd_vfs_write.isra.12+0xf8/0x2e0 [nfsd]
> [<ffffffffa0172888>] nfsd_write+0xf8/0x110 [nfsd]
> [<ffffffffa0178b5f>] nfsd3_proc_write+0x9f/0xe0 [nfsd]
> [<ffffffffa016cade>] nfsd_dispatch+0xbe/0x1c0 [nfsd]
> [<ffffffff81871679>] svc_process+0x499/0x790
> [<ffffffffa016c125>] nfsd+0xc5/0x1a0 [nfsd]
> [<ffffffff810609bb>] kthread+0xdb/0xe0
> [<ffffffff8193b904>] kernel_thread_helper+0x4/0x10
>
> The inode-i_mutex seems to be taken in ext4_sync_file() before the call
> to jbd2_complete_transaction().
>
> It looks like jbd2_log_wait_commit() has just called schedule() in
> wait_event() in the code below:
>
> while (tid_gt(tid, journal->j_commit_sequence)) {
>      jbd_debug(1, "JBD2: want %d, j_commit_sequence=%d\n",
>          tid, journal->j_commit_sequence);
>      wake_up(&journal->j_wait_commit);
>      read_unlock(&journal->j_state_lock);
>      wait_event(journal->j_wait_done_commit,
>          !tid_gt(tid, journal->j_commit_sequence));
>      read_lock(&journal->j_state_lock);
> }
>
>
> The kjournald2 thread (pid 5305) blocks significantly later:
> se.statistics.block_start          :      13953712.751778
>
> Here is the traceback:
> [<ffffffff8110e3ae>] sleep_on_page+0xe/0x20
> [<ffffffff8110e5b8>] wait_on_page_bit+0x78/0x80
> [<ffffffff8110e81c>] filemap_fdatawait_range+0x10c/0x1b0
> [<ffffffff8110e8eb>] filemap_fdatawait+0x2b/0x30
> [<ffffffff8125832c>] jbd2_journal_commit_transaction+0x8dc/0x1a70
>      This calls journal_finish_inode_data_buffers which calls
>      filemap_fdatawait()
> [<ffffffff8125ddaf>] kjournald2+0xbf/0x280
> [<ffffffff810609bb>] kthread+0xdb/0xe0
> [<ffffffff8193b904>] kernel_thread_helper+0x4/0x10
>
> It is stuck in jbd2_journal_commit_transaction, apparently waiting for
> inodes to be written to disk? I'm not sure what would be preventing that
> from happening.

Given the above traces, it appears that nfsd is waiting for jbd2 to 
commit a transaction to the journal, and jbd2 is waiting for a page to 
finish writing to disk.

Can someone point me to the code path that actually starts the writing 
process, and also the code path we would expect to follow when the page 
has been written?  I assume we're going to be calling 
set_page_writeback/end_page_writeback, but I don't know how we're going 
to get there given the above tracebacks.

Thanks,
Chris


