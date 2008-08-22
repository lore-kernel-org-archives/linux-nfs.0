From: Ian Campbell <ijc@hellion.org.uk>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS
	export.
Date: Fri, 22 Aug 2008 11:23:43 +0100
Message-ID: <1219400624.18774.67.camel@zakaz.uk.xensource.com>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xGIro9u1WVMxjSPc4za8"
Cc: Grant Coady <gcoady.lk@gmail.com>, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759965AbYHVKZB@vger.kernel.org>
In-Reply-To: <1219087258.7192.19.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-xGIro9u1WVMxjSPc4za8
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2008-08-18 at 15:20 -0400, Trond Myklebust wrote:
> Please try to reproduce the hang, then do
> 
> 	echo 0 >/proc/sys/sunrpc/rpc_debug
> 
> and send the output from 'dmesg'...

I've also been seeing some NFS related lockups, although I'm not sure if
they are the same as the one in this thread or not. Client is 2.6.26
(Debian's kernel) and Server is 2.6.25 (also a Debian kernel, but from
backports.org).

rpc_debug on the server gives nothing, on the client gives:
[144741.637997] -pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait -action- ---ops--
[144741.637997]  3439 0004 0080    -11 f3f48200 100003 f7770000        0 xprt_sending fa0ae88e fa0bddf4
[144741.637997]  3438 0001 00a0      0 f77f2a00 100003 f77700d0    15000 xprt_pending fa0ae88e fa0bddf4

There are no processes running with pid 3439 3438 (I don't think it's
that sort of pid though).

mounts points are:
hopkins:/storage/music /storage/music nfs rw,nosuid,vers=3,rsize=32768,wsize=32768,namlen=255,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=192.168.1.6 0 0
hopkins:/storage/mythtv/recordings /var/lib/mythtv/recordings nfs rw,nosuid,vers=3,rsize=32768,wsize=32768,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=192.168.1.6 0 0
hopkins:/var/lib/mythvideo /var/lib/mythvideo nfs rw,nosuid,vers=3,rsize=32768,wsize=32768,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=192.168.1.6 0 0
hopkins:/storage/home/ijc /home/ijc nfs rw,vers=3,rsize=131072,wsize=131072,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=192.168.1.6 0 0
and all seem to be effected.

It hasn't happened this time (yet) but usually I get a hung task
backtrace like this:
Aug  4 06:27:28 iranon kernel: [137969.382277] INFO: task mythbackend:3161 blocked for more than 120 seconds.
Aug  4 06:27:28 iranon kernel: [137969.382287] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Aug  4 06:27:28 iranon kernel: [137969.382291] mythbackend   D 00005dfc     0  3161      1
Aug  4 06:27:28 iranon kernel: [137969.382295]        f2006c70 00000082 4b05cc7e 00005dfc f2006df0 c1c0e920 00000000 f7273390 
Aug  4 06:27:28 iranon kernel: [137969.382301]        0000c8b4 00000000 00000001 f7273398 00000282 00000202 f71b0ab0 f200ddf0 
Aug  4 06:27:28 iranon kernel: [137969.382306]        c1c012bc fa18f0a6 fa18f0bf c02b45a7 f71b0ab0 00000000 f200de0c fa18f0a6 
Aug  4 06:27:28 iranon kernel: [137969.382311] Call Trace:
Aug  4 06:27:28 iranon kernel: [137969.382347]  [<fa18f0a6>] nfs_wait_schedule+0x0/0x1e [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382384]  [<fa18f0bf>] nfs_wait_schedule+0x19/0x1e [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382399]  [<c02b45a7>] __wait_on_bit_lock+0x2a/0x52
Aug  4 06:27:28 iranon kernel: [137969.382407]  [<fa18f0a6>] nfs_wait_schedule+0x0/0x1e [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382421]  [<c02b462e>] out_of_line_wait_on_bit_lock+0x5f/0x67
Aug  4 06:27:28 iranon kernel: [137969.382429]  [<c0133a1d>] wake_bit_function+0x0/0x3c
Aug  4 06:27:28 iranon kernel: [137969.382441]  [<fa18f16e>] __nfs_revalidate_inode+0xaa/0x211 [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382458]  [<c017bac0>] do_lookup+0x53/0x145
Aug  4 06:27:28 iranon kernel: [137969.382466]  [<c0187609>] mntput_no_expire+0x11/0x64
Aug  4 06:27:28 iranon kernel: [137969.382472]  [<c017d971>] __link_path_walk+0xa71/0xb65
Aug  4 06:27:28 iranon kernel: [137969.382477]  [<c017bac0>] do_lookup+0x53/0x145
Aug  4 06:27:28 iranon kernel: [137969.382483]  [<c0187609>] mntput_no_expire+0x11/0x64
Aug  4 06:27:28 iranon kernel: [137969.382492]  [<c0187609>] mntput_no_expire+0x11/0x64
Aug  4 06:27:28 iranon kernel: [137969.382496]  [<c017daf5>] path_walk+0x90/0x98
Aug  4 06:27:28 iranon kernel: [137969.382502]  [<fa18f935>] nfs_getattr+0x8f/0xbe [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382520]  [<fa18f8a6>] nfs_getattr+0x0/0xbe [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382536]  [<c01785ac>] vfs_getattr+0x36/0x4d
Aug  4 06:27:28 iranon kernel: [137969.382545]  [<c0178684>] vfs_lstat_fd+0x27/0x39
Aug  4 06:27:28 iranon kernel: [137969.382550]  [<fa18bca6>] nfs_permission+0x0/0x129 [nfs]
Aug  4 06:27:28 iranon kernel: [137969.382567]  [<c0187609>] mntput_no_expire+0x11/0x64
Aug  4 06:27:28 iranon kernel: [137969.382572]  [<c0174914>] sys_faccessat+0x11e/0x15d
Aug  4 06:27:28 iranon kernel: [137969.382582]  [<c0178703>] sys_lstat64+0xf/0x23
Aug  4 06:27:28 iranon kernel: [137969.382588]  [<c017603c>] vfs_read+0xe3/0x11e
Aug  4 06:27:28 iranon kernel: [137969.382598]  [<c0174962>] sys_access+0xf/0x13
Aug  4 06:27:28 iranon kernel: [137969.382603]  [<c01077e8>] sysenter_past_esp+0x6d/0xa5
Aug  4 06:27:28 iranon kernel: [137969.382617]  =======================

Sysrq-T from dmesg (therefore truncated a bit) is attached.

Ian.

-- 
Ian Campbell

There are no answers, only cross-references.
		-- Weiner

--=-xGIro9u1WVMxjSPc4za8
Content-Disposition: attachment; filename=sysrq
Content-Type: text/plain; name=sysrq; charset=utf-8
Content-Transfer-Encoding: 7bit

d+0x3c/0x63
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S 005fdb20     0  3378   2818
[148193.520887]        f3be45c0 00000082 f3b7b200 005fdb20 00006034 f3be474c c1c0efa0 00000000 
[148193.520887]        00000000 f3bf3e48 000361ad 00000000 00000000 00000001 f7339b78 00000286 
[148193.520887]        7fffffff 00000000 f3bf1e5c f3bb1ac0 c02b7ea9 f78cd840 000000a0 f78cd840 
[148193.520887] Call Trace:
[148193.520887]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520887]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520887]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520887]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520887]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520887]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520887]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520887]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520887]  [<f889008a>] ide_intr+0x190/0x19b [ide_core]
[148193.520887]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520887]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520887]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S 8a931ce4     0  3529   2818
[148193.520887]        f3424ce0 00000082 f7a639e0 8a931ce4 000086c5 f3424e6c c1c0efa0 00000000 
[148193.520887]        f74019a0 023420f5 00008e45 00000000 00000000 00000000 00000000 000000ff 
[148193.520887]        7fffffff 00000000 f2ef3e5c f368d040 c02b7ea9 f3eda260 000008e0 f3eda260 
[148193.520887] Call Trace:
[148193.520887]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520887]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520887]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520887]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520887]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520887]  [<c0137502>] clocksource_get_next+0x39/0x3f
[148193.520887]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520887]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520887]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520887]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520887]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520887]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S 93aced7a     0  3530   2818
[148193.520887]        f34244a0 00000082 00000001 93aced7a 000083f1 f342462c c1c0efa0 00000000 
[148193.520887]        00000001 00000001 00278dd9 00000000 f2ec1e88 00000cda 00000000 00000246 
[148193.520887]        f2ec1eb0 00000000 c04037ac 087448e4 c013a642 00000210 00000210 00000000 
[148193.520887] Call Trace:
[148193.520887]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520887]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520887]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520887]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520887]  [<c0182157>] d_kill+0x37/0x46
[148193.520887]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520887]  [<c017289d>] filp_close+0x4d/0x53
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S bb6ed648     0  4898   2818
[148193.520887]        f79220e0 00000082 00000001 bb6ed648 000083fc f792226c c1c0efa0 00000000 
[148193.520887]        00000001 00000001 0001ab0e 00000000 f7947e88 000035c5 00000000 00000246 
[148193.520887]        f7947eb0 00000000 c04037ac 087448e4 c013a642 00000212 00000212 00000000 
[148193.520887] Call Trace:
[148193.520887]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520887]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520887]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520887]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520887]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520887]  [<c0182157>] d_kill+0x37/0x46
[148193.520887]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520887]  [<c017289d>] filp_close+0x4d/0x53
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S 69331d39     0  4899   2818
[148193.520887]        f7923580 00000082 00000001 69331d39 00007742 f792370c c1c0efa0 00000000 
[148193.520887]        00000001 00000001 000083ae 00000000 f2f19e88 0000467a 00000000 00000246 
[148193.520887]        f2f19eb0 00000000 c04037ac 087448e4 c013a642 0000020b 0000020b 00000000 
[148193.520887] Call Trace:
[148193.520887]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520887]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520887]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520887]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520887]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520887]  [<c0182157>] d_kill+0x37/0x46
[148193.520887]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520887]  [<c017289d>] filp_close+0x4d/0x53
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S 693158ed     0  4979   2818
[148193.520887]        f34248c0 00000082 00000001 693158ed 00007742 f3424a4c c1c0efa0 00000000 
[148193.520887]        00000001 00000001 0000781b 00000000 f2ef7e88 0000467a 00000000 00000246 
[148193.520887]        f2ef7eb0 00000000 c04037ac 087448e4 c013a642 0000020a 0000020a 00000000 
[148193.520887] Call Trace:
[148193.520887]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520887]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520887]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520887]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520887]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520887]  [<c0182157>] d_kill+0x37/0x46
[148193.520887]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520887]  [<c017289d>] filp_close+0x4d/0x53
[148193.520887]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520887]  =======================
[148193.520887] mysqld        S 6941a010     0  4980   2818
[148193.520887]        f3424080 00000082 00000001 6941a010 00007742 f342420c c1c0efa0 00000000 
[148193.520887]        00000001 00000001 0000aeba 00000000 f2f9de88 0000467a 00000000 00000246 
[148193.520888]        f2f9deb0 00000000 c04037ac 087448e4 c013a642 0000020c 0000020c 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520888]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c0182157>] d_kill+0x37/0x46
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c017289d>] filp_close+0x4d/0x53
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] logger        S 2f87513b     0  2859   2818
[148193.520888]        f7a735e0 00000086 d662d853 2f87513b 00000007 f7a7376c c1c0efa0 00000000 
[148193.520888]        f3f63f04 f740eea0 0003fbbc 00000000 c0182366 f7169884 00000246 c013187f 
[148193.520888]        f3f75200 00001000 f3f63e84 f3f63fa0 c017967e 00000000 f7a735e0 c0131774 
[148193.520888] Call Trace:
[148193.520888]  [<c0182366>] dput+0x15/0xbb
[148193.520888]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520888]  [<c017967e>] pipe_wait+0x51/0x6f
[148193.520888]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520888]  [<c0179d50>] pipe_read+0x2bf/0x32b
[148193.520888]  [<c017c34f>] path_walk+0x67/0x70
[148193.520888]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520888]  [<c0176a3d>] cp_new_stat64+0xfc/0x10e
[148193.520888]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520888]  [<c0173f20>] do_sync_read+0x0/0xfe
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] inetd         S a145ef04     0  2968      1
[148193.520888]        f78984e0 00000082 c034d300 a145ef04 000058d4 f789866c c1c0efa0 00000000 
[148193.520888]        c036e2e0 0233b2df 00056aa8 00000000 00000000 00000000 00000000 000000ff 
[148193.520888]        7fffffff f77460a0 00000010 f778bf9c c02b7ea9 c01042a7 f778be5c 00000203 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520888]  [<c01318c2>] remove_wait_queue+0xc/0x34
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c027b144>] tcp_poll+0x14/0x10e
[148193.520888]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c029df63>] bictcp_cong_avoid+0x12/0x2a1
[148193.520888]  [<c022016b>] mix_pool_bytes_extract+0x5c/0x165
[148193.520888]  [<c027e2ad>] tcp_cong_avoid+0xd/0x1b
[148193.520888]  [<c0280bd2>] tcp_ack+0x15c4/0x1757
[148193.520888]  [<c029df63>] bictcp_cong_avoid+0x12/0x2a1
[148193.520888]  [<c029df63>] bictcp_cong_avoid+0x12/0x2a1
[148193.520888]  [<c027e2ad>] tcp_cong_avoid+0xd/0x1b
[148193.520888]  [<c0280bd2>] tcp_ack+0x15c4/0x1757
[148193.520888]  [<c01e0532>] number+0x13d/0x217
[148193.520888]  [<c0283dbc>] tcp_current_mss+0xaa/0xc8
[148193.520888]  [<c029df63>] bictcp_cong_avoid+0x12/0x2a1
[148193.520888]  [<c027e2ad>] tcp_cong_avoid+0xd/0x1b
[148193.520888]  [<c0280bd2>] tcp_ack+0x15c4/0x1757
[148193.520888]  [<c0283dbc>] tcp_current_mss+0xaa/0xc8
[148193.520888]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520888]  [<c0288920>] tcp_v4_do_rcv+0x37f/0x3e8
[148193.520888]  [<c010f4b1>] flush_tlb_page+0x3e/0x62
[148193.520888]  [<c011731a>] ptep_set_access_flags+0x52/0x5c
[148193.520888]  [<c0161e6f>] do_wp_page+0x1da/0x49f
[148193.520888]  [<f887846c>] e1000_clean_rx_irq+0x429/0x46f [e1000]
[148193.520888]  [<c0163e87>] handle_mm_fault+0x623/0x690
[148193.520888]  [<f887880a>] e1000_clean+0xf7/0x215 [e1000]
[148193.520888]  [<c017f718>] sys_select+0xce/0x180
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] sensord       S daed64ed     0  2984      1
[148193.520888]        f749e0c0 00000082 c1c0c2f8 daed64ed 000086c4 f749e24c c1c0efa0 00000000 
[148193.520888]        f3811f48 c1c0c2f8 0021726f 00000000 d334ba31 000086d2 00000282 f3811f48 
[148193.520888]        f3811f48 00000001 bfddf9b4 f3810000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] smartd        S 00000000     0  3001      1
[148193.520888]        f75509e0 00000086 c1c0c2f8 00000000 c0133c26 f7550b6c c1c0efa0 00000000 
[148193.520888]        f3817f48 023208c3 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        f3817f48 00000001 bf96f044 f3816000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] uptimed       S 00000000     0  3024      1
[148193.520888]        f77a20e0 00000086 c1c0c2f8 00000000 c0133c26 f77a226c c1c0efa0 00000000 
[148193.520888]        f3fcdf48 023419cc 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        f3fcdf48 00000001 bf98edc4 f3fcc000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] xfs           S f3bcee20     0  3043      1
[148193.520888]        f749e900 00000086 c034d300 f3bcee20 00008645 f749ea8c c1c0efa0 00000000 
[148193.520888]        c0129950 f3fe9b5c 00019ada 00000000 00000286 c0129a63 00000000 00000286 
[148193.520888]        023453c6 023453c6 00000040 f3fe9f9c c02b7f01 fa10bf00 fa10ec70 023453c6 
[148193.520888] Call Trace:
[148193.520888]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520888]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520888]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520888]  [<c012968c>] process_timeout+0x0/0x5
[148193.520888]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520888]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<f888fbdf>] ide_do_request+0x5f2/0x81b [ide_core]
[148193.520888]  [<f888fda3>] ide_do_request+0x7b6/0x81b [ide_core]
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<c0119081>] hrtick_start_fair+0xeb/0x12c
[148193.520888]  [<c011fc07>] check_preempt_wakeup+0xa2/0xc2
[148193.520888]  [<c011b614>] try_to_wake_up+0xe8/0xf1
[148193.520888]  [<c01183ee>] __wake_up_common+0x2e/0x58
[148193.520888]  [<c011a59f>] __wake_up_sync+0x2a/0x3e
[148193.520888]  [<c02a8175>] unix_write_space+0x3a/0x63
[148193.520888]  [<c0253396>] skb_dequeue+0x42/0x48
[148193.520888]  [<c02a71b1>] unix_stream_recvmsg+0x390/0x480
[148193.520888]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520888]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520888]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520888]  [<c01df80c>] rb_insert_color+0x8c/0xad
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520888]  [<c0135f76>] do_gettimeofday+0xd/0x27
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] ntpd          S c0152eff     0  3155      1
[148193.520888]        f744f0e0 00200082 c034d300 c0152eff 000006c0 f744f26c c1c0efa0 00000000 
[148193.520888]        c0105f3f 02342b05 f3fc1be4 00000000 00000000 00000000 00000000 000000ff 
[148193.520888]        7fffffff f788f8c0 00200000 f3fc1f9c c02b7ea9 f792d260 f3fc1be4 00200246 
[148193.520888] Call Trace:
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0255831>] datagram_poll+0x14/0xab
[148193.520888]  [<c028cd49>] udp_poll+0x10/0xd5
[148193.520888]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<c0119081>] hrtick_start_fair+0xeb/0x12c
[148193.520888]  [<c011fc07>] check_preempt_wakeup+0xa2/0xc2
[148193.520888]  [<c011b614>] try_to_wake_up+0xe8/0xf1
[148193.520888]  [<c01183ee>] __wake_up_common+0x2e/0x58
[148193.520888]  [<c011a567>] complete+0x28/0x36
[148193.520888]  [<f8858df0>] usb_hcd_giveback_urb+0x64/0x8f [usbcore]
[148193.520888]  [<c016c583>] dma_pool_free+0x57/0xe9
[148193.520888]  [<f883f3fd>] qh_completions+0x9a/0x304 [ehci_hcd]
[148193.520888]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c0109237>] save_i387+0x123/0x139
[148193.520888]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520888]  [<c0102b85>] setup_sigcontext+0x105/0x189
[148193.520888]  [<c012a0aa>] recalc_sigpending+0xb/0x2c
[148193.520888]  [<c01034ad>] do_notify_resume+0x565/0x649
[148193.520888]  [<c0109020>] restore_i387+0x9f/0xda
[148193.520888]  [<c017f718>] sys_select+0xce/0x180
[148193.520888]  [<c0102d2e>] restore_sigcontext+0x113/0x168
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 1985ddd1     0  3168      1
[148193.520888]        f77a2500 00000082 c034d300 1985ddd1 000086c0 f77a268c c1c0efa0 00000000 
[148193.520888]        c0129950 02342776 023444c1 f3807b5c 00000000 00000000 00000000 000000ff 
[148193.520888]        023444c1 023444c1 00002000 f3807f9c c02b7f01 c03f258c c03f258c 023444c1 
[148193.520888] Call Trace:
[148193.520888]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520888]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520888]  [<c012968c>] process_timeout+0x0/0x5
[148193.520888]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520888]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<c0257d8e>] netif_receive_skb+0x2d6/0x343
[148193.520888]  [<c025a139>] process_backlog+0x74/0xce
[148193.520888]  [<c0259a7e>] net_rx_action+0x9c/0x1b9
[148193.520888]  [<c0126419>] __do_softirq+0x66/0xd3
[148193.520888]  [<c029df63>] bictcp_cong_avoid+0x12/0x2a1
[148193.520888]  [<c0275d31>] ip_finish_output+0x1c5/0x1fc
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520888]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520888]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c012679d>] irq_exit+0x50/0x67
[148193.520888]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520888]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabb2ab5>] _nv008482rm+0x1c/0x20 [nvidia]
[148193.520888]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520888]  [<fac9c410>] nv_kern_isr+0x46/0x78 [nvidia]
[148193.520888]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520888]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520888]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<fabf33ea>] _nv003983rm+0x1d5/0x212 [nvidia]
[148193.520888]  [<fabf1bd2>] _nv003976rm+0x3d/0x65 [nvidia]
[148193.520888]  [<fabf7ed2>] rm_isr+0x9c/0xef [nvidia]
[148193.520888]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520888]  [<c0135f76>] do_gettimeofday+0xd/0x27
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 3229efef     0  3232      1
[148193.520888]        f7858080 00000082 c1c0c2f8 3229efef 00008685 f785820c c1c0efa0 00000000 
[148193.520888]        f3febf48 c1c0c2f8 0000d2a1 00000000 35949909 000086cc 00000282 f3febf48 
[148193.520888]        f3febf48 00000001 b4747174 f3fea000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S d999efa2     0  3262      1
[148193.520888]        f75505c0 00000082 c1c0c2f8 d999efa2 000086c7 f755074c c1c0efa0 00000000 
[148193.520888]        f3853e5c c1c0c2f8 000026f6 00000000 1534bbe7 000086c8 00000282 f3853f98 
[148193.520888]        00000000 00000000 f3853e5c 08c350d4 c013a6a5 00048517 00048517 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S e9acbdfd     0  3263      1
[148193.520888]        f749f980 00000082 c1c0c2f8 e9acbdfd 000086c7 f749fb0c c1c0efa0 00000000 
[148193.520888]        f386fe5c c1c0c2f8 00001379 00000000 01843d07 000086c8 00000282 f386ff98 
[148193.520888]        00000000 00000000 f386fe5c 08c4858c c013a6a5 000b4d6b 000b4d6b 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c010fc69>] lapic_next_event+0xc/0x10
[148193.520888]  [<c0138608>] clockevents_program_event+0xc4/0xd2
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S f52b36b1     0  3264      1
[148193.520888]        f77a3160 00000082 c1c0c2f8 f52b36b1 000086c7 f77a32ec c1c0efa0 00000000 
[148193.520888]        f3863e5c c1c0c2f8 00000005 00000000 30c67d65 000086c8 00000282 f3863f98 
[148193.520888]        00000000 00000000 f3863e5c 08c2999c c013a6a5 00048561 00048561 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3298      1
[148193.520888]        f744e480 00000082 c1c0c2f8 00000000 c0133c26 f744e60c c1c0efa0 00000000 
[148193.520888]        f38cde5c 02342aab 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f38cde5c 08c3b674 c013a6a5 00048505 00048505 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c0119bba>] __dequeue_entity+0x1f/0x71
[148193.520888]  [<c011d358>] hrtick_set+0x7a/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3299      1
[148193.520888]        f78880a0 00000082 c1c0c2f8 00000000 c0133c26 f788822c c1c0efa0 00000000 
[148193.520888]        f38cfe5c 02342aef 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f38cfe5c 08c7c96c c013a6a5 000b4d67 000b4d67 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c010fc69>] lapic_next_event+0xc/0x10
[148193.520888]  [<c0138608>] clockevents_program_event+0xc4/0xd2
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3302      1
[148193.520888]        f7551a60 00000082 c1c0c2f8 00000000 c0133c26 f7551bec c1c0efa0 00000000 
[148193.520888]        f38a9e5c 02342b14 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f38a9e5c 08c3daa4 c013a6a5 0004855d 0004855d 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520888]  [<c010296e>] __switch_to+0xa5/0x125
[148193.520888]  [<c011d358>] hrtick_set+0x7a/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S d999fb3b     0  3305      1
[148193.520888]        f78888e0 00000082 c1c0c2f8 d999fb3b 000086c7 f7888a6c c1c0efa0 00000000 
[148193.520888]        f38d5e5c c1c0c2f8 0000ae39 00000000 1534cb52 000086c8 00000282 f38d5f98 
[148193.520888]        00000000 00000000 f38d5e5c 08c3e834 c013a6a5 00048557 00048557 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3306      1
[148193.520888]        f7a72560 00000082 c1c0c2f8 00000000 c0133c26 f7a726ec c1c0efa0 00000000 
[148193.520888]        f38d7e5c 02342ae6 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f38d7e5c 08c9011c c013a6a5 000b4d61 000b4d61 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c011c59e>] rebalance_domains+0x6d/0x355
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3311      1
[148193.520888]        f7a73a00 00000082 c1c0c2f8 00000000 c0133c26 f7a73b8c c1c0efa0 00000000 
[148193.520888]        f39dbe5c 02342b1e 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f39dbe5c 08c3ed8c c013a6a5 0004855b 0004855b 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c0119bba>] __dequeue_entity+0x1f/0x71
[148193.520888]  [<c011d358>] hrtick_set+0x7a/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S d99a3be6     0  3316      1
[148193.520888]        f7859100 00000082 c1c0c2f8 d99a3be6 000086c7 f785928c c1c0efa0 00000000 
[148193.520888]        f3b2be5c c1c0c2f8 0000c83c 00000000 153509cc 000086c8 00000282 f3b2bf98 
[148193.520888]        00000000 00000000 f3b2be5c 08c3c204 c013a6a5 00048553 00048553 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3317      1
[148193.520888]        f74af160 00000082 c1c0c2f8 00000000 c0133c26 f74af2ec c1c0efa0 00000000 
[148193.520888]        f3b2de5c 02342adf 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f3b2de5c 08cc42a4 c013a6a5 000b4d55 000b4d55 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c01294f8>] run_timer_softirq+0x11a/0x17c
[148193.520888]  [<c011f9be>] run_rebalance_domains+0x28/0x98
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S f3367837     0  3326      1
[148193.520888]        f74ae920 00000082 c1c0c2f8 f3367837 000086c7 f74aeaac c1c0efa0 00000000 
[148193.520888]        f3b35e5c c1c0c2f8 00000d94 00000000 2ed13c9c 000086c8 00000282 f3b35f98 
[148193.520888]        00000000 00000000 f3b35e5c 08c3cb5c c013a6a5 00048557 00048557 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3328      1
[148193.520888]        f7a62d80 00000082 c1c0c2f8 00000000 c0133c26 f7a62f0c c1c0efa0 00000000 
[148193.520888]        f3b57e5c 02342ab8 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f3b57e5c 08c289ac c013a6a5 0004730b 0004730b 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c010fc69>] lapic_next_event+0xc/0x10
[148193.520888]  [<c0138608>] clockevents_program_event+0xc4/0xd2
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   D 272c2867     0  3329      1
[148193.520888]        f78588c0 00000082 c034d300 272c2867 000086c1 f7858a4c c1c0efa0 00000000 
[148193.520888]        00000012 02339963 000022b1 00000000 00000000 00000000 00000000 00000246 
[148193.520888]        f3b31d7c 00000000 f3b31d84 c1c00dd0 fa0b27a9 c02b803e fa0b2784 f3ee5488 
[148193.520888] Call Trace:
[148193.520888]  [<fa0b27a9>] rpc_wait_bit_killable+0x25/0x2a [sunrpc]
[148193.520888]  [<c02b803e>] __wait_on_bit+0x33/0x58
[148193.520888]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520888]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520888]  [<c02b80c2>] out_of_line_wait_on_bit+0x5f/0x67
[148193.520888]  [<c01317a1>] wake_bit_function+0x0/0x3c
[148193.520888]  [<fa0b2bea>] __rpc_execute+0xbe/0x1d9 [sunrpc]
[148193.520888]  [<fa0ada72>] rpc_run_task+0x40/0x45 [sunrpc]
[148193.520888]  [<fa0adb00>] rpc_call_sync+0x38/0x52 [sunrpc]
[148193.520888]  [<fa12e23d>] nfs3_rpc_wrapper+0x14/0x49 [nfs]
[148193.520888]  [<fa12e4fe>] nfs3_proc_getattr+0x52/0x73 [nfs]
[148193.520888]  [<fa1242fd>] __nfs_revalidate_inode+0xed/0x211 [nfs]
[148193.520888]  [<c017a2ac>] do_lookup+0x53/0x153
[148193.520888]  [<c0186774>] mntput_no_expire+0x13/0xd9
[148193.520888]  [<c017c1f4>] __link_path_walk+0xa17/0xb0b
[148193.520888]  [<c0186774>] mntput_no_expire+0x13/0xd9
[148193.520888]  [<c0186774>] mntput_no_expire+0x13/0xd9
[148193.520888]  [<c017c34f>] path_walk+0x67/0x70
[148193.520888]  [<fa124a5e>] nfs_getattr+0x8f/0xbe [nfs]
[148193.520888]  [<fa1249cf>] nfs_getattr+0x0/0xbe [nfs]
[148193.520888]  [<c0176e52>] vfs_getattr+0x36/0x4d
[148193.520888]  [<c0176f2a>] vfs_lstat_fd+0x27/0x39
[148193.520888]  [<fa120d73>] nfs_permission+0x0/0x11d [nfs]
[148193.520888]  [<c01730c2>] sys_faccessat+0x14f/0x15b
[148193.520888]  [<c0176fa9>] sys_lstat64+0xf/0x23
[148193.520888]  [<c01747c9>] vfs_read+0xe3/0x11e
[148193.520888]  [<c01730dd>] sys_access+0xf/0x13
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 8a9e1aa3     0  3333      1
[148193.520888]        f7a639e0 00000082 c1c0c2f8 8a9e1aa3 000086c5 f7a63b6c c1c0efa0 00000000 
[148193.520888]        f3b5df48 c1c0c2f8 000aebde 00000000 82e56cda 000086d3 00000282 f3b5df48 
[148193.520888]        f3b5df48 00000001 acf37de4 f3b5c000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 00000000     0  3335      1
[148193.520888]        f7a635c0 00000082 c1c0c2f8 00000000 c0133c26 f7a6374c c1c0efa0 00000000 
[148193.520888]        f3b59e5c 02342b1e 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        00000000 00000000 f3b59e5c 08ccc9a4 c013a6a5 00090aa9 00090aa9 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<c010296e>] __switch_to+0xa5/0x125
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 8d4f3f25     0  3336      1
[148193.520888]        f7a62540 00000082 f77a2500 8d4f3f25 0000000b f7a626cc c1c0efa0 00000000 
[148193.520888]        00000000 001200d2 00000bc0 00000000 00000001 00000001 00000000 00000246 
[148193.520888]        f3b5feb0 00000000 c04042c4 08c34194 c013a642 00000003 00000003 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520888]  [<c015d523>] mark_page_accessed+0x18/0x2b
[148193.520888]  [<c0158670>] filemap_fault+0x1f5/0x359
[148193.520888]  [<c0117c11>] kunmap_atomic+0x67/0x8a
[148193.520888]  [<c0161c56>] __do_fault+0x30e/0x34d
[148193.520888]  [<c011b614>] try_to_wake_up+0xe8/0xf1
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c017289d>] filp_close+0x4d/0x53
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c01029b1>] __switch_to+0xe8/0x125
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 8d4fe72c     0  3337      1
[148193.520888]        f7858ce0 00000082 f77a2500 8d4fe72c 0000000b f7858e6c c1c0efa0 00000000 
[148193.520888]        00000000 001200d2 000006e8 00000000 000408b4 f3b33e64 00000000 00000246 
[148193.520888]        f3b33eb0 00000000 c0404238 08cd9d6c c013a642 00000003 00000003 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<c01df7cc>] rb_insert_color+0x4c/0xad
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c017289d>] filp_close+0x4d/0x53
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c010296e>] __switch_to+0xa5/0x125
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 8d508441     0  3338      1
[148193.520888]        f3b5ba20 00000082 f77a2500 8d508441 0000000b f3b5bbac c1c0efa0 00000000 
[148193.520888]        00000000 00000000 00000631 00000000 00000000 f3b61e64 00000000 00000246 
[148193.520888]        f3b61eb0 00000000 c0403a40 08cd73bc c013a642 00000003 00000003 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<c01df7cc>] rb_insert_color+0x4c/0xad
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c010296e>] __switch_to+0xa5/0x125
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S f3b5b600     0  3339      1
[148193.520888]        f3b5b600 00000082 c0119081 f3b5b600 f3b5b600 f3b5b78c c1c0efa0 00000000 
[148193.520888]        f3b7b200 02285426 00000001 c011fc07 00000000 00000000 00000000 000000ff 
[148193.520888]        f3b63eb0 00000000 c0403f18 08cd2f9c c013a642 00001385 00001385 00000000 
[148193.520888] Call Trace:
[148193.520888]  [<c0119081>] hrtick_start_fair+0xeb/0x12c
[148193.520888]  [<c011fc07>] check_preempt_wakeup+0xa2/0xc2
[148193.520888]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520888]  [<c0184bf6>] file_update_time+0x83/0xac
[148193.520888]  [<c0187278>] mnt_drop_write+0x1a/0xb4
[148193.520888]  [<c0179a15>] pipe_write+0x379/0x3c7
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<c010296e>] __switch_to+0xa5/0x125
[148193.520888]  [<c011d358>] hrtick_set+0x7a/0xd8
[148193.520888]  [<c02b7cd7>] schedule+0x63d/0x66f
[148193.520888]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520888]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520888]  [<c0174c3a>] sys_write+0x5b/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   D 626f0644     0  3340      1
[148193.520888]        f3b5b1e0 00000082 c314d000 626f0644 000083f3 f3b5b36c c1c0efa0 00000000 
[148193.520888]        00000000 00000000 012cf0b9 00000000 f3ee22bc f3ee5ee0 f78b3840 00000246 
[148193.520888]        f3b65ccc 00000000 f3b65cd4 c1c01010 fa0b27a9 c02b803e fa0b2784 f3ee5f28 
[148193.520888] Call Trace:
[148193.520888]  [<fa0b27a9>] rpc_wait_bit_killable+0x25/0x2a [sunrpc]
[148193.520888]  [<c02b803e>] __wait_on_bit+0x33/0x58
[148193.520888]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520888]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520888]  [<c02b80c2>] out_of_line_wait_on_bit+0x5f/0x67
[148193.520888]  [<c01317a1>] wake_bit_function+0x0/0x3c
[148193.520888]  [<fa0b2bea>] __rpc_execute+0xbe/0x1d9 [sunrpc]
[148193.520888]  [<fa0ada72>] rpc_run_task+0x40/0x45 [sunrpc]
[148193.520888]  [<fa0adb00>] rpc_call_sync+0x38/0x52 [sunrpc]
[148193.520888]  [<fa12e23d>] nfs3_rpc_wrapper+0x14/0x49 [nfs]
[148193.520888]  [<fa12e76f>] nfs3_proc_access+0x101/0x166 [nfs]
[148193.520888]  [<c011fc07>] check_preempt_wakeup+0xa2/0xc2
[148193.520888]  [<c011b614>] try_to_wake_up+0xe8/0xf1
[148193.520888]  [<c0131781>] autoremove_wake_function+0xd/0x2d
[148193.520888]  [<c01183ee>] __wake_up_common+0x2e/0x58
[148193.520888]  [<c011a59f>] __wake_up_sync+0x2a/0x3e
[148193.520888]  [<fa120c00>] nfs_do_access+0x134/0x2a7 [nfs]
[148193.520888]  [<fa0b36d8>] rpcauth_lookupcred+0x69/0x8f [sunrpc]
[148193.520888]  [<fa120e30>] nfs_permission+0xbd/0x11d [nfs]
[148193.520888]  [<fa120d73>] nfs_permission+0x0/0x11d [nfs]
[148193.520888]  [<c017a6cd>] permission+0xa3/0xfc
[148193.520888]  [<c017b8f9>] __link_path_walk+0x11c/0xb0b
[148193.520888]  [<c0161e6f>] do_wp_page+0x1da/0x49f
[148193.520888]  [<c017c31f>] path_walk+0x37/0x70
[148193.520888]  [<c017c5ce>] do_path_lookup+0x122/0x184
[148193.520888]  [<c017ce2b>] __user_walk_fd+0x29/0x3a
[148193.520888]  [<c017301a>] sys_faccessat+0xa7/0x15b
[148193.520888]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520888]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520888]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c01730dd>] sys_access+0xf/0x13
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] mythbackend   S 54dac9f3     0  3379      1
[148193.520888]        f3b7b200 00000082 f77a2500 54dac9f3 000083f5 f3b7b38c c1c0efa0 00000000 
[148193.520888]        c036e2e0 02287b2e 00006456 00000000 00000000 00000000 00000000 000000ff 
[148193.520888]        7fffffff f367c800 00080000 f3bf5f9c c02b7ea9 00020000 00000011 00000207 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c01318c2>] remove_wait_queue+0xc/0x34
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c027b144>] tcp_poll+0x14/0x10e
[148193.520888]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0253723>] __kfree_skb+0x8/0x61
[148193.520888]  [<c0255bd4>] sk_stream_kill_queues+0xab/0xf7
[148193.520888]  [<c027961c>] inet_csk_destroy_sock+0xab/0xf9
[148193.520888]  [<c0280fe0>] tcp_fin+0x77/0x15d
[148193.520888]  [<c0281aad>] tcp_data_queue+0x285/0xac9
[148193.520888]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520888]  [<c02831c6>] tcp_rcv_state_process+0x93d/0x9b2
[148193.520888]  [<c0288920>] tcp_v4_do_rcv+0x37f/0x3e8
[148193.520888]  [<c0278a6f>] __inet_lookup_established+0xc4/0x16e
[148193.520888]  [<c026197c>] sk_filter+0x63/0x6b
[148193.520888]  [<c028a29d>] tcp_v4_rcv+0x292/0x609
[148193.520888]  [<c0272927>] ip_local_deliver_finish+0xe8/0x183
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c02b7cd7>] schedule+0x63d/0x66f
[148193.520888]  [<c0126702>] local_bh_enable+0x66/0x71
[148193.520888]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520888]  [<c0184ce6>] touch_atime+0xc7/0xd1
[148193.520888]  [<c0187278>] mnt_drop_write+0x1a/0xb4
[148193.520888]  [<c0179dae>] pipe_read+0x31d/0x32b
[148193.520888]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabb2ab5>] _nv008482rm+0x1c/0x20 [nvidia]
[148193.520888]  [<fabf33ea>] _nv003983rm+0x1d5/0x212 [nvidia]
[148193.520888]  [<fabf1bd2>] _nv003976rm+0x3d/0x65 [nvidia]
[148193.520888]  [<fabf7ed2>] rm_isr+0x9c/0xef [nvidia]
[148193.520888]  [<c017f718>] sys_select+0xce/0x180
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] atd           S 00000000     0  3180      1
[148193.520888]        f744ecc0 00000082 c1c0c2f8 00000000 c0133c26 f744ee4c c1c0efa0 00000000 
[148193.520888]        f3fc3f48 02320f84 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        f3fc3f48 00000001 bf920974 f3fc2000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] cron          S 00000000     0  3207      1
[148193.520888]        f78584a0 00000082 c1c0c2f8 00000000 c0133c26 f785862c c1c0efa0 00000000 
[148193.520888]        f3fdff48 0233f236 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520888]        f3fdff48 00000001 bff10364 f3fde000 c02b8363 00000000 00000001 c0134240 
[148193.520888] Call Trace:
[148193.520888]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520888]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520888]  [<c02b8363>] do_nanosleep+0x51/0x87
[148193.520888]  [<c0134240>] hrtimer_nanosleep+0x39/0x96
[148193.520888]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520888]  [<c02b834a>] do_nanosleep+0x38/0x87
[148193.520888]  [<c01342de>] sys_nanosleep+0x41/0x51
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] kdvb-fe-0     S c1c0c2c0     0  3234      2
[148193.520888]        f749e4e0 00000046 c034d300 c1c0c2c0 00000002 f749e66c c1c0efa0 00000000 
[148193.520888]        c0129950 023429d5 02342bc8 f384ff70 00000000 00000000 00000000 000000ff 
[148193.520888]        02342bc8 02342bc8 f79379a8 000001d9 c02b7f01 c03f23ac c03f23ac 02342bc8 
[148193.520888] Call Trace:
[148193.520888]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520888]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520888]  [<c012968c>] process_timeout+0x0/0x5
[148193.520888]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520888]  [<f92cd3ab>] dvb_frontend_thread+0x12a/0x2a7 [dvb_core]
[148193.520888]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520888]  [<f92cd281>] dvb_frontend_thread+0x0/0x2a7 [dvb_core]
[148193.520888]  [<c01316b3>] kthread+0x38/0x5d
[148193.520888]  [<c013167b>] kthread+0x0/0x5d
[148193.520888]  [<c01044f3>] kernel_thread_helper+0x7/0x10
[148193.520888]  =======================
[148193.520888] apache2       S e99d6d39     0  3235      1
[148193.520888]        f748ed00 00200082 c034d300 e99d6d39 000086c7 f748ee8c c1c0efa0 00000000 
[148193.520888]        c0129950 f3831b5c 0000468d 00000000 00200286 c0129a63 00000000 00200286 
[148193.520888]        02342be8 02342be8 f77d7c2c f3831f9c c02b7f01 c1c0c690 c03f24ac 02342be8 
[148193.520888] Call Trace:
[148193.520888]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520888]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520888]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520888]  [<c012968c>] process_timeout+0x0/0x5
[148193.520888]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520888]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520888]  [<f8876e57>] e1000_xmit_frame+0xa59/0xaa3 [e1000]
[148193.520888]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c0108214>] nommu_map_single+0x2b/0x43
[148193.520888]  [<fabdff58>] _nv004365rm+0x24/0x70 [nvidia]
[148193.520888]  [<fabdff84>] _nv004365rm+0x50/0x70 [nvidia]
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabb28fc>] _nv008244rm+0x70/0x95 [nvidia]
[148193.520888]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520888]  [<c024d73d>] raw_pci_read+0x3d/0x45
[148193.520888]  [<c024d80b>] pci_read+0x1c/0x21
[148193.520888]  [<c01e4d9c>] pci_bus_read_config_word+0x59/0x64
[148193.520888]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520888]  [<fabb2ab5>] _nv008482rm+0x1c/0x20 [nvidia]
[148193.520888]  [<fabb2a02>] _nv008484rm+0x21/0x3b [nvidia]
[148193.520888]  [<fabb2764>] _nv008168rm+0xbc/0xc6 [nvidia]
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520888]  [<c013438e>] ktime_get+0xd/0x21
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520888]  [<c010fc69>] lapic_next_event+0xc/0x10
[148193.520888]  [<c0138608>] clockevents_program_event+0xc4/0xd2
[148193.520888]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520888]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520888]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<c012679d>] irq_exit+0x50/0x67
[148193.520888]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520888]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520888]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c0139378>] tick_program_event+0x2b/0x4a
[148193.520888]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520888]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520888]  [<f88e11bd>] cdrom_timer_expiry+0x0/0x4b [ide_cd_mod]
[148193.520888]  [<f88e2b59>] cdrom_newpc_intr+0x0/0x54d [ide_cd_mod]
[148193.520888]  [<f8890a43>] ide_set_handler+0x2c/0x3e [ide_core]
[148193.520888]  [<f88e11bd>] cdrom_timer_expiry+0x0/0x4b [ide_cd_mod]
[148193.520888]  [<f88e301a>] cdrom_newpc_intr+0x4c1/0x54d [ide_cd_mod]
[148193.520888]  [<f88e11bd>] cdrom_timer_expiry+0x0/0x4b [ide_cd_mod]
[148193.520888]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520888]  [<f88e2b59>] cdrom_newpc_intr+0x0/0x54d [ide_cd_mod]
[148193.520888]  [<f889008a>] ide_intr+0x190/0x19b [ide_core]
[148193.520888]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520888]  [<c01318c2>] remove_wait_queue+0xc/0x34
[148193.520888]  [<c0124ad9>] do_wait+0x8c4/0x969
[148193.520888]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520888]  [<c0124c06>] sys_wait4+0x88/0x92
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] getty         S 8ca24196     0  3251      1
[148193.520888]        f747f100 00000082 00000008 8ca24196 0000000a f747f28c c1c0efa0 00000000 
[148193.520888]        f7750810 f3865f68 00000001 00000000 00000000 00000001 00000002 c1ae3060 
[148193.520888]        7fffffff f7750800 f3865f44 bfefdb3b c02b7ea9 57183067 f3eeaf7c b7fdf000 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0162622>] unmap_vmas+0x31a/0x5ad
[148193.520888]  [<c0134c00>] up+0x9/0x2a
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520888]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520888]  [<c02237e0>] tty_read+0x59/0x96
[148193.520888]  [<c0223787>] tty_read+0x0/0x96
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] getty         S 8ca24194     0  3253      1
[148193.520888]        f77a2d40 00000082 00000008 8ca24194 0000000a f77a2ecc c1c0efa0 00000000 
[148193.520888]        f74cf810 f386bf68 00000001 00000000 00000000 00000001 00000002 c1ae3060 
[148193.520888]        7fffffff f74cf800 f386bf44 bfa1865b c02b7ea9 57183067 f3fa4bf0 b7efc000 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0162622>] unmap_vmas+0x31a/0x5ad
[148193.520888]  [<c0134c00>] up+0x9/0x2a
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520888]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520888]  [<c02237e0>] tty_read+0x59/0x96
[148193.520888]  [<c0223787>] tty_read+0x0/0x96
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] getty         S 8ca2418e     0  3255      1
[148193.520888]        f7550e00 00000082 00000008 8ca2418e 0000000a f7550f8c c1c0efa0 00000000 
[148193.520888]        f78b6810 f386df68 00000001 00000000 00000000 00000001 00000002 c1ae3060 
[148193.520888]        7fffffff f78b6800 f386df44 bfc638ab c02b7ea9 57183067 f380ed1c b7f47000 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0162622>] unmap_vmas+0x31a/0x5ad
[148193.520888]  [<c0134c00>] up+0x9/0x2a
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520888]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520888]  [<c02237e0>] tty_read+0x59/0x96
[148193.520888]  [<c0223787>] tty_read+0x0/0x96
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] getty         S 8ca24192     0  3257      1
[148193.520888]        f75501a0 00000082 00000008 8ca24192 0000000a f755032c c1c0efa0 00000000 
[148193.520888]        f7975810 f3851f68 00000001 00000000 00000000 00000001 00000002 c1ae3060 
[148193.520888]        7fffffff f7975800 f3851f44 bfda49eb c02b7ea9 57183067 f3f65e18 b7f86000 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0162622>] unmap_vmas+0x31a/0x5ad
[148193.520888]  [<c0134c00>] up+0x9/0x2a
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520888]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520888]  [<c02237e0>] tty_read+0x59/0x96
[148193.520888]  [<c0223787>] tty_read+0x0/0x96
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] getty         S 8ca24190     0  3259      1
[148193.520888]        f748e8e0 00000086 00000008 8ca24190 0000000a f748ea6c c1c0efa0 00000000 
[148193.520888]        f3f53c10 f3855f68 00000001 00000000 00000000 00000001 00000002 c1ae3060 
[148193.520888]        7fffffff f3f53c00 f3855f44 bfe3927b c02b7ea9 57183067 f3ff5c74 b7f1d000 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0162622>] unmap_vmas+0x31a/0x5ad
[148193.520888]  [<c0134c00>] up+0x9/0x2a
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520888]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520888]  [<c02237e0>] tty_read+0x59/0x96
[148193.520888]  [<c0223787>] tty_read+0x0/0x96
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] getty         S 8d499799     0  3260      1
[148193.520888]        f748f540 00000086 00000000 8d499799 0000000a f748f6cc c1c0efa0 00000000 
[148193.520888]        f77e7810 f3857f68 000116d1 00000000 00000000 00000001 00000002 c1ae3060 
[148193.520888]        7fffffff f77e7800 f3857f44 bfced91b c02b7ea9 c0235552 c0418be0 f77e7800 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c0235552>] serial8250_start_tx+0x28/0xb6
[148193.520888]  [<c0232726>] __uart_start+0x2e/0x30
[148193.520888]  [<c0232b16>] uart_start+0x1e/0x2a
[148193.520888]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520888]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520888]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520888]  [<c02237e0>] tty_read+0x59/0x96
[148193.520888]  [<c0223787>] tty_read+0x0/0x96
[148193.520888]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520888]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] su            S 00000000     0  3261      1
[148193.520888]        f748e4c0 00000082 c1bf9680 00000000 c1000000 f748e64c c1c0efa0 00000000 
[148193.520888]        f385bb7c ffff0661 00000000 00000000 00000000 00000000 00000000 000000ff 
[148193.520888]        ffffffea 00000001 f748e4b8 00000000 c0124aa7 00000006 00000000 00000003 
[148193.520888] Call Trace:
[148193.520888]  [<c0124aa7>] do_wait+0x892/0x969
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0124bfd>] sys_wait4+0x7f/0x92
[148193.520888]  [<c0124c23>] sys_waitpid+0x13/0x17
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] kdvb-fe-1     S 9b2e8f10     0  3265      2
[148193.520888]        f747ece0 00000046 c034d300 9b2e8f10 000086ba f747ee6c c1c0efa0 00000000 
[148193.520888]        c0129950 02342a87 02342c65 f3867f70 00000000 00000000 00000000 000000ff 
[148193.520888]        02342c65 02342c65 f7a68da8 000001d9 c02b7f01 c1c0c6d0 f3fadb5c 02342c65 
[148193.520888] Call Trace:
[148193.520888]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520888]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520888]  [<c012968c>] process_timeout+0x0/0x5
[148193.520888]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520888]  [<f92cd3ab>] dvb_frontend_thread+0x12a/0x2a7 [dvb_core]
[148193.520888]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520888]  [<f92cd281>] dvb_frontend_thread+0x0/0x2a7 [dvb_core]
[148193.520888]  [<c01316b3>] kthread+0x38/0x5d
[148193.520888]  [<c013167b>] kthread+0x0/0x5d
[148193.520888]  [<c01044f3>] kernel_thread_helper+0x7/0x10
[148193.520888]  =======================
[148193.520888] startx        S 57686065     0  3276   3261
[148193.520888]        f7a731c0 00000086 00000018 57686065 c1670f0c f7a7334c c1c0efa0 00000000 
[148193.520888]        f3878fd8 ffff06b4 c1670f0c 57686065 00000000 00000000 00000000 000000ff 
[148193.520888]        ffffffea 00000001 f7a731b8 00000000 c0124aa7 00000004 00000000 00000003 
[148193.520888] Call Trace:
[148193.520888]  [<c0124aa7>] do_wait+0x892/0x969
[148193.520888]  [<c011d36d>] hrtick_set+0x8f/0xd8
[148193.520888]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520888]  [<c0124bfd>] sys_wait4+0x7f/0x92
[148193.520888]  [<c0124c23>] sys_waitpid+0x13/0x17
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] apache2       S cfeb6685     0  3290   3235
[148193.520888]        f7888d00 00200086 f2f21dc4 cfeb6685 000083f1 f7888e8c c1c0efa0 00000000 
[148193.520888]        f778f000 f38adf2c 000140af 00000000 00000040 fa10d160 f38adea8 f72bce00 
[148193.520888]        7fffffff 7fffffff f38adeb8 f3f6e75c c02b7ea9 00000000 fa0fb320 c02b8f4d 
[148193.520888] Call Trace:
[148193.520888]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520888]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520888]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520888]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520888]  [<c02505e8>] release_sock+0xf/0x85
[148193.520888]  [<c0279933>] inet_csk_accept+0x9b/0x1db
[148193.520888]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520888]  [<c0293a3c>] inet_accept+0x1c/0x9b
[148193.520888]  [<c024fad0>] sys_accept+0xe5/0x1bd
[148193.520888]  [<f8875bc4>] e1000_clean_tx_irq+0xaf/0x263 [e1000]
[148193.520888]  [<f887880a>] e1000_clean+0xf7/0x215 [e1000]
[148193.520888]  [<c024fc50>] sys_socketcall+0xa8/0x19e
[148193.520888]  [<c012679d>] irq_exit+0x50/0x67
[148193.520888]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520888]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520888]  =======================
[148193.520888] xinit         S 7fffffff     0  3296   3276
[148193.520888]        f7898900 00000086 c0135ee4 7fffffff 7fffffff f7898a8c c1c0efa0 00000000 
[148193.520889]        c013435a ffff0c42 00000000 c013438e 00000000 00000000 00000000 000000ff 
[148193.520889]        ffffffea 00000001 f78988f8 00000000 c0124aa7 00000004 00000000 00000003 
[148193.520889] Call Trace:
[148193.520889]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520889]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520889]  [<c013438e>] ktime_get+0xd/0x21
[148193.520889]  [<c0124aa7>] do_wait+0x892/0x969
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0124bfd>] sys_wait4+0x7f/0x92
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] Xorg          S f3bcda9d     0  3297   3296
[148193.520889]        f7889960 00003082 f749e900 f3bcda9d 00008645 f7889aec c1c0efa0 00000000 
[148193.520889]        c036e2e0 02244e37 00000ba0 00000000 c035b684 00000000 00000001 00003082 
[148193.520889]        7fffffff f7a66ee0 04000000 f38a7f9c c02b7ea9 00003282 f7a66c60 00003082 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520889]  [<c0222343>] tty_poll+0x53/0x60
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c012679d>] irq_exit+0x50/0x67
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520889]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520889]  [<c025087b>] sock_alloc_send_skb+0x68/0x192
[148193.520889]  [<c02a71b1>] unix_stream_recvmsg+0x390/0x480
[148193.520889]  [<c02532c3>] skb_queue_tail+0x11/0x2d
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e454>] sock_aio_write+0xdd/0xea
[148193.520889]  [<c0173edf>] do_sync_write+0xbf/0x100
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c01340dc>] hrtimer_try_to_cancel+0x5c/0x63
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] kdvb-fe-2     S d8827452     0  3303      2
[148193.520889]        f7859520 00000046 c034d300 d8827452 000086b7 f78596ac c1c0efa0 00000000 
[148193.520889]        c0129950 023429d5 02342be7 f38abf70 00000000 00000000 00000000 000000ff 
[148193.520889]        02342be7 02342be7 f7a685a8 000001d9 c02b7f01 c03f24a4 c03f24a4 02342be7 
[148193.520889] Call Trace:
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520889]  [<c012968c>] process_timeout+0x0/0x5
[148193.520889]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520889]  [<f92cd3ab>] dvb_frontend_thread+0x12a/0x2a7 [dvb_core]
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<f92cd281>] dvb_frontend_thread+0x0/0x2a7 [dvb_core]
[148193.520889]  [<c01316b3>] kthread+0x38/0x5d
[148193.520889]  [<c013167b>] kthread+0x0/0x5d
[148193.520889]  [<c01044f3>] kernel_thread_helper+0x7/0x10
[148193.520889]  =======================
[148193.520889] kdvb-fe-3     S b52961e3     0  3312      2
[148193.520889]        f7551640 00000046 f743eca0 b52961e3 000086c7 f75517cc c1c0efa0 00000000 
[148193.520889]        c0129950 f38d1f70 00000002 00000000 00000286 c0129a63 00000000 00000286 
[148193.520889]        02342beb 02342beb f796fda8 000001d9 c02b7f01 c03f24c4 c03f24c4 02342beb 
[148193.520889] Call Trace:
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520889]  [<c012968c>] process_timeout+0x0/0x5
[148193.520889]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520889]  [<f92cd3ab>] dvb_frontend_thread+0x12a/0x2a7 [dvb_core]
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<f92cd281>] dvb_frontend_thread+0x0/0x2a7 [dvb_core]
[148193.520889]  [<c01316b3>] kthread+0x38/0x5d
[148193.520889]  [<c013167b>] kthread+0x0/0x5d
[148193.520889]  [<c01044f3>] kernel_thread_helper+0x7/0x10
[148193.520889]  =======================
[148193.520889] mythfrontend  S f3b73b5c     0  3343   3296
[148193.520889]        f3b5adc0 00000086 c034d300 f3b73b5c 0000007b f3b5af4c c1c0efa0 00000000 
[148193.520889]        c0129950 02342b44 02342b47 f3b73b5c 00000000 00000000 00000000 000000ff 
[148193.520889]        02342b47 02342b47 20000000 f3b73f9c c02b7f01 c03f1fa4 c03f1fa4 02342b47 
[148193.520889] Call Trace:
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520889]  [<c012968c>] process_timeout+0x0/0x5
[148193.520889]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0257d8e>] netif_receive_skb+0x2d6/0x343
[148193.520889]  [<c025a139>] process_backlog+0x74/0xce
[148193.520889]  [<c0259a7e>] net_rx_action+0x9c/0x1b9
[148193.520889]  [<c0126419>] __do_softirq+0x66/0xd3
[148193.520889]  [<c0126702>] local_bh_enable+0x66/0x71
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c0275d31>] ip_finish_output+0x1c5/0x1fc
[148193.520889]  [<c02758bf>] ip_local_out+0x15/0x17
[148193.520889]  [<c02762e1>] ip_queue_xmit+0x25b/0x29d
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<fabdff58>] _nv004365rm+0x24/0x70 [nvidia]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<fabdff84>] _nv004365rm+0x50/0x70 [nvidia]
[148193.520889]  [<fabdff58>] _nv004365rm+0x24/0x70 [nvidia]
[148193.520889]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520889]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c012679d>] irq_exit+0x50/0x67
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c0253396>] skb_dequeue+0x42/0x48
[148193.520889]  [<c02a71b1>] unix_stream_recvmsg+0x390/0x480
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c021a373>] pnp_bus_suspend+0x2/0x57
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520889]  [<c0135f76>] do_gettimeofday+0xd/0x27
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythfrontend  S 00000000     0  3362   3296
[148193.520889]        f3b7a180 00000086 c1c0c2f8 00000000 c0133c26 f3b7a30c c1c0efa0 00000000 
[148193.520889]        f3bbfe5c 02342b1e 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520889]        00000000 00000000 f3bbfe5c 08302f2c c013a6a5 00090a81 00090a81 00000000 
[148193.520889] Call Trace:
[148193.520889]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520889]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520889]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520889]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520889]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520889]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520889]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythfrontend  S 00000000     0  3363   3296
[148193.520889]        f3b7a5a0 00000086 c1c0c2f8 00000000 c0133c26 f3b7a72c c1c0efa0 00000000 
[148193.520889]        f3b69e5c 02342b2d 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520889]        00000000 00000000 f3b69e5c b408f278 c013a6a5 00000001 00000001 00000000 
[148193.520889] Call Trace:
[148193.520889]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520889]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520889]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520889]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520889]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520889]  [<c011fc07>] check_preempt_wakeup+0xa2/0xc2
[148193.520889]  [<c011c59e>] rebalance_domains+0x6d/0x355
[148193.520889]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520889]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythfrontend  S f67d381c     0  3364   3296
[148193.520889]        f3b7a9c0 00000086 c034d300 f67d381c 000086c7 f3b7ab4c c1c0efa0 00000000 
[148193.520889]        c0129950 f3b6bb5c 0000284a 00000000 00000286 c0129a63 00000000 00000286 
[148193.520889]        02342c1e 02342c1e 00000200 f3b6bf9c c02b7f01 c03f1e5c c03f1e5c 02342c1e 
[148193.520889] Call Trace:
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520889]  [<c012968c>] process_timeout+0x0/0x5
[148193.520889]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<c024d73d>] raw_pci_read+0x3d/0x45
[148193.520889]  [<c024d80b>] pci_read+0x1c/0x21
[148193.520889]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520889]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520889]  [<f8a30b0b>] ivtv_irq_handler+0xb37/0xdb8 [ivtv]
[148193.520889]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<f88425c9>] ehci_irq+0x1a/0x128 [ehci_hcd]
[148193.520889]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c012679d>] irq_exit+0x50/0x67
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520889]  [<c0253816>] skb_release_data+0x2c/0x86
[148193.520889]  [<c0250bcb>] sk_free+0x97/0xaa
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c028e644>] udp_ioctl+0x5a/0x5e
[148193.520889]  [<c028e5ea>] udp_ioctl+0x0/0x5e
[148193.520889]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythfrontend  S b40e9cb7     0  3370   3296
[148193.520889]        f3be5a60 00000086 00000001 b40e9cb7 00005ba3 f3be5bec c1c0efa0 00000000 
[148193.520889]        000001fe 003519eb 0002be4e 00000000 00351a31 00000000 00000000 00000246 
[148193.520889]        f3be7eb0 00000000 c0403fe0 082e6aa4 c013a642 00000011 00000011 00000000 
[148193.520889] Call Trace:
[148193.520889]  [<c013a642>] futex_wait+0x199/0x31d
[148193.520889]  [<c01df7cc>] rb_insert_color+0x4c/0xad
[148193.520889]  [<c0157c5a>] generic_file_aio_write+0x5b/0xa9
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520889]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520889]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520889]  [<c0174c3a>] sys_write+0x5b/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythfrontend  S d81b2ae8     0  3380   3296
[148193.520889]        f3be5220 00000086 f3be41a0 d81b2ae8 000086c5 f3be53ac c1c0efa0 00000000 
[148193.520889]        c036e2e0 0234187e 00028e28 00000000 00000000 00000000 00000000 000000ff 
[148193.520889]        7fffffff f2eb1e80 08000000 f3bf7f9c c02b7ea9 00002000 0000000d 00000207 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c01318c2>] remove_wait_queue+0xc/0x34
[148193.520889]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520889]  [<c027b144>] tcp_poll+0x14/0x10e
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<f8876e57>] e1000_xmit_frame+0xa59/0xaa3 [e1000]
[148193.520889]  [<c018fd1f>] __getblk+0x27/0x24e
[148193.520889]  [<f88f876b>] do_get_write_access+0x2f8/0x331 [jbd]
[148193.520889]  [<f897a523>] __ext3_get_inode_loc+0xcf/0x26c [ext3]
[148193.520889]  [<f898537b>] __ext3_journal_dirty_metadata+0x13/0x32 [ext3]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f88425c9>] ehci_irq+0x1a/0x128 [ehci_hcd]
[148193.520889]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f88426b7>] ehci_irq+0x108/0x128 [ehci_hcd]
[148193.520889]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c0254f2d>] memcpy_toiovec+0x27/0x4a
[148193.520889]  [<c0255428>] skb_copy_datagram_iovec+0xfe/0x1bf
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c027d0dc>] tcp_recvmsg+0x8b6/0x9b8
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c01e4d9c>] pci_bus_read_config_word+0x59/0x64
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c027b579>] tcp_ioctl+0x101/0x10c
[148193.520889]  [<c027b478>] tcp_ioctl+0x0/0x10c
[148193.520889]  [<c0292cd3>] inet_ioctl+0xa0/0xa3
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythfrontend  S 486a6f85     0  3382   3296
[148193.520889]        f3be4e00 00000086 f74aed40 486a6f85 00005d45 f3be4f8c c1c0efa0 00000000 
[148193.520889]        00000000 00000000 00062a3a 00000000 c0253e7d 00000000 f74139e0 f3eced80 
[148193.520889]        7fffffff 00000000 f3443e5c f3bb1040 c02b7ea9 c0135ee4 224ee1f6 f3443df8 
[148193.520889] Call Trace:
[148193.520889]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520889]  [<c02a814a>] unix_write_space+0xf/0x63
[148193.520889]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520889]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c01790f4>] pipe_ioctl+0x51/0x56
[148193.520889]  [<c01790a3>] pipe_ioctl+0x0/0x56
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] irexec        S 48682d9d     0  3351   3343
[148193.520889]        f3b7ba40 00000082 f7a52100 48682d9d 00005d45 f3b7bbcc c1c0efa0 00000000 
[148193.520889]        c30c5660 f795e7c4 0000af9e 00000000 c011b614 00000003 00000002 c3131c60 
[148193.520889]        7fffffff 00000000 f3b7de5c f388d040 c02b7ea9 f752604c 37b00000 f7813638 
[148193.520889] Call Trace:
[148193.520889]  [<c011b614>] try_to_wake_up+0xe8/0xf1
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c02a814a>] unix_write_space+0xf/0x63
[148193.520889]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520889]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<f92c97db>] dvb_dmx_swfilter+0xc5/0x105 [dvb_core]
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mtd           S 33f0e486     0  3355      1
[148193.520889]        f3b5a160 00000086 c034d300 33f0e486 000086c7 f3b5a2ec c1c0efa0 00000000 
[148193.520889]        c0129950 02342adf 02342bdc f3b9bb5c 00000000 00000000 00000000 000000ff 
[148193.520889]        02342bdc 02342bdc 00000020 f3b9bf9c c02b7f01 f7441b5c c03f244c 02342bdc 
[148193.520889] Call Trace:
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520889]  [<c012968c>] process_timeout+0x0/0x5
[148193.520889]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<fabdff86>] _nv004365rm+0x52/0x70 [nvidia]
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<fabb28fc>] _nv008244rm+0x70/0x95 [nvidia]
[148193.520889]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520889]  [<c024d73d>] raw_pci_read+0x3d/0x45
[148193.520889]  [<c024d80b>] pci_read+0x1c/0x21
[148193.520889]  [<c01e4d9c>] pci_bus_read_config_word+0x59/0x64
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<fabb2ab5>] _nv008482rm+0x1c/0x20 [nvidia]
[148193.520889]  [<fabb2a02>] _nv008484rm+0x21/0x3b [nvidia]
[148193.520889]  [<fabb2764>] _nv008168rm+0xbc/0xc6 [nvidia]
[148193.520889]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520889]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<f883f230>] end_unlink_async+0xb5/0xcd [ehci_hcd]
[148193.520889]  [<f884262c>] ehci_irq+0x7d/0x128 [ehci_hcd]
[148193.520889]  [<c01110b8>] ack_ioapic_quirk_irq+0x34/0x85
[148193.520889]  [<c0151dd6>] handle_IRQ_event+0x23/0x51
[148193.520889]  [<c0152eff>] handle_fasteoi_irq+0x9b/0xa4
[148193.520889]  [<c012679d>] irq_exit+0x50/0x67
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c0133b45>] hrtimer_reprogram+0x83/0x9b
[148193.520889]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520889]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520889]  [<c024c850>] pci_conf1_read+0xa4/0xac
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<fabe00db>] _nv004359rm+0x19/0x1d [nvidia]
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<fabf33ea>] _nv003983rm+0x1d5/0x212 [nvidia]
[148193.520889]  [<fabf1bd2>] _nv003976rm+0x3d/0x65 [nvidia]
[148193.520889]  [<fabf7ed2>] rm_isr+0x9c/0xef [nvidia]
[148193.520889]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520889]  [<c0135f76>] do_gettimeofday+0xd/0x27
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mtd           S 00000000     0  3358      1
[148193.520889]        f3b5a580 00000086 c1c0c2f8 00000000 c0133c26 f3b5a70c c1c0efa0 00000000 
[148193.520889]        f3b75e5c 02342ad8 00000282 c01341ee 00000000 00000000 00000000 000000ff 
[148193.520889]        00000000 00000000 f3b75e5c b53632a8 c013a6a5 00000001 00000001 00000000 
[148193.520889] Call Trace:
[148193.520889]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520889]  [<c01341ee>] hrtimer_start+0xf7/0x110
[148193.520889]  [<c013a6a5>] futex_wait+0x1fc/0x31d
[148193.520889]  [<c0133e18>] hrtimer_wakeup+0x0/0x18
[148193.520889]  [<c013a689>] futex_wait+0x1e0/0x31d
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c013b4df>] do_futex+0x68/0x6ff
[148193.520889]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520889]  [<c013bc47>] sys_futex+0xd1/0xe6
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] ratpoison     S ced50264     0  3357   3343
[148193.520889]        f3b5a9a0 00000082 f7889960 ced50264 00005d3c f3b5ab2c c1c0efa0 00000000 
[148193.520889]        c012679d c0105f3f 0000254f 00000000 00000008 00000003 c01042a7 f3b4cac0 
[148193.520889]        7fffffff f3fbe2c0 00000008 f3b9ff9c c02b7ea9 00000246 0000007b 00000203 
[148193.520889] Call Trace:
[148193.520889]  [<c012679d>] irq_exit+0x50/0x67
[148193.520889]  [<c0105f3f>] do_IRQ+0x52/0x63
[148193.520889]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520889]  [<c02a7510>] unix_poll+0x17/0x8c
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<f8894f36>] ide_dma_exec_cmd+0x17/0x1a [ide_core]
[148193.520889]  [<c0108214>] nommu_map_single+0x2b/0x43
[148193.520889]  [<f8876e57>] e1000_xmit_frame+0xa59/0xaa3 [e1000]
[148193.520889]  [<c0258370>] dev_hard_start_xmit+0x1eb/0x24f
[148193.520889]  [<c0266456>] __qdisc_run+0xcc/0x17c
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c0275d31>] ip_finish_output+0x1c5/0x1fc
[148193.520889]  [<c02758bf>] ip_local_out+0x15/0x17
[148193.520889]  [<c02762e1>] ip_queue_xmit+0x25b/0x29d
[148193.520889]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520889]  [<c0289531>] tcp_v4_send_check+0x7a/0xb0
[148193.520889]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520889]  [<c025087b>] sock_alloc_send_skb+0x68/0x192
[148193.520889]  [<c02532c3>] skb_queue_tail+0x11/0x2d
[148193.520889]  [<c0251d95>] sock_def_readable+0xf/0x58
[148193.520889]  [<c02a7814>] unix_stream_sendmsg+0x1fc/0x2c7
[148193.520889]  [<c02a814a>] unix_write_space+0xf/0x63
[148193.520889]  [<c0253396>] skb_dequeue+0x42/0x48
[148193.520889]  [<c02a71b1>] unix_stream_recvmsg+0x390/0x480
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<f887880a>] e1000_clean+0xf7/0x215 [e1000]
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythlcdserver S a8c418c9     0  3377      1
[148193.520889]        f3be41a0 00000086 f744f920 a8c418c9 000086c7 f3be432c c1c0efa0 00000000 
[148193.520889]        c0129950 02342adf 02342bab f3bf3b5c 00000000 00000000 00000000 000000ff 
[148193.520889]        02342bab 02342bab 00010000 f3bf3f9c c02b7f01 c03f22c4 c03f22c4 02342bab 
[148193.520889] Call Trace:
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c02b7f01>] schedule_timeout+0x6b/0x86
[148193.520889]  [<c012968c>] process_timeout+0x0/0x5
[148193.520889]  [<c02b7efc>] schedule_timeout+0x66/0x86
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0259a7e>] net_rx_action+0x9c/0x1b9
[148193.520889]  [<c0126419>] __do_softirq+0x66/0xd3
[148193.520889]  [<c0126702>] local_bh_enable+0x66/0x71
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c0275d31>] ip_finish_output+0x1c5/0x1fc
[148193.520889]  [<c02758bf>] ip_local_out+0x15/0x17
[148193.520889]  [<c02762e1>] ip_queue_xmit+0x25b/0x29d
[148193.520889]  [<c01df7cc>] rb_insert_color+0x4c/0xad
[148193.520889]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520889]  [<c028485c>] tcp_transmit_skb+0x6a2/0x6d5
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<c0254f2d>] memcpy_toiovec+0x27/0x4a
[148193.520889]  [<c0255428>] skb_copy_datagram_iovec+0xfe/0x1bf
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c027d0dc>] tcp_recvmsg+0x8b6/0x9b8
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0176a3d>] cp_new_stat64+0xfc/0x10e
[148193.520889]  [<f8a2ffe8>] ivtv_irq_handler+0x14/0xdb8 [ivtv]
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c027b579>] tcp_ioctl+0x101/0x10c
[148193.520889]  [<c027b478>] tcp_ioctl+0x0/0x10c
[148193.520889]  [<c0292cd3>] inet_ioctl+0xa0/0xa3
[148193.520889]  [<c017f6e9>] sys_select+0x9f/0x180
[148193.520889]  [<c0135f76>] do_gettimeofday+0xd/0x27
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] mythlcdserver S e855f4f2     0  3381      1
[148193.520889]        f3be49e0 00000086 f77a2500 e855f4f2 00007750 f3be4b6c c1c0efa0 00000000 
[148193.520889]        00000000 01925c5c 00003ff4 00000000 00000000 00000000 00000000 000000ff 
[148193.520889]        7fffffff f3ba6840 00000040 f3be9f9c c02b7ea9 378130c0 f7877400 00000203 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c01318c2>] remove_wait_queue+0xc/0x34
[148193.520889]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520889]  [<c0178e2b>] pipe_poll+0x24/0x7d
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<f8876e57>] e1000_xmit_frame+0xa59/0xaa3 [e1000]
[148193.520889]  [<f88411df>] ehci_urb_enqueue+0x15c/0xd12 [ehci_hcd]
[148193.520889]  [<c0258370>] dev_hard_start_xmit+0x1eb/0x24f
[148193.520889]  [<c0266456>] __qdisc_run+0xcc/0x17c
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c0275d31>] ip_finish_output+0x1c5/0x1fc
[148193.520889]  [<c02758bf>] ip_local_out+0x15/0x17
[148193.520889]  [<c02762e1>] ip_queue_xmit+0x25b/0x29d
[148193.520889]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520889]  [<c0289531>] tcp_v4_send_check+0x7a/0xb0
[148193.520889]  [<c028485c>] tcp_transmit_skb+0x6a2/0x6d5
[148193.520889]  [<fa0b2aa3>] rpc_wake_up_queued_task+0x14/0x1d [sunrpc]
[148193.520889]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520889]  [<c0135ee4>] getnstimeofday+0x37/0xbc
[148193.520889]  [<c013435a>] ktime_get_ts+0x22/0x49
[148193.520889]  [<c013438e>] ktime_get+0xd/0x21
[148193.520889]  [<c0119081>] hrtick_start_fair+0xeb/0x12c
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c0184ce6>] touch_atime+0xc7/0xd1
[148193.520889]  [<c0187278>] mnt_drop_write+0x1a/0xb4
[148193.520889]  [<c0179dae>] pipe_read+0x31d/0x32b
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c027b579>] tcp_ioctl+0x101/0x10c
[148193.520889]  [<c027b478>] tcp_ioctl+0x0/0x10c
[148193.520889]  [<c0292cd3>] inet_ioctl+0xa0/0xa3
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          S 7b4635e4     0  3460   2733
[148193.520889]        f3425940 00000082 f3425100 7b4635e4 000000b1 f3425acc c1c0efa0 00000000 
[148193.520889]        00000000 00000000 000418be 00000000 00000000 f3425940 00000000 00000000 
[148193.520889]        7fffffff 00000000 f3423e5c f368dc80 c02b7ea9 f3eda560 00000060 f3423e0c 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0182aea>] __d_lookup+0x98/0xd7
[148193.520889]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520889]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          S c974c621     0  3462   3460
[148193.520889]        f3425520 00000086 f3425100 c974c621 000056bc f34256ac c1c0efa0 00000000 
[148193.520889]        0000000a 016aa88c 00005e26 00000000 c035b684 00000000 00000001 00000082 
[148193.520889]        7fffffff f3665400 00000400 f3417f9c c02b7ea9 00000282 f3665400 00000082 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520889]  [<c0222343>] tty_poll+0x53/0x60
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0258370>] dev_hard_start_xmit+0x1eb/0x24f
[148193.520889]  [<c0266456>] __qdisc_run+0xcc/0x17c
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c025ea9c>] neigh_resolve_output+0x1f1/0x21b
[148193.520889]  [<c0275d31>] ip_finish_output+0x1c5/0x1fc
[148193.520889]  [<c02758bf>] ip_local_out+0x15/0x17
[148193.520889]  [<c02762e1>] ip_queue_xmit+0x25b/0x29d
[148193.520889]  [<c028485c>] tcp_transmit_skb+0x6a2/0x6d5
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<c0285e67>] __tcp_push_pending_frames+0x630/0x6c9
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c027c427>] tcp_sendmsg+0x7fc/0x8fe
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e454>] sock_aio_write+0xdd/0xea
[148193.520889]  [<c0173edf>] do_sync_write+0xbf/0x100
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] bash          S 00000282     0  3463   3462
[148193.520889]        f3425100 00000086 4b8f2065 00000282 00000000 f342528c c1c0efa0 00000000 
[148193.520889]        c0161e6f 016aa88c 00000001 f78c3680 00000000 00000000 00000000 000000ff 
[148193.520889]        7fffffff f3ffb400 f2e9bf44 bf85611f c02b7ea9 000005f4 000005f2 f79a1f01 
[148193.520889] Call Trace:
[148193.520889]  [<c0161e6f>] do_wp_page+0x1da/0x49f
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<f887846c>] e1000_clean_rx_irq+0x429/0x46f [e1000]
[148193.520889]  [<c013192b>] add_wait_queue+0x12/0x33
[148193.520889]  [<c0226370>] read_chan+0x357/0x5d3
[148193.520889]  [<c013438e>] ktime_get+0xd/0x21
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0226019>] read_chan+0x0/0x5d3
[148193.520889]  [<c02237e0>] tty_read+0x59/0x96
[148193.520889]  [<c0223787>] tty_read+0x0/0x96
[148193.520889]  [<c0174767>] vfs_read+0x81/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] apache2       S 9c01e3b4     0 13762   3235
[148193.520889]        f2f799c0 00200086 f342a5d4 9c01e3b4 00005ea1 f2f79b4c c1c0efa0 00000000 
[148193.520889]        f342a5d4 00200297 00018177 00000000 f342a5d4 f354f860 f3ffb0fc f354f820 
[148193.520889]        7fffffff 7fffffff f2eadeb8 f3f6e75c c02b7ea9 f342a5d4 00000000 c02b8f4d 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c0279933>] inet_csk_accept+0x9b/0x1db
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c0293a3c>] inet_accept+0x1c/0x9b
[148193.520889]  [<c024fad0>] sys_accept+0xe5/0x1bd
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<fa0d6738>] inet6_destroy_sock+0x22/0x3a [ipv6]
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c024fc50>] sys_socketcall+0xa8/0x19e
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] apache2       S 00000001     0 13763   3235
[148193.520889]        f2f78100 00200082 c313fdc4 00000001 00000000 f2f7828c c1c0efa0 00000000 
[148193.520889]        f342a454 0188bf63 00000000 000000e4 00000000 00000000 00000000 000000ff 
[148193.520889]        7fffffff 7fffffff f7909eb8 f3f6e75c c02b7ea9 00000000 fa0fb320 c02b8f4d 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c0279933>] inet_csk_accept+0x9b/0x1db
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c0293a3c>] inet_accept+0x1c/0x9b
[148193.520889]  [<c024fad0>] sys_accept+0xe5/0x1bd
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<fa0d6738>] inet6_destroy_sock+0x22/0x3a [ipv6]
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c024fc50>] sys_socketcall+0xa8/0x19e
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] apache2       S 9a19ff9b     0 13764   3235
[148193.520889]        f2f78520 00200086 c0354c40 9a19ff9b 00005ea1 f2f786ac c1c0efa0 00000000 
[148193.520889]        00000001 00000000 0001588b 00000000 c0354c54 00000000 00000001 00000001 
[148193.520889]        7fffffff 7fffffff f2ee9eb8 f3f6e75c c02b7ea9 00000020 f3f2c130 c02b8f4d 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c0279933>] inet_csk_accept+0x9b/0x1db
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c0293a3c>] inet_accept+0x1c/0x9b
[148193.520889]  [<c024fad0>] sys_accept+0xe5/0x1bd
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<fa0d6738>] inet6_destroy_sock+0x22/0x3a [ipv6]
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c024fc50>] sys_socketcall+0xa8/0x19e
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] apache2       S 00000001     0 13765   3235
[148193.520889]        f79239a0 00200086 f2f21384 00000001 00000000 f7923b2c c1c0efa0 00000000 
[148193.520889]        f778f000 02287310 00000000 00000089 00000000 00000000 00000000 000000ff 
[148193.520889]        7fffffff 7fffffff f2f9beb8 f3f6e75c c02b7ea9 00000000 fa0fb320 c02b8f4d 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02506e2>] lock_sock_nested+0x84/0x8c
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c0279933>] inet_csk_accept+0x9b/0x1db
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c0293a3c>] inet_accept+0x1c/0x9b
[148193.520889]  [<c024fad0>] sys_accept+0xe5/0x1bd
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<f887880a>] e1000_clean+0xf7/0x215 [e1000]
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c024fc50>] sys_socketcall+0xa8/0x19e
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          D 00000002     0 19654   2733
[148193.520889]        f7923160 00000086 c32abc50 00000002 00011200 f79232ec c1c0efa0 00000000 
[148193.520889]        c32abc50 0226dcfc c017163c c32abc50 00000000 00000000 00000000 000000ff 
[148193.520889]        c32abc74 00000000 c32abc7c c1c02390 fa0b27a9 c02b803e fa0b2784 f3ee5de8 
[148193.520889] Call Trace:
[148193.520889]  [<c017163c>] cache_alloc_refill+0x54/0x44d
[148193.520889]  [<fa0b27a9>] rpc_wait_bit_killable+0x25/0x2a [sunrpc]
[148193.520889]  [<c02b803e>] __wait_on_bit+0x33/0x58
[148193.520889]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520889]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520889]  [<c02b80c2>] out_of_line_wait_on_bit+0x5f/0x67
[148193.520889]  [<c01317a1>] wake_bit_function+0x0/0x3c
[148193.520889]  [<fa0b2bea>] __rpc_execute+0xbe/0x1d9 [sunrpc]
[148193.520889]  [<fa0ada72>] rpc_run_task+0x40/0x45 [sunrpc]
[148193.520889]  [<fa0adb00>] rpc_call_sync+0x38/0x52 [sunrpc]
[148193.520889]  [<fa12e23d>] nfs3_rpc_wrapper+0x14/0x49 [nfs]
[148193.520889]  [<fa12e76f>] nfs3_proc_access+0x101/0x166 [nfs]
[148193.520889]  [<c01d0000>] elv_merge+0x51/0x15b
[148193.520889]  [<c01e0532>] number+0x13d/0x217
[148193.520889]  [<c01195a6>] find_busiest_group+0x21e/0x623
[148193.520889]  [<c0182aea>] __d_lookup+0x98/0xd7
[148193.520889]  [<fa120c00>] nfs_do_access+0x134/0x2a7 [nfs]
[148193.520889]  [<fa0b36d8>] rpcauth_lookupcred+0x69/0x8f [sunrpc]
[148193.520889]  [<fa120e30>] nfs_permission+0xbd/0x11d [nfs]
[148193.520889]  [<fa120d73>] nfs_permission+0x0/0x11d [nfs]
[148193.520889]  [<c017a6cd>] permission+0xa3/0xfc
[148193.520889]  [<c017b8f9>] __link_path_walk+0x11c/0xb0b
[148193.520889]  [<f88f8170>] __journal_file_buffer+0xa2/0x123 [jbd]
[148193.520889]  [<c0158670>] filemap_fault+0x1f5/0x359
[148193.520889]  [<c017c31f>] path_walk+0x37/0x70
[148193.520889]  [<c017c5ce>] do_path_lookup+0x122/0x184
[148193.520889]  [<c017cfb0>] __path_lookup_intent_open+0x42/0x72
[148193.520889]  [<c017d02f>] path_lookup_open+0xf/0x13
[148193.520889]  [<c017d0ba>] do_filp_open+0x87/0x684
[148193.520889]  [<c016462b>] free_pgtables+0x86/0x93
[148193.520889]  [<c0172994>] do_sys_open+0x40/0xb0
[148193.520889]  [<c0172a48>] sys_open+0x1e/0x23
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          S dcaf0343     0 19655  19654
[148193.520889]        f7922500 00000082 f7923160 dcaf0343 0000839b f792268c c1c0efa0 00000000 
[148193.520889]        f7923160 f7922528 0000052d 00000000 f7923160 c1c0efa0 00000001 00000002 
[148193.520889]        7fffffff 00000000 f2ed5e5c f368dac0 c02b7ea9 f3ece6c0 00000140 f3ece6c0 
[148193.520889] Call Trace:
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520889]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520889]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          S c0126419     0 19656   2733
[148193.520889]        f7922d40 00000082 c034d300 c0126419 00000046 f7922ecc c1c0efa0 00000000 
[148193.520889]        00000046 0233819e 00000003 c035b684 00000000 00000000 00000000 000000ff 
[148193.520889]        7fffffff f747b0e0 00000200 c3129f9c c02b7ea9 00000282 f747b0e0 00000082 
[148193.520889] Call Trace:
[148193.520889]  [<c0126419>] __do_softirq+0x66/0xd3
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520889]  [<c0222343>] tty_poll+0x53/0x60
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0258370>] dev_hard_start_xmit+0x1eb/0x24f
[148193.520889]  [<c0266456>] __qdisc_run+0xcc/0x17c
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c025ea9c>] neigh_resolve_output+0x1f1/0x21b
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<f8875bc4>] e1000_clean_tx_irq+0xaf/0x263 [e1000]
[148193.520889]  [<f887880a>] e1000_clean+0xf7/0x215 [e1000]
[148193.520889]  [<c0259a7e>] net_rx_action+0x9c/0x1b9
[148193.520889]  [<c0126419>] __do_softirq+0x66/0xd3
[148193.520889]  [<c0254f2d>] memcpy_toiovec+0x27/0x4a
[148193.520889]  [<c025537d>] skb_copy_datagram_iovec+0x53/0x1bf
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c027d0dc>] tcp_recvmsg+0x8b6/0x9b8
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c02244ce>] tty_ioctl+0xb97/0xbd9
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c01318c2>] remove_wait_queue+0xc/0x34
[148193.520889]  [<c011a5dc>] __wake_up+0x29/0x39
[148193.520889]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] bash          D f640561f     0 19665  19656
[148193.520889]        f7922920 00000082 c3077d46 f640561f 000086a3 f7922aac c1c0efa0 00000000 
[148193.520889]        fa0bdfa0 f2c7fc20 00000002 00000000 fa0b38bd f3ee5d00 f78b3840 00000246 
[148193.520889]        c3077d7c 00000000 c3077d84 c1c01550 fa0b27a9 c02b803e fa0b2784 f3ee5d48 
[148193.520889] Call Trace:
[148193.520889]  [<fa0b38bd>] rpcauth_lookup_credcache+0x42/0x180 [sunrpc]
[148193.520889]  [<fa0b27a9>] rpc_wait_bit_killable+0x25/0x2a [sunrpc]
[148193.520889]  [<c02b803e>] __wait_on_bit+0x33/0x58
[148193.520889]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520889]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520889]  [<c02b80c2>] out_of_line_wait_on_bit+0x5f/0x67
[148193.520889]  [<c01317a1>] wake_bit_function+0x0/0x3c
[148193.520889]  [<fa0b2bea>] __rpc_execute+0xbe/0x1d9 [sunrpc]
[148193.520889]  [<fa0ada72>] rpc_run_task+0x40/0x45 [sunrpc]
[148193.520889]  [<fa0adb00>] rpc_call_sync+0x38/0x52 [sunrpc]
[148193.520889]  [<fa12e23d>] nfs3_rpc_wrapper+0x14/0x49 [nfs]
[148193.520889]  [<fa12e4fe>] nfs3_proc_getattr+0x52/0x73 [nfs]
[148193.520889]  [<fa1242fd>] __nfs_revalidate_inode+0xed/0x211 [nfs]
[148193.520889]  [<c017a2ac>] do_lookup+0x53/0x153
[148193.520889]  [<c0186774>] mntput_no_expire+0x13/0xd9
[148193.520889]  [<c017c1f4>] __link_path_walk+0xa17/0xb0b
[148193.520889]  [<f897b2af>] ext3_getblk+0x4a/0x17d [ext3]
[148193.520889]  [<f897b304>] ext3_getblk+0x9f/0x17d [ext3]
[148193.520889]  [<c0186774>] mntput_no_expire+0x13/0xd9
[148193.520889]  [<c017c34f>] path_walk+0x67/0x70
[148193.520889]  [<fa124a5e>] nfs_getattr+0x8f/0xbe [nfs]
[148193.520889]  [<fa1249cf>] nfs_getattr+0x0/0xbe [nfs]
[148193.520889]  [<c0176e52>] vfs_getattr+0x36/0x4d
[148193.520889]  [<c0176f2a>] vfs_lstat_fd+0x27/0x39
[148193.520889]  [<c0176fa9>] sys_lstat64+0xf/0x23
[148193.520889]  [<c0182366>] dput+0x15/0xbb
[148193.520889]  [<c0186774>] mntput_no_expire+0x13/0xd9
[148193.520889]  [<c017289d>] filp_close+0x4d/0x53
[148193.520889]  [<c01739d7>] sys_close+0x5b/0x8d
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          D 00000002     0 20037   2733
[148193.520889]        f2f78940 00000082 c3071000 00000002 00011200 f2f78acc c1c0efa0 00000000 
[148193.520889]        00000000 02319a2c 00000020 00011200 00000000 00000000 00000000 000000ff 
[148193.520889]        c316dc74 00000000 c316dc7c c1c01c10 fa0b27a9 c02b803e fa0b2784 f3ee5528 
[148193.520889] Call Trace:
[148193.520889]  [<fa0b27a9>] rpc_wait_bit_killable+0x25/0x2a [sunrpc]
[148193.520889]  [<c02b803e>] __wait_on_bit+0x33/0x58
[148193.520889]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520889]  [<fa0b2784>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
[148193.520889]  [<c02b80c2>] out_of_line_wait_on_bit+0x5f/0x67
[148193.520889]  [<c01317a1>] wake_bit_function+0x0/0x3c
[148193.520889]  [<fa0b2bea>] __rpc_execute+0xbe/0x1d9 [sunrpc]
[148193.520889]  [<fa0ada72>] rpc_run_task+0x40/0x45 [sunrpc]
[148193.520889]  [<fa0adb00>] rpc_call_sync+0x38/0x52 [sunrpc]
[148193.520889]  [<fa12e23d>] nfs3_rpc_wrapper+0x14/0x49 [nfs]
[148193.520889]  [<fa12e76f>] nfs3_proc_access+0x101/0x166 [nfs]
[148193.520889]  [<c01e0532>] number+0x13d/0x217
[148193.520889]  [<c018f97f>] __find_get_block_slow+0xdd/0xe6
[148193.520889]  [<c018fcee>] __find_get_block+0x176/0x180
[148193.520889]  [<c0182aea>] __d_lookup+0x98/0xd7
[148193.520889]  [<fa120c00>] nfs_do_access+0x134/0x2a7 [nfs]
[148193.520889]  [<fa0b36d8>] rpcauth_lookupcred+0x69/0x8f [sunrpc]
[148193.520889]  [<fa120e30>] nfs_permission+0xbd/0x11d [nfs]
[148193.520889]  [<fa120d73>] nfs_permission+0x0/0x11d [nfs]
[148193.520889]  [<c017a6cd>] permission+0xa3/0xfc
[148193.520889]  [<c017b8f9>] __link_path_walk+0x11c/0xb0b
[148193.520889]  [<f88f8170>] __journal_file_buffer+0xa2/0x123 [jbd]
[148193.520889]  [<c0158670>] filemap_fault+0x1f5/0x359
[148193.520889]  [<c017c31f>] path_walk+0x37/0x70
[148193.520889]  [<c017c5ce>] do_path_lookup+0x122/0x184
[148193.520889]  [<c017cfb0>] __path_lookup_intent_open+0x42/0x72
[148193.520889]  [<c017d02f>] path_lookup_open+0xf/0x13
[148193.520889]  [<c017d0ba>] do_filp_open+0x87/0x684
[148193.520889]  [<c016462b>] free_pgtables+0x86/0x93
[148193.520889]  [<c0172994>] do_sys_open+0x40/0xb0
[148193.520889]  [<c0172a48>] sys_open+0x1e/0x23
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          S 5fdc45c8     0 20038  20037
[148193.520889]        f2f78d60 00000086 f2f78940 5fdc45c8 0000862b f2f78eec c1c0efa0 00000000 
[148193.520889]        f2e8e858 f2e8e640 00000599 00000000 c0129a63 00000001 00000286 f2fa3f70 
[148193.520889]        7fffffff 00000000 f2fa3e5c c3036200 c02b7ea9 f3bdd840 00000140 f3bdd840 
[148193.520889] Call Trace:
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0253e7d>] __alloc_skb+0x49/0xf7
[148193.520889]  [<c013187f>] prepare_to_wait+0x12/0x49
[148193.520889]  [<c02a7004>] unix_stream_recvmsg+0x1e3/0x480
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c024e54b>] sock_aio_read+0xea/0xf8
[148193.520889]  [<c0161c56>] __do_fault+0x30e/0x34d
[148193.520889]  [<c0173fdf>] do_sync_read+0xbf/0xfe
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<f887880a>] e1000_clean+0xf7/0x215 [e1000]
[148193.520889]  [<c01b9157>] security_file_permission+0xc/0xd
[148193.520889]  [<c0174778>] vfs_read+0x92/0x11e
[148193.520889]  [<c0174bb8>] sys_read+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] sshd          S fe2ba3a2     0 20194   2733
[148193.520889]        c30cf680 00000086 c30cfaa0 fe2ba3a2 000086c7 c30cf80c c1c0efa0 00000000 
[148193.520889]        c01042a7 02342ab8 00000001 00000000 c035b684 00000000 00000001 00000082 
[148193.520889]        7fffffff c30c42c0 00000200 f2f09f9c c02b7ea9 00000282 c30c42c0 00000082 
[148193.520889] Call Trace:
[148193.520889]  [<c01042a7>] common_interrupt+0x23/0x28
[148193.520889]  [<c02b7ea9>] schedule_timeout+0x13/0x86
[148193.520889]  [<c0221548>] tty_ldisc_deref+0x4c/0x5b
[148193.520889]  [<c0222343>] tty_poll+0x53/0x60
[148193.520889]  [<c017f09a>] do_select+0x364/0x3bd
[148193.520889]  [<c017f59e>] __pollwait+0x0/0xac
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c011b61d>] default_wake_function+0x0/0x8
[148193.520889]  [<c0258370>] dev_hard_start_xmit+0x1eb/0x24f
[148193.520889]  [<c0266456>] __qdisc_run+0xcc/0x17c
[148193.520889]  [<c025a614>] dev_queue_xmit+0x287/0x2bf
[148193.520889]  [<c025ea9c>] neigh_resolve_output+0x1f1/0x21b
[148193.520889]  [<c0275d3f>] ip_finish_output+0x1d3/0x1fc
[148193.520889]  [<c02758bf>] ip_local_out+0x15/0x17
[148193.520889]  [<c02762e1>] ip_queue_xmit+0x25b/0x29d
[148193.520889]  [<c028485c>] tcp_transmit_skb+0x6a2/0x6d5
[148193.520889]  [<c0129950>] lock_timer_base+0x19/0x35
[148193.520889]  [<c0129a63>] __mod_timer+0x99/0xa3
[148193.520889]  [<c025070f>] sk_reset_timer+0xc/0x16
[148193.520889]  [<c0285e67>] __tcp_push_pending_frames+0x630/0x6c9
[148193.520889]  [<c02b8f4d>] _spin_lock_bh+0x8/0x1e
[148193.520889]  [<c02505e8>] release_sock+0xf/0x85
[148193.520889]  [<c027c427>] tcp_sendmsg+0x7fc/0x8fe
[148193.520889]  [<c017f375>] core_sys_select+0x282/0x29f
[148193.520889]  [<c024e454>] sock_aio_write+0xdd/0xea
[148193.520889]  [<c0133c26>] enqueue_hrtimer+0xc9/0xd4
[148193.520889]  [<c0173edf>] do_sync_write+0xbf/0x100
[148193.520889]  [<c0131774>] autoremove_wake_function+0x0/0x2d
[148193.520889]  [<c017f718>] sys_select+0xce/0x180
[148193.520889]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] bash          R running      0 20196  20194
[148193.520889]        0007f2b9 c310bef4 c03d1720 c310bef4 00000008 c01e0e95 00000000 00000000 
[148193.520889]        3cef4169 00000008 ffffffff 00000021 00000400 c03d1720 01ffffff 00000010 
[148193.520889]        c03d1b20 00000000 ffffffff c030ef22 c310bec2 013d1720 0000000a ffffffff 
[148193.520889] Call Trace:
[148193.520889]  [<c01e0e95>] vsnprintf+0x411/0x452
[148193.520889]  [<c0104774>] print_trace_address+0x0/0x37
[148193.520889]  [<c0122d63>] printk+0x14/0x18
[148193.520889]  [<c01400af>] __print_symbol+0x1c/0x25
[148193.520889]  [<c013572d>] sched_clock_cpu+0x104/0x112
[148193.520889]  [<c0134c00>] up+0x9/0x2a
[148193.520889]  [<c01228cc>] release_console_sem+0x173/0x18c
[148193.520889]  [<c01228cc>] release_console_sem+0x173/0x18c
[148193.520889]  [<c0104774>] print_trace_address+0x0/0x37
[148193.520889]  [<c0122d63>] printk+0x14/0x18
[148193.520889]  [<c0104786>] print_trace_address+0x12/0x37
[148193.520889]  [<c012fdf3>] __kernel_text_address+0x18/0x23
[148193.520889]  [<c01103b4>] touch_nmi_watchdog+0x34/0x3e
[148193.520889]  [<c010481e>] dump_trace+0x73/0xbd
[148193.520889]  [<c010487c>] show_trace_log_lvl+0x14/0x29
[148193.520889]  [<c0104921>] show_stack_log_lvl+0x90/0x98
[148193.520889]  [<c0104f07>] show_stack+0x22/0x28
[148193.520889]  [<c011f170>] show_state_filter+0x39/0x78
[148193.520889]  [<c0230dd5>] __handle_sysrq+0x83/0xfa
[148193.520889]  [<c01a6131>] write_sysrq_trigger+0x0/0x29
[148193.520889]  [<c01a6154>] write_sysrq_trigger+0x23/0x29
[148193.520889]  [<c01a0ee5>] proc_reg_write+0x58/0x6b
[148193.520889]  [<c01a0e8d>] proc_reg_write+0x0/0x6b
[148193.520889]  [<c0174649>] vfs_write+0x83/0x120
[148193.520889]  [<c0174c1b>] sys_write+0x3c/0x63
[148193.520889]  [<c0103853>] sysenter_past_esp+0x78/0xb1
[148193.520889]  =======================
[148193.520889] Sched Debug Version: v0.07, 2.6.26-1-686 #1
[148193.520889] now at 148193560.809862 msecs
[148193.520889]   .sysctl_sched_latency                    : 20.000000
[148193.520889]   .sysctl_sched_min_granularity            : 4.000000
[148193.520889]   .sysctl_sched_wakeup_granularity         : 10.000000
[148193.520889]   .sysctl_sched_child_runs_first           : 0.000001
[148193.520889]   .sysctl_sched_features                   : 895
[148193.520889] 
[148193.520889] cpu#0, 2162.720 MHz
[148193.520889]   .nr_running                    : 2
[148193.520889]   .load                          : 2048
[148193.520889]   .nr_switches                   : 156718457
[148193.520889]   .nr_load_updates               : 17492867
[148193.520889]   .nr_uninterruptible            : 5
[148193.520889]   .jiffies                       : 36973380
[148193.520889]   .next_balance                  : 36.973380
[148193.520889]   .curr->pid                     : 20196
[148193.520889]   .clock                         : 148193520.886692
[148193.520889]   .cpu_load[0]                   : 0
[148193.520889]   .cpu_load[1]                   : 0
[148193.520889]   .cpu_load[2]                   : 0
[148193.520889]   .cpu_load[3]                   : 0
[148193.520889]   .cpu_load[4]                   : 0
[148193.520889] 
[148193.520889] cfs_rq[0]:
[148193.520889]   .exec_clock                    : 0.000000
[148193.520889]   .MIN_vruntime                  : 123570597.680058
[148193.520889]   .min_vruntime                  : 123570617.680058
[148193.520889]   .max_vruntime                  : 123570597.680058
[148193.520889]   .spread                        : 0.000000
[148193.520889]   .spread0                       : 0.000000
[148193.520889]   .nr_running                    : 2
[148193.520889]   .load                          : 2048
[148193.520889]   .nr_spread_over                : 0
[148193.520889] 
[148193.520889] runnable tasks:
[148193.520889]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[148193.520889] ----------------------------------------------------------------------------------------------------------
[148193.520889]            klogd  2696 123570597.680058      7328   120               0               0               0.000000               0.000000               0.000000 /
[148193.520889] R           bash 20196 123570597.680062       502   120               0               0               0.000000               0.000000               0.000000 /
[148193.520889] 

--=-xGIro9u1WVMxjSPc4za8--
