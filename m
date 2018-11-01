Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACD09C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:01:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F06B2081B
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:01:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F06B2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726042AbeKBCFq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 22:05:46 -0400
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47762 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725843AbeKBCFp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 22:05:45 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA1GsOee124146
        for <linux-nfs@vger.kernel.org>; Thu, 1 Nov 2018 13:01:56 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ng3byx5c5-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 13:01:55 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 1 Nov 2018 17:01:55 -0000
Received: from b01cxnp22034.gho.pok.ibm.com (9.57.198.24)
        by e12.ny.us.ibm.com (146.89.104.199) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Thu, 1 Nov 2018 17:01:47 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
        by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id wA1H1krW4850004
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Thu, 1 Nov 2018 17:01:46 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 0BFDCB205F;
        Thu,  1 Nov 2018 17:01:46 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id BFFE2B2068;
        Thu,  1 Nov 2018 17:01:45 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.141])
        by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
        Thu,  1 Nov 2018 17:01:45 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
        id 1304B16C36E4; Thu,  1 Nov 2018 10:01:46 -0700 (PDT)
Date:   Thu, 1 Nov 2018 10:01:46 -0700
From:   "Paul E. McKenney" <paulmck@linux.ibm.com>
To:     Peter Zijlstra <peterz@infradead.org>
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
        aryabinin@virtuozzo.com, dvyukov@google.com
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Reply-To: paulmck@linux.ibm.com
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101163212.GF3159@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 18110117-0060-0000-0000-000002CB422C
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00009966; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000268; SDB=6.01111178; UDB=6.00575823; IPR=6.00891269;
 MB=3.00023993; MTD=3.00000008; XFM=3.00000015; UTC=2018-11-01 17:01:53
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 18110117-0061-0000-0000-0000470D8E3E
Message-Id: <20181101170146.GQ4170@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2018-11-01_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=588 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1807170000 definitions=main-1811010144
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 05:32:12PM +0100, Peter Zijlstra wrote:
> On Thu, Nov 01, 2018 at 03:22:15PM +0000, Trond Myklebust wrote:
> > On Thu, 2018-11-01 at 15:59 +0100, Peter Zijlstra wrote:
> > > On Thu, Nov 01, 2018 at 01:18:46PM +0000, Mark Rutland wrote:
> 
> > > > > My one question (and the reason why I went with cmpxchg() in the
> > > > > first place) would be about the overflow behaviour for
> > > > > atomic_fetch_inc() and friends. I believe those functions should
> > > > > be OK on x86, so that when we overflow the counter, it behaves
> > > > > like an unsigned value and wraps back around.  Is that the case
> > > > > for all architectures?
> > > > > 
> > > > > i.e. are atomic_t/atomic64_t always guaranteed to behave like
> > > > > u32/u64 on increment?
> > > > > 
> > > > > I could not find any documentation that explicitly stated that
> > > > > they should.
> > > > 
> > > > Peter, Will, I understand that the atomic_t/atomic64_t ops are
> > > > required to wrap per 2's-complement. IIUC the refcount code relies
> > > > on this.
> > > > 
> > > > Can you confirm?
> > > 
> > > There is quite a bit of core code that hard assumes 2s-complement.
> > > Not only for atomics but for any signed integer type. Also see the
> > > kernel using -fno-strict-overflow which implies -fwrapv, which
> > > defines signed overflow to behave like 2s-complement (and rids us of
> > > that particular UB).
> > 
> > Fair enough, but there have also been bugfixes to explicitly fix unsafe
> > C standards assumptions for signed integers. See, for instance commit
> > 5a581b367b5d "jiffies: Avoid undefined behavior from signed overflow"
> > from Paul McKenney.
> 
> Yes, I feel Paul has been to too many C/C++ committee meetings and got
> properly paranoid. Which isn't always a bad thing :-)

Even the C standard defines 2s complement for atomics.  Just not for
normal arithmetic, where yes, signed overflow is UB.  And yes, I do
know about -fwrapv, but I would like to avoid at least some copy-pasta
UB from my kernel code to who knows what user-mode environment.  :-/

At least where it is reasonably easy to do so.

And there is a push to define C++ signed arithmetic as 2s complement,
but there are still 1s complement systems with C compilers.  Just not
C++ compilers.  Legacy...

> But for us using -fno-strict-overflow which actually defines signed
> overflow, I myself am really not worried. I'm also not sure if KASAN has
> been taught about this, or if it will still (incorrectly) warn about UB
> for signed types.

UBSAN gave me a signed-overflow warning a few days ago.  Which I have
fixed, even though 2s complement did the right thing.  I am also taking
advantage of the change to use better naming.

> > Anyhow, if the atomic maintainers are willing to stand up and state for
> > the record that the atomic counters are guaranteed to wrap modulo 2^n
> > just like unsigned integers, then I'm happy to take Paul's patch.
> 
> I myself am certainly relying on it.

Color me confused.  My 5a581b367b5d is from 2013.  Or is "Paul" instead
intended to mean Paul Mackerras, who happens to be on CC?

							Thanx, Paul

