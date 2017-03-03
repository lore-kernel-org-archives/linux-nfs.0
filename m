Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:32791 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751137AbdCCLCu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 06:02:50 -0500
Date: Fri, 3 Mar 2017 11:38:51 +0100
From: Sascha Hauer <s.hauer@pengutronix.de>
To: linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
        linux-security-module@vger.kernel.org,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
        James Morris <james.l.morris@oracle.com>, kernel@pengutronix.de
Subject: IMA on NFS deadlocks since a5864c999de670
Message-ID: <20170303103838.tnprd3pww4jmippp@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I discovered a deadlock when IMA is used in conjunction with NFS. I
booted with "ima_tcb". The deadlock happens when IMA measures the first
file on a NFS. It seems the IMA measurement triggers further NFS reads
and the NFS code then tries to acquire a lock it's already holding.
Reading/writing files works fine, the deadlock occurs once something
is executed. I bisected this down to:

commit a5864c999de6703f7ce908f72337568520c6cad3
Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Fri Jun 3 17:07:19 2016 -0400

    NFS: Do not serialise O_DIRECT reads and writes
    
    Allow dio requests to be scheduled in parallel, but ensuring that they
    do not conflict with buffered I/O.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Right now I have no idea if this commit is breaking things or if IMA
is the guilty one and this commit only triggers it.

Any idea what's wrong?

Sascha

Here's the deadlock (It's not just a warning, the system really locks up):

[   15.848882] =============================================
[   15.854287] [ INFO: possible recursive locking detected ]
[   15.859696] 4.10.0 #244 Tainted: G        W
[   15.864406] ---------------------------------------------
[   15.869811] sh/206 is trying to acquire lock:
[   15.874175]  (&sb->s_type->i_mutex_key#13){+++++.}, at: [<c031eea4>] nfs_start_io_read+0x1c/0x68
[   15.883001]
[   15.883001] but task is already holding lock:
[   15.888838]  (&sb->s_type->i_mutex_key#13){+++++.}, at: [<c03e0c64>] process_measurement+0x1a0/0x43c
[   15.898006]
[   15.898006] other info that might help us debug this:
[   15.904539]  Possible unsafe locking scenario:
[   15.904539]
[   15.910463]        CPU0
[   15.912913]        ----
[   15.915362]   lock(&sb->s_type->i_mutex_key#13);
[   15.919993]   lock(&sb->s_type->i_mutex_key#13);
[   15.924624]
[   15.924624]  *** DEADLOCK ***
[   15.924624]
[   15.930550]  May be due to missing lock nesting notation
[   15.930550]
[   15.937345] 1 lock held by sh/206:
[   15.940750]  #0:  (&sb->s_type->i_mutex_key#13){+++++.}, at: [<c03e0c64>] process_measurement+0x1a0/0x43c
[   15.950342]
[   15.950342] stack backtrace:
[   15.954710] CPU: 0 PID: 206 Comm: sh Tainted: G        W       4.10.0 #244
[   15.961590] Hardware name: Freescale i.MX53 (Device Tree Support)
[   15.967687] Backtrace:
[   15.970162] [<c010c5c0>] (dump_backtrace) from [<c010c868>] (show_stack+0x18/0x1c)
[   15.977742]  r6:60000093 r5:00000000 r4:c0e2b658 r3:00000000
[   15.983412] [<c010c850>] (show_stack) from [<c042c9ec>] (dump_stack+0xb4/0xe8)
[   15.990648] [<c042c938>] (dump_stack) from [<c0175410>] (__lock_acquire+0x1694/0x1a04)
[   15.998575]  r10:c1605ca0 r9:c165b5f0 r8:de5658a0 r7:c0e2b748 r6:c0fe31c4 r5:de565400
[   16.006409]  r4:c0fe31c4 r3:00000002
[   16.009994] [<c0173d7c>] (__lock_acquire) from [<c0175b40>] (lock_acquire+0x78/0x98)
[   16.017749]  r10:de1683c0 r9:00000000 r8:00001000 r7:00000001 r6:c031eea4 r5:60000013
[   16.025583]  r4:00000000
[   16.028138] [<c0175ac8>] (lock_acquire) from [<c09c1f14>] (down_read+0x58/0xa0)
[   16.035456]  r7:de3b7abc r6:c031eea4 r5:00000000 r4:dea245e0
[   16.041125] [<c09c1ebc>] (down_read) from [<c031eea4>] (nfs_start_io_read+0x1c/0x68)
[   16.048876]  r6:dea24540 r5:dea245e0 r4:dea24540
[   16.053508] [<c031ee88>] (nfs_start_io_read) from [<c0316c50>] (nfs_file_read+0x30/0xbc)
[   16.061604]  r5:de3b7b18 r4:de3b7ad0
[   16.065192] [<c0316c20>] (nfs_file_read) from [<c0225764>] (__vfs_read+0xc8/0x118)
[   16.072770]  r7:00000000 r6:00000000 r5:de3b7b18 r4:de1683c0
[   16.078439] [<c022569c>] (__vfs_read) from [<c03df894>] (integrity_kernel_read+0x44/0x64)
[   16.086624]  r8:00000000 r7:de1c3000 r6:de595100 r5:de3b7b80 r4:bf000000
[   16.093335] [<c03df850>] (integrity_kernel_read) from [<c03e1a68>] (ima_calc_file_hash+0x45c/0x8a8)
[   16.102386]  r4:00000000
[   16.104928] [<c03e160c>] (ima_calc_file_hash) from [<c03e2574>] (ima_collect_measurement+0xc4/0xe0)
[   16.113982]  r10:00000000 r9:00000000 r8:de3b7cf4 r7:00000000 r6:00000009 r5:de1683c0
[   16.121816]  r4:de38d210
[   16.124359] [<c03e24b0>] (ima_collect_measurement) from [<c03e0d78>] (process_measurement+0x2b4/0x43c)
[   16.133674]  r9:00000000 r8:00000000 r7:dea245e0 r6:00000000 r5:de1683c0 r4:00000001
[   16.141427] [<c03e0ac4>] (process_measurement) from [<c03e0f34>] (ima_file_check+0x34/0x3c)
[   16.149787]  r10:debc3f18 r9:de3b7ea8 r8:00000000 r7:00020000 r6:00000000 r5:de3b7f5c
[   16.157621]  r4:de1683c0
[   16.160169] [<c03e0f00>] (ima_file_check) from [<c023659c>] (path_openat+0x334/0x1028)
[   16.168095] [<c0236268>] (path_openat) from [<c02380e8>] (do_filp_open+0x68/0xcc)
[   16.175587]  r10:00000000 r9:de3b6000 r8:c0108144 r7:00000001 r6:de3b7ea8 r5:de3b7f5c
[   16.183420]  r4:00000003
[   16.185963] [<c0238080>] (do_filp_open) from [<c0224fa0>] (do_sys_open+0x108/0x1cc)
[   16.193626]  r7:00000005 r6:de1c4000 r5:ffffff9c r4:00000003
[   16.199294] [<c0224e98>] (do_sys_open) from [<c0225088>] (SyS_open+0x24/0x28)
[   16.206439]  r9:de3b6000 r8:c0108144 r7:00000005 r6:00c58210 r5:00000003 r4:00000000
[   16.214192] [<c0225064>] (SyS_open) from [<c0107fa0>] (ret_fast_syscall+0x0/0x1c)
[  159.767566] random: crng init done


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
