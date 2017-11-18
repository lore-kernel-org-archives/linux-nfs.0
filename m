Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35025 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163224AbdKRIU6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 03:20:58 -0500
Received: by mail-io0-f182.google.com with SMTP id i38so11104954iod.2
        for <linux-nfs@vger.kernel.org>; Sat, 18 Nov 2017 00:20:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz5Z-9RDOyQhj-oNVQdrfmW_tXPhOqCK7M8nBnUjAVrPw@mail.gmail.com>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org> <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
 <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org> <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
 <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org> <ab1a286f-73dc-01aa-d797-0fef82534911@gentoo.org>
 <CA+55aFxw-ycca8+9ywckyXxH4dTggLJi5hXGdJtCQocjM86f5g@mail.gmail.com>
 <CAGXu5jL83V7hSpVLT69UTfgh3XkOsJw-S7Wc9_PQP7zGc8__rg@mail.gmail.com>
 <CA+55aFytWtipkgGtkZgzRTQqLPxG+QzJ2K9+oFdo9NVNXxB69g@mail.gmail.com>
 <3d948180-6bd7-c4e9-5ac8-5baef9cc15a7@gentoo.org> <CAGXu5jJBnJEPoUMQJTxxHXtHEUhpvq75xqzVdXsY5cKuHoe5Mg@mail.gmail.com>
 <09f2480f-e8e8-645b-6d94-b6ae4ca47806@gentoo.org> <CAGXu5jK=_BAKAAyhNms0MddJWPsLV2f78UWdnkxcSErmruhtNw@mail.gmail.com>
 <b2b323ae-447c-c44f-32a7-d9c1381545bf@gentoo.org> <CA+55aFwSfaqGN1R=N0c8fyFe-oengamdkTtnyomcCwG7f3HU5Q@mail.gmail.com>
 <242b16cd-056a-1499-2b65-69084dac1d8d@gentoo.org> <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <CA+55aFz5Z-9RDOyQhj-oNVQdrfmW_tXPhOqCK7M8nBnUjAVrPw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Sat, 18 Nov 2017 00:20:56 -0800
Message-ID: <CAGXu5jLMCK6yudcp5kyGpC-CdHdhBFRGkzW84GfOjZPhyV2kOQ@mail.gmail.com>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and 4.13.11
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Emese Revfy <re.emese@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 17, 2017 at 9:29 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Nov 17, 2017 at 9:14 PM, Kees Cook <keescook@chromium.org> wrote:
>>
>> FWIW, myself doing a build at d9e12200852d with and without
>> GCC_PLUGIN_RANDSTRUCT _appears_ to produce identical objdump output
>> where I did spot-checks.
>
> That would probably be a good thing to check anyway - check the
> difference between GCC_PLUGIN_RANDSTRUCT on and off at that commit.
>
> Just do
>
>    objdump --disassemble vmlinux > file
>
> and compare the two files for where the differences start occurring.

Yeah, I was just doing that now. Looks like there _is_ something
getting changed just from having the plugin enabled, but it appears
localized. For me, the first non-offset change happens in
lookup_user_key and persists for a while.

-ffffffff813893a7:      0f 85 55 03 00 00       jne
ffffffff81389702 <lookup_user_key+0x3f2>
-ffffffff813893ad:      f0 41 ff 06             lock incl (%r14)
-ffffffff813893b1:      83 fb 07                cmp    $0x7,%ebx
-ffffffff813893b4:      4c 89 b5 70 ff ff ff    mov    %r14,-0x90(%rbp)
...
+ffffffff813893a7:      0f 85 35 03 00 00       jne
ffffffff813896e2 <lookup_user_key+0x3d2>
+ffffffff813893ad:      4d 89 f0                mov    %r14,%r8
+ffffffff813893b0:      f0 41 ff 06             lock incl (%r14)
+ffffffff813893b4:      83 fb 07                cmp    $0x7,%ebx
+ffffffff813893b7:      4c 89 b5 70 ff ff ff    mov    %r14,-0x90(%rbp)

And removing the TYPE_ATTRIBUTES() poking makes the register storage
differences go away, but there's still a 0x40 byte offset delta.

I'll continue looking at this tomorrow.

-Kees

-- 
Kees Cook
Pixel Security
