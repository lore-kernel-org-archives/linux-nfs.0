Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31026 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdGEPLh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 11:11:37 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC] fix parallelism for rpc tasks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyHy=c6z4v5oTecSJMVpTe28CCVAkBQxj56iruJwetjHqQ@mail.gmail.com>
Date: Wed, 5 Jul 2017 11:11:26 -0400
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B944CE35-FC0A-461D-B43A-223B0CFDAD50@oracle.com>
References: <CAN-5tyEX1Z_3EB3h6=z_S1E=gpTObOrcP5Ub2HmVKBB5RaU1DQ@mail.gmail.com> <1499093918.79205.3.camel@primarydata.com> <CAN-5tyHy=c6z4v5oTecSJMVpTe28CCVAkBQxj56iruJwetjHqQ@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 5, 2017, at 10:44 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> 
> On Mon, Jul 3, 2017 at 10:58 AM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>> On Thu, 2017-06-29 at 09:25 -0400, Olga Kornievskaia wrote:
>>> Hi folks,
>>> 
>>> On a multi-core machine, is it expected that we can have parallel
>>> RPCs
>>> handled by each of the per-core workqueue?
>>> 
>>> In testing a read workload, observing via "top" command that a single
>>> "kworker" thread is running servicing the requests (no parallelism).
>>> It's more prominent while doing these operations over krb5p mount.
>>> 
>>> What has been suggested by Bruce is to try this and in my testing I
>>> see then the read workload spread among all the kworker threads.
>>> 
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> 
>>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>>> index 0cc8383..f80e688 100644
>>> --- a/net/sunrpc/sched.c
>>> +++ b/net/sunrpc/sched.c
>>> @@ -1095,7 +1095,7 @@ static int rpciod_start(void)
>>>  * Create the rpciod thread and wait for it to start.
>>>  */
>>>  dprintk("RPC:       creating workqueue rpciod\n");
>>> - wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 0);
>>> + wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
>>>  if (!wq)
>>>  goto out_failed;
>>>  rpciod_workqueue = wq;
>>> 
>> 
>> WQ_UNBOUND turns off concurrency management on the thread pool (See
>> Documentation/core-api/workqueue.rst. It also means we contend for work
>> item queuing/dequeuing locks, since the threads which run the work
>> items are not bound to a CPU.
>> 
>> IOW: This is not a slam-dunk obvious gain.
> 
> I agree but I think it's worth consideration. I'm waiting to get
> (real) performance numbers of improvement (instead of my VM setup) to
> help my case. However, it was reported 90% degradation for the read
> performance over krb5p when 1CPU is executing all ops.
> 
> Is there a different way to make sure that on a multi-processor
> machine we can take advantage of all available CPUs? Simple kernel
> threads instead of a work queue?

There is a trade-off between spreading the work, and ensuring it
is executed on a CPU close to the I/O and application. IMO UNBOUND
is a good way to do that. UNBOUND will attempt to schedule the
work on the preferred CPU, but allow it to be migrated if that
CPU is busy.

The advantage of this is that when the client workload is CPU
intensive (say, a software build), RPC client work can be scheduled
and run more quickly, which reduces latency.


> Can/should we have an WQ_UNBOUND work queue for secure mounts and
> another queue for other mounts?
> 
> While I wouldn't call krb5 load long running, Documentation says that
> an example for WQ_UNBOUND is for CPU intensive workloads. And also in
> general "work items are not expected to hog a CPU and consume many
> cycles". How "many" is too "many". How many operations are crypto
> operations?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



