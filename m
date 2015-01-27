Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:47230 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756442AbbA0AeV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2015 19:34:21 -0500
Received: by mail-vc0-f179.google.com with SMTP id la4so3833001vcb.10
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2015 16:34:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54C6CEDD.40808@oracle.com>
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
	<54C6CEDD.40808@oracle.com>
Date: Mon, 26 Jan 2015 19:34:20 -0500
Message-ID: <CAHQdGtThFmpoSxp00p1OeL7mTuUqSmLL8Th2u4bd9uFrehEXNg@mail.gmail.com>
Subject: Re: [PATCH 1/2] SUNRPC: Adjust rpciod workqueue parameters
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 26, 2015 at 6:33 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
> Hello Trond,
>
> workqueue WQ_UNBOUND flag is also needed. Some customer hit a problem, RT thread caused rpciod starvation. It is easy to reproduce it with running a cpu intensive workload with lower nice value than rpciod workqueue on the cpu the network interrupt is received.
>
> I've also tested iozone and fio test with WQ_UNBOUND|WQ_SYSFS flag on for NFS/RDMA, NFS/IPoIB. The results are better than BOUND.

It certainly does not seem appropriate to use WQ_SYSFS on a queue that
is used for swap, and Documentation/kernel-per-CPU-kthreads.txt makes
an extra strong argument against enabling it on the grounds that it is
not easily reversible.

As for unbound queues: they will almost by definition defeat all the
packet steering and balancing that is done in the networking layer in
the name of multi-process scalability (see
Documentation/networking/scaling.txt). While RDMA systems may or may
not care about that, ordinary networked systems probably do.
Don't most RDMA drivers allow you to balance those interrupts, at
least on the high end systems?


> Thanks,
> Shirley
>
> On 01/24/2015 04:18 PM, Trond Myklebust wrote:
>> Increase the concurrency level for rpciod threads to allow for allocations
>> etc that happen in the RPCSEC_GSS layer. Also note that the NFSv4 byte range
>> locks may now need to allocate memory from inside rpciod.
>>
>> Add the WQ_HIGHPRI flag to improve latency guarantees while we're at it.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/sched.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index d20f2329eea3..4f65ec28d2b4 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -1069,7 +1069,8 @@ static int rpciod_start(void)
>>        * Create the rpciod thread and wait for it to start.
>>        */
>>       dprintk("RPC:       creating workqueue rpciod\n");
>> -     wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 1);
>> +     /* Note: highpri because network receive is latency sensitive */
>> +     wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_HIGHPRI, 0);
>>       rpciod_workqueue = wq;
>>       return rpciod_workqueue != NULL;
>>  }
>>



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
