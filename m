Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF309C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:35:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B61462064C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:35:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EjDVk916"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B61462064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726094AbeKBBi6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:38:58 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:41986 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726042AbeKBBi5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:38:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=72R9GSVv7q61E8s94sqJXn1GeQMfmrRmyrChueXaE7o=; b=EjDVk916koSID/y6g6cHYn2U0
        H0Dp44Xq9Z4gsV937jqvr0H8/OvdnyAJrPM4MSc0DghXIXDQYKRd7XszAq73m8jiPtcLDA3RaNcF6
        s8jDzxwGB42zer9eDKYQt23SthtpPQlMYaFTagbfYWlXx3pkhZD6gWoS4l77j4T3ez0XXgBh4mvw5
        pU3DqmA8ykYhW06wZLT+Vx+KEzEdOLoM+E/BtFiW1AejvhVkSTK7xo8ryt7EnpoyDHSb/MArxg/rG
        rkuf7fCmBhGO3jJy0j1x25iy9pwUK0V1tTxDAIvfGEuqOcV+Rv+HVv4Fct2rw8aPBmQOKRKlQ7IsW
        UFvIJi2NA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
        by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gIFtH-0002L3-Pg; Thu, 01 Nov 2018 16:32:16 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
        id 7CAE020297B7F; Thu,  1 Nov 2018 17:32:12 +0100 (CET)
Date:   Thu, 1 Nov 2018 17:32:12 +0100
From:   Peter Zijlstra <peterz@infradead.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
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
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        aryabinin@virtuozzo.com, dvyukov@google.com
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181101163212.GF3159@hirez.programming.kicks-ass.net>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 03:22:15PM +0000, Trond Myklebust wrote:
> On Thu, 2018-11-01 at 15:59 +0100, Peter Zijlstra wrote:
> > On Thu, Nov 01, 2018 at 01:18:46PM +0000, Mark Rutland wrote:

> > > > My one question (and the reason why I went with cmpxchg() in the
> > > > first place) would be about the overflow behaviour for
> > > > atomic_fetch_inc() and friends. I believe those functions should
> > > > be OK on x86, so that when we overflow the counter, it behaves
> > > > like an unsigned value and wraps back around.  Is that the case
> > > > for all architectures?
> > > > 
> > > > i.e. are atomic_t/atomic64_t always guaranteed to behave like
> > > > u32/u64 on increment?
> > > > 
> > > > I could not find any documentation that explicitly stated that
> > > > they should.
> > > 
> > > Peter, Will, I understand that the atomic_t/atomic64_t ops are
> > > required to wrap per 2's-complement. IIUC the refcount code relies
> > > on this.
> > > 
> > > Can you confirm?
> > 
> > There is quite a bit of core code that hard assumes 2s-complement.
> > Not only for atomics but for any signed integer type. Also see the
> > kernel using -fno-strict-overflow which implies -fwrapv, which
> > defines signed overflow to behave like 2s-complement (and rids us of
> > that particular UB).
> 
> Fair enough, but there have also been bugfixes to explicitly fix unsafe
> C standards assumptions for signed integers. See, for instance commit
> 5a581b367b5d "jiffies: Avoid undefined behavior from signed overflow"
> from Paul McKenney.

Yes, I feel Paul has been to too many C/C++ committee meetings and got
properly paranoid. Which isn't always a bad thing :-)

But for us using -fno-strict-overflow which actually defines signed
overflow, I myself am really not worried. I'm also not sure if KASAN has
been taught about this, or if it will still (incorrectly) warn about UB
for signed types.

> Anyhow, if the atomic maintainers are willing to stand up and state for
> the record that the atomic counters are guaranteed to wrap modulo 2^n
> just like unsigned integers, then I'm happy to take Paul's patch.

I myself am certainly relying on it.
