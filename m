Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:12703 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab1JVQIw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2011 12:08:52 -0400
Subject: Re: NFS4 client blocked (kernel 3.0.7)
From: Dilip Daya <dilip.daya@hp.com>
Reply-To: dilip.daya@hp.com
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: David Flynn <davidf@rd.bbc.co.uk>
In-Reply-To: <20111022082838.GB32587@rd.bbc.co.uk>
References: <20111022082838.GB32587@rd.bbc.co.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 22 Oct 2011 12:00:18 -0400
Message-ID: <1319299218.2590.10.camel@pro6455b.example.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See below...

0n Sat, 2011-10-22 at 08:28 +0000, David Flynn wrote: 
> Dear all,
> 
> When mounting a solaris NFS4 export on a v3.0.4 client, we've experienced
> processes becoming blocked.  Any further attempt to access the mountpoint
> from another process also blocks.  Other mountpoints are unaffected.
> I have not identified a test case to reproduce the behaviour.
> 
> Any thoughts on the matter would be most welcome,
> 
> Kind regards,
> 
> ..david
> 
> from /proc/mounts:
> home:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.29.190.20,minorversion=0,local_lock=none,addr=172.29.120.140 0 0
> 
> [105121.204200] INFO: task bash:4457 blocked for more than 120 seconds.
> [105121.247424] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [105121.299955] bash            D ffffffff818050a0     0  4457      1 0x00000000
> [105121.347840]  ffff8802954b5c28 0000000000000082 ffff8802954b5db8 0000000000012a40
> [105121.397793]  ffff8802954b5fd8 0000000000012a40 ffff8802954b4000 0000000000012a40
> [105121.441724]  0000000000012a40 0000000000012a40 ffff8802954b5fd8 0000000000012a40
> [105121.441728] Call Trace:
> [105121.441740]  [<ffffffff81110030>] ? __lock_page+0x70/0x70
> [105121.441744]  [<ffffffff8160007c>] io_schedule+0x8c/0xd0
> [105121.441746]  [<ffffffff8111003e>] sleep_on_page+0xe/0x20
> [105121.441749]  [<ffffffff816008ff>] __wait_on_bit+0x5f/0x90
> [105121.441751]  [<ffffffff81110203>] wait_on_page_bit+0x73/0x80
> [105121.441756]  [<ffffffff81085bf0>] ? autoremove_wake_function+0x40/0x40
> [105121.441759]  [<ffffffff8111c5e5>] ? pagevec_lookup_tag+0x25/0x40
> [105121.441761]  [<ffffffff81110436>] filemap_fdatawait_range+0xf6/0x1a0
> [105121.441786]  [<ffffffffa023a7d0>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
> [105121.441789]  [<ffffffff8111bae1>] ? do_writepages+0x21/0x40
> [105121.441791]  [<ffffffff811116bb>] ? __filemap_fdatawrite_range+0x5b/0x60
> [105121.441793]  [<ffffffff8111050b>] filemap_fdatawait+0x2b/0x30
> [105121.441795]  [<ffffffff81112124>] filemap_write_and_wait+0x44/0x60
> [105121.441803]  [<ffffffffa0232805>] nfs_getattr+0x105/0x120 [nfs]
> [105121.441806]  [<ffffffff81605e88>] ? do_page_fault+0x258/0x550
> [105121.441810]  [<ffffffff81175b31>] vfs_getattr+0x51/0x120
> [105121.441812]  [<ffffffff81175c70>] vfs_fstatat+0x70/0x90
> [105121.441814]  [<ffffffff81175ccb>] vfs_stat+0x1b/0x20
> [105121.441816]  [<ffffffff81175f14>] sys_newstat+0x24/0x40
> [105121.441820]  [<ffffffff8101449a>] ? init_fpu+0x4a/0x150
> [105121.441822]  [<ffffffff81602955>] ? page_fault+0x25/0x30
> [105121.441825]  [<ffffffff8160a702>] system_call_fastpath+0x16/0x1b
> [105121.441837] INFO: task bash:5612 blocked for more than 120 seconds.
> [105121.441838] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [105121.441840] bash            D 0000000000000005     0  5612      1 0x00000000
> [105121.441843]  ffff8801f25d5ca8 0000000000000086 ffff8800163e9b08 0000000000012a40
> [105121.441845]  ffff8801f25d5fd8 0000000000012a40 ffff8801f25d4000 0000000000012a40
> [105121.441848]  0000000000012a40 0000000000012a40 ffff8801f25d5fd8 0000000000012a40
> [105121.441850] Call Trace:
> [105121.441853]  [<ffffffff81110030>] ? __lock_page+0x70/0x70
> [105121.441855]  [<ffffffff8160007c>] io_schedule+0x8c/0xd0
> [105121.441857]  [<ffffffff8111003e>] sleep_on_page+0xe/0x20
> [105121.441859]  [<ffffffff816008ff>] __wait_on_bit+0x5f/0x90
> [105121.441861]  [<ffffffff81110203>] wait_on_page_bit+0x73/0x80
> [105121.441863]  [<ffffffff81085bf0>] ? autoremove_wake_function+0x40/0x40
> [105121.441866]  [<ffffffff8111c5e5>] ? pagevec_lookup_tag+0x25/0x40
> [105121.441868]  [<ffffffff81110436>] filemap_fdatawait_range+0xf6/0x1a0
> [105121.441876]  [<ffffffffa023a7d0>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
> [105121.441878]  [<ffffffff8111bae1>] ? do_writepages+0x21/0x40
> [105121.441880]  [<ffffffff811116bb>] ? __filemap_fdatawrite_range+0x5b/0x60
> [105121.441882]  [<ffffffff81111730>] filemap_write_and_wait_range+0x70/0x80
> [105121.441886]  [<ffffffff8119cc6a>] vfs_fsync_range+0x5a/0x90
> [105121.441888]  [<ffffffff8119cd0c>] vfs_fsync+0x1c/0x20
> [105121.441894]  [<ffffffffa022ec74>] nfs_file_flush+0x54/0x80 [nfs]
> [105121.441898]  [<ffffffff8116ee7f>] filp_close+0x3f/0x90
> [105121.441900]  [<ffffffff8116f8a7>] sys_close+0xb7/0x120
> [105121.441902]  [<ffffffff8160a702>] system_call_fastpath+0x16/0x1b
> --

Same issue!

In my case I have NFS client & server  both with Linux kernel
v3.0.7-stable.


Kernel: v3.0.7-stable (amd64)

# nfsstat -m
/opt/xorsyst/nfs_test from 192.168.1.53:/opt/xorsyst/nfs_test
Flags:
rw,relatime,vers=4,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,port=0,timeo=600,retrans=6,sec=sys,clientaddr=192.168.1.52,minorversion=0,local_lock=none,addr=192.168.1.53


[48315.746955] nfs: server 192.168.1.53 not responding, still trying
[48315.748133] nfs: server 192.168.1.53 not responding, still trying
[48482.012303] INFO: task fblockio:15607 blocked for more than 120
seconds.
[48482.013506] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.014924] fblockio        D ffff8800775bc420     0 15607  27608
0x00000000
[48482.016298]  ffff88006fbd3c48 0000000000000046 ffff88006fbd3bf8
ffffffff81079174
[48482.017636]  ffff88006fbd2010 ffff8800775bc140 00000000001d2f00
ffff88006fbd3fd8
[48482.018959]  ffff88006fbd3fd8 00000000001d2f00 ffff8800807aa280
ffff8800775bc140
[48482.020370] Call Trace:
[48482.020901]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48482.022083]  [<ffffffff8137c6ca>] ? __mutex_lock_common+0x239/0x390
[48482.023484]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.024905]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.026346]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.027523]  [<ffffffff8137c6da>] __mutex_lock_common+0x249/0x390
[48482.028909]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.030328]  [<ffffffff8100e7e9>] ? sched_clock+0x9/0xd
[48482.031498]  [<ffffffff8137c91c>] mutex_lock_nested+0x3b/0x40
[48482.032794]  [<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.034191]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48482.035409]  [<ffffffffa04d2375>] nfs_file_write+0xda/0x172 [nfs]
[48482.036767]  [<ffffffff81115e0b>] do_sync_write+0xc6/0x103
[48482.038010]  [<ffffffff81077e18>] ? trace_hardirqs_off+0xd/0xf
[48482.039343]  [<ffffffff811170b1>] ? fget_light+0xa3/0xc6
[48482.040552]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48482.041834]  [<ffffffff81077e18>] ? trace_hardirqs_off+0xd/0xf
[48482.043153]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.044635]  [<ffffffff811167c8>] vfs_write+0xac/0x108
[48482.045777]  [<ffffffff811170c9>] ? fget_light+0xbb/0xc6
[48482.046968]  [<ffffffff8111687c>] sys_pwrite64+0x58/0x77
[48482.048229]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.049577] 1 lock held by fblockio/15607:
[48482.050821]  #0:  (&sb->s_type->i_mutex_key#15){+.+.+.}, at:
[<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.053225] INFO: task fblockio:10308 blocked for more than 120
seconds.
[48482.054715] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.056469] fblockio        D ffff88010b604d60     0 10308  27608
0x00000000
[48482.058130]  ffff88008aeafc48 0000000000000046 ffff88008aeafbf8
ffffffff81079174
[48482.059717]  ffff88008aeae010 ffff88010b604a80 00000000001d2f00
ffff88008aeaffd8
[48482.061368]  ffff88008aeaffd8 00000000001d2f00 ffff880000184840
ffff88010b604a80
[48482.063002] Call Trace:
[48482.063541]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48482.064743]  [<ffffffff8137c6ca>] ? __mutex_lock_common+0x239/0x390
[48482.066147]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.067557]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.068987]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.070152]  [<ffffffff8137c6da>] __mutex_lock_common+0x249/0x390
[48482.071507]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.072934]  [<ffffffff8137c91c>] mutex_lock_nested+0x3b/0x40
[48482.074224]  [<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.075617]  [<ffffffff8100f216>] ? native_sched_clock+0x2d/0x5f
[48482.076977]  [<ffffffffa04d2375>] nfs_file_write+0xda/0x172 [nfs]
[48482.078353]  [<ffffffff81046ee5>] ? finish_task_switch+0x82/0xef
[48482.079704]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48482.081059]  [<ffffffff81115e0b>] do_sync_write+0xc6/0x103
[48482.082310]  [<ffffffff81077e68>] ? lock_release_holdtime+0x2c/0xd7
[48482.083704]  [<ffffffff8137ddfd>] ? _raw_spin_unlock_irq+0x2b/0x37
[48482.085090]  [<ffffffff81046ea7>] ? finish_task_switch+0x44/0xef
[48482.086434]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.087886]  [<ffffffff811167c8>] vfs_write+0xac/0x108
[48482.089054]  [<ffffffff81117047>] ? fget_light+0x39/0xc6
[48482.090250]  [<ffffffff811168e3>] sys_write+0x48/0x72
[48482.091424]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.092775] 1 lock held by fblockio/10308:
[48482.093700]  #0:  (&sb->s_type->i_mutex_key#15){+.+.+.}, at:
[<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.096034] INFO: task fblockio:10349 blocked for more than 120
seconds.
[48482.097514] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.099196] fblockio        D ffff880007de83e0     0 10349  27608
0x00000000
[48482.100796]  ffff880004111c48 0000000000000046 ffff880004111bf8
ffffffff81079174
[48482.102476]  ffff880004110010 ffff880007de8100 00000000001d2f00
ffff880004111fd8
[48482.104136]  ffff880004111fd8 00000000001d2f00 ffff8800b1066a00
ffff880007de8100
[48482.105775] Call Trace:
[48482.106359]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48482.107551]  [<ffffffff8137c6ca>] ? __mutex_lock_common+0x239/0x390
[48482.108961]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.110380]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.111792]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.112979]  [<ffffffff8137c6da>] __mutex_lock_common+0x249/0x390
[48482.114360]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48482.115771]  [<ffffffff8137c91c>] mutex_lock_nested+0x3b/0x40
[48482.117084]  [<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.118485]  [<ffffffff8100f216>] ? native_sched_clock+0x2d/0x5f
[48482.119847]  [<ffffffffa04d2375>] nfs_file_write+0xda/0x172 [nfs]
[48482.121225]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48482.122516]  [<ffffffff81115e0b>] do_sync_write+0xc6/0x103
[48482.123786]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.125263]  [<ffffffff811167c8>] vfs_write+0xac/0x108
[48482.126443]  [<ffffffff81117047>] ? fget_light+0x39/0xc6
[48482.127635]  [<ffffffff811168e3>] sys_write+0x48/0x72
[48482.128784]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.130130] 1 lock held by fblockio/10349:
[48482.130999]  #0:  (&sb->s_type->i_mutex_key#15){+.+.+.}, at:
[<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.133397] INFO: task fblockio:6007 blocked for more than 120
seconds.
[48482.134903] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.136659] fblockio        D ffff880055e48660     0  6007  27608
0x00000000
[48482.138299]  ffff8800129779f8 0000000000000046 0000000000000006
0000000000000002
[48482.139882]  ffff880012976010 ffff880055e48380 00000000001d2f00
ffff880012977fd8
[48482.141603]  ffff880012977fd8 00000000001d2f00 ffff8800b1066a00
ffff880055e48380
[48482.143207] Call Trace:
[48482.143726]  [<ffffffff810cad31>] ? __lock_page+0x68/0x68
[48482.144947]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.146075]  [<ffffffff8137bcff>] io_schedule+0x87/0xca
[48482.147298]  [<ffffffff810cad3a>] sleep_on_page+0x9/0xd
[48482.148483]  [<ffffffff8137c15c>] __wait_on_bit+0x43/0x76
[48482.149686]  [<ffffffff810caf0d>] wait_on_page_bit+0x6d/0x74
[48482.150954]  [<ffffffff810673db>] ? autoremove_wake_function
+0x34/0x34
[48482.152432]  [<ffffffff810cc365>] grab_cache_page_write_begin
+0xa4/0xb6
[48482.153895]  [<ffffffffa04d19b1>] nfs_write_begin+0xc3/0x1b8 [nfs]
[48482.155289]  [<ffffffffa04d18d6>] ? nfs_write_end+0x11e/0x136 [nfs]
[48482.161747]  [<ffffffff810c9f13>] ? iov_iter_copy_from_user_atomic
+0x7c/0xec
[48482.162963]  [<ffffffff810ca219>] generic_file_buffered_write
+0x101/0x262
[48482.164222]  [<ffffffff810cb7cc>] __generic_file_aio_write
+0x240/0x275
[48482.165397]  [<ffffffff810cb861>] generic_file_aio_write+0x60/0xb7
[48482.166574]  [<ffffffffa04d2375>] nfs_file_write+0xda/0x172 [nfs]
[48482.167666]  [<ffffffff81115e0b>] do_sync_write+0xc6/0x103
[48482.168670]  [<ffffffff81077e18>] ? trace_hardirqs_off+0xd/0xf
[48482.169715]  [<ffffffff811170b1>] ? fget_light+0xa3/0xc6
[48482.170679]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48482.171720]  [<ffffffff81077e18>] ? trace_hardirqs_off+0xd/0xf
[48482.182801]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.189220]  [<ffffffff811167c8>] vfs_write+0xac/0x108
[48482.190105]  [<ffffffff811170c9>] ? fget_light+0xbb/0xc6
[48482.191026]  [<ffffffff8111687c>] sys_pwrite64+0x58/0x77
[48482.192018]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.193146] 1 lock held by fblockio/6007:
[48482.193883]  #0:  (&sb->s_type->i_mutex_key#15){+.+.+.}, at:
[<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48482.195830] INFO: task fblockio:11226 blocked for more than 120
seconds.
[48482.197056] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.198472] fblockio        D ffff8800043caa60     0 11226  27608
0x00000000
[48482.199900]  ffff8800158d1b58 0000000000000046 ffff8800043ca780
ffff8800043cad88
[48482.201668]  ffff8800158d0010 ffff8800043ca780 00000000001d2f00
ffff8800158d1fd8
[48482.213513]  ffff8800158d1fd8 00000000001d2f00 ffff8800bf5ac6c0
ffff8800043ca780
[48482.215072] Call Trace:
[48482.215650]  [<ffffffff810cad31>] ? __lock_page+0x68/0x68
[48482.216792]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.217857]  [<ffffffff8137bcff>] io_schedule+0x87/0xca
[48482.218998]  [<ffffffff810cad3a>] sleep_on_page+0x9/0xd
[48482.220216]  [<ffffffff8137c05c>] __wait_on_bit_lock+0x41/0x8a
[48482.221477]  [<ffffffff810cad2a>] __lock_page+0x61/0x68
[48482.222621]  [<ffffffff810673db>] ? autoremove_wake_function
+0x34/0x34
[48482.224047]  [<ffffffff810d5584>] lock_page+0x37/0x3b
[48482.225163]  [<ffffffff810d5624>] invalidate_inode_pages2_range
+0x9c/0x2f3
[48482.226687]  [<ffffffffa04f77f1>] ? rcu_read_lock_held+0x22/0x22
[nfs]
[48482.228098]  [<ffffffff810d588a>] invalidate_inode_pages2+0xf/0x11
[48482.229454]  [<ffffffffa04d4160>] nfs_revalidate_mapping+0x72/0xfc
[nfs]
[48482.245312]  [<ffffffffa04d24a1>] nfs_file_read+0x94/0xd1 [nfs]
[48482.246327]  [<ffffffff81115f0e>] do_sync_read+0xc6/0x103
[48482.247359]  [<ffffffff81189dca>] ? fsnotify_perm+0x64/0x70
[48482.248366]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.249517]  [<ffffffff811169b6>] vfs_read+0xa9/0x105
[48482.250442]  [<ffffffff811170c9>] ? fget_light+0xbb/0xc6
[48482.251421]  [<ffffffff81116a6a>] sys_pread64+0x58/0x77
[48482.252383]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.253680] no locks held by fblockio/11226.
[48482.254674] INFO: task fblockio:11240 blocked for more than 120
seconds.
[48482.256188] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.257945] fblockio        D ffff880081b027e0     0 11240  27608
0x00000000
[48482.259472]  ffff8800806cdb58 0000000000000046 ffff880081b02500
ffff880081b02b08
[48482.261177]  ffff8800806cc010 ffff880081b02500 00000000001d2f00
ffff8800806cdfd8
[48482.272504]  ffff8800806cdfd8 00000000001d2f00 ffff88008285c7c0
ffff880081b02500
[48482.274188] Call Trace:
[48482.274696]  [<ffffffff810cad31>] ? __lock_page+0x68/0x68
[48482.275942]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.277056]  [<ffffffff8137bcff>] io_schedule+0x87/0xca
[48482.282992]  [<ffffffff810cad3a>] sleep_on_page+0x9/0xd
[48482.283943]  [<ffffffff8137c05c>] __wait_on_bit_lock+0x41/0x8a
[48482.285032]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48482.286042]  [<ffffffff810cad2a>] __lock_page+0x61/0x68
[48482.286969]  [<ffffffff810673db>] ? autoremove_wake_function
+0x34/0x34
[48482.288136]  [<ffffffff810d5584>] lock_page+0x37/0x3b
[48482.289001]  [<ffffffff810d5624>] invalidate_inode_pages2_range
+0x9c/0x2f3
[48482.290216]  [<ffffffff810d588a>] invalidate_inode_pages2+0xf/0x11
[48482.291302]  [<ffffffffa04d4160>] nfs_revalidate_mapping+0x72/0xfc
[nfs]
[48482.307024]  [<ffffffffa04d24a1>] nfs_file_read+0x94/0xd1 [nfs]
[48482.308060]  [<ffffffff81115f0e>] do_sync_read+0xc6/0x103
[48482.309025]  [<ffffffff81189dca>] ? fsnotify_perm+0x64/0x70
[48482.310048]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.311279]  [<ffffffff811169b6>] vfs_read+0xa9/0x105
[48482.312233]  [<ffffffff811170c9>] ? fget_light+0xbb/0xc6
[48482.313182]  [<ffffffff81116a6a>] sys_pread64+0x58/0x77
[48482.314129]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.315210] no locks held by fblockio/11240.
[48482.315978] INFO: task fblockio:11252 blocked for more than 120
seconds.
[48482.317221] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.318614] fblockio        D ffff880106a408e0     0 11252  27608
0x00000000
[48482.320390]  ffff880129c79b58 0000000000000046 ffff880106a40600
ffff880106a40c08
[48482.336509]  ffff880129c78010 ffff880106a40600 00000000001d2f00
ffff880129c79fd8
[48482.337841]  ffff880129c79fd8 00000000001d2f00 ffff880081282600
ffff880106a40600
[48482.339222] Call Trace:
[48482.339748]  [<ffffffff810cad31>] ? __lock_page+0x68/0x68
[48482.340999]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.342105]  [<ffffffff8137bcff>] io_schedule+0x87/0xca
[48482.343242]  [<ffffffff810cad3a>] sleep_on_page+0x9/0xd
[48482.344449]  [<ffffffff8137c05c>] __wait_on_bit_lock+0x41/0x8a
[48482.345739]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48482.347083]  [<ffffffff810cad2a>] __lock_page+0x61/0x68
[48482.348290]  [<ffffffff810673db>] ? autoremove_wake_function
+0x34/0x34
[48482.349743]  [<ffffffff810d5584>] lock_page+0x37/0x3b
[48482.350877]  [<ffffffff810d5624>] invalidate_inode_pages2_range
+0x9c/0x2f3
[48482.352434]  [<ffffffff810d588a>] invalidate_inode_pages2+0xf/0x11
[48482.368385]  [<ffffffffa04d4160>] nfs_revalidate_mapping+0x72/0xfc
[nfs]
[48482.369546]  [<ffffffffa04d24a1>] nfs_file_read+0x94/0xd1 [nfs]
[48482.370601]  [<ffffffff81115f0e>] do_sync_read+0xc6/0x103
[48482.371582]  [<ffffffff81189dca>] ? fsnotify_perm+0x64/0x70
[48482.372609]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.373816]  [<ffffffff811169b6>] vfs_read+0xa9/0x105
[48482.374734]  [<ffffffff811170c9>] ? fget_light+0xbb/0xc6
[48482.375700]  [<ffffffff81116a6a>] sys_pread64+0x58/0x77
[48482.376668]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.377737] no locks held by fblockio/11252.
[48482.378525] INFO: task fblockio:10681 blocked for more than 120
seconds.
[48482.379734] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48482.381160] fblockio        D ffff880081b32de0     0 10681  27608
0x00000000
[48482.382629]  ffff88012a6b9b58 0000000000000046 ffff880081b32b00
ffff880081b33108
[48482.398142]  ffff88012a6b8010 ffff880081b32b00 00000000001d2f00
ffff88012a6b9fd8
[48482.399569]  ffff88012a6b9fd8 00000000001d2f00 ffff8800814ce0c0
ffff880081b32b00
[48482.400918] Call Trace:
[48482.401467]  [<ffffffff810cad31>] ? __lock_page+0x68/0x68
[48482.402681]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48482.403796]  [<ffffffff8137bcff>] io_schedule+0x87/0xca
[48482.405002]  [<ffffffff810cad3a>] sleep_on_page+0x9/0xd
[48482.406182]  [<ffffffff8137c05c>] __wait_on_bit_lock+0x41/0x8a
[48482.407500]  [<ffffffff810cad2a>] __lock_page+0x61/0x68
[48482.408754]  [<ffffffff810673db>] ? autoremove_wake_function
+0x34/0x34
[48482.410205]  [<ffffffff810d5584>] lock_page+0x37/0x3b
[48482.411340]  [<ffffffff810d5624>] invalidate_inode_pages2_range
+0x9c/0x2f3
[48482.412901]  [<ffffffff81104a9a>] ? virt_to_slab+0x9/0x3b
[48482.414095]  [<ffffffff810d588a>] invalidate_inode_pages2+0xf/0x11
[48482.430079]  [<ffffffffa04d4160>] nfs_revalidate_mapping+0x72/0xfc
[nfs]
[48482.435915]  [<ffffffffa04d24a1>] nfs_file_read+0x94/0xd1 [nfs]
[48482.436960]  [<ffffffff81115f0e>] do_sync_read+0xc6/0x103
[48482.437949]  [<ffffffff81189dca>] ? fsnotify_perm+0x64/0x70
[48482.438956]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48482.440177]  [<ffffffff811169b6>] vfs_read+0xa9/0x105
[48482.441076]  [<ffffffff81117047>] ? fget_light+0x39/0xc6
[48482.442033]  [<ffffffff81116ad1>] sys_read+0x48/0x72
[48482.442954]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48482.444102] no locks held by fblockio/10681.
[48602.444332] INFO: task fblockio:15607 blocked for more than 120
seconds.
[48602.445536] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48602.446957] fblockio        D ffff8800775bc420     0 15607  27608
0x00000000
[48602.448439]  ffff88006fbd3c48 0000000000000046 ffff88006fbd3bf8
ffffffff81079174
[48602.450107]  ffff88006fbd2010 ffff8800775bc140 00000000001d2f00
ffff88006fbd3fd8
[48602.451786]  ffff88006fbd3fd8 00000000001d2f00 ffff8800807aa280
ffff8800775bc140
[48602.453520] Call Trace:
[48602.454072]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48602.455272]  [<ffffffff8137c6ca>] ? __mutex_lock_common+0x239/0x390
[48602.456703]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48602.458101]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48602.459517]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48602.460671]  [<ffffffff8137c6da>] __mutex_lock_common+0x249/0x390
[48602.462015]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48602.463466]  [<ffffffff8100e7e9>] ? sched_clock+0x9/0xd
[48602.464690]  [<ffffffff8137c91c>] mutex_lock_nested+0x3b/0x40
[48602.465964]  [<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48602.467355]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48602.468604]  [<ffffffffa04d2375>] nfs_file_write+0xda/0x172 [nfs]
[48602.470235]  [<ffffffff81115e0b>] do_sync_write+0xc6/0x103
[48602.471279]  [<ffffffff81077e18>] ? trace_hardirqs_off+0xd/0xf
[48602.472398]  [<ffffffff811170b1>] ? fget_light+0xa3/0xc6
[48602.473362]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48602.474395]  [<ffffffff81077e18>] ? trace_hardirqs_off+0xd/0xf
[48602.475458]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48602.476671]  [<ffffffff811167c8>] vfs_write+0xac/0x108
[48602.477578]  [<ffffffff811170c9>] ? fget_light+0xbb/0xc6
[48602.478497]  [<ffffffff8111687c>] sys_pwrite64+0x58/0x77
[48602.479462]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48602.480553] 1 lock held by fblockio/15607:
[48602.481341]  #0:  (&sb->s_type->i_mutex_key#15){+.+.+.}, at:
[<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48602.483450] INFO: task fblockio:10308 blocked for more than 120
seconds.
[48602.484970] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[48602.486702] fblockio        D ffff88010b604d60     0 10308  27608
0x00000000
[48602.488287]  ffff88008aeafc48 0000000000000046 ffff88008aeafbf8
ffffffff81079174
[48602.489975]  ffff88008aeae010 ffff88010b604a80 00000000001d2f00
ffff88008aeaffd8
[48602.491565]  ffff88008aeaffd8 00000000001d2f00 ffff880000184840
ffff88010b604a80
[48602.493258] Call Trace:
[48602.493793]  [<ffffffff81079174>] ? mark_lock+0x2d/0x235
[48602.494987]  [<ffffffff8137c6ca>] ? __mutex_lock_common+0x239/0x390
[48602.496408]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48602.497825]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48602.499238]  [<ffffffff8137bc76>] schedule+0x55/0x57
[48602.500384]  [<ffffffff8137c6da>] __mutex_lock_common+0x249/0x390
[48602.501754]  [<ffffffff810cb845>] ? generic_file_aio_write+0x44/0xb7
[48602.503183]  [<ffffffff8137c91c>] mutex_lock_nested+0x3b/0x40
[48602.504515]  [<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7
[48602.505901]  [<ffffffff8100f216>] ? native_sched_clock+0x2d/0x5f
[48602.507247]  [<ffffffffa04d2375>] nfs_file_write+0xda/0x172 [nfs]
[48602.508626]  [<ffffffff81046ee5>] ? finish_task_switch+0x82/0xef
[48602.509973]  [<ffffffff8106ca9a>] ? sched_clock_cpu+0xc3/0xce
[48602.511257]  [<ffffffff81115e0b>] do_sync_write+0xc6/0x103
[48602.512511]  [<ffffffff81077e68>] ? lock_release_holdtime+0x2c/0xd7
[48602.513917]  [<ffffffff8137ddfd>] ? _raw_spin_unlock_irq+0x2b/0x37
[48602.515344]  [<ffffffff81046ea7>] ? finish_task_switch+0x44/0xef
[48602.516711]  [<ffffffff81189e2d>] ? security_file_permission
+0x29/0x2e
[48602.518152]  [<ffffffff811167c8>] vfs_write+0xac/0x108
[48602.519326]  [<ffffffff81117047>] ? fget_light+0x39/0xc6
[48602.520530]  [<ffffffff811168e3>] sys_write+0x48/0x72
[48602.521675]  [<ffffffff81383a12>] system_call_fastpath+0x16/0x1b
[48602.523012] 1 lock held by fblockio/10308:
[48602.523962]  #0:  (&sb->s_type->i_mutex_key#15){+.+.+.}, at:
[<ffffffff810cb845>] generic_file_aio_write+0x44/0xb7

Thanking everyone in advance for any guidance or pointers to upstream
patches that I could try and provide feedback.
 
-DilipD.

