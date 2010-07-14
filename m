Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:53751 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab0GNLEs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 07:04:48 -0400
Received: from linuxbox.linuxbox.cz (server.linuxbox.cz [10.76.66.10])
	by gwu.lbox.cz (Sendmail) with ESMTP id o6EAx57f012082
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Jul 2010 12:59:05 +0200
Date: Wed, 14 Jul 2010 13:00:20 +0200
From: Nikola Ciprich <extmaillist@linuxbox.cz>
To: linux NFS list <linux-nfs@vger.kernel.org>
Cc: nikola.ciprich@linuxbox.cz, mzik@linuxbox.cz
Subject: 2.6.32.16 - NFS still having trouble (nfsd: peername failed (err
 107)!)
Message-ID: <20100714110020.GB10153@develbox.linuxbox.cz>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I just updated one of my NFS boxes to 2.6.32.16, but NFS is still not in
top condition. Clients are hanging during copying, and following messages 
are appearing in dmesg:

[403761.756101] nfsd: peername failed (err 107)!
[403761.756157] nfsd: peername failed (err 107)!
[492481.116096] INFO: task jbd2/dm-8-8:4563 blocked for more than 120 seconds.
[492481.116101] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[492481.116105] jbd2/dm-8-8   D ffff8800712db000     0  4563      2 0x00000080
[492481.116111]  ffff88007529fcf0 0000000000000046 0000000000000000 ffff88000190dd88
[492481.116119]  0000000000013780 ffff88007ab9af80 ffff88007ab9aec0 ffff88007f89c620
[492481.116125]  ffff88007ab9b278 ffff88007529ffd8 0000000000000282 000000010754f3a6
[492481.116131] Call Trace:
[492481.116143]  [<ffffffff81337d9d>] ? _spin_unlock_irqrestore+0x1d/0x50
[492481.116163]  [<ffffffffa039bbc0>] jbd2_journal_commit_transaction+0x1f0/0x1890 [jbd2]
[492481.116169]  [<ffffffff81337d54>] ? _spin_unlock_irq+0x14/0x40
[492481.116175]  [<ffffffff8106d7f0>] ? autoremove_wake_function+0x0/0x40
[492481.116180]  [<ffffffff81337f9a>] ? _spin_lock_irqsave+0x2a/0x40
[492481.116186]  [<ffffffff8105d974>] ? try_to_del_timer_sync+0x44/0x110
[492481.116196]  [<ffffffffa03a2b63>] kjournald2+0xb3/0x230 [jbd2]
[492481.116200]  [<ffffffff8106d7f0>] ? autoremove_wake_function+0x0/0x40
[492481.116209]  [<ffffffffa03a2ab0>] ? kjournald2+0x0/0x230 [jbd2]
[492481.116214]  [<ffffffff8106d6ae>] kthread+0x8e/0xa0
[492481.116219]  [<ffffffff8100c30a>] child_rip+0xa/0x20
[492481.116224]  [<ffffffff8106d620>] ? kthread+0x0/0xa0
[492481.116227]  [<ffffffff8100c300>] ? child_rip+0x0/0x20
[569401.116077] INFO: task nfsd:4659 blocked for more than 120 seconds.
[569401.116081] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[569401.116085] nfsd          D 0000000000000000     0  4659      2 0x00000080
[569401.116092]  ffff880072c45930 0000000000000046 0000000272c458c0 ffffea00004f4a00
[569401.116099]  0000000000013780 ffff880072bbaf80 ffff880072bbaec0 ffff8800729a9760
[569401.116105]  ffff880072bbb278 ffff880072c45fd8 0000000000000003 ffffea00004f4800
[569401.116111] Call Trace:
[569401.116123]  [<ffffffff813364c7>] __mutex_lock_slowpath+0x107/0x310
[569401.116129]  [<ffffffff813366f7>] mutex_lock+0x27/0x50
[569401.116134]  [<ffffffff810cd4b4>] generic_file_aio_write+0x44/0xb0
[569401.116157]  [<ffffffffa03bdf06>] ext4_file_write+0x46/0xb0 [ext4]
[569401.116169]  [<ffffffffa03bdec0>] ? ext4_file_write+0x0/0xb0 [ext4]
[569401.116175]  [<ffffffff8110eaab>] do_sync_readv_writev+0xeb/0x130
[569401.116181]  [<ffffffff8106d7f0>] ? autoremove_wake_function+0x0/0x40
[569401.116186]  [<ffffffff8110e8c8>] ? rw_copy_check_uvector+0x78/0x130
[569401.116192]  [<ffffffff811912e1>] ? security_file_permission+0x11/0x20
[569401.116197]  [<ffffffff8110f17b>] do_readv_writev+0xcb/0x1e0
[569401.116208]  [<ffffffffa03bddb1>] ? ext4_file_open+0x51/0x100 [ext4]
[569401.116222]  [<ffffffffa0502273>] ? nfsd_setuser+0x113/0x2d0 [nfsd]
[569401.116228]  [<ffffffff8110f2c9>] vfs_writev+0x39/0x60
[569401.116237]  [<ffffffffa04fbd23>] nfsd_vfs_write+0x103/0x410 [nfsd]
[569401.116242]  [<ffffffff8110e49d>] ? dentry_open+0x4d/0xb0
[569401.116251]  [<ffffffffa04fc5cc>] ? nfsd_open+0x15c/0x1e0 [nfsd]
[569401.116261]  [<ffffffffa04fc9d5>] nfsd_write+0xe5/0x100 [nfsd]
[569401.116272]  [<ffffffffa050511e>] nfsd3_proc_write+0xfe/0x140 [nfsd]
[569401.116281]  [<ffffffffa04f73a5>] nfsd_dispatch+0xb5/0x230 [nfsd]
[569401.116311]  [<ffffffffa043e6e6>] svc_process+0x466/0x770 [sunrpc]
[569401.116319]  [<ffffffffa04f7850>] ? nfsd+0x0/0x150 [nfsd]
[569401.116326]  [<ffffffffa04f790d>] nfsd+0xbd/0x150 [nfsd]
[569401.116330]  [<ffffffff8106d6ae>] kthread+0x8e/0xa0
[569401.116334]  [<ffffffff8100c30a>] child_rip+0xa/0x20
[569401.116338]  [<ffffffff8106d620>] ? kthread+0x0/0xa0
[569401.116341]  [<ffffffff8100c300>] ? child_rip+0x0/0x20
[569401.116345] INFO: task nfsd:4661 blocked for more than 120 seconds.
[569401.116347] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[569401.116350] nfsd          D 0000000000000000     0  4661      2 0x00000080
[569401.116355]  ffff880072ccd4d8 0000000000000046 0000000000000000 ffff880072ccd440
[569401.116360]  0000000000013780 ffff880072bbde40 ffff880072bbdd80 ffffffff81516080
[569401.116366]  ffff880072bbe138 ffff880072ccdfd8 ffff8800714997f0 00000001087a7b5c
[569401.116371] Call Trace:
[569401.116376]  [<ffffffff813378e9>] rwsem_down_failed_common+0x89/0x1d0
[569401.116380]  [<ffffffff81337a86>] rwsem_down_read_failed+0x26/0x30
[569401.116385]  [<ffffffff811bc694>] call_rwsem_down_read_failed+0x14/0x30
[569401.116389]  [<ffffffff81336dbd>] ? down_read+0x2d/0x40
[569401.116399]  [<ffffffffa03c335a>] ext4_get_blocks+0x4a/0x350 [ext4]
[569401.116404]  [<ffffffff8113475e>] ? alloc_buffer_head+0x5e/0x90
[569401.116415]  [<ffffffffa03c855f>] ext4_da_get_block_prep+0x7f/0x2b0 [ext4]
[569401.116420]  [<ffffffff81337de3>] ? _spin_unlock+0x13/0x40
[569401.116424]  [<ffffffff811366de>] __block_prepare_write+0x26e/0x430
[569401.116435]  [<ffffffffa03c84e0>] ? ext4_da_get_block_prep+0x0/0x2b0 [ext4]
[569401.116440]  [<ffffffff810d5d82>] ? __lru_cache_add+0x72/0xb0
[569401.116445]  [<ffffffff81136939>] block_write_begin+0x59/0xe0
[569401.116455]  [<ffffffffa03c7576>] ext4_da_write_begin+0x156/0x290 [ext4]
[569401.116466]  [<ffffffffa03c84e0>] ? ext4_da_get_block_prep+0x0/0x2b0 [ext4]
[569401.116471]  [<ffffffff810ccd6a>] generic_file_buffered_write+0x10a/0x290
[569401.116476]  [<ffffffff810cd2b6>] __generic_file_aio_write+0x266/0x420
[569401.116481]  [<ffffffff810cd4ca>] generic_file_aio_write+0x5a/0xb0
[569401.116490]  [<ffffffffa03bdf06>] ext4_file_write+0x46/0xb0 [ext4]
[569401.116499]  [<ffffffffa03bdec0>] ? ext4_file_write+0x0/0xb0 [ext4]
[569401.116504]  [<ffffffff8110eaab>] do_sync_readv_writev+0xeb/0x130
[569401.116508]  [<ffffffff8106d7f0>] ? autoremove_wake_function+0x0/0x40
[569401.116512]  [<ffffffff8110e8c8>] ? rw_copy_check_uvector+0x78/0x130
[569401.116517]  [<ffffffff811912e1>] ? security_file_permission+0x11/0x20
[569401.116521]  [<ffffffff8110f17b>] do_readv_writev+0xcb/0x1e0
[569401.116530]  [<ffffffffa03bddb1>] ? ext4_file_open+0x51/0x100 [ext4]
[569401.116539]  [<ffffffffa0502273>] ? nfsd_setuser+0x113/0x2d0 [nfsd]
[569401.116544]  [<ffffffff8110f2c9>] vfs_writev+0x39/0x60
[569401.116552]  [<ffffffffa04fbd23>] nfsd_vfs_write+0x103/0x410 [nfsd]
[569401.116556]  [<ffffffff8110e49d>] ? dentry_open+0x4d/0xb0
[569401.116564]  [<ffffffffa04fc5cc>] ? nfsd_open+0x15c/0x1e0 [nfsd]
[569401.116572]  [<ffffffffa04fc9d5>] nfsd_write+0xe5/0x100 [nfsd]
[569401.116581]  [<ffffffffa050511e>] nfsd3_proc_write+0xfe/0x140 [nfsd]
[569401.116589]  [<ffffffffa04f73a5>] nfsd_dispatch+0xb5/0x230 [nfsd]
[569401.116601]  [<ffffffffa043e6e6>] svc_process+0x466/0x770 [sunrpc]
[569401.116609]  [<ffffffffa04f7850>] ? nfsd+0x0/0x150 [nfsd]
[569401.116616]  [<ffffffffa04f790d>] nfsd+0xbd/0x150 [nfsd]
[569401.116620]  [<ffffffff8106d6ae>] kthread+0x8e/0xa0
[569401.116624]  [<ffffffff8100c30a>] child_rip+0xa/0x20
[569401.116628]  [<ffffffff8106d620>] ? kthread+0x0/0xa0
[569401.116631]  [<ffffffff8100c300>] ? child_rip+0x0/0x20
[569405.983124] rpc-srv/tcp: nfsd: got error -104 when sending 140 bytes - shutting down socket
[569405.983334] nfsd: peername failed (err 107)!
[569405.983371] nfsd: peername failed (err 107)!

machine is x86_64, what is certainly important to note is that
NFS share sits on top of (large) dm-crypted ext4 volume.
Could somebody please help me to track the source of problems?

Thanks a lot in advance...

with best regards

nikola ciprich


-- 
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------
