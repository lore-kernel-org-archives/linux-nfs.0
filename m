Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ve1eur01on0091.outbound.protection.outlook.com ([104.47.1.91]:20819
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750917AbdGNTpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Jul 2017 15:45:25 -0400
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Dave Jones <davej@codemonkey.org.uk>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4c68e120-5ada-6ce1-30fd-e26155c9704e@virtuozzo.com>
Date: Fri, 14 Jul 2017 22:43:07 +0300
MIME-Version: 1.0
In-Reply-To: <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/14/2017 10:05 PM, Linus Torvalds wrote:
> On Fri, Jul 14, 2017 at 7:25 AM, Dave Jones <davej@codemonkey.org.uk> wrote:
>> On Thu, Jul 13, 2017 at 05:16:24PM -0400, Anna Schumaker wrote:
>>  >
>>  >   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1
>>
>> Since this landed, I'm seeing this during boot..
>>
>>  ==================================================================
>>  BUG: KASAN: global-out-of-bounds in strscpy+0x4a/0x230
>>  Read of size 8 at addr ffffffffb4eeaf20 by task nfsd/688
> 
> Is KASAN aware that strscpy() does the word-at-a-time optimistic reads
> of the sources?
> 

Nope.

> The problem may be that the source is initialized from the global
> string "nfsd", and KASAN may be unhappy abotu the fact that we read 8
> bytes from a 5-byte string (four plus NUL) as we do the word-at-a-time
> strscpy..
> 

Right.

> That said, we do check the size first (because we also *write* 8 bytes
> at a time), so maybe KASAN shouldn't even need to care.
>

Perhaps we could fallback to unoptimzed copy for KASAN case by setting max = 0
in strscpy().

 
> Hmm. it really looks to me like this is actually a compiler bug (I'm
> using current gcc in F26, which is gcc-7.1.1 - I'm assuming DaveJ is
> the same).
> 
> This is the source code in __ip_map_lookup:
> 
>         struct ip_map ip;
>      .....
>         strcpy(ip.m_class, class);
> 
> and "m_class" is 8 bytes in size:
> 
>     struct ip_map {
>     ...
>             char                    m_class[8]; /* e.g. "nfsd" */
>     ...
> 
> yet when I look at the generated code for __ip_map_lookup, I see
> 
>         movl    $32, %edx       #,
>         movq    %r13, %rsi      # class,
>         leaq    48(%rax), %rdi  #, tmp126
>         call    strscpy #
> 
> what's the bug here? Look at that third argume8nt - %rdx. It is
> initialized to 32.
> 
> WTF?
> 


It's not a compiler bug, it's a bug in our strcpy().
Whoever wrote this strcpy() into strscpy() code apparently didn't read carefully
enough gcc manual about __builtin_object_size().

Summary from https://gcc.gnu.org/onlinedocs/gcc/Object-Size-Checking.html :

	__builtin_object_size(ptr, type) returns a constant number of bytes from 'ptr' to the end of the object 'ptr'
	pointer points to. "type" is an integer constant from 0 to 3. If the least significant bit is clear, objects
	are whole variables, if it is set, a closest surrounding subobject is considered the object a pointer points to.
	The second bit determines if maximum or minimum of remaining bytes is computed. 

We have type = 0 in strcpy(), so the least significant bit is clear. So the 'ptr' is considered as a pointer to the whole
variable i.e. pointer to struct ip_map ip;
And the number of bytes from 'ip.m_class' to the end of the ip object is exactly 32.

I suppose that changing the type to 1 should fix this bug.



> The code to turn "strcpy()" into "strscpy()" should pick the *smaller*
> of the two object sizes as the size argument. How the hell is that
> size argument 32?
> 
> Am I missing something? DaveJ, do you see the same?
> 
>                        Linus
> 
