Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:41953 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdLFQTE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 11:19:04 -0500
MIME-Version: 1.0
In-Reply-To: <1512576648.26816.3.camel@primarydata.com>
References: <CAMuHMdWm8SGtekpdGVKsDi4L4sgvVZDFoC5wnSggVXFRt-irzA@mail.gmail.com>
 <CAMuHMdW00vUYmbvS=bvD+dAF4ge4yTLjE7gyso2Gk_tfqGrwXg@mail.gmail.com> <1512576648.26816.3.camel@primarydata.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 6 Dec 2017 17:19:02 +0100
Message-ID: <CAMuHMdWopysALsAzR0x0=uBk_bZDNT4RzgjKwGzqANDfoTxn-A@mail.gmail.com>
Subject: Re: NFS crash, hashed pointers in backtrace
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "me@tobin.cc" <me@tobin.cc>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Wed, Dec 6, 2017 at 5:10 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> On Wed, 2017-12-06 at 15:31 +0100, Geert Uytterhoeven wrote:
>> On Tue, Dec 5, 2017 at 5:02 PM, Geert Uytterhoeven <geert@linux-m68k.
>> org> wrote:
>> Got another nfsroot crash:
>>
>> Unable to handle kernel NULL pointer dereference at virtual address
>> 00000030
>> pgd = 329e8f6e
>> [00000030] *pgd=80000040004003, *pmd=00000000
>> Internal error: Oops: 206 [#1] SMP ARM
>> Modules linked in:
>> CPU: 0 PID: 101 Comm: kworker/u4:1 Not tainted
>> 4.15.0-rc2-koelsch-01166-g047d7d3248e08fc7-dirty #3762
>> Hardware name: Generic R-Car Gen2 (Flattened Device Tree)
>> Workqueue: writeback wb_workfn (flush-0:15)
>> task: 8a5bf858 task.stack: e93c92bc
>> PC is at nfs_page_async_flush+0x110/0x244

>> static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
>>                                 struct page *page)
>> {
>>         struct nfs_page *req;
>>         int ret = 0;
>>
>>         ...
>>
>>         /* If there is a fatal error that covers this write, just
>> exit */
>>         if (nfs_error_is_fatal_on_server(req->wb_context->error))
>>                 goto out_launder;
>>
>> c03bc644:       e595300c        ldr     r3, [r5, #12]
>> c03bc648:       e5930030        ldr     r0, [r3, #48]   ; 0x30
>> c03bc64c:       ebfffd1b        bl      c03bbac0
>> <nfs_error_is_fatal_on_server>
>>
>> req->wb_context must be NULL.
>>
>
> I'm confused. If your test involves only writing to a sysfs file, then
> why is the NFS code involved at all?

I don't think the second was related to sysfs.

> Could this be a use-after-free?

Possibly. I'm seeing other crashes, too. Looking into them...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
