Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:33347 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753417Ab3H2OmM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Aug 2013 10:42:12 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 3A4A8280994
	for <linux-nfs@vger.kernel.org>; Thu, 29 Aug 2013 16:42:08 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 28FF313E83
	for <linux-nfs@vger.kernel.org>; Thu, 29 Aug 2013 16:42:05 +0200 (MEST)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.4.1) with ESMTP id <Tadd75ccee083a9615f7a00@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Thu, 29 Aug 2013 16:42:05 +0200
Received: from zimbratest.desy.de (zimbratest.desy.de [131.169.72.254])
	by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id C0B1210C8
	for <linux-nfs@vger.kernel.org>; Thu, 29 Aug 2013 16:42:05 +0200 (MEST)
Date: Thu, 29 Aug 2013 16:42:05 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Message-ID: <792883988.3232533.1377787325193.JavaMail.zimbra@desy.de>
In-Reply-To: <427608263.3232319.1377785594378.JavaMail.zimbra@desy.de>
Subject: kernel panic  with 3.10.9 with pNFS write
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



I am getting this every time (IOW, reproducible ) when I trying to write.
This is fedora 19, 64 bit 3.10.9-200.fc19.x86_64

[257349.666159] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[257366.629133] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
[257366.629154] IP: [<ffffffffa075d527>] nfs4_fl_prepare_ds+0x127/0x280 [nfs_layout_nfsv41_files]
[257366.629167] PGD 1fc02f067 PUD 16a081067 PMD 0 
[257366.629176] Oops: 0002 [#1] SMP 
[257366.629182] Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 auth_rpcgss nfsv4 nfs lockd sunrpc dns_resolver fscache tcp_lp fuse nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack vboxpci(OF) vboxnetadp(OF) vboxnetflt(OF) ebtable_filter rfcomm ebtables ip6table_filter bnep ip6_tables vboxdrv(OF) snd_hda_codec_hdmi snd_hda_codec_idt uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev arc4 iTCO_wdt iTCO_vendor_support media mperf coretemp kvm_intel iwldvm dell_laptop btusb dell_wmi mac80211 kvm bluetooth sdhci_pci snd_hda_intel ppdev sparse_keymap crc32_pclmul crc32c_intel dcdbas
[257366.629308]  ghash_clmulni_intel iwlwifi microcode snd_hda_codec cfg80211 snd_hwdep snd_seq joydev snd_seq_device snd_pcm i2c_i801 sdhci snd_page_alloc e1000e mmc_core snd_timer snd lpc_ich mei_me mfd_core rfkill mei ptp soundcore pps_core parport_pc parport uinput nouveau mxm_wmi i2c_algo_bit drm_kms_helper ttm drm firewire_ohci firewire_core crc_itu_t i2c_core wmi video
[257366.629381] CPU: 0 PID: 16763 Comm: cp Tainted: GF        C O 3.10.9-200.fc19.x86_64 #1
[257366.629387] Hardware name: Dell Inc. Latitude E6520/0J4TFW, BIOS A06 07/11/2011
[257366.629393] task: ffff8800a3a5b560 ti: ffff880221416000 task.ti: ffff880221416000
[257366.629398] RIP: 0010:[<ffffffffa075d527>]  [<ffffffffa075d527>] nfs4_fl_prepare_ds+0x127/0x280 [nfs_layout_nfsv41_files]
[257366.629409] RSP: 0018:ffff880221417c70  EFLAGS: 00010202
[257366.629414] RAX: 000000010f4e66ef RBX: 0000000000000000 RCX: 0000000000000000
[257366.629419] RDX: 00000000000bbbf6 RSI: ffffffffa07eb248 RDI: ffff8801709a8580
[257366.629424] RBP: ffff880221417ca8 R08: 0000000000016f20 R09: 019d86e3c80c0000
[257366.629429] R10: ffff880213b10d10 R11: 0000000000000000 R12: ffffffffffffff8f
[257366.629434] R13: ffff8801709a8580 R14: ffff8802125f4800 R15: 0000000000000038
[257366.629439] FS:  00007f519c809800(0000) GS:ffff88022dc00000(0000) knlGS:0000000000000000
[257366.629449] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[257366.629453] CR2: 0000000000000038 CR3: 000000022006d000 CR4: 00000000000407f0
[257366.629459] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[257366.629464] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[257366.629469] Stack:
[257366.629472]  ffff880213b10d98 ffff88009b3449c0 ffff8801fc0f00a0 ffff880101683800
[257366.629482]  ffff8802125f4800 0000000000000000 0000000000000000 ffff880221417d00
[257366.629491]  ffffffffa075b210 ffff8801eaddc598 ffff88009b345f48 ffff8801fc0f0000
[257366.629501] Call Trace:
[257366.629508]  [<ffffffffa075b210>] filelayout_write_pagelist+0x50/0x150 [nfs_layout_nfsv41_files]
[257366.629524]  [<ffffffffa084b2de>] pnfs_generic_pg_writepages+0xee/0x280 [nfsv4]
[257366.629536]  [<ffffffffa080d869>] nfs_pageio_doio+0x19/0x50 [nfs]
[257366.629546]  [<ffffffffa080dba4>] nfs_pageio_complete+0x24/0x30 [nfs]
[257366.629556]  [<ffffffffa0811c6c>] nfs_writepages+0xac/0x130 [nfs]
[257366.629565]  [<ffffffff8113a55e>] do_writepages+0x1e/0x40
[257366.629571]  [<ffffffff8112f909>] __filemap_fdatawrite_range+0x59/0x60
[257366.629578]  [<ffffffff8112fa0a>] filemap_write_and_wait_range+0x2a/0x70
[257366.629592]  [<ffffffffa0842aaf>] nfs4_file_fsync+0x5f/0xb0 [nfsv4]
[257366.629599]  [<ffffffff811c42cb>] vfs_fsync+0x2b/0x40
[257366.629607]  [<ffffffffa0803b9a>] nfs_file_flush+0x7a/0xb0 [nfs]
[257366.629614]  [<ffffffff811957a4>] filp_close+0x34/0x80
[257366.629622]  [<ffffffff811b352a>] __close_fd+0x6a/0x80
[257366.629628]  [<ffffffff81196f63>] SyS_close+0x23/0x50
[257366.629635]  [<ffffffff81647719>] system_call_fastpath+0x16/0x1b
[257366.629640] Code: 49 8b 06 4c 89 e7 48 8b b0 20 01 00 00 e8 c2 c8 0e 00 85 c0 0f 85 9f 00 00 00 f6 05 c4 08 09 00 20 4c 89 63 28 0f 85 0c 01 00 00 <f0> 41 80 27 fe 31 f6 4c 89 ff 49 89 dc e8 87 43 92 e0 e9 0c ff 
[257366.629728] RIP  [<ffffffffa075d527>] nfs4_fl_prepare_ds+0x127/0x280 [nfs_layout_nfsv41_files]
[257366.629736]  RSP <ffff880221417c70>
[257366.629740] CR2: 0000000000000038
[257366.637157] ---[ end trace 72a58bcbc080508c ]---
[root@ani data]#



Tigran.
