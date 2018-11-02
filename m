Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E6DDC32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 12:24:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE91E2081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 12:24:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Xhph0d9i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE91E2081F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726129AbeKBVbu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 17:31:50 -0400
Received: from merlin.infradead.org ([205.233.59.134]:33810 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726099AbeKBVbt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 17:31:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=79c9zmPcOUUU1UAuRc5HBkl7+igHKIgqc4mNscycBvg=; b=Xhph0d9iIiViyCbG/1IQdhNuj
        JIDUhhsu8Ds6cMIOM1jhZNaYInzAUorTwaE4ZgckudtUAdJGWLYaTXzRVLHAlCH66hj7fIGLHr4B4
        iArpJcMU4Vd/DCDPt0CpAPCDej9RZl4cF+24YTKlElJQefk46wfcjrUg2xdw7YewesKJB4ESTgYAu
        c0nWrEqFXzsoD0RBH1dMRMGsqs6ezr2VB7k2vfmx/UGUgVmW9p+/9OKaJywqEKGBsV9/gzSsgwzHG
        hVmhudiVVKXdS9y5lEmchzijVbrdLS/7oPqGG9KXJj7mqbQh8yE3JWhAiWPh/pwasFFsq7biCe3oI
        JmEE1iwhw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
        by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gIYU7-0002oa-2E; Fri, 02 Nov 2018 12:23:31 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
        id 32E3F2029F9FF; Fri,  2 Nov 2018 13:23:28 +0100 (CET)
Date:   Fri, 2 Nov 2018 13:23:28 +0100
From:   Peter Zijlstra <peterz@infradead.org>
To:     David Laight <David.Laight@ACULAB.COM>
Cc:     "'paulmck@linux.ibm.com'" <paulmck@linux.ibm.com>,
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
        "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>,
        "dvyukov@google.com" <dvyukov@google.com>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181102122328.GM3178@hirez.programming.kicks-ass.net>
References: <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <20181101170146.GQ4170@linux.ibm.com>
 <7d1ecd21c4c249138dfdd42b9aaa1cea@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d1ecd21c4c249138dfdd42b9aaa1cea@AcuMS.aculab.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 02, 2018 at 10:56:31AM +0000, David Laight wrote:
> From: Paul E. McKenney
> > Sent: 01 November 2018 17:02
> ...
> > And there is a push to define C++ signed arithmetic as 2s complement,
> > but there are still 1s complement systems with C compilers.  Just not
> > C++ compilers.  Legacy...
> 
> Hmmm... I've used C compilers for DSPs where signed integer arithmetic
> used the 'data registers' and would saturate, unsigned used the 'address
> registers' and wrapped.
> That was deliberate because it is much better to clip analogue values.

Seems a dodgy heuristic if you ask me.

> Then there was the annoying cobol run time that didn't update the
> result variable if the result wouldn't fit.
> Took a while to notice that the sum of a list of values was even wrong!
> That would be perfectly valid for C - if unexpected.

That's just insane ;-)

> > > But for us using -fno-strict-overflow which actually defines signed
> > > overflow
> 
> I wonder how much real code 'strict-overflow' gets rid of?
> IIRC gcc silently turns loops like:
> 	int i; for (i = 1; i != 0; i *= 2) ...
> into infinite ones.
> Which is never what is required.

Nobody said C was a 'safe' language. But less UB makes a better language
IMO. Ideally we'd get all UBs filled in -- but I realise C has a few
very 'interesting' ones that might be hard to get rid of.
