Return-Path: <SRS0=wnB3=NQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DFE9C46475
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 10:41:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4DFCE20869
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 10:41:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Wv+odmWP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DFCE20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729158AbeKEUAx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Nov 2018 15:00:53 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:54744 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726932AbeKEUAw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2018 15:00:52 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=xM+5KMmwXYKR9Dl+Z8QkTOny5tVl3Bw3ZbxUOoCyscc=; b=Wv+odmWPtgTZFNxPoRYeWsf1q
        zALPW7CCk8mgrIshGlbTfXFUH+25v16P/rUnrQRVFSzQJ//1lz+BJ744NjhIuXEOcIX4xEluFRcrz
        RjBK/tXUJeoZmyrfmn9hjrteIoFTY/tbkBT/4VKv2LaKMUL5PkLTw/Mv7Y112A8+LzfDpD5ICbXUf
        XU3qgzXhjmHnMMngQ1C8LfBpxSWLFHgYG1P9w81QthqXS1OQpnFoWX4lMUTr/bM9+dyqHy1op+5aq
        30eYLR1Ig9byueGRzHCuZ9o/lmTSO7Y9hZ9OO8ulQG0sO47Dg9Q42bI+KUkaNO3o7An//O2a4ecaO
        Tiw6aeszA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
        by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gJcHb-0002gD-BL; Mon, 05 Nov 2018 10:38:59 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
        id B1FB72029F9FF; Mon,  5 Nov 2018 11:38:57 +0100 (CET)
Date:   Mon, 5 Nov 2018 11:38:57 +0100
From:   Peter Zijlstra <peterz@infradead.org>
To:     Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
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
        Paul McKenney <paulmck@linux.vnet.ibm.com>, dvyukov@google.com
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181105103857.GB22431@hirez.programming.kicks-ass.net>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <5a846924-e642-d9d1-4e0e-810bd4d01c26@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a846924-e642-d9d1-4e0e-810bd4d01c26@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 02, 2018 at 07:19:15PM +0300, Andrey Ryabinin wrote:

> UBSAN warns about signed overflows despite -fno-strict-overflow if gcc
> version is < 8.  I have learned recently that UBSAN in GCC 8 ignores
> signed overflows if -fno-strict-overflow of fwrapv is used.

Ah, good.

> We can always just drop -fsanitize=signed-integer-overflow if it considered too noisy.

I think that is the most consistent beahviour. signed overflow is not UB
in the kernel.

> Although it did catch some real bugs.

If we want an over/under-flow checker, then that should be a separate
plugin and not specific to signed or unsigned.
