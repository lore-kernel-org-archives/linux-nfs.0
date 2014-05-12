Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59520 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbaELIU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 04:20:59 -0400
Date: Mon, 12 May 2014 01:20:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: nfsd4 xdr encoding fixes v2
Message-ID: <20140512082059.GC14194@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series seem to cause hangs during xfstests against a server on the
same VM.  The trace is fairly similar every the hang happens, but the
point at which it happens differs:

[ 3120.186527] INFO: task fill:26222 blocked for more than 120 seconds.
[ 3120.187607]       Not tainted 3.15.0-rc1+ #22
[ 3120.188424] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 3120.189765] fill            D ffff88007a5b3c20     0 26222  26130
0x00000002
[ 3120.191158]  ffff88007a5b3b78 0000000000000046 ffff880079284f10
0000000000013dc0
[ 3120.192666]  ffff88007a5b3fd8 0000000000013dc0 ffff88007350cf10
ffff880079284f10
[ 3120.195303]  0000000000000000 0000000000000002 0000000000000001
0000000000000000
[ 3120.197980] Call Trace:
[ 3120.198849]  [<ffffffff8112ff2d>] ? __delayacct_blkio_start+0x1d/0x20
[ 3120.200791]  [<ffffffff810ead35>] ? prepare_to_wait+0x25/0x90
[ 3120.202438]  [<ffffffff811114f5>] ? ktime_get_ts+0x145/0x180
[ 3120.204033]  [<ffffffff8115ef50>] ? __lock_page+0x70/0x70
[ 3120.205598]  [<ffffffff8107c83f>] ? kvm_clock_read+0x1f/0x30
[ 3120.207236]  [<ffffffff8107c859>] ? kvm_clock_get_cycles+0x9/0x10
[ 3120.209006]  [<ffffffff81111464>] ? ktime_get_ts+0xb4/0x180
[ 3120.210828]  [<ffffffff8112ff2d>] ? __delayacct_blkio_start+0x1d/0x20
[ 3120.212645]  [<ffffffff8115ef50>] ? __lock_page+0x70/0x70
[ 3120.214290]  [<ffffffff81ce5294>] schedule+0x24/0x70
[ 3120.216915]  [<ffffffff81ce536a>] io_schedule+0x8a/0xd0
[ 3120.218484]  [<ffffffff8115ef59>] sleep_on_page+0x9/0x10
[ 3120.219979]  [<ffffffff81ce5a8a>] __wait_on_bit+0x5a/0x90
[ 3120.221543]  [<ffffffff8115e9cf>] ? find_get_pages_tag+0x1f/0x190
[ 3120.223310]  [<ffffffff8115f438>] wait_on_page_bit+0x78/0x80
[ 3120.224934]  [<ffffffff810eb240>] ? wake_atomic_t_function+0x30/0x30
[ 3120.226755]  [<ffffffff8115f5a2>] filemap_fdatawait_range+0x102/0x190
[ 3120.228615]  [<ffffffff8116033a>]
filemap_write_and_wait_range+0x4a/0x80
[ 3120.230640]  [<ffffffff8135c00f>] nfs4_file_fsync+0x5f/0xb0
[ 3120.232230]  [<ffffffff811d70c1>] vfs_fsync+0x21/0x30
[ 3120.233716]  [<ffffffff8132a1fe>] nfs_file_flush+0x6e/0x90
[ 3120.235261]  [<ffffffff811a4ac5>] filp_close+0x35/0x80
[ 3120.236758]  [<ffffffff811c4844>] put_files_struct+0x94/0xe0
[ 3120.238361]  [<ffffffff811c494d>] exit_files+0x4d/0x60
[ 3120.239863]  [<ffffffff810ad947>] do_exit+0x297/0xa00
[ 3120.241336]  [<ffffffff811a91b8>] ? __sb_end_write+0x78/0x80
[ 3120.242925]  [<ffffffff81cea158>] ? retint_swapgs+0x13/0x1b
[ 3120.244541]  [<ffffffff810ae1d7>] do_group_exit+0x47/0xc0
[ 3120.246129]  [<ffffffff810ae262>] SyS_exit_group+0x12/0x20
[ 3120.247960]  [<ffffffff81cf24f9>] system_call_fastpath+0x16/0x1b
[ 3120.249226] no locks held by fill/26222.

