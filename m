Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:40843 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750913AbdLGSC7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 13:02:59 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id C304C28035A
        for <linux-nfs@vger.kernel.org>; Thu,  7 Dec 2017 19:02:56 +0100 (CET)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 6F664142E
        for <linux-nfs@vger.kernel.org>; Thu,  7 Dec 2017 19:02:56 +0100 (MET)
Date: Thu, 7 Dec 2017 19:02:56 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1331153121.8329860.1512669776409.JavaMail.zimbra@desy.de>
Subject: kernel BUG on umount
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


triggered on umount.


[18593.320000] ------------[ cut here ]------------
[18593.320003] kernel BUG at fs/inode.c:567!
[18593.320010] invalid opcode: 0000 [#1] SMP
[18593.320043] Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache xt_nat veth ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_addrtype br_netfilter overlay xfs uas usb_storage nfnetlink_queue nfnetlink_log tun fuse ccm xt_multiport nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables bnep binfmt_misc sunrpc vfat fat arc4 snd_soc_skl snd_soc_skl_ipc snd_soc_sst_ipc
[18593.320416]  snd_soc_sst_dsp snd_hda_ext_core uvcvideo intel_rapl snd_soc_sst_match snd_hda_codec_hdmi videobuf2_vmalloc x86_pkg_temp_thermal snd_soc_core intel_powerclamp videobuf2_memops iwlmvm videobuf2_v4l2 videobuf2_core coretemp dell_laptop dell_wmi iTCO_wdt iTCO_vendor_support mei_wdt kvm_intel videodev snd_compress btusb sparse_keymap kvm mac80211 snd_hda_codec_realtek wmi_bmof ppdev btrtl snd_hda_codec_generic dell_smbios dcdbas snd_pcm_dmaengine ac97_bus media irqbypass iwlwifi crct10dif_pclmul snd_hda_intel crc32_pclmul dell_smm_hwmon ghash_clmulni_intel intel_cstate snd_hda_codec intel_uncore snd_hda_core intel_rapl_perf snd_hwdep snd_seq cfg80211 rtsx_pci_ms snd_seq_device joydev snd_pcm memstick snd_timer snd hci_uart soundcore i2c_i801 mei_me tpm_tis btbcm btqca tpm_tis_core mei shpchp
[18593.320671]  processor_thermal_device intel_pch_thermal intel_soc_dts_iosf btintel tpm bluetooth wmi parport_pc parport pinctrl_sunrisepoint intel_lpss_acpi pinctrl_intel ecdh_generic intel_lpss dell_rbtn acpi_als kfifo_buf int3403_thermal rfkill int340x_thermal_zone industrialio int3400_thermal acpi_thermal_rel acpi_pad i915 rtsx_pci_sdmmc mmc_core e1000e i2c_algo_bit drm_kms_helper ptp drm serio_raw rtsx_pci crc32c_intel pps_core video i2c_hid
[18593.320818] CPU: 3 PID: 27568 Comm: umount.nfs4 Not tainted 4.13.16-300.fc27.x86_64 #1
[18593.320848] Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.6.3 06/15/2016
[18593.320884] task: ffff8c8dbb6a0000 task.stack: ffffa512c6508000
[18593.320921] RIP: 0010:evict+0x172/0x190
[18593.320942] RSP: 0018:ffffa512c650bd70 EFLAGS: 00010202
[18593.320973] RAX: 0000000000000000 RBX: ffff8c8b6bf06400 RCX: ffff8c8b6bf064a0
[18593.321009] RDX: ffffffff96e063f8 RSI: ffff8c8b6bf064a0 RDI: ffffffff96e063f0
[18593.321048] RBP: ffffa512c650bd88 R08: 0000000000000001 R09: 0000000180150012
[18593.321084] R10: ffffa512c650bc68 R11: 0000000000000000 R12: ffff8c8b6bf06520
[18593.321109] R13: ffffffffc11e94c0 R14: ffff8c8b54755c68 R15: ffff8c8b6bf00e08
[18593.321135] FS:  00007f4a7deeb000(0000) GS:ffff8c8dcdd80000(0000) knlGS:0000000000000000
[18593.321164] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[18593.321190] CR2: 00007f4a7d8b0930 CR3: 00000001ba15a000 CR4: 00000000003406e0
[18593.321218] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[18593.321243] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[18593.321276] Call Trace:
[18593.321291]  dispose_list+0x4d/0x70
[18593.321306]  evict_inodes+0x17a/0x1a0
[18593.321323]  generic_shutdown_super+0x44/0x110
[18593.321349]  nfs_kill_super+0x21/0x40 [nfs]
[18593.321366]  deactivate_locked_super+0x43/0x70
[18593.321384]  deactivate_super+0x3f/0x60
[18593.321400]  cleanup_mnt+0x3f/0x80
[18593.321415]  __cleanup_mnt+0x12/0x20
[18593.321431]  task_work_run+0x76/0x90
[18593.321447]  exit_to_usermode_loop+0xab/0xb0
[18593.321464]  syscall_return_slowpath+0x8f/0xa0
[18593.321483]  entry_SYSCALL_64_fastpath+0xa3/0xa5
[18593.321502] RIP: 0033:0x7f4a7d385ea7
[18593.321516] RSP: 002b:00007fff597454a8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a6
[18593.321543] RAX: 0000000000000000 RBX: 00005619e0a4d920 RCX: 00007f4a7d385ea7
[18593.321574] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 00005619e0a567d0
[18593.321605] RBP: 00005619e0a567d0 R08: 00007fff59745410 R09: 00005619e0a5b85a
[18593.321631] R10: 0000000000000013 R11: 0000000000000246 R12: 00007f4a7dabd184
[18593.321656] R13: 0000000000000000 R14: 00005619e0a5b660 R15: 00007fff59746379
[18593.321682] Code: 89 df e8 f2 5b fe ff eb 8f 48 83 bb 28 02 00 00 00 74 85 48 89 df e8 3e 24 02 00 0f b7 03 66 25 00 f0 e9 6b ff ff ff 0f 0b 0f 0b <0f> 0b 48 8d bb 78 01 00 00 e8 70 5c f5 ff 48 89 df e8 b8 ef ff 
[18593.321774] RIP: evict+0x172/0x190 RSP: ffffa512c650bd70
[18593.329038] ---[ end trace bd3e16565ae6e59c ]---

Tigran.
