Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85B1DC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:34:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E903205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:34:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E903205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727838AbeKBCi3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 22:38:29 -0400
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53458 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727789AbeKBCi2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 22:38:28 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA1HXuJj136004
        for <linux-nfs@vger.kernel.org>; Thu, 1 Nov 2018 13:34:33 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ng49y4nh4-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 13:34:33 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 1 Nov 2018 17:34:32 -0000
Received: from b01cxnp22034.gho.pok.ibm.com (9.57.198.24)
        by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Thu, 1 Nov 2018 17:34:25 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
        by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id wA1HYOFA65601682
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Thu, 1 Nov 2018 17:34:24 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 8952DB2071;
        Thu,  1 Nov 2018 17:34:24 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 5C629B205F;
        Thu,  1 Nov 2018 17:34:24 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.141])
        by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
        Thu,  1 Nov 2018 17:34:24 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
        id AAFDA16C0292; Thu,  1 Nov 2018 10:34:24 -0700 (PDT)
Date:   Thu, 1 Nov 2018 10:34:24 -0700
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
References: <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <20181101170146.GQ4170@linux.ibm.com>
 <20181101171846.GI3178@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101171846.GI3178@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 18110117-0040-0000-0000-0000048AD9C2
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00009966; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000268; SDB=6.01111189; UDB=6.00575830; IPR=6.00891280;
 MB=3.00023993; MTD=3.00000008; XFM=3.00000015; UTC=2018-11-01 17:34:31
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 18110117-0041-0000-0000-00000893DA77
Message-Id: <20181101173424.GU4170@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2018-11-01_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=505 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1807170000 definitions=main-1811010149
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 06:18:46PM +0100, Peter Zijlstra wrote:
> On Thu, Nov 01, 2018 at 10:01:46AM -0700, Paul E. McKenney wrote:
> > On Thu, Nov 01, 2018 at 05:32:12PM +0100, Peter Zijlstra wrote:
> > > On Thu, Nov 01, 2018 at 03:22:15PM +0000, Trond Myklebust wrote:
> > > > On Thu, 2018-11-01 at 15:59 +0100, Peter Zijlstra wrote:
> > > > > On Thu, Nov 01, 2018 at 01:18:46PM +0000, Mark Rutland wrote:
> > > 
> > > > > > > My one question (and the reason why I went with cmpxchg() in the
> > > > > > > first place) would be about the overflow behaviour for
> > > > > > > atomic_fetch_inc() and friends. I believe those functions should
> > > > > > > be OK on x86, so that when we overflow the counter, it behaves
> > > > > > > like an unsigned value and wraps back around.  Is that the case
> > > > > > > for all architectures?
> > > > > > > 
> > > > > > > i.e. are atomic_t/atomic64_t always guaranteed to behave like
> > > > > > > u32/u64 on increment?
> > > > > > > 
> > > > > > > I could not find any documentation that explicitly stated that
> > > > > > > they should.
> > > > > > 
> > > > > > Peter, Will, I understand that the atomic_t/atomic64_t ops are
> > > > > > required to wrap per 2's-complement. IIUC the refcount code relies
> > > > > > on this.
> > > > > > 
> > > > > > Can you confirm?
> > > > > 
> > > > > There is quite a bit of core code that hard assumes 2s-complement.
> > > > > Not only for atomics but for any signed integer type. Also see the
> > > > > kernel using -fno-strict-overflow which implies -fwrapv, which
> > > > > defines signed overflow to behave like 2s-complement (and rids us of
> > > > > that particular UB).
> > > > 
> > > > Fair enough, but there have also been bugfixes to explicitly fix unsafe
> > > > C standards assumptions for signed integers. See, for instance commit
> > > > 5a581b367b5d "jiffies: Avoid undefined behavior from signed overflow"
> > > > from Paul McKenney.
> > > 
> > > Yes, I feel Paul has been to too many C/C++ committee meetings and got
> > > properly paranoid. Which isn't always a bad thing :-)
> > 
> > Even the C standard defines 2s complement for atomics.  
> 
> Ooh good to know.

Must be some mistake, right?  ;-)

> > Just not for
> > normal arithmetic, where yes, signed overflow is UB.  And yes, I do
> > know about -fwrapv, but I would like to avoid at least some copy-pasta
> > UB from my kernel code to who knows what user-mode environment.  :-/
> > 
> > At least where it is reasonably easy to do so.
> 
> Fair enough I suppose; I just always make sure to include the same
> -fknobs for the userspace thing when I lift code.

Agreed!  But when it is other people lifting the code...

> > And there is a push to define C++ signed arithmetic as 2s complement,
> > but there are still 1s complement systems with C compilers.  Just not
> > C++ compilers.  Legacy...
> 
> *groan*; how about those ancient hardwares keep using ancient compilers
> and we all move on to the 70s :-)

Hey!!!  Some of that 70s (and 60s!) 1s-complement hardware helped pay
my way through university the first time around!!!  ;-)

Though where it once filled a room it is now on a single small chip.
Go figure...

> > > But for us using -fno-strict-overflow which actually defines signed
> > > overflow, I myself am really not worried. I'm also not sure if KASAN has
> > > been taught about this, or if it will still (incorrectly) warn about UB
> > > for signed types.
> > 
> > UBSAN gave me a signed-overflow warning a few days ago.  Which I have
> > fixed, even though 2s complement did the right thing.  I am also taking
> > advantage of the change to use better naming.
> 
> Oh too many *SANs I suppose; and yes, if you can make the code better,
> why not.

Yeah, when INT_MIN was confined to a single function, no problem.
But thanks to the RCU flavor consolidation, it has to be spread out a
bit more...  Plus there is now INT_MAX, INT_MAX/2, ...

> > > > Anyhow, if the atomic maintainers are willing to stand up and state for
> > > > the record that the atomic counters are guaranteed to wrap modulo 2^n
> > > > just like unsigned integers, then I'm happy to take Paul's patch.
> > > 
> > > I myself am certainly relying on it.
> > 
> > Color me confused.  My 5a581b367b5d is from 2013.  Or is "Paul" instead
> > intended to mean Paul Mackerras, who happens to be on CC?
> 
> Paul Burton I think, on a part of the thread before we joined :-)

Couldn't be bothered to look up the earlier part of the thread.  Getting
lazy in my old age.  ;-)

							Thanx, Paul

