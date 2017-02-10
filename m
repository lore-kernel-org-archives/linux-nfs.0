Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mxin.vub.ac.be ([134.184.129.114]:46771 "EHLO mxin.vub.ac.be"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751652AbdBJKuG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Feb 2017 05:50:06 -0500
Message-ID: <1486723236.15809.44.camel@ai.vub.ac.be>
Subject: cachefs: kernel BUG at fs/cachefiles/namei.c:197
From: Frederik Himpe <fhimpe@ai.vub.ac.be>
To: linux-cachefs@redhat.com,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Date: Fri, 10 Feb 2017 11:40:36 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I encountered this bug on a Debian Stretch system with an NFS 4 mount
and cachefilesd 0.10.9. NFS 4 file systems are mounted like this from
fstab:

master.cluster.ai:/home	/home	nfs4	_netdev,fsc,noatime,vers=4.2,nodev,nosuid	0	0
master.cluster.ai:/cluster	/srv/cluster	nfs4	_netdev,fsc,noatime,vers=4.2,nodev,nosuid	0	0

cachefilesd.conf contains this:

dir /var/cache/fscache
tag mycache
brun 10%
bcull 7%
bstop 3%
frun 10%
fcull 7%
fstop 3%
secctx system_u:system_r:cachefiles_kernel_t:s0


[2967555.161617] CacheFiles: 
[2967555.161652] CacheFiles: Error: Unexpected object collision
[2967555.161712] CacheFiles: object: OBJ35e9f
[2967555.161744] CacheFiles: objstate=LOOK_UP_OBJECT fl=8 wbusy=2 ev=0[0]
[2967555.161790] CacheFiles: ops=0 inp=0 exc=0
[2967555.161821] CacheFiles: parent=ffff93a412926900
[2967555.161856] CacheFiles: cookie=ffff93aa080e53c0 [pr=ffff93a5327ce870 nd=ffff93acaa1be810 fl=27]
[2967555.161918] CacheFiles: key=[32] '010006812fb038644d2346408da129441408b285fb15aa4600000000676141aa'
[2967555.162076] CacheFiles: xobject: OBJ35e39
[2967555.162108] CacheFiles: xobjstate=WAIT_FOR_CMD fl=38 wbusy=1 ev=40[6d]
[2967555.162156] CacheFiles: xops=0 inp=0 exc=0
[2967555.162188] CacheFiles: xparent=ffff93a412926900
[2967555.162225] CacheFiles: xcookie=ffff939ae8a6cbe0 [pr=ffff93a5327ce870 nd=          (null) fl=18]
[2967555.162325] ------------[ cut here ]------------
[2967555.162361] kernel BUG at /build/linux-zDY19G/linux-4.8.15/fs/cachefiles/namei.c:197!
[2967555.162416] invalid opcode: 0000 [#1] SMP
[2967555.162446] Modules linked in: bluetooth(E) rfkill(E) crc16(E) msr(E) rpcsec_gss_krb5(E) auth_rpcgss(E) nfsv4(E) dns_resolver(E) nfs(E) lockd(E) grace(E) sunrpc(E) 8021q(E) garp(E) mrp(E) stp(E) llc(E) cachefiles(E) fscache(E) xt_multiport(E) iptable_filter(E) dm_mod(E) binfmt_misc cpuid cpufreq_userspace cpufreq_powersave cpufreq_conservative intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp mgag200 kvm_intel kvm ipmi_devintf irqbypass ttm drm_kms_helper drm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt i2c_algo_bit iTCO_vendor_support pcspkr evdev dcdbas sg ipmi_si ipmi_msghandler tpm_tis ioatdma wmi mei_me mei lpc_ich mfd_core tpm_tis_core tpm shpchp acpi_power_meter dca acpi_pad button psmouse ip_tables x_tables autofs4 xfs libcrc32c btrfs crc32c_generic xor raid6_pq hid_generic usbhid hid sd_mod crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd ahci xhci_pci libahci xhci_hcd ehci_pci libata megaraid_sas ehci_hcd t!
 g3 usbcor
 e ptp scsi_mod pps_core libphy usb_common fjes
[2967555.163363] CPU: 29 PID: 206756 Comm: kworker/u578:0 Tainted: G            E   4.8.0-2-amd64 #1 Debian 4.8.11-1
[2967555.163432] Hardware name: Dell Inc. PowerEdge R430/03XKDV, BIOS 1.2.6 06/08/2015
[2967555.163496] Workqueue: fscache_object fscache_object_work_func [fscache]
[2967555.163546] task: ffff93aa2dec9000 task.stack: ffff93b18f1bc000
[2967555.163590] RIP: 0010:[<ffffffffc06d62a3>]  [<ffffffffc06d62a3>] cachefiles_walk_to_object+0x7a3/0x800 [cachefiles]
[2967555.163668] RSP: 0018:ffff93b18f1bfd18  EFLAGS: 00010286
[2967555.163708] RAX: 0000000000000000 RBX: ffff93ad450b9000 RCX: ffff93a86aec0600
[2967555.163776] RDX: 0000000000000005 RSI: ffff93a7eaec0600 RDI: 0000000000000286
[2967555.163828] RBP: ffff93b530706f00 R08: 0000000000000000 R09: 0000000000000000
[2967555.163882] R10: 000000000001e818 R11: 0000000000000001 R12: ffff939e213fbba8
[2967555.163935] R13: ffff939e213fba80 R14: ffff93a5320cd400 R15: ffff939eaa822240
[2967555.163988] FS:  0000000000000000(0000) GS:ffff93b53d580000(0000) knlGS:0000000000000000
[2967555.164048] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[2967555.164092] CR2: 00007f0a61ce1024 CR3: 00000018a020c000 CR4: 00000000001406e0
[2967555.164145] Stack:
[2967555.164165]  ffff93a5320cd520 ffff93ad450b9110 ffff93a7baecf000 ffff93aa2dec9000
[2967555.164230]  ffff93b18f1bfd80 ffff93b18f1bfd98 ffffffffaceadda8 00000000342c372c
[2967555.164297]  ffff93b5301187e0 0000000000000246 0000000000000003 ffff93a3efcf5080
[2967555.164363] Call Trace:
[2967555.164391]  [<ffffffffaceadda8>] ? set_next_entity+0xa8/0x430
[2967555.164439]  [<ffffffffc06d49a7>] ? cachefiles_lookup_object+0x47/0xe0 [cachefiles]
[2967555.164501]  [<ffffffffc03e6de0>] ? fscache_look_up_object+0xa0/0x1b0 [fscache]
[2967555.164559]  [<ffffffffc03e722a>] ? fscache_object_work_func+0x9a/0x1f0 [fscache]
[2967555.164617]  [<fffffffface94e00>] ? process_one_work+0x160/0x410
[2967555.164664]  [<fffffffface950fd>] ? worker_thread+0x4d/0x480
[2967555.164708]  [<fffffffface950b0>] ? process_one_work+0x410/0x410
[2967555.164755]  [<fffffffface9aecd>] ? kthread+0xcd/0xf0
[2967555.164814]  [<ffffffffad3efcaf>] ? ret_from_fork+0x1f/0x40
[2967555.164857]  [<fffffffface9ae00>] ? kthread_create_on_node+0x190/0x190
[2967555.164903] Code: ec 0f 0b e8 40 5c 7a ec 48 c7 c7 91 95 6d c0 e8 e2 46 8a ec 48 c7 c7 80 a2 6d c0 e8 d6 46 8a ec 4c 89 ee 48 89 df e8 25 28 00 00 <0f> 0b 48 c7 c7 91 95 6d c0 e8 bd 46 8a ec 48 c7 c7 b8 a2 6d c0 
[2967555.165258] RIP  [<ffffffffc06d62a3>] cachefiles_walk_to_object+0x7a3/0x800 [cachefiles]
[2967555.165321]  RSP <ffff93b18f1bfd18>
[2967555.180113] ---[ end trace 80e48067b39ab6d6 ]---
[2967555.237997] general protection fault: 0000 [#2] SMP
[2967555.238051] Modules linked in: bluetooth(E) rfkill(E) crc16(E) msr(E) rpcsec_gss_krb5(E) auth_rpcgss(E) nfsv4(E) dns_resolver(E) nfs(E) lockd(E) grace(E) sunrpc(E) 8021q(E) garp(E) mrp(E) stp(E) llc(E) cachefiles(E) fscache(E) xt_multiport(E) iptable_filter(E) dm_mod(E) binfmt_misc cpuid cpufreq_userspace cpufreq_powersave cpufreq_conservative intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp mgag200 kvm_intel kvm ipmi_devintf irqbypass ttm drm_kms_helper drm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt i2c_algo_bit iTCO_vendor_support pcspkr evdev dcdbas sg ipmi_si ipmi_msghandler tpm_tis ioatdma wmi mei_me mei lpc_ich mfd_core tpm_tis_core tpm shpchp acpi_power_meter dca acpi_pad button psmouse ip_tables x_tables autofs4 xfs libcrc32c btrfs crc32c_generic xor raid6_pq hid_generic usbhid hid sd_mod crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd ahci xhci_pci libahci xhci_hcd ehci_pci libata megaraid_sas ehci_hcd t!
 g3 usbcor
 e ptp scsi_mod pps_core libphy usb_common fjes
[2967555.238927] CPU: 7 PID: 206756 Comm: kworker/u578:0 Tainted: G      D     E   4.8.0-2-amd64 #1 Debian 4.8.11-1
[2967555.242057] Hardware name: Dell Inc. PowerEdge R430/03XKDV, BIOS 1.2.6 06/08/2015
[2967555.245234] task: ffff93aa2dec9000 task.stack: ffff93b18f1bc000
[2967555.248355] RIP: 0010:[<ffffffffacec48d4>]  [<ffffffffacec48d4>] native_queued_spin_lock_slowpath+0x104/0x190
[2967555.251582] RSP: 0018:ffff93b18f1bfe90  EFLAGS: 00010006
[2967555.254722] RAX: 000000000000234b RBX: 0000000000000282 RCX: ffff93b53d2d8cc0
[2967555.257977] RDX: 6f401c6375a7cadd RSI: 000000008d336c48 RDI: ffff93b18f1bff18
[2967555.261143] RBP: ffff93b18f1bff10 R08: 0000000000200000 R09: 0000000000000000
[2967555.264385] R10: 00000000ffffffff R11: 00000000000077ef R12: 0000000000000000
[2967555.267573] R13: ffffffffad5e44c6 R14: 0000000000000001 R15: ffff939eaa822240
[2967555.270821] FS:  0000000000000000(0000) GS:ffff93b53d2c0000(0000) knlGS:0000000000000000
[2967555.274001] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[2967555.277227] CR2: 0000000000000028 CR3: 0000001b4f406000 CR4: 00000000001406e0
[2967555.280393] Stack:
[2967555.283582]  ffffffffad3ef9f2 ffff93b18f1bff18 ffffffffacebd288 ffff93aa2dec9728
[2967555.286844]  ffff93aa2dec9000 0000000000000000 fffffffface79680 ffff93aa2dec9000
[2967555.290123]  000000000000000b fffffffface7fbcb 35343438342c382c 000000006c8b5600
[2967555.293326] Call Trace:
[2967555.296561]  [<ffffffffad3ef9f2>] ? _raw_spin_lock_irqsave+0x32/0x39
[2967555.299748]  [<ffffffffacebd288>] ? complete+0x18/0x40
[2967555.302937]  [<fffffffface79680>] ? mm_release+0xb0/0x130
[2967555.305953]  [<fffffffface7fbcb>] ? do_exit+0x14b/0xb30
[2967555.308945]  [<ffffffffad3f1257>] ? rewind_stack_do_exit+0x17/0x20
[2967555.311780]  [<fffffffface9ae00>] ? kthread_create_on_node+0x190/0x190
[2967555.314604] Code: c1 e0 10 45 31 c9 85 c0 74 44 48 89 c2 c1 e8 12 48 c1 ea 0c 83 e8 01 83 e2 30 48 98 48 81 c2 c0 8c 01 00 48 03 14 c5 c0 7c 91 ad <48> 89 0a 8b 41 08 85 c0 75 09 f3 90 8b 41 08 85 c0 74 f7 4c 8b 
[2967555.320446] RIP  [<ffffffffacec48d4>] native_queued_spin_lock_slowpath+0x104/0x190
[2967555.323333]  RSP <ffff93b18f1bfe90>
[2967555.326195] ---[ end trace 80e48067b39ab6d7 ]---
[2967555.389315] Fixing recursive fault but reboot is needed!
[2967555.389413] BUG: unable to handle kernel paging request at ffffffffffffffd8
[2967555.389436] IP: [<fffffffface9b53c>] kthread_data+0xc/0x20
[2967555.389438] PGD 1b4f409067 PUD 1b4f40b067 PMD 0 
[2967555.389445] Oops: 0000 [#3] SMP
[2967555.389531] Modules linked in: bluetooth(E) rfkill(E) crc16(E) msr(E) rpcsec_gss_krb5(E) auth_rpcgss(E) nfsv4(E) dns_resolver(E) nfs(E) lockd(E) grace(E) sunrpc(E) 8021q(E) garp(E) mrp(E) stp(E) llc(E) cachefiles(E) fscache(E) xt_multiport(E) iptable_filter(E) dm_mod(E) binfmt_misc cpuid cpufreq_userspace cpufreq_powersave cpufreq_conservative intel_rapl sb_edac edac_core x86_pkg_temp_thermal coretemp mgag200 kvm_intel kvm ipmi_devintf irqbypass ttm drm_kms_helper drm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel iTCO_wdt i2c_algo_bit iTCO_vendor_support pcspkr evdev dcdbas sg ipmi_si ipmi_msghandler tpm_tis ioatdma wmi mei_me mei lpc_ich mfd_core tpm_tis_core tpm shpchp acpi_power_meter dca acpi_pad button psmouse ip_tables x_tables autofs4 xfs libcrc32c btrfs crc32c_generic xor raid6_pq hid_generic usbhid hid sd_mod crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd ahci xhci_pci libahci xhci_hcd ehci_pci libata megaraid_sas ehci_hcd t!
 g3 usbcor
 e ptp scsi_mod pps_core libphy usb_common fjes
[2967555.389558] CPU: 7 PID: 206756 Comm: kworker/u578:0 Tainted: G      D     E   4.8.0-2-amd64 #1 Debian 4.8.11-1
[2967555.389559] Hardware name: Dell Inc. PowerEdge R430/03XKDV, BIOS 1.2.6 06/08/2015
[2967555.389599] task: ffff93aa2dec9000 task.stack: ffff93b18f1bc000
[2967555.389612] RIP: 0010:[<fffffffface9b53c>]  [<fffffffface9b53c>] kthread_data+0xc/0x20
[2967555.389613] RSP: 0018:ffff93b18f1bfe70  EFLAGS: 00010002
[2967555.389614] RAX: 0000000000000000 RBX: ffff93b53d2d8180 RCX: 0000000000000007
[2967555.389615] RDX: ffff93a53d406000 RSI: ffff93aa2dec9080 RDI: ffff93aa2dec9000
[2967555.389615] RBP: ffff93aa2dec9000 R08: ffff93aa2dec90a8 R09: 0000000000000001
[2967555.389616] R10: 0000000000000010 R11: ffff93aa2dec9080 R12: 0000000000018180
[2967555.389618] R13: 0000000000000000 R14: ffff93aa2dec95d0 R15: ffff93b53d2d8180
[2967555.389622] FS:  0000000000000000(0000) GS:ffff93b53d2c0000(0000) knlGS:0000000000000000
[2967555.389626] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[2967555.389627] CR2: 0000000000000028 CR3: 0000001b4f406000 CR4: 00000000001406e0
[2967555.389630] Stack:
[2967555.389635]  fffffffface9600a ffffffffad3eb423 ffff93b18f1bfee0 ffff93b18f1bfe98
[2967555.389640]  000000008d336c48 ffff93b18f1c0000 000000000000000b ffff93b18f1bfde8
[2967555.389645]  ffffffffad5e44c6 0000000000000001 ffff939eaa822240 ffffffffad3eb6d1
[2967555.389645] Call Trace:
[2967555.389648]  [<fffffffface9600a>] ? wq_worker_sleeping+0xa/0x80
[2967555.389656]  [<ffffffffad3eb423>] ? __schedule+0x4e3/0x760
[2967555.389664]  [<ffffffffad3eb6d1>] ? schedule+0x31/0x80
[2967555.389670]  [<fffffffface80397>] ? do_exit+0x917/0xb30
[2967555.389684]  [<ffffffffad3f1257>] ? rewind_stack_do_exit+0x17/0x20
[2967555.389689]  [<fffffffface9ae00>] ? kthread_create_on_node+0x190/0x190
[2967555.389711] Code: 00 00 48 c7 c7 08 96 5e ad e8 61 0d fe ff e9 ad fe ff ff 66 90 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 8b 87 70 05 00 00 <48> 8b 40 d8 c3 0f 1f 44 00 00 66 2e 0f 1f 84 00 00 00 00 00 0f 
[2967555.389714] RIP  [<fffffffface9b53c>] kthread_data+0xc/0x20
[2967555.389715]  RSP <ffff93b18f1bfe70>
[2967555.389716] CR2: ffffffffffffffd8
[2967555.389718] ---[ end trace 80e48067b39ab6d8 ]---
[2967555.451116] Fixing recursive fault but reboot is needed!

-- 
Frederik Himpe <fhimpe@ai.vub.ac.be>
