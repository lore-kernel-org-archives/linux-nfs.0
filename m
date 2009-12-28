From: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Subject: 2.6.32 nfs regression?
Date: Mon, 28 Dec 2009 13:10:18 +0100
Message-ID: <20091228121018.GA13987@develbox.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org,
	Linux kernel list <linux-kernel@vger.kernel.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:56865 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892AbZL1MTB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2009 07:19:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I just upgraded two my machines to 2.6.32.1, and am getting lots of nfs-related
error messages and backtraces.

those two repeat quite often:
[60144.870302] rpc-srv/tcp: nfsd: got error -104 when sending 140 bytes - shutting down socket
[60144.870436] nfsd: peername failed (err 107)!

and the backtraces:
[697321.291127] INFO: task nfsd:3707 blocked for more than 120 seconds.
[697321.291132] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[697321.291135] nfsd          D 00000000ffffffff     0  3707      2 0x00000080
[697321.291143]  ffff880077997b30 0000000000000046 0000000000000000 ffffffff8106e995
[697321.291150]  ffff880000000000 ffff8800779980c0 ffff880077998000 ffffffff8153a220
[697321.291157]  ffff8800779983b8 ffff8800751d90f0 000000010a626ceb 0000000000000002
[697321.291164] Call Trace:
[697321.291175]  [<ffffffff8106e995>] ? prepare_to_wait+0x25/0x80
[697321.291187]  [<ffffffffa05f3336>] start_this_handle+0x246/0x530 [jbd2]
[697321.291194]  [<ffffffff8106e760>] ? autoremove_wake_function+0x0/0x40
[697321.291202]  [<ffffffffa05f36e3>] jbd2_journal_start+0xc3/0xf0 [jbd2]
[697321.291223]  [<ffffffffa062fe31>] ext4_journal_start_sb+0x31/0x80 [ext4]
[697321.291235]  [<ffffffffa0620b95>] ext4_dirty_inode+0x25/0x60 [ext4]
[697321.291242]  [<ffffffff811364b5>] __mark_inode_dirty+0x35/0x180
[697321.291247]  [<ffffffff8112c67c>] inode_setattr+0x6c/0x180
[697321.291259]  [<ffffffffa062097b>] ext4_setattr+0x14b/0x340 [ext4]
[697321.291264]  [<ffffffff8112c907>] notify_change+0x177/0x350
[697321.291279]  [<ffffffffa04b1d8d>] nfsd_setattr+0x26d/0x510 [nfsd]
[697321.291291]  [<ffffffffa04b9cef>] nfsd3_proc_setattr+0x7f/0xd0 [nfsd]
[697321.291301]  [<ffffffffa04ac3b5>] nfsd_dispatch+0xb5/0x230 [nfsd]
[697321.291323]  [<ffffffffa03c6b07>] svc_process+0x477/0x780 [sunrpc]
[697321.291333]  [<ffffffffa04ac860>] ? nfsd+0x0/0x150 [nfsd]
[697321.291342]  [<ffffffffa04ac91d>] nfsd+0xbd/0x150 [nfsd]
[697321.291347]  [<ffffffff8106e61e>] kthread+0x8e/0xa0
[697321.291352]  [<ffffffff8100c31a>] child_rip+0xa/0x20
[697321.291357]  [<ffffffff8106e590>] ? kthread+0x0/0xa0
[697321.291361]  [<ffffffff8100c310>] ? child_rip+0x0/0x20
[697321.291365] 2 locks held by nfsd/3707:
[697321.291368]  #0:  (hash_sem){......}, at: [<ffffffffa04b5710>] exp_readlock+0x10/0x20 [nfsd]
[697321.291383]  #1:  (&sb->s_type->i_mutex_key#14){......}, at: [<ffffffffa04b1ef7>] nfsd_setattr+0x3d7/0x510 [nfsd]
[697321.291403] INFO: task jbd2/dm-7-8:4448 blocked for more than 120 seconds.
[697321.291406] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[697321.291409] jbd2/dm-7-8   D 00000000ffffffff     0  4448      2 0x00000080
[697321.291415]  ffff8800722e7ce0 0000000000000046 0000000000000000 ffffffff8106e995
[697321.291422]  ffff880000000000 ffff8800722d4f00 ffff8800722d4e40 ffff88007f8ace40
[697321.291428]  ffff8800722d51f8 ffff8800751d9230 000000010a626d1b 0000000000000002
[697321.291435] Call Trace:
[697321.291440]  [<ffffffff8106e995>] ? prepare_to_wait+0x25/0x80
[697321.291449]  [<ffffffffa05f4c1a>] jbd2_journal_commit_transaction+0x1ea/0x1890 [jbd2]
[697321.291455]  [<ffffffff8105e026>] ? lock_timer_base+0x36/0x70
[697321.291460]  [<ffffffff8106e760>] ? autoremove_wake_function+0x0/0x40
[697321.291466]  [<ffffffff8105e0a4>] ? try_to_del_timer_sync+0x44/0x100
[697321.291475]  [<ffffffffa05fbbba>] kjournald2+0xba/0x240 [jbd2]
[697321.291479]  [<ffffffff8106e760>] ? autoremove_wake_function+0x0/0x40
[697321.291487]  [<ffffffffa05fbb00>] ? kjournald2+0x0/0x240 [jbd2]
[697321.291492]  [<ffffffff8106e61e>] kthread+0x8e/0xa0
[697321.291497]  [<ffffffff8100c31a>] child_rip+0xa/0x20
[697321.291501]  [<ffffffff8106e590>] ? kthread+0x0/0xa0
[697321.291506]  [<ffffffff8100c310>] ? child_rip+0x0/0x20
[697321.291509] no locks held by jbd2/dm-7-8/4448.
[698041.288035] INFO: task nfsd:3703 blocked for more than 120 seconds.
[698041.288040] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[698041.288044] nfsd          D 00000000ffffffff     0  3703      2 0x00000080
[698041.288051]  ffff88007a309930 0000000000000046 0000000000000000 0000000000000000
[698041.288058]  0000000000000000 ffff88007a1200c0 ffff88007a120000 ffffffff8153a220
[698041.288065]  ffff88007a12le_move+0x28/0x60
[698041.288522]  [<ffffffff81115db8>] ? file_move+0x28/0x60
[698041.288527]  [<ffffffff81115149>] vfs_writev+0x39/0x60
[698041.288537]  [<ffffffffa04b0d73>] nfsd_vfs_write+0x103/0x410 [nfsd]
[698041.288543]  [<ffffffff8111430d>] ? dentry_open+0x4d/0xb0
[698041.288553]  [<ffffffffa04b161c>] ? nfsd_open+0x15c/0x1e0 [nfsd]
[698041.288563]  [<ffffffffa04b1a25>] nfsd_write+0xe5/0x100 [nfsd]
[698041.288575]  [<ffffffffa04ba19e>] nfsd3_proc_write+0xfe/0x140 [nfsd]
[698041.288584]  [<ffffffffa04ac3b5>] nfsd_dispatch+0xb5/0x230 [nfsd]
[698041.288599]  [<ffffffffa03c6b07>] svc_process+0x477/0x780 [sunrpc]
[698041.288610]  [<ffffffffa04ac860>] ? nfsd+0x0/0x150 [nfsd]
[698041.288618]  [<ffffffffa04ac91d>] nfsd+0xbd/0x150 [nfsd]
[698041.288623]  [<ffffffff8106e61e>] kthread+0x8e/0xa0
[698041.288628]  [<ffffffff8100c31a>] child_rip+0xa/0x20

there's ext4 mentioned, so I'm not 100% sure if it ain't ext4-related,
but on second machine (without ext4) I'm getting similar messages:

[704103.575633] nfsd: peername failed (err 107)!
[704280.628046] INFO: task reiserfs/0:2637 blocked for more than 120 seconds.
[704280.628050] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[704280.628053] reiserfs/0    D 0000000000000000     0  2637      2 0x00000000
[704280.628058]  ffff880139267c80 0000000000000046 0000000000000000 000000008103d1e9
[704280.628063]  0000000000000000 ffff88013f1400c0 ffff88013f140000 ffffffff8153a220
[704280.628067]  ffff88013f1403b8 0000000000000000 000000010a7cf74c 0000000000000000
[704280.628071] Call Trace:
[704280.628092]  [<ffffffffa0216b75>] ? flush_commit_list+0x145/0x6f0 [reiserfs]
[704280.628099]  [<ffffffff81340a82>] mutex_lock_nested+0x132/0x330
[704280.628106]  [<ffffffffa0216b75>] ? flush_commit_list+0x145/0x6f0 [reiserfs]
[704280.628115]  [<ffffffffa0216b75>] flush_commit_list+0x145/0x6f0 [reiserfs]
[704280.628123]  [<ffffffffa0216c67>] flush_commit_list+0x237/0x6f0 [reiserfs]
[704280.628131]  [<ffffffffa021b200>] ? flush_async_commits+0x0/0x70 [reiserfs]
[704280.628138]  [<ffffffffa021b257>] flush_async_commits+0x57/0x70 [reiserfs]
[704280.628144]  [<ffffffff81069f85>] worker_thread+0x235/0x390
[704280.628147]  [<ffffffff81069f33>] ? worker_thread+0x1e3/0x390
[704280.628151]  [<ffffffff8106e760>] ? autoremove_wake_function+0x0/0x40
[704280.628155]  [<ffffffff81069d50>] ? worker_thread+0x0/0x390
[704280.628158]  [<ffffffff8106e61e>] kthread+0x8e/0xa0
[704280.628162]  [<ffffffff8100c31a>] child_rip+0xa/0x20
[704280.628165]  [<ffffffff8106e590>] ? kthread+0x0/0xa0
[704280.628168]  [<ffffffff8100c310>] ? child_rip+0x0/0x20
[704280.628170] 3 locks held by reiserfs/0/2637:
[704280.628172]  #0:  (reiserfs){......}, at: [<ffffffff81069f33>] worker_thread+0x1e3/0x390
[704280.628178]  #1:  (&(&journal->j_work)->work){......}, at: [<ffffffff81069f33>] worker_thread+0x1e3/0x390
[704280.628184]  #2:  (&jl->j_commit_mutex){......}, at: [<ffffffffa0216b75>] flush_commit_list+0x145/0x6f0 [reiserfs]
[704329.500101] rpc-srv/tcp: nfsd: got error -32 when sending 140 bytes - shutting down socket

which leads me to suspicion the problems are somewhere within nfs code...
both machines are SMP x86_64.
I'll update to 2.6.32.2 on Wednesday, but according to changelog, it doesn't
seem to fix anything related...
Could somebody please have a look at this? I'll be glad to provide further
information if needed...

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
email servis: servis-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
-------------------------------------
