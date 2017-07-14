Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:58156 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdGNTs4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 15:48:56 -0400
Date: Fri, 14 Jul 2017 15:48:52 -0400
From: Dave Jones <davej@codemonkey.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170714194852.zmjqrc4t3thlvxaa@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFx=jOBws09qMfOyy22uz6CxezfS_DbKs7Ks6ZNqeZN6sQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 14, 2017 at 12:05:02PM -0700, Linus Torvalds wrote:
 > On Fri, Jul 14, 2017 at 7:25 AM, Dave Jones <davej@codemonkey.org.uk> wrote:
 > > On Thu, Jul 13, 2017 at 05:16:24PM -0400, Anna Schumaker wrote:
 > >  >
 > >  >   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1
 > >
 > > Since this landed, I'm seeing this during boot..
 > >
 > >  ==================================================================
 > >  BUG: KASAN: global-out-of-bounds in strscpy+0x4a/0x230
 > >  Read of size 8 at addr ffffffffb4eeaf20 by task nfsd/688
 > 
 > Is KASAN aware that strscpy() does the word-at-a-time optimistic reads
 > of the sources?
 > 
 > The problem may be that the source is initialized from the global
 > string "nfsd", and KASAN may be unhappy abotu the fact that we read 8
 > bytes from a 5-byte string (four plus NUL) as we do the word-at-a-time
 > strscpy..
 > 
 > That said, we do check the size first (because we also *write* 8 bytes
 > at a time), so maybe KASAN shouldn't even need to care.
 > 
 > Hmm. it really looks to me like this is actually a compiler bug (I'm
 > using current gcc in F26, which is gcc-7.1.1 - I'm assuming DaveJ is
 > the same).

Debian's 6.4.0

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
 > what's the bug here? Look at that third argument - %rdx. It is
 > initialized to 32.
 > 
 > WTF?
 > 
 > The code to turn "strcpy()" into "strscpy()" should pick the *smaller*
 > of the two object sizes as the size argument. How the hell is that
 > size argument 32?
 > 
 > Am I missing something? DaveJ, do you see the same?

My compiler seems to have replaced the call with an inlined copy afaics.

0000000000000be0 <__ip_map_lookup>:
{
     be0:       e8 00 00 00 00          callq  be5 <__ip_map_lookup+0x5>
     be5:       55                      push   %rbp
     be6:       48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
     bed:       fc ff df 
     bf0:       48 89 e5                mov    %rsp,%rbp
     bf3:       41 57                   push   %r15
     bf5:       41 56                   push   %r14
     bf7:       4c 8d 32                lea    (%rdx),%r14
        if (strscpy(p, q, p_size < q_size ? p_size : q_size) < 0)
     bfa:       ba 20 00 00 00          mov    $0x20,%edx
     bff:       41 55                   push   %r13
     c01:       4c 8d 2e                lea    (%rsi),%r13
     c04:       41 54                   push   %r12
     c06:       53                      push   %rbx
     c07:       48 8d 1f                lea    (%rdi),%rbx
     c0a:       48 8d a4 24 60 ff ff    lea    -0xa0(%rsp),%rsp
     c11:       ff 
     c12:       49 89 e4                mov    %rsp,%r12
     c15:       49 c1 ec 03             shr    $0x3,%r12
     c19:       48 c7 04 24 b3 8a b5    movq   $0x41b58ab3,(%rsp)
     c20:       41 
     c21:       48 c7 44 24 08 00 00    movq   $0x0,0x8(%rsp)
     c28:       00 00 
     c2a:       48 c7 44 24 10 00 00    movq   $0x0,0x10(%rsp)
     c31:       00 00 
     c33:       48 8d 7c 24 50          lea    0x50(%rsp),%rdi
     c38:       4d 8d 24 04             lea    (%r12,%rax,1),%r12
     c3c:       41 c7 04 24 f1 f1 f1    movl   $0xf1f1f1f1,(%r12)
     c43:       f1 
     c44:       41 c7 44 24 0c 00 00    movl   $0xf4f40000,0xc(%r12)
     c4b:       f4 f4 
     c4d:       65 48 8b 04 25 28 00    mov    %gs:0x28,%rax
     c54:       00 00 
     c56:       48 89 84 24 98 00 00    mov    %rax,0x98(%rsp)
     c5d:       00 
     c5e:       31 c0                   xor    %eax,%eax
     c60:       e8 00 00 00 00          callq  c65 <__ip_map_lookup+0x85>
     c65:       48 85 c0                test   %rax,%rax
     c68:       0f 88 a0 00 00 00       js     d0e <__ip_map_lookup+0x12e>
        ip.m_addr = *addr;
     c6e:       be 10 00 00 00          mov    $0x10,%esi
     c73:       49 8d 3e                lea    (%r14),%rdi
     c76:       e8 00 00 00 00          callq  c7b <__ip_map_lookup+0x9b>
     c7b:       49 8b 56 08             mov    0x8(%r14),%rdx


But that mov $0x20,%edx looks like it might be the same value we're talking about.

	Dave

