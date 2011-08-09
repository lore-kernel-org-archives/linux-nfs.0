Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:53610 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250Ab1HIWGN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Aug 2011 18:06:13 -0400
Received: from mail.virtall.com (localhost [127.0.0.1])
	by mail.virtall.com (Postfix) with ESMTP id 6CC7A367B19
	for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 00:06:11 +0200 (CEST)
Received: from [192.168.10.145] (e183095092.adsl.alicedsl.de [85.183.95.92])
	by mail.virtall.com (Postfix) with ESMTPSA id DFD58367997
	for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 00:06:09 +0200 (CEST)
Message-ID: <4E41AF51.1050502@wpkg.org>
Date: Wed, 10 Aug 2011 00:06:09 +0200
From: Tomasz Chmielewski <mangoo@wpkg.org>
To: linux-nfs@vger.kernel.org
Subject: 2.6.39.x nfs_mark_return_delegation crash
References: <4E3A5623.8090003@wpkg.org>
In-Reply-To: <4E3A5623.8090003@wpkg.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just had a server dying (had to be hard rebooted) with this found in syslog.

It is 2.6.39.3; I see it with 2.6.39.4 as well, on multiple servers.

Pasted two crashes below.


Aug  4 00:15:53 octo kernel: [104324.700338] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
Aug  4 00:15:53 octo kernel: [104324.700834] IP: [<ffffffffa053d7b9>] nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  4 00:15:53 octo kernel: [104324.706518] PGD 0 
Aug  4 00:15:53 octo kernel: [104324.706736] Oops: 0000 [#1] SMP 
Aug  4 00:15:53 octo kernel: [104324.706959] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
Aug  4 00:15:53 octo kernel: [104324.707398] CPU 4 
Aug  4 00:15:53 octo kernel: [104324.707406] Modules linked in: ip_vs_wlc ip_vs nf_conntrack drbd lru_cache nfsd fuse ipv6 nfs fscache auth_rpcgss nfs_acl lockd sunrpc 8021q xt_tcpudp iptable_filter ip_tables x_tables ext4 jbd2 crc16 dm_multipath scsi_dh video sbs sbshc battery acpi_memhotplug acpi_ipmi ipmi_msghandler ac parport_pc lp parport sg serio_raw tpm_tis tpm rtc_cmos tpm_bios rtc_core rtc_lib button i2c_i801 i2c_core ioatdma pcspkr shpchp netxen_nic 3w_9xxx qlge ixgbe dca mdio sata_nv forcedeth via686a hwmon mptctl mptsas scsi_transport_sas dm_crypt raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid0 dm_mirror sata_via sata_sis pata_sis sym53c8xx megaraid aic7xxx 3w_xxxx sky2 r8169 skge e1000e e1000 via_rhine sis900 8139too e100 mii dm_region_hash dm_log ata_piix mptspi mptscsih scsi_transport_spi mptbase ahci libahci libata sd_mod scsi_mod raid1 ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Aug  4 00:15:53 octo kernel: [104324.710582] 
Aug  4 00:15:53 octo kernel: [104324.710801] Pid: 1993, comm: kworker/4:0 Not tainted 2.6.39.3 #1 Supermicro X8DT6/X8DT6
Aug  4 00:15:53 octo kernel: [104324.711244] RIP: 0010:[<ffffffffa053d7b9>]  [<ffffffffa053d7b9>] nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  4 00:15:53 octo kernel: [104324.711701] RSP: 0018:ffff8806262d9dd0  EFLAGS: 00010246
Aug  4 00:15:53 octo kernel: [104324.711925] RAX: 0000000000000000 RBX: ffff88053e2a2e00 RCX: 0000000000000390
Aug  4 00:15:53 octo kernel: [104324.712361] RDX: ffff8803321ad808 RSI: 0000000000000286 RDI: ffff88053e2a2e00
Aug  4 00:15:53 octo kernel: [104324.712799] RBP: ffff8806262d9dd0 R08: 00000000000001f4 R09: ffff88063fc31df0
Aug  4 00:15:53 octo kernel: [104324.713232] R10: ffff8806262d9db0 R11: 0000000000000286 R12: ffff8803321ad800
Aug  4 00:15:53 octo kernel: [104324.713662] R13: ffff880331831c00 R14: ffffffffa054ab70 R15: 0000000000000000
Aug  4 00:15:53 octo kernel: [104324.714104] FS:  0000000000000000(0000) GS:ffff88063fc00000(0000) knlGS:0000000000000000
Aug  4 00:15:53 octo kernel: [104324.714539] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Aug  4 00:15:53 octo kernel: [104324.714762] CR2: 0000000000000018 CR3: 0000000001713000 CR4: 00000000000006e0
Aug  4 00:15:53 octo kernel: [104324.715198] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug  4 00:15:53 octo kernel: [104324.715630] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug  4 00:15:53 octo kernel: [104324.716063] Process kworker/4:0 (pid: 1993, threadinfo ffff8806262d8000, task ffff880622a49620)
Aug  4 00:15:53 octo kernel: [104324.716498] Stack:
Aug  4 00:15:53 octo kernel: [104324.716712]  ffff8806262d9e10 ffffffffa053de26 ffff8806262d9df0 0000000000000018
Aug  4 00:15:53 octo kernel: [104324.717155]  ffff88053e2a2e00 0000000000000000 ffff880331831d10 ffff880331831c00
Aug  4 00:15:53 octo kernel: [104324.717597]  ffff8806262d9e50 ffffffffa053d64e 00000001009eac05 0000000000002328
Aug  4 00:15:53 octo kernel: [104324.718040] Call Trace:
Aug  4 00:15:53 octo kernel: [104324.718274]  [<ffffffffa053de26>] nfs_expire_unreferenced_delegations+0x37/0x92 [nfs]
Aug  4 00:15:53 octo kernel: [104324.718722]  [<ffffffffa053d64e>] nfs4_renew_state+0x104/0x12e [nfs]
Aug  4 00:15:53 octo kernel: [104324.718951]  [<ffffffff81049b71>] process_one_work+0x19b/0x2c5
Aug  4 00:15:53 octo kernel: [104324.719190]  [<ffffffffa053d54a>] ? nfs4_schedule_state_renewal+0xc8/0xc8 [nfs]
Aug  4 00:15:53 octo kernel: [104324.719623]  [<ffffffff8104b4bb>] worker_thread+0x12e/0x20d
Aug  4 00:15:53 octo kernel: [104324.719847]  [<ffffffff8104b38d>] ? gcwq_mayday_timeout+0x67/0x67
Aug  4 00:15:53 octo kernel: [104324.720084]  [<ffffffff8104e9be>] kthread+0x81/0x89
Aug  4 00:15:53 octo kernel: [104324.720312]  [<ffffffff813f7d94>] kernel_thread_helper+0x4/0x10
Aug  4 00:15:53 octo kernel: [104324.720534]  [<ffffffff8104e93d>] ? kthread_stop+0x57/0x57
Aug  4 00:15:53 octo kernel: [104324.720756]  [<ffffffff813f7d90>] ? gs_change+0xb/0xb
Aug  4 00:15:53 octo kernel: [104324.720976] Code: 48 8d 7b 58 48 c7 c6 a2 d7 53 a0 e8 e8 a2 b3 e0 59 5b c9 c3 55 48 83 ef 58 48 89 e5 e8 6e 9a b7 e0 c9 c3 48 8b 47 18 55 48 89 e5 
Aug  4 00:15:53 octo kernel: <48>[104324.721311]  8b 40 18 48 8b 80 88 02 00 00 48 8b 00 f0 80 4f 48 02 f0 80 
Aug  4 00:15:53 octo kernel: [104324.721791] RIP  [<ffffffffa053d7b9>] nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  4 00:15:53 octo kernel: [104324.722242]  RSP <ffff8806262d9dd0>
Aug  4 00:15:53 octo kernel: [104324.722458] CR2: 0000000000000018
Aug  4 00:15:53 octo kernel: [104324.723126] ---[ end trace cbde0c25a938b281 ]---
Aug  4 00:15:53 octo kernel: [104324.723459] BUG: unable to handle kernel paging request at fffffffffffffff8
Aug  4 00:15:53 octo kernel: [104324.723891] IP: [<ffffffff8104e678>] kthread_data+0xb/0x11
Aug  4 00:15:53 octo kernel: [104324.724209] PGD 1715067 PUD 1716067 PMD 0 
Aug  4 00:15:53 octo kernel: [104324.724715] Oops: 0000 [#2] SMP 
Aug  4 00:15:53 octo kernel: [104324.725137] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
Aug  4 00:15:53 octo kernel: [104324.725616] CPU 4 
Aug  4 00:15:53 octo kernel: [104324.725667] Modules linked in: ip_vs_wlc ip_vs nf_conntrack drbd lru_cache nfsd fuse ipv6 nfs fscache auth_rpcgss nfs_acl lockd sunrpc 8021q xt_tcpudp iptable_filter ip_tables x_tables ext4 jbd2 crc16 dm_multipath scsi_dh video sbs sbshc battery acpi_memhotplug acpi_ipmi ipmi_msghandler ac parport_pc lp parport sg serio_raw tpm_tis tpm rtc_cmos tpm_bios rtc_core rtc_lib button i2c_i801 i2c_core ioatdma pcspkr shpchp netxen_nic 3w_9xxx qlge ixgbe dca mdio sata_nv forcedeth via686a hwmon mptctl mptsas scsi_transport_sas dm_crypt raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid0 dm_mirror sata_via sata_sis pata_sis sym53c8xx megaraid aic7xxx 3w_xxxx sky2 r8169 skge e1000e e1000 via_rhine sis900 8139too e100 mii dm_region_hash dm_log ata_piix mptspi mptscsih scsi_transport_spi mptbase ahci libahci libata sd_mod scsi_mod raid1 ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Aug  4 00:15:53 octo kernel: [104324.733747] 
Aug  4 00:15:53 octo kernel: [104324.734008] Pid: 1993, comm: kworker/4:0 Tainted: G      D     2.6.39.3 #1 Supermicro X8DT6/X8DT6
Aug  4 00:15:53 octo kernel: [104324.734628] RIP: 0010:[<ffffffff8104e678>]  [<ffffffff8104e678>] kthread_data+0xb/0x11
Aug  4 00:15:53 octo kernel: [104324.735154] RSP: 0018:ffff8806262d9968  EFLAGS: 00010096
Aug  4 00:15:53 octo kernel: [104324.735420] RAX: 0000000000000000 RBX: ffff880622a49620 RCX: ffff880622a49620
Aug  4 00:15:53 octo kernel: [104324.735898] RDX: 0000000000000040 RSI: 0000000000000004 RDI: ffff880622a49620
Aug  4 00:15:53 octo kernel: [104324.736378] RBP: ffff8806262d9968 R08: ffffea0004e32940 R09: ffffffff81036a4a
Aug  4 00:15:53 octo kernel: [104324.736859] R10: dead000000200200 R11: 0000000000000004 R12: 00007ffffffff000
Aug  4 00:15:53 octo kernel: [104324.737336] R13: 0000000000000004 R14: ffff88063fc11d80 R15: ffff880622a499a0
Aug  4 00:15:53 octo kernel: [104324.737813] FS:  0000000000000000(0000) GS:ffff88063fc00000(0000) knlGS:0000000000000000
Aug  4 00:15:53 octo kernel: [104324.738294] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Aug  4 00:15:53 octo kernel: [104324.738563] CR2: fffffffffffffff8 CR3: 0000000001713000 CR4: 00000000000006e0
Aug  4 00:15:53 octo kernel: [104324.739040] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug  4 00:15:53 octo kernel: [104324.739515] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug  4 00:15:53 octo kernel: [104324.739997] Process kworker/4:0 (pid: 1993, threadinfo ffff8806262d8000, task ffff880622a49620)
Aug  4 00:15:53 octo kernel: [104324.740506] Stack:
Aug  4 00:15:53 octo kernel: [104324.740767]  ffff8806262d9998 ffffffff8104b151 ffff8806262d9a18 ffff880622a49620
Aug  4 00:15:53 octo kernel: [104324.741510]  00007ffffffff000 ffff880622a49620 ffff8806262d9aa8 ffffffff813f4377
Aug  4 00:15:53 octo kernel: [104324.742183]  ffff880333004240 ffff880622a49620 ffff8806262d99d8 00000004810cd870
Aug  4 00:15:53 octo kernel: [104324.742856] Call Trace:
Aug  4 00:15:53 octo kernel: [104324.743120]  [<ffffffff8104b151>] wq_worker_sleeping+0x15/0x81
Aug  4 00:15:53 octo kernel: [104324.743396]  [<ffffffff813f4377>] schedule+0x16a/0x930
Aug  4 00:15:53 octo kernel: [104324.743668]  [<ffffffff81077a96>] ? call_rcu_sched+0x10/0x12
Aug  4 00:15:53 octo kernel: [104324.743939]  [<ffffffff8103b30b>] ? release_task+0x39f/0x3b7
Aug  4 00:15:53 octo kernel: [104324.744207]  [<ffffffff8103c500>] do_exit+0x6eb/0x705
Aug  4 00:15:53 octo kernel: [104324.744475]  [<ffffffff810051d3>] oops_end+0xb2/0xba
Aug  4 00:15:53 octo kernel: [104324.744743]  [<ffffffff810237ac>] no_context+0x1f5/0x204
Aug  4 00:15:53 octo kernel: [104324.745011]  [<ffffffff813f4dd0>] ? schedule_timeout+0x26/0x1c7
Aug  4 00:15:53 octo kernel: [104324.745279]  [<ffffffff81023936>] __bad_area_nosemaphore+0x17b/0x19e
Aug  4 00:15:53 octo kernel: [104324.745551]  [<ffffffff8102b713>] ? enqueue_task+0x5a/0x69
Aug  4 00:15:53 octo kernel: [104324.745819]  [<ffffffff810239cf>] bad_area_nosemaphore+0xe/0x10
Aug  4 00:15:53 octo kernel: [104324.746087]  [<ffffffff81023da5>] do_page_fault+0x17d/0x384
Aug  4 00:15:53 octo kernel: [104324.746356]  [<ffffffff8102c227>] ? select_idle_sibling+0x4a/0xe2
Aug  4 00:15:53 octo kernel: [104324.746685]  [<ffffffff8102c333>] ? __enqueue_entity+0x74/0x76
Aug  4 00:15:53 octo kernel: [104324.746953]  [<ffffffff810355b1>] ? enqueue_task_fair+0x205/0x21d
Aug  4 00:15:53 octo kernel: [104324.747291]  [<ffffffff813f689f>] page_fault+0x1f/0x30
Aug  4 00:15:53 octo kernel: [104324.747573]  [<ffffffffa053d7b9>] ? nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  4 00:15:53 octo kernel: [104324.748071]  [<ffffffffa053de26>] nfs_expire_unreferenced_delegations+0x37/0x92 [nfs]
Aug  4 00:15:53 octo kernel: [104324.748634]  [<ffffffffa053d64e>] nfs4_renew_state+0x104/0x12e [nfs]
Aug  4 00:15:53 octo kernel: [104324.748910]  [<ffffffff81049b71>] process_one_work+0x19b/0x2c5
Aug  4 00:15:53 octo kernel: [104324.749193]  [<ffffffffa053d54a>] ? nfs4_schedule_state_renewal+0xc8/0xc8 [nfs]
Aug  4 00:15:53 octo kernel: [104324.749675]  [<ffffffff8104b4bb>] worker_thread+0x12e/0x20d
Aug  4 00:15:53 octo kernel: [104324.749947]  [<ffffffff8104b38d>] ? gcwq_mayday_timeout+0x67/0x67
Aug  4 00:15:53 octo kernel: [104324.750233]  [<ffffffff8104e9be>] kthread+0x81/0x89
Aug  4 00:15:53 octo kernel: [104324.750563]  [<ffffffff813f7d94>] kernel_thread_helper+0x4/0x10
Aug  4 00:15:53 octo kernel: [104324.750831]  [<ffffffff8104e93d>] ? kthread_stop+0x57/0x57
Aug  4 00:15:53 octo kernel: [104324.751162]  [<ffffffff813f7d90>] ? gs_change+0xb/0xb
Aug  4 00:15:53 octo kernel: [104324.751428] Code: 5e 41 5f c9 c3 90 90 55 65 48 8b 04 25 c0 b5 00 00 48 8b 80 28 03 00 00 48 89 e5 8b 40 f0 c9 c3 48 8b 87 28 03 00 00 55 48 89 e5 
Aug  4 00:15:53 octo kernel: <48>[104324.754033]  8b 40 f8 c9 c3 48 3b 3d db f3 85 00 55 48 89 e5 75 09 0f bf 
Aug  4 00:15:53 octo kernel: [104324.755655] RIP  [<ffffffff8104e678>] kthread_data+0xb/0x11
Aug  4 00:15:53 octo kernel: [104324.755972]  RSP <ffff8806262d9968>
Aug  4 00:15:53 octo kernel: [104324.756235] CR2: fffffffffffffff8
Aug  4 00:15:53 octo kernel: [104324.756496] ---[ end trace cbde0c25a938b282 ]---
Aug  4 00:15:53 octo kernel: [104324.756762] Fixing recursive fault but reboot is needed!






Aug  9 20:56:12 brink kernel: [250089.549839] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
Aug  9 20:56:12 brink kernel: [250089.549872] IP: [<ffffffffa05447b9>] nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  9 20:56:12 brink kernel: [250089.549921] PGD 0 
Aug  9 20:56:12 brink kernel: [250089.550144] Oops: 0000 [#1] SMP 
Aug  9 20:56:12 brink kernel: [250089.550374] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
Aug  9 20:56:12 brink kernel: [250089.550815] CPU 4 
Aug  9 20:56:12 brink kernel: [250089.550822] Modules linked in: ip_vs_wlc ip_vs nf_conntrack drbd lru_cache nfsd fuse ipv6 nfs fscache auth_rpcgss nfs_acl lockd sunrpc 8021q xt_tcpudp iptable_filter ip_tables x_tables ext4 jbd2 crc16 dm_multipath scsi_dh video sbs sbshc battery acpi_memhotplug acpi_ipmi ipmi_msghandler ac parport_pc lp parport sg serio_raw rtc_cmos rtc_core tpm_tis rtc_lib tpm tpm_bios button i2c_i801 i2c_core ioatdma shpchp pcspkr netxen_nic 3w_9xxx qlge ixgbe dca mdio sata_nv forcedeth via686a hwmon mptctl mptsas scsi_transport_sas dm_crypt raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid0 dm_mirror sata_via sata_sis pata_sis sym53c8xx megaraid aic7xxx 3w_xxxx sky2 r8169 skge e1000e e1000 via_rhine sis900 8139too e100 mii dm_region_hash dm_log ata_piix mptspi mptscsih scsi_transport_spi mptbase ahci libahci libata sd_mod scsi_mod raid1 ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Aug  9 20:56:12 brink kernel: [250089.553973] 
Aug  9 20:56:12 brink kernel: [250089.554188] Pid: 9284, comm: kworker/4:1 Not tainted 2.6.39.4 #1 Supermicro X8DT6/X8DT6
Aug  9 20:56:12 brink kernel: [250089.554634] RIP: 0010:[<ffffffffa05447b9>]  [<ffffffffa05447b9>] nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  9 20:56:12 brink kernel: [250089.555094] RSP: 0000:ffff8804725e3dd0  EFLAGS: 00010246
Aug  9 20:56:12 brink kernel: [250089.555318] RAX: 0000000000000000 RBX: ffff8805ddfc6680 RCX: 0000000000000200
Aug  9 20:56:12 brink kernel: [250089.555758] RDX: ffff880330edf808 RSI: 0000000000000286 RDI: ffff8805ddfc6680
Aug  9 20:56:12 brink kernel: [250089.556194] RBP: ffff8804725e3dd0 R08: 00000000000001f4 R09: ffff88033fc11df0
Aug  9 20:56:12 brink kernel: [250089.556629] R10: ffff8804725e3db0 R11: 0000000000000286 R12: ffff880330edf800
Aug  9 20:56:12 brink kernel: [250089.557064] R13: ffff880332555000 R14: ffffffffa0551b70 R15: 0000000000000000
Aug  9 20:56:12 brink kernel: [250089.557497] FS:  0000000000000000(0000) GS:ffff88063fc00000(0000) knlGS:0000000000000000
Aug  9 20:56:12 brink kernel: [250089.557932] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Aug  9 20:56:12 brink kernel: [250089.558156] CR2: 0000000000000018 CR3: 00000001906c4000 CR4: 00000000000006e0
Aug  9 20:56:12 brink kernel: [250089.558592] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug  9 20:56:12 brink kernel: [250089.559033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug  9 20:56:12 brink kernel: [250089.559468] Process kworker/4:1 (pid: 9284, threadinfo ffff8804725e2000, task ffff88062ee71620)
Aug  9 20:56:12 brink kernel: [250089.559927] Stack:
Aug  9 20:56:12 brink kernel: [250089.560147]  ffff8804725e3e10 ffffffffa0544e26 ffff8804725e3e10 ffffffffa0544537
Aug  9 20:56:12 brink kernel: [250089.560595]  ffff8805ddfc6680 0000000000000000 ffff880332555110 ffff880332555000
Aug  9 20:56:12 brink kernel: [250089.561048]  ffff8804725e3e50 ffffffffa054464e 00000001017d1338 0000000000002328
Aug  9 20:56:12 brink kernel: [250089.561499] Call Trace:
Aug  9 20:56:12 brink kernel: [250089.561734]  [<ffffffffa0544e26>] nfs_expire_unreferenced_delegations+0x37/0x92 [nfs]
Aug  9 20:56:12 brink kernel: [250089.562188]  [<ffffffffa0544537>] ? nfs4_schedule_state_renewal+0xb5/0xc8 [nfs]
Aug  9 20:56:12 brink kernel: [250089.562645]  [<ffffffffa054464e>] nfs4_renew_state+0x104/0x12e [nfs]
Aug  9 20:56:12 brink kernel: [250089.562879]  [<ffffffff81049b71>] process_one_work+0x19b/0x2c5
Aug  9 20:56:12 brink kernel: [250089.563119]  [<ffffffffa054454a>] ? nfs4_schedule_state_renewal+0xc8/0xc8 [nfs]
Aug  9 20:56:12 brink kernel: [250089.563563]  [<ffffffff8104b4bb>] worker_thread+0x12e/0x20d
Aug  9 20:56:12 brink kernel: [250089.563791]  [<ffffffff8104b38d>] ? gcwq_mayday_timeout+0x67/0x67
Aug  9 20:56:12 brink kernel: [250089.564020]  [<ffffffff8104e9be>] kthread+0x81/0x89
Aug  9 20:56:12 brink kernel: [250089.564249]  [<ffffffff813f7e54>] kernel_thread_helper+0x4/0x10
Aug  9 20:56:12 brink kernel: [250089.564477]  [<ffffffff8104e93d>] ? kthread_stop+0x57/0x57
Aug  9 20:56:12 brink kernel: [250089.564704]  [<ffffffff813f7e50>] ? gs_change+0xb/0xb
Aug  9 20:56:12 brink kernel: [250089.564927] Code: 48 8d 7b 58 48 c7 c6 a2 47 54 a0 e8 e8 32 b3 e0 59 5b c9 c3 55 48 83 ef 58 48 89 e5 e8 da 2a b7 e0 c9 c3 48 8b 47 18 55 48 89 e5 
Aug  9 20:56:12 brink kernel: <48>[250089.565265]  8b 40 18 48 8b 80 88 02 00 00 48 8b 00 f0 80 4f 48 02 f0 80 
Aug  9 20:56:12 brink kernel: [250089.570988] RIP  [<ffffffffa05447b9>] nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  9 20:56:12 brink kernel: [250089.571439]  RSP <ffff8804725e3dd0>
Aug  9 20:56:12 brink kernel: [250089.571655] CR2: 0000000000000018
Aug  9 20:56:12 brink kernel: [250089.572470] ---[ end trace 8a87366e64b6d806 ]---
Aug  9 20:56:12 brink kernel: [250089.572792] BUG: unable to handle kernel paging request at fffffffffffffff8
Aug  9 20:56:12 brink kernel: [250089.573319] IP: [<ffffffff8104e678>] kthread_data+0xb/0x11
Aug  9 20:56:12 brink kernel: [250089.573808] PGD 1715067 PUD 1716067 PMD 0 
Aug  9 20:56:12 brink kernel: [250089.574216] Oops: 0000 [#2] SMP 
Aug  9 20:56:12 brink kernel: [250089.574577] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
Aug  9 20:56:12 brink kernel: [250089.575061] CPU 4 
Aug  9 20:56:12 brink kernel: [250089.575113] Modules linked in: ip_vs_wlc ip_vs nf_conntrack drbd lru_cache nfsd fuse ipv6 nfs fscache auth_rpcgss nfs_acl lockd sunrpc 8021q xt_tcpudp iptable_filter ip_tables x_tables ext4 jbd2 crc16 dm_multipath scsi_dh video sbs sbshc battery acpi_memhotplug acpi_ipmi ipmi_msghandler ac parport_pc lp parport sg serio_raw rtc_cmos rtc_core tpm_tis rtc_lib tpm tpm_bios button i2c_i801 i2c_core ioatdma shpchp pcspkr netxen_nic 3w_9xxx qlge ixgbe dca mdio sata_nv forcedeth via686a hwmon mptctl mptsas scsi_transport_sas dm_crypt raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid0 dm_mirror sata_via sata_sis pata_sis sym53c8xx megaraid aic7xxx 3w_xxxx sky2 r8169 skge e1000e e1000 via_rhine sis900 8139too e100 mii dm_region_hash dm_log ata_piix mptspi mptscsih scsi_transport_spi mptbase ahci libahci libata sd_mod scsi_mod raid1 ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Aug  9 20:56:12 brink kernel: [250089.583304] 
Aug  9 20:56:12 brink kernel: [250089.583570] Pid: 9284, comm: kworker/4:1 Tainted: G      D     2.6.39.4 #1 Supermicro X8DT6/X8DT6
Aug  9 20:56:12 brink kernel: [250089.584196] RIP: 0010:[<ffffffff8104e678>]  [<ffffffff8104e678>] kthread_data+0xb/0x11
Aug  9 20:56:12 brink kernel: [250089.584731] RSP: 0000:ffff8804725e3968  EFLAGS: 00010096
Aug  9 20:56:12 brink kernel: [250089.585049] RAX: 0000000000000000 RBX: ffff88062ee71620 RCX: ffff88062ee71620
Aug  9 20:56:12 brink kernel: [250089.585577] RDX: 0000000000000040 RSI: 0000000000000004 RDI: ffff88062ee71620
Aug  9 20:56:12 brink kernel: [250089.586062] RBP: ffff8804725e3968 R08: ffffea000b0937c0 R09: ffffffff81036a4a
Aug  9 20:56:12 brink kernel: [250089.586577] R10: dead000000200200 R11: 0000000000000004 R12: 00007ffffffff000
Aug  9 20:56:12 brink kernel: [250089.587062] R13: 0000000000000004 R14: ffff88063fc11d80 R15: ffff88062ee719a0
Aug  9 20:56:12 brink kernel: [250089.587586] FS:  0000000000000000(0000) GS:ffff88063fc00000(0000) knlGS:0000000000000000
Aug  9 20:56:12 brink kernel: [250089.588071] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Aug  9 20:56:12 brink kernel: [250089.588345] CR2: fffffffffffffff8 CR3: 00000001906c4000 CR4: 00000000000006e0
Aug  9 20:56:12 brink kernel: [250089.588889] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug  9 20:56:12 brink kernel: [250089.589437] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug  9 20:56:12 brink kernel: [250089.589978] Process kworker/4:1 (pid: 9284, threadinfo ffff8804725e2000, task ffff88062ee71620)
Aug  9 20:56:12 brink kernel: [250089.590514] Stack:
Aug  9 20:56:12 brink kernel: [250089.590780]  ffff8804725e3998 ffffffff8104b151 ffff8804725e3a18 ffff88062ee71620
Aug  9 20:56:12 brink kernel: [250089.591565]  00007ffffffff000 ffff88062ee71620 ffff8804725e3aa8 ffffffff813f4427
Aug  9 20:56:12 brink kernel: [250089.592286]  ffff880633004240 ffff88062ee71620 ffff8804725e39d8 00000004810cd8dc
Aug  9 20:56:12 brink kernel: [250089.593011] Call Trace:
Aug  9 20:56:12 brink kernel: [250089.593328]  [<ffffffff8104b151>] wq_worker_sleeping+0x15/0x81
Aug  9 20:56:12 brink kernel: [250089.593607]  [<ffffffff813f4427>] schedule+0x16a/0x930
Aug  9 20:56:12 brink kernel: [250089.593943]  [<ffffffff81077a96>] ? call_rcu_sched+0x10/0x12
Aug  9 20:56:12 brink kernel: [250089.594217]  [<ffffffff8103b30b>] ? release_task+0x39f/0x3b7
Aug  9 20:56:12 brink kernel: [250089.594489]  [<ffffffff8103c500>] do_exit+0x6eb/0x705
Aug  9 20:56:12 brink kernel: [250089.594759]  [<ffffffff810051d3>] oops_end+0xb2/0xba
Aug  9 20:56:12 brink kernel: [250089.595031]  [<ffffffff810237ac>] no_context+0x1f5/0x204
Aug  9 20:56:12 brink kernel: [250089.595303]  [<ffffffff813f4e80>] ? schedule_timeout+0x26/0x1c7
Aug  9 20:56:12 brink kernel: [250089.595713]  [<ffffffff81023936>] __bad_area_nosemaphore+0x17b/0x19e
Aug  9 20:56:12 brink kernel: [250089.595987]  [<ffffffff8102b713>] ? enqueue_task+0x5a/0x69
Aug  9 20:56:12 brink kernel: [250089.596257]  [<ffffffff810239cf>] bad_area_nosemaphore+0xe/0x10
Aug  9 20:56:12 brink kernel: [250089.596527]  [<ffffffff81023da5>] do_page_fault+0x17d/0x384
Aug  9 20:56:12 brink kernel: [250089.596796]  [<ffffffff8102c227>] ? select_idle_sibling+0x4a/0xe2
Aug  9 20:56:12 brink kernel: [250089.597112]  [<ffffffff8102c333>] ? __enqueue_entity+0x74/0x76
Aug  9 20:56:12 brink kernel: [250089.597382]  [<ffffffff813f674e>] ? common_interrupt+0xe/0x13
Aug  9 20:56:12 brink kernel: [250089.597723]  [<ffffffff813f695f>] page_fault+0x1f/0x30
Aug  9 20:56:12 brink kernel: [250089.598017]  [<ffffffffa05447b9>] ? nfs_mark_return_delegation+0x8/0x25 [nfs]
Aug  9 20:56:12 brink kernel: [250089.598555]  [<ffffffffa0544e26>] nfs_expire_unreferenced_delegations+0x37/0x92 [nfs]
Aug  9 20:56:12 brink kernel: [250089.599053]  [<ffffffffa0544537>] ? nfs4_schedule_state_renewal+0xb5/0xc8 [nfs]
Aug  9 20:56:12 brink kernel: [250089.599588]  [<ffffffffa054464e>] nfs4_renew_state+0x104/0x12e [nfs]
Aug  9 20:56:12 brink kernel: [250089.599864]  [<ffffffff81049b71>] process_one_work+0x19b/0x2c5
Aug  9 20:56:12 brink kernel: [250089.600195]  [<ffffffffa054454a>] ? nfs4_schedule_state_renewal+0xc8/0xc8 [nfs]
Aug  9 20:56:12 brink kernel: [250089.600678]  [<ffffffff8104b4bb>] worker_thread+0x12e/0x20d
Aug  9 20:56:12 brink kernel: [250089.600948]  [<ffffffff8104b38d>] ? gcwq_mayday_timeout+0x67/0x67
Aug  9 20:56:12 brink kernel: [250089.601264]  [<ffffffff8104e9be>] kthread+0x81/0x89
Aug  9 20:56:12 brink kernel: [250089.601534]  [<ffffffff813f7e54>] kernel_thread_helper+0x4/0x10
Aug  9 20:56:12 brink kernel: [250089.601846]  [<ffffffff8104e93d>] ? kthread_stop+0x57/0x57
Aug  9 20:56:12 brink kernel: [250089.602156]  [<ffffffff813f7e50>] ? gs_change+0xb/0xb
Aug  9 20:56:12 brink kernel: [250089.602422] Code: 5e 41 5f c9 c3 90 90 55 65 48 8b 04 25 c0 b5 00 00 48 8b 80 28 03 00 00 48 89 e5 8b 40 f0 c9 c3 48 8b 87 28 03 00 00 55 48 89 e5 
Aug  9 20:56:12 brink kernel: <48>[250089.604943]  8b 40 f8 c9 c3 48 3b 3d db f3 85 00 55 48 89 e5 75 09 0f bf 
Aug  9 20:56:12 brink kernel: [250089.606625] RIP  [<ffffffff8104e678>] kthread_data+0xb/0x11
Aug  9 20:56:12 brink kernel: [250089.606945]  RSP <ffff8804725e3968>
Aug  9 20:56:12 brink kernel: [250089.607210] CR2: fffffffffffffff8
Aug  9 20:56:12 brink kernel: [250089.607474] ---[ end trace 8a87366e64b6d807 ]---
Aug  9 20:56:12 brink kernel: [250089.607741] Fixing recursive fault but reboot is needed!
Aug  9 20:57:01 brink kernel: [250146.856954] irq 75: nobody cared (try booting with the "irqpoll" option)
Aug  9 20:57:01 brink kernel: [250146.857229] Pid: 0, comm: swapper Tainted: G      D     2.6.39.4 #1
Aug  9 20:57:01 brink kernel: [250146.857497] Call Trace:
Aug  9 20:57:01 brink kernel: [250146.857757]  <IRQ>  [<ffffffff8107507b>] __report_bad_irq+0x43/0xac
Aug  9 20:57:01 brink kernel: [250146.858079]  [<ffffffff81075251>] note_interrupt+0x16d/0x1ba
Aug  9 20:57:01 brink kernel: [250146.858347]  [<ffffffff81073958>] handle_irq_event_percpu+0x110/0x127
Aug  9 20:57:01 brink kernel: [250146.858618]  [<ffffffff810739a3>] handle_irq_event+0x34/0x51
Aug  9 20:57:01 brink kernel: [250146.858887]  [<ffffffff810757cd>] handle_edge_irq+0xcb/0xe0
Aug  9 20:57:01 brink kernel: [250146.859157]  [<ffffffff81003fff>] handle_irq+0x1f/0x2a
Aug  9 20:57:01 brink kernel: [250146.859424]  [<ffffffff81003689>] do_IRQ+0x4b/0xb2
Aug  9 20:57:01 brink kernel: [250146.859693]  [<ffffffff813f6753>] common_interrupt+0x13/0x13
Aug  9 20:57:01 brink kernel: [250146.859960]  <EOI>  [<ffffffff8133f15b>] ? poll_idle+0x1f/0x60
Aug  9 20:57:01 brink kernel: [250146.860278]  [<ffffffff8133f14a>] ? poll_idle+0xe/0x60
Aug  9 20:57:01 brink kernel: [250146.860545]  [<ffffffff8133f327>] cpuidle_idle_call+0x8e/0xc7
Aug  9 20:57:01 brink kernel: [250146.860814]  [<ffffffff81001aa7>] cpu_idle+0x52/0x77
Aug  9 20:57:01 brink kernel: [250146.861079]  [<ffffffff813e11a9>] rest_init+0x6d/0x6f
Aug  9 20:57:01 brink kernel: [250146.861344]  [<ffffffff81795bf8>] start_kernel+0x344/0x350
Aug  9 20:57:01 brink kernel: [250146.861618]  [<ffffffff817952aa>] x86_64_start_reservations+0xba/0xbe
Aug  9 20:57:01 brink kernel: [250146.861891]  [<ffffffff8179539d>] x86_64_start_kernel+0xef/0xf6
Aug  9 20:57:01 brink kernel: [250146.862161] handlers:
Aug  9 20:57:01 brink kernel: [250146.862425] [<ffffffffa01960f8>] (e1000_msix_other+0x0/0xc5 [e1000e])
Aug  9 20:57:01 brink kernel: [250146.862814] Disabling IRQ #75


-- 
Tomasz Chmielewski
http://wpkg.org

