Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.81]:49512 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab1I0AcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 20:32:17 -0400
Date: Mon, 26 Sep 2011 20:32:11 -0400
From: Jim Rees <jim.rees@rees.org>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Subject: pnfs crash
Message-ID: <20110927003211.GA13245@umich.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The pnfs block layout client doesn't work on the latest kernel from benny's
git.  The problem is this commit, which is still being hotly debated:

commit 0ec26fd0698285b31248e34bf1abb022c00f23d6
Author: Miklos Szeredi <mszeredi@suse.cz>
Date:   Mon Sep 5 18:06:26 2011 +0200

    vfs: automount should ignore LOOKUP_FOLLOW

Here's the traceback:

WARNING: at /home/rees/linux-pnfs/lib/list_debug.c:30 __list_add+0x66/0x7f()
Hardware name: ProLiant DL145 G2
list_add corruption. prev->next should be next (ffff88007a5baba8), but was ffff8800377fde80. (prev=ffff88007996d870).
Modules linked in: blocklayoutdriver nfs lockd fscache auth_rpcgss nfs_acl sunrpc cpufreq_ondemand powernow_k8 freq_table mperf be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb3i libcxgbi cxgb3 mdio ip6t_REJECT ib_iser rdma_cm nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ib_cm iw_cm ip6_tables ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi amd64_edac_mod edac_core tg3 pcspkr serio_raw shpchp i2c_nforce2 edac_mce_amd i2c_core k8temp ipv6 autofs4 ata_generic pata_acpi mptspi mptscsih mptbase scsi_transport_spi pata_amd sata_nv [last unloaded: scsi_wait_scan]
Pid: 1453, comm: iozone Not tainted 3.1.0-rc6-pnfs #10
Call Trace:
 [<ffffffff8103bd8a>] warn_slowpath_common+0x7e/0x96
 [<ffffffff8103be36>] warn_slowpath_fmt+0x41/0x43
 [<ffffffff8120b9b7>] __list_add+0x66/0x7f
 [<ffffffffa020abdf>] rpc_queue_upcall+0x8f/0xc6 [sunrpc]
 [<ffffffffa02f1a9b>] dev_remove+0x103/0x156 [blocklayoutdriver]
 [<ffffffff8103449c>] ? try_to_wake_up+0x1d0/0x1d0
 [<ffffffffa02f1b81>] bl_free_block_dev+0x93/0xa5 [blocklayoutdriver]
 [<ffffffffa02ee7a9>] free_blk_mountid+0x2e/0x50 [blocklayoutdriver]
 [<ffffffffa02eeeaf>] bl_clear_layoutdriver+0x33/0x57 [blocklayoutdriver]
 [<ffffffffa02af016>] unset_pnfs_layoutdriver+0x21/0x41 [nfs]
 [<ffffffffa02806e2>] nfs_free_server+0x8d/0x10a [nfs]
 [<ffffffffa02899d8>] nfs4_xdev_mount+0xcd/0x221 [nfs]
 [<ffffffff810f93d0>] mount_fs+0x64/0x150
 [<ffffffff810cb551>] ? __alloc_percpu+0xb/0xd
 [<ffffffff8110cf96>] vfs_kern_mount+0x5e/0x9b
 [<ffffffffa0293481>] nfs_d_automount+0x352/0x436 [nfs]
 [<ffffffff810ff19e>] follow_managed+0x144/0x215
 [<ffffffff810ffd2e>] walk_component+0x2c5/0x3e3
 [<ffffffff81100487>] link_path_walk+0x184/0x423
 [<ffffffff810ff504>] ? rcu_read_lock+0x2e/0x30
 [<ffffffff811023ed>] path_openat+0xad/0x30b
 [<ffffffff8110bf2d>] ? alloc_fd+0x36/0x116
 [<ffffffff81102699>] do_filp_open+0x33/0x81
 [<ffffffff8143e748>] ? _raw_spin_unlock+0x23/0x27
 [<ffffffff8110bffb>] ? alloc_fd+0x104/0x116
 [<ffffffff810f5bb5>] do_sys_open+0x69/0xfb
 [<ffffffff810873ac>] ? audit_syscall_entry+0x117/0x143
 [<ffffffff810f5c62>] sys_open+0x1b/0x1d
 [<ffffffff8144483b>] system_call_fastpath+0x16/0x1b
---[ end trace 7e065bc4dff611d4 ]---
