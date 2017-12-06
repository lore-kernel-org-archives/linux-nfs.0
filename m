Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36305 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdLFObr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 09:31:47 -0500
MIME-Version: 1.0
In-Reply-To: <CAMuHMdWm8SGtekpdGVKsDi4L4sgvVZDFoC5wnSggVXFRt-irzA@mail.gmail.com>
References: <CAMuHMdWm8SGtekpdGVKsDi4L4sgvVZDFoC5wnSggVXFRt-irzA@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 6 Dec 2017 15:31:46 +0100
Message-ID: <CAMuHMdW00vUYmbvS=bvD+dAF4ge4yTLjE7gyso2Gk_tfqGrwXg@mail.gmail.com>
Subject: Re: NFS crash, hashed pointers in backtrace
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: "Tobin C. Harding" <me@tobin.cc>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond. Anna,

On Tue, Dec 5, 2017 at 5:02 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> During a failed write to a virtual sysfs file (root fs is NFS), I got:
>
> Unable to handle kernel NULL pointer dereference at virtual address 00000020
> pgd = c448bb15
> [00000020] *pgd=69c9c003, *pmd=69d55003, *pte=00000000
> Internal error: Oops: 207 [#1] SMP ARM
> Modules linked in:
> CPU: 0 PID: 1230 Comm: rs:main Q:Reg Not tainted
> 4.15.0-rc2-koelsch-01160-gd389a154c640caab-dirty #3752
> Hardware name: Generic R-Car Gen2 (Flattened Device Tree)
> task: 4a3bb6d2 task.stack: fd0c00bd
> PC is at nfs_flush_incompatible+0x54/0xf8

Got another nfsroot crash:

Unable to handle kernel NULL pointer dereference at virtual address 00000030
pgd = 329e8f6e
[00000030] *pgd=80000040004003, *pmd=00000000
Internal error: Oops: 206 [#1] SMP ARM
Modules linked in:
CPU: 0 PID: 101 Comm: kworker/u4:1 Not tainted
4.15.0-rc2-koelsch-01166-g047d7d3248e08fc7-dirty #3762
Hardware name: Generic R-Car Gen2 (Flattened Device Tree)
Workqueue: writeback wb_workfn (flush-0:15)
task: 8a5bf858 task.stack: e93c92bc
PC is at nfs_page_async_flush+0x110/0x244
LR is at 0x10
pc : [<c03bc648>]    lr : [<00000010>]    psr: 400f0013
sp : eaff9c98  ip : c0c5092b  fp : 00000005
r10: 00018e84  r9 : ebef92c0  r8 : eaff9d64
r7 : ea421a00  r6 : ebef92c0  r5 : ea999040  r4 : ea9b1a00
r3 : 00000000  r2 : 00000006  r1 : 00000000  r0 : 00000000
Flags: nZcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 30c5387d  Table: 69d65680  DAC: fffffffd
Process kworker/u4:1 (pid: 101, stack limit = 0xeaff8210)
Stack: (0xeaff9c98 to 0xeaffa000)
9c80:                                                       ebef92c0 eaff9d64
9ca0: eaff9e20 ea421afc 00000000 c03bc858 eaff9e20 00000000 ffffffff c02b11e8
9cc0: 00000000 ea8f4500 eb427328 00018e89 00000000 00000009 eaff9d0c 00000000
9ce0: c03bc830 eaff9d64 00000000 ffffffff 00000009 00000000 ebef8440 ebef45c0
9d00: ebf1abc0 ebef8860 ebef8420 ebef92c0 ebef5ce0 ebef7e80 ebef3cc0 eaff9d1c
9d20: eaff9d1c eb1d2d98 eb1d2d28 ea421a00 eb400700 ea421a00 eab89bc0 ea421afc
9d40: eaff9e20 ea421afc 00000002 ea421a50 eaff8000 c03bc94c c081590c c02483d8
9d60: eaa62140 00000001 ea421a00 c08157cc c08158e0 00000000 00000000 c08157bc
9d80: c081590c 00000000 eab89bc0 00000000 00001000 00000001 eaff9d9c ea999fc0
9da0: ea999fc0 00004000 00001000 00001000 00000000 c0745704 00000000 00000000
9dc0: ec09e250 eaff9e20 ea421afc eaff9e20 ea9c4c38 c02b2d48 00000086 ea421a00
9de0: ea421a00 c0310434 ea421a00 eaff9e20 00000000 ea421ab4 ea421a00 00001400
9e00: ea9c4c38 eaff9efc 00000002 c03109b8 ea9c4c64 00003fd0 ea98b800 00000000
9e20: 000013fb 00000000 00000000 00000000 ffffffff 7fffffff 00000000 00000011
9e40: 00000000 ea9c4c38 00000000 c0e04900 00003fda eaff9efc ea9c4c4c ea98b800
9e60: eb1f7584 c0310be0 ea9c4c4c ea9c4c38 eaff9efc c0e04900 ea9c4c64 0000175c
9e80: ea9c4d90 c0e13020 0000000a c0310d2c 00003fd0 00003fd0 eb465198 00003418
9ea0: eaff9ea0 eaff9ea0 eaff9ea8 eaff9ea8 eaff9eb0 eaff9eb0 0000001a ea9c4d98
9ec0: ea9c4c38 0000175c ea9c4d90 ea9c4c3c ea9c4d80 00000000 00000088 c03110a0
9ee0: 00000000 c023b924 eb9a0d80 eafd7100 eb465100 eabe8000 00000000 0000175c
9f00: 00000000 eaff9e9c 00000000 00000006 00000003 00000000 00000000 00000000
9f20: eb7f6200 ea9c4d98 eb406600 00000000 eb407f00 00000000 ea9c4d9c c0235bdc
9f40: eb7f6200 ea9c4d98 eb7f6200 eb406600 eb406600 eaff8000 eb406624 c0e04900
9f60: eb7f6218 c023634c eafd7100 eb7f6380 eb7a7fc0 00000000 eb443ee4 eb7f63a8
9f80: eb7f6200 c0236080 00000000 c023a528 eb7a7fc0 c023a40c 00000000 00000000
9fa0: 00000000 00000000 00000000 c0206f38 00000000 00000000 00000000 00000000
9fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
9fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[<c03bc648>] (nfs_page_async_flush) from [<c03bc858>]
(nfs_writepages_callback+0x28/0x54)
[<c03bc858>] (nfs_writepages_callback) from [<c02b11e8>]
(write_cache_pages+0x278/0x364)
[<c02b11e8>] (write_cache_pages) from [<c03bc94c>] (nfs_writepages+0xa8/0xe8)
[<c03bc94c>] (nfs_writepages) from [<c02b2d48>] (do_writepages+0x34/0x80)
[<c02b2d48>] (do_writepages) from [<c0310434>]
(__writeback_single_inode+0x34/0x194)
[<c0310434>] (__writeback_single_inode) from [<c03109b8>]
(writeback_sb_inodes+0x1cc/0x390)
[<c03109b8>] (writeback_sb_inodes) from [<c0310be0>]
(__writeback_inodes_wb+0x64/0xa0)
[<c0310be0>] (__writeback_inodes_wb) from [<c0310d2c>]
(wb_writeback+0x110/0x18c)
[<c0310d2c>] (wb_writeback) from [<c03110a0>] (wb_workfn+0x1b8/0x304)
[<c03110a0>] (wb_workfn) from [<c0235bdc>] (process_one_work+0x1cc/0x31c)
[<c0235bdc>] (process_one_work) from [<c023634c>] (worker_thread+0x2cc/0x408)
[<c023634c>] (worker_thread) from [<c023a528>] (kthread+0x11c/0x13c)
[<c023a528>] (kthread) from [<c0206f38>] (ret_from_fork+0x14/0x3c)
Code: e3a02001 e5c32004 ebf98e95 e595300c (e5930030)
---[ end trace 2771b70506a823a3 ]---

static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
                                struct page *page)
{
        struct nfs_page *req;
        int ret = 0;

        ...

        /* If there is a fatal error that covers this write, just exit */
        if (nfs_error_is_fatal_on_server(req->wb_context->error))
                goto out_launder;

c03bc644:       e595300c        ldr     r3, [r5, #12]
c03bc648:       e5930030        ldr     r0, [r3, #48]   ; 0x30
c03bc64c:       ebfffd1b        bl      c03bbac0 <nfs_error_is_fatal_on_server>

req->wb_context must be NULL.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
