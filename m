Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:50192 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500AbcEBHgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 03:36:00 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id B5FF22804E3
	for <linux-nfs@vger.kernel.org>; Mon,  2 May 2016 09:29:52 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 898DE13F11
	for <linux-nfs@vger.kernel.org>; Mon,  2 May 2016 09:29:51 +0200 (MEST)
Date: Mon, 2 May 2016 09:29:51 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        Andy Adamson <william.adamson@netapp.com>
Message-ID: <148899538.11512158.1462174191227.JavaMail.zimbra@desy.de>
Subject: blocked on the spin lock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Dros et. al.

We have seen the following stack trace on one of out systems:


Apr 28 22:09:51 bird510 kernel: BUG: soft lockup - CPU#7 stuck for 67s! [tee:13755]
Apr 28 22:09:51 bird510 kernel: Modules linked in: ipmi_devintf dell_rbu nfs_layout_nfsv41_files fuse nfs lockd fscache auth_rpcgss nfs_acl vfat fat usb_storage mpt3sas mpt2sas raid_class mptctl openafs(P)(U) autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf sg joy
dev power_meter acpi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support bnx2 microcode dcdbas lpc_ich mfd_core i7core_edac edac_core shpchp ext4 jbd2 mbcache sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas mlx4_ib ib_sa ib_mad ib_core ib_addr ipv6 mlx4_en p
tp pps_core mlx4_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipmi_devintf]
Apr 28 22:09:51 bird510 kernel: CPU 7
Apr 28 22:09:51 bird510 kernel: Modules linked in: ipmi_devintf dell_rbu nfs_layout_nfsv41_files fuse nfs lockd fscache auth_rpcgss nfs_acl vfat fat usb_storage mpt3sas mpt2sas raid_class mptctl openafs(P)(U) autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf sg joy
dev power_meter acpi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support bnx2 microcode dcdbas lpc_ich mfd_core i7core_edac edac_core shpchp ext4 jbd2 mbcache sd_mod crc_t10dif mptsas mptscsih mptbase scsi_transport_sas mlx4_ib ib_sa ib_mad ib_core ib_addr ipv6 mlx4_en p
tp pps_core mlx4_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipmi_devintf]
Apr 28 22:09:51 bird510 kernel:
Apr 28 22:09:51 bird510 kernel: Pid: 13755, comm: tee Tainted: P           -- ------------    2.6.32-573.12.1.el6.x86_64 #1 Dell Inc. PowerEdge M610/0N582M
Apr 28 22:09:51 bird510 kernel: RIP: 0010:[<ffffffff8153bde1>]  [<ffffffff8153bde1>] _spin_lock+0x21/0x30
Apr 28 22:09:51 bird510 kernel: RSP: 0018:ffff8803528179c8  EFLAGS: 00000297
Apr 28 22:09:51 bird510 kernel: RAX: 00000000000003b1 RBX: ffff8803528179c8 RCX: 0000000000000000
Apr 28 22:09:51 bird510 kernel: RDX: 00000000000003b0 RSI: ffff880159aeb820 RDI: ffff880159aeb8d0
Apr 28 22:09:51 bird510 kernel: RBP: ffffffff8100bc0e R08: ffff880352817af0 R09: 0000000000000002
Apr 28 22:09:51 bird510 kernel: R10: ffffea0008efc428 R11: 0000000000000003 R12: 0000000000000001
Apr 28 22:09:51 bird510 kernel: R13: 001310facb5806bd R14: 0000000000000000 R15: 0000000000000000
Apr 28 22:09:51 bird510 kernel: FS:  00007f3e78118700(0000) GS:ffff880028260000(0000) knlGS:0000000000000000
Apr 28 22:09:51 bird510 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Apr 28 22:09:51 bird510 kernel: CR2: 00007fefa21ff000 CR3: 0000000352959000 CR4: 00000000000007e0
Apr 28 22:09:51 bird510 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr 28 22:09:51 bird510 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr 28 22:09:51 bird510 kernel: Process tee (pid: 13755, threadinfo ffff880352814000, task ffff880636064ab0)
Apr 28 22:09:51 bird510 kernel: Stack:
Apr 28 22:09:51 bird510 kernel: ffff880352817a18 ffffffffa0490dc1 ffff880159aeb8d0 ffff880159aeb770
Apr 28 22:09:51 bird510 kernel: <d> 0000000000000000 0000000000000000 ffffffffa04bd040 ffffffffa048f39a
Apr 28 22:09:51 bird510 kernel: <d> ffff8803378761c0 ffffea000a13dcc0 ffff880352817a48 ffffffffa0490ec8
Apr 28 22:09:51 bird510 kernel: Call Trace:
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490dc1>] ? nfs_clear_request_commit+0xa1/0xf0 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f39a>] ? nfs_page_find_request_locked+0x2a/0x40 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490ec8>] ? nfs_wb_page_cancel+0xb8/0xf0 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa047e4f7>] ? nfs_invalidate_page+0x47/0x80 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113edb5>] ? do_invalidatepage+0x25/0x30
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f0d2>] ? truncate_inode_page+0xa2/0xc0
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f47f>] ? truncate_inode_pages_range+0x16f/0x500
Apr 28 22:09:51 bird510 kernel: [<ffffffff81129cd7>] ? mempool_free_slab+0x17/0x20
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8a5>] ? truncate_inode_pages+0x15/0x20
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8ff>] ? truncate_pagecache+0x4f/0x70
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480eb9>] ? nfs_setattr_update_inode+0xb9/0x150 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0493a6b>] ? nfs3_proc_setattr+0xdb/0x120 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f6b3>] ? nfs_wb_all+0x43/0x50 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0482610>] ? nfs_setattr+0xf0/0x170 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1118>] ? notify_change+0x168/0x340
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480de8>] ? nfs_open+0x78/0x90 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffff8118fcb4>] ? do_truncate+0x64/0xa0
Apr 28 22:09:51 bird510 kernel: [<ffffffff81232b9f>] ? security_inode_permission+0x1f/0x30
Apr 28 22:09:51 bird510 kernel: [<ffffffff811a4fc1>] ? do_filp_open+0x861/0xd20
Apr 28 22:09:51 bird510 kernel: [<ffffffff8129df8a>] ? strncpy_from_user+0x4a/0x90
Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1ff2>] ? alloc_fd+0x92/0x160
Apr 28 22:09:51 bird510 kernel: [<ffffffff8118e967>] ? do_sys_open+0x67/0x130
Apr 28 22:09:51 bird510 kernel: [<ffffffff8118ea70>] ? sys_open+0x20/0x30
Apr 28 22:09:51 bird510 kernel: [<ffffffff8100b0d2>] ? system_call_fastpath+0x16/0x1b
Apr 28 22:09:51 bird510 kernel: Code: 01 74 05 e8 52 1c d6 ff c9 c3 55 48 89 e5 0f 1f 44 00 00 b8 00 00 01 00 f0 0f c1 07 0f b7 d0 c1 e8 10 39 c2 74 0e f3 90 0f b7 17 <eb> f5 83 3f 00 75 f4 eb df c9 c3 0f 1f 40 00 55 48 89 e5 0f 1f
Apr 28 22:09:51 bird510 kernel: Call Trace:
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490dc1>] ? nfs_clear_request_commit+0xa1/0xf0 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f39a>] ? nfs_page_find_request_locked+0x2a/0x40 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0490ec8>] ? nfs_wb_page_cancel+0xb8/0xf0 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa047e4f7>] ? nfs_invalidate_page+0x47/0x80 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113edb5>] ? do_invalidatepage+0x25/0x30
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f0d2>] ? truncate_inode_page+0xa2/0xc0
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f47f>] ? truncate_inode_pages_range+0x16f/0x500
Apr 28 22:09:51 bird510 kernel: [<ffffffff81129cd7>] ? mempool_free_slab+0x17/0x20
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8a5>] ? truncate_inode_pages+0x15/0x20
Apr 28 22:09:51 bird510 kernel: [<ffffffff8113f8ff>] ? truncate_pagecache+0x4f/0x70
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480eb9>] ? nfs_setattr_update_inode+0xb9/0x150 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0493a6b>] ? nfs3_proc_setattr+0xdb/0x120 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa048f6b3>] ? nfs_wb_all+0x43/0x50 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0482610>] ? nfs_setattr+0xf0/0x170 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1118>] ? notify_change+0x168/0x340
Apr 28 22:09:51 bird510 kernel: [<ffffffffa0480de8>] ? nfs_open+0x78/0x90 [nfs]
Apr 28 22:09:51 bird510 kernel: [<ffffffff8118fcb4>] ? do_truncate+0x64/0xa0
Apr 28 22:09:51 bird510 kernel: [<ffffffff81232b9f>] ? security_inode_permission+0x1f/0x30
Apr 28 22:09:51 bird510 kernel: [<ffffffff811a4fc1>] ? do_filp_open+0x861/0xd20
Apr 28 22:09:51 bird510 kernel: [<ffffffff8129df8a>] ? strncpy_from_user+0x4a/0x90
Apr 28 22:09:51 bird510 kernel: [<ffffffff811b1ff2>] ? alloc_fd+0x92/0x160
Apr 28 22:09:51 bird510 kernel: [<ffffffff8118e967>] ? do_sys_open+0x67/0x130
Apr 28 22:09:51 bird510 kernel: [<ffffffff8118ea70>] ? sys_open+0x20/0x30
Apr 28 22:09:51 bird510 kernel: [<ffffffff8100b0d2>] ? system_call_fastpath+0x16/0x1b




The questionable spin lock was remove by commit 411a99adf. Is there was a problem?
Do we need a packport in RHEL kernel?

Thanks a lot,
   Tigran.
