Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:58355 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498AbcF2OcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jun 2016 10:32:20 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 1AFFC280A0E
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2016 16:32:18 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 0DAFB1318
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2016 16:32:16 +0200 (MEST)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tc2a969c32f83a961601254@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Wed, 29 Jun 2016 16:32:16 +0200
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id F13D53E901
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jun 2016 16:32:15 +0200 (MEST)
Date: Wed, 29 Jun 2016 16:32:15 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Message-ID: <1437966383.20209875.1467210735879.JavaMail.zimbra@desy.de>
Subject: unhappy 4.5.7 kernel with nfs
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear NFS gurus and Co.


During some simple testing as:

on a fresh rebooted host

[root@anahit ~]# uptime
 16:31:10 up  1:29,  1 user,  load average: 0.39, 0.65, 0.35
[root@anahit ~]# uname -a
Linux anahit.desy.de 4.5.7-300.fc24.x86_64 #1 SMP Wed Jun 8 18:12:45 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
[root@anahit ~]# mount -o vers=4.1 dcache-lab007:/ /pnfs
[root@anahit ~]# cd /pnfs/exports/data
[root@anahit data]# python
Python 2.7.11 (default, Jun 21 2016, 09:15:12) 
[GCC 6.1.1 20160510 (Red Hat 6.1.1-2)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> f = open("NTUP_MINBIAS.125118._000007.root.1")
>>> b = f.read(1)
Segmentation fault
[root@anahit data]# dmesg 

......

[ 5128.031968] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[ 5153.179497] page:ffffea0001863980 count:2 mapcount:0 mapping:ffff880074d73eb0 index:0x0
[ 5153.179502] flags: 0x1ffffc00000000()
[ 5153.179504] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
[ 5153.179506] page->mem_cgroup:ffff88012b013800
[ 5153.179528] ------------[ cut here ]------------
[ 5153.179542] kernel BUG at mm/filemap.c:843!
[ 5153.179548] invalid opcode: 0000 [#1] SMP 
[ 5153.179556] Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache fuse binfmt_misc nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_security ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables btrfs xor raid6_pq coretemp snd_hda_codec_idt kvm_intel snd_hda_codec_generic snd_hda_intel kvm snd_hda_codec snd_hda_core irqbypass snd_hwdep snd_seq snd_seq_device snd_pcm gpio_ich ppdev iTCO_wdt iTCO_vendor_support lpc_ich winbond_cir snd_timer i2c_i801
[ 5153.179700]  rc_core parport_pc snd parport shpchp soundcore acpi_cpufreq x38_edac edac_core tpm_tis tpm nfsd auth_rpcgss nfs_acl lockd grace sunrpc ata_generic pata_acpi nouveau serio_raw video mxm_wmi wmi i2c_algo_bit drm_kms_helper firewire_ohci firewire_core ttm crc_itu_t drm pata_marvell fjes e1000e ptp pps_core
[ 5153.179772] CPU: 0 PID: 2504 Comm: python Tainted: G          I     4.5.7-300.fc24.x86_64 #1
[ 5153.179780] Hardware name: Comptronic pczW1007/DX38BT, BIOS BTX3810J.86A.1893.2008.1009.1712 10/09/2008
[ 5153.179788] task: ffff8800c88cd880 ti: ffff88007fef8000 task.ti: ffff88007fef8000
[ 5153.179794] RIP: 0010:[<ffffffff811b1966>]  [<ffffffff811b1966>] unlock_page+0xa6/0xb0
[ 5153.179808] RSP: 0018:ffff88007fefbac8  EFLAGS: 00010282
[ 5153.179813] RAX: 0000000000000021 RBX: ffffea0001863980 RCX: 0000000000000006
[ 5153.179820] RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffff88012fc0dfb0
[ 5153.179826] RBP: ffff88007fefbac8 R08: 000000000002bd32 R09: 0000000000000389
[ 5153.179833] R10: 0000000000000000 R11: ffffffff81f410cd R12: ffff880090f6fa00
[ 5153.179839] R13: 00000000fffffffb R14: ffff88007fefbb60 R15: ffffea00018639a0
[ 5153.179846] FS:  00007fef72a0b700(0000) GS:ffff88012fc00000(0000) knlGS:0000000000000000
[ 5153.179853] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 5153.179859] CR2: 00007f45eaadc000 CR3: 000000007fe35000 CR4: 00000000000406f0
[ 5153.179865] Stack:
[ 5153.179869]  ffff88007fefbaf8 ffffffffa07d7c28 ffff88007fefbc90 ffffea0001863980
[ 5153.179882]  ffff880074d73eb0 ffff8800c88cd880 ffff88007fefbb48 ffffffff811c2aa1
[ 5153.179894]  ffff8800c88cd880 ffff88007fefbb60 ffffffffa07d7b70 ffff880074d73d48
[ 5153.179906] Call Trace:
[ 5153.179928]  [<ffffffffa07d7c28>] readpage_async_filler+0xb8/0x220 [nfs]
[ 5153.179938]  [<ffffffff811c2aa1>] read_cache_pages+0xc1/0x150
[ 5153.179954]  [<ffffffffa07d7b70>] ? nfs_read_completion+0x210/0x210 [nfs]
[ 5153.179972]  [<ffffffffa07d8319>] nfs_readpages+0x129/0x200 [nfs]
[ 5153.179980]  [<ffffffff811c2ccd>] __do_page_cache_readahead+0x19d/0x270
[ 5153.179988]  [<ffffffff811c2e6e>] ondemand_readahead+0xce/0x250
[ 5153.179995]  [<ffffffff811c318e>] page_cache_sync_readahead+0x2e/0x50
[ 5153.180002]  [<ffffffff811b4a32>] generic_file_read_iter+0x5d2/0x8b0
[ 5153.180028]  [<ffffffffa0822563>] ? nfs4_have_delegation+0x13/0x20 [nfsv4]
[ 5153.180044]  [<ffffffffa07cf3eb>] ? __nfs_revalidate_mapping+0x8b/0x240 [nfs]
[ 5153.180053]  [<ffffffff811c542c>] ? lru_cache_add_active_or_unevictable+0x4c/0xf0
[ 5153.180068]  [<ffffffffa07cac72>] nfs_file_read+0x52/0xa0 [nfs]
[ 5153.180076]  [<ffffffff81241528>] __vfs_read+0xc8/0x110
[ 5153.180083]  [<ffffffff81242496>] vfs_read+0x86/0x130
[ 5153.180090]  [<ffffffff81243455>] SyS_read+0x55/0xc0
[ 5153.180098]  [<ffffffff817cf06e>] entry_SYSCALL_64_fastpath+0x12/0x6d
[ 5153.180104] Code: 92 b0 00 00 00 48 d3 ee 48 8d 0c 76 48 89 c6 48 8d 3c ca 31 d2 e8 db 68 f3 ff 5d c3 48 c7 c6 58 bb a7 81 48 89 c7 e8 0a 1a 03 00 <0f> 0b 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 fa 48 89 
[ 5153.180206] RIP  [<ffffffff811b1966>] unlock_page+0xa6/0xb0
[ 5153.180215]  RSP <ffff88007fefbac8>
[ 5153.182743] ---[ end trace 7439f3337246bf52 ]---


100% reproducible!

Tigran.

