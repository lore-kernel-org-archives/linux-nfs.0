Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:59249 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480Ab1G3OSn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 10:18:43 -0400
Date: Sat, 30 Jul 2011 10:18:41 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
Message-ID: <20110730141841.GA26194@merit.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
 <20110729155136.GB28306@infradead.org>
 <20110729185415.GA23061@merit.edu>
 <20110729190133.GA10946@infradead.org>
 <20110729191341.GC23061@merit.edu>
 <1311988172.16078.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311988172.16078.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  Is that reproducible on the upstream kernel, or is it something that is
  being introduced by the pNFS blocks code?

Upstream kernel 3.0.0-next-20110729 fails in a similar way, so it's not
anything introduced by the block layout code.

kernel BUG at /home/rees/linux-next/fs/nfs/callback_xdr.c:775!
invalid opcode: 0000 [#1] SMP 
CPU 0 
Modules linked in: nfs lockd fscache auth_rpcgss nfs_acl sunrpc cpufreq_ondemand powernow_k8 freq_table mperf be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb3i ip6t_REJECT libcxgbi cxgb3 nf_conntrack_ipv6 nf_defrag_ipv6 mdio ib_iser ip6table_filter ip6_tables rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi amd64_edac_mod i2c_nforce2 shpchp tg3 pcspkr edac_core i2c_core serio_raw k8temp edac_mce_amd ipv6 autofs4 ata_generic pata_acpi mptspi mptscsih mptbase scsi_transport_spi sata_nv pata_amd [last unloaded: scsi_wait_scan]

Pid: 6494, comm: nfsv4.1-svc Tainted: G        W   3.0.0-next-20110729 #2 HP ProLiant DL145 G2/K85NL
RIP: 0010:[<ffffffffa02998df>]  [<ffffffffa02998df>] nfs4_cb_take_slot+0x2e/0x3e [nfs]
RSP: 0018:ffff880074275bf0  EFLAGS: 00010286
RAX: 00000000ffffffff RBX: ffff88007b67ec00 RCX: 0000000000000001
RDX: 000000000000001c RSI: ffff88006b8b49f0 RDI: ffff88007b67ed88
RBP: ffff880074275c00 R08: 00000000000000d0 R09: 0000000000000002
R10: ffff88007fc12e70 R11: ffffffff81b42ab0 R12: ffff880037e72000
R13: 0000000000000000 R14: ffff880037ed3800 R15: ffff88007b67e800
FS:  00007fb17e8de720(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000003ff9064c60 CR3: 0000000069a99000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsv4.1-svc (pid: 6494, threadinfo ffff880074274000, task ffff880069410000)
Stack:
 ffff880037e72000 ffff880037ed3800 ffff880074275ca0 ffffffffa029a5c2
 ffff88006b8b49e0 ffff880071786098 ffff880074275ca0 ffffffffa0299a1a
 ffff88006b8b49e0 0000000100000246 ffff88007b67ec48 ffff880037ed3808
Call Trace:
 [<ffffffffa029a5c2>] nfs4_callback_sequence+0x272/0x338 [nfs]
 [<ffffffffa0299a1a>] ? decode_cb_sequence_args+0x12b/0x24a [nfs]
 [<ffffffffa0299733>] nfs4_callback_compound+0x364/0x4e2 [nfs]
 [<ffffffff8106f3bf>] ? groups_alloc+0x38/0xbe
 [<ffffffffa01f7206>] svc_process_common+0x260/0x4d3 [sunrpc]
 [<ffffffffa01f7552>] bc_svc_process+0xd9/0x102 [sunrpc]
 [<ffffffffa029884c>] nfs41_callback_svc+0xd5/0x126 [nfs]
 [<ffffffff8106905f>] ? wake_up_bit+0x25/0x25
 [<ffffffffa0298777>] ? nfs_callback_down+0x7c/0x7c [nfs]
 [<ffffffff81068bf8>] kthread+0x7d/0x85
 [<ffffffff81467e14>] kernel_thread_helper+0x4/0x10
 [<ffffffff81068b7b>] ? kthread_worker_fn+0x147/0x147
 [<ffffffff81467e10>] ? gs_change+0x13/0x13
Code: e5 53 48 83 ec 08 48 8b 9f a8 02 00 00 48 8d bb 88 01 00 00 e8 c4 5b 1c e1 8b 83 5c 02 00 00 ff c0 85 c0 89 83 5c 02 00 00 74 04 <0f> 0b eb fe 66 ff 83 88 01 00 00 41 5b 5b c9 c3 55 48 8d 42 08 
RIP  [<ffffffffa02998df>] nfs4_cb_take_slot+0x2e/0x3e [nfs]
 RSP <ffff880074275bf0>
---[ end trace 27e49b345894527a ]---
Callback slot table overflowed
