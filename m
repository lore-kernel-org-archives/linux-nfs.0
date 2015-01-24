Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53941 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbAXStM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 13:49:12 -0500
Date: Sat, 24 Jan 2015 10:49:11 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Tom Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH v5 00/51] Add Flexfile Layout Module
Message-ID: <20150124184911.GA8159@infradead.org>
References: <CAKVebiXRc2OZ+=PkC33de25xX3C-VOzrW+Ufo6s5e05TC422jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiXRc2OZ+=PkC33de25xX3C-VOzrW+Ufo6s5e05TC422jw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 24, 2015 at 10:37:09PM +0800, Peng Tao wrote:
> oops, sorry for editing the mail subject... It was supposed to reply
> to your email "Re: [PATCH v5 00/51] Add Flexfile Layout Module"

With your patch it surives a little longer, but then this happens:
(you could just try my receipt for the reproducer, it really is that
simple..):

generic/013 26s ...[  192.023340] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [fsstress:9440]
[  192.024091] Modules linked in:
[  192.024489] irq event stamp: 93792
[  192.024845] hardirqs last  enabled at (93791): [<ffffffff81dfd9f7>] restore_args+0x0/0x30
[  192.025701] hardirqs last disabled at (93792): [<ffffffff81dfdcdd>] apic_timer_interrupt+0x6d/0x80
[  192.026606] softirqs last  enabled at (93790): [<ffffffff810be593>] __do_softirq+0x1e3/0x2d0
[  192.026651] softirqs last disabled at (93785): [<ffffffff810be96e>] irq_exit+0x9e/0xc0
[  192.026651] CPU: 0 PID: 9440 Comm: fsstress Not tainted 3.19.0-rc5+ #1555
[  192.026651] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  192.026651] task: ffff88007a4e82d0 ti: ffff88007d7fc000 task.ti: ffff88007d7fc000
[  192.026651] RIP: 0010:[<ffffffff8178af6c>]  [<ffffffff8178af6c>] __radix_tree_lookup+0x5c/0xb0
[  192.026651] RSP: 0018:ffff88007d7ffa58  EFLAGS: 00000293
[  192.026651] RAX: 0000000000000002 RBX: ffffffff81dfd9f7 RCX: 0000000000000000
[  192.026651] RDX: 0000000000000000 RSI: 0000000000000028 RDI: 0000000000000002
[  192.026651] RBP: ffff88007d7ffa58 R08: 000000000000002b R09: 0000000000000000
[  192.026651] R10: ffff880078426d48 R11: 0000000000000000 R12: ffff88007d7ff9c8
[  192.026651] R13: ffff88007a4e82d0 R14: ffff88007d7fc000 R15: ffff88007a4e82d0
[  192.026651] FS:  00007ff90c7b1700(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  192.026651] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  192.026651] CR2: 00007ff904020000 CR3: 000000007a12a000 CR4: 00000000000006f0
[  192.026651] Stack:
[  192.026651]  ffff88007d7ffa68 ffffffff8178afcd ffff88007d7ffa98 ffffffff81178d6a
[  192.026651]  ffff88007adf4140 ffff88007d7ffd48 ffff88007adf4140 ffff88007879b518
[  192.026651]  ffff88007d7ffaf8 ffffffff8139c8b6 ffffffff8139c878 0000000000000000
[  192.026651] Call Trace:
[  192.026651]  [<ffffffff8178afcd>] radix_tree_lookup+0xd/0x10
[  192.026651]  [<ffffffff81178d6a>] page_cache_next_hole+0x3a/0x50
[  192.026651]  [<ffffffff8139c8b6>] bl_pg_init_write+0xf6/0x140
[  192.026651]  [<ffffffff8139c878>] ? bl_pg_init_write+0xb8/0x140
[  192.026651]  [<ffffffff813559e0>] __nfs_pageio_add_request+0xf0/0x470
[  192.026651]  [<ffffffff81356293>] nfs_pageio_add_request+0x93/0x1c0
[  192.026651]  [<ffffffff811788ff>] ? find_get_pages_tag+0x1f/0x190
[  192.026651]  [<ffffffff81359ed0>] nfs_do_writepage+0x120/0x1e0
[  192.026651]  [<ffffffff8135a048>] nfs_writepages_callback+0x18/0x30
[  192.026651]  [<ffffffff81182616>] write_cache_pages+0x1e6/0x490
[  192.026651]  [<ffffffff8135a030>] ? nfs_writepage_locked+0xa0/0xa0
[  192.026651]  [<ffffffff8135a124>] nfs_writepages+0x94/0x130
[  192.026651]  [<ffffffff8118428c>] do_writepages+0x1c/0x40
[  192.026651]  [<ffffffff8117a281>] __filemap_fdatawrite_range+0x51/0x60
[  192.026651]  [<ffffffff8117a365>] filemap_write_and_wait_range+0x35/0x80
[  192.026651]  [<ffffffff813843df>] nfs4_file_fsync+0x5f/0xb0
[  192.026651]  [<ffffffff81384670>] ? nfs4_file_llseek+0x60/0x60
[  192.026651]  [<ffffffff811f7074>] vfs_fsync+0x24/0x40
[  192.026651]  [<ffffffff8134bd02>] nfs_file_flush+0x82/0xc0
[  192.026651]  [<ffffffff811c3f35>] filp_close+0x35/0x80
[  192.026651]  [<ffffffff811e462a>] __close_fd+0x8a/0xb0
[  192.026651]  [<ffffffff811c3ece>] SyS_close+0x1e/0x50
[  192.026651]  [<ffffffff81dfcd69>] system_call_fastpath+0x12/0x17
[  192.026651] Code: 07 48 83 c7 08 49 89 3b 5d c3 0f 1f 44 00 00 49 89 c2 49 83 e2 fe 41 8b 3a 81 e7 ff 0f 00 00 89 f8 48 3b 34 c5 80 b3 58 82 77 4c <8d> 04 7f 8d 4c 00 fa eb 06 0f 1f 00 49 89 c2 49 89 f0 49 d3 e8 

and never recovers from it, printing that backtrace again and again.

