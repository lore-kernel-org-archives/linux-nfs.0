Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34676 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbdEDKtT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 06:49:19 -0400
Received: by mail-qk0-f181.google.com with SMTP id k74so7245053qke.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 May 2017 03:49:18 -0700 (PDT)
Message-ID: <1493894954.2783.1.camel@poochiereds.net>
Subject: Re: general protection fault: 0000 [#1] SMP
From: Jeff Layton <jlayton@poochiereds.net>
To: Paul Menzel <pmenzel@molgen.mpg.de>, linux-nfs@vger.kernel.org
Cc: it+linux-nfs@molgen.mpg.de,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 04 May 2017 06:49:14 -0400
In-Reply-To: <550186fd-f426-08a6-8b32-e2818717b06a@molgen.mpg.de>
References: <550186fd-f426-08a6-8b32-e2818717b06a@molgen.mpg.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-04 at 11:36 +0200, Paul Menzel wrote:
> Dear Linux folks,
> 
> 
> Rebooting a system running Linux 4.8.4 to Linux 4.9.25, the general 
> protection fault below showed up requiring another reboot of the system. 
> After that, the problem couldn’t be reproduced.
> 
> ```
> > [ 4110.000731] general protection fault: 0000 [#1] SMP
> > [ 4110.000748] Modules linked in: af_packet nfsv4 nfs xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack ip_tables 8021q garp mrp stp llc nfsd ixgbe 3w_9xxx auth_rpcgss oid_registry nfs_acl lockd grace sunrpc ipv6 autofs4 unix
> > [ 4110.000942] CPU: 4 PID: 3677 Comm: grep Not tainted 4.9.25.mx64.152 #1
> > [ 4110.000959] Hardware name: Dell Inc. PowerEdge R720/0X6H47, BIOS 2.0.19 08/29/2013
> > [ 4110.000981] task: ffff88080687b1c0 task.stack: ffffc9000ecfc000
> > [ 4110.000999] RIP: 0010:[<ffffffffa0229db1>]  [<ffffffffa0229db1>] nfs4_put_open_state+0x51/0xe0 [nfsv4]
> > [ 4110.001034] RSP: 0018:ffffc9000ecffaf0  EFLAGS: 00010246
> > [ 4110.001051] RAX: dead000000000200 RBX: ffff8807ee04e780 RCX: 0000000000000001
> > [ 4110.001071] RDX: dead000000000100 RSI: ffff88080b68c240 RDI: ffff8807ea17b638
> > [ 4110.001093] RBP: ffffc9000ecffb08 R08: 0000000000008000 R09: ffff8807ee04e780
> > [ 4110.001114] R10: 0000000000000000 R11: ffff8807eaf55240 R12: ffff88080b68c200
> > [ 4110.001135] R13: ffff8807ea17b5b8 R14: ffff88080b68c200 R15: ffff8807e9047380
> > [ 4110.001157] FS:  00007f7846809700(0000) GS:ffff88080f880000(0000) knlGS:0000000000000000
> > [ 4110.001181] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [ 4110.001198] CR2: 0000000000661000 CR3: 00000007e9df8000 CR4: 00000000000406e0
> > [ 4110.001462] Stack:
> > [ 4110.001711]  ffff880808b7f400 ffff8807e90ab000 ffff8807e90a0800 ffffc9000ecffb28
> > [ 4110.002229]  ffffffffa0216b99 ffff880808b7f400 ffff88080b68c200 ffffc9000ecffbe8
> > [ 4110.002747]  ffffffffa021d030 ffffc900024000c0 0000000000000000 ffff8807e90473f8
> > [ 4110.003261] Call Trace:
> > [ 4110.003613]  [<ffffffffa0216b99>] nfs4_opendata_put+0x59/0xb0 [nfsv4]
> > [ 4110.003873]  [<ffffffffa021d030>] nfs4_do_open.constprop.54+0x420/0x7a0 [nfsv4]
> > [ 4110.004372]  [<ffffffffa021d44e>] nfs4_atomic_open+0xe/0x20 [nfsv4]
> > [ 4110.004634]  [<ffffffffa022c4d0>] nfs4_file_open+0xf0/0x220 [nfsv4]
> > [ 4110.004896]  [<ffffffffa01e8967>] ? nfs_permission+0xe7/0x1b0 [nfs]
> > [ 4110.005158]  [<ffffffff81086094>] ? try_to_wake_up+0x184/0x390
> > [ 4110.005419]  [<ffffffffa022c3e0>] ? nfs4_try_mount+0x60/0x60 [nfsv4]
> > [ 4110.005679]  [<ffffffff8119534f>] do_dentry_open.isra.1+0x15f/0x2f0
> > [ 4110.005938]  [<ffffffff811962ee>] vfs_open+0x4e/0x70
> > [ 4110.006195]  [<ffffffff811a6687>] path_openat+0x557/0x12b0
> > [ 4110.006453]  [<ffffffff811a8591>] do_filp_open+0x81/0xe0
> > [ 4110.006712]  [<ffffffff8149b306>] ? tty_ldisc_deref+0x16/0x20
> > [ 4110.006971]  [<ffffffff811a75c1>] ? getname_flags+0x61/0x210
> > [ 4110.007229]  [<ffffffff811b580f>] ? __alloc_fd+0x3f/0x170
> > [ 4110.007487]  [<ffffffff811966e9>] do_sys_open+0x139/0x200
> > [ 4110.007744]  [<ffffffff811967e4>] SyS_openat+0x14/0x20
> > [ 4110.008003]  [<ffffffff81a972e0>] entry_SYSCALL_64_fastpath+0x13/0x94
> > [ 4110.008261] Code: 00 4c 8b 6f ac 49 8d 74 24 40 e8 8b 65 1b e1 85 c0 0f 84 86 00 00 00 49 8d bd 80 00 00 00 e8 07 d2 86 e1 48 8b 53 10 48 8b 43 18 <48> 89 42 08 48 89 10 48 b8 00 01 00 00 00 00 ad de 48 89 43 10 
> > [ 4110.009334] RIP  [<ffffffffa0229db1>] nfs4_put_open_state+0x51/0xe0 [nfsv4]
> > [ 4110.009606]  RSP <ffffc9000ecffaf0>
> > [ 4110.010444] ---[ end trace 321fb30dd41845f9 ]---```
> 
> Please find the full log attached.
> 

(FWIW, this is a client-side crash, but you cc'ed Bruce and I who are
the server maintainers)

This one doesn't look familiar to me.

It crashed while tearing down the opendata. On my machine that
instruction offset corresponds to one of the list_del calls in
nfs4_put_open_state. Your offset may be different. What you may want to
do is grab the debuginfo for that kernel (if it's stripped) and use gdb
to open nfsv4.ko and then do something like:

    gdb> list *(nfs4_put_open_state+0x51)

That should give you a listing around the exact spot of the crash.
Without a vmcore here though, you may be out of luck on really tracking
this down.

-- 
Jeff Layton <jlayton@poochiereds.net>
