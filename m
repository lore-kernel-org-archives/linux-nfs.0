Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:40307 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbeCETPh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 14:15:37 -0500
Received: by mail-ua0-f195.google.com with SMTP id c14so11283998uak.7
        for <linux-nfs@vger.kernel.org>; Mon, 05 Mar 2018 11:15:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAK7LNASKHOb5GNPu9XHWxyq-iucxTRkw99_7wL4zgm5HNc6_SA@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name>
 <CA+55aFz-AD8rWb66rjN-YhAtPXukMiGSFfW3nBMCp8k1RYUvOQ@mail.gmail.com> <CAK7LNASKHOb5GNPu9XHWxyq-iucxTRkw99_7wL4zgm5HNc6_SA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 5 Mar 2018 11:15:35 -0800
Message-ID: <CAGXu5jJo+c4d+=57rFiHaFrOHxDHVSZzMhWSMqNQe+tcw0-4zQ@mail.gmail.com>
Subject: Re: RANDSTRUCT structs need linux/compiler_types.h (Was: [nfsd4]
 potentially hardware breaking regression in 4.14-rc and 4.13.11)
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>,
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

On Mon, Mar 5, 2018 at 1:27 AM, Masahiro Yamada
<yamada.masahiro@socionext.com> wrote:
> Sorry for chiming in late.
>
> I noticed this thread today,
> honestly, the commit made me upset.
>
>
> Can I suggest another way to make it less fragile?
> __attribute((...)) can be placed after 'struct'.
>
>
> So, we can write:
>
>
> struct __randomize_layout path {
>         struct vfsmount *mnt;
>         struct dentry *dentry;
> };
>
>
>   instead of
>
>
> struct path {
>         struct vfsmount *mnt;
>         struct dentry *dentry;
> } __randomize_layout;

Ugh. I had tried this after the struct _name_, not after "struct"
itself. This does fix it, though it remains fragile, as you mention.

> If we force the former notation,
> the undefined __randomize_layout results in a build error
> instead of silent broken code generation.
>
>
> It is true somebody can still place
> __randomize_layout after the closing brace,
> but can we check this by coccicheck or checkpatch.pl?
> (we can describe it in coding style documentation, of course)
>
>
> IMHO, we should not (ab)use include/linux/kconfig.h
> to bring in misc things.

I'm happy to send a patch that reverts the other changes and relocates
all the markings...

Linus, how would you like this to go?

-Kees

-- 
Kees Cook
Pixel Security
