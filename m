From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: BUG NULL pointer dereference in SUNRPC xs_udp_send_request
Date: Mon, 23 Feb 2009 12:11:09 -0800
Message-ID: <20090223201108.GB3308@merfinllc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from quackingmoose.com ([63.73.180.143]:59426 "EHLO
	penguin.merfinllc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751680AbZBWUdA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2009 15:33:00 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

  We received the trace below on one of our machines this weekend.   The
machine is running vanilla 2.6.27.14.

  If I'm reading the trace correctly, it looks like this line of
xs_udp_send_request:

   clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);

  The machine is x86 (32-bit).  

  Please let me know if you need anything else e.g .config or full
dmesg.  

  Thanks for your time.

				=a=


--
BUG: unable to handle kernel NULL pointer dereference at 00000008
IP: [<f89fbf5e>] :sunrpc:xs_udp_send_request+0xa3/0xca
*pdpt = 0000000035b6d001 *pde = 0000000000000000 
Oops: 0002 [#1] PREEMPT SMP 
Modules linked in: nfs lockd autofs4 sunrpc ohci_hcd usbcore tg3 libphy [last unloaded: x_tables]

Pid: 1870, comm: mount Not tainted (2.6.27.14-asb #104)
EIP: 0060:[<f89fbf5e>] EFLAGS: 00010202 CPU: 2
EIP is at xs_udp_send_request+0xa3/0xca [sunrpc]
EAX: 00000000 EBX: ffffff95 ECX: 00000010 EDX: 00000000
ESI: f58ba000 EDI: f58f9000 EBP: f78df800 ESP: c66d1a80
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process mount (pid: 1870, ti=c66d0000 task=f78d4a20 task.ti=c66d0000)
Stack: f58ba004 f58ba000 f58ba054 f58ba0b4 f58f9000 f89f981a f78df800 f58f9290 
       f58ba074 c66d1b64 f58ba000 f78df800 f78df848 f89f83a3 f78df848 f78df800 
       00000000 f89fcbe2 f78df800 c66d1ae8 c66d1b04 c66d1bc0 f89f78a9 f63bf800 
Call Trace:
 [<f89f981a>] xprt_transmit+0xd3/0x1ad [sunrpc]
 [<f89f83a3>] call_transmit+0x1b0/0x1e6 [sunrpc]
 [<f89fcbe2>] __rpc_execute+0x63/0x1e1 [sunrpc]
 [<f89f78a9>] rpc_run_task+0x3e/0x45 [sunrpc]
 [<f89f7939>] rpc_call_sync+0x38/0x52 [sunrpc]
 [<f8a02408>] rpcb_register_call+0x85/0xc7 [sunrpc]
 [<f8a024f7>] rpcb_register+0xad/0xb5 [sunrpc]
 [<f89fe43e>] svc_register+0xb0/0x12a [sunrpc]
 [<f89ff7b2>] svc_setup_socket+0x6b/0x242 [sunrpc]
 [<f89ffbde>] svc_create_socket+0x255/0x2bd [sunrpc]
 [<f89f7b5d>] rpc_shutdown_client+0xa2/0xaa [sunrpc]
 [<f8a02411>] rpcb_register_call+0x8e/0xc7 [sunrpc]
 [<f89fc7d4>] rpc_wait_bit_killable+0x0/0x2a [sunrpc]
 [<f8a024f7>] rpcb_register+0xad/0xb5 [sunrpc]
 [<f89ffc57>] svc_tcp_create+0x11/0x14 [sunrpc]
 [<f8a07055>] svc_create_xprt+0xd8/0x18c [sunrpc]
 [<f8891f45>] make_socks+0x85/0xc2 [lockd]
 [<f889216f>] lockd_up+0x80/0x145 [lockd]
 [<f8890384>] nlmclnt_init+0x1c/0x4e [lockd]
 [<f8a1d80b>] nfs_start_lockd+0x5f/0x7d [nfs]
 [<f8a1e1dc>] nfs_create_server+0x6d9/0x9bd [nfs]
 [<c02a9cd7>] sock_common_recvmsg+0x2f/0x45
 [<c02a8784>] sock_recvmsg+0xc8/0xe3
 [<c02a8857>] sock_sendmsg+0xb8/0xd1
 [<c0114407>] kmap_atomic+0x11/0x14
 [<c0143fa3>] get_page_from_freelist+0x352/0x3ca
 [<c01bf5b6>] idr_get_empty_slot+0x150/0x225
 [<f8a25518>] nfs_get_sb+0x651/0x87d [nfs]
 [<c0148e3a>] kstrdup+0x27/0x48
 [<c015f9cb>] vfs_kern_mount+0x39/0x72
 [<c015fa42>] do_kern_mount+0x2f/0xb4
 [<c017166f>] do_new_mount+0x55/0x89
 [<c017181f>] do_mount+0x17c/0x19b
 [<c030e3da>] error_code+0x72/0x78
 [<c016fa36>] copy_mount_options+0x78/0x10d
 [<c01718ab>] sys_mount+0x6d/0xaa
 [<c0102cb9>] sysenter_do_call+0x12/0x25
 =======================
Code: 83 fb e0 74 13 83 fb f5 75 1b 89 e8 e8 6c e7 ff ff bb f5 ff ff ff eb 32 8b 87 f4 02 00 00 f0 80 60 08 fe eb 25 8b 87 f4 02 00 00 <f0> 80 60 08 fe 80 3d 68 b8 a1 f8 00 79 11 89 d8 f7 d8 50 68 fa 
EIP: [<f89fbf5e>] xs_udp_send_request+0xa3/0xca [sunrpc] SS:ESP 0068:c66d1a80
---[ end trace a09733af92e06ec6 ]---
 
-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org
