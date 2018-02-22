Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:47097 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbeBVAX2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 19:23:28 -0500
Received: by mail-ua0-f193.google.com with SMTP id n48so2238169uae.13
        for <linux-nfs@vger.kernel.org>; Wed, 21 Feb 2018 16:23:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxyvr-PVWaOe_PGjej4gGMdfF_Moq0a3A9xZ6gGWAQjbQ@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name>
 <CAGXu5j+gvH+X-XyqFbY+X0xtG2mQoL5bO7T2_QaeEyr3-Z5eLw@mail.gmail.com>
 <CA+55aFzsiVMFZVwm92N8L=E+YgOG+fpjwxt7rmz72=yMQGz8rg@mail.gmail.com>
 <CAGXu5jL5C1PHzVKwaQXuMm+jB=Wf0x-AN71_19RtzxvgYHHz3g@mail.gmail.com> <CA+55aFxyvr-PVWaOe_PGjej4gGMdfF_Moq0a3A9xZ6gGWAQjbQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 16:23:26 -0800
Message-ID: <CAGXu5jJRtiPNTZdA_RBUR=Xy6xcstqJUn_KoQtT4t=8jkucFQg@mail.gmail.com>
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

On Wed, Feb 21, 2018 at 4:22 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Feb 21, 2018 at 4:12 PM, Kees Cook <keescook@chromium.org> wrote:
>>
>> Do you want me to send the patch for this, or do you already have it
>> prepared?
>
> I'd rather get something explicitly tested. I tried my earlier patch
> with "make allmodconfig" (and a fix to nfsd to make it compile), but
> now I'm back to testing hjl's gas updates so it would be better to get
> a tested commit with a good commit message.
>
>> The body-fields I had prepared for the nfs were:
>>
>> Reported-by: Patrick McLean <chutzpah@gentoo.org>
>> Reported-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
>
> Oh, I think Maciej needs to get more than a "Reported-by:". This was a
> really subtle thing that we didn't figure out in the original thread,
> so give him a gold star in the form of "Root-caused-by:" or something.

Oops, I just sent this out. I will adjust a re-send. I couldn't find a
documented field name for this...

> *Fixing* this ends up being a one-liner or so. Finding the cause was
> the painful part.

Yes indeed!

-Kees

-- 
Kees Cook
Pixel Security
