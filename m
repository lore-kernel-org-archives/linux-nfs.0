Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:44986 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222Ab2DESzM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 14:55:12 -0400
MIME-Version: 1.0
Date: Thu, 5 Apr 2012 20:55:11 +0200
Message-ID: <CAPVoSvQ8M=VUjNCwd5=0ax9O1FOFruP33FcN-_NNPeE68J0FaQ@mail.gmail.com>
Subject: 3.4-rc1:NFS Oops in nfs_clear_request_commit
From: Torsten Kaiser <just.for.lkml@googlemail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While using wget to download a 100MB+ file onto a nfs share I got the
following Oops:

Apr  5 19:53:59 thoregon kernel: [ 1726.918412] BUG: unable to handle
kernel NULL pointer dereference at 0000000000000048
Apr  5 19:53:59 thoregon kernel: [ 1726.918455] IP:
[<ffffffff81151821>] nfs_clear_request_commit+0x11/0x90
Apr  5 19:53:59 thoregon kernel: [ 1726.918489] PGD 1e6300067 PUD
21175c067 PMD 0
Apr  5 19:53:59 thoregon kernel: [ 1726.918511] Oops: 0000 [#1] SMP
Apr  5 19:53:59 thoregon kernel: [ 1726.918527] CPU 5
Apr  5 19:53:59 thoregon kernel: [ 1726.918536] Modules linked in: fuse
Apr  5 19:53:59 thoregon kernel: [ 1726.918554]
Apr  5 19:53:59 thoregon kernel: [ 1726.918562] Pid: 11486, comm: wget
Not tainted 3.4.0-rc1 #1 MSI MS-7640/890FXA-GD70 (MS-7640)
Apr  5 19:53:59 thoregon kernel: [ 1726.918600] RIP:
0010:[<ffffffff81151821>]  [<ffffffff81151821>]
nfs_clear_request_commit+0x11/0x90
Apr  5 19:53:59 thoregon kernel: [ 1726.918639] RSP:
0018:ffff8801e546fb08  EFLAGS: 00010292
Apr  5 19:53:59 thoregon kernel: [ 1726.918660] RAX: 0000000000000000
RBX: 0000000000000000 RCX: 0000000180200000
Apr  5 19:53:59 thoregon kernel: [ 1726.918689] RDX: 4000000000000029
RSI: 0000000000000001 RDI: 0000000000000000
Apr  5 19:53:59 thoregon kernel: [ 1726.918717] RBP: 000000000000078c
R08: 0000000000000000 R09: ffffffff81152d68
Apr  5 19:53:59 thoregon kernel: [ 1726.918745] R10: ffffffff8114d54a
R11: 0000000000000000 R12: ffff8802312c73a8
Apr  5 19:53:59 thoregon kernel: [ 1726.918774] R13: 0000000000000874
R14: ffff8803291a2580 R15: 0000000000000000
Apr  5 19:53:59 thoregon kernel: [ 1726.918803] FS:
00007f7b3a65d720(0000) GS:ffff880337d40000(0000)
knlGS:0000000000000000
Apr  5 19:53:59 thoregon kernel: [ 1726.918835] CS:  0010 DS: 0000 ES:
0000 CR0: 0000000080050033
Apr  5 19:53:59 thoregon kernel: [ 1726.918858] CR2: 0000000000000048
CR3: 000000021e3c0000 CR4: 00000000000007e0
Apr  5 19:53:59 thoregon kernel: [ 1726.918887] DR0: 0000000000000000
DR1: 0000000000000000 DR2: 0000000000000000
Apr  5 19:53:59 thoregon kernel: [ 1726.918915] DR3: 0000000000000000
DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr  5 19:53:59 thoregon kernel: [ 1726.918944] Process wget (pid:
11486, threadinfo ffff8801e546e000, task ffff8801d2decac0)
Apr  5 19:53:59 thoregon kernel: [ 1726.918976] Stack:
Apr  5 19:53:59 thoregon kernel: [ 1726.918985]  000000000000078c
ffffea0006d484c0 000000000000078c ffffffff81152d98
Apr  5 19:53:59 thoregon kernel: [ 1726.919020]  ffff8802312c74e0
ffffffff00000000 ffff8802312c7420 0000100006d484c0
Apr  5 19:53:59 thoregon kernel: [ 1726.919053]  ffff8803291a2580
ffff880235f43c00 0000000000000874 ffffea0006d484c0
Apr  5 19:53:59 thoregon kernel: [ 1726.919086] Call Trace:
Apr  5 19:53:59 thoregon kernel: [ 1726.919099]  [<ffffffff81152d98>]
? nfs_updatepage+0x1e8/0x3d0
Apr  5 19:53:59 thoregon kernel: [ 1726.919124]  [<ffffffff811445c9>]
? nfs_write_end+0x129/0x250
Apr  5 19:53:59 thoregon kernel: [ 1726.919149]  [<ffffffff8108e46b>]
? generic_file_buffered_write+0x19b/0x2c0
Apr  5 19:53:59 thoregon kernel: [ 1726.919179]  [<ffffffff8108ffb1>]
? __generic_file_aio_write+0x211/0x410
Apr  5 19:53:59 thoregon kernel: [ 1726.919207]  [<ffffffff81090226>]
? generic_file_aio_write+0x76/0xf0
Apr  5 19:53:59 thoregon kernel: [ 1726.919233]  [<ffffffff8114439b>]
? nfs_file_write+0x7b/0x180
Apr  5 19:53:59 thoregon kernel: [ 1726.919258]  [<ffffffff810cf4df>]
? do_sync_write+0xbf/0x100
Apr  5 19:53:59 thoregon kernel: [ 1726.919282]  [<ffffffff810cfd16>]
? vfs_write+0xc6/0x170
Apr  5 19:53:59 thoregon kernel: [ 1726.919304]  [<ffffffff810cfffe>]
? sys_write+0x4e/0x90
Apr  5 19:53:59 thoregon kernel: [ 1726.919328]  [<ffffffff815f7822>]
? system_call_fastpath+0x16/0x1b
Apr  5 19:53:59 thoregon kernel: [ 1726.919352] Code: 00 00 e8 f3 4d
11 00 53 9d 5b c3 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 83
ec 18 48 89 5c 24 08 48 89 6c 24 10 48 89 fb <48> 8b 47 48 a8 04 74 47
48 8b 47 18 48 8b 40 30 48 8b 68 30 48
Apr  5 19:53:59 thoregon kernel: [ 1726.919494] RIP
[<ffffffff81151821>] nfs_clear_request_commit+0x11/0x90
Apr  5 19:53:59 thoregon kernel: [ 1726.919522]  RSP <ffff8801e546fb08>
Apr  5 19:53:59 thoregon kernel: [ 1726.919537] CR2: 0000000000000048
Apr  5 19:53:59 thoregon kernel: [ 1726.940636] ---[ end trace
0e47a071a9891fab ]---

Otherwise 3.4-rc1 works fine for me. And other big downloads before
and after that worked fine.

(gdb) list *0xffffffff81151821
0xffffffff81151821 is in nfs_clear_request_commit
(/usr/src/linux-3.4-rc1/arch/x86/include/asm/bitops.h:312).
307     }
308
309     static __always_inline int constant_test_bit(unsigned int nr,
const volatile unsigned long *addr)
310     {
311             return ((1UL << (nr % BITS_PER_LONG)) &
312                     (addr[nr / BITS_PER_LONG])) != 0;
313     }
314
315     static inline int variable_test_bit(int nr, volatile const
unsigned long *addr)
316     {
(gdb) list *0xffffffff81152d98
0xffffffff81152d98 is in nfs_updatepage (fs/nfs/write.c:685).
680                     req->wb_bytes = end - req->wb_offset;
681             else
682                     req->wb_bytes = rqend - req->wb_offset;
683     out_unlock:
684             spin_unlock(&inode->i_lock);
685             nfs_clear_request_commit(req);
686             return req;
687     out_flushme:
688             spin_unlock(&inode->i_lock);
689             nfs_release_request(req);

Thanks for looking into this.

Torsten
