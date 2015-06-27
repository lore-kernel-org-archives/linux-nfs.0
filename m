Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39740 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbbF0EJk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jun 2015 00:09:40 -0400
Message-ID: <558E2201.1040003@roeck-us.net>
Date: Fri, 26 Jun 2015 21:09:37 -0700
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
To: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Build errors due to 64 bit xchg/cmpxchg operations in fs/nfs/flexfilelayout
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

commits 'pNFS/flexfiles: add layoutstats tracking' and 'pnfs/flexfiles: report layoutstat
regularly' in -next introduce 64 bit xchg and cmpxchg operations. This causes compile
errors with 32 bit builds on architectures which do not support those operations.

arm:shmobile_defconfig:

fs/built-in.o: In function `nfs4_ff_end_busy_timer':
:(.text+0xa7110): undefined reference to `__bad_xchg'
fs/built-in.o: In function `nfs4_ff_layoutstat_start_io':
:(.text+0xa7304): undefined reference to `__bad_cmpxchg'
:(.text+0xa731c): undefined reference to `__bad_cmpxchg'
:(.text+0xa73d8): undefined reference to `__bad_cmpxchg'

xtensa:allmodconfig:

ERROR: "__xchg_called_with_bad_pointer" [fs/nfs/flexfilelayout/nfs_layout_flexfiles.ko] undefined!
ERROR: "__cmpxchg_called_with_bad_pointer" [fs/nfs/flexfilelayout/nfs_layout_flexfiles.ko] undefined!

Guenter
