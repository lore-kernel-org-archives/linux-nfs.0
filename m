Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:56579 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754871Ab0KJSMV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 13:12:21 -0500
Subject: Memory leak via nfs_readdir_make_qstr
From: Catalin Marinas <catalin.marinas@arm.com>
To: Bryan Schumaker <bjschuma@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 18:12:17 +0000
Message-ID: <1289412737.4513.80.camel@e102109-lin.cambridge.arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I tested the 2.6.37-rc1 on an ARM platform with nfsroot filesystem.
Kmemleak reports quite a lot (> 150) of leaks like below. You seem to
have made changes recently to this area.

unreferenced object 0xef3aa600 (size 32):
  comm "modprobe", pid 480, jiffies 4294938128 (age 1250.660s)
  hex dump (first 32 bytes):
    2e 2e 3a ef 00 01 10 00 00 02 20 00 60 f3 93 ef  ..:....... .`...
    e0 be 82 ef e0 01 00 00 a1 85 48 39 1d 08 44 bb  ..........H9..D.
  backtrace:
    [<c00a3351>] create_object+0xbd/0x1bc
    [<c0272c11>] kmemleak_alloc+0x21/0x40
    [<c00a1d05>] __kmalloc_track_caller+0x81/0xc4
    [<c008a491>] kmemdup+0x11/0x20
    [<c01053db>] nfs_readdir_page_filler+0xef/0x360
    [<c0105843>] nfs_readdir_xdr_to_array+0x1f7/0x2e4
    [<c0105941>] nfs_readdir_filler+0x11/0x58
    [<c007c397>] do_read_cache_page+0x47/0xd8
    [<c007c459>] read_cache_page_async+0x15/0x18
    [<c007c463>] read_cache_page+0x7/0xc
    [<c0105a5d>] nfs_readdir+0xd5/0x398
    [<c00af433>] vfs_readdir+0x5f/0x74
    [<c00af50d>] sys_getdents+0x49/0x74
    [<c0036401>] ret_fast_syscall+0x1/0x44

Any quick thoughts? I'll have a look tomorrow as well.

Thanks,

Catalin

