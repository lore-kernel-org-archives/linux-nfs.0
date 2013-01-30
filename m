Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34126 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761Ab3A3VbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2013 16:31:10 -0500
Date: Wed, 30 Jan 2013 16:31:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thierry Moreau <thierry.moreau@connotech.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel message when no support for NFSv4 compiled into it
Message-ID: <20130130213109.GA15584@fieldses.org>
References: <510812C0.1070307@connotech.com>
 <20130129194729.GC4209@fieldses.org>
 <51084167.8060802@connotech.com>
 <51084428.6080302@connotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51084428.6080302@connotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29, 2013 at 04:50:32PM -0500, Thierry Moreau wrote:
> Oh, I got the kernel log for the very first occurrence of this
> symptom, this time with what-looks-like kernel symbols (BUG at
> 14:17:52):

So, probably something to do with having V4 and/or GSS compiled out,
since we don't test that configuration very often.

And we're oopsing on what's probably the first rpcauth_lookupcred, on
the first rpc call of any kind (to register the server.

But it's not immediately obvious to me why this is oopsing; probably
need to try that myself.

--b.

> 
> - Thierry
> 
> Jan 29 14:06:04 host----name kernel: Adding 1542204k swap on
> /dev/sda7.  Priority:62 extents:1 across:1542204k
> Jan 29 14:06:04 host----name kernel: NET: Registered protocol family 10
> Jan 29 14:17:52 host----name kernel: RPC: Registered named UNIX
> socket transport module.
> Jan 29 14:17:52 host----name kernel: RPC: Registered udp transport module.
> Jan 29 14:17:52 host----name kernel: RPC: Registered tcp transport module.
> Jan 29 14:17:52 host----name kernel: RPC: Registered tcp NFSv4.1
> backchannel transport module.
> Jan 29 14:17:52 host----name kernel: Installing knfsd (copyright (C)
> 1996 okir@monad.swb.de).
> Jan 29 14:17:52 host----name kernel: BUG: unable to handle kernel
> paging request at 01ffffff
> Jan 29 14:17:52 host----name kernel: IP: [<cef30068>]
> rpcauth_lookupcred+0x30/0x66 [sunrpc]
> Jan 29 14:17:52 host----name kernel: *pde = 00000000
> Jan 29 14:17:52 host----name kernel: Oops: 0002 [#1] SMP
> Jan 29 14:17:52 host----name kernel: Modules linked in: nfsd
> exportfs lockd sunrpc ipv6 dm_mod snd_via82xx snd_mpu401_uart
> snd_rawmidi snd_ac97_codec ac97_bus snd_pcm snd_page_alloc 8250_pnp
> snd_timer snd soundcore ehci_hcd uhci_hcd sr_mod usbcore usb_common
> cdrom floppy 8250 parport_pc serial_core parport via_rhine via_agp
> agpgart
> Jan 29 14:17:52 host----name kernel:
> Jan 29 14:17:52 host----name kernel: Pid: 6769, comm: rpc.nfsd Not
> tainted 3.5.4 #3 PCCHIPS P25G/P4M800-8237
> Jan 29 14:17:52 host----name kernel: EIP: 0060:[<cef30068>] EFLAGS:
> 00010246 CPU: 0
> Jan 29 14:17:52 host----name kernel: EIP is at
> rpcauth_lookupcred+0x30/0x66 [sunrpc]
> Jan 29 14:17:52 host----name kernel: EAX: 01ffffff EBX: ccce3a80
> ECX: 00000000 EDX: 00000000
> Jan 29 14:17:53 host----name kernel: ESI: ccce3c00 EDI: cc261dc8
> EBP: cef3e204 ESP: cc261db4
> Jan 29 14:17:53 host----name kernel:  DS: 007b ES: 007b FS: 00d8 GS:
> 0033 SS: 0068
> Jan 29 14:17:53 host----name kernel: CR0: 8005003b CR2: 01ffffff
> CR3: 0c258000 CR4: 00000790
> Jan 29 14:17:53 host----name kernel: DR0: 00000000 DR1: 00000000
> DR2: 00000000 DR3: 00000000
> Jan 29 14:17:53 host----name kernel: DR6: ffff0ff0 DR7: 00000400
> Jan 29 14:17:53 host----name kernel: Process rpc.nfsd (pid: 6769,
> ti=cc260000 task=cdb95440 task.ti=cc260000)
> Jan 29 14:17:53 host----name kernel: Stack:
> Jan 29 14:17:53 host----name kernel:  00000000 00000000 00000000
> 00000000 00000000 ccce3a80 ccce3a80 00000000
> Jan 29 14:17:53 host----name kernel:  cdaeab00 cef301a6 cef2c068
> ccce3a80 cef2c7f3 cdb7ba64 00000000 ccce3ab8
> Jan 29 14:17:53 host----name kernel:  ccce3a80 00000000 cdaaa000
> cef2f5e7 ccce3ab8 c102c9af ccce3a80 cc261e2c
> Jan 29 14:17:53 host----name kernel: Call Trace:
> Jan 29 14:17:53 host----name kernel:  [<cef301a6>] ?
> rpcauth_refreshcred+0x5a/0x95 [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef2c068>] ?
> xprt_release_xprt+0x31/0x3f [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef2c7f3>] ?
> xprt_reserve+0x184/0x1ad [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef2f5e7>] ?
> __rpc_execute+0x34/0x158 [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<c102c9af>] ? wake_up_bit+0xb/0x16
> Jan 29 14:17:53 host----name kernel:  [<cef2b2f8>] ?
> rpc_run_task+0x57/0x5c [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef2b3d9>] ?
> rpc_call_sync+0x39/0x54 [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef34b41>] ?
> rpcb_register_call+0x11/0x20 [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef34edd>] ?
> rpcb_v4_register+0x82/0xed [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef31431>] ?
> svc_unregister.isra.15+0x3c/0x98 [sunrpc]
> Jan 29 14:17:53 host----name kernel:  [<cef91c7d>] ?
> write_filehandle+0x14b/0x14b [nfsd]
> Jan 29 14:17:53 host----name kernel:  [<cef314bc>] ?
> svc_rpcb_setup+0x1f/0x25 [sunrpc]
> Jan 29 14:17:54 host----name kernel:  [<cef91302>] ?
> nfsd_create_serv+0xba/0x10a [nfsd]
> Jan 29 14:17:54 host----name kernel:  [<c10eb6a0>] ?
> simple_strtoull+0x23/0x3f
> Jan 29 14:17:54 host----name kernel:  [<cef91d2d>] ?
> export_features_show+0x18/0x18 [nfsd]
> Jan 29 14:17:54 host----name kernel:  [<cef91dc6>] ?
> write_ports+0x99/0x2be [nfsd]
> Jan 29 14:17:54 host----name kernel:  [<c11499d8>] ?
> get_random_bytes+0x12/0x15
> Jan 29 14:17:54 host----name kernel:  [<c11eecf3>] ?
> _raw_write_lock_bh+0x9/0x1c
> Jan 29 14:17:54 host----name kernel:  [<c108d955>] ?
> simple_transaction_get+0x66/0x80
> Jan 29 14:17:54 host----name kernel:  [<cef91d2d>] ?
> export_features_show+0x18/0x18 [nfsd]
> Jan 29 14:17:54 host----name kernel:  [<cef91cb4>] ?
> nfsctl_transaction_write+0x37/0x51 [nfsd]
> Jan 29 14:17:54 host----name kernel:  [<c1076e7c>] ? vfs_write+0x7b/0xf3
> Jan 29 14:17:54 host----name kernel:  [<c1077081>] ? sys_write+0x38/0x65
> Jan 29 14:17:54 host----name kernel:  [<c11ef6d0>] ?
> sysenter_do_call+0x12/0x26
> Jan 29 14:17:54 host----name kernel: Code: 00 57 89 c5 56 53 83 ec
> 14 64 a1 b8 45 31 c1 89 e7 8b b0 c4 01 00 00 31 c0 f3 ab 8b 46 1c 89
> 04 24 8b 46 20 89 44 24 04 8b 46 60 <3e> ff 00 8b 75 10 89 d1 89 e2
> 89 44 24 08 89 e8 ff 56 14 8b 54
> Jan 29 14:17:54 host----name kernel: EIP: [<cef30068>]
> rpcauth_lookupcred+0x30/0x66 [sunrpc] SS:ESP 0068:cc261db4
> Jan 29 14:17:54 host----name kernel: CR2: 0000000001ffffff
> Jan 29 14:17:54 host----name kernel: ---[ end trace 7dad9f92a03954c6 ]---
> 
> 
> 
> --- end of message ---
