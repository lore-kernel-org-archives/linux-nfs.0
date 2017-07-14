Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36128 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdGNT6y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 15:58:54 -0400
MIME-Version: 1.0
In-Reply-To: <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk> <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
 <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 14 Jul 2017 12:58:52 -0700
Message-ID: <CA+55aFyH-bL6NhX_jvqS50L4G5Y1QBgYhdiX9d1OH8Ze25EU6w@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Daniel Micay <danielmicay@gmail.com>,
        Kees Cook <keescook@chromium.org>
Cc: Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 12:43 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>> yet when I look at the generated code for __ip_map_lookup, I see
>>
>>        movl    $32, %edx       #,
>>        movq    %r13, %rsi      # class,
>>        leaq    48(%rax), %rdi  #, tmp126
>>        call    strscpy #
>>
>> what's the bug here? Look at that third argume8nt - %rdx. It is
>> initialized to 32.
>
> It's not a compiler bug, it's a bug in our strcpy().
> Whoever wrote this strcpy() into strscpy() code apparently didn't read carefully
> enough gcc manual about __builtin_object_size().
>
> Summary from https://gcc.gnu.org/onlinedocs/gcc/Object-Size-Checking.html :
>
>         __builtin_object_size(ptr, type) returns a constant number of bytes from 'ptr' to the end of the object 'ptr'
>         pointer points to. "type" is an integer constant from 0 to 3. If the least significant bit is clear, objects
>         are whole variables, if it is set, a closest surrounding subobject is considered the object a pointer points to.
>         The second bit determines if maximum or minimum of remaining bytes is computed.
>
> We have type = 0 in strcpy(), so the least significant bit is clear. So the 'ptr' is considered as a pointer to the whole
> variable i.e. pointer to struct ip_map ip;
> And the number of bytes from 'ip.m_class' to the end of the ip object is exactly 32.
>
> I suppose that changing the type to 1 should fix this bug.

Oh, that absolutely needs to be done.

Because that "strcpy() -> strscpy()" conversion really depends on that
size being the right size (well, in this case minimal safe size) for
the actual accesses, exactly because "strscpy()" is perfectly willing
to write *past* the end of the destination string within that given
size limit (ie it reads and writes in the same 8-byte chunks).

So if you have a small target string that is contained in a big
object, then the "hardened" strcpy() code can actually end up
overwriting things past the end of the strring, even if the string
itself were to have fit in the buffer.

I note that every single use in string.h is buggy, and it worries me
that __compiletime_object_size() does this too. The only user of that
seems to be check_copy_size(), and now I'm a bit worried what that bug
may have hidden.

I find "hardening" code that adds bugs to be particularly bad and
ugly, the same way that I absolutely *hate* debugging code that turns
out to make debugging impossible (we had that with the "better" stack
tracing code that caused kernel panics to kill the machine entirely
rather than show the backtrace, and I'm still bitter about it a decade
after the fact).

There is something actively *evil* about it. Daniel, Kees, please jump on this.

Andrey, thanks for noticing this thing,

                          Linus
