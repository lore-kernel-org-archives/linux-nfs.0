Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:39624 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751494AbbJBMCk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Oct 2015 08:02:40 -0400
From: Andrew W Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Subject: 4.1.6 nfs client crash
Date: Fri, 02 Oct 2015 08:02:38 -0400
Message-ID: <m2y4fla36p.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We've seen this one a few times now. Any ideas on where to look?

[315893.208846] ------------[ cut here ]------------
[315893.215486] WARNING: CPU: 32 PID: 3056 at lib/list_debug.c:36 __list_add+0x92/0xc0()
[315893.225679] list_add double add: new=ffff886008f98908, prev=ffff886008f98908, next=ffff88600d42e530.
[315893.237281] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill cts rpcsec_gss_krb5 nfsv4(E) dns_resolver nfs(E) fscache nf_log_ipv6 xt_multiport nf_log_ipv4 nf_log_common xt_LOG bonding ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_filter iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip6_tables ip_tables x86_pkg_temp_thermal coretemp kvm_intel nfsd kvm crct10dif_pclmul auth_rpcgss crc32_pclmul mei_me crc32c_intel ghash_clmulni_intel nfs_acl lockd aesni_intel iTCO_wdt iTCO_vendor_support lrw gf128mul glue_helper sb_edac ablk_helper edac_core cryptd mei pcspkr lpc_ich shpchp mfd_core wmi grace ipmi_si ipmi_msghandler acpi_pad sunrpc acpi_power_meter binfmt_misc xfs sd_mod fnic mgag200
[315893.325480]  syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm igb ahci libfcoe libahci ptp libfc libata enic megaraid_sas pps_core dca i2c_algo_bit scsi_transport_fc i2c_core dm_mirror dm_region_hash dm_log dm_mod
[315893.349194] CPU: 32 PID: 3056 Comm: 129.21.16.62-ma Tainted: G        W   E   4.1.6 #1
[315893.359571] Hardware name: Cisco Systems Inc UCSC-C220-M4S/UCSC-C220-M4S, BIOS C220M4.2.0.3c.0.091920141954 09/19/2014
[315893.373094]  ffffffff818c31a0 ffff884809b6fc88 ffffffff81657d87 0000000000000001
[315893.382995]  ffff884809b6fcd8 ffff884809b6fcc8 ffffffff8107855a 0000000000000282
[315893.393066]  ffff886008f98908 ffff88600d42e530 ffff886008f98908 ffff883010b24930
[315893.403149] Call Trace:
[315893.407593]  [<ffffffff81657d87>] dump_stack+0x45/0x57
[315893.415073]  [<ffffffff8107855a>] warn_slowpath_common+0x8a/0xc0
[315893.423566]  [<ffffffff810785d6>] warn_slowpath_fmt+0x46/0x50
[315893.431717]  [<ffffffff81313c82>] __list_add+0x92/0xc0
[315893.439206]  [<ffffffffa073cba8>] nfs4_put_state_owner+0x58/0x70 [nfsv4]
[315893.448473]  [<ffffffffa073d227>] nfs4_do_reclaim+0x137/0x630 [nfsv4]
[315893.457263]  [<ffffffff810b17ff>] ? put_prev_entity+0x2f/0x490
[315893.465579]  [<ffffffff810b4bfc>] ? pick_next_task_fair+0x1ac/0x900
[315893.474197]  [<ffffffffa073dc27>] nfs4_state_manager+0x507/0x840 [nfsv4]
[315893.483514]  [<ffffffff8165ab2c>] ? __schedule+0x2dc/0x920
[315893.491450]  [<ffffffff81083ed4>] ? kernel_sigaction+0x34/0x100
[315893.499730]  [<ffffffffa073df60>] ? nfs4_state_manager+0x840/0x840 [nfsv4]
[315893.509213]  [<ffffffffa073df88>] nfs4_run_state_manager+0x28/0x40 [nfsv4]
[315893.518704]  [<ffffffff81096919>] kthread+0xc9/0xe0
[315893.525938]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315893.535007]  [<ffffffff8165f3a2>] ret_from_fork+0x42/0x70
[315893.542648]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315893.551766] ---[ end trace af6cbdf806fd8c5a ]---
[315893.558757] ------------[ cut here ]------------
[315893.564814] WARNING: CPU: 32 PID: 3056 at lib/idr.c:1051 ida_remove+0xf2/0x130()
[315893.574033] ida_remove called for id=1 which is not allocated.
[315893.581446] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill cts rpcsec_gss_krb5 nfsv4(E) dns_resolver nfs(E) fscache nf_log_ipv6 xt_multiport nf_log_ipv4 nf_log_common xt_LOG bonding ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_filter iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip6_tables ip_tables x86_pkg_temp_thermal coretemp kvm_intel nfsd kvm crct10dif_pclmul auth_rpcgss crc32_pclmul mei_me crc32c_intel ghash_clmulni_intel nfs_acl lockd aesni_intel iTCO_wdt iTCO_vendor_support lrw gf128mul glue_helper sb_edac ablk_helper edac_core cryptd mei pcspkr lpc_ich shpchp mfd_core wmi grace ipmi_si ipmi_msghandler acpi_pad sunrpc acpi_power_meter binfmt_misc xfs sd_mod fnic mgag200
[315893.666726]  syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm igb ahci libfcoe libahci ptp libfc libata enic megaraid_sas pps_core dca i2c_algo_bit scsi_transport_fc i2c_core dm_mirror dm_region_hash dm_log dm_mod
[315893.689460] CPU: 32 PID: 3056 Comm: 129.21.16.62-ma Tainted: G        W   E   4.1.6 #1
[315893.699385] Hardware name: Cisco Systems Inc UCSC-C220-M4S/UCSC-C220-M4S, BIOS C220M4.2.0.3c.0.091920141954 09/19/2014
[315893.712469]  ffffffff818c21dd ffff884809b6fc48 ffffffff81657d87 0000000000000001
[315893.721885]  ffff884809b6fc98 ffff884809b6fc88 ffffffff8107855a 0000000000000000
[315893.731284]  ffff88600d42e4d0 ffff88601030c980 ffff886008f98900 ffff88600d42e530
[315893.740668] Call Trace:
[315893.744452]  [<ffffffff81657d87>] dump_stack+0x45/0x57
[315893.751305]  [<ffffffff8107855a>] warn_slowpath_common+0x8a/0xc0
[315893.759087]  [<ffffffff810785d6>] warn_slowpath_fmt+0x46/0x50
[315893.766577]  [<ffffffff812f8862>] ida_remove+0xf2/0x130
[315893.773473]  [<ffffffffa073b909>] nfs4_remove_state_owner_locked+0x39/0x40 [nfsv4]
[315893.782980]  [<ffffffffa073cc49>] nfs4_purge_state_owners+0x89/0x100 [nfsv4]
[315893.791867]  [<ffffffffa073d151>] nfs4_do_reclaim+0x61/0x630 [nfsv4]
[315893.799956]  [<ffffffff810b17ff>] ? put_prev_entity+0x2f/0x490
[315893.807446]  [<ffffffff810b4bfc>] ? pick_next_task_fair+0x1ac/0x900
[315893.815407]  [<ffffffffa073dc27>] nfs4_state_manager+0x507/0x840 [nfsv4]
[315893.823852]  [<ffffffff8165ab2c>] ? __schedule+0x2dc/0x920
[315893.830945]  [<ffffffff81083ed4>] ? kernel_sigaction+0x34/0x100
[315893.838513]  [<ffffffffa073df60>] ? nfs4_state_manager+0x840/0x840 [nfsv4]
[315893.847156]  [<ffffffffa073df88>] nfs4_run_state_manager+0x28/0x40 [nfsv4]
[315893.855787]  [<ffffffff81096919>] kthread+0xc9/0xe0
[315893.862192]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315893.870447]  [<ffffffff8165f3a2>] ret_from_fork+0x42/0x70
[315893.877442]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315893.885696] ---[ end trace af6cbdf806fd8c5b ]---
[315893.891816] ------------[ cut here ]------------
[315893.897933] WARNING: CPU: 32 PID: 3056 at lib/list_debug.c:29 __list_add+0x6d/0xc0()
[315893.907555] list_add corruption. next->prev should be prev (ffff884809b6fd48), but was ffff886008f98908. (next=ffff886008f98908).
[315893.922460] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill cts rpcsec_gss_krb5 nfsv4(E) dns_resolver nfs(E) fscache nf_log_ipv6 xt_multiport nf_log_ipv4 nf_log_common xt_LOG bonding ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_filter iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip6_tables ip_tables x86_pkg_temp_thermal coretemp kvm_intel nfsd kvm crct10dif_pclmul auth_rpcgss crc32_pclmul mei_me crc32c_intel ghash_clmulni_intel nfs_acl lockd aesni_intel iTCO_wdt iTCO_vendor_support lrw gf128mul glue_helper sb_edac ablk_helper edac_core cryptd mei pcspkr lpc_ich shpchp mfd_core wmi grace ipmi_si ipmi_msghandler acpi_pad sunrpc acpi_power_meter binfmt_misc xfs sd_mod fnic mgag200
[315894.008262]  syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm igb ahci libfcoe libahci ptp libfc libata enic megaraid_sas pps_core dca i2c_algo_bit scsi_transport_fc i2c_core dm_mirror dm_region_hash dm_log dm_mod
[315894.031146] CPU: 32 PID: 3056 Comm: 129.21.16.62-ma Tainted: G        W   E   4.1.6 #1
[315894.041172] Hardware name: Cisco Systems Inc UCSC-C220-M4S/UCSC-C220-M4S, BIOS C220M4.2.0.3c.0.091920141954 09/19/2014
[315894.054326]  ffffffff818c31a0 ffff884809b6fc58 ffffffff81657d87 0000000000000001
[315894.063834]  ffff884809b6fca8 ffff884809b6fc98 ffffffff8107855a ffff88601030c980
[315894.073301]  ffff884809b6fd48 ffff886008f98908 ffff884809b6fd48 ffff88600d42e530
[315894.082761] Call Trace:
[315894.086616]  [<ffffffff81657d87>] dump_stack+0x45/0x57
[315894.093474]  [<ffffffff8107855a>] warn_slowpath_common+0x8a/0xc0
[315894.101279]  [<ffffffff810785d6>] warn_slowpath_fmt+0x46/0x50
[315894.108768]  [<ffffffff81313c5d>] __list_add+0x6d/0xc0
[315894.115557]  [<ffffffffa073cc41>] nfs4_purge_state_owners+0x81/0x100 [nfsv4]
[315894.124465]  [<ffffffffa073d151>] nfs4_do_reclaim+0x61/0x630 [nfsv4]
[315894.132574]  [<ffffffff810b17ff>] ? put_prev_entity+0x2f/0x490
[315894.140079]  [<ffffffff810b4bfc>] ? pick_next_task_fair+0x1ac/0x900
[315894.148079]  [<ffffffffa073dc27>] nfs4_state_manager+0x507/0x840 [nfsv4]
[315894.156559]  [<ffffffff8165ab2c>] ? __schedule+0x2dc/0x920
[315894.163678]  [<ffffffff81083ed4>] ? kernel_sigaction+0x34/0x100
[315894.171282]  [<ffffffffa073df60>] ? nfs4_state_manager+0x840/0x840 [nfsv4]
[315894.179956]  [<ffffffffa073df88>] nfs4_run_state_manager+0x28/0x40 [nfsv4]
[315894.188625]  [<ffffffff81096919>] kthread+0xc9/0xe0
[315894.195067]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315894.203353]  [<ffffffff8165f3a2>] ret_from_fork+0x42/0x70
[315894.210378]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315894.218656] ---[ end trace af6cbdf806fd8c5c ]---
[315894.224803] ------------[ cut here ]------------
[315894.230954] WARNING: CPU: 32 PID: 3056 at lib/list_debug.c:36 __list_add+0x92/0xc0()
[315894.240610] list_add double add: new=ffff884809b6fd48, prev=ffff884809b6fd48, next=ffff886008f98908.
[315894.251833] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill cts rpcsec_gss_krb5 nfsv4(E) dns_resolver nfs(E) fscache nf_log_ipv6 xt_multiport nf_log_ipv4 nf_log_common xt_LOG bonding ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_filter iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip6_tables ip_tables x86_pkg_temp_thermal coretemp kvm_intel nfsd kvm crct10dif_pclmul auth_rpcgss crc32_pclmul mei_me crc32c_intel ghash_clmulni_intel nfs_acl lockd aesni_intel iTCO_wdt iTCO_vendor_support lrw gf128mul glue_helper sb_edac ablk_helper edac_core cryptd mei pcspkr lpc_ich shpchp mfd_core wmi grace ipmi_si ipmi_msghandler acpi_pad sunrpc acpi_power_meter binfmt_misc xfs sd_mod fnic mgag200
[315894.337625]  syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm igb ahci libfcoe libahci ptp libfc libata enic megaraid_sas pps_core dca i2c_algo_bit scsi_transport_fc i2c_core dm_mirror dm_region_hash dm_log dm_mod
[315894.360522] CPU: 32 PID: 3056 Comm: 129.21.16.62-ma Tainted: G        W   E   4.1.6 #1
[315894.370566] Hardware name: Cisco Systems Inc UCSC-C220-M4S/UCSC-C220-M4S, BIOS C220M4.2.0.3c.0.091920141954 09/19/2014
[315894.383728]  ffffffff818c31a0 ffff884809b6fc58 ffffffff81657d87 0000000000000001
[315894.393241]  ffff884809b6fca8 ffff884809b6fc98 ffffffff8107855a ffff88601030c980
[315894.402734]  ffff884809b6fd48 ffff886008f98908 ffff884809b6fd48 ffff88600d42e530
[315894.412205] Call Trace:
[315894.416077]  [<ffffffff81657d87>] dump_stack+0x45/0x57
[315894.422942]  [<ffffffff8107855a>] warn_slowpath_common+0x8a/0xc0
[315894.430755]  [<ffffffff810785d6>] warn_slowpath_fmt+0x46/0x50
[315894.438250]  [<ffffffff81313c82>] __list_add+0x92/0xc0
[315894.445045]  [<ffffffffa073cc41>] nfs4_purge_state_owners+0x81/0x100 [nfsv4]
[315894.453973]  [<ffffffffa073d151>] nfs4_do_reclaim+0x61/0x630 [nfsv4]
[315894.462085]  [<ffffffff810b17ff>] ? put_prev_entity+0x2f/0x490
[315894.469583]  [<ffffffff810b4bfc>] ? pick_next_task_fair+0x1ac/0x900
[315894.477566]  [<ffffffffa073dc27>] nfs4_state_manager+0x507/0x840 [nfsv4]
[315894.486016]  [<ffffffff8165ab2c>] ? __schedule+0x2dc/0x920
[315894.493105]  [<ffffffff81083ed4>] ? kernel_sigaction+0x34/0x100
[315894.500687]  [<ffffffffa073df60>] ? nfs4_state_manager+0x840/0x840 [nfsv4]
[315894.509342]  [<ffffffffa073df88>] nfs4_run_state_manager+0x28/0x40 [nfsv4]
[315894.517991]  [<ffffffff81096919>] kthread+0xc9/0xe0
[315894.524395]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315894.532642]  [<ffffffff8165f3a2>] ret_from_fork+0x42/0x70
[315894.539635]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315894.547901] ---[ end trace af6cbdf806fd8c5d ]---
[315894.554032] BUG: unable to handle kernel paging request at 00000000d7bad7ca
[315894.562785] IP: [<ffffffff812fde16>] rb_erase+0x36/0x390
[315894.569702] PGD 0 
[315894.572923] Oops: 0000 [#1] SMP 
[315894.577504] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill cts rpcsec_gss_krb5 nfsv4(E) dns_resolver nfs(E) fscache nf_log_ipv6 xt_multiport nf_log_ipv4 nf_log_common xt_LOG bonding ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_filter iptable_filter nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip6_tables ip_tables x86_pkg_temp_thermal coretemp kvm_intel nfsd kvm crct10dif_pclmul auth_rpcgss crc32_pclmul mei_me crc32c_intel ghash_clmulni_intel nfs_acl lockd aesni_intel iTCO_wdt iTCO_vendor_support lrw gf128mul glue_helper sb_edac ablk_helper edac_core cryptd mei pcspkr lpc_ich shpchp mfd_core wmi grace ipmi_si ipmi_msghandler acpi_pad sunrpc acpi_power_meter binfmt_misc xfs sd_mod fnic mgag200
[315894.662971]  syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm igb ahci libfcoe libahci ptp libfc libata enic megaraid_sas pps_core dca i2c_algo_bit scsi_transport_fc i2c_core dm_mirror dm_region_hash dm_log dm_mod
[315894.685773] CPU: 32 PID: 3056 Comm: 129.21.16.62-ma Tainted: G        W   E   4.1.6 #1
[315894.695766] Hardware name: Cisco Systems Inc UCSC-C220-M4S/UCSC-C220-M4S, BIOS C220M4.2.0.3c.0.091920141954 09/19/2014
[315894.708878] task: ffff8844c7b443d0 ti: ffff884809b6c000 task.ti: ffff884809b6c000
[315894.718400] RIP: 0010:[<ffffffff812fde16>]  [<ffffffff812fde16>] rb_erase+0x36/0x390
[315894.728221] RSP: 0018:ffff884809b6fd08  EFLAGS: 00010202
[315894.735287] RAX: ffff8860103dd218 RBX: ffff884809b6fd40 RCX: 00000000d7bad7ba
[315894.744384] RDX: 00000000d7bad7ba RSI: ffff883010b24df8 RDI: ffff884809b6fd60
[315894.753457] RBP: ffff884809b6fd08 R08: ffff88600d42e000 R09: ffff88180f572f00
[315894.762504] R10: 00000000000026b2 R11: 0000000000000001 R12: ffff883010b24930
[315894.771536] R13: ffff884809b6fd40 R14: ffff88600d42e530 R15: ffff886008f98900
[315894.780556] FS:  0000000000000000(0000) GS:ffff88481fb80000(0000) knlGS:0000000000000000
[315894.790628] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[315894.798059] CR2: 00000000d7bad7ca CR3: 000000000197e000 CR4: 00000000001406e0
[315894.807033] Stack:
[315894.810269]  ffff884809b6fd28 ffffffffa073b8f9 ffff886008f98908 ffff884809b6fd48
[315894.819577]  ffff884809b6fd88 ffffffffa073cc49 ffff88481fb977f8 ffff883010b24930
[315894.828887]  ffff884809b6fd48 ffff884809b6fd48 ffff884809b6fd88 ffffffffa0754680
[315894.838186] Call Trace:
[315894.841910]  [<ffffffffa073b8f9>] nfs4_remove_state_owner_locked+0x29/0x40 [nfsv4]
[315894.851378]  [<ffffffffa073cc49>] nfs4_purge_state_owners+0x89/0x100 [nfsv4]
[315894.860268]  [<ffffffffa073d151>] nfs4_do_reclaim+0x61/0x630 [nfsv4]
[315894.868379]  [<ffffffff810b17ff>] ? put_prev_entity+0x2f/0x490
[315894.875911]  [<ffffffff810b4bfc>] ? pick_next_task_fair+0x1ac/0x900
[315894.883929]  [<ffffffffa073dc27>] nfs4_state_manager+0x507/0x840 [nfsv4]
[315894.892425]  [<ffffffff8165ab2c>] ? __schedule+0x2dc/0x920
[315894.899564]  [<ffffffff81083ed4>] ? kernel_sigaction+0x34/0x100
[315894.907191]  [<ffffffffa073df60>] ? nfs4_state_manager+0x840/0x840 [nfsv4]
[315894.915890]  [<ffffffffa073df88>] nfs4_run_state_manager+0x28/0x40 [nfsv4]
[315894.924579]  [<ffffffff81096919>] kthread+0xc9/0xe0
[315894.931038]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315894.939345]  [<ffffffff8165f3a2>] ret_from_fork+0x42/0x70
[315894.946384]  [<ffffffff81096850>] ? kthread_create_on_node+0x180/0x180
[315894.954688] Code: e5 48 85 c9 0f 84 e4 02 00 00 4d 85 c0 0f 84 fb 02 00 00 49 8b 50 10 4c 89 c0 48 85 d2 75 0c e9 94 02 00 00 90 48 89 d0 48 89 ca <48> 8b 4a 10 48 85 c9 75 f1 4c 8b 4a 08 49 89 d2 4c 89 48 10 4c 
[315894.978521] RIP  [<ffffffff812fde16>] rb_erase+0x36/0x390
[315894.985613]  RSP <ffff884809b6fd08>
[315894.990547] CR2: 00000000d7bad7ca


-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
