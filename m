Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:50390 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753539AbeCEW1B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Mar 2018 17:27:01 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id C66CD2800BB
        for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2018 23:26:59 +0100 (CET)
Date: Mon, 5 Mar 2018 23:26:59 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <1569515727.10818617.1520288819283.JavaMail.zimbra@desy.de>
Subject: Kernel ops with flexfiles
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond et al.

looks like I can always reproduce the following ops with a simple cp:

[10722.729463] nfs4flexfilelayout_init: NFSv4 Flexfile Layout Driver Registering...
[10736.187403] ------------[ cut here ]------------
[10736.187405] Kernel BUG at 00000000f71645f7 [verbose debug info unavailable]
[10736.187417] ------------[ cut here ]------------
[10736.187432] refcount_t hit zero at pnfs_layout_remove_lseg+0x46/0x90 [nfsv4] in kworker/1:0[16409], uid/euid: 0/0
[10736.187436] WARNING: CPU: 1 PID: 16409 at kernel/panic.c:657 refcount_error_report+0x94/0x9e
[10736.187436] Modules linked in: nfs_layout_flexfiles rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache xt_nat veth ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_addrtype br_netfilter overlay tun rfcomm fuse ccm nf_conntrack_netbios_ns nf_conntrack_broadcast xt_CT ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack xt_multiport ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables cmac binfmt_misc bnep sunrpc vfat fat arc4 snd_soc_skl snd_hda_codec_hdmi snd_soc_skl_ipc snd_hda_ext_core snd_soc_sst_dsp
[10736.187463]  snd_soc_sst_ipc snd_soc_acpi uvcvideo snd_soc_core videobuf2_vmalloc btusb btrtl intel_rapl btbcm btintel videobuf2_memops x86_pkg_temp_thermal intel_powerclamp videobuf2_v4l2 bluetooth snd_hda_codec_realtek videobuf2_core iwlmvm snd_hda_codec_generic coretemp videodev kvm_intel snd_compress snd_pcm_dmaengine ac97_bus mac80211 media snd_hda_intel kvm snd_hda_codec iTCO_wdt iTCO_vendor_support iwlwifi mei_wdt dell_wmi ecdh_generic wmi_bmof dell_smbios_wmi dell_laptop sparse_keymap snd_hda_core dell_wmi_descriptor ppdev dell_smbios_smm dell_smbios dcdbas snd_hwdep irqbypass crct10dif_pclmul dell_smm_hwmon crc32_pclmul snd_seq cfg80211 snd_seq_device ghash_clmulni_intel snd_pcm intel_cstate intel_uncore i2c_i801 intel_rapl_perf snd_timer joydev rtsx_pci_ms memstick snd mei_me soundcore
[10736.187491]  mei processor_thermal_device shpchp intel_soc_dts_iosf intel_pch_thermal wmi parport_pc parport dell_rbtn int3400_thermal acpi_thermal_rel acpi_pad int3403_thermal rfkill int340x_thermal_zone i915 rtsx_pci_sdmmc mmc_core i2c_algo_bit drm_kms_helper drm e1000e crc32c_intel serio_raw rtsx_pci ptp pps_core video
[10736.187504] CPU: 1 PID: 16409 Comm: kworker/1:0 Tainted: G        W        4.15.6-300.fc27.x86_64 #1
[10736.187505] Hardware name: Dell Inc. Latitude E7470/0T6HHJ, BIOS 1.6.3 06/15/2016
[10736.187518] Workqueue: nfsiod rpc_async_release [sunrpc]
[10736.187520] RIP: 0010:refcount_error_report+0x94/0x9e
[10736.187521] RSP: 0018:ffffa5c6d196fac0 EFLAGS: 00010282
[10736.187522] RAX: 0000000000000000 RBX: ffffffff93088273 RCX: 0000000000000006
[10736.187523] RDX: 0000000000000007 RSI: 0000000000000082 RDI: ffff9a780dc968f0
[10736.187523] RBP: ffffa5c6d196fc08 R08: 0000000000000651 R09: 0000000000000004
[10736.187524] R10: ffffffff93206a80 R11: 0000000000000001 R12: ffff9a776fe63f80
[10736.187525] R13: 0000000000000000 R14: ffffffff930795b5 R15: 0000000000000004
[10736.187526] FS:  0000000000000000(0000) GS:ffff9a780dc80000(0000) knlGS:0000000000000000
[10736.187527] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[10736.187528] CR2: 000000000000000c CR3: 000000036120a005 CR4: 00000000003606e0
[10736.187529] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[10736.187529] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[10736.187530] Call Trace:
[10736.187534]  ex_handler_refcount+0x4e/0x80
[10736.187536]  fixup_exception+0x33/0x40
[10736.187538]  do_trap+0x83/0x140
[10736.187540]  do_error_trap+0x9d/0x120
[10736.187550]  ? nfs42_proc_clone+0x2c7/0x309 [nfsv4]
[10736.187552]  ? __update_load_avg_se.isra.30+0x1b6/0x1c0
[10736.187553]  ? __update_load_avg_se.isra.30+0x1b6/0x1c0
[10736.187555]  ? update_load_avg+0x558/0x6b0
[10736.187557]  invalid_op+0x51/0x70
[10736.187566] RIP: 0010:pnfs_layout_remove_lseg+0x46/0x90 [nfsv4]
[10736.187566] RSP: 0018:ffffa5c6d196fcb8 EFLAGS: 00010246
[10736.187567] RAX: ffff9a765cc07f28 RBX: ffff9a757fe5f000 RCX: ffff9a765cc07f00
[10736.187568] RDX: ffff9a765cc07f28 RSI: ffff9a757fe5f000 RDI: ffff9a757fe5f000
[10736.187569] RBP: ffff9a765cc07f00 R08: 0000000000000004 R09: 0fb19d5a01000000
[10736.187570] R10: ffffa5c6d196fda8 R11: ffffffffc10e3470 R12: ffff9a765cc07f01
[10736.187570] R13: ffff9a756cc2d8c0 R14: 0000000000000000 R15: ffff9a765cc07f00
[10736.187579]  ? pnfs_layout_remove_lseg+0x1d/0x90 [nfsv4]
[10736.187585]  pnfs_lseg_dec_and_remove_zero+0x37/0x70 [nfsv4]
[10736.187593]  mark_lseg_invalid+0x29/0x50 [nfsv4]
[10736.187600]  pnfs_roc+0x1ad/0x310 [nfsv4]
[10736.187606]  ? nfs4_do_close+0x1c9/0x2e0 [nfsv4]
[10736.187611]  nfs4_do_close+0x1c9/0x2e0 [nfsv4]
[10736.187620]  __put_nfs_open_context+0x7c/0x100 [nfs]
[10736.187627]  nfs_commitdata_release+0x15/0x30 [nfs]
[10736.187634]  rpc_free_task+0x2d/0x70 [sunrpc]
[10736.187637]  process_one_work+0x175/0x390
[10736.187640]  worker_thread+0x2e/0x380
[10736.187641]  ? process_one_work+0x390/0x390
[10736.187644]  kthread+0x113/0x130
[10736.187645]  ? kthread_create_worker_on_cpu+0x70/0x70
[10736.187647]  ? kthread_create_worker_on_cpu+0x70/0x70
[10736.187648]  ret_from_fork+0x35/0x40
[10736.187649] Code: 48 8b 95 80 00 00 00 41 55 49 8d 8c 24 48 07 00 00 45 8b 84 24 68 05 00 00 41 89 c1 48 89 de 48 c7 c7 c0 c7 08 93 e8 4c fa ff ff <0f> 0b 58 5b 5d 41 5c 41 5d c3 0f 1f 44 00 00 55 48 89 e5 41 56 
[10736.187673] ---[ end trace ae865330f8bfd4f0 ]---
[10736.187699] ------------[ cut here ]------------
[10736.187700] Kernel BUG at 00000000c11ed4b1 [verbose debug info unavailable]


If I downgrade my kernel to any of 4.14 - ops is gone. The 4.16-rc4 panics as well.
Let me know if you need more info or testing.


Regards,
   Tigran
