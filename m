Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36322 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbeCETSw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 14:18:52 -0500
MIME-Version: 1.0
In-Reply-To: <CAK7LNASKHOb5GNPu9XHWxyq-iucxTRkw99_7wL4zgm5HNc6_SA@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name>
 <CA+55aFz-AD8rWb66rjN-YhAtPXukMiGSFfW3nBMCp8k1RYUvOQ@mail.gmail.com> <CAK7LNASKHOb5GNPu9XHWxyq-iucxTRkw99_7wL4zgm5HNc6_SA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 5 Mar 2018 11:18:50 -0800
Message-ID: <CA+55aFyf9NkW26BNyEnvUT60u2oXezRiXMexdHy8yx1AD9aUYw@mail.gmail.com>
Subject: Re: RANDSTRUCT structs need linux/compiler_types.h (Was: [nfsd4]
 potentially hardware breaking regression in 4.14-rc and 4.13.11)
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>,
        Kees Cook <keescook@chromium.org>,
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
>
> Can I suggest another way to make it less fragile?
> __attribute((...)) can be placed after 'struct'.

That avoids the actual bug, but it wouldn't have helped _find_ the
problem in the first place.

If somebody ever does the same thing, they'd hit the same issue. And
it's not just __randomize_struct, it's any of our other type markers.

We can say "don't do that", but if there is no automated checking,
it's still ripe to cause problems just because somebody didn't notice.

So I'd rather have something that causes a build failure when
something goes wrong, rather than silently accepting syntax that
wasn't intended.

                   Linus
