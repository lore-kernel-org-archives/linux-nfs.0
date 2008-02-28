From: David Warren <warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Subject: 2.6.24.3 crashes
Date: Thu, 28 Feb 2008 14:33:30 -0800
Message-ID: <47C736BA.2060805@atmos.washington.edu>
Reply-To: warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:25114 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759178AbYB1Wde (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2008 17:33:34 -0500
Received: by wf-out-1314.google.com with SMTP id 28so3470677wff.4
        for <linux-nfs@vger.kernel.org>; Thu, 28 Feb 2008 14:33:33 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

yesterday I built and installed 2.6.24.3 and now I am getting general 
protection faults with this showing up in the logs (cpus 2 - 7 give 
similar dumps following):
Feb 28 13:55:34 enkf1 kernel: CPU 0
Feb 28 13:55:34 enkf1 kernel: Modules linked in: nfs nfsd lockd nfs_acl 
auth_rpc
gss sunrpc exportfs autofs4 ac battery ipv6 qla2xxx dm_snapshot 
dm_mirror dm_mod
 ioatdma dca ide_generic ide_disk ide_cd cdrom ide_core i2c_i801 
container parpo
rt_pc i2c_core button floppy parport psmouse evdev serio_raw pcspkr 
shpchp pci_h
otplug xfs firmware_class scsi_transport_fc e1000 sd_mod thermal 
processor fan a
ta_piix libata scsi_mod
Feb 28 13:55:34 enkf1 kernel: Pid: 261, comm: kswapd0 Not tainted 
2.6.24.3 #1
Feb 28 13:55:34 enkf1 kernel: RIP: 0010:[<ffffffff8028358e>]  
[<ffffffff8028358e
 >] iput+0x27/0x7b
Feb 28 13:55:34 enkf1 kernel: RSP: 0000:ffff81032e66ddb0  EFLAGS: 00010206
Feb 28 13:55:34 enkf1 kernel: RAX: 0020103e00044039 RBX: 
ffff810218051d70 RCX: f
fff810218032cb0
Feb 28 13:55:34 enkf1 kernel: RDX: ffffffff8834efc0 RSI: 
ffff810218051c98 RDI: f
fff810218051d70
Feb 28 13:55:34 enkf1 kernel: RBP: ffff810218051cb0 R08: 
0000000000000000 R09: f
fff81032e66ddc0
Feb 28 13:55:34 enkf1 kernel: R10: ffff81032e66ddc0 R11: 
0000000000000001 R12: f
fff810218051d70
Feb 28 13:55:34 enkf1 kernel: R13: ffff810218051ca0 R14: 
000000000000007f R15: 0
000000000000580
Feb 28 13:55:34 enkf1 kernel: FS:  0000000000000000(0000) 
GS:ffffffff804ab000(00
00) knlGS:0000000000000000
Feb 28 13:55:34 enkf1 kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 
000000008005003b
Feb 28 13:55:34 enkf1 kernel: CR2: 00002b78e29c6000 CR3: 
0000000029cc0000 CR4: 0
0000000000006e0
Feb 28 13:55:34 enkf1 kernel: DR0: 0000000000000000 DR1: 
0000000000000000 DR2: 0
000000000000000
Feb 28 13:55:34 enkf1 kernel: DR3: 0000000000000000 DR6: 
00000000ffff0ff0 DR7: 0
000000000000400
Feb 28 13:55:34 enkf1 kernel: Process kswapd0 (pid: 261, threadinfo 
ffff81032e66
c000, task ffff81032ff52850)
Feb 28 13:55:34 enkf1 kernel: Stack:  ffff810218051bc8 ffffffff883145d9 
ffff8102
572eb7d8 ffff8102572eb7d8
Feb 28 13:55:34 enkf1 kernel:  ffffffff8834f540 00000000000010cc 
000000000000008
0 00000000000000d0
Feb 28 13:55:34 enkf1 kernel:  0000000000000064 ffffffff8025c544 
000000000026658
8 ffffffff80485d40
Feb 28 13:55:34 enkf1 kernel: Call Trace:
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff883145d9>] 
:nfs:nfs_access_cache_shrink
er+0x12d/0x1c5
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8025c544>] shrink_slab+0xe2/0x15a
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8025c962>] kswapd+0x320/0x42b
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff803c8006>] thread_return+0x3d/0xab
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8023c270>] 
autoremove_wake_function+0x0
/0x2e
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8025c642>] kswapd+0x0/0x42b
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8023c15e>] kthread+0x47/0x75
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8020c3b8>] child_rip+0xa/0x12
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8023c117>] kthread+0x0/0x75
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8020c3ae>] child_rip+0x0/0x12
Feb 28 13:55:34 enkf1 kernel:
Feb 28 13:55:34 enkf1 kernel:
Feb 28 13:55:34 enkf1 kernel: Code: 48 8b 40 28 48 85 c0 74 02 ff d0 48 
8d 7b 48
 48 c7 c6 60 95
Feb 28 13:55:34 enkf1 kernel:  RSP <ffff81032e66ddb0>
Feb 28 13:55:34 enkf1 kernel: ---[ end trace 47ea6c3d1720e062 ]---
Feb 28 13:55:34 enkf1 kernel: CPU 0
Feb 28 13:55:34 enkf1 kernel: Modules linked in: nfs nfsd lockd nfs_acl 
auth_rpc
gss sunrpc exportfs autofs4 ac battery ipv6 qla2xxx dm_snapshot 
dm_mirror dm_mod
 ioatdma dca ide_generic ide_disk ide_cd cdrom ide_core i2c_i801 
container parpo
rt_pc i2c_core button floppy parport psmouse evdev serio_raw pcspkr 
shpchp pci_h
otplug xfs firmware_class scsi_transport_fc e1000 sd_mod thermal 
processor fan a
ta_piix libata scsi_mod
Feb 28 13:55:34 enkf1 kernel: Pid: 31386, comm: wrf.exe Tainted: G      
D 2.6.24
.3 #1
Feb 28 13:55:34 enkf1 kernel: RIP: 0010:[<ffffffff8028358e>]  
[<ffffffff8028358e
 >] iput+0x27/0x7b
Feb 28 13:55:34 enkf1 kernel: RSP: 0000:ffff810029cbfc88  EFLAGS: 00010206
Feb 28 13:55:34 enkf1 kernel: RAX: 0020103e00044039 RBX: 
ffff810218032d70 RCX: f
fff81021802f500
Feb 28 13:55:34 enkf1 kernel: RDX: ffffffff8834efc0 RSI: 
ffff810218032c98 RDI: f
fff810218032d70
Feb 28 13:55:34 enkf1 kernel: RBP: ffff810218032cb0 R08: 
0000000000000000 R09: f
fff810029cbfc98
Feb 28 13:55:34 enkf1 kernel: R10: ffff810029cbfc98 R11: 
ffffffff802185fe R12: f
fff810218032d70
Feb 28 13:55:34 enkf1 kernel: R13: ffff810218032ca0 R14: 
000000000000007f R15: 0
000000000000600
Feb 28 13:55:34 enkf1 kernel: FS:  00002b78d30f86d0(0000) 
GS:ffffffff804ab000(00
00) knlGS:0000000000000000
Feb 28 13:55:34 enkf1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
Feb 28 13:55:34 enkf1 kernel: CR2: 00000000065f4000 CR3: 
0000000029cc0000 CR4: 0
0000000000006e0
Feb 28 13:55:34 enkf1 kernel: DR0: 0000000000000000 DR1: 
0000000000000000 DR2: 0
000000000000000
Feb 28 13:55:34 enkf1 kernel: DR3: 0000000000000000 DR6: 
00000000ffff0ff0 DR7: 0
000000000000400
Feb 28 13:55:34 enkf1 kernel: Process wrf.exe (pid: 31386, threadinfo 
ffff810029
cbe000, task ffff8100bbb22100)
Feb 28 13:55:34 enkf1 kernel: Stack:  ffff810218032bc8 ffffffff883145d9 
ffff8103
2a008b98 ffff81032a008b98
Feb 28 13:55:34 enkf1 kernel:  ffffffff8834f540 00000000000010cc 
000000000000008
0 00000000001280d2
Feb 28 13:55:34 enkf1 kernel:  0000000000000064 ffffffff8025c544 
0000000000266c8
9 0000000000000000
Feb 28 13:55:34 enkf1 kernel: Call Trace:
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff883145d9>] 
:nfs:nfs_access_cache_shrink
er+0x12d/0x1c5
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8025c544>] shrink_slab+0xe2/0x15a
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8025ceae>] 
try_to_free_pages+0x172/0x24
4
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff802580f8>] 
__alloc_pages+0x1af/0x2ee
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff802606a8>] 
handle_mm_fault+0x227/0x6b2
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff8021a7e9>] 
do_page_fault+0x308/0x68f
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff80264702>] do_brk+0x1d6/0x288
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff802d736b>] __up_write+0x21/0x10e
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff802d736b>] __up_write+0x21/0x10e
Feb 28 13:55:34 enkf1 kernel:  [<ffffffff803c95d9>] error_exit+0x0/0x51
Feb 28 13:55:34 enkf1 kernel:
Feb 28 13:55:34 enkf1 kernel:
Feb 28 13:55:34 enkf1 kernel: Code: 48 8b 40 28 48 85 c0 74 02 ff d0 48 
8d 7b 48
 48 c7 c6 60 95
Feb 28 13:55:34 enkf1 kernel:  RSP <ffff810029cbfc88>
Feb 28 13:55:34 enkf1 kernel: ---[ end trace 47ea6c3d1720e062 ]---

