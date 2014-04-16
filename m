Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28175 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaDPSVy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 14:21:54 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <534EA06A.7090200@dev.mellanox.co.il>
Date: Wed, 16 Apr 2014 14:21:33 -0400
Cc: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <FC61F219-ACA2-4CE8-BF02-1B8EE2464639@oracle.com>
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com> <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com> <534EA06A.7090200@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 16, 2014, at 11:23 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:

> On 4/16/2014 6:08 PM, Chuck Lever wrote:
>> Hi Sagi-
>> 
>> Thanks for the review! In-line replies below.
> <SNIP>
>> 
>>>> 2. If I understood correctly, I see that the CQs are loop-polled in an interrupt context.
>>>>    This may become problematic in stress workload where the CQ simply never drains (imagine
>>>>    some studios task keeps posting WRs as soon as IOs complete). This will cause CQ poll loop
>>>>    to go on forever. This situation may cause starvation of other CQs that share the same EQ (CPU
>>>>    is hogged by the endless poller).
>>>>    This may be solved in 2 ways:
>>>>    - Use blk-iopoll to maintain fairness - the downside will be moving from interrupt context to soft-irq (slower).
>>>>    - Set some configurable budget to CQ poller - after finishing the budget, notify the CQ and bail.
>>>>      If there is another CQ waiting to get in - it's only fair that it will be given with a chance, else another interrupt
>>>>      on that CQ will immediately come.
>> I think it would be a reasonable change to pass an array of WC’s to
>> ib_poll_cq() just once in rpcrdma_{send,recv}cq_poll(), instead of
>> looping. Would that be enough?
>> 
>> To be clear, my patch merely cleans up the completion handler logic,
>> which already did loop-polling. Should we consider this improvement
>> for another patch?
> 
> Well, I wasn't suggesting passing an array, carrying it around (or on the stack for that manner) might be annoying...
> I was suggesting a budget (poll loops or a time bound - jiffy is usually well behaved).

Passing a small array to ip_poll_cq() is actually easy to do, and is
exactly equivalent to a poll budget. The struct ib_wc should be taken
off the stack anyway, IMO.

The only other example I see in 3.15 right now is IPoIB, which seems
to do exactly this.

I’m testing a patch now. I’d like to start simple and make it more
complex only if we need to.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



