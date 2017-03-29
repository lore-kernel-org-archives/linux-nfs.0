Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:36826 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932159AbdC2K2q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Mar 2017 06:28:46 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 503D22801B2
        for <linux-nfs@vger.kernel.org>; Wed, 29 Mar 2017 12:28:43 +0200 (CEST)
Date: Wed, 29 Mar 2017 12:28:40 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <870043102.5132506.1490783320914.JavaMail.zimbra@desy.de>
Subject: flexfile: kernel oops with v4.1 data server
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We have updated out MDS to return v4.1 DSes for flexfile layout. 

[  220.370709] BUG: unable to handle kernel NULL pointer dereference at 0000000000000065
[  220.370842] IP: ff_layout_mirror_valid+0x2d/0x110 [nfs_layout_flexfiles]
[  220.370920] PGD 0 

[  220.370972] Oops: 0000 [#1] SMP
[  220.371013] Modules linked in: nfnetlink_queue nfnetlink_log bluetooth nfs_layout_flexfiles rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_raw ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security iptable_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_security ebtable_filter ebtables ip6table_filter ip6_tables binfmt_misc intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel btrfs kvm arc4 snd_hda_codec_hdmi iwldvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel intel_cstate mac80211 xor uvcvideo
[  220.371814]  videobuf2_vmalloc videobuf2_memops snd_hda_codec_idt mei_wdt videobuf2_v4l2 snd_hda_codec_generic iTCO_wdt ppdev videobuf2_core iTCO_vendor_support dell_rbtn dell_wmi iwlwifi sparse_keymap dell_laptop dell_smbios snd_hda_intel dcdbas videodev snd_hda_codec dell_smm_hwmon snd_hda_core media cfg80211 intel_uncore snd_hwdep raid6_pq snd_seq intel_rapl_perf snd_seq_device joydev i2c_i801 rfkill lpc_ich snd_pcm parport_pc mei_me parport snd_timer dell_smo8800 mei snd shpchp soundcore tpm_tis tpm_tis_core tpm nfsd auth_rpcgss nfs_acl lockd grace sunrpc i915 nouveau mxm_wmi ttm i2c_algo_bit drm_kms_helper crc32c_intel e1000e drm sdhci_pci firewire_ohci sdhci serio_raw mmc_core firewire_core ptp crc_itu_t pps_core wmi fjes video
[  220.372568] CPU: 7 PID: 4988 Comm: cat Not tainted 4.10.5-200.fc25.x86_64 #1
[  220.372647] Hardware name: Dell Inc. Latitude E6520/0J4TFW, BIOS A06 07/11/2011
[  220.372729] task: ffff94791f6ea580 task.stack: ffffb72b88c0c000
[  220.372802] RIP: 0010:ff_layout_mirror_valid+0x2d/0x110 [nfs_layout_flexfiles]
[  220.372883] RSP: 0018:ffffb72b88c0f970 EFLAGS: 00010246
[  220.372945] RAX: 0000000000000000 RBX: ffff9479015ca600 RCX: ffffffffffffffed
[  220.373025] RDX: ffffffffffffffed RSI: ffff9479753dc980 RDI: 0000000000000000
[  220.373104] RBP: ffffb72b88c0f988 R08: 000000000001c980 R09: ffffffffc0ea6112
[  220.373184] R10: ffffef17477d9640 R11: ffff9479753dd6c0 R12: ffff9479211c7440
[  220.373264] R13: ffff9478f45b7790 R14: 0000000000000001 R15: ffff9479015ca600
[  220.373345] FS:  00007f555fa3e700(0000) GS:ffff9479753c0000(0000) knlGS:0000000000000000
[  220.373435] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  220.373506] CR2: 0000000000000065 CR3: 0000000196044000 CR4: 00000000000406e0
[  220.373586] Call Trace:
[  220.373627]  nfs4_ff_layout_prepare_ds+0x5e/0x200 [nfs_layout_flexfiles]
[  220.373708]  ff_layout_pg_init_read+0x81/0x160 [nfs_layout_flexfiles]
[  220.373806]  __nfs_pageio_add_request+0x11f/0x4a0 [nfs]
[  220.373886]  ? nfs_create_request.part.14+0x37/0x330 [nfs]
[  220.373967]  nfs_pageio_add_request+0xb2/0x260 [nfs]
[  220.374042]  readpage_async_filler+0xaf/0x280 [nfs]
[  220.374103]  read_cache_pages+0xef/0x1b0
[  220.374166]  ? nfs_read_completion+0x210/0x210 [nfs]
[  220.374239]  nfs_readpages+0x129/0x200 [nfs]
[  220.374293]  __do_page_cache_readahead+0x1d0/0x2f0
[  220.374352]  ondemand_readahead+0x17d/0x2a0
[  220.374403]  page_cache_sync_readahead+0x2e/0x50
[  220.374460]  generic_file_read_iter+0x6c8/0x950
[  220.374532]  ? nfs_mapping_need_revalidate_inode+0x17/0x40 [nfs]
[  220.374617]  nfs_file_read+0x6e/0xc0 [nfs]
[  220.374670]  __vfs_read+0xe2/0x150
[  220.374715]  vfs_read+0x96/0x130
[  220.374758]  SyS_read+0x55/0xc0
[  220.374801]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[  220.374856] RIP: 0033:0x7f555f570bd0
[  220.374900] RSP: 002b:00007ffeb73e1b38 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
[  220.374986] RAX: ffffffffffffffda RBX: 00007f555f839ae0 RCX: 00007f555f570bd0
[  220.375066] RDX: 0000000000020000 RSI: 00007f555fa41000 RDI: 0000000000000003
[  220.375145] RBP: 0000000000021010 R08: ffffffffffffffff R09: 0000000000000000
[  220.375226] R10: 00007f555fa40010 R11: 0000000000000246 R12: 0000000000022000
[  220.375305] R13: 0000000000021010 R14: 0000000000001000 R15: 0000000000002710
[  220.375386] Code: 66 66 90 55 48 89 e5 41 54 53 49 89 fc 48 83 ec 08 48 85 f6 74 2e 48 8b 4e 30 48 89 f3 48 81 f9 00 f0 ff ff 77 1e 48 85 c9 74 15 <48> 83 79 78 00 b8 01 00 00 00 74 2c 48 83 c4 08 5b 41 5c 5d c3 
[  220.375653] RIP: ff_layout_mirror_valid+0x2d/0x110 [nfs_layout_flexfiles] RSP: ffffb72b88c0f970
[  220.375748] CR2: 0000000000000065
[  220.403538] ---[ end trace bcdca752211b7da9 ]---


I had a look at the code. 

Here is an other problem (or this one?) which I have spotted. If I ead core correctly, then in flexfilelayoutdev.c

198                         node = nfs4_find_get_deviceid(NFS_SERVER(lh->plh_inode),
199                                         &mirror->devid, lh->plh_lc_cred,
200                                         GFP_KERNEL);
201                         if (node)
202                                 mirror_ds = FF_LAYOUT_MIRROR_DS(node);
203 
204                         /* check for race with another call to this function */
205                         if (cmpxchg(&mirror->mirror_ds, NULL, mirror_ds) &&
206                             mirror_ds != ERR_PTR(-ENODEV))
207                                 nfs4_put_deviceid_node(node);

at line 207 we may pass NULL to nfs4_put_deviceid_node, when nfs4_find_get_deviceid returns NULL.


the nfs4_put_deviceid_node itself, unconditionally references provided value.

272 bool
273 nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
274 {
275         if (test_bit(NFS_DEVICEID_NOCACHE, &d->flags)) {
276                 if (atomic_add_unless(&d->ref, -1, 2))
277                         return false;
278                 nfs4_delete_deviceid(d->ld, d->nfs_client, &d->deviceid);
279         }



According to packet trace, LAYOUTGET and GETDEVICEINFO was processed.

I can reproduce it with v4.11-rc3 as well. If I switch back to v3 for DSes, that problem is gone.


Tigran.


