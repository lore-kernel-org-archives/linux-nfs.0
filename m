Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:50083 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752484Ab1GIKoM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jul 2011 06:44:12 -0400
From: =?iso-8859-1?q?R=FCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: kernel BUG at linux-2.6.37/fs/nfsd/nfs4state.c:391
Date: Sat, 9 Jul 2011 12:44:06 +0200
Content-Type: text/plain;
  charset="us-ascii"
Message-Id: <201107091244.08597.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Today I've got the following trace on opensuse 11.4 nfs server.
Clients are hanging now. I couldn't manage to kill/restart nfsd yet.
Probably I have to reboot.


Jul  9 05:00:39 glaukos kernel: [3225065.434416] ------------[ cut here ]------------
Jul  9 05:00:39 glaukos kernel: [3225065.434429] kernel BUG at /usr/src/packages/BUILD/kernel-desktop-2.6.37.6/linux-2.6.37/fs/nfsd/nfs4state.c:391!
Jul  9 05:00:39 glaukos kernel: [3225065.434439] invalid opcode: 0000 [#1] PREEMPT SMP
Jul  9 05:00:39 glaukos kernel: [3225065.434448] last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
Jul  9 05:00:39 glaukos kernel: [3225065.434456] CPU 0
Jul  9 05:00:39 glaukos kernel: [3225065.434459] Modules linked in: microcode raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx md5 
nfsd lockd nfs_acl auth_rpcgss sunrpc w83793 hwmon_vid coretemp edd cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf xfs exportfs 
radeon ttm drm_kms_helper drm i3200_edac e1000e ses enclosure iTCO_wdt edac_core i2c_algo_bit i2c_i801 iTCO_vendor_support shpchp sg pci_hotplug sr_mod cdrom 
pcspkr ghes serio_raw hed video container button ext4 jbd2 crc16 linear dm_snapshot dm_mod fan processor thermal thermal_sys aacraid
Jul  9 05:00:39 glaukos kernel: [3225065.434545]
Jul  9 05:00:39 glaukos kernel: [3225065.434551] Pid: 10526, comm: nfsd Not tainted 2.6.37.6-0.5-desktop #1 Supermicro X7SB4/E/X7SB4/E
Jul  9 05:00:39 glaukos kernel: [3225065.434564] RIP: 0010:[<ffffffffa04ee3b2>]  [<ffffffffa04ee3b2>] nfs4_access_to_omode+0x12/0x40 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.434588] RSP: 0018:ffff88003c755b98  EFLAGS: 00010297
Jul  9 05:00:39 glaukos kernel: [3225065.434595] RAX: 0000000000000004 RBX: ffff8800490aebf0 RCX: ffff88003c755b90
Jul  9 05:00:39 glaukos kernel: [3225065.434602] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
Jul  9 05:00:39 glaukos kernel: [3225065.434610] RBP: ffff8800071b20d8 R08: dead000000100100 R09: dead000000200200
Jul  9 05:00:39 glaukos kernel: [3225065.434617] R10: dead000000100100 R11: dead000000200200 R12: ffff8800071b2110
Jul  9 05:00:39 glaukos kernel: [3225065.434625] R13: ffff8800071b20d8 R14: ffff88001eb0aa58 R15: 0000000000000000
Jul  9 05:00:39 glaukos kernel: [3225065.434633] FS:  0000000000000000(0000) GS:ffff8800cfc00000(0000) knlGS:0000000000000000
Jul  9 05:00:39 glaukos kernel: [3225065.434642] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Jul  9 05:00:39 glaukos kernel: [3225065.434649] CR2: 00007f0173626000 CR3: 0000000225588000 CR4: 00000000000006f0
Jul  9 05:00:39 glaukos kernel: [3225065.434657] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jul  9 05:00:39 glaukos kernel: [3225065.434664] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jul  9 05:00:39 glaukos kernel: [3225065.434672] Process nfsd (pid: 10526, threadinfo ffff88003c754000, task ffff8802241b2400)
Jul  9 05:00:39 glaukos kernel: [3225065.434679] Stack:
Jul  9 05:00:39 glaukos kernel: [3225065.434684]  ffffffffa04ef2e0 ffff88001eb0aa58 00000000071b20d8 ffff8800a3ea2dd0
Jul  9 05:00:39 glaukos kernel: [3225065.434696]  ffff8800490aebf0 ffff8800071b20d8 ffffffffa04ef421 ffff8800071b20d8
Jul  9 05:00:39 glaukos kernel: [3225065.434707]  000000001d270000 ffff8802249fd040 ffffffffa04ef4f9 ffff8802257ce1a0
Jul  9 05:00:39 glaukos kernel: [3225065.434718] Call Trace:
Jul  9 05:00:39 glaukos kernel: [3225065.434786]  [<ffffffffa04ef2e0>] free_generic_stateid+0x20/0xb0 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.434850]  [<ffffffffa04ef421>] unhash_lockowner+0xb1/0x180 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.434914]  [<ffffffffa04ef4f9>] release_lockowner+0x9/0x20 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.434977]  [<ffffffffa04f4618>] nfsd4_lock+0x258/0x5e0 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.435045]  [<ffffffffa04e3ca1>] nfsd4_proc_compound+0x3f1/0x4d0 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.435095]  [<ffffffffa04d198d>] nfsd_dispatch+0xfd/0x240 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.435122]  [<ffffffffa0487184>] svc_process_common+0x344/0x680 [sunrpc]
Jul  9 05:00:39 glaukos kernel: [3225065.435169]  [<ffffffffa04875ce>] svc_process+0x10e/0x150 [sunrpc]
Jul  9 05:00:39 glaukos kernel: [3225065.435210]  [<ffffffffa04d10e2>] nfsd+0xb2/0x150 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.435224]  [<ffffffff81079ad6>] kthread+0x96/0xa0
Jul  9 05:00:39 glaukos kernel: [3225065.435238]  [<ffffffff81003d74>] kernel_thread_helper+0x4/0x10
Jul  9 05:00:39 glaukos kernel: [3225065.435247] Code: 03 e1 eb 97 83 eb 01 75 d9 31 c0 eb a2 66 66 66 2e 0f 1f 84 00 00 00 00 00 83 e7 03 83 ff 02 74 28 83 ff 03 
74 13 83 ff 01 74 06 <0f> 0b 0f 1f 40 00 31 c0 c3 0f 1f 44 00 00 b8 02 00 00 00 c3 66
Jul  9 05:00:39 glaukos kernel: [3225065.435302] RIP  [<ffffffffa04ee3b2>] nfs4_access_to_omode+0x12/0x40 [nfsd]
Jul  9 05:00:39 glaukos kernel: [3225065.435320]  RSP <ffff88003c755b98>
Jul  9 05:00:39 glaukos kernel: [3225065.534070] ---[ end trace a6e93c30dd913031 ]---

Jul  9 05:16:14 glaukos sm-notify[10529]: Unable to notify chantico.ga.local, giving up
Jul  9 05:16:14 glaukos sm-notify[10529]: Unable to notify otto.ga.local, giving up
Jul  9 05:16:14 glaukos sm-notify[10529]: Unable to notify quant.ga.local, giving up
Jul  9 05:16:14 glaukos sm-notify[10529]: Unable to notify clyde.ga.local, giving up


cu,
Rudi
