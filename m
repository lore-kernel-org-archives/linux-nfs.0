Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:36821 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbeBUXeg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 18:34:36 -0500
Received: by mail-vk0-f67.google.com with SMTP id q7so2058979vkh.3
        for <linux-nfs@vger.kernel.org>; Wed, 21 Feb 2018 15:34:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz-AD8rWb66rjN-YhAtPXukMiGSFfW3nBMCp8k1RYUvOQ@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name> <CA+55aFz-AD8rWb66rjN-YhAtPXukMiGSFfW3nBMCp8k1RYUvOQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 15:34:34 -0800
Message-ID: <CAGXu5jK3ZEs5SauEMHA3BnAyM1zbOkoG5cbM3B44_67TH1EZ=A@mail.gmail.com>
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

On Wed, Feb 21, 2018 at 2:47 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> And other attribute specifiers we encourage people to put in other
> parts of the type, like __user etc, so they don't have that same
> parsing issue.

Looking at other attributes we use on structs, we may have similar
risks for these:

__packed
____cacheline_aligned
____cacheline_aligned_in_smp
____cacheline_internodealigned_in_smp

But they just haven't been used in places that we could trip over it
as badly, AFAICT.

> I guess one _extreme_ fix for this would be to put
>
>     extern struct nostruct __randomize_layout;
>
> in our include/linux/kconfig.h, which I think we end up always
> including first thanks to having it on the command line.

We could do that for all the above, but I wonder if the real problem
is our convention of using "regular" names for these kinds of
attributes instead of parameterized names. If we always used something
like:

#define __struct(x)   __attribute__(x)

We'd avoid it, but we'd uglify our struct attributes:

struct thing { ... } __struct(randomize_layout);

though trying this now creates other problems. Hmmm.

(Regardless, let me send the nfs fix separately...)

-Kees

>
> Because if you do that, you actually get an error:
>
>     CC [M]  fs/nfsd/nfs4xdr.o
>   In file included from ./include/linux/fs_struct.h:5:0,
>                    from fs/nfsd/nfs4xdr.c:36:
>   ./include/linux/path.h:11:3: error: conflicting types for =E2=80=98__ra=
ndomize_layout=E2=80=99
>    } __randomize_layout;
>      ^~~~~~~~~~~~~~~~~~
>   In file included from <command-line>:0:0:
>   ././include/linux/kconfig.h:8:28: note: previous declaration of
> =E2=80=98__randomize_layout=E2=80=99 was here
>        extern struct nostruct __randomize_layout;
>                               ^~~~~~~~~~~~~~~~~~
>   make[1]: *** [scripts/Makefile.build:317: fs/nfsd/nfs4xdr.o] Error 1
>
> and we would have figured this out immediately.
>
> Broken example patch appended, in case somebody wants to play with
> something like this or comes up with a better model entirely..
>
>                Linus
>
> ---
>
> diff --git a/include/linux/kconfig.h b/include/linux/kconfig.h
> index fec5076eda91..537dacb83380 100644
> --- a/include/linux/kconfig.h
> +++ b/include/linux/kconfig.h
> @@ -4,6 +4,10 @@
>
>  #include <generated/autoconf.h>
>
> +#ifndef __ASSEMBLY__
> + extern struct nostruct __randomize_layout;
> +#endif
> +
>  #define __ARG_PLACEHOLDER_1 0,
>  #define __take_second_arg(__ignored, val, ...) val



--=20
Kees Cook
Pixel Security
