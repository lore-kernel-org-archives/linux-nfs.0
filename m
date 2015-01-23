Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56166 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbbAWI1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 03:27:05 -0500
Date: Fri, 23 Jan 2015 00:27:05 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 00/51] Add Flexfile Layout Module
Message-ID: <20150123082705.GA17608@infradead.org>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
 <20150123080732.GA8687@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150123080732.GA8687@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 23, 2015 at 12:07:32AM -0800, Christoph Hellwig wrote:
> This series breaks xfstests with the first test when used together
> with a local pnfs block export.

And here is the backtrace before it hangs, sorry:

generic/001 14s ...[  116.095264] pNFS: using block device vdb
[  116.478161] ------------[ cut here ]------------
[  116.478773] WARNING: CPU: 3 PID: 4483 at fs/nfs/pnfs.c:1738 pnfs_generic_pg_init_write+0x8f/0xa0()
[  116.479622] Modules linked in:
[  116.480029] CPU: 3 PID: 4483 Comm: fill Not tainted 3.19.0-rc5+ #1549
[  116.480886] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  116.481764]  ffffffff822ec4aa ffff88007a9c3918 ffffffff81df2678 ffff88007c3e5150
[  116.483234]  0000000000000000 ffff88007a9c3958 ffffffff810ba9f2 0000000000000000
[  116.484435]  ffff88007a9c3c48 ffff88007a4d3e40 ffff88007b5e3870 0000000000000040
[  116.485337] Call Trace:
[  116.485617]  [<ffffffff81df2678>] dump_stack+0x45/0x57
[  116.486118]  [<ffffffff810ba9f2>] warn_slowpath_common+0x92/0xd0
[  116.486820]  [<ffffffff810baa45>] warn_slowpath_null+0x15/0x20
[  116.487490]  [<ffffffff81393cdf>] pnfs_generic_pg_init_write+0x8f/0xa0
[  116.488223]  [<ffffffff8139c8a2>] bl_pg_init_write+0x92/0x140
[  116.488871]  [<ffffffff813559e0>] __nfs_pageio_add_request+0xf0/0x470
[  116.489586]  [<ffffffff81356293>] nfs_pageio_add_request+0x93/0x1c0
[  116.490319]  [<ffffffff811788ff>] ? find_get_pages_tag+0x1f/0x190
[  116.491001]  [<ffffffff81359ed0>] nfs_do_writepage+0x120/0x1e0
[  116.491660]  [<ffffffff8135a048>] nfs_writepages_callback+0x18/0x30
[  116.492362]  [<ffffffff81182616>] write_cache_pages+0x1e6/0x490
[  116.493029]  [<ffffffff8135a030>] ? nfs_writepage_locked+0xa0/0xa0
[  116.493746]  [<ffffffff8135a124>] nfs_writepages+0x94/0x130
[  116.494379]  [<ffffffff8118428c>] do_writepages+0x1c/0x40
[  116.495003]  [<ffffffff8117a281>] __filemap_fdatawrite_range+0x51/0x60
[  116.495726]  [<ffffffff8117a365>] filemap_write_and_wait_range+0x35/0x80
[  116.496468]  [<ffffffff813843df>] nfs4_file_fsync+0x5f/0xb0
[  116.497323]  [<ffffffff81384670>] ? nfs4_file_llseek+0x60/0x60
[  116.498375]  [<ffffffff811f7074>] vfs_fsync+0x24/0x40
[  116.499329]  [<ffffffff8134bd02>] nfs_file_flush+0x82/0xc0
[  116.500418]  [<ffffffff811c3f35>] filp_close+0x35/0x80
[  116.501204]  [<ffffffff811e4294>] put_files_struct+0x94/0xe0
[  116.502007]  [<ffffffff811e439d>] exit_files+0x4d/0x60
[  116.502804]  [<ffffffff810bce16>] do_exit+0x2b6/0xa60
[  116.503491]  [<ffffffff811c8ae8>] ? __sb_end_write+0x78/0x80
[  116.504154]  [<ffffffff81dfda1c>] ? retint_swapgs+0x13/0x1b
[  116.504799]  [<ffffffff810bd697>] do_group_exit+0x47/0xc0
[  116.505425]  [<ffffffff810bd722>] SyS_exit_group+0x12/0x20
[  116.506058]  [<ffffffff81dfcda9>] system_call_fastpath+0x12/0x17
[  116.506782] ---[ end trace f766241646eab9dc ]---

