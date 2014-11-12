Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:40517 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbaKLQUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 11:20:00 -0500
Received: by mail-qc0-f169.google.com with SMTP id i17so9654519qcy.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 08:19:57 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 12 Nov 2014 11:19:55 -0500
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: BUG: [<ffffffffa01dac02>] nfsd4_proc_compound+0x432/0x6c0 [nfsd]
Message-ID: <20141112111955.7e2d3dd9@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I've seen the following crash happen on a couple of different kernels
recently. This one is from an older kernel that I just happened to be
testing some other code on, but I've seen the same oops as well on
v3.17.2 kernel from the fedora repos:

[  891.382557] BUG: unable to handle kernel paging request at ffffffffa026b848
[  891.383474] IP: [<ffffffffa01dac02>] nfsd4_proc_compound+0x432/0x6c0 [nfsd]
[  891.383474] PGD 1c0f067 PUD 1c10063 PMD da7ec067 PTE 0
[  891.383474] Oops: 0000 [#1] SMP 
[  891.383474] Modules linked in: rpcsec_gss_krb5 microcode pvpanic virtio_net virtio_balloon nfsd auth_rpcgss nfs_acl lockd sunrpc ext4 mbcache jbd2 qxl drm_kms_helper ttm drm virtio_blk i2c_core
[  891.383474] CPU: 1 PID: 653 Comm: nfsd Not tainted 3.14.15-.ds.1+ #5
[  891.383474] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  891.383474] task: ffff8800d1aa0000 ti: ffff8800d1a9c000 task.ti: ffff8800d1a9c000
[  891.383474] RIP: 0010:[<ffffffffa01dac02>]  [<ffffffffa01dac02>] nfsd4_proc_compound+0x432/0x6c0 [nfsd]
[  891.383474] RSP: 0018:ffff8800d1a9dda8  EFLAGS: 00010202
[  891.383474] RAX: 0000000000075b40 RBX: ffff880118f47000 RCX: ffff880118f46080
[  891.383474] RDX: 0000000000000006 RSI: ffff880118f46000 RDI: 0000000000000003
[  891.383474] RBP: ffff8800d1a9ddf0 R08: ffffffffa01f6120 R09: 0000000000000000
[  891.383474] R10: 0000000000000400 R11: ffff880118f46220 R12: ffff880118fc4000
[  891.383474] R13: ffff880118f47040 R14: ffff880118f46000 R15: 0000000000000080
[  891.383474] FS:  0000000000000000(0000) GS:ffff88011fc80000(0000) knlGS:0000000000000000
[  891.383474] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  891.383474] CR2: ffffffffa026b848 CR3: 0000000118d01000 CR4: 00000000000006e0
[  891.383474] Stack:
[  891.383474]  ffff880118f46220 ffffffffa01f6120 ffff880118f46220 ffff880118f47180
[  891.383474]  ffff880118fc4000 ffffffffa01fe6b8 ffff8800d1ace018 000000000000001c
[  891.383474]  ffff8800d1ace000 ffff8800d1a9de28 ffffffffa01c7e1b ffff880118fc4000
[  891.383474] Call Trace:
[  891.383474]  [<ffffffffa01c7e1b>] nfsd_dispatch+0xbb/0x210 [nfsd]
[  891.383474]  [<ffffffffa017dbf1>] svc_process_common+0x421/0x690 [sunrpc]
[  891.383474]  [<ffffffffa01c76b0>] ? nfsd_destroy+0x80/0x80 [nfsd]
[  891.383474]  [<ffffffffa017df73>] svc_process+0x113/0x1a0 [sunrpc]
[  891.383474]  [<ffffffffa01c76b0>] ? nfsd_destroy+0x80/0x80 [nfsd]
[  891.383474]  [<ffffffffa01c7777>] nfsd+0xc7/0x130 [nfsd]
[  891.383474]  [<ffffffff810a5bfb>] kthread+0xdb/0x100
[  891.383474]  [<ffffffff810a5b20>] ? insert_kthread_work+0x40/0x40
[  891.383474]  [<ffffffff8162857c>] ret_from_fork+0x7c/0xb0
[  891.383474]  [<ffffffff810a5b20>] ? insert_kthread_work+0x40/0x40
[  891.383474] Code: 5d 1f a0 10 0f 84 c6 fd ff ff 3b 46 6c 0f 84 bd fd ff ff 48 8d 14 40 48 8d 04 90 48 c1 e0 05 48 63 04 01 48 8d 04 40 48 c1 e0 04 <f6> 80 08 5d 1f a0 08 0f 85 98 fd ff ff 48 8b bb d0 00 00 00 4c 
[  891.383474] RIP  [<ffffffffa01dac02>] nfsd4_proc_compound+0x432/0x6c0 [nfsd]
[  891.383474]  RSP <ffff8800d1a9dda8>
[  891.383474] CR2: ffffffffa026b848
[  891.528734] ---[ end trace cb3422188344cc64 ]---

gdb says:

(gdb) list *(nfsd4_proc_compound+0x432)
0x13c32 is in nfsd4_proc_compound (fs/nfsd/nfs4proc.c:1376).
1371					opdesc->op_set_currentstateid(cstate, &op->u);
1372	
1373				if (opdesc->op_flags & OP_CLEAR_STATEID)
1374					clear_current_stateid(cstate);
1375	
1376				if (need_wrongsec_check(rqstp))
1377					op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
1378			}
1379	
1380	encode_op:

...and looking at the disassembly, it looks like it's falling down in
this line in need_wrongsec_check:

        return !(nextd->op_flags & OP_HANDLES_WRONGSEC);

0xffffffffa01dabea <nfsd4_proc_compound+0x41a>: lea    (%rax,%rax,2),%rdx
0xffffffffa01dabee <nfsd4_proc_compound+0x41e>: lea    (%rax,%rdx,4),%rax
0xffffffffa01dabf2 <nfsd4_proc_compound+0x422>: shl    $0x5,%rax
0xffffffffa01dabf6 <nfsd4_proc_compound+0x426>: movslq (%rcx,%rax,1),%rax
0xffffffffa01dabfa <nfsd4_proc_compound+0x42a>: lea    (%rax,%rax,2),%rax
0xffffffffa01dabfe <nfsd4_proc_compound+0x42e>: shl    $0x4,%rax
0xffffffffa01dac02 <nfsd4_proc_compound+0x432>: testb  $0x8,-0x5fe0a2f8(%rax)   <<<< CRASH HERE

I think that means that "nextd" was probably bogus, so maybe we walked
off the end of the argp->ops array? I haven't been able to reproduce it
at will yet, but both times it happened while using v4.1.


Seen anything like this before?

-- 
Jeff Layton <jlayton@primarydata.com>
