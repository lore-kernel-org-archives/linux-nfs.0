Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-2.desy.de ([131.169.56.85]:36560 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab0KIOOE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Nov 2010 09:14:04 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id 1FFE6D4C
	for <linux-nfs@vger.kernel.org>; Tue,  9 Nov 2010 14:44:02 +0100 (MET)
Received: from adserv71.win.desy.de (adserv71.win.desy.de [131.169.97.57])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 10177D4A
	for <linux-nfs@vger.kernel.org>; Tue,  9 Nov 2010 14:44:01 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by adserv71.win.desy.de
 (Clearswift SMTPRS 5.3.4) with ESMTP id <T993d80b6cc83a96139140@adserv71.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Tue, 9 Nov 2010 14:44:01 +0100
Received: from [131.169.185.68] (anahit.desy.de [131.169.185.68])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id D13083E901
	for <linux-nfs@vger.kernel.org>; Tue,  9 Nov 2010 14:43:57 +0100 (MET)
Message-ID: <4CD95DB5.2030006@desy.de>
Date: Tue, 09 Nov 2010 15:41:57 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: kernel panic with 2.6.37-rc1 +pnfs
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



pnfs-all-2.6.37-rc1-2010-11-03 from Banny's tree (git 
6a1df873544d146fcdc493034b170879985909e8)
I am not sure that this is NFS code issue, but anyway. With NFS IO  
minutes machine becomes unresponcive.
This prevents us to update our cluster with latest code base.

Tigran.

[  293.145013] general protection fault: 0000 [#1] SMP
[  293.145017] last sysfs file: 
/sys/devices/pci0000:00/0000:00:0d.0/resource
[  293.145019] CPU 0
[  293.145021] Modules linked in: ipv6 af_packet binfmt_misc dm_mirror 
dm_multipath scsi_dh video output thermal sbs sbshc pci_slot fan 
container battery lp sg option usb_wwan ac usbserial button thermal_sys 
parport_pc serio_raw parport tpm_tis tpm tpm_bios e1000 i2c_piix4 
pata_mpiix dm_region_hash dm_log dm_mod [last unloaded: mperf]
[  293.145042]
[  293.145045] Pid: 1953, comm: sadc Not tainted 2.6.37-rc1.pnfs.1 #1 
/VirtualBox
[  293.145047] RIP: 0010:[<ffffffff811a2cfa>]  [<ffffffff811a2cfa>] 
strnlen+0xa/0x30
[  293.145054] RSP: 0018:ffff88002d4cfcd0  EFLAGS: 00010297
[  293.145056] RAX: ffffffff814d5cfa RBX: ffffffffffffffff RCX: 
ffffffffffffffff
[  293.145058] RDX: fffffffffffffffe RSI: ffffffffffffffff RDI: 
9a81ffffffff814d
[  293.145060] RBP: 9a81ffffffff814d R08: 0000000000000000 R09: 
ffffffff8165c4a8
[  293.145062] R10: 00007f73dd7243fb R11: 0000000000000246 R12: 
0000000000000000
[  293.145064] R13: ffff88002d47d000 R14: ffff88002d47c000 R15: 
00000000ffffffff
[  293.145071] FS:  00007f73dd70b6e0(0000) GS:ffff88003fc00000(0000) 
knlGS:0000000000000000
[  293.145074] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  293.145076] CR2: 00007f73dd724000 CR3: 000000002d4a6000 CR4: 
00000000000006f0
[  293.145083] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[  293.145085] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  293.145088] Process sadc (pid: 1953, threadinfo ffff88002d4ce000, 
task ffff88003d5a51f0)
[  293.145091] Stack:
[  293.145093]  ffffffff811a46bc ffff88002d41e840 ffffffff814d98f9 
0000000000000002
[  293.145096]  ffff88002d47c000 ffff88002d4cfd78 ffff88002d47d000 
ffffffff814d98fb
[  293.145100]  ffffffff811a5488 0000000000001000 ffff88002d47c000 
ffffffffff0a0004
[  293.145104] Call Trace:
[  293.145107]  [<ffffffff811a46bc>] ? string+0x4c/0x100
[  293.145110]  [<ffffffff811a5488>] ? vsnprintf+0x218/0x560
[  293.145114]  [<ffffffff810efac7>] ? seq_printf+0x67/0xa0
[  293.145118]  [<ffffffff81043d32>] ? get_online_cpus+0x22/0x50
[  293.145121]  [<ffffffff81043d82>] ? put_online_cpus+0x22/0x70
[  293.145125]  [<ffffffff810ac71f>] ? vmstat_start+0x7f/0xa0
[  293.145128]  [<ffffffff810abeb3>] ? vmstat_show+0x23/0x30
[  293.145130]  [<ffffffff810eff2f>] ? seq_read+0xaf/0x3a0
[  293.145134]  [<ffffffff8111e223>] ? proc_reg_read+0x73/0xb0
[  293.145138]  [<ffffffff810d43ed>] ? vfs_read+0xcd/0x170
[  293.145141]  [<ffffffff810d4633>] ? sys_read+0x53/0x90
[  293.145144]  [<ffffffff81002c6b>] ? system_call_fastpath+0x16/0x1b
[  293.145146] Code: 01 e8 38 10 74 0b 48 83 e8 01 48 39 c5 76 f3 31 c0 
5b 5d c3 66 0f 1f 44 00 00 0f 1f 80 00 00 00 00 48 8d 56 ff 48 83 fa ff 
74 21 <80> 3f 00 74 1c 48 89 f8 eb 05 80 38 00 74 0e 48 83 ea 01 48 83
[  293.145171] RIP  [<ffffffff811a2cfa>] strnlen+0xa/0x30
[  293.145174]  RSP <ffff88002d4cfcd0>
[  293.145177] ---[ end trace 63b42edd98a8dea9 ]---

