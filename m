Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48586 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbeDGCnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Apr 2018 22:43:25 -0400
Date: Fri, 6 Apr 2018 22:43:25 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: lock debugging warning in nfs_async_unlink_release
Message-ID: <20180407024325.GC5306@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is this something you already know about?

--b.

DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct *)1UL))
WARNING: CPU: 1 PID: 1418 at kernel/locking/rwsem.c:217 up_read_non_owner+0x58/0x60
Modules linked in: rpcsec_gss_krb5 nfsv4 nfs nfsd auth_rpcgss nfs_acl lockd grace sunrpc
CPU: 1 PID: 1418 Comm: kworker/1:2 Not tainted 4.16.0-09576-g38c23685b273 #1706
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-2.fc27 04/01/2014
Workqueue: nfsiod rpc_async_release [sunrpc]
RIP: 0010:up_read_non_owner+0x58/0x60
RSP: 0018:ffffc900019efe20 EFLAGS: 00010282
RAX: 000000000000003e RBX: ffff880221246338 RCX: 0000000000000001
RDX: 0000000080000001 RSI: 0000000000000001 RDI: 00000000ffffffff
RBP: ffff8802319a9000 R08: 0000000000000000 R09: ffffffff810ee1c9
R10: ffffc900019efe00 R11: 0000000000000000 R12: ffff880230515000
R13: ffff880232badb40 R14: 0000000000000000 R15: ffff88023fd1fec0
FS:  0000000000000000(0000) GS:ffff88023fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ffd79b9290c CR3: 0000000235fb8000 CR4: 00000000000406e0
Call Trace:
nfs_async_unlink_release+0x2d/0x80 [nfs]
rpc_free_task+0x2d/0x70 [sunrpc]
process_one_work+0x1e8/0x650
worker_thread+0x3a/0x390
? process_one_work+0x650/0x650
kthread+0x11e/0x140
? kthread_create_on_node+0x40/0x40
ret_from_fork+0x3a/0x50
Code: ff b3 00 5b c3 e8 39 67 60 00 85 c0 74 df 8b 05 97 87 bd 02 85 c0 75 d5 48 c7 c6 b8 cc 4f 82 48 c7 c7 1b c4 4e 82 e8 98 be fa ff <0f> 0b eb be 0f 1f 40 00 66 66 66 66 90 53 48 8b
74 24 08 48 89 

