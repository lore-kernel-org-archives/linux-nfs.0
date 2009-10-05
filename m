From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: 4.1 NULL dereference in 2.6.32-rc3
Date: Mon, 5 Oct 2009 19:07:36 -0400
Message-ID: <20091005230736.GB31874@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48013 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963AbZJEXHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2009 19:07:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After mounting and unmounting a 4.1 partition with client and server
both 2.6.32-rc3, I see the following NULL dereference on the client.

I think the only cache lookup there is in unix_gid_find().  Hm.
Maybe it's trying to defer a request without a defer method set?

Of course there's no point to the client's callback server doing this
upcall at all.

--b.

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<(null)>] (null)
*pde = 00000000 
Oops: 0000 [#1] PREEMPT 
last sysfs file: /sys/kernel/uevent_seqnum
Modules linked in:

Pid: 3108, comm: nfsv4.1-svc Tainted: G        W  (2.6.32-rc3 #144) 
EIP: 0060:[<00000000>] EFLAGS: 00010293 CPU: 0
EIP is at 0x0
EAX: c73edd7c EBX: c5d2f8e8 ECX: 00000000 EDX: 00000001
ESI: c5d2f8d8 EDI: 4aca7522 EBP: c71b1e80 ESP: c71b1e58
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process nfsv4.1-svc (pid: 3108, ti=c71b0000 task=c4800020 task.ti=c71b0000)
Stack:
 c176f01a c71b1e80 c176f695 c71b1e90 c73edd7c c1aca8a0 fffffff5 c73ed000
<0> c5d2f8d8 00000000 c71b1eb8 c1768dcf c71b1f30 00000fc4 c1aca7bc 00000246
<0> c17689e2 00000001 c1aca7bc 00000000 c17c0158 c1aca944 c73ed0c8 00000000
Call Trace:
 [<c176f01a>] ? cache_check+0xea/0x350
 [<c176f695>] ? sunrpc_cache_lookup+0x125/0x140
 [<c1768dcf>] ? svcauth_unix_accept+0x15f/0x2e0
 [<c17689e2>] ? svc_authenticate+0x142/0x1a0
 [<c17c0158>] ? sub_preempt_count+0x8/0x90
 [<c17689f7>] ? svc_authenticate+0x157/0x1a0
 [<c17bd877>] ? _spin_unlock_irq+0x27/0x50
 [<c1764cd3>] ? svc_process_common+0x3f3/0x630
 [<c1764fd2>] ? bc_svc_process+0xc2/0x100
 [<c1059d0b>] ? trace_hardirqs_on+0xb/0x10
 [<c1213487>] ? nfs41_callback_svc+0x87/0x120
 [<c1049c50>] ? autoremove_wake_function+0x0/0x50
 [<c1213400>] ? nfs41_callback_svc+0x0/0x120
 [<c10499a4>] ? kthread+0x74/0x80
 [<c1049930>] ? kthread+0x0/0x80
 [<c100363b>] ? kernel_thread_helper+0x7/0x10
Code:  Bad EIP value.
EIP: [<00000000>] 0x0 SS:ESP 0068:c71b1e58
CR2: 0000000000000000
---[ end trace 39933fa1a06d9d4b ]---
