Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:37988 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755632Ab2DXJ0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 05:26:52 -0400
Content-Type: text/plain; charset="utf-8"
Date: Tue, 24 Apr 2012 11:26:50 +0200
From: "Johannes Schild" <JSchild@gmx.de>
Message-ID: <20120424092650.190300@gmx.net>
MIME-Version: 1.0
Subject: ctl bug
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

i tried to set up a pnfs-server with a blocklayout. I used the howto from  http://wiki.linux-nfs.org/wiki/index.php/PNFS_Block_Server_Setup_Instructions.
I compiled the sources from the pnfs-all-3.3 branch. Exactly the sources with SHA1-Tag 4f32d9efd121222cf8a158b37563aac197da9d41.

Starting ctl like described in the howto and connect to the server i got the following output from dmesg on the server:

[70239.578792] BUG: unable to handle kernel paging request at ffffeddfff6dea80
[70239.578822] IP: [<ffffffff811a0889>] kfree+0x49/0x2a0
[70239.579017] PGD 0 
[70239.579020] Oops: 0000 [#1] SMP 
[70239.579083] CPU 0 
[70239.579085] Modules linked in: xfs btrfs zlib_deflate libcrc32c tcp_lp nls_utf8 hfsplus hfs vfat fat be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i libcxgbi cxgb3 mdio ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi fuse ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter fcoe libfcoe ip6_tables libfc 8021q garp stp llc scsi_transport_fc scsi_tgt snd_ens1371 gameport snd_rawmidi snd_ac97_codec ac97_bus ppdev snd_seq joydev snd_seq_device snd_pcm vmw_balloon microcode pcspkr snd_timer snd pcnet32 parport_pc floppy parport soundcore snd_page_alloc mii shpchp i2c_piix4 i2c_core uinput nfsd lockd nfs_acl auth_rpcgss sunrpc mptspi mptscsih mptbase scsi_transport_spi [last unloaded: nf_defrag_ipv4]
[70239.579240] 
[70239.579267] Pid: 15759, comm: ctl Tainted: G        W    3.3.0-pnfs #1 VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform
[70239.579296] RIP: 0010:[<ffffffff811a0889>]  [<ffffffff811a0889>] kfree+0x49/0x2a0
[70239.579303] RSP: 0018:ffff88003b295e18  EFLAGS: 00010282
[70239.579305] RAX: 000003dfff6dea80 RBX: 00007fffdb7aa978 RCX: 0000000000000000
[70239.579308] RDX: ffffffff7fffffff RSI: ffff88003b295e60 RDI: 00007fffdb7aa978
[70239.579311] RBP: ffff88003b295e48 R08: 0000000000000001 R09: 0000000000000000
[70239.579314] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
[70239.579316] R13: ffffeddfff6dea80 R14: 00007fffdb7aa978 R15: 0000000000000004
[70239.579320] FS:  00007ff172de3800(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[70239.579323] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[70239.579326] CR2: ffffeddfff6dea80 CR3: 00000000354e7000 CR4: 00000000000406f0
[70239.579397] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[70239.579451] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[70239.579476] Process ctl (pid: 15759, threadinfo ffff88003b294000, task ffff880026d92680)
[70239.579480] Stack:
[70239.579481]  ffff88003b295e48 0000000000000004 0000000000000000 00007fffdb7aa978
[70239.579488]  00007fffdb7aa978 0000000000000004 ffff88003b295ea8 ffffffffa00ebac0
[70239.579493]  ffff88003b686098 ffff880000000000 ffff88003b290b00 ffffffffa00eb9f0
[70239.579499] Call Trace:
[70239.579677]  [<ffffffffa00ebac0>] ctl_write+0xd0/0x140 [nfsd]
[70239.579697]  [<ffffffffa00eb9f0>] ? bl_upcall+0x1e0/0x1e0 [nfsd]
[70239.579711]  [<ffffffffa00eb9f0>] ? bl_upcall+0x1e0/0x1e0 [nfsd]
[70239.579794]  [<ffffffff81224836>] proc_reg_write+0x86/0xc0
[70239.579820]  [<ffffffff811b9df6>] vfs_write+0xb6/0x180
[70239.579825]  [<ffffffff811ba11d>] sys_write+0x4d/0x90
[70239.579902]  [<ffffffff816a5fa9>] system_call_fastpath+0x16/0x1b
[70239.579904] Code: 66 66 66 90 48 83 fb 10 0f 86 e6 00 00 00 48 89 df 49 bd 00 00 00 00 00 ea ff ff e8 b2 af ea ff 48 c1 e8 0c 48 c1 e0 06 49 01 c5 <49> 8b 45 00 f6 c4 80 0f 85 1c 02 00 00 49 8b 45 00 a8 80 0f 84 
[70239.579963] RIP  [<ffffffff811a0889>] kfree+0x49/0x2a0
[70239.579968]  RSP <ffff88003b295e18>
[70239.579970] CR2: ffffeddfff6dea80
[70239.579999] ---[ end trace 7dac578d4af52866 ]---
[70239.580005] BUG: sleeping function called from invalid context at kernel/rwsem.c:21
[70239.580008] in_atomic(): 0, irqs_disabled(): 1, pid: 15759, name: ctl
[70239.580012] INFO: lockdep is turned off.
[70239.580015] irq event stamp: 6902
[70239.580018] hardirqs last  enabled at (6901): [<ffffffff816a5fd5>] sysret_check+0x22/0x5d
[70239.580045] hardirqs last disabled at (6902): [<ffffffff8169dbb6>] error_sti+0x5/0x6
[70239.580072] softirqs last  enabled at (6746): [<ffffffff8106aeac>] __do_softirq+0x13c/0x3c0
[70239.580119] softirqs last disabled at (6709): [<ffffffff816a74ec>] call_softirq+0x1c/0x30
[70239.580146] Pid: 15759, comm: ctl Tainted: G      D W    3.3.0-pnfs #1
[70239.580149] Call Trace:
[70239.580214]  [<ffffffff810cb4d0>] ? print_irqtrace_events+0xd0/0xe0
[70239.580244]  [<ffffffff81097927>] __might_sleep+0x137/0x1f0
[70239.580250]  [<ffffffff8169a786>] down_read+0x26/0x98
[70239.580258]  [<ffffffff8107b9a4>] exit_signals+0x24/0x130
[70239.580284]  [<ffffffff81066cb4>] do_exit+0xc4/0xa80
[70239.580290]  [<ffffffff81063f12>] ? kmsg_dump+0x182/0x270
[70239.580294]  [<ffffffff81063e2c>] ? kmsg_dump+0x9c/0x270
[70239.580300]  [<ffffffff8169e5dc>] oops_end+0xac/0xf0
[70239.580326]  [<ffffffff8169094c>] no_context+0x27b/0x28a
[70239.580332]  [<ffffffff81690b34>] __bad_area_nosemaphore+0x1d9/0x1f8
[70239.580359]  [<ffffffff81021ff9>] ? sched_clock+0x9/0x10
[70239.580386]  [<ffffffff810a3b4d>] ? sched_clock_cpu+0xbd/0x110
[70239.580391]  [<ffffffff81690b66>] bad_area_nosemaphore+0x13/0x15
[70239.580395]  [<ffffffff816a14bb>] do_page_fault+0x42b/0x590
[70239.580400]  [<ffffffff81021f83>] ? native_sched_clock+0x13/0x80
[70239.580403]  [<ffffffff81021ff9>] ? sched_clock+0x9/0x10
[70239.580407]  [<ffffffff810a3b4d>] ? sched_clock_cpu+0xbd/0x110
[70239.580412]  [<ffffffff810c7fcd>] ? trace_hardirqs_off+0xd/0x10
[70239.580416]  [<ffffffff810a3c0f>] ? local_clock+0x6f/0x80
[70239.580464]  [<ffffffff8132ab7d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[70239.580471]  [<ffffffff8169d975>] page_fault+0x25/0x30
[70239.580475]  [<ffffffff811a0889>] ? kfree+0x49/0x2a0
[70239.580479]  [<ffffffff811a087e>] ? kfree+0x3e/0x2a0
[70239.580497]  [<ffffffffa00ebac0>] ctl_write+0xd0/0x140 [nfsd]
[70239.580510]  [<ffffffffa00eb9f0>] ? bl_upcall+0x1e0/0x1e0 [nfsd]
[70239.580522]  [<ffffffffa00eb9f0>] ? bl_upcall+0x1e0/0x1e0 [nfsd]
[70239.580527]  [<ffffffff81224836>] proc_reg_write+0x86/0xc0
[70239.580530]  [<ffffffff811b9df6>] vfs_write+0xb6/0x180
[70239.580534]  [<ffffffff811ba11d>] sys_write+0x4d/0x90
[70239.580539]  [<ffffffff816a5fa9>] system_call_fastpath+0x16/0x1b


Thanks in advance for your help.

Johannes 
-- 
Empfehlen Sie GMX DSL Ihren Freunden und Bekannten und wir
belohnen Sie mit bis zu 50,- Euro! https://freundschaftswerbung.gmx.de
