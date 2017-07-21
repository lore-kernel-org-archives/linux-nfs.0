Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:40313 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752152AbdGUM3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 08:29:48 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 32E962804AA
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 14:29:46 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id F40B43E901
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 14:29:45 +0200 (MEST)
Date: Fri, 21 Jul 2017 14:29:45 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <2136011996.159391.1500640185938.JavaMail.zimbra@desy.de>
Subject: Kernel Oops with 4.13.0-0.rc1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



FYI. Triggered by xfstest generic/013


[  955.424063] BUG: unable to handle kernel paging request at ffffffffc0bb5118
[  955.424086] IP: report_bug+0x94/0x120
[  955.424090] PGD 29e0c067 
[  955.424091] P4D 29e0c067 
[  955.424094] PUD 29e0e067 
[  955.424097] PMD 1265ab067 
[  955.424100] PTE 80000000c2d46161

[  955.424108] Oops: 0003 [#1] SMP
[  955.424112] Modules linked in: nfs_layout_flexfiles rpcsec_gss_krb5 nfsv4 dns_resolver nfs lockd grace fscache binfmt_misc nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables btrfs xor raid6_pq coretemp kvm_intel kvm irqbypass iTCO_wdt iTCO_vendor_support snd_hda_codec_idt gpio_ich ppdev snd_hda_codec_generic pcspkr snd_hda_intel snd_hda_codec i2c_i801 snd_hda_core lpc_ich snd_hwdep snd_seq tpm_tis tpm_tis_core
[  955.424175]  tpm snd_seq_device snd_pcm winbond_cir rc_core snd_timer parport_pc parport snd soundcore x38_edac acpi_cpufreq shpchp auth_rpcgss sunrpc ata_generic pata_acpi nouveau video serio_raw firewire_ohci mxm_wmi wmi i2c_algo_bit firewire_core drm_kms_helper ttm crc_itu_t drm e1000e pata_marvell ptp pps_core
[  955.424205] CPU: 1 PID: 4549 Comm: fsstress Tainted: G        W I     4.13.0-0.rc1.git1.1.vanilla.knurd.1.fc26.x86_64 #1
[  955.424211] Hardware name: Comptronic pczW1007/DX38BT, BIOS BTX3810J.86A.1893.2008.1009.1712 10/09/2008
[  955.424216] task: ffff9f7f2a4d4a00 task.stack: ffffb79290914000
[  955.424221] RIP: 0010:report_bug+0x94/0x120
[  955.424224] RSP: 0018:ffffb79290917860 EFLAGS: 00010202
[  955.424229] RAX: 0000000000000907 RBX: ffffb792909179c8 RCX: ffffffffc0bb510e
[  955.424233] RDX: 0000000000000001 RSI: 0000000000000378 RDI: 0000000000000001
[  955.424238] RBP: ffffb79290917880 R08: ffffb79290918000 R09: 00000000000002c0
[  955.424242] R10: ffffffff85e06a80 R11: ffffffffffffffff R12: ffffffffc0ba5f18
[  955.424248] R13: ffffffffc0bb4966 R14: 0000000000000004 R15: ffffb792909179c8
[  955.424253] FS:  00007f3a5e58ae80(0000) GS:ffff9f7f2fc80000(0000) knlGS:0000000000000000
[  955.424257] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  955.424262] CR2: ffffffffc0bb5118 CR3: 00000000c40ac000 CR4: 00000000000406e0
[  955.424266] Call Trace:
[  955.424290]  ? nfs_pageio_add_request+0x238/0x260 [nfs]
[  955.424300]  fixup_bug+0x2e/0x50
[  955.424304]  do_trap+0x119/0x150
[  955.424308]  do_error_trap+0x89/0x110
[  955.424318]  ? nfs_pageio_add_request+0x238/0x260 [nfs]
[  955.424326]  ? nfs_put_client+0x13/0x20 [nfs]
[  955.424358]  ? pnfs_put_layout_hdr+0x4a/0x180 [nfsv4]
[  955.424370]  ? nfs4_wait_clnt_recover+0x3f/0x80 [nfsv4]
[  955.424663]  ? pnfs_update_layout+0x675/0x1320 [nfsv4]
[  955.425013]  do_invalid_op+0x20/0x30
[  955.425013]  invalid_op+0x1e/0x30
[  955.425013] RIP: 0010:nfs_pageio_add_request+0x238/0x260 [nfs]
[  955.425013] RSP: 0018:ffffb79290917a78 EFLAGS: 00010246
[  955.425013] RAX: 0000000000000001 RBX: ffffb79290917c28 RCX: 0000000000000000
[  955.425013] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff9f7f2881f100
[  955.425013] RBP: ffffb79290917aa8 R08: ffffffffffffffff R09: ffffffffffffffff
[  955.425013] R10: ffffb79290917a58 R11: ffffffffffffffff R12: ffff9f7ec2f69880
[  955.425013] R13: ffffb79290917c28 R14: ffff9f7ec2f69880 R15: 0000000000000000
[  955.425013]  ? nfs_pageio_add_request+0x3f/0x260 [nfs]
[  955.425013]  nfs_do_writepage+0x1fd/0x340 [nfs]
[  955.425013]  nfs_writepages_callback+0x14/0x30 [nfs]
[  955.425013]  write_cache_pages+0x1e2/0x510
[  955.425013]  ? btrfs_clear_bit_hook+0x164/0x420 [btrfs]
[  955.425013]  ? nfs_do_writepage+0x340/0x340 [nfs]
[  955.425013]  nfs_writepages+0xbc/0x120 [nfs]
[  955.425013]  do_writepages+0x48/0xe0
[  955.425013]  ? __enqueue_entity+0x6c/0x70
[  955.425013]  ? enqueue_entity+0x109/0x7a0
[  955.425013]  __filemap_fdatawrite_range+0xc1/0x100
[  955.425013]  ? __filemap_fdatawrite_range+0xc1/0x100
[  955.425013]  filemap_write_and_wait_range+0x41/0xa0
[  955.425013]  nfs_file_fsync+0x96/0x1d0 [nfs]
[  955.425013]  vfs_fsync_range+0x49/0xa0
[  955.425013]  vfs_fsync+0x1c/0x20
[  955.425013]  nfs4_file_flush+0x57/0x80 [nfsv4]
[  955.425013]  filp_close+0x2c/0x80
[  955.425013]  __close_fd+0x81/0xa0
[  955.425013]  SyS_close+0x23/0x50
[  955.425013]  entry_SYSCALL_64_fastpath+0x1a/0xa5
[  955.425013] RIP: 0033:0x7f3a5dd761e0
[  955.425013] RSP: 002b:00007ffc3aad15c8 EFLAGS: 00000246 ORIG_RAX: 0000000000000003
[  955.425013] RAX: ffffffffffffffda RBX: 0000000000000008 RCX: 00007f3a5dd761e0
[  955.425013] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000003
[  955.425013] RBP: 00000000000120cf R08: 00007f3a580009d0 R09: 0000000000000090
[  955.425013] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000003
[  955.425013] R13: 00000000000d6a90 R14: 00007f3a58001b60 R15: 0000000000000000
[  955.425013] Code: 74 59 0f b7 41 0a 4c 63 69 04 0f b7 71 08 89 c7 49 01 cd 83 e7 01 a8 02 74 15 66 85 ff 74 10 a8 04 ba 01 00 00 00 75 26 83 c8 04 <66> 89 41 0a 66 85 ff 74 49 0f b6 49 0b 4c 89 e2 45 31 c9 49 89 
[  955.425013] RIP: report_bug+0x94/0x120 RSP: ffffb79290917860
[  955.425013] CR2: ffffffffc0bb5118
[  955.425013] ---[ end trace a5ecaff0687a5621 ]---


Tigran.
