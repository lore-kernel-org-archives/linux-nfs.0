Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB6DCC6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:29:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC115205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:29:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC115205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727722AbeKBFd6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:33:58 -0400
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34976 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727734AbeKBFdw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 01:33:52 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA1KT6Y5107342
        for <linux-nfs@vger.kernel.org>; Thu, 1 Nov 2018 16:29:21 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2ng7d5tymf-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 16:29:20 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 1 Nov 2018 20:29:19 -0000
Received: from b01cxnp22033.gho.pok.ibm.com (9.57.198.23)
        by e17.ny.us.ibm.com (146.89.104.204) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Thu, 1 Nov 2018 20:29:11 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
        by b01cxnp22033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id wA1KTAJJ46071974
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Thu, 1 Nov 2018 20:29:10 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id AE47AB2067;
        Thu,  1 Nov 2018 20:29:10 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 8B88EB205F;
        Thu,  1 Nov 2018 20:29:10 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.141])
        by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
        Thu,  1 Nov 2018 20:29:10 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
        id 02B6B16C3799; Thu,  1 Nov 2018 13:29:10 -0700 (PDT)
Date:   Thu, 1 Nov 2018 13:29:10 -0700
From:   "Paul E. McKenney" <paulmck@linux.ibm.com>
To:     Peter Zijlstra <peterz@infradead.org>
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
Reply-To: paulmck@linux.ibm.com
References: <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <b0160f4b-b996-b0ee-405a-3d5f1866272e@gmail.com>
 <20181101171432.GH3178@hirez.programming.kicks-ass.net>
 <20181101172739.GA3196@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101172739.GA3196@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 18110120-0040-0000-0000-0000048AF53A
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00009967; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000268; SDB=6.01111247; UDB=6.00575865; IPR=6.00891339;
 MB=3.00023995; MTD=3.00000008; XFM=3.00000015; UTC=2018-11-01 20:29:17
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 18110120-0041-0000-0000-00000893F604
Message-Id: <20181101202910.GB4170@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2018-11-01_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=795 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1807170000 definitions=main-1811010171
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 06:27:39PM +0100, Peter Zijlstra wrote:
> On Thu, Nov 01, 2018 at 06:14:32PM +0100, Peter Zijlstra wrote:
> > > This reminds me of this sooooo silly patch :/
> > > 
> > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=adb03115f4590baa280ddc440a8eff08a6be0cb7
> 
> You'd probably want to write it like so; +- some ordering stuff, that
> code didn't look like it really needs the memory barriers implied by
> these, but I didn't look too hard.

The atomic_fetch_add() API would need to be propagated out to the other
architectures, correct?

							Thanx, Paul

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index c0a9d26c06ce..11deb1d7e96b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -485,16 +485,10 @@ u32 ip_idents_reserve(u32 hash, int segs)
>  	u32 now = (u32)jiffies;
>  	u32 new, delta = 0;
> 
> -	if (old != now && cmpxchg(p_tstamp, old, now) == old)
> +	if (old != now && try_cmpxchg(p_tstamp, &old, now))
>  		delta = prandom_u32_max(now - old);
> 
> -	/* Do not use atomic_add_return() as it makes UBSAN unhappy */
> -	do {
> -		old = (u32)atomic_read(p_id);
> -		new = old + delta + segs;
> -	} while (atomic_cmpxchg(p_id, old, new) != old);
> -
> -	return new - segs;
> +	return atomic_fetch_add(segs + delta, p_id) + delta;
>  }
>  EXPORT_SYMBOL(ip_idents_reserve);
> 
> 

