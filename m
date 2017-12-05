Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:42165 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752611AbdLEQCg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 11:02:36 -0500
MIME-Version: 1.0
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 5 Dec 2017 17:02:35 +0100
Message-ID: <CAMuHMdWm8SGtekpdGVKsDi4L4sgvVZDFoC5wnSggVXFRt-irzA@mail.gmail.com>
Subject: NFS crash, hashed pointers in backtrace
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: "Tobin C. Harding" <me@tobin.cc>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During a failed write to a virtual sysfs file (root fs is NFS), I got:

Unable to handle kernel NULL pointer dereference at virtual address 00000020
pgd = c448bb15
[00000020] *pgd=69c9c003, *pmd=69d55003, *pte=00000000
Internal error: Oops: 207 [#1] SMP ARM
Modules linked in:
CPU: 0 PID: 1230 Comm: rs:main Q:Reg Not tainted
4.15.0-rc2-koelsch-01160-gd389a154c640caab-dirty #3752
Hardware name: Generic R-Car Gen2 (Flattened Device Tree)
task: 4a3bb6d2 task.stack: fd0c00bd
PC is at nfs_flush_incompatible+0x54/0xf8
LR is at _raw_spin_unlock+0x8/0x24
pc : [<c03bcf04>]    lr : [<c074543c>]    psr: 600c0013
sp : eab25e40  ip : 00000000  fp : eb9dc760
r10: ea4a1d94  r9 : 00000c20  r8 : eb9dc760
r7 : ea933840  r6 : eab24000  r5 : 00000000  r4 : 00000000
r3 : 00000000  r2 : ea933840  r1 : ea9d0900  r0 : e9d9fe40
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 30c5387d  Table: 6aa37440  DAC: fffffffd
Process rs:main Q:Reg (pid: 1230, stack limit = 0xab6fd568)
Stack: (0xeab25e40 to 0xeab26000)
5e40: 00000000 00000000 00000ab9 0000660a eaaaea00 c03b098c 00000000 00000000
5e60: eab25f10 ea4a1d94 00000167 00000547 eab24000 eab24000 c081536c c02a646c
5e80: 00000167 00000000 eab25ea0 eab25ea4 0660aab9 00000000 eaaaea00 00000ab9
5ea0: eb9dc760 c028662c 00000000 ea4a1c98 eab25f28 eaaaea00 e9c56000 eab25f10
5ec0: eab24000 00000000 b5a1c8d0 c03b0c74 00000001 00000001 0009a6f0 c02880f8
5ee0: ffffffff eaaaea00 00000002 00000000 eab25f88 00000167 eab24000 c02eb0e0
5f00: 00000167 00000000 b5a1c8d0 00000167 00000001 00000000 00000167 eab25f08
5f20: 00000001 40000002 eaaaea00 00000000 0660aab9 00000000 00000000 00000000
5f40: 00000002 00000000 00000167 eaaaea00 eab25f88 b5a1c8d0 c0207044 c02eb280
5f60: eaaaea00 b5a1c8d0 00000167 eaaaea00 eaaaea03 00000167 b5a1c8d0 c0207044
5f80: eab24000 c02eb400 0660aab9 00000000 00000167 00000167 00000000 b5a1c710
5fa0: 00000004 c0206e60 00000167 00000000 00000005 b5a1c8d0 00000167 0007d000
5fc0: 00000167 00000000 b5a1c710 00000004 b58fe91c 00069be4 000998a0 b5a1c8d0
5fe0: 00000000 b58fe4d0 b6f3c4e9 b6f3c4f0 800c0030 00000005 00000000 00000000
[<c03bcf04>] (nfs_flush_incompatible) from [<c03b098c>]
(nfs_write_begin+0x50/0x208)
[<c03b098c>] (nfs_write_begin) from [<c02a646c>]
(generic_perform_write+0xc0/0x1ac)
[<c02a646c>] (generic_perform_write) from [<c03b0c74>]
(nfs_file_write+0x130/0x254)
[<c03b0c74>] (nfs_file_write) from [<c02eb0e0>] (__vfs_write+0xf0/0x11c)
[<c02eb0e0>] (__vfs_write) from [<c02eb280>] (vfs_write+0xb8/0x144)
[<c02eb280>] (vfs_write) from [<c02eb400>] (SyS_write+0x40/0x80)
[<c02eb400>] (SyS_write) from [<c0206e60>] (ret_fast_syscall+0x0/0x4c)
Code: 13a04001 1a00000a e590300c e5971020 (e593c020)
---[ end trace 7dc43d92647b9bd9 ]---

Unfortunately, due to the%p hashing, I no longer know which values I
can trust...

Any clues? Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
