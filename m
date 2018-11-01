Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 133FAC6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 21:46:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C2A2820657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 21:46:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ls+xdu4o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2A2820657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727790AbeKBGuq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 02:50:46 -0400
Received: from merlin.infradead.org ([205.233.59.134]:57064 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727151AbeKBGuq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 02:50:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=MEJyokPYI7oa2A6Ix9ONUmGbnct/Kvmgb/sJnQOStxc=; b=ls+xdu4ozQ7c4yvsm9ovqZ/4f
        fiFuSHac7Q2elKhmdle5qz3kdC0phtzafFsg4Fo2K2xfxrjjRsDtWE8XnThq8D8sZp3qGvjfpHNYJ
        KPaE2XjSwPvKGaCuIvf0YpWpc37Hen7TUH95ZQP0r4vzo5jp+Nq2MzUx1YnyYOG061j3OHyzTmnlr
        s4Jw3VZyfp0csnbleNLXSg2xp268RVktS0DawCGK+9p+MdaTrMQynXvZgyztm7d70YjSIr84TKOug
        92DT3I1mDBUZhew+WI6z8TpS90qReNeQaT3Sba2tf1zJwoV+RlbOUgr7lAc/5xwwbeYpK4YRYEmbD
        9zqkC8MRw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=worktop)
        by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gIKmR-00079A-Uh; Thu, 01 Nov 2018 21:45:32 +0000
Received: by worktop (Postfix, from userid 1000)
        id 4A4CE6E07D9; Thu,  1 Nov 2018 22:45:29 +0100 (CET)
Date:   Thu, 1 Nov 2018 22:45:29 +0100
From:   Peter Zijlstra <peterz@infradead.org>
To:     Dmitry Vyukov <dvyukov@google.com>
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
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181101214529.GB3339@worktop.programming.kicks-ass.net>
References: <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <20181101170146.GQ4170@linux.ibm.com>
 <20181101171846.GI3178@hirez.programming.kicks-ass.net>
 <CACT4Y+aC45BtS88DXarn3A+LV2RRRsPQoSs_3_DnKjU4O3AMHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aC45BtS88DXarn3A+LV2RRRsPQoSs_3_DnKjU4O3AMHQ@mail.gmail.com>
User-Agent: Mutt/1.5.22.1 (2013-10-16)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 06:46:50PM +0100, Dmitry Vyukov wrote:
> If there is a warning that we don't want to see at all, then we can
> disable it. It supposed to be a useful tool, rather than a thing in
> itself that lives own life. We already I think removed 1 particularly
> noisy warning and made another optional via a config.

> But the thing with overflows is that, even if it's defined, it's not
> necessary the intended behavior. For example, take allocation size
> calculation done via unsigned size_t. If it overflows it does not help
> if C defines result or not, it still gives a user controlled write
> primitive. We've seen similar cases with timeout/deadline calculation
> in kernel, we really don't want it to just wrap modulo-2, right. Some
> user-space projects even test with unsigned overflow warnings or
> implicit truncation warnings, which are formally legal, but frequently
> bugs.

Sure; but then don't call it UB.

If we want to have an additional integer over/underflow checker (ideally
with a gcc plugin that has explicit annotations like __wrap to make it
go away) that is fine; and it can be done on unsigned and signed.


