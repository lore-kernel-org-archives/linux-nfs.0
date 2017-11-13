Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:56423 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753128AbdKMW7r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Nov 2017 17:59:47 -0500
Received: by mail-wm0-f43.google.com with SMTP id z3so18439157wme.5
        for <linux-nfs@vger.kernel.org>; Mon, 13 Nov 2017 14:59:46 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: bit tweaks [was: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and 4.13.11]
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
        <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
Date: Mon, 13 Nov 2017 23:59:43 +0100
In-Reply-To: <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
        (Linus Torvalds's message of "Wed, 8 Nov 2017 18:40:22 -0800")
Message-ID: <87efp1zsww.fsf_-_@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 09 2017, Linus Torvalds <torvalds@linux-foundation.org> wrote:

> The code disassembles to
>
>    0: 83 c9 08              or     $0x8,%ecx
>    3: 40 f6 c6 04          test   $0x4,%sil
>    7: 0f 45 d1              cmovne %ecx,%edx
>    a: 89 d1                mov    %edx,%ecx
>    c: 80 cd 04              or     $0x4,%ch
>    f: 40 f6 c6 08          test   $0x8,%sil
>   13: 0f 45 d1              cmovne %ecx,%edx
>   16: 89 d1                mov    %edx,%ecx
>   18: 80 cd 08              or     $0x8,%ch
>   1b: 40 f6 c6 10          test   $0x10,%sil
>   1f: 0f 45 d1              cmovne %ecx,%edx
>   22: 89 d1                mov    %edx,%ecx
>   24: 80 cd 10              or     $0x10,%ch
>   27: 83 e6 20              and    $0x20,%esi
>   2a:* 48 8b b7 30 02 00 00 mov    0x230(%rdi),%rsi <-- trapping instruction
>   31: 0f 45 d1              cmovne %ecx,%edx
>   34: 83 ca 20              or     $0x20,%edx
>   37: 89 f1                mov    %esi,%ecx
>   39: 83 e1 10              and    $0x10,%ecx
>   3c: 89 cf                mov    %ecx,%edi
>
> and all those odd cmovne and bit-ops are just the bit selection code
> in flags_by_mnt(), which is inlined through calculate_f_flags (which
> is _also_ inlined) into vfs_statfs().
>
> Sadly, gcc makes a mess of it and actually generates code that looks
> like the original C. I would have hoped that gcc could have turned
>
>    if (x & BIT)
>         y |= OTHER_BIT;
>
> into
>
>     y |= (x & BIT) shifted-by-the-bit-difference-between BIT/OTHER_BIT;
>
> but that doesn't happen.

Actually, new enough gcc (7.1, I think) does contain a pattern that does
this, but unfortunately only if one spells it

  y |= (x & BIT) ? OTHER_BIT : 0;

which is half-way to doing it by hand, I suppose. Doing the

-       if (mnt_flags & MNT_READONLY)
-               flags |= ST_RDONLY;
+       flags |= (mnt_flags & MNT_READONLY) ? ST_RDONLY : 0;

and pasting into godbolt.org, one can apparently get gcc to compile it
to

flags_by_mnt(int):
  leal (%rdi,%rdi), %edx
  movl %edi, %eax
  sarl $6, %eax
  movl %edx, %ecx
  andl $1, %eax
  andl $12, %edx
  andl $2, %ecx
  orl %ecx, %eax
  orl %eax, %edx
  movl %edi, %eax
  sall $7, %eax
  andl $7168, %eax
  orl %edx, %eax
  ret

Rasmus
