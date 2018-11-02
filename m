Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A450C65C22
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:47:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4CC6E2082D
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CC6E2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727946AbeKCBzV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 21:55:21 -0400
Received: from relay.sw.ru ([185.231.240.75]:47642 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727805AbeKCBzV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 21:55:21 -0400
X-Greylist: delayed 1715 seconds by postgrey-1.27 at vger.kernel.org; Fri, 02 Nov 2018 21:55:20 EDT
Received: from [172.16.25.12]
        by relay.sw.ru with esmtp (Exim 4.90_1)
        (envelope-from <aryabinin@virtuozzo.com>)
        id 1gIc9V-0006r7-Q8; Fri, 02 Nov 2018 19:18:30 +0300
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
To:     Peter Zijlstra <peterz@infradead.org>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc:     "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "boqun.feng@gmail.com" <boqun.feng@gmail.com>,
        "paul.burton@mips.com" <paul.burton@mips.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jhogan@kernel.org" <jhogan@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "paulus@samba.org" <paulus@samba.org>,
        "mpe@ellerman.id.au" <mpe@ellerman.id.au>,
        "benh@kernel.crashing.org" <benh@kernel.crashing.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>, dvyukov@google.com
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
From:   Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5a846924-e642-d9d1-4e0e-810bd4d01c26@virtuozzo.com>
Date:   Fri, 2 Nov 2018 19:19:15 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20181101163212.GF3159@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 11/01/2018 07:32 PM, Peter Zijlstra wrote:
> On Thu, Nov 01, 2018 at 03:22:15PM +0000, Trond Myklebust wrote:
>> On Thu, 2018-11-01 at 15:59 +0100, Peter Zijlstra wrote:
>>> On Thu, Nov 01, 2018 at 01:18:46PM +0000, Mark Rutland wrote:
> 
>>>>> My one question (and the reason why I went with cmpxchg() in the
>>>>> first place) would be about the overflow behaviour for
>>>>> atomic_fetch_inc() and friends. I believe those functions should
>>>>> be OK on x86, so that when we overflow the counter, it behaves
>>>>> like an unsigned value and wraps back around.  Is that the case
>>>>> for all architectures?
>>>>>
>>>>> i.e. are atomic_t/atomic64_t always guaranteed to behave like
>>>>> u32/u64 on increment?
>>>>>
>>>>> I could not find any documentation that explicitly stated that
>>>>> they should.
>>>>
>>>> Peter, Will, I understand that the atomic_t/atomic64_t ops are
>>>> required to wrap per 2's-complement. IIUC the refcount code relies
>>>> on this.
>>>>
>>>> Can you confirm?
>>>
>>> There is quite a bit of core code that hard assumes 2s-complement.
>>> Not only for atomics but for any signed integer type. Also see the
>>> kernel using -fno-strict-overflow which implies -fwrapv, which
>>> defines signed overflow to behave like 2s-complement (and rids us of
>>> that particular UB).
>>
>> Fair enough, but there have also been bugfixes to explicitly fix unsafe
>> C standards assumptions for signed integers. See, for instance commit
>> 5a581b367b5d "jiffies: Avoid undefined behavior from signed overflow"
>> from Paul McKenney.
> 
> Yes, I feel Paul has been to too many C/C++ committee meetings and got
> properly paranoid. Which isn't always a bad thing :-)
> 
> But for us using -fno-strict-overflow which actually defines signed
> overflow, I myself am really not worried. I'm also not sure if KASAN has
> been taught about this, or if it will still (incorrectly) warn about UB
> for signed types.
> 

UBSAN warns about signed overflows despite -fno-strict-overflow if gcc version is < 8.
I have learned recently that UBSAN in GCC 8 ignores signed overflows if -fno-strict-overflow of fwrapv is used.

$ cat signed_overflow.c 
#include <stdio.h>

__attribute__((noinline))
int foo(int a, int b)
{
        return a+b;
}

int main(void)
{
        int a = 0x7fffffff;
        int b = 2;
        printf("%d\n", foo(a,b));
        return 0;
}

$ gcc-8.2.0 -fsanitize=signed-integer-overflow signed_overflow.c && ./a.out 
signed_overflow.c:6:10: runtime error: signed integer overflow: 2147483647 + 2 cannot be represented in type 'int'
-2147483647
$ gcc-8.2.0 -fno-strict-overflow -fsanitize=signed-integer-overflow signed_overflow.c && ./a.out 
-2147483647
$ gcc-7.3.0 -fsanitize=signed-integer-overflow signed_overflow.c && ./a.out
signed_overflow.c:6:10: runtime error: signed integer overflow: 2147483647 + 2 cannot be represented in type 'int'
-2147483647
$ gcc-7.3.0 -fno-strict-overflow -fsanitize=signed-integer-overflow signed_overflow.c && ./a.out
signed_overflow.c:6:10: runtime error: signed integer overflow: 2147483647 + 2 cannot be represented in type 'int'
-2147483647


clang behaves the same way as GCC 8:
$ clang -fsanitize=signed-integer-overflow signed_overflow.c && ./a.out 
signed_overflow.c:6:10: runtime error: signed integer overflow: 2147483647 + 2 cannot be represented in type 'int'
-2147483647
$ clang -fno-strict-overflow -fsanitize=signed-integer-overflow signed_overflow.c && ./a.out 
-2147483647


We can always just drop -fsanitize=signed-integer-overflow if it considered too noisy.
Although it did catch some real bugs.
