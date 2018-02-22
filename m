Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:36851 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbeBVAMd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 19:12:33 -0500
Received: by mail-ua0-f193.google.com with SMTP id i15so2232482uak.3
        for <linux-nfs@vger.kernel.org>; Wed, 21 Feb 2018 16:12:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzsiVMFZVwm92N8L=E+YgOG+fpjwxt7rmz72=yMQGz8rg@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name>
 <CAGXu5j+gvH+X-XyqFbY+X0xtG2mQoL5bO7T2_QaeEyr3-Z5eLw@mail.gmail.com> <CA+55aFzsiVMFZVwm92N8L=E+YgOG+fpjwxt7rmz72=yMQGz8rg@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 16:12:29 -0800
Message-ID: <CAGXu5jL5C1PHzVKwaQXuMm+jB=Wf0x-AN71_19RtzxvgYHHz3g@mail.gmail.com>
Subject: Re: RANDSTRUCT structs need linux/compiler_types.h (Was: [nfsd4]
 potentially hardware breaking regression in 4.14-rc and 4.13.11)
To: Linus Torvalds <torvalds@linux-foundation.org>
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

On Wed, Feb 21, 2018 at 3:24 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Feb 21, 2018 at 2:52 PM, Kees Cook <keescook@chromium.org> wrote:
>>
>> I'll play with Linus's suggestion and see what we get.
>
> It may be just as well to just include <linux/compiler_types.h> from
> <linux/kconfig.h> and be done with it.

Hah, yeah, that would certainly solve it too. :)

> I do hate including unnecessary stuff because it makes builds slower,
> but kernel header files probably don't get much more core than
> <linux/compiler_types.h>.

It also has the benefit of not letting it "go wrong" in the first
place. (And the separate fix for nfs isn't needed...)

Do you want me to send the patch for this, or do you already have it
prepared? The body-fields I had prepared for the nfs were:

Reported-by: Patrick McLean <chutzpah@gentoo.org>
Reported-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
Fixes: 3859a271a003 ("randstruct: Mark various structs for randomization")

-Kees

-- 
Kees Cook
Pixel Security
