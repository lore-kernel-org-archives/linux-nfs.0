Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F1F1C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 21:40:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0C83720657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 21:40:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eSYq8oli"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C83720657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726363AbeKBGov (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 02:44:51 -0400
Received: from merlin.infradead.org ([205.233.59.134]:56988 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726701AbeKBGov (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 02:44:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=fJNe5Xh2vBtwfNg51MvYtBkChDHBfibLaKDhcAYFpnw=; b=eSYq8oliMMglqA58wMET6Qr2k
        2ywznbVYZX0/FMpfVY7rqbvHdOwKrEbrOBNY+KXXY/Uhk8V2SOE4KXD4eq45Wd8MfIjDm2c5k0etd
        0h7KUpnjwHu1PG3njA1oSmutQEjm3D+iTJUzUdKZIiqhuJgB0dnqoazOSttG3+xqmZAxJE6wf7Ma8
        y6+FSA6rxxofN1LP2SX8mk895sHvFhuyN54y20OvlfNawkBI1ratjWlgaNbgNR14YFoCV9c4PrWPS
        dvp23cp3f01zFUJ4O7LlLpRthqfOhhVhWfzw+4ZwRd95Crad7YaTNzUoTsmNjBwdoREY+QPNr89bX
        hv0THCWaQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=worktop)
        by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gIKfl-00074t-Jj; Thu, 01 Nov 2018 21:38:38 +0000
Received: by worktop (Postfix, from userid 1000)
        id 2ADB86E07D9; Thu,  1 Nov 2018 22:38:34 +0100 (CET)
Date:   Thu, 1 Nov 2018 22:38:34 +0100
From:   Peter Zijlstra <peterz@infradead.org>
To:     "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc:     Eric Dumazet <eric.dumazet@gmail.com>,
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
        aryabinin@virtuozzo.com, dvyukov@google.com
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181101213834.GA3339@worktop.programming.kicks-ass.net>
References: <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <b0160f4b-b996-b0ee-405a-3d5f1866272e@gmail.com>
 <20181101171432.GH3178@hirez.programming.kicks-ass.net>
 <20181101172739.GA3196@hirez.programming.kicks-ass.net>
 <20181101202910.GB4170@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101202910.GB4170@linux.ibm.com>
User-Agent: Mutt/1.5.22.1 (2013-10-16)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 01:29:10PM -0700, Paul E. McKenney wrote:
> On Thu, Nov 01, 2018 at 06:27:39PM +0100, Peter Zijlstra wrote:
> > On Thu, Nov 01, 2018 at 06:14:32PM +0100, Peter Zijlstra wrote:
> > > > This reminds me of this sooooo silly patch :/
> > > > 
> > > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=adb03115f4590baa280ddc440a8eff08a6be0cb7
> > 
> > You'd probably want to write it like so; +- some ordering stuff, that
> > code didn't look like it really needs the memory barriers implied by
> > these, but I didn't look too hard.
> 
> The atomic_fetch_add() API would need to be propagated out to the other
> architectures, correct?

Like these commits I did like 2 years ago ? :-)

$ git log --oneline 6dc25876cdb1...1f51dee7ca74
6dc25876cdb1 locking/atomic, arch/xtensa: Implement atomic_fetch_{add,sub,and,or,xor}()
a8bcccaba162 locking/atomic, arch/x86: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
1af5de9af138 locking/atomic, arch/tile: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
3a1adb23a52c locking/atomic, arch/sparc: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
7d9794e75237 locking/atomic, arch/sh: Implement atomic_fetch_{add,sub,and,or,xor}()
56fefbbc3f13 locking/atomic, arch/s390: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
a28cc7bbe8e3 locking/atomic, arch/powerpc: Implement atomic{,64}_fetch_{add,sub,and,or,xor}{,_relaxed,_acquire,_release}()
e5857a6ed600 locking/atomic, arch/parisc: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
f8d638e28d7c locking/atomic, arch/mn10300: Implement atomic_fetch_{add,sub,and,or,xor}()
4edac529eb62 locking/atomic, arch/mips: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
e898eb27ffd8 locking/atomic, arch/metag: Implement atomic_fetch_{add,sub,and,or,xor}()
e39d88ea3ce4 locking/atomic, arch/m68k: Implement atomic_fetch_{add,sub,and,or,xor}()
f64937052303 locking/atomic, arch/m32r: Implement atomic_fetch_{add,sub,and,or,xor}()
cc102507fac7 locking/atomic, arch/ia64: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
4be7dd393515 locking/atomic, arch/hexagon: Implement atomic_fetch_{add,sub,and,or,xor}()
0c074cbc3309 locking/atomic, arch/h8300: Implement atomic_fetch_{add,sub,and,or,xor}()
d9c730281617 locking/atomic, arch/frv: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
e87fc0ec0705 locking/atomic, arch/blackfin: Implement atomic_fetch_{add,sub,and,or,xor}()
1a6eafacd481 locking/atomic, arch/avr32: Implement atomic_fetch_{add,sub,and,or,xor}()
2efe95fe6952 locking/atomic, arch/arm64: Implement atomic{,64}_fetch_{add,sub,and,andnot,or,xor}{,_relaxed,_acquire,_release}() for LSE instructions
6822a84dd4e3 locking/atomic, arch/arm64: Generate LSE non-return cases using common macros
e490f9b1d3b4 locking/atomic, arch/arm64: Implement atomic{,64}_fetch_{add,sub,and,andnot,or,xor}{,_relaxed,_acquire,_release}()
6da068c1beba locking/atomic, arch/arm: Implement atomic{,64}_fetch_{add,sub,and,andnot,or,xor}{,_relaxed,_acquire,_release}()
fbffe892e525 locking/atomic, arch/arc: Implement atomic_fetch_{add,sub,and,andnot,or,xor}()
