Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33443 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdGEOoe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 10:44:34 -0400
Received: by mail-qt0-f195.google.com with SMTP id c20so30823327qte.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Jul 2017 07:44:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1499093918.79205.3.camel@primarydata.com>
References: <CAN-5tyEX1Z_3EB3h6=z_S1E=gpTObOrcP5Ub2HmVKBB5RaU1DQ@mail.gmail.com>
 <1499093918.79205.3.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 5 Jul 2017 10:44:33 -0400
Message-ID: <CAN-5tyHy=c6z4v5oTecSJMVpTe28CCVAkBQxj56iruJwetjHqQ@mail.gmail.com>
Subject: Re: [RFC] fix parallelism for rpc tasks
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 3, 2017 at 10:58 AM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Thu, 2017-06-29 at 09:25 -0400, Olga Kornievskaia wrote:
>> Hi folks,
>>
>> On a multi-core machine, is it expected that we can have parallel
>> RPCs
>> handled by each of the per-core workqueue?
>>
>> In testing a read workload, observing via "top" command that a single
>> "kworker" thread is running servicing the requests (no parallelism).
>> It's more prominent while doing these operations over krb5p mount.
>>
>> What has been suggested by Bruce is to try this and in my testing I
>> see then the read workload spread among all the kworker threads.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index 0cc8383..f80e688 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -1095,7 +1095,7 @@ static int rpciod_start(void)
>>   * Create the rpciod thread and wait for it to start.
>>   */
>>   dprintk("RPC:       creating workqueue rpciod\n");
>> - wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 0);
>> + wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
>>   if (!wq)
>>   goto out_failed;
>>   rpciod_workqueue = wq;
>>
>
> WQ_UNBOUND turns off concurrency management on the thread pool (See
> Documentation/core-api/workqueue.rst. It also means we contend for work
> item queuing/dequeuing locks, since the threads which run the work
> items are not bound to a CPU.
>
> IOW: This is not a slam-dunk obvious gain.

I agree but I think it's worth consideration. I'm waiting to get
(real) performance numbers of improvement (instead of my VM setup) to
help my case. However, it was reported 90% degradation for the read
performance over krb5p when 1CPU is executing all ops.

Is there a different way to make sure that on a multi-processor
machine we can take advantage of all available CPUs? Simple kernel
threads instead of a work queue?

Can/should we have an WQ_UNBOUND work queue for secure mounts and
another queue for other mounts?

While I wouldn't call krb5 load long running, Documentation says that
an example for WQ_UNBOUND is for CPU intensive workloads. And also in
general "work items are not expected to hog a CPU and consume many
cycles". How "many" is too "many". How many operations are crypto
operations?
