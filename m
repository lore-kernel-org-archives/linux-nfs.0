Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:65082 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752909AbbG0PU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 11:20:29 -0400
From: Andrew W Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Subject: list_del corruption / unhash_ol_stateid()
Date: Mon, 27 Jul 2015 11:13:48 -0400
Message-ID: <m23809zl8z.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


We've seen this a few times now. This will eventually crash.

This is 4.1.3

I'm still trying to get more information.

Any ideas/things to try?

Thanks,

Andy

[16562.212036] ------------[ cut here ]------------
[16562.217481] WARNING: CPU: 46 PID: 32242 at lib/list_debug.c:53 __list_del_entry+0x63/0xd0()
[16562.227126] list_del corruption, ffff8814774ff2b0->next is LIST_POISON1 (dead000000100100)
[16562.236637] Modules linked in: gfs2 dlm sctp drbd lru_cache cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp l
ibiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conn
track_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables dm_multipath x86_pkg_temp_thermal coretemp kvm_intel kvm nfsd ipmi_devintf
crct10dif_pclmul iTCO_wdt crc32_pclmul crc32c_intel iTCO_vendor_support ghash_clmulni_intel auth_rpcgss lpc_ich aesni_intel ipmi_si lrw gf128
mul glue_helper ablk_helper ipmi_msghandler cryptd mfd_core nfs_acl dcdbas wmi acpi_pad mei_me sb_edac mei edac_core pcspkr shpchp lockd acpi
_power_meter grace sunrpc binfmt_misc xfs mgag200 syscopyarea sr_mod sysfillrect sysimgblt cdrom i2c_algo_bit
[16562.319032]  sd_mod drm_kms_helper ttm ixgbe drm ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_h
ash dm_log dm_mod
[16562.334398] CPU: 46 PID: 32242 Comm: nfsd Tainted: G        W       4.1.3 #1
[16562.342844] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.4.3 07/09/2014
[16562.351830]  0000000000000000 000000003f77bdfd ffff881f419afba8 ffffffff81683d19
[16562.360778]  0000000000000000 ffff881f419afc00 ffff881f419afbe8 ffffffff8107d15a
[16562.369715]  ffff881f419afbc8 ffff8814774ff2b0 ffff8814777b4c64 ffff881f419afcd8
[16562.378659] Call Trace:
[16562.382054]  [<ffffffff81683d19>] dump_stack+0x45/0x57
[16562.388472]  [<ffffffff8107d15a>] warn_slowpath_common+0x8a/0xc0
[16562.395895]  [<ffffffff8107d1e5>] warn_slowpath_fmt+0x55/0x70
[16562.403045]  [<ffffffff8132a983>] __list_del_entry+0x63/0xd0
[16562.410065]  [<ffffffff8132aa01>] list_del+0x11/0x40
[16562.416403]  [<ffffffffa060eaa8>] unhash_ol_stateid+0x28/0x40 [nfsd]
[16562.424245]  [<ffffffffa061660d>] nfsd4_close+0xdd/0x2c0 [nfsd]
[16562.431642]  [<ffffffffa0604147>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[16562.439897]  [<ffffffffa05efff3>] nfsd_dispatch+0xc3/0x210 [nfsd]
[16562.447534]  [<ffffffffa019d483>] svc_process_common+0x453/0x6f0 [sunrpc]
[16562.455915]  [<ffffffffa019d833>] svc_process+0x113/0x1b0 [sunrpc]
[16562.463613]  [<ffffffffa05ef9ff>] nfsd+0xff/0x170 [nfsd]
[16562.470356]  [<ffffffffa05ef900>] ? nfsd_destroy+0x80/0x80 [nfsd]
[16562.477987]  [<ffffffff8109c8d8>] kthread+0xd8/0xf0
[16562.484254]  [<ffffffff8109c800>] ? kthread_create_on_node+0x1b0/0x1b0
[16562.492412]  [<ffffffff8168b7a2>] ret_from_fork+0x42/0x70
[16562.499294]  [<ffffffff8109c800>] ? kthread_create_on_node+0x1b0/0x1b0
[16562.507488] ---[ end trace cc575d5b980d16bb ]---
[16562.513551] ------------[ cut here ]------------

This was preceded by:

[12492.267703] ------------[ cut here ]------------
[12492.273425] WARNING: CPU: 0 PID: 32238 at fs/nfsd/nfs4state.c:3937 nfsd4_process_open2+0x120d/0x1230 [nfsd]()
[12492.285010] Modules linked in: gfs2 dlm sctp drbd lru_cache cts rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_service_time iscsi_tcp l
ibiscsi_tcp libiscsi scsi_transport_iscsi 8021q garp mrp stp llc bonding nf_log_ipv4 nf_log_common xt_LOG xt_conntrack iptable_filter nf_conn
track_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables dm_multipath x86_pkg_temp_thermal coretemp kvm_intel kvm nfsd ipmi_devintf
crct10dif_pclmul iTCO_wdt crc32_pclmul crc32c_intel iTCO_vendor_support ghash_clmulni_intel auth_rpcgss lpc_ich aesni_intel ipmi_si lrw gf128
mul glue_helper ablk_helper ipmi_msghandler cryptd mfd_core nfs_acl dcdbas wmi acpi_pad mei_me sb_edac mei edac_core pcspkr shpchp lockd acpi
_power_meter grace sunrpc binfmt_misc xfs mgag200 syscopyarea sr_mod sysfillrect sysimgblt cdrom i2c_algo_bit
[12492.368457]  sd_mod drm_kms_helper ttm ixgbe drm ahci tg3 mdio libahci dca ptp libata megaraid_sas i2c_core pps_core dm_mirror dm_region_h
ash dm_log dm_mod
[12492.383931] CPU: 0 PID: 32238 Comm: nfsd Not tainted 4.1.3 #1
[12492.391019] Hardware name: Dell Inc. PowerEdge R720/0X3D66, BIOS 2.4.3 07/09/2014
[12492.400011]  0000000000000000 000000001d7c2753 ffff881f47d5fbb8 ffffffff81683d19
[12492.408969]  0000000000000000 0000000000000000 ffff881f47d5fbf8 ffffffff8107d15a
[12492.417973]  ffff881f3f151dc0 ffff881f36d303e0 ffff881f3f151dc0 ffff881f42393398
[12492.426916] Call Trace:
[12492.430380]  [<ffffffff81683d19>] dump_stack+0x45/0x57
[12492.436857]  [<ffffffff8107d15a>] warn_slowpath_common+0x8a/0xc0
[12492.444343]  [<ffffffff8107d28a>] warn_slowpath_null+0x1a/0x20
[12492.451615]  [<ffffffffa06150fd>] nfsd4_process_open2+0x120d/0x1230 [nfsd]
[12492.460049]  [<ffffffffa0603972>] nfsd4_open+0x532/0x830 [nfsd]
[12492.467366]  [<ffffffffa0604147>] nfsd4_proc_compound+0x4d7/0x7e0 [nfsd]
[12492.475664]  [<ffffffffa05efff3>] nfsd_dispatch+0xc3/0x210 [nfsd]
[12492.483169]  [<ffffffffa019d483>] svc_process_common+0x453/0x6f0 [sunrpc]
[12492.491520]  [<ffffffffa019d833>] svc_process+0x113/0x1b0 [sunrpc]
[12492.499232]  [<ffffffffa05ef9ff>] nfsd+0xff/0x170 [nfsd]
[12492.505932]  [<ffffffffa05ef900>] ? nfsd_destroy+0x80/0x80 [nfsd]
[12492.513494]  [<ffffffff8109c8d8>] kthread+0xd8/0xf0
[12492.519728]  [<ffffffff8109c800>] ? kthread_create_on_node+0x1b0/0x1b0
[12492.527791]  [<ffffffff8168b7a2>] ret_from_fork+0x42/0x70
[12492.534535]  [<ffffffff8109c800>] ? kthread_create_on_node+0x1b0/0x1b0
[12492.542504] ---[ end trace cc575d5b980d16ba ]---


-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
