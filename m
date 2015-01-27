Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:62098 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbA0GeO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jan 2015 01:34:14 -0500
Received: by mail-vc0-f182.google.com with SMTP id kv19so4144620vcb.13
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2015 22:34:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54C72E17.5090201@oracle.com>
References: <1422145127-81838-1-git-send-email-trond.myklebust@primarydata.com>
	<54C6CEDD.40808@oracle.com>
	<CAHQdGtThFmpoSxp00p1OeL7mTuUqSmLL8Th2u4bd9uFrehEXNg@mail.gmail.com>
	<54C6F82C.2020700@oracle.com>
	<CAHQdGtTVBtLTWu54Vfwx6CSUOTEBRo_Ep+=ENz787pypQRhWfw@mail.gmail.com>
	<54C72E17.5090201@oracle.com>
Date: Tue, 27 Jan 2015 01:34:13 -0500
Message-ID: <CAHQdGtT7j33hJqZ6OaUJrJ5fhr4Fz_JP9Qizcgyd7r8REkTMXg@mail.gmail.com>
Subject: Re: [PATCH 1/2] SUNRPC: Adjust rpciod workqueue parameters
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 27, 2015 at 1:20 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
>
> On 01/26/2015 07:17 PM, Trond Myklebust wrote:
>> On Mon, Jan 26, 2015 at 9:30 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
>>>
>>>
>>>
>>> On 01/26/2015 04:34 PM, Trond Myklebust wrote:
>>>> On Mon, Jan 26, 2015 at 6:33 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
>>>>> Hello Trond,
>>>>>
>>>>> workqueue WQ_UNBOUND flag is also needed. Some customer hit a problem, RT thread caused rpciod starvation. It is easy to reproduce it with running a cpu intensive workload with lower nice value than rpciod workqueue on the cpu the network interrupt is received.
>>>>>
>>>>> I've also tested iozone and fio test with WQ_UNBOUND|WQ_SYSFS flag on for NFS/RDMA, NFS/IPoIB. The results are better than BOUND.
>>>>
>>>> It certainly does not seem appropriate to use WQ_SYSFS on a queue that
>>>> is used for swap, and Documentation/kernel-per-CPU-kthreads.txt makes
>>>> an extra strong argument against enabling it on the grounds that it is
>>>> not easily reversible.
>>>
>>> If enabling UNBOUND, I thought customizing workqueue would help.
>>>
>>>> As for unbound queues: they will almost by definition defeat all the
>>>> packet steering and balancing that is done in the networking layer in
>>>> the name of multi-process scalability (see
>>>> Documentation/networking/scaling.txt). While RDMA systems may or may
>>>> not care about that, ordinary networked systems probably do.
>>>> Don't most RDMA drivers allow you to balance those interrupts, at
>>>> least on the high end systems?
>>>
>>> The problem was IRQ balance is not aware of which cpu is busy on the system, networking NIC interrupts can be directed to the busy CPU while other cpus are much lightly loaded. So packet steering and balancing in the networking layer doesn't have any benefit.
>>
>> Sure it does. You are argument revolves around a corner case.
>>
>>> The network workload can cause starvation in this situation it doesn't matter it's RDMA or Ethernet. The workaround solution is to unmask this busy cpu in irq balance, or manually set up irq smp affinity to avoid any interrupts on this cpu.
>>
>> Then schedule it to system_unbound_wq instead. Why do you need to change rpciod?
>>
>>> UNBOUND workqueue will choose same CPU to run the work if this CPU is not busy, it is scheduled to another CPU on the same NUMA node when this CPU is busy. So it doesn't defeat packet steering and balancing.
>>
>> Yes it does. The whole point of packet steering is to maximise
>> locality in order to avoid contention for resources, locks etc for
>> networking data that is being consumed by just one (or a few)
>> processes. By spraying jobs across multiple threads, you are
>> reintroducing that contention. Furthermore, you are randomising the
>> processing order for _all_rpciod tasks.
>> Please read Documentation/workqueue.txt where it state clearly that:
>>
>>         Unbound wq sacrifices locality but is useful for
>>         the following cases.
>>
>>         * Wide fluctuation in the concurrency level requirement is
>>           expected and using bound wq may end up creating large number
>>           of mostly unused workers across different CPUs as the issuer
>>           hops through different CPUs.
>>
>>         * Long running CPU intensive workloads which can be better
>>           managed by the system scheduler.
>>
>> neither of which conditions are the common case for rpciod.
>
> My point was the locality is for performance, if locality doesn't gain much performance, then unbound is a better choice. From the data I've collected for rpciod workqueue bound vs unbound: when the local CPU is busy, bound's performance is much worse than unbound (which is scheduled to other remote CPU), when local CPU is not busy, bound and unbound performance (both latency and BW) seems similar. So unbound seems a better choice for rpciod.
>

You have supplied 1 data point on a platform (RDMA) that has no users.
I see no reason to make a change.


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
