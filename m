From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.24.3 kernel BUG at fs/nfs/pagelist.c:82
Date: Sat, 12 Apr 2008 12:10:17 +0200
Message-ID: <20080412101017.GB29211@janus>
References: <20080319094942.GA7627@janus> <1206017233.8465.7.camel@heimdal.trondhjem.org> <20080320125716.GA20071@janus> <20080410115433.GA29211@janus> <1207944436.14621.6.camel@heimdal.trondhjem.org> <47FFC5C2.1070009@redhat.com> <1207946679.15646.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:53483 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756291AbYDLKKT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Apr 2008 06:10:19 -0400
In-Reply-To: <1207946679.15646.29.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


It happened again. tail -f died with the usual stack trace:
> [<c010562a>] show_trace_log_lvl+0x1a/0x30
> [<c01056fa>] show_stack_log_lvl+0x9a/0xc0
> [<c01058a8>] show_registers+0xc8/0x1d0
> [<c0105b1c>] die+0x10c/0x230
> [<c0105cd1>] do_trap+0x91/0xd0
> [<c0105f79>] do_invalid_op+0x89/0xa0
> [<c05bba62>] error_code+0x72/0x80
> [<c01fdf55>] nfs_readpage_async+0xb5/0x1b0
> [<c01fe94e>] nfs_readpage+0xae/0x120
> [<c01552b8>] do_generic_mapping_read+0xe8/0x440
> [<c0155900>] generic_file_aio_read+0x160/0x190
> [<c01f5037>] nfs_file_read+0x97/0xe0
> [<c0179647>] do_sync_read+0xc7/0x120
> [<c0179724>] vfs_read+0x84/0x130
> [<c0179a5d>] sys_read+0x3d/0x70
> [<c0104292>] syscall_call+0x7/0xb

And this is the trace of the writer, now stuck in state D (using echo
t >/proc/sysrq-trigger):
> [<c05b9d4e>] io_schedule+0x1e/0x30
> [<c0154465>] sync_page+0x35/0x60
> [<c05b9fc9>] __wait_on_bit_lock+0x49/0x70
> [<c0154cd5>] __lock_page+0x85/0xa0
> [<c0154e62>] find_lock_page+0x62/0xa0
> [<c0156a5c>] __grab_cache_page+0x1c/0xb0
> [<c01f5258>] nfs_write_begin+0x18/0x60
> [<c0156ebe>] generic_perform_write+0x9e/0x180
> [<c0157007>] generic_file_buffered_write+0x67/0x110
> [<c01572f7>] __generic_file_aio_write_nolock+0x247/0x560
> [<c015774c>] generic_file_aio_write+0x5c/0xd0
> [<c01f55d7>] nfs_file_write+0xa7/0x150
> [<c0179897>] do_sync_write+0xc7/0x120
> [<c0179977>] vfs_write+0x87/0x130
> [<c0179acd>] sys_write+0x3d/0x70
> [<c0104292>] syscall_call+0x7/0xb

The file is not mmap()'ed, at least not by reader or writer in userland.

-- 
Frank
