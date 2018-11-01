Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCEEFC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 22:26:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D84E204FD
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 22:26:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D84E204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726115AbeKBHbq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 03:31:46 -0400
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48742 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727645AbeKBHbp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 03:31:45 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wA1MNo8q129104
        for <linux-nfs@vger.kernel.org>; Thu, 1 Nov 2018 18:26:50 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ng7r46grf-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 18:26:49 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Thu, 1 Nov 2018 22:26:48 -0000
Received: from b01cxnp23032.gho.pok.ibm.com (9.57.198.27)
        by e13.ny.us.ibm.com (146.89.104.200) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Thu, 1 Nov 2018 22:26:41 -0000
Received: from b01ledav003.gho.pok.ibm.com (b01ledav003.gho.pok.ibm.com [9.57.199.108])
        by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id wA1MQf7i25100518
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Thu, 1 Nov 2018 22:26:41 GMT
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id EB775B205F;
        Thu,  1 Nov 2018 22:26:40 +0000 (GMT)
Received: from b01ledav003.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id B4B29B2064;
        Thu,  1 Nov 2018 22:26:40 +0000 (GMT)
Received: from paulmck-ThinkPad-W541 (unknown [9.70.82.141])
        by b01ledav003.gho.pok.ibm.com (Postfix) with ESMTP;
        Thu,  1 Nov 2018 22:26:40 +0000 (GMT)
Received: by paulmck-ThinkPad-W541 (Postfix, from userid 1000)
        id 3AAED16C0598; Thu,  1 Nov 2018 15:26:41 -0700 (PDT)
Date:   Thu, 1 Nov 2018 15:26:41 -0700
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
References: <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
 <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
 <20181101145926.GE3178@hirez.programming.kicks-ass.net>
 <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
 <20181101163212.GF3159@hirez.programming.kicks-ass.net>
 <b0160f4b-b996-b0ee-405a-3d5f1866272e@gmail.com>
 <20181101171432.GH3178@hirez.programming.kicks-ass.net>
 <20181101172739.GA3196@hirez.programming.kicks-ass.net>
 <20181101202910.GB4170@linux.ibm.com>
 <20181101213834.GA3339@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181101213834.GA3339@worktop.programming.kicks-ass.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-TM-AS-GCONF: 00
x-cbid: 18110122-0064-0000-0000-0000036C7196
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00009968; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000268; SDB=6.01111286; UDB=6.00575888; IPR=6.00891378;
 MB=3.00023997; MTD=3.00000008; XFM=3.00000015; UTC=2018-11-01 22:26:47
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 18110122-0065-0000-0000-00003B313D77
Message-Id: <20181101222641.GI4170@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2018-11-01_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=649 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1807170000 definitions=main-1811010187
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 10:38:34PM +0100, Peter Zijlstra wrote:
> On Thu, Nov 01, 2018 at 01:29:10PM -0700, Paul E. McKenney wrote:
> > On Thu, Nov 01, 2018 at 06:27:39PM +0100, Peter Zijlstra wrote:
> > > On Thu, Nov 01, 2018 at 06:14:32PM +0100, Peter Zijlstra wrote:
> > > > > This reminds me of this sooooo silly patch :/
> > > > > 
> > > > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=adb03115f4590baa280ddc440a8eff08a6be0cb7
> > > 
> > > You'd probably want to write it like so; +- some ordering stuff, that
> > > code didn't look like it really needs the memory barriers implied by
> > > these, but I didn't look too hard.
> > 
> > The atomic_fetch_add() API would need to be propagated out to the other
> > architectures, correct?
> 
> Like these commits I did like 2 years ago ? :-)

Color me blind and stupid!  ;-)

							Thanx, Paul

> $ git log --oneline 6dc25876cdb1...1f51dee7ca74
> 6dc25876cdb1 locking/atomic, arch/xtensa: Implement atomic_fetch_{add,sub,and,or,xor}()
> a8bcccaba162 locking/atomic, arch/x86: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> 1af5de9af138 locking/atomic, arch/tile: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> 3a1adb23a52c locking/atomic, arch/sparc: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> 7d9794e75237 locking/atomic, arch/sh: Implement atomic_fetch_{add,sub,and,or,xor}()
> 56fefbbc3f13 locking/atomic, arch/s390: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> a28cc7bbe8e3 locking/atomic, arch/powerpc: Implement atomic{,64}_fetch_{add,sub,and,or,xor}{,_relaxed,_acquire,_release}()
> e5857a6ed600 locking/atomic, arch/parisc: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> f8d638e28d7c locking/atomic, arch/mn10300: Implement atomic_fetch_{add,sub,and,or,xor}()
> 4edac529eb62 locking/atomic, arch/mips: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> e898eb27ffd8 locking/atomic, arch/metag: Implement atomic_fetch_{add,sub,and,or,xor}()
> e39d88ea3ce4 locking/atomic, arch/m68k: Implement atomic_fetch_{add,sub,and,or,xor}()
> f64937052303 locking/atomic, arch/m32r: Implement atomic_fetch_{add,sub,and,or,xor}()
> cc102507fac7 locking/atomic, arch/ia64: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> 4be7dd393515 locking/atomic, arch/hexagon: Implement atomic_fetch_{add,sub,and,or,xor}()
> 0c074cbc3309 locking/atomic, arch/h8300: Implement atomic_fetch_{add,sub,and,or,xor}()
> d9c730281617 locking/atomic, arch/frv: Implement atomic{,64}_fetch_{add,sub,and,or,xor}()
> e87fc0ec0705 locking/atomic, arch/blackfin: Implement atomic_fetch_{add,sub,and,or,xor}()
> 1a6eafacd481 locking/atomic, arch/avr32: Implement atomic_fetch_{add,sub,and,or,xor}()
> 2efe95fe6952 locking/atomic, arch/arm64: Implement atomic{,64}_fetch_{add,sub,and,andnot,or,xor}{,_relaxed,_acquire,_release}() for LSE instructions
> 6822a84dd4e3 locking/atomic, arch/arm64: Generate LSE non-return cases using common macros
> e490f9b1d3b4 locking/atomic, arch/arm64: Implement atomic{,64}_fetch_{add,sub,and,andnot,or,xor}{,_relaxed,_acquire,_release}()
> 6da068c1beba locking/atomic, arch/arm: Implement atomic{,64}_fetch_{add,sub,and,andnot,or,xor}{,_relaxed,_acquire,_release}()
> fbffe892e525 locking/atomic, arch/arc: Implement atomic_fetch_{add,sub,and,andnot,or,xor}()
> 

