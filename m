From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Kernel call trace on NFS-mount (using autofs).
Date: Tue, 20 May 2008 20:55:42 +0200
Message-ID: <48331EAE.6060107@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:43928 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756123AbYETS4F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 14:56:05 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by shrek.krogh.cc (Postfix) with ESMTP id 14BB23BF2F1
	for <linux-nfs@vger.kernel.org>; Tue, 20 May 2008 20:56:03 +0200 (CEST)
Received: from shrek.krogh.cc ([127.0.0.1])
	by localhost (shrek.krogh.cc [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cr2CaYP7I7ZP for <linux-nfs@vger.kernel.org>;
	Tue, 20 May 2008 20:55:48 +0200 (CEST)
Received: from [192.168.1.5] (unknown [90.184.13.46])
	by shrek.krogh.cc (Postfix) with ESMTP id D40E73BF2BE
	for <linux-nfs@vger.kernel.org>; Tue, 20 May 2008 20:55:48 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. I'm seeing this every now and then. (not directly reproduceable).

May 20 13:58:33 node36 kernel: [1291441.355677] PGD 6b195067 PUD 
a7751067 PMD 0
May 20 13:58:33 node36 kernel: [1291441.448833] CPU 0
May 20 13:58:33 node36 kernel: [1291441.475005] Modules linked in: nfs 
lockd sunrpc autofs4 ipv6 usbhid hid uhci_hcd ehci_hcd usbkbd fuse 
parport_pc lp parport af_packet i2c_amd756 i2c_core pcspkr psmouse 
k8temp amd_rng serio_raw shpchp pci_hotplug evdev ext3 jbd mbcache sg 
sd_mod ide_cd cdrom ata_generic libata floppy mptspi mptscsih mptbase 
scsi_transport_spi scsi_mod tg3 ohci_hcd amd74xx ide_core usbcore 
thermal processor fan capability commoncap
May 20 13:58:33 node36 kernel: [1291441.920746] Pid: 1080, comm: 
mount.nfs Not tainted 2.6.22-14-generic #1
May 20 13:58:33 node36 kernel: [1291442.001856] RIP: 
0010:[graft_tree+76/304]  [graft_tree+76/304] graft_tree+0x4c/0x130
May 20 13:58:33 node36 kernel: [1291442.098650] RSP: 
0018:ffff8100856b3c48  EFLAGS: 00010246
May 20 13:58:33 node36 kernel: [1291442.164181] RAX: ffff8100ce0e41a0 
RBX: 00000000ffffffec RCX: 0000000000000000
May 20 13:58:33 node36 kernel: [1291442.251524] RDX: ffff8100ba66f100 
RSI: ffff8100856b3e58 RDI: ffff8100a7c63600
May 20 13:58:33 node36 kernel: [1291442.338866] RBP: ffff8100a7c63600 
R08: 0000000000000000 R09: ffff81005ad02980
May 20 13:58:33 node36 kernel: [1291442.426210] R10: 000000001685c20a 
R11: 0000000000000006 R12: ffff8100856b3e58
May 20 13:58:33 node36 kernel: [1291442.513551] R13: 0000000000000000 
R14: 000000000000000b R15: 000000000000000b
May 20 13:58:33 node36 kernel: [1291442.600894] FS: 
00002b12c126d6e0(0000) GS:ffffffff80561000(0000) knlGS:00000000f7da76b0
May 20 13:58:33 node36 kernel: [1291442.699656] CS:  0010 DS: 0000 ES: 
0000 CR0: 000000008005003b
May 20 13:58:33 node36 kernel: [1291442.770380] CR2: 00000000000000b2 
CR3: 000000002ade7000 CR4: 00000000000006e0
May 20 13:58:33 node36 kernel: [1291442.857723] Process mount.nfs (pid: 
1080, threadinfo ffff8100856b2000, task ffff8100bcba14a0)
May 20 13:58:33 node36 kernel: [1291442.961678] Stack:  ffff8100856b3e58 
ffff8100856b3e60 ffff8100a7c63600 ffffffff802b1fa0
May 20 13:58:33 node36 kernel: [1291443.059926]  0000000000000006 
ffffffffa7c63600 ffff810030d78000 ffff810059996000
May 20 13:58:33 node36 kernel: [1291443.150800]  ffff81007b39e000 
ffffffff802b3271 0000000000000010 0000000000000000
May 20 13:58:33 node36 kernel: [1291443.239489] Call Trace:
May 20 13:58:33 node36 kernel: [1291443.272934]  [do_add_mount+160/352] 
do_add_mount+0xa0/0x160
May 20 13:58:33 node36 kernel: [1291443.339502]  [do_mount+1329/2000] 
do_mount+0x531/0x7d0
May 20 13:58:33 node36 kernel: [1291443.402957] 
[__handle_mm_fault+1985/2912] __handle_mm_fault+0x7c1/0xb60
May 20 13:58:33 node36 kernel: [1291443.475761] 
[autoremove_wake_function+0/48] autoremove_wake_function+0x0/0x30
May 20 13:58:33 node36 kernel: [1291443.552711]  [__up_read+33/176] 
__up_read+0x21/0xb0
May 20 13:58:33 node36 kernel: [1291443.615125] 
[do_page_fault+971/2160] do_page_fault+0x3cb/0x870
May 20 13:58:33 node36 kernel: [1291443.683776] 
[zone_statistics+125/128] zone_statistics+0x7d/0x80
May 20 13:58:33 node36 kernel: [1291443.752425]  [error_exit+0/132] 
error_exit+0x0/0x84
May 20 13:58:33 node36 kernel: [1291443.814842] 
[copy_mount_options+273/384] copy_mount_options+0x111/0x180
May 20 13:58:33 node36 kernel: [1291443.888680]  [sys_mount+155/256] 
sys_mount+0x9b/0x100
May 20 13:58:33 node36 kernel: [1291443.952136]  [system_call+126/131] 
system_call+0x7e/0x83
May 20 13:58:33 node36 kernel: [1291444.016629]
May 20 13:58:33 node36 kernel: [1291444.036459]
May 20 13:58:33 node36 kernel: [1291444.036460] Code: 0f b7 81 b2 00 00 
00 25 00 f0 00 00 3d 00 40 00 00 48 8b 47
May 20 13:58:33 node36 kernel: [1291444.215606]  RSP <ffff8100856b3c48>


It does get triggered by some application using the automounter (autofs)
that then does the mount.nfs call.

Kernel is a: 2.6.22-14-generic. I wasn't able to search similar stuff
up from the archive.

Jesper

-- 
Jesper
