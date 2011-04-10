Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from orca.ele.uri.edu ([131.128.51.63]:49461 "EHLO orca.ele.uri.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab1DJDDA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Apr 2011 23:03:00 -0400
From: "Will Simoneau" <simoneau@ele.uri.edu>
Date: Sat, 9 Apr 2011 23:02:58 -0400
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: lockdep splat: 2.6.39-rc2 + nfsroot
Message-ID: <20110410030258.GB15112@ele.uri.edu>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yNb1oOkm5a9FJOVX"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--yNb1oOkm5a9FJOVX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[should have CCed linux-nfs, sorry for the dupe]

Hi,

I just got this soft-lockup 3 times in a row and was able to reproduce
it with lockdep enabled. The kernel is Linus git 94c8a984 plus patches
to support my hardware. System is a full custom 2-way SMP mipsel/R4K
clone on an FPGA, I am hoping this is not my fault or the hardware's
fault though. Root is on NFS (tcp).

This seems to happen consistently when running "apt-get update". Ideas?
Known bug?

---8<---

[  926.390000] =============================================
[  926.390000] [ INFO: possible recursive locking detected ]
[  926.390000] 2.6.39-rc2+ #7
[  926.390000] ---------------------------------------------
[  926.390000] rred/1443 is trying to acquire lock:
[  926.390000]  (&sb->s_type->i_lock_key#11){+.+.-.}, at: [<800dc6c0>] __mark_in
ode_dirty+0x70/0x250
[  926.390000]
[  926.390000] but task is already holding lock:
[  926.390000]  (&sb->s_type->i_lock_key#11){+.+.-.}, at: [<8017b128>] nfs_commi
t_inode+0xe8/0x270
[  926.390000]
[  926.390000] other info that might help us debug this:
[  926.390000] 3 locks held by rred/1443:
[  926.390000]  #0:  (&sb->s_type->i_mutex_key#3){+.+.+.}, at: [<8007a3f0>] gene
ric_file_aio_write+0x6c/0x120
[  926.390000]  #1:  (&type->s_umount_key#14){++++..}, at: [<800dcb94>] writebac
k_inodes_wb+0xb8/0x178
[  926.390000]  #2:  (&sb->s_type->i_lock_key#11){+.+.-.}, at: [<8017b128>] nfs_
commit_inode+0xe8/0x270
[  926.390000]
[  926.390000] stack backtrace:
[  926.390000] Call Trace:
[  926.390000] [<8032666c>] dump_stack+0x8/0x34
[  926.390000] [<80065eb8>] __lock_acquire+0x1454/0x1d44
[  926.390000] [<8006681c>] lock_acquire+0x74/0xb0
[  926.390000] [<8032a898>] _raw_spin_lock+0x40/0x54
[  926.390000] [<800dc6c0>] __mark_inode_dirty+0x70/0x250
[  926.390000] [<8017b268>] nfs_commit_inode+0x228/0x270
[  926.390000] [<8017bc50>] nfs_write_inode+0x74/0xcc
[  926.390000] [<800db9b0>] writeback_single_inode+0x298/0x2a0
[  926.390000] [<800dbf40>] writeback_sb_inodes+0x11c/0x1f0
[  926.390000] [<800dcbbc>] writeback_inodes_wb+0xe0/0x178
[  926.390000] [<80083a3c>] balance_dirty_pages_ratelimited_nr+0x4f8/0x644
[  926.390000] [<80077b7c>] generic_file_buffered_write+0x16c/0x2f0
[  926.390000] [<8007a018>] __generic_file_aio_write+0x28c/0x5f8
[  926.390000] [<8007a40c>] generic_file_aio_write+0x88/0x120
[  926.390000] [<8016b1a4>] nfs_file_write+0x104/0x29c
[  926.390000] [<800b1c30>] do_sync_readv_writev+0xbc/0x13c
[  926.390000] [<800b2520>] do_readv_writev+0xbc/0x1c8
[  926.390000] [<800b268c>] vfs_writev+0x60/0x78
[  926.390000] [<800b27ac>] sys_writev+0x50/0xa0
[  926.390000] [<8000afd8>] stack_done+0x20/0x40
[  926.390000]
[  989.240000] BUG: soft lockup - CPU#0 stuck for 61s! [rred:1443]
[  989.240000] irq event stamp: 995027
[  989.240000] hardirqs last  enabled at (995027): [<8032b538>] _raw_spin_unlock
_irqrestore+0x9c/0xd8
[  989.240000] hardirqs last disabled at (995026): [<8032aa08>] _raw_spin_lock_i
rqsave+0x40/0x90
[  989.240000] softirqs last  enabled at (995006): [<80033d1c>] do_softirq+0xfc/
0x104
[  989.240000] softirqs last disabled at (994993): [<80033d1c>] do_softirq+0xfc/
0x104
[  989.240000] Cpu 0
[  989.240000] $ 0   : 00000000 10008c00 85e285e1 000085e2
[  989.240000] $ 4   : 00000000 015bf440 8002c7a8 00000000
[  989.240000] $ 8   : 00000000 00000001 ffffffff 00000000
[  989.240000] $12   : a3f77b00 83d7c140 00000000 00000003
[  989.240000] $16   : 8383cb94 00010000 00000000 02703800
[  989.240000] $20   : 803aaf6c 00000001 015bf440 00000000
[  989.240000] $24   : 00000000 00000000
[  989.240000] $28   : 827f2000 827f39e8 8383cb34 801ba4b4
[  989.240000] Hi    : 00000000
[  989.240000] Lo    : 00002f00
[  989.240000] epc   : 801ba48c do_raw_spin_lock+0x12c/0x1cc
[  989.240000]     Not tainted
[  989.240000] ra    : 801ba4b4 do_raw_spin_lock+0x154/0x1cc
[  989.240000] Status: 10008c03    KERNEL EXL IE
[  989.240000] Cause : 00008000
[  989.240000] PrId  : 00004800 (Z4800)
[  992.830000] BUG: soft lockup - CPU#1 stuck for 63s! [kworker/1:1:213]
[  992.900000] irq event stamp: 499011
[  992.970000] hardirqs last  enabled at (499011): [<801791d8>] nfs_mark_request
_commit+0x14c/0x200
[  993.050000] hardirqs last disabled at (499010): [<8017913c>] nfs_mark_request
_commit+0xb0/0x200
[  993.120000] softirqs last  enabled at (498916): [<80033d1c>] do_softirq+0xfc/
0x104
[  993.200000] softirqs last disabled at (498911): [<80033d1c>] do_softirq+0xfc/
0x104
[  993.270000] Cpu 1
[  993.340000] $ 0   : 00000000 10008800 85e285e1 000085e2
[  993.410000] $ 4   : 00000000 021056b6 807e8c2c 00000000
[  993.480000] $ 8   : 807e8c2c 0000012e 00000000 fff80003
[  993.560000] $12   : 00000001 00000008 4e0811a1 13aebc2e
[  993.630000] $16   : 8383cb94 00010000 00000000 02703800
[  993.700000] $20   : 803aaf6c 00000001 021056b6 00000000
[  993.780000] $24   : 00000000 80002be0
[  993.850000] $28   : 83cb0000 83cb1d68 803a7458 801ba4b4
[  993.920000] Hi    : 0f388e26
[  993.990000] Lo    : fed1e12d
[  994.050000] epc   : 801ba48c do_raw_spin_lock+0x12c/0x1cc
[  994.130000]     Not tainted
[  994.190000] ra    : 801ba4b4 do_raw_spin_lock+0x154/0x1cc
[  994.270000] Status: 10008803    KERNEL EXL IE
[  994.340000] Cause : 00008000
[  994.400000] PrId  : 00004800 (Z4800)

---8<---

Thanks for looking.

--yNb1oOkm5a9FJOVX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAk2hHeIACgkQLYBaX8VDLLUwgwCgmRYEfyf1sbk7f0hFr41gvni/
KiIAnRMothPTXoJ94bcbXYx8VUr2wcx9
=aHqL
-----END PGP SIGNATURE-----

--yNb1oOkm5a9FJOVX--
