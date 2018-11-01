Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61C36C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:47:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 140052082E
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:47:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Xfu7lthm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 140052082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727956AbeKBCvK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 22:51:10 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:41218 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727946AbeKBCvK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 22:51:10 -0400
Received: by mail-io1-f65.google.com with SMTP id a5-v6so3908497ioq.8
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 10:47:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=GZ3g5TRsHSoiWmTwurfiPS0thu9nmyugmKBuMq6OY2A=;
        b=Xfu7lthmFocaTqqm4oUshXSI+8ZnFrLXuhIeV7gzUSUo30oBrQ5Ot2i+XioUneRAvV
         4epi7aEXKZ2l5Szj190g6sKE1JcSxDYxoqp9AwJqy5NgcFR+1OUpVW2rHTdHGgC84w6w
         rJk3BEGQ0GoCNSv6vVGJ2awh2d92AETxPMAx3BFNYBA9qK8vSdDKxs8mYtSAAdQ1vqc7
         2eq2Mr5CwIcdUI3FxTGIrq4yC6nBtV7V0v9o/angn1/tud8AP4QLjqYLwb3oHlZzpLfg
         UNGxORvSLriKk1PMRkRjec2lAKl6K/vaHjWtYefQJ+AXaANzPOLimMazCGwXmaxC/b3S
         x4Bg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=GZ3g5TRsHSoiWmTwurfiPS0thu9nmyugmKBuMq6OY2A=;
        b=rEUDjghs4XJjV2vlpF3YP5ZTx+JI2ZR7wOfJn/x2EVTsjQapsFpWefnmEy9T1gMThR
         s/hin9shARVC89l7vkA6Vd9gGLMO5WCw3DEVFQBORwO1c4So4hyESWCtAGT04g/5CtOw
         G3K5kpF7n9V2WvX+JObHRRnH7RIRW7fKDrueSrjK/LS3DU7YyAHyvqtJIdIzzFKsDN/K
         Nez31GpNc7/rbDsoZWHSgTZHYCYL//zVB7zlQiuLxZ6lSd7eO6GC0p4Yy2UDQHpEMDqy
         WWpv56i+cp1Nl6O+3wMygL1dZRz3atpHtM185yqiQaeYIgTiHbPD2e/9SBgfceBuFjlh
         0ovg==
X-Gm-Message-State: AGRZ1gLK8B7XvHpwGCcvzxkhYxdK3i8G6OSibGxsDbQkhtOqSYRn8m93
        iC+HzHoJL4bVm6uiQ/CnKy6yAJHCyaNvQ2lOzCZIXw==
X-Google-Smtp-Source: AJdET5eg28D2pB1ekw21nVpAOzB/FyaT3cOuFpZ8dio02aUzgoBPNz7gY7dCeb7ej+mqfTI72Lcai/crr0MgJ5sQxfE=
X-Received: by 2002:a6b:9383:: with SMTP id v125-v6mr5274871iod.282.1541094431071;
 Thu, 01 Nov 2018 10:47:11 -0700 (PDT)
MIME-Version: 1.0
Received: by 2002:a02:1003:0:0:0:0:0 with HTTP; Thu, 1 Nov 2018 10:46:50 -0700 (PDT)
In-Reply-To: <20181101171846.GI3178@hirez.programming.kicks-ass.net>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop> <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop> <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net> <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net> <20181101170146.GQ4170@linux.ibm.com>
 <20181101171846.GI3178@hirez.programming.kicks-ass.net>
From:   Dmitry Vyukov <dvyukov@google.com>
Date:   Thu, 1 Nov 2018 18:46:50 +0100
Message-ID: <CACT4Y+aC45BtS88DXarn3A+LV2RRRsPQoSs_3_DnKjU4O3AMHQ@mail.gmail.com>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
To:     Peter Zijlstra <peterz@infradead.org>
Cc:     "Paul E. McKenney" <paulmck@linux.ibm.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
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
        Andrey Ryabinin <aryabinin@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 1, 2018 at 6:18 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > > > > > My one question (and the reason why I went with cmpxchg() in the
>> > > > > > first place) would be about the overflow behaviour for
>> > > > > > atomic_fetch_inc() and friends. I believe those functions should
>> > > > > > be OK on x86, so that when we overflow the counter, it behaves
>> > > > > > like an unsigned value and wraps back around.  Is that the case
>> > > > > > for all architectures?
>> > > > > >
>> > > > > > i.e. are atomic_t/atomic64_t always guaranteed to behave like
>> > > > > > u32/u64 on increment?
>> > > > > >
>> > > > > > I could not find any documentation that explicitly stated that
>> > > > > > they should.
>> > > > >
>> > > > > Peter, Will, I understand that the atomic_t/atomic64_t ops are
>> > > > > required to wrap per 2's-complement. IIUC the refcount code relies
>> > > > > on this.
>> > > > >
>> > > > > Can you confirm?
>> > > >
>> > > > There is quite a bit of core code that hard assumes 2s-complement.
>> > > > Not only for atomics but for any signed integer type. Also see the
>> > > > kernel using -fno-strict-overflow which implies -fwrapv, which
>> > > > defines signed overflow to behave like 2s-complement (and rids us of
>> > > > that particular UB).
>> > >
>> > > Fair enough, but there have also been bugfixes to explicitly fix unsafe
>> > > C standards assumptions for signed integers. See, for instance commit
>> > > 5a581b367b5d "jiffies: Avoid undefined behavior from signed overflow"
>> > > from Paul McKenney.
>> >
>> > Yes, I feel Paul has been to too many C/C++ committee meetings and got
>> > properly paranoid. Which isn't always a bad thing :-)
>>
>> Even the C standard defines 2s complement for atomics.
>
> Ooh good to know.
>
>> Just not for
>> normal arithmetic, where yes, signed overflow is UB.  And yes, I do
>> know about -fwrapv, but I would like to avoid at least some copy-pasta
>> UB from my kernel code to who knows what user-mode environment.  :-/
>>
>> At least where it is reasonably easy to do so.
>
> Fair enough I suppose; I just always make sure to include the same
> -fknobs for the userspace thing when I lift code.
>
>> And there is a push to define C++ signed arithmetic as 2s complement,
>> but there are still 1s complement systems with C compilers.  Just not
>> C++ compilers.  Legacy...
>
> *groan*; how about those ancient hardwares keep using ancient compilers
> and we all move on to the 70s :-)
>
>> > But for us using -fno-strict-overflow which actually defines signed
>> > overflow, I myself am really not worried. I'm also not sure if KASAN has
>> > been taught about this, or if it will still (incorrectly) warn about UB
>> > for signed types.
>>
>> UBSAN gave me a signed-overflow warning a few days ago.  Which I have
>> fixed, even though 2s complement did the right thing.  I am also taking
>> advantage of the change to use better naming.
>
> Oh too many *SANs I suppose; and yes, if you can make the code better,
> why not.

If there is a warning that we don't want to see at all, then we can
disable it. It supposed to be a useful tool, rather than a thing in
itself that lives own life. We already I think removed 1 particularly
noisy warning and made another optional via a config.
But the thing with overflows is that, even if it's defined, it's not
necessary the intended behavior. For example, take allocation size
calculation done via unsigned size_t. If it overflows it does not help
if C defines result or not, it still gives a user controlled write
primitive. We've seen similar cases with timeout/deadline calculation
in kernel, we really don't want it to just wrap modulo-2, right. Some
user-space projects even test with unsigned overflow warnings or
implicit truncation warnings, which are formally legal, but frequently
bugs.
