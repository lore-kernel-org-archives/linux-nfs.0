Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37972 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589Ab2ITO2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Sep 2012 10:28:07 -0400
Received: by pbbrr4 with SMTP id rr4so325439pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Sep 2012 07:28:07 -0700 (PDT)
MIME-Version: 1.0
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 20 Sep 2012 16:27:46 +0200
Message-ID: <CAJ75kXapMH7daNwgcW18t+OjYkgQehHTzKZ0xZAy9pKfAP2G8Q@mail.gmail.com>
Subject: wait_for_key_construction oops
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm still hitting a kernel NULL dereference on
wait_for_key_construction with a 3.4.7 x86_64 kernel.
My build also includes those NFS patches:

a427b9e # NFS: Fix a number of bugs in the idmapper
c506694 # NFS: Clear key construction data if the idmap upcall fails
12dfd08 # NFS: return -ENOKEY when the upcall fails to map the name
5cf02d0 # nfs: skip commit in releasepage if we're freeing memory for
fs-related reasons
caea33d # SUNRPC: return negative value in case rpcbind client creation error
cac5d07 # sunrpc: clnt: Add missing braces
0866004 # NFSv3: Ensure that do_proc_get_root() reports errors correctly

Since I'm not able to reproduce it easily, I don't know exactly when
it's happening.
Any idea? or maybe am I missing some other patches?
I'm using the old nfs userland.

Regards,

BUG: unable to handle kernel NULL pointer dereference at 0000000000000070
IP: [<ffffffff811a5248>] wait_for_key_construction+0x28/0x70
PGD 313892000
Oops: 0000 [#1] PREEMPT SMP
CPU 20
Pid: 23261, comm: kworker/20:12 Tainted: G        W    3.4.7
RIP: 0010:[<ffffffff811a5248>]  [<ffffffff811a5248>]
wait_for_key_construction+0x28/0x70
RSP: 0018:ffff88089e6e1a70  EFLAGS: 00010246
RAX: ffffffff811a52a0 RBX: 0000000000000000 RCX: 0000000000000002
RDX: ffffffff811a5290 RSI: 0000000000000000 RDI: 0000000000000070
RBP: ffff8804ac5d4800 R08: ffff880bf234c6c1 R09: 0000000000000000
R10: 00000000505a8526 R11: 0000000000000000 R12: ffffffff816abcd1
R13: ffff880887590a48 R14: 000000000000001b R15: ffff8804ac5d4803
FS:  0000000000000000(0000) GS:ffff880c3fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000070 CR3: 000000000149e000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/20:12 (pid: 23261, threadinfo ffff8808e9de7950, task
ffff8808e9de7500)
Stack:
0000000000000000 ffffffff811a595f 0000000000000000 ffffffff810df3cd
ffff8808e9de7500 0000000000000016 ffff88088cdc98c0 ffffffff816be7c0
ffff8804ac5d4800 ffffffff8118564b 000000000000001b ffffffff81935c40
Call Trace:
[<ffffffff811a595f>] ? request_key+0x5f/0xa0
[<ffffffff810df3cd>] ? __kmalloc+0x2d/0x120
[<ffffffff8118564b>] ? nfs_idmap_request_key+0x1ab/0x1c0
[<ffffffff811856b7>] ? nfs_idmap_get_key+0x57/0xe0
[<ffffffff8118594e>] ? nfs_map_string_to_numeric+0x3e/0xc0
[<ffffffff811859ff>] ? nfs_idmap_lookup_id+0x2f/0x80
[<ffffffff81185b19>] ? nfs_map_name_to_uid+0x39/0x90
[<ffffffff8117e56b>] ? decode_getfattr_attrs+0x94b/0xa10
[<ffffffff8117fe06>] ? T.1607+0x96/0xe0
[<ffffffff8117fee2>] ? nfs4_xdr_dec_delegreturn+0x72/0x80
[<ffffffff8105f160>] ? cpuacct_charge+0x20/0x70
[<ffffffff8117fe70>] ? decode_getfattr+0x20/0x20
[<ffffffff81445969>] ? rpcauth_unwrap_resp+0x79/0x80
[<ffffffff8117fe70>] ? decode_getfattr+0x20/0x20
[<ffffffff8143d7c3>] ? call_decode+0x2a3/0x400
[<ffffffff81444d46>] ? __rpc_execute+0x46/0x1b0
[<ffffffff81064a47>] ? try_to_wake_up+0x1d7/0x290
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
Code: 00 00 00 40 80 fe 01 53 19 c9 48 89 fb 48 c7 c0 a0 52 1a 81 f7
d1 48 c7 c2 90 52 1a 81 83 c1 02 48 8d 7f 70 40 84 f6 48 0f 45 d0 <48>
8b 43 70 a8 10 75 20 48 8b 43 70 a8 20 74 08 8b 83 80 00 00
RIP  [<ffffffff811a5248>] wait_for_key_construction+0x28/0x70
RSP <ffff88089e6e1a70>
CR2: 0000000000000070
---[ end trace c733770a2ba5b873 ]---

-- 
William
