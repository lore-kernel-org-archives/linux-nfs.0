Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33346 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdGERdL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 13:33:11 -0400
Received: by mail-qk0-f193.google.com with SMTP id p21so32175001qke.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Jul 2017 10:33:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1499271287.10445.1.camel@primarydata.com>
References: <CAN-5tyEX1Z_3EB3h6=z_S1E=gpTObOrcP5Ub2HmVKBB5RaU1DQ@mail.gmail.com>
 <1499093918.79205.3.camel@primarydata.com> <CAN-5tyHy=c6z4v5oTecSJMVpTe28CCVAkBQxj56iruJwetjHqQ@mail.gmail.com>
 <B944CE35-FC0A-461D-B43A-223B0CFDAD50@oracle.com> <1499269592.6496.1.camel@primarydata.com>
 <CAN-5tyHaT_j+fNPVbYzBLUh5_jbFxhFDVP+eby=Mf25V=JtpBw@mail.gmail.com> <1499271287.10445.1.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 5 Jul 2017 13:33:09 -0400
Message-ID: <CAN-5tyFeN3cUCi8u8VnHAQmGD=GE5+3ox-dyLrSdL52L4Lfrng@mail.gmail.com>
Subject: Re: [RFC] fix parallelism for rpc tasks
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 5, 2017 at 12:14 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Wed, 2017-07-05 at 12:09 -0400, Olga Kornievskaia wrote:
>> On Wed, Jul 5, 2017 at 11:46 AM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>> > On Wed, 2017-07-05 at 11:11 -0400, Chuck Lever wrote:
>> > > > On Jul 5, 2017, at 10:44 AM, Olga Kornievskaia <aglo@umich.edu>
>> > > > wrote:
>> > > >
>> > > > On Mon, Jul 3, 2017 at 10:58 AM, Trond Myklebust
>> > > > <trondmy@primarydata.com> wrote:
>> > > > > On Thu, 2017-06-29 at 09:25 -0400, Olga Kornievskaia wrote:
>> > > > > > Hi folks,
>> > > > > >
>> > > > > > On a multi-core machine, is it expected that we can have
>> > > > > > parallel
>> > > > > > RPCs
>> > > > > > handled by each of the per-core workqueue?
>> > > > > >
>> > > > > > In testing a read workload, observing via "top" command
>> > > > > > that a
>> > > > > > single
>> > > > > > "kworker" thread is running servicing the requests (no
>> > > > > > parallelism).
>> > > > > > It's more prominent while doing these operations over krb5p
>> > > > > > mount.
>> > > > > >
>> > > > > > What has been suggested by Bruce is to try this and in my
>> > > > > > testing I
>> > > > > > see then the read workload spread among all the kworker
>> > > > > > threads.
>> > > > > >
>> > > > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> > > > > >
>> > > > > > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> > > > > > index 0cc8383..f80e688 100644
>> > > > > > --- a/net/sunrpc/sched.c
>> > > > > > +++ b/net/sunrpc/sched.c
>> > > > > > @@ -1095,7 +1095,7 @@ static int rpciod_start(void)
>> > > > > >  * Create the rpciod thread and wait for it to start.
>> > > > > >  */
>> > > > > >  dprintk("RPC:       creating workqueue rpciod\n");
>> > > > > > - wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 0);
>> > > > > > + wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM |
>> > > > > > WQ_UNBOUND,
>> > > > > > 0);
>> > > > > >  if (!wq)
>> > > > > >  goto out_failed;
>> > > > > >  rpciod_workqueue = wq;
>> > > > > >
>> > > > >
>> > > > > WQ_UNBOUND turns off concurrency management on the thread
>> > > > > pool
>> > > > > (See
>> > > > > Documentation/core-api/workqueue.rst. It also means we
>> > > > > contend
>> > > > > for work
>> > > > > item queuing/dequeuing locks, since the threads which run the
>> > > > > work
>> > > > > items are not bound to a CPU.
>> > > > >
>> > > > > IOW: This is not a slam-dunk obvious gain.
>> > > >
>> > > > I agree but I think it's worth consideration. I'm waiting to
>> > > > get
>> > > > (real) performance numbers of improvement (instead of my VM
>> > > > setup)
>> > > > to
>> > > > help my case. However, it was reported 90% degradation for the
>> > > > read
>> > > > performance over krb5p when 1CPU is executing all ops.
>> > > >
>> > > > Is there a different way to make sure that on a multi-processor
>> > > > machine we can take advantage of all available CPUs? Simple
>> > > > kernel
>> > > > threads instead of a work queue?
>> > >
>> > > There is a trade-off between spreading the work, and ensuring it
>> > > is executed on a CPU close to the I/O and application. IMO
>> > > UNBOUND
>> > > is a good way to do that. UNBOUND will attempt to schedule the
>> > > work on the preferred CPU, but allow it to be migrated if that
>> > > CPU is busy.
>> > >
>> > > The advantage of this is that when the client workload is CPU
>> > > intensive (say, a software build), RPC client work can be
>> > > scheduled
>> > > and run more quickly, which reduces latency.
>> > >
>> >
>> > That should no longer be a huge issue, since queue_work() will now
>> > default to the WORK_CPU_UNBOUND flag, which prefers the local CPU,
>> > but
>> > will schedule elsewhere if the local CPU is congested.
>>
>> I don't believe NFS use workqueue_congested() to somehow schedule the
>> work elsewhere. Unless the queue is marked UNBOUNDED I don't believe
>> there is any intention of balancing the CPU load.
>>
>
> I shouldn't have to test the queue when scheduling with
> WORK_CPU_UNBOUND.
>

Comments in the code says that "if CPU dies" it'll be re-scheduled on
another. I think the code requires to mark the queue UNBOUND to really
be scheduled on a different CPU. Just my reading of the code and it
matches what is seen with the krb5 workload.
