Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:52916 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbbATOGS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jan 2015 09:06:18 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id A76E828037C
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 15:00:47 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 9A71210D9
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 15:00:47 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP4.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb81444f9f083a9616264c@ZITSWEEP4.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Tue, 20 Jan 2015 15:00:47 +0100
Received: from z-mta-1.desy.de (z-mta-1.desy.de [131.169.55.135])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id DA31E3E906
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 15:00:46 +0100 (MET)
Received: from z-mta-1.desy.de (localhost [127.0.0.1])
	by z-mta-1.desy.de (Postfix) with ESMTPS id CB9F21C01CA
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 15:00:46 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by z-mta-1.desy.de (Postfix) with ESMTP id A58161C01C4
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 15:00:46 +0100 (CET)
Received: from z-mta-1.desy.de ([127.0.0.1])
	by localhost (z-mta-1.desy.de [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id qfknv6fWMSez for <linux-nfs@vger.kernel.org>;
	Tue, 20 Jan 2015 15:00:46 +0100 (CET)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
	by z-mta-1.desy.de (Postfix) with ESMTP id 8E10A1C00A8
	for <linux-nfs@vger.kernel.org>; Tue, 20 Jan 2015 15:00:46 +0100 (CET)
Date: Tue, 20 Jan 2015 15:00:46 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Message-ID: <1063664421.96812.1421762446484.JavaMail.zimbra@desy.de>
Subject: kernel crashes on commit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Dear fellows,

since we have enabled commit through DS code we
permanently observe kernel crashes with RHEL6/7 and ubuntu 14.04:


<1>BUG: unable to handle kernel paging request at 00000000dc364913
<1>IP: [<ffffffffa02b45df>] nfs_init_commit+0x1f/0xf0 [nfs]
<4>PGD 6393ae067 PUD 0 
<4>Oops: 0000 [#1] SMP 
<4>last sysfs file: /sys/devices/system/cpu/online
<4>CPU 1 
<4>Modules linked in: vfat fat usb_storage mpt3sas mpt2sas raid_class mptctl ipmi_devintf dell_rbu openafs(P)(U) autof
s4 nfs_layout_nfsv41_files nfs lockd fscache auth_rpcgss nfs_acl sunrpc bonding 8021q garp stp llc ipv6 power_meter ac
pi_ipmi ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support microcode dcdbas sg bnx2 lpc_ich mfd_core i7core_edac eda
c_core ext4 jbd2 mbcache sd_mod crc_t10dif wmi pata_acpi ata_generic ata_piix mptsas mptscsih mptbase scsi_transport_s
as dm_mirror dm_region_hash dm_log dm_mod [last unloaded: scsi_wait_scan]
<4>
<4>Pid: 18209, comm: flush-0:19 Tainted: P           ---------------    2.6.32-504.3.3.el6.x86_64 #1 Dell Inc. PowerEdge M610/0N582M
<4>RIP: 0010:[<ffffffffa02b45df>]  [<ffffffffa02b45df>] nfs_init_commit+0x1f/0xf0 [nfs]
<4>RSP: 0018:ffff88063988da30  EFLAGS: 00010246
<4>RAX: ffff88063988db60 RBX: ffff88009c492040 RCX: ffff88063988db30
<4>RDX: 0000000000000000 RSI: ffff88063988db60 RDI: 00000000dc364903
<4>RBP: ffff88063988da40 R08: ffff88063988da90 R09: f9aa37faa254d404
<4>R10: 0000000000000010 R11: 0000000000000000 R12: 0000000000000001
<4>R13: ffff880339f33a00 R14: ffff88063988db30 R15: ffff88063988d8c8
<4>FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
<4>CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
<4>CR2: 00000000dc364913 CR3: 0000000639fbb000 CR4: 00000000000007e0
<4>DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>Process flush-0:19 (pid: 18209, threadinfo ffff88063988c000, task ffff88063837c040)
<4>Stack:
<4> 0000000000000000 ffff88009c492040 ffff88063988dad0 ffffffffa031fdb7
<4><d> ffff88063837c5f8 ffff88063988da90 ffff8800a6e34600 ffff880337f2a950
<4><d> ffff880637c99488 0000000037f2a940 ffff88063988db60 0000000000000000
<4>Call Trace:
<4> [<ffffffffa031fdb7>] filelayout_commit_pagelist+0x277/0x3c0 [nfs_layout_nfsv41_files]
<4> [<ffffffffa02b613b>] nfs_generic_commit_list+0xab/0x100 [nfs]
<4> [<ffffffffa02b627c>] nfs_commit_inode+0xec/0x150 [nfs]
<4> [<ffffffffa02b6aab>] nfs_write_inode+0xab/0x100 [nfs]
<4> [<ffffffff811baedc>] writeback_single_inode+0x20c/0x290
<4> [<ffffffff811bb1ad>] writeback_sb_inodes+0xbd/0x170
<4> [<ffffffff811bb30b>] writeback_inodes_wb+0xab/0x1b0
<4> [<ffffffff811bb703>] wb_writeback+0x2f3/0x410
<4> [<ffffffff8100b9ce>] ? common_interrupt+0xe/0x13
<4> [<ffffffff81088062>] ? del_timer_sync+0x22/0x30
<4> [<ffffffff811bb9c5>] wb_do_writeback+0x1a5/0x240
<4> [<ffffffff811bbac3>] bdi_writeback_task+0x63/0x1b0
<4> [<ffffffff8109e987>] ? bit_waitqueue+0x17/0xd0
<4> [<ffffffff81148360>] ? bdi_start_fn+0x0/0x100
<4> [<ffffffff811483e6>] bdi_start_fn+0x86/0x100
<4> [<ffffffff81148360>] ? bdi_start_fn+0x0/0x100
<4> [<ffffffff8109e66e>] kthread+0x9e/0xc0
<4> [<ffffffff8100c20a>] child_rip+0xa/0x20
<4> [<ffffffff8109e5d0>] ? kthread+0x0/0xc0
<4> [<ffffffff8100c200>] ? child_rip+0x0/0x20
<4>Code: c3 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 0f 1f 44 00 00 48 8b 06 48 89 fb 48 8b 78 18 48 39 c6 48 8b 7f 40 <48> 8b 7f 10 74 2b 4c 8b 83 c8 01 00 00 4c 8b 4e 08 4c 8d 93 c8 
<1>RIP  [<ffffffffa02b45df>] nfs_init_commit+0x1f/0xf0 [nfs]
<4> RSP <ffff88063988da30>
<4>CR2: 00000000dc364913


I have vmcore file as well, so let me know if you need some more information.

Tigran.
