Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35621 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbEGHmQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 03:42:16 -0400
Date: Thu, 7 May 2015 00:42:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: blocklayout regression in "pnfs: lookup new lseg at lseg
 boundary"
Message-ID: <20150507074215.GA14450@infradead.org>
References: <20150425165640.GA2008@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150425165640.GA2008@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ping?

On Sat, Apr 25, 2015 at 09:56:40AM -0700, Christoph Hellwig wrote:
> Hi Andros,
> 
> your commit "pnfs: lookup new lseg at lseg boundary: triggers a warning
> with the block layout driver under xfstests.  I have hard time
> parsing he commit log, but it changes this WARN_ON from a > to a >=
> without mentioning anything related to this one-off which make
> me suspicious.
> 
> generic/013 files ...[  170.557305] ------------[ cut here ]------------
> [  170.557889] WARNING: CPU: 0 PID: 9755 at ../fs/nfs/pnfs.c:1792 pnfs_generic_pg_test+0xba/0xd0()
> [  170.558728] Modules linked in:
> [  170.559104] CPU: 0 PID: 9755 Comm: fsstress Not tainted 4.0.0+ #356
> [  170.559770] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [  170.560368]  ffffffff822a6079 ffff8800770af9c8 ffffffff81e03a7f 0000000000000000
> [  170.561282]  0000000000000000 ffff8800770afa08 ffffffff810c4dc2 0000000000000000
> [  170.562303]  ffff88007a730140 ffff8800770afcb8 ffff88007a730140 ffff88007a730140
> [  170.563218] Call Trace:
> [  170.563636]  [<ffffffff81e03a7f>] dump_stack+0x45/0x57
> [  170.564254]  [<ffffffff810c4dc2>] warn_slowpath_common+0x92/0xd0
> [  170.565283]  [<ffffffff810c4e15>] warn_slowpath_null+0x15/0x20
> [  170.566273]  [<ffffffff813b608a>] pnfs_generic_pg_test+0xba/0xd0
> [  170.567325]  [<ffffffff813be7c5>] bl_pg_test_write+0x45/0x50
> [  170.568533]  [<ffffffff8137b7ae>] __nfs_pageio_add_request+0x10e/0x470
> [  170.569616]  [<ffffffff8137c043>] nfs_pageio_add_request+0x93/0x1c0
> [  170.570679]  [<ffffffff8137faef>] nfs_do_writepage+0x11f/0x1e0
> [  170.571649]  [<ffffffff8137fc68>] nfs_writepages_callback+0x18/0x30
> [  170.572668]  [<ffffffff8119d50c>] write_cache_pages+0x22c/0x4a0
> [  170.573704]  [<ffffffff8111132d>] ? trace_hardirqs_on_caller+0x10d/0x1d0
> [  170.574861]  [<ffffffff811113fd>] ? trace_hardirqs_on+0xd/0x10
> [  170.575833]  [<ffffffff811da881>] ? kmem_cache_free+0xe1/0x210
> [  170.576867]  [<ffffffff8137fc50>] ? nfs_writepage_locked+0xa0/0xa0
> [  170.577876]  [<ffffffff8137fd44>] nfs_writepages+0x94/0x130
> [  170.578805]  [<ffffffff8119f34c>] do_writepages+0x1c/0x40
> [  170.579712]  [<ffffffff811948f1>] __filemap_fdatawrite_range+0x51/0x60
> [  170.580774]  [<ffffffff811949d5>] filemap_write_and_wait_range+0x35/0x80
> [  170.581817]  [<ffffffff813a73ef>] nfs4_file_fsync+0x5f/0xb0
> [  170.582710]  [<ffffffff81213bd1>] vfs_fsync_range+0x41/0xc0
> [  170.583630]  [<ffffffff813a75f0>] ? nfs4_file_open+0x1b0/0x1b0
> [  170.584584]  [<ffffffff81213c67>] vfs_fsync+0x17/0x20
> [  170.585461]  [<ffffffff813724ce>] nfs_file_flush+0x6e/0x90
> [  170.586428]  [<ffffffff811dd185>] filp_close+0x35/0x80
> [  170.587075]  [<ffffffff811ff7ce>] __close_fd+0x9e/0x110
> [  170.587694]  [<ffffffff811dd11e>] SyS_close+0x1e/0x50
> [  170.588291]  [<ffffffff81e0e2ee>] system_call_fastpath+0x12/0x76
> [  170.588971] ---[ end trace c6bc30a03cc4fc6e ]---
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---
