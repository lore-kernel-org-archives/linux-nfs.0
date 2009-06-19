From: Simon Kirby <sim@hostway.ca>
Subject: kernel NULL pointer dereference in rpcb_getport_done (2.6.29.4)
Date: Fri, 19 Jun 2009 15:54:37 -0700
Message-ID: <20090619225437.GA8472@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:55833 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751797AbZFSWyj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2009 18:54:39 -0400
Received: from sim by peace.netnation.com with local (Exim 4.63)
	(envelope-from <sim@netnation.com>)
	id 1MHmyj-0004jN-Va
	for linux-nfs@vger.kernel.org; Fri, 19 Jun 2009 15:54:37 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

'lo!

On a few different boxes with heavy NFSv3 serving (and quite a bit of
file locking), I am seeing the following Oops regularly recurring
(2.6.28.10 and 2.6.29.4):

BUG: unable to handle kernel NULL pointer dereference at 0000000000000032
IP: [<ffffffff8068499c>] rpcb_getport_done+0x4c/0xd0
PGD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/block/dm-47/removable
CPU 6 
Modules linked in: drbd cn aoe xt_MARK bnx2 zlib_inflate e1000e
Pid: 1471, comm: rpciod/6 Not tainted 2.6.29.4-hw #2 PowerEdge 1950
RIP: 0010:[<ffffffff8068499c>]  [<ffffffff8068499c>] rpcb_getport_done+0x4c/0xd0
RSP: 0018:ffff88043d8ddde0  EFLAGS: 00010282
RAX: 0000000000000012 RBX: ffff880309c80780 RCX: ffff88043de65930
RDX: 0000000000009554 RSI: 0000000000009554 RDI: ffff880309c80780
RBP: ffff88043d8dde00 R08: ffff880309c80d14 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff880309c80d00 R14: ffff880167591400 R15: ffff880167591490
FS:  0000000000000000(0000) GS:ffff88043efa9500(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000032 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process rpciod/6 (pid: 1471, threadinfo ffff88043d8dc000, task ffff88043d8d1db0)
Stack:
 ffff880167591400 ffff880167591400 0000000000000000 0000000000000001
 ffff88043d8dde20 ffffffff8067ce97 0000000000000001 ffff8801675914b0
 ffff88043d8dde60 ffffffff8067d487 ffff88043d8dde40 ffff8801675914b0
Call Trace:
 [<ffffffff8067ce97>] rpc_exit_task+0x27/0x60
 [<ffffffff8067d487>] __rpc_execute+0x87/0x2d0
 [<ffffffff8067d6d0>] ? rpc_async_schedule+0x0/0x20
 [<ffffffff8067d6e0>] rpc_async_schedule+0x10/0x20
 [<ffffffff80252100>] run_workqueue+0xa0/0x150
 [<ffffffff80252cb3>] worker_thread+0x93/0xd0
 [<ffffffff80256370>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff80252c20>] ? worker_thread+0x0/0xd0
 [<ffffffff80255efd>] kthread+0x4d/0x80
 [<ffffffff8020d61a>] child_rip+0xa/0x20
 [<ffffffff80255eb0>] ? kthread+0x0/0x80
 [<ffffffff8020d610>] ? child_rip+0x0/0x20
Code: 44 8b 67 30 48 8b 1e 41 83 fc fb 74 32 41 83 fc a3 74 2f 45 85 e4 78 30 8b 56 14 66 85 d2 90 74 55 48 8b 43 08 0f b7 f2 48 89 df <ff> 50 20 f0 0f ba ab e0 03 00 00 04 19 c0 45 31 e4 eb 16 90 41 
RIP  [<ffffffff8068499c>] rpcb_getport_done+0x4c/0xd0
 RSP <ffff88043d8ddde0>
CR2: 0000000000000032
---[ end trace 209472a1a8b9753c ]---

After this occurs, a lot of "lockd: server x not responding, timed out"
messages start occurring for almost all of the clients, and locking
becomes lossy (it works, eventually), until the NFS server is rebooted.

The backtrace is always the same and always in rpcb_getport_done().

(gdb) disassemble rpcb_getport_done
Dump of assembler code for function rpcb_getport_done:
00e0 <rpcb_getport_done+0>:       push   %rbp
00e1 <rpcb_getport_done+1>:       mov    %rsp,%rbp
00e4 <rpcb_getport_done+4>:       sub    $0x20,%rsp
00e8 <rpcb_getport_done+8>:       mov    %r13,0x10(%rsp)
00ed <rpcb_getport_done+13>:      mov    %r14,0x18(%rsp)
00f2 <rpcb_getport_done+18>:      mov    %rsi,%r13
00f5 <rpcb_getport_done+21>:      mov    %rbx,(%rsp)
00f9 <rpcb_getport_done+25>:      mov    %r12,0x8(%rsp)
00fe <rpcb_getport_done+30>:      mov    %rdi,%r14
0101 <rpcb_getport_done+33>:      mov    0x30(%rdi),%r12d
0105 <rpcb_getport_done+37>:      mov    (%rsi),%rbx
0108 <rpcb_getport_done+40>:      cmp    $0xfffffffffffffffb,%r12d
010c <rpcb_getport_done+44>:      je     0x140 <rpcb_getport_done+96>
010e <rpcb_getport_done+46>:      cmp    $0xffffffffffffffa3,%r12d
0112 <rpcb_getport_done+50>:      je     0x143 <rpcb_getport_done+99>
0114 <rpcb_getport_done+52>:      test   %r12d,%r12d
0117 <rpcb_getport_done+55>:      js     0x149 <rpcb_getport_done+105>
0119 <rpcb_getport_done+57>:      mov    0x14(%rsi),%edx
011c <rpcb_getport_done+60>:      test   %dx,%dx
011f <rpcb_getport_done+63>:      nop    
0120 <rpcb_getport_done+64>:      je     0x177 <rpcb_getport_done+151>
0122 <rpcb_getport_done+66>:      mov    0x8(%rbx),%rax
0126 <rpcb_getport_done+70>:      movzwl %dx,%esi
0129 <rpcb_getport_done+73>:      mov    %rbx,%rdi
012c <rpcb_getport_done+76>:      callq  *0x20(%rax) <================
012f <rpcb_getport_done+79>:      lock btsl $0x4,0x3e0(%rbx)
0138 <rpcb_getport_done+88>:      sbb    %eax,%eax
013a <rpcb_getport_done+90>:      xor    %r12d,%r12d
013d <rpcb_getport_done+93>:      jmp    0x155 <rpcb_getport_done+117>
013f <rpcb_getport_done+95>:      nop    
0140 <rpcb_getport_done+96>:      mov    $0xa3,%r12b
0143 <rpcb_getport_done+99>:      incl   0x3ec(%rbx)
0149 <rpcb_getport_done+105>:     mov    0x8(%rbx),%rax
014d <rpcb_getport_done+109>:     xor    %esi,%esi
014f <rpcb_getport_done+111>:     mov    %rbx,%rdi
0152 <rpcb_getport_done+114>:     callq  *0x20(%rax)
...

>From my crappy assembler reading, this looks like this code:

		/* Succeeded */
		xprt->ops->set_port(xprt, map->r_port);

RAX is 0x12, and 0x12 + 0x20 is the fault address of 0x32, so it looks
like xprt or ops is NULL.  0x20 is the offset of set_port in xprt->ops.

Looks like there is some sort of race here...? :)

Simon-
