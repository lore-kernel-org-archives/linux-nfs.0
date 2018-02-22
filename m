Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:50204 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbeBVAWI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 19:22:08 -0500
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL5C1PHzVKwaQXuMm+jB=Wf0x-AN71_19RtzxvgYHHz3g@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name>
 <CAGXu5j+gvH+X-XyqFbY+X0xtG2mQoL5bO7T2_QaeEyr3-Z5eLw@mail.gmail.com>
 <CA+55aFzsiVMFZVwm92N8L=E+YgOG+fpjwxt7rmz72=yMQGz8rg@mail.gmail.com> <CAGXu5jL5C1PHzVKwaQXuMm+jB=Wf0x-AN71_19RtzxvgYHHz3g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Feb 2018 16:22:06 -0800
Message-ID: <CA+55aFxyvr-PVWaOe_PGjej4gGMdfF_Moq0a3A9xZ6gGWAQjbQ@mail.gmail.com>
Subject: Re: RANDSTRUCT structs need linux/compiler_types.h (Was: [nfsd4]
 potentially hardware breaking regression in 4.14-rc and 4.13.11)
To: Kees Cook <keescook@chromium.org>
Cc: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>,
        Patrick McLean <chutzpah@gentoo.org>,
        Emese Revfy <re.emese@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 21, 2018 at 4:12 PM, Kees Cook <keescook@chromium.org> wrote:
>
> Do you want me to send the patch for this, or do you already have it
> prepared?

I'd rather get something explicitly tested. I tried my earlier patch
with "make allmodconfig" (and a fix to nfsd to make it compile), but
now I'm back to testing hjl's gas updates so it would be better to get
a tested commit with a good commit message.

> The body-fields I had prepared for the nfs were:
>
> Reported-by: Patrick McLean <chutzpah@gentoo.org>
> Reported-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>

Oh, I think Maciej needs to get more than a "Reported-by:". This was a
really subtle thing that we didn't figure out in the original thread,
so give him a gold star in the form of "Root-caused-by:" or something.

*Fixing* this ends up being a one-liner or so. Finding the cause was
the painful part.

               Linus
