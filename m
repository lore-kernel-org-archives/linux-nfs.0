Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35874 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448AbbCRLG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2015 07:06:29 -0400
Received: from hch by bombadil.infradead.org with local (Exim 4.80.1 #2 (Red Hat Linux))
	id 1YYBnw-0000pX-T1
	for linux-nfs@vger.kernel.org; Wed, 18 Mar 2015 11:06:28 +0000
Date: Wed, 18 Mar 2015 04:06:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Subject: long stall in xfstests generic/075
Message-ID: <20150318110628.GA22522@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm running 4.0-rc against a local xfs server.  I have a few commits
reverted to get over the nfsd use after free bugs:

b4019c0e219bb1301865f8b2efedb4773526ed91
c69899a17ca4836230720e65493942d9582a0424
425c1d4e5b6d4bd700eb94ad8318bdb05431fdc7
6b447539aa9aaac0a0215f3e28a0839553210e7e
39071e6fff7d7e11a5993afd67240ef04a4d05a0
63f5f796af613898669b23ccfc091ec77de7591c

but now I'm running into the following hang:

generic/075 22s ...[  360.216954] INFO: task fsx:17125 blocked for more than 120 seconds.
[  360.218762]       Not tainted 4.0.0-rc3+ #151
[  360.220034] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  360.222310] fsx             D ffff88007af37a18     0 17125  16912 0x00000000
[  360.224732]  ffff88007af37a18 ffff88007a0e5d90 0000000000000002 ffffffff8249b500
[  360.227590]  ffff88007a0e5550 ffff88007af37ad8 ffff88007af37fd8 0000000000000000
[  360.230711]  7fffffffffffffff 0000000000000002 ffffffff81e3b5f0 ffff88007af37a38
[  360.233162] Call Trace:
[  360.233953]  [<ffffffff81e3b5f0>] ? yield+0x30/0x30
[  360.235368]  [<ffffffff81e3b2e2>] schedule+0x32/0x80
[  360.236719]  [<ffffffff81e3ef0c>] schedule_timeout+0x19c/0x210
[  360.238638]  [<ffffffff8112bcd5>] ? ktime_get+0x105/0x140
[  360.240380]  [<ffffffff8108c13e>] ? kvm_clock_read+0x1e/0x20
[  360.242259]  [<ffffffff8108c149>] ? kvm_clock_get_cycles+0x9/0x10
[  360.244046]  [<ffffffff8112bc75>] ? ktime_get+0xa5/0x140
[  360.245694]  [<ffffffff8114d87e>] ? __delayacct_blkio_start+0x1e/0x30
[  360.247201]  [<ffffffff81104ccd>] ? trace_hardirqs_on_caller+0x10d/0x1d0
[  360.248567]  [<ffffffff81e3a638>] io_schedule_timeout+0xa8/0x130
[  360.249752]  [<ffffffff810f9676>] ? prepare_to_wait_exclusive+0x56/0x90
[  360.251075]  [<ffffffff81e3b620>] bit_wait_io+0x30/0x50
[  360.252222]  [<ffffffff81e3b7ce>] __wait_on_bit_lock+0x6e/0xb0
[  360.253432]  [<ffffffff81184302>] ? find_get_entries+0x22/0x160
[  360.254719]  [<ffffffff81181a4c>] ? find_get_entry+0x8c/0xc0
[  360.255799]  [<ffffffff811819c0>] ? find_get_pages_contig+0x1a0/0x1a0
[  360.257058]  [<ffffffff81181c65>] __lock_page+0x95/0xa0
[  360.258175]  [<ffffffff810f9ae0>] ? wake_atomic_t_function+0x30/0x30
[  360.259369]  [<ffffffff81190646>] truncate_inode_pages_range+0x3c6/0x710
[  360.260627]  [<ffffffff81190a10>] truncate_inode_pages+0x10/0x20
[  360.261849]  [<ffffffff81190a66>] truncate_pagecache+0x46/0x70
[  360.262960]  [<ffffffff81357fcf>] nfs_setattr_update_inode+0x12f/0x140
[  360.264192]  [<ffffffff8137832b>] nfs4_proc_setattr+0xbb/0x100
[  360.265366]  [<ffffffff81358162>] nfs_setattr+0xe2/0x200
[  360.266410]  [<ffffffff811e8f90>] notify_change+0x170/0x3f0
[  360.267447]  [<ffffffff811ca581>] do_truncate+0x61/0xa0
[  360.268476]  [<ffffffff811ca924>] do_sys_ftruncate.constprop.18+0x104/0x160
[  360.269678]  [<ffffffff81797b2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  360.270836]  [<ffffffff811ca9a9>] SyS_ftruncate+0x9/0x10
[  360.271880]  [<ffffffff81e40849>] system_call_fastpath+0x12/0x17
[  360.272940] 2 locks held by fsx/17125:
[  360.273719]  #0:  (sb_writers#9){.+.+.+}, at: [<ffffffff811ca8ef>] do_sys_ftruncate.constprop.18+0xcf/0x160
[  360.276008]  #1:  (&sb->s_type->i_mutex_key#11){+.+.+.}, at: [<ffffffff811ca573>] do_truncate+0x53/0xa0
[  385.757079] nfs: server 127.0.0.1 not responding, still trying
[  445.919739] nfs: server 127.0.0.1 OK

from which the run eventually recovers after a few minutes
