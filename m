Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48718 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524Ab2IRJuU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2012 05:50:20 -0400
Received: by pbbrr13 with SMTP id rr13so10728217pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 18 Sep 2012 02:50:20 -0700 (PDT)
MIME-Version: 1.0
From: William Dauchy <wdauchy@gmail.com>
Date: Tue, 18 Sep 2012 11:49:59 +0200
Message-ID: <CAJ75kXZuM_p3qknD4RgdjLLWd393u02S5FKQyu3Q8y8NwmfiVw@mail.gmail.com>
Subject: unhandled error -10026
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: R.Eggermont@tudelft.nl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm getting a trace following an unhandled error on a linux nfs client
3.4.7 x86_64.

Any hint?

NFS: nfs4_reclaim_open_state: unhandled error -10026. Zeroing state
------------[ cut here ]------------
kernel BUG at net/sunrpc/sched.c:699!
invalid opcode: 0000 [#1] PREEMPT SMP
CPU 19
Pid: 17671, comm: kworker/19:12 Not tainted 3.4.7         /0D61XP
RIP: 0010:[<ffffffff81444ea9>]  [<ffffffff81444ea9>] __rpc_execute+0x1a9/0x1b0
RSP: 0018:ffff880bb8913db0  EFLAGS: 00010202
RAX: 0000000000000007 RBX: ffff880bec6e2080 RCX: ffff880c3fcec188
RDX: ffff880c3fcec188 RSI: 0000000000000000 RDI: ffff880bec6e2080
RBP: ffff880bec6e20f0 R08: ffff880bb64bd4c0 R09: 0000000000029440
R10: 0000000000000000 R11: 000000000000000c R12: 0000000000000001
R13: ffff880c3fcf1305 R14: 0000000000000000 R15: ffff880bec6e2108
FS:  0000000000000000(0000) GS:ffff880c3fce0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000078080280000 CR3: 000000000149d000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/19:12 (pid: 17671, threadinfo ffff880bb64bd4c0, task
ffff880bb64bd070)
Stack:
000000000000df00 ffff880bb64bd4c0 ffff880bb64bd4c8 ffff880bb64bd070
ffff880c3fcec180 ffff880c3fcf1300 ffff880c3fcf1305 ffffffff81444efd
ffff8803e327df00 ffffffff810503b8 000000000000df00 ffffffff81444ee0
Call Trace:
[<ffffffff81444efd>] ? rpc_async_schedule+0x1d/0x30
[<ffffffff810503b8>] ? process_one_work+0x108/0x3a0
[<ffffffff81444ee0>] ? rpc_execute+0x30/0x30
[<ffffffff81050aa1>] ? worker_thread+0x151/0x420
[<ffffffff81050950>] ? rescuer_thread+0x300/0x300
[<ffffffff81050950>] ? rescuer_thread+0x300/0x300
[<ffffffff81054ebe>] ? kthread+0x9e/0xb0
[<ffffffff8147bbb4>] ? kernel_thread_helper+0x4/0x10
[<ffffffff81479e78>] ? retint_restore_args+0x6/0x6
[<ffffffff81054e20>] ? kthread_freezable_should_stop+0x60/0x60
[<ffffffff8147bbb0>] ? gs_change+0xb/0xb
Code: e8 3d fe ff ff eb dd f0 ff 0b 71 05 f0 ff 03 cd 04 0f 94 c0 84
c0 0f 85 7b ff ff ff 48 83 c4 18 5b 5d 41 5c 41 5d c3 0f 0b eb fe <0f>
0b eb fe 0f 1f 00 53 48 89 fb f0 80 4f 70 04 e8 72 f7 ff ff
RIP  [<ffffffff81444ea9>] __rpc_execute+0x1a9/0x1b0
RSP <ffff880bb8913db0>
---[ end trace 27110931730a34ea ]---

-- 
William
