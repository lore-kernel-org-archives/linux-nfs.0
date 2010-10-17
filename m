Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2686 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756986Ab0JQRv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Oct 2010 13:51:59 -0400
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id D5BB62803
	for <linux-nfs@vger.kernel.org>; Sun, 17 Oct 2010 13:51:58 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 729428DEC
	for <linux-nfs@vger.kernel.org>; Sun, 17 Oct 2010 13:51:58 -0400 (EDT)
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-fJKg+e3doScWFZQLIw5L"
Message-ID: <1287334833.4871.6.camel@pc>
Subject: Error: state manager failed on NFSv4 server linux with error 127
Date: Sun, 17 Oct 2010 13:51:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-fJKg+e3doScWFZQLIw5L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi.

Yesterday, on the Ubuntu 2.6.35-22-generic kernel, I got a spew of:

Oct 16 17:00:21 pc kernel: [415259.309475] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.311413] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.314178] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.316237] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.318169] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.320442] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.322989] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.324761] Error: state manager failed on N=
FSv4 server linux with error 127
Oct 16 17:00:21 pc kernel: [415259.326443] Error: state manager failed on N=
FSv4 server linux with error 127

At the same time, many processes were blocked with stacks similar to:

[415723.293796] SysRq : Show Blocked State
[415723.293803]   task                PC stack   pid father
[415723.293848] gnome-setting D f368bd04     0  4136      1 0x00000000
[415723.293854]  f368bd14 00200086 00000002 f368bd04 f8256917 c05d89e0 c08c=
3700 c08c3700
[415723.293859]  d209ff9f 00017a15 c08c3700 c08c3700 d209dca8 00017a15 0000=
0000 c08c3700
[415723.293864]  c08c3700 f69bcc20 00000001 f7090000 f7090000 f368bd34 f368=
bd78 c05c72df
[415723.293868] Call Trace:
[415723.293916]  [<f8256917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[415723.293924]  [<c05c72df>] schedule_timeout+0x12f/0x270
[415723.293949]  [<f882e3b1>] ? _nfs4_proc_access+0xf1/0x170 [nfs]
[415723.293954]  [<c01589c0>] ? process_timeout+0x0/0x10
[415723.293959]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[415723.293972]  [<f882c32d>] nfs4_delay+0x2d/0x70 [nfs]
[415723.293984]  [<f882c50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[415723.293997]  [<f882e47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[415723.294006]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.294015]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.294020]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[415723.294023]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.294027]  [<c0223867>] link_path_walk+0x67/0x890
[415723.294032]  [<c012ce18>] ? default_spin_lock_flags+0x8/0x10
[415723.294036]  [<c02241b1>] path_walk+0x51/0xc0
[415723.294039]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.294042]  [<c0224e81>] user_path_at+0x41/0x80
[415723.294046]  [<c01f46c4>] ? handle_mm_fault+0x2d4/0x400
[415723.294050]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[415723.294054]  [<c05cc3fd>] ? do_page_fault+0x1cd/0x440
[415723.294057]  [<c021cb30>] vfs_stat+0x20/0x30
[415723.294060]  [<c021cb59>] sys_stat64+0x19/0x30
[415723.294064]  [<c0151519>] ? irq_exit+0x39/0x70
[415723.294068]  [<c05c9a40>] ? do_device_not_available+0x0/0x60
[415723.294072]  [<c0104279>] ? math_state_restore+0x39/0x60
[415723.294075]  [<c05c9a8d>] ? do_device_not_available+0x4d/0x60
[415723.294078]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.294087] pidgin        D f373fcd4     0  4191   4057 0x00000000
[415723.294091]  f373fd14 00000086 00000080 f373fcd4 c460e000 ffffff81 c08c=
3700 c08c3700
[415723.294095]  3084e28e 00017a17 c08c3700 c08c3700 00000001 00017a17 0000=
0000 c08c3700
[415723.294100]  c08c3700 f42f2610 f7090000 f7090000 f7090000 f373fd34 f373=
fd78 c05c72df
[415723.294104] Call Trace:
[415723.294108]  [<c05c72df>] schedule_timeout+0x12f/0x270
[415723.294123]  [<f882e3b1>] ? _nfs4_proc_access+0xf1/0x170 [nfs]
[415723.294126]  [<c01589c0>] ? process_timeout+0x0/0x10
[415723.294130]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[415723.294143]  [<f882c32d>] nfs4_delay+0x2d/0x70 [nfs]
[415723.294155]  [<f882c50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[415723.294168]  [<f882e47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[415723.294177]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.294186]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.294190]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[415723.294193]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.294196]  [<c0223867>] link_path_walk+0x67/0x890
[415723.294201]  [<c0139665>] ? update_curr+0x175/0x2a0
[415723.294204]  [<c02241b1>] path_walk+0x51/0xc0
[415723.294208]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.294211]  [<c0224e81>] user_path_at+0x41/0x80
[415723.294216]  [<c03551a3>] ? rb_insert_color+0xd3/0x110
[415723.294218]  [<c05c8b6d>] ? _raw_spin_lock+0xd/0x10
[415723.294222]  [<c01abfc3>] ? rcu_report_qs_rnp+0xb3/0x100
[415723.294225]  [<c01ac6b7>] ? __rcu_process_callbacks+0x47/0x2d0
[415723.294228]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[415723.294231]  [<c021cb30>] vfs_stat+0x20/0x30
[415723.294234]  [<c021cb59>] sys_stat64+0x19/0x30
[415723.294239]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[415723.294242]  [<c035a249>] ? copy_to_user+0x39/0x130
[415723.294245]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[415723.294249]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[415723.294252]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.294284] vinagre       D d9423cd4     0  8801      1 0x00000000
[415723.294288]  d9423d14 00200086 00000080 d9423cd4 c460c000 ffffff81 c08c=
3700 c08c3700
[415723.294293]  6ada7549 00017a16 c08c3700 c08c3700 00000000 00017a16 0000=
0000 c08c3700
[415723.294297]  c08c3700 efa6e580 c08fc500 c08fc500 c08fc500 d9423d34 d942=
3d78 c05c72df
[415723.294302] Call Trace:
[415723.294306]  [<c05c72df>] schedule_timeout+0x12f/0x270
[415723.294310]  [<c01589c0>] ? process_timeout+0x0/0x10
[415723.294313]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[415723.294328]  [<f882c32d>] nfs4_delay+0x2d/0x70 [nfs]
[415723.294340]  [<f882c50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[415723.294353]  [<f882e47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[415723.294362]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.294371]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.294375]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[415723.294378]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.294381]  [<c0223867>] link_path_walk+0x67/0x890
[415723.294385]  [<c02241b1>] path_walk+0x51/0xc0
[415723.294388]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.294391]  [<c0224e81>] user_path_at+0x41/0x80
[415723.294395]  [<c0142a11>] ? try_to_wake_up+0xa1/0x3b0
[415723.294399]  [<c01222db>] ? lapic_next_event+0x1b/0x20
[415723.294402]  [<c0175802>] ? tick_dev_program_event+0x42/0x150
[415723.294406]  [<c0169bd2>] ? __run_hrtimer+0x92/0x190
[415723.294409]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[415723.294411]  [<c021cb30>] vfs_stat+0x20/0x30
[415723.294414]  [<c021cb59>] sys_stat64+0x19/0x30
[415723.294418]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[415723.294421]  [<c035a249>] ? copy_to_user+0x39/0x130
[415723.294424]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[415723.294427]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[415723.294430]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.294433] rhythmbox     D f7090000     0 27043      1 0x00000000
[415723.294437]  d5dc7cac 00200086 c01588cc f7090000 d5dc7c70 c05d89e0 c08c=
3700 c08c3700
[415723.294441]  a4861998 00017a18 c08c3700 c08c3700 a485c4cb 00017a18 0000=
0000 c08c3700
[415723.294446]  c08c3700 ef950000 d5dc7cb4 d5dc7ce0 00000000 d5dc7ce8 d5dc=
7cb4 f8256c0c
[415723.294450] Call Trace:
[415723.294453]  [<c01588cc>] ? lock_timer_base+0x2c/0x60
[415723.294473]  [<f8256c0c>] rpc_wait_bit_killable+0x1c/0x40 [sunrpc]
[415723.294476]  [<c05c761d>] __wait_on_bit+0x4d/0x70
[415723.294490]  [<f8256bf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[415723.294502]  [<f8256bf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[415723.294506]  [<c05c76eb>] out_of_line_wait_on_bit+0xab/0xc0
[415723.294510]  [<c0165e60>] ? wake_bit_function+0x0/0x50
[415723.294525]  [<f825731b>] __rpc_execute+0xdb/0x250 [sunrpc]
[415723.294538]  [<f8256a17>] ? rpc_init_task+0xd7/0x120 [sunrpc]
[415723.294552]  [<f82574fe>] rpc_execute+0x6e/0x80 [sunrpc]
[415723.294563]  [<f82509af>] rpc_run_task+0x1f/0x30 [sunrpc]
[415723.294575]  [<f8250abe>] rpc_call_sync+0x3e/0x60 [sunrpc]
[415723.294591]  [<f882f5e2>] _nfs4_call_sync+0x22/0x30 [nfs]
[415723.294604]  [<f882e3a3>] _nfs4_proc_access+0xe3/0x170 [nfs]
[415723.294617]  [<f882e469>] nfs4_proc_access+0x39/0x60 [nfs]
[415723.294626]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.294635]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.294639]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[415723.294642]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.294645]  [<c0223867>] link_path_walk+0x67/0x890
[415723.294649]  [<c02241b1>] path_walk+0x51/0xc0
[415723.294652]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.294655]  [<c0224e81>] user_path_at+0x41/0x80
[415723.294659]  [<c016ffbd>] ? ktime_get_ts+0xed/0x120
[415723.294662]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[415723.294666]  [<c024ad63>] sys_inotify_add_watch+0x63/0x100
[415723.294669]  [<c0228829>] ? sys_poll+0x59/0xc0
[415723.294672]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.294681] clock-applet  D ce1f5cd4     0 29323      1 0x00000000
[415723.294684]  ce1f5d14 00200086 00000080 ce1f5cd4 f5fa6000 ffffff81 c08c=
3700 c08c3700
[415723.294689]  e8a6c632 00017a18 c08c3700 c08c3700 00000000 00017a18 f5e6=
7e00 c08c3700
[415723.294693]  c08c3700 f68bd8d0 c08fc500 c08fc500 c08fc500 ce1f5d34 ce1f=
5d78 c05c72df
[415723.294698] Call Trace:
[415723.294701]  [<c05c72df>] schedule_timeout+0x12f/0x270
[415723.294705]  [<c01589c0>] ? process_timeout+0x0/0x10
[415723.294709]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[415723.294722]  [<f882c32d>] nfs4_delay+0x2d/0x70 [nfs]
[415723.294734]  [<f882c50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[415723.294747]  [<f882e47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[415723.294756]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.294765]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.294770]  [<c02306cf>] ? mntput_no_expire+0x1f/0xd0
[415723.294773]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.294776]  [<c0223867>] link_path_walk+0x67/0x890
[415723.294780]  [<c02241b1>] path_walk+0x51/0xc0
[415723.294783]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.294787]  [<c0224e81>] user_path_at+0x41/0x80
[415723.294802]  [<c04f5f4b>] ? net_rx_action+0x1ab/0x220
[415723.294805]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[415723.294809]  [<c0124fc4>] ? ack_apic_level+0x64/0x1f0
[415723.294812]  [<c021cb30>] vfs_stat+0x20/0x30
[415723.294815]  [<c021cb59>] sys_stat64+0x19/0x30
[415723.294818]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[415723.294821]  [<c035a249>] ? copy_to_user+0x39/0x130
[415723.294824]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[415723.294828]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[415723.294831]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.294833] evolution     D f20e9cd4     0 29359      1 0x00000000
[415723.294837]  f20e9d14 00000086 00000080 f20e9cd4 c4478000 ffffff81 c08c=
3700 c08c3700
[415723.294841]  ee19e4de 00017a15 c08c3700 c08c3700 00000000 00017a15 0000=
0000 c08c3700
[415723.294846]  c08c3700 d049b2c0 c08fc500 c08fc500 c08fc500 f20e9d34 f20e=
9d78 c05c72df
[415723.294850] Call Trace:
[415723.294854]  [<c05c72df>] schedule_timeout+0x12f/0x270
[415723.294857]  [<c01589c0>] ? process_timeout+0x0/0x10
[415723.294861]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[415723.294874]  [<f882c32d>] nfs4_delay+0x2d/0x70 [nfs]
[415723.294886]  [<f882c50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[415723.294899]  [<f882e47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[415723.294908]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.294917]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.294922]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[415723.294926]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.294929]  [<c0223867>] link_path_walk+0x67/0x890
[415723.294933]  [<c02241b1>] path_walk+0x51/0xc0
[415723.294936]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.294939]  [<c0224e81>] user_path_at+0x41/0x80
[415723.294942]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[415723.294945]  [<c021cb30>] vfs_stat+0x20/0x30
[415723.294948]  [<c021cb59>] sys_stat64+0x19/0x30
[415723.294951]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.294954]  [<c01698a8>] ? lock_hrtimer_base+0x28/0x50
[415723.294960] uptrack-upgra D e9fa5cfc     0 11865  11864 0x00000000
[415723.294964]  e9fa5d0c 00000086 00000002 e9fa5cfc 00017a19 c05d89e0 c08c=
3700 c08c3700
[415723.294968]  1ed1c8f3 00017a19 c08c3700 c08c3700 1ed196bd 00017a19 0000=
0000 c08c3700
[415723.294973]  c08c3700 c5a558d0 00000001 e9fa5d40 00000000 e9fa5d48 e9fa=
5d14 f88198cc
[415723.294977] Call Trace:
[415723.294988]  [<f88198cc>] nfs_wait_bit_killable+0x1c/0x40 [nfs]
[415723.294992]  [<c05c761d>] __wait_on_bit+0x4d/0x70
[415723.295002]  [<f88198b0>] ? nfs_wait_bit_killable+0x0/0x40 [nfs]
[415723.295011]  [<f88198b0>] ? nfs_wait_bit_killable+0x0/0x40 [nfs]
[415723.295015]  [<c05c76eb>] out_of_line_wait_on_bit+0xab/0xc0
[415723.295018]  [<c0165e60>] ? wake_bit_function+0x0/0x50
[415723.295031]  [<f882c407>] nfs4_wait_clnt_recover+0x37/0x40 [nfs]
[415723.295044]  [<f882c4d3>] nfs4_handle_exception+0xc3/0x180 [nfs]
[415723.295057]  [<f883053e>] nfs4_do_open+0x8e/0xf0 [nfs]
[415723.295070]  [<f8830896>] nfs4_atomic_open+0x96/0x180 [nfs]
[415723.295079]  [<f8813173>] nfs_atomic_lookup+0x93/0x100 [nfs]
[415723.295082]  [<c05c8b6d>] ? _raw_spin_lock+0xd/0x10
[415723.295085]  [<c022b797>] ? d_alloc+0x117/0x170
[415723.295089]  [<c022317b>] do_lookup+0x15b/0x1c0
[415723.295092]  [<c022361d>] do_last+0x24d/0x3a0
[415723.295096]  [<c02251bd>] do_filp_open+0x19d/0x4c0
[415723.295101]  [<c0216a65>] do_sys_open+0x55/0x150
[415723.295105]  [<c0216bce>] sys_open+0x2e/0x40
[415723.295107]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.295110] gnome-screens D ed361cd4     0 23902   4269 0x00000000
[415723.295114]  ed361d14 00000086 00000080 ed361cd4 f5fa6000 ffffff81 c08c=
3700 c08c3700
[415723.295118]  cc6ee762 00017a17 c08c3700 c08c3700 00000001 00017a17 f5e6=
7e00 c08c3700
[415723.295123]  c08c3700 f344f230 f7090000 f7090000 f7090000 ed361d34 ed36=
1d78 c05c72df
[415723.295127] Call Trace:
[415723.295131]  [<c05c72df>] schedule_timeout+0x12f/0x270
[415723.295144]  [<f882e3b1>] ? _nfs4_proc_access+0xf1/0x170 [nfs]
[415723.295147]  [<c01589c0>] ? process_timeout+0x0/0x10
[415723.295151]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[415723.295164]  [<f882c32d>] nfs4_delay+0x2d/0x70 [nfs]
[415723.295176]  [<f882c50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[415723.295189]  [<f882e47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[415723.295197]  [<f8813edd>] nfs_do_access+0x7d/0xc0 [nfs]
[415723.295206]  [<f8813f98>] nfs_permission+0x78/0x1a0 [nfs]
[415723.295210]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[415723.295213]  [<c02212ea>] exec_permission+0x2a/0x90
[415723.295216]  [<c0223867>] link_path_walk+0x67/0x890
[415723.295220]  [<c02241b1>] path_walk+0x51/0xc0
[415723.295223]  [<c0224339>] do_path_lookup+0x59/0x90
[415723.295227]  [<c0224e81>] user_path_at+0x41/0x80
[415723.295230]  [<c0218534>] ? do_sync_read+0xa4/0xe0
[415723.295234]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[415723.295236]  [<c021cb30>] vfs_stat+0x20/0x30
[415723.295239]  [<c021cb59>] sys_stat64+0x19/0x30
[415723.295243]  [<c0219f9d>] ? fput+0x1d/0x30
[415723.295246]  [<c021691c>] ? filp_close+0x4c/0x80
[415723.295249]  [<c02169c5>] ? sys_close+0x75/0xc0
[415723.295252]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.295255] lsb_release   D 00000095     0 30540  30529 0x00000000
[415723.295259]  da947f2c 00000086 00000000 00000095 f42b0000 c2ce14c0 c08c=
3700 c08c3700
[415723.295263]  33bfe72a 000179a8 c08c3700 c08c3700 00000001 000179a8 f5db=
4c00 c08c3700
[415723.295268]  c08c3700 f1733f70 dc1d4008 cafac954 ffffffff cafac95c da94=
7f58 c05c7bbc
[415723.295272] Call Trace:
[415723.295276]  [<c05c7bbc>] __mutex_lock_killable_slowpath+0xdc/0x160
[415723.295280]  [<c05cc3fd>] ? do_page_fault+0x1cd/0x440
[415723.295283]  [<c05c7c74>] mutex_lock_killable+0x34/0x40
[415723.295286]  [<c0227494>] vfs_readdir+0x64/0xb0
[415723.295289]  [<c0227190>] ? filldir64+0x0/0xf0
[415723.295292]  [<c0227549>] sys_getdents64+0x69/0xc0
[415723.295294]  [<c05c90a4>] syscall_call+0x7/0xb
[415723.295302] Sched Debug Version: v0.09, 2.6.35-22-generic #33-Ubuntu

A reboot was required to resolve this.

Today, I found similar (although no errors about the state manager):

[64676.088847] SysRq : Show Blocked State
[64676.092628]   task                PC stack   pid father
[64676.092652] pulseaudio    D f36b1d34     0  3323      1 0x00000000
[64676.092652]  f36b1d44 00000086 00000002 f36b1d34 f879c917 c05d89e0 c08c3=
700 c08c3700
[64676.092652]  8e643a96 00003acf c08c3700 c08c3700 8e6404cd 00003acf 00000=
000 c08c3700
[64676.092652]  c08c3700 f3418000 00000001 c08fc500 c08fc500 f36b1d64 f36b1=
da8 c05c72df
[64676.092652] Call Trace:
[64676.092652]  [<f879c917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[64676.092652]  [<c05c72df>] schedule_timeout+0x12f/0x270
[64676.092652]  [<c01589c0>] ? process_timeout+0x0/0x10
[64676.092652]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[64676.092652]  [<f8c5a32d>] nfs4_delay+0x2d/0x70 [nfs]
[64676.092652]  [<f8c5a50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[64676.092652]  [<f8c5c47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[64676.092652]  [<f8c41edd>] nfs_do_access+0x7d/0xc0 [nfs]
[64676.092652]  [<f8c41f98>] nfs_permission+0x78/0x1a0 [nfs]
[64676.092652]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[64676.092652]  [<c02212ea>] exec_permission+0x2a/0x90
[64676.092652]  [<c0223867>] link_path_walk+0x67/0x890
[64676.092652]  [<c02306cf>] ? mntput_no_expire+0x1f/0xd0
[64676.092652]  [<c022510d>] do_filp_open+0xed/0x4c0
[64676.092652]  [<f8050b98>] ? nv_napi_poll+0x148/0x2e0 [forcedeth]
[64676.092652]  [<c01512cc>] ? __do_softirq+0xec/0x1b0
[64676.092652]  [<c022f0fd>] ? alloc_fd+0xbd/0xf0
[64676.092652]  [<c0216a65>] do_sys_open+0x55/0x150
[64676.092652]  [<c05cf665>] ? do_IRQ+0x55/0xc0
[64676.092652]  [<c0216bce>] sys_open+0x2e/0x40
[64676.092652]  [<c05c90a4>] syscall_call+0x7/0xb
[64676.092652] rhythmbox     D f3731d5c     0  3342   3227 0x00000000
[64676.092652]  f3731d6c 00000086 00000002 f3731d5c f879c917 c05d89e0 c08c3=
700 c08c3700
[64676.092652]  6c3d30ab 00003ad2 c08c3700 c08c3700 6c3cf7c6 00003ad2 00000=
000 c08c3700
[64676.092652]  c08c3700 f36f2610 00000001 c08fc500 c08fc500 f3731d8c f3731=
dd0 c05c72df
[64676.092652] Call Trace:
[64676.092652]  [<f879c917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[64676.092652]  [<c05c72df>] schedule_timeout+0x12f/0x270
[64676.092652]  [<c01589c0>] ? process_timeout+0x0/0x10
[64676.092652]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[64676.092652]  [<f8c5a32d>] nfs4_delay+0x2d/0x70 [nfs]
[64676.092652]  [<f8c5a50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[64676.092652]  [<f8c5c47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[64676.092652]  [<f8c41edd>] nfs_do_access+0x7d/0xc0 [nfs]
[64676.092652]  [<f8c41f98>] nfs_permission+0x78/0x1a0 [nfs]
[64676.092652]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[64676.092652]  [<c02212ea>] exec_permission+0x2a/0x90
[64676.092652]  [<c0223867>] link_path_walk+0x67/0x890
[64676.092652]  [<c02241b1>] path_walk+0x51/0xc0
[64676.092652]  [<c0224339>] do_path_lookup+0x59/0x90
[64676.092652]  [<c0224e81>] user_path_at+0x41/0x80
[64676.092652]  [<c032e626>] ? apparmor_file_permission+0x16/0x20
[64676.092652]  [<c016ffbd>] ? ktime_get_ts+0xed/0x120
[64676.092652]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[64676.092652]  [<c024ad63>] sys_inotify_add_watch+0x63/0x100
[64676.092652]  [<c0228829>] ? sys_poll+0x59/0xc0
[64676.092652]  [<c05c90a4>] syscall_call+0x7/0xb
[64676.092652] pidgin        D f37b7d04     0  3354   3227 0x00000000
[64676.092652]  f37b7d14 00000086 00000002 f37b7d04 f879c917 c05d89e0 c08c3=
700 c08c3700
[64676.092652]  680f2ffc 00003ad0 c08c3700 c08c3700 680efa47 00003ad0 00000=
000 c08c3700
[64676.092652]  c08c3700 f36f58d0 00000001 c08fc500 c08fc500 f37b7d34 f37b7=
d78 c05c72df
[64676.092652] Call Trace:
[64676.092652]  [<f879c917>] ? rpc_put_task+0x77/0x80 [sunrpc]
[64676.092652]  [<c05c72df>] schedule_timeout+0x12f/0x270
[64676.092652]  [<c01589c0>] ? process_timeout+0x0/0x10
[64676.092652]  [<c05c745a>] schedule_timeout_killable+0x1a/0x20
[64676.092652]  [<f8c5a32d>] nfs4_delay+0x2d/0x70 [nfs]
[64676.092652]  [<f8c5a50a>] nfs4_handle_exception+0xfa/0x180 [nfs]
[64676.092652]  [<f8c5c47e>] nfs4_proc_access+0x4e/0x60 [nfs]
[64676.092652]  [<f8c41edd>] nfs_do_access+0x7d/0xc0 [nfs]
[64676.092652]  [<f8c41f98>] nfs_permission+0x78/0x1a0 [nfs]
[64676.092652]  [<c022309a>] ? do_lookup+0x7a/0x1c0
[64676.092652]  [<c02212ea>] exec_permission+0x2a/0x90
[64676.092652]  [<c0223867>] link_path_walk+0x67/0x890
[64676.092652]  [<c02241b1>] path_walk+0x51/0xc0
[64676.092652]  [<c0224339>] do_path_lookup+0x59/0x90
[64676.092652]  [<c0224e81>] user_path_at+0x41/0x80
[64676.092652]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[64676.092652]  [<c021cb30>] vfs_stat+0x20/0x30
[64676.092652]  [<c021cb59>] sys_stat64+0x19/0x30
[64676.092652]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[64676.092652]  [<c035a249>] ? copy_to_user+0x39/0x130
[64676.092652]  [<c016fc76>] ? do_gettimeofday+0x16/0x40
[64676.092652]  [<c0150146>] ? sys_gettimeofday+0x36/0x70
[64676.092652]  [<c05c90a4>] syscall_call+0x7/0xb
[64676.092652] sensors-apple D f0cd9c44     0  3778      1 0x00000000
[64676.092652]  f0cd9c54 00000086 00000002 f0cd9c44 f0cd9c18 c05d89e0 c08c3=
700 c08c3700
[64676.092652]  5929818f 00003ad2 c08c3700 c08c3700 59294ecf 00003ad2 00000=
000 c08c3700
[64676.092652]  c08c3700 f1abd8d0 00000001 f0cd9c88 00000000 f0cd9c90 f0cd9=
c5c f879cc0c
[64676.092652] Call Trace:
[64676.092652]  [<f879cc0c>] rpc_wait_bit_killable+0x1c/0x40 [sunrpc]
[64676.092652]  [<c05c761d>] __wait_on_bit+0x4d/0x70
[64676.092652]  [<f879cbf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[64676.092652]  [<f879cbf0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[64676.092652]  [<c05c76eb>] out_of_line_wait_on_bit+0xab/0xc0
[64676.092652]  [<c0165e60>] ? wake_bit_function+0x0/0x50
[64676.092652]  [<f879d31b>] __rpc_execute+0xdb/0x250 [sunrpc]
[64676.092652]  [<f879ca17>] ? rpc_init_task+0xd7/0x120 [sunrpc]
[64676.092652]  [<c01449b8>] ? dequeue_entity+0x1c8/0x210
[64676.092652]  [<f879d4fe>] rpc_execute+0x6e/0x80 [sunrpc]
[64676.092652]  [<f87969af>] rpc_run_task+0x1f/0x30 [sunrpc]
[64676.092652]  [<f8796abe>] rpc_call_sync+0x3e/0x60 [sunrpc]
[64676.092652]  [<f8c5d5e2>] _nfs4_call_sync+0x22/0x30 [nfs]
[64676.092652]  [<f8c5c3a3>] _nfs4_proc_access+0xe3/0x170 [nfs]
[64676.092652]  [<f8c5c469>] nfs4_proc_access+0x39/0x60 [nfs]
[64676.092652]  [<f8c41edd>] nfs_do_access+0x7d/0xc0 [nfs]
[64676.092652]  [<f8c41f98>] nfs_permission+0x78/0x1a0 [nfs]
[64676.092652]  [<c02306cf>] ? mntput_no_expire+0x1f/0xd0
[64676.092652]  [<c02212ea>] exec_permission+0x2a/0x90
[64676.092652]  [<c0223867>] link_path_walk+0x67/0x890
[64676.092652]  [<c02241b1>] path_walk+0x51/0xc0
[64676.092652]  [<c0224339>] do_path_lookup+0x59/0x90
[64676.092652]  [<c0224e81>] user_path_at+0x41/0x80
[64676.092652]  [<c0139665>] ? update_curr+0x175/0x2a0
[64676.092652]  [<c016bf14>] ? sched_clock_local+0xa4/0x180
[64676.092652]  [<c0139cb6>] ? __dequeue_entity+0x26/0x50
[64676.092652]  [<c021c9da>] vfs_fstatat+0x3a/0x70
[64676.092652]  [<c021cb30>] vfs_stat+0x20/0x30
[64676.092652]  [<c021cb59>] sys_stat64+0x19/0x30
[64676.092652]  [<c016fb56>] ? getnstimeofday+0x56/0x120
[64676.092652]  [<c05c90a4>] syscall_call+0x7/0xb
[64676.092652] Sched Debug Version: v0.09, 2.6.35-22-generic #33-Ubuntu

Any ideas what's going on here?  If there isn't enough info here, I'd
more than happy to gather and post whatever is needed.

Thanx,
b.


--=-fJKg+e3doScWFZQLIw5L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAky7K6QACgkQl3EQlGLyuXC56wCdHg87eh6+xOqfNA4PtuXsJaKJ
zMMAoKq6J1mxGe++VJhiPdC+8s5yusXV
=/GjE
-----END PGP SIGNATURE-----

--=-fJKg+e3doScWFZQLIw5L--
