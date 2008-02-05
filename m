From: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Subject: (fwd) nfs hang on 2.6.24
Date: Tue, 5 Feb 2008 10:01:32 +0100
Message-ID: <20080205090132.GA8286@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:49319 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324AbYBEJBw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 04:01:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

please take a look

----- Forwarded message from Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org> -----

Date: Tue, 5 Feb 2008 12:57:37 +1300 (NZDT)
Subject: nfs hang on 2.6.24
From: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
To: debian-kernel@lists.debian.org

I've recently updated to 2.6.24 as recommended on bug 463508.

But the new kernel now has nfs hanging problems.
A few times now it has got into a situation such that any process that
touches an nfs mount hangs.

The machine has both nfs3 and nfs4 mounts. My suspicion is that it relates
to putting a heavy load on both nfs3 and nfs4 mounts at the same time.

The machine for the moment is still hung so let me know if there are
further debugging steps I can perform.

There are many other processes but these are the unique call stacks that
involve nfs related functions.

 =======================
nfsv4-delegre S 00000282     0 17156      2
       df8dcd30 00000046 f8c5f813 00000282 f35d4a60 00000000 93c19d62
000008a4
       df8dce98 c180a940 00000000 f35d4b10 0000a296 00000000 f669be00
f8ce9b74
       f8c5f08b 00000246 e6a59f34 00000000 e6a59f3c c18003b0 f8c62e85
c02bc97f
Call Trace:
 [<f8c5f813>] xprt_timer+0x0/0x6f [sunrpc]
 [<f8ce9b74>] nfs4_xdr_enc_delegreturn+0x0/0x84 [nfs]
 [<f8c5f08b>] xprt_release_xprt+0x39/0x66 [sunrpc]
 [<f8c62e85>] rpc_wait_bit_interruptible+0x1a/0x1f [sunrpc]
 [<c02bc97f>] __wait_on_bit+0x33/0x58
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<c02bca07>] out_of_line_wait_on_bit+0x63/0x6b
 [<c013545e>] wake_bit_function+0x0/0x3c
 [<f8c62e19>] __rpc_wait_for_completion_task+0x32/0x39 [sunrpc]
 [<f8ce1352>] nfs4_wait_for_completion_rpc_task+0x1b/0x2f [nfs]
 [<f8ce2336>] nfs4_proc_delegreturn+0x116/0x172 [nfs]
 [<f8ced370>] nfs_do_return_delegation+0xf/0x1d [nfs]
 [<f8ced88a>] recall_thread+0xad/0xc0 [nfs]
 [<f8ced7dd>] recall_thread+0x0/0xc0 [nfs]
 [<c0104b0f>] kernel_thread_helper+0x7/0x10
 =======================
mysqld        S f704db38     0  3156   3110
       df848130 00000082 00000002 f704db38 f704db30 00000000 6369898c
0000052b
       df848298 c1822940 00000003 0163574b f704db5c f7c86000 000000ff
00000000
       00000000 00000000 f704db5c 016359d3 f7459140 000001f4 c02bc84e
00000001
Call Trace:
 [<c02bc84e>] schedule_timeout+0x70/0x8d
 [<c01048c3>] common_interrupt+0x23/0x28
 [<c012c3e2>] process_timeout+0x0/0x5
 [<c02bc849>] schedule_timeout+0x6b/0x8d
 [<c0183476>] do_select+0x365/0x3bc
 [<c0183a60>] __pollwait+0x0/0xac
 [<c011e069>] enqueue_entity+0x2b/0x3d
 [<c0115343>] apic_wait_icr_idle+0xe/0x15
 [<c011e091>] enqueue_task_fair+0x16/0x24
 [<c011d647>] enqueue_task+0x52/0x5d
 [<c011de8a>] resched_task+0x52/0x54
 [<c011f445>] try_to_wake_up+0x2b8/0x2c2
 [<c013543e>] autoremove_wake_function+0x15/0x35
 [<c011d482>] __wake_up_common+0x32/0x5c
 [<c011eeb8>] __wake_up+0x32/0x42
 [<c013540e>] __wake_up_bit+0x2e/0x33
 [<f8c630f5>] __rpc_do_wake_up_task+0x1fb/0x218 [sunrpc]
 [<f8c6003a>] xdr_partial_copy_from_skb+0x32/0x171 [sunrpc]
 [<f8c63148>] rpc_wake_up_task+0x36/0x4a [sunrpc]
 [<f8c61cfd>] xs_tcp_data_recv+0x3d3/0x407 [sunrpc]
 [<f8c6028f>] xdr_skb_read_bits+0x0/0x35 [sunrpc]
 [<c0259bb5>] skb_release_all+0xa3/0xfa
 [<c028484c>] tcp_read_sock+0x15e/0x16a
 [<f8c6192a>] xs_tcp_data_recv+0x0/0x407 [sunrpc]
 [<f8c624a8>] xs_tcp_data_ready+0x55/0x61 [sunrpc]
 [<c012c8ec>] mod_timer+0x19/0x36
 [<c02564e7>] sk_reset_timer+0xc/0x16
 [<c028ba16>] tcp_rcv_established+0x3ae/0x63c
 [<c0290ceb>] tcp_v4_do_rcv+0x2b/0x343
 [<f8a593a5>] ip_vs_in+0xa5/0x220 [ip_vs]
 [<f8a59300>] ip_vs_in+0x0/0x220 [ip_vs]
 [<c0293000>] tcp_v4_rcv+0x80e/0x882
 [<c0183750>] core_sys_select+0x283/0x2a0
 [<c027a934>] ip_local_deliver_finish+0x114/0x1b7
 [<c0259c6b>] __alloc_skb+0x49/0xf7
 [<c0259bb5>] skb_release_all+0xa3/0xfa
 [<f8833e62>] e1000_alloc_rx_buffers+0x1cb/0x295 [e1000]
 [<c02594b1>] __kfree_skb+0x8/0x61
 [<f88301f9>] e1000_unmap_and_free_tx_resource+0x1b/0x23 [e1000]
 [<f8831c09>] e1000_clean_tx_irq+0xbe/0x2c3 [e1000]
 [<f883480e>] e1000_clean_rx_irq+0x419/0x449 [e1000]
 [<f88343f5>] e1000_clean_rx_irq+0x0/0x449 [e1000]
 [<f8832045>] e1000_clean+0x1e9/0x213 [e1000]
 [<c025fe81>] net_rx_action+0x9f/0x198
 [<c0183bb0>] sys_select+0xa4/0x187
 [<c0103e5e>] sysenter_past_esp+0x6b/0xa1
 =======================
sshd          S f74fdc80     0 17157   3065
       df813830 00000086 00000002 f74fdc80 f74fdc78 00000000 f52ac680
f8c634bf
       df813998 c1822940 00000003 015ba1ef 00000000 f7d6fcd0 000000ff
00000000
       00000000 00000000 f74fdcc0 00000000 f74fdcc8 c1800ce0 f8c62e85
c02bc97f
Call Trace:
 [<f8c634bf>] rpc_sleep_on+0x21/0x221 [sunrpc]
 [<f8c62e85>] rpc_wait_bit_interruptible+0x1a/0x1f [sunrpc]
 [<c02bc97f>] __wait_on_bit+0x33/0x58
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<c02bca07>] out_of_line_wait_on_bit+0x63/0x6b
 [<c013545e>] wake_bit_function+0x0/0x3c
 [<f8c62e19>] __rpc_wait_for_completion_task+0x32/0x39 [sunrpc]
 [<f8ce1352>] nfs4_wait_for_completion_rpc_task+0x1b/0x2f [nfs]
 [<f8ce3812>] _nfs4_proc_open+0x75/0x1b4 [nfs]
 [<f8ce3e0c>] nfs4_do_open+0x112/0x23b [nfs]
 [<f8ce50d3>] nfs4_open_revalidate+0x5e/0x11e [nfs]
 [<f8cd25c1>] nfs_open_revalidate+0xc7/0x187 [nfs]
 [<c017e8c4>] do_lookup+0x101/0x140
 [<c01803f0>] __link_path_walk+0x744/0xb4b
 [<c018083b>] link_path_walk+0x44/0xb3
 [<c0176b59>] get_unused_fd_flags+0x4d/0xba
 [<c0180b23>] do_path_lookup+0x162/0x1c4
 [<c01793cc>] get_empty_filp+0x95/0x152
 [<c0181488>] __path_lookup_intent_open+0x45/0x75
 [<c0181527>] path_lookup_open+0x20/0x25
 [<c0181606>] open_namei+0x72/0x558
 [<c0176e00>] do_filp_open+0x25/0x39
 [<c0176b59>] get_unused_fd_flags+0x4d/0xba
 [<c0176e58>] do_sys_open+0x44/0xc0
 [<c0176f0d>] sys_open+0x1c/0x1e
 [<c0103e5e>] sysenter_past_esp+0x6b/0xa1
 =======================
sshd          S f52e4800     0 17199   3065
       df8dd8f0 00000082 f8c63859 f52e4800 f669be00 c02bd82e 8660c63b
000008ce
       df8dda58 c180a940 00000000 c01868b0 0000a690 00000000 c7387ce4
f7699b80
       f7699b80 00000246 e7379cc0 00000000 e7379cc8 c1802c60 f8c62e85
c02bc97f
Call Trace:
 [<f8c63859>] rpc_wake_up_next+0x12c/0x136 [sunrpc]
 [<c02bd82e>] _spin_lock_bh+0x8/0x18
 [<c01868b0>] dput+0x15/0xdc
 [<f8c62e85>] rpc_wait_bit_interruptible+0x1a/0x1f [sunrpc]
 [<c02bc97f>] __wait_on_bit+0x33/0x58
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<c02bca07>] out_of_line_wait_on_bit+0x63/0x6b
 [<c013545e>] wake_bit_function+0x0/0x3c
 [<f8c62e19>] __rpc_wait_for_completion_task+0x32/0x39 [sunrpc]
 [<f8ce1352>] nfs4_wait_for_completion_rpc_task+0x1b/0x2f [nfs]
 [<f8ce3812>] _nfs4_proc_open+0x75/0x1b4 [nfs]
 [<f8ce3e0c>] nfs4_do_open+0x112/0x23b [nfs]
 [<f8ce50d3>] nfs4_open_revalidate+0x5e/0x11e [nfs]
 [<f8cd25c1>] nfs_open_revalidate+0xc7/0x187 [nfs]
 [<c017e8c4>] do_lookup+0x101/0x140
 [<c01803f0>] __link_path_walk+0x744/0xb4b
 [<f8ce2021>] nfs4_proc_getattr+0x31/0x3e [nfs]
 [<f8cd459b>] __nfs_revalidate_inode+0x269/0x276 [nfs]
 [<c018083b>] link_path_walk+0x44/0xb3
 [<c0176b59>] get_unused_fd_flags+0x4d/0xba
 [<c0180b23>] do_path_lookup+0x162/0x1c4
 [<c01793cc>] get_empty_filp+0x95/0x152
 [<c0181488>] __path_lookup_intent_open+0x45/0x75
 [<c0181527>] path_lookup_open+0x20/0x25
 [<c0181606>] open_namei+0x72/0x558
 [<c0176e00>] do_filp_open+0x25/0x39
 [<c0176b59>] get_unused_fd_flags+0x4d/0xba
 [<c0176e58>] do_sys_open+0x44/0xc0
 [<c0176f0d>] sys_open+0x1c/0x1e
 [<c0103e5e>] sysenter_past_esp+0x6b/0xa1
 =======================
sshd          S f5203bf4     0 17252   3065
       f7cd2db0 00000086 00000002 f5203bf4 f5203bec 00000000 ffffffff
f76742c0
       f7cd2f18 c1822940 00000003 015e25d4 015e2abf c017554d 000000ff
00000000
       00000000 00000000 f5203c34 00000000 f5203c3c c1802f30 f8c62e85
c02bc97f
Call Trace:
 [<c017554d>] cache_alloc_refill+0x58/0x477
 [<f8c62e85>] rpc_wait_bit_interruptible+0x1a/0x1f [sunrpc]
 [<c02bc97f>] __wait_on_bit+0x33/0x58
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
 [<c02bca07>] out_of_line_wait_on_bit+0x63/0x6b
 [<c013545e>] wake_bit_function+0x0/0x3c
 [<f8c632cb>] __rpc_execute+0xeb/0x231 [sunrpc]
 [<f8c62ac7>] rpc_set_active+0x3a/0x56 [sunrpc]
 [<f8c5dc5e>] rpc_do_run_task+0x76/0x8f [sunrpc]
 [<f8c5dcf8>] rpc_call_sync+0x21/0x39 [sunrpc]
 [<f8ce2501>] nfs4_proc_access+0x129/0x19e [nfs]
 [<c0176b59>] get_unused_fd_flags+0x4d/0xba
 [<c0176a8e>] fd_install+0x1b/0x41
 [<c025c25c>] scm_detach_fds+0xf4/0x12c
 [<c02b0fe5>] unix_stream_recvmsg+0x48d/0x4bd
 [<c0259c6b>] __alloc_skb+0x49/0xf7
 [<f8cd0d83>] nfs_do_access+0x133/0x2ab [nfs]
 [<f8c63fb0>] rpcauth_lookupcred+0x65/0x8a [sunrpc]
 [<f8cd0fc0>] nfs_permission+0xc5/0x134 [nfs]
 [<c01868b0>] dput+0x15/0xdc
 [<c017e6c1>] __follow_mount+0x1e/0x60
 [<f8cd0efb>] nfs_permission+0x0/0x134 [nfs]
 [<c017e5bc>] permission+0xa3/0xef
 [<c017fdc6>] __link_path_walk+0x11a/0xb4b
 [<c015a9cd>] find_lock_page+0x19/0x7f
 [<c018083b>] link_path_walk+0x44/0xb3
 [<c0259157>] skb_dequeue+0x39/0x3f
 [<c0180b23>] do_path_lookup+0x162/0x1c4
 [<c017fae8>] getname+0x59/0xad
 [<c01812f4>] __user_walk_fd+0x2f/0x40
 [<c017b33f>] vfs_stat_fd+0x19/0x40
 [<c0259157>] skb_dequeue+0x39/0x3f
 [<c017b41b>] sys_stat64+0xf/0x23
 [<c012fe3f>] set_current_groups+0x14d/0x159
 [<c01bd9cf>] security_capable+0x9/0xa
 [<c012aff8>] __capable+0x8/0x1b
 [<c0131894>] sys_setresuid+0x163/0x18e
 [<c01bdc8f>] security_task_post_setuid+0x17/0x1a
 [<c0103e5e>] sysenter_past_esp+0x6b/0xa1



-- 
To UNSUBSCRIBE, email to debian-kernel-REQUEST@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian.org


----- End forwarded message -----
