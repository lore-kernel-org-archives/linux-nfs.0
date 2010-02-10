From: Marvin <marvin24@gmx.de>
Subject: fscache releated bug
Date: Wed, 10 Feb 2010 14:33:40 +0100
Message-ID: <201002101433.41006.marvin24@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, linux-cachefs@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout.uni-giessen.de ([134.176.2.3]:56154 "EHLO
	merkurneu.hrz.uni-giessen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750868Ab0BJNd6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2010 08:33:58 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

I constantly getting these with current master:

------------[ cut here ]------------                                                                   
kernel BUG at fs/nfs/fscache.c:360!                                                                    
invalid opcode: 0000 [#1] SMP                                                                          
last sysfs file: /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map                              
CPU 0                                                                                                  
Pid: 35, comm: kswapd0 Not tainted 2.6.33-rc7-00064-gac73fdd-dirty #4 GA-MA69VM-
S2/GA-MA69VM-S2        
RIP: 0010:[<ffffffffa03c20cb>]  [<ffffffffa03c20cb>] 
nfs_fscache_release_page+0xab/0xb0 [nfs]          
RSP: 0018:ffff880038983990  EFLAGS: 00010246
RAX: ffff8800398c7938 RBX: ffffea0000d199a0 RCX: ffff8800398c7790
RDX: 0100000000000009 RSI: 00000000000000d0 RDI: ffffea0000d199a0
RBP: ffff8800389839b0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000000
R13: 00000000000000d0 R14: ffff880038983c30 R15: 0000000000000001
FS:  00007f27b7e516f0(0000) GS:ffff880001a00000(0000) knlGS:00000000f74976c0
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f27b3b81000 CR3: 0000000001807000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kswapd0 (pid: 35, threadinfo ffff880038982000, task ffff88003bbcd980)
Stack:
 ffff88003b426f70 ffffea0000d199a0 00000000000000d0 ffff880038983da0
<0> ffff8800389839d0 ffffffffa039742b ffffea0000d199a0 ffffea0000d199c8
<0> ffff8800389839e0 ffffffff810bc73b ffff880038983af0 ffffffff810c9d7b
Call Trace:
 [<ffffffffa039742b>] nfs_release_page+0x3b/0x70 [nfs]
 [<ffffffff810bc73b>] try_to_release_page+0x2b/0x50
 [<ffffffff810c9d7b>] shrink_page_list+0x42b/0x5b0
 [<ffffffff810c88d1>] ? isolate_pages_global+0xa1/0x220
 [<ffffffff810ca208>] shrink_inactive_list+0x308/0x700
 [<ffffffff810ca85c>] ? shrink_active_list+0x25c/0x310
 [<ffffffff810cab86>] shrink_zone+0x276/0x470
 [<ffffffff810caec2>] ? shrink_slab+0x142/0x180
 [<ffffffff810cb7f1>] balance_pgdat+0x681/0x700
 [<ffffffff810c8830>] ? isolate_pages_global+0x0/0x220
 [<ffffffff810cb979>] kswapd+0x109/0x220
 [<ffffffff81062b70>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff810cb870>] ? kswapd+0x0/0x220
 [<ffffffff8106267e>] kthread+0x8e/0xa0
 [<ffffffff81003b14>] kernel_thread_helper+0x4/0x10
 [<ffffffff810625f0>] ? kthread+0x0/0xa0
 [<ffffffff81003b10>] ? kernel_thread_helper+0x0/0x10
Code: e8 4c 8b 65 f0 4c 8b 6d f8 c9 c3 48 89 fa 31 c0 4c 89 e6 48 c7 c7 c8 ad 3c a0 
e8 38 7c 04 e1 48 8b 03 f6 c4 10 75 a0 31 c0 eb d2 <0f> 0b eb fe 90 55 48 89 e5 e8 77 
7e 04 e1 31 c0 c9 c3 0f 1f 00
RIP  [<ffffffffa03c20cb>] nfs_fscache_release_page+0xab/0xb0 [nfs]
 RSP <ffff880038983990>
---[ end trace 99c0b5e9d282a6b2 ]---

I applied this patch:

http://marc.info/?l=linux-nfs&m=126399012901759&w=2

but this didn't helped and yes, I'm using cachefilesd.

Thanks

Marvin


