Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:32533 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbA0CaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2015 21:30:09 -0500
Message-ID: <54C6F82C.2020700@oracle.com>
Date: Mon, 26 Jan 2015 18:30:04 -0800
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] SUNRPC: Adjust rpciod workqueue parameters
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>	<54C6CEDD.40808@oracle.com> <CAHQdGtThFmpoSxp00p1OeL7mTuUqSmLL8Th2u4bd9uFrehEXNg@mail.gmail.com>
In-Reply-To: <CAHQdGtThFmpoSxp00p1OeL7mTuUqSmLL8Th2u4bd9uFrehEXNg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2015 04:34 PM, Trond Myklebust wrote:
> On Mon, Jan 26, 2015 at 6:33 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
>> Hello Trond,
>>
>> workqueue WQ_UNBOUND flag is also needed. Some customer hit a problem, RT thread caused rpciod starvation. It is easy to reproduce it with running a cpu intensive workload with lower nice value than rpciod workqueue on the cpu the network interrupt is received.
>>
>> I've also tested iozone and fio test with WQ_UNBOUND|WQ_SYSFS flag on for NFS/RDMA, NFS/IPoIB. The results are better than BOUND.
> 
> It certainly does not seem appropriate to use WQ_SYSFS on a queue that
> is used for swap, and Documentation/kernel-per-CPU-kthreads.txt makes
> an extra strong argument against enabling it on the grounds that it is
> not easily reversible.

If enabling UNBOUND, I thought customizing workqueue would help. 

> As for unbound queues: they will almost by definition defeat all the
> packet steering and balancing that is done in the networking layer in
> the name of multi-process scalability (see
> Documentation/networking/scaling.txt). While RDMA systems may or may
> not care about that, ordinary networked systems probably do.
> Don't most RDMA drivers allow you to balance those interrupts, at
> least on the high end systems?

The problem was IRQ balance is not aware of which cpu is busy on the system, networking NIC interrupts can be directed to the busy CPU while other cpus are much lightly loaded. So packet steering and balancing in the networking layer doesn't have any benefit. The network workload can cause starvation in this situation it doesn't matter it's RDMA or Ethernet. The workaround solution is to unmask this busy cpu in irq balance, or manually set up irq smp affinity to avoid any interrupts on this cpu.

UNBOUND workqueue will choose same CPU to run the work if this CPU is not busy, it is scheduled to another CPU on the same NUMA node when this CPU is busy. So it doesn't defeat packet steering and balancing.  

> 
>> Thanks,
>> Shirley
>>
>> On 01/24/2015 04:18 PM, Trond Myklebust wrote:
>>> Increase the concurrency level for rpciod threads to allow for allocations
>>> etc that happen in the RPCSEC_GSS layer. Also note that the NFSv4 byte range
>>> locks may now need to allocate memory from inside rpciod.
>>>
>>> Add the WQ_HIGHPRI flag to improve latency guarantees while we're at it.
>>>
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>>  net/sunrpc/sched.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>>> index d20f2329eea3..4f65ec28d2b4 100644
>>> --- a/net/sunrpc/sched.c
>>> +++ b/net/sunrpc/sched.c
>>> @@ -1069,7 +1069,8 @@ static int rpciod_start(void)
>>>        * Create the rpciod thread and wait for it to start.
>>>        */
>>>       dprintk("RPC:       creating workqueue rpciod\n");
>>> -     wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 1);
>>> +     /* Note: highpri because network receive is latency sensitive */
>>> +     wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
>>>       rpciod_workqueue = wq;
>>>       return rpciod_workqueue != NULL;
>>>  }
>>>
> 
> 
> 
