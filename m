Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33579 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161133AbaDPPX1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 11:23:27 -0400
Received: by mail-wg0-f46.google.com with SMTP id b13so11188625wgh.5
        for <linux-nfs@vger.kernel.org>; Wed, 16 Apr 2014 08:23:26 -0700 (PDT)
Message-ID: <534EA06A.7090200@dev.mellanox.co.il>
Date: Wed, 16 Apr 2014 18:23:22 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 7/8] xprtrdma: Split the completion queue
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <20140414222323.20646.66946.stgit@manet.1015granger.net> <534E7C1C.5070407@dev.mellanox.co.il> <534E8608.8030801@opengridcomputing.com> <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com>
In-Reply-To: <E9B601B5-1984-40D8-914A-DDD1380E8183@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/16/2014 6:08 PM, Chuck Lever wrote:
> Hi Sagi-
>
> Thanks for the review! In-line replies below.
<SNIP>
>
>>> 2. If I understood correctly, I see that the CQs are loop-polled in an interrupt context.
>>>     This may become problematic in stress workload where the CQ simply never drains (imagine
>>>     some studios task keeps posting WRs as soon as IOs complete). This will cause CQ poll loop
>>>     to go on forever. This situation may cause starvation of other CQs that share the same EQ (CPU
>>>     is hogged by the endless poller).
>>>     This may be solved in 2 ways:
>>>     - Use blk-iopoll to maintain fairness - the downside will be moving from interrupt context to soft-irq (slower).
>>>     - Set some configurable budget to CQ poller - after finishing the budget, notify the CQ and bail.
>>>       If there is another CQ waiting to get in - it's only fair that it will be given with a chance, else another interrupt
>>>       on that CQ will immediately come.
> I think it would be a reasonable change to pass an array of WC’s to
> ib_poll_cq() just once in rpcrdma_{send,recv}cq_poll(), instead of
> looping. Would that be enough?
>
> To be clear, my patch merely cleans up the completion handler logic,
> which already did loop-polling. Should we consider this improvement
> for another patch?

Well, I wasn't suggesting passing an array, carrying it around (or on 
the stack for that manner) might be annoying...
I was suggesting a budget (poll loops or a time bound - jiffy is usually 
well behaved).

Sagi.
