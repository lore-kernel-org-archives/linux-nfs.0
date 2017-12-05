Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:39528 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdLEQdU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 11:33:20 -0500
MIME-Version: 1.0
In-Reply-To: <CAMuHMdWm8SGtekpdGVKsDi4L4sgvVZDFoC5wnSggVXFRt-irzA@mail.gmail.com>
References: <CAMuHMdWm8SGtekpdGVKsDi4L4sgvVZDFoC5wnSggVXFRt-irzA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Dec 2017 08:33:18 -0800
Message-ID: <CA+55aFz=nbbOcNOfA1rbrkiFPdeRFPVANGLCoUTm=LGqS9KqGg@mail.gmail.com>
Subject: Re: NFS crash, hashed pointers in backtrace
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Tobin C. Harding" <me@tobin.cc>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 5, 2017 at 8:02 AM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> During a failed write to a virtual sysfs file (root fs is NFS), I got:
>
> Unable to handle kernel NULL pointer dereference at virtual address 00000020
> pgd = c448bb15

Ok, this pgd value looks hashed, and should maybe be fixed to using
%px, although possibly that line could/should just be deleted. The
whole "print out page table pointer" is very traditional, but it is of
seriously dubious utility. I don't think I've used that information in
about two decades or more, and I doubt anybody else has either.

> task: 4a3bb6d2 task.stack: fd0c00bd

Again, hashed, and again, likely useless.

This is actually generic code (show_regs_print_info()), and I think
I'll just remove that line. The actual _useful_ information was
printed earlier by dump_stack_print_info(), which printed the process
names etc.

The reason we print out the task and task.stack values is that they
used to be related to each other, and that was basically printing out
the stack depth (in a weird format). And the stack depth might still
be a very interesting thing to print out, but we should actually do it
as such, not by printing out these two pointers in generic code that
aren't even related to each other, and haven't been for over a decade.
Even when we allocate the stack together with the process structure,
these days we do it with the "thread_info", not the "task_struct".
That thread_info separation happened ages and ages ago.

And obviously, more recently we unlinked even the thread_info from the
stack, so now those two pointers are just completely random and have
absolutely nothing to do with each other if you pick the virtual stack
option.

Equally importantly, printing out the task_struct address is actually
an example of exactly the kinds of things we should _not_ do without
big big reasons.

And it's a totally useless number to print out on its own, unless you
have kgdb, in which case you can just get it with kgdb itself anyway.

> Stack: (0xeab25e40 to 0xeab26000)
> 5e40: 00000000 00000000 00000ab9 0000660a eaaaea00 c03b098c 00000000 00000000

So this isn't hashed, but may I suggest that the stack printout should
just be removed? Again, it's traditional, and it was useful back in
the days, but we removed it on x86 about a year ago:

    0ee1dd9f5e7e ("x86/dumpstack: Remove raw stack dump")

and I'm not aware of anybody having missed it (and I definitely like
the new stack traces better, because they show information that is
actually _useful_, and doesn't mix that up with the noise that isn't).

And then you have the backtrace itself, which _is_ very useful, but:

> [<c03bcf04>] (nfs_flush_incompatible) from [<c03b098c>]

Those hex numbers are not hashed, but they should just be removed.
Again, we did that on x86 some time ago.

The hex values are pointless. Nobody can use them if you do kaslr, and
you really should. And even if you don't have kaslr enabled, nobody
uses them because all they would do with them is look up the symbol
names anyway.

They exist - once again - for historical reasons. We used to have
"ksymoops" that took the hex numbers and turned them into this
"[<hex>] symbol+offset/size" format, but then when we started doing
kallsyms and print out the symbol name natively, we kept the legacy
format. Not for any very good reason.

So I'd suggest all architectures follow the x86 lead of just removing
the hex output from the stack backtrace.

Anyway, I did the generic code case, but the arch cases I left alone.
If arch maintainers feel strongly that they are useful, they can
always use %px. I suspect none of those values are worth converting to
that, though.

                 Linus
