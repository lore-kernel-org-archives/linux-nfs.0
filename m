Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:42510 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbeBQSzT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Feb 2018 13:55:19 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC] fix parallelism for rpc tasks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <BN6PR06MB35218ABC67EAAF5193E56264E1F50@BN6PR06MB3521.namprd06.prod.outlook.com>
Date: Sat, 17 Feb 2018 13:55:08 -0500
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8DCB7426-5C06-440C-A32D-7BD390AA9C1B@oracle.com>
References: <CAN-5tyEX1Z_3EB3h6=z_S1E=gpTObOrcP5Ub2HmVKBB5RaU1DQ@mail.gmail.com>
 <1499093918.79205.3.camel@primarydata.com>
 <CAN-5tyHy=c6z4v5oTecSJMVpTe28CCVAkBQxj56iruJwetjHqQ@mail.gmail.com>
 <B944CE35-FC0A-461D-B43A-223B0CFDAD50@oracle.com>
 <1499269592.6496.1.camel@primarydata.com>
 <CAN-5tyHaT_j+fNPVbYzBLUh5_jbFxhFDVP+eby=Mf25V=JtpBw@mail.gmail.com>
 <1499271287.10445.1.camel@primarydata.com>
 <CAN-5tyFeN3cUCi8u8VnHAQmGD=GE5+3ox-dyLrSdL52L4Lfrng@mail.gmail.com>
 <CAN-5tyFJoMUcXVWcmte7UUQ9j=vA9QO_D=HY6Qs8eH=MGAotiw@mail.gmail.com>
 <BN6PR06MB35218ABC67EAAF5193E56264E1F50@BN6PR06MB3521.namprd06.prod.outlook.com>
To: "Mora, Jorge" <Jorge.Mora@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 14, 2018, at 6:13 PM, Mora, Jorge <Jorge.Mora@netapp.com> =
wrote:
>=20
> Hello,
>=20
> The patch gives some performance improvement on Kerberos read.
> The following results show performance comparisons between unpatched
> and patched systems. The html files included as attachments show the
> results as line charts.
>=20
> - Best read performance improvement when testing with a single dd =
transfer.
>  The patched system gives 70% better performance than the unpatched =
system.
>  (first set of results)
>=20
> - The patched system gives 18% better performance than the unpatched =
system
>  when testing with multiple dd transfers.
>  (second set of results)
>=20
> - The write test shows there is no performance hit by the patch.
>  (third set of results)
>=20
> - When testing on a different client having less RAM and fewer number =
of CPU cores,
>  there is no performance degradation for Kerberos in the unpatched =
system.
>  In this case, the patch does not provide any performance improvement.
>  (fourth set of results)
>=20
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> Test environment:
>=20
> NFS client:  CPU: 16 cores, RAM: 32GB (E5620 @ 2.40GHz)
> NFS servers: CPU: 16 cores, RAM: 32GB (E5620 @ 2.40GHz)
> NFS mount:   NFSv3 with sec=3D(sys or krb5p)
>=20
> For tests with a single dd transfer there is of course one NFS server =
used
> and one file being read -- only one transfer was needed to fill up the
> network connection.
>=20
> For tests with multiple dd transfers, three different NFS server were =
used
> and four different files were used per NFS server for a total of 12 =
different
> files being read (12 different transfers in parallel).
>=20
> The patch was applied on top of 4.14.0-rc3 kernel and the NFS servers =
were
> running RHEL 7.4.
>=20
> The fourth set of results below show an unpatched system with no =
Kerberos
> degradation (same kernel 4.14.0-rc3) but in contrast with the main =
client
> used for testing this client has only 4 CPU cores and 8GB of RAM.
> I believe that even though this system has less CPU cores and less =
RAM,
> the CPU is faster (E31220 @ 3.10GHz vs E5620 @ 2.40GHz) so it is able
> to handle the Kerberos load better and fill up the network connection
> with a single thread than the main client with more CPU cores and more
> memory.

Jorge, thanks for publishing these results.

Can you do a "numactl -H" on your clients and post the output? I suspect
the throughput improvement on the big client is because WQ_UNBOUND
behaves differently on NUMA systems. (Even so, I agree that the proposed
change is valuable).


> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>=20
> Kerberos Read Performance: 170.15% (patched system over unpatched =
system)
>=20
> Client CPU:        Intel(R) Xeon(R) CPU E5620 @ 2.40GHz
> CPU cores:         16
> RAM:               32 GB
> NFS version:       3
> Mount points:      1
> dd's per mount:    1
> Total dd's:        1
> Data transferred:  7.81 GB (per run)
> Number of runs:    10
>=20
> Kerberos Read Performance (unpatched system vs patched system)
> Transfer rate (unpatched system)  avg:  65.88 MB/s,   var:  20.28,   =
stddev:   4.50
> Transfer rate (patched system)    avg: 112.10 MB/s,   var:   0.00,   =
stddev:   0.01
> Performance (patched over unpatched):  170.15%
>=20
> Unpatched System Read Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 111.96 MB/s,   var:   0.02,   =
stddev:   0.13
> Transfer rate (sec=3Dkrb5p)  avg:  65.88 MB/s,   var:  20.28,   =
stddev:   4.50
> Performance (krb5p over sys):   58.84%
>=20
> Patched System Read Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 111.94 MB/s,   var:   0.02,   =
stddev:   0.14
> Transfer rate (sec=3Dkrb5p)  avg: 112.10 MB/s,   var:   0.00,   =
stddev:   0.01
> Performance (krb5p over sys):  100.14%
>=20
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>=20
> Kerberos Read Performance: 118.02% (patched system over unpatched =
system)
>=20
> Client CPU:        Intel(R) Xeon(R) CPU E5620 @ 2.40GHz
> CPU cores:         16
> RAM:               32 GB
> NFS version:       3
> Mount points:      3
> dd's per mount:    4
> Total dd's:        12
> Data transferred:  93.75 GB (per run)
> Number of runs:    10
>=20
> Kerberos Read Performance (unpatched system vs patched system)
> Transfer rate (unpatched system)  avg:  94.99 MB/s,   var:  68.96,   =
stddev:   8.30
> Transfer rate (patched system)    avg: 112.11 MB/s,   var:   0.00,   =
stddev:   0.03
> Performance (patched over unpatched):  118.02%
>=20
> Unpatched System Read Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 112.21 MB/s,   var:   0.00,   =
stddev:   0.00
> Transfer rate (sec=3Dkrb5p)  avg:  94.99 MB/s,   var:  68.96,   =
stddev:   8.30
> Performance (krb5p over sys):   84.66%
>=20
> Patched System Read Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 112.20 MB/s,   var:   0.00,   =
stddev:   0.00
> Transfer rate (sec=3Dkrb5p)  avg: 112.11 MB/s,   var:   0.00,   =
stddev:   0.03
> Performance (krb5p over sys):   99.92%
>=20
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>=20
> Kerberos Write Performance: 101.55% (patched system over unpatched =
system)
>=20
> Client CPU:        Intel(R) Xeon(R) CPU E5620 @ 2.40GHz
> CPU cores:         16
> RAM:               32 GB
> NFS version:       3
> Mount points:      3
> dd's per mount:    4
> Total dd's:        12
> Data transferred:  93.75 GB (per run)
> Number of runs:    10
>=20
> Kerberos Write Performance (unpatched system vs patched system)
> Transfer rate (unpatched system)  avg: 103.70 MB/s,   var: 110.51,   =
stddev:  10.51
> Transfer rate (patched system)    avg: 105.31 MB/s,   var:  35.04,   =
stddev:   5.92
> Performance (patched over unpatched):  101.55%
>=20
> Unpatched System Write Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 109.87 MB/s,   var:  10.27,   =
stddev:   3.20
> Transfer rate (sec=3Dkrb5p)  avg: 103.70 MB/s,   var: 110.51,   =
stddev:  10.51
> Performance (krb5p over sys):   94.39%
>=20
> Patched System Write Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 111.03 MB/s,   var:   0.58,   =
stddev:   0.76
> Transfer rate (sec=3Dkrb5p)  avg: 105.31 MB/s,   var:  35.04,   =
stddev:   5.92
> Performance (krb5p over sys):   94.85%
>=20
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>=20
> Kerberos Read Performance: 99.99% (patched system over unpatched =
system)
>=20
> Client CPU:        Intel(R) Xeon(R) CPU E31220 @ 3.10GHz
> CPU cores:         4
> RAM:               8 GB
> NFS version:       3
> Mount points:      1
> dd's per mount:    1
> Total dd's:        1
> Data transferred:  7.81 GB (per run)
> Number of runs:    10
>=20
> Kerberos Read Performance (unpatched system vs patched system)
> Transfer rate (unpatched system)  avg: 112.02 MB/s,   var:   0.04,   =
stddev:   0.21
> Transfer rate (patched system)    avg: 112.01 MB/s,   var:   0.06,   =
stddev:   0.25
> Performance (patched over unpatched):   99.99%
>=20
> Unpatched System Read Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 111.86 MB/s,   var:   0.06,   =
stddev:   0.24
> Transfer rate (sec=3Dkrb5p)  avg: 112.02 MB/s,   var:   0.04,   =
stddev:   0.21
> Performance (krb5p over sys):  100.14%
>=20
> Patched System Read Performance (sys vs krb5p)
> Transfer rate (sec=3Dsys)    avg: 111.76 MB/s,   var:   0.12,   =
stddev:   0.34
> Transfer rate (sec=3Dkrb5p)  avg: 112.01 MB/s,   var:   0.06,   =
stddev:   0.25
> Performance (krb5p over sys):  100.22%
>=20
>=20
> --Jorge
>=20
> ________________________________________
> From: linux-nfs-owner@vger.kernel.org =
<linux-nfs-owner@vger.kernel.org> on behalf of Olga Kornievskaia =
<aglo@umich.edu>
> Sent: Wednesday, July 19, 2017 11:59 AM
> To: Trond Myklebust
> Cc: linux-nfs@vger.kernel.org; chuck.lever@oracle.com
> Subject: Re: [RFC] fix parallelism for rpc tasks
>=20
> On Wed, Jul 5, 2017 at 1:33 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>> On Wed, Jul 5, 2017 at 12:14 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>> On Wed, 2017-07-05 at 12:09 -0400, Olga Kornievskaia wrote:
>>>> On Wed, Jul 5, 2017 at 11:46 AM, Trond Myklebust
>>>> <trondmy@primarydata.com> wrote:
>>>>> On Wed, 2017-07-05 at 11:11 -0400, Chuck Lever wrote:
>>>>>>> On Jul 5, 2017, at 10:44 AM, Olga Kornievskaia <aglo@umich.edu>
>>>>>>> wrote:
>>>>>>>=20
>>>>>>> On Mon, Jul 3, 2017 at 10:58 AM, Trond Myklebust
>>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>>> On Thu, 2017-06-29 at 09:25 -0400, Olga Kornievskaia wrote:
>>>>>>>>> Hi folks,
>>>>>>>>>=20
>>>>>>>>> On a multi-core machine, is it expected that we can have
>>>>>>>>> parallel
>>>>>>>>> RPCs
>>>>>>>>> handled by each of the per-core workqueue?
>>>>>>>>>=20
>>>>>>>>> In testing a read workload, observing via "top" command
>>>>>>>>> that a
>>>>>>>>> single
>>>>>>>>> "kworker" thread is running servicing the requests (no
>>>>>>>>> parallelism).
>>>>>>>>> It's more prominent while doing these operations over krb5p
>>>>>>>>> mount.
>>>>>>>>>=20
>>>>>>>>> What has been suggested by Bruce is to try this and in my
>>>>>>>>> testing I
>>>>>>>>> see then the read workload spread among all the kworker
>>>>>>>>> threads.
>>>>>>>>>=20
>>>>>>>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>>>>>>>>=20
>>>>>>>>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>>>>>>>>> index 0cc8383..f80e688 100644
>>>>>>>>> --- a/net/sunrpc/sched.c
>>>>>>>>> +++ b/net/sunrpc/sched.c
>>>>>>>>> @@ -1095,7 +1095,7 @@ static int rpciod_start(void)
>>>>>>>>> * Create the rpciod thread and wait for it to start.
>>>>>>>>> */
>>>>>>>>> dprintk("RPC:       creating workqueue rpciod\n");
>>>>>>>>> - wq =3D alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 0);
>>>>>>>>> + wq =3D alloc_workqueue("rpciod", WQ_MEM_RECLAIM |
>>>>>>>>> WQ_UNBOUND,
>>>>>>>>> 0);
>>>>>>>>> if (!wq)
>>>>>>>>> goto out_failed;
>>>>>>>>> rpciod_workqueue =3D wq;
>>>>>>>>>=20
>>>>>>>>=20
>>>>>>>> WQ_UNBOUND turns off concurrency management on the thread
>>>>>>>> pool
>>>>>>>> (See
>>>>>>>> Documentation/core-api/workqueue.rst. It also means we
>>>>>>>> contend
>>>>>>>> for work
>>>>>>>> item queuing/dequeuing locks, since the threads which run the
>>>>>>>> work
>>>>>>>> items are not bound to a CPU.
>>>>>>>>=20
>>>>>>>> IOW: This is not a slam-dunk obvious gain.
>>>>>>>=20
>>>>>>> I agree but I think it's worth consideration. I'm waiting to
>>>>>>> get
>>>>>>> (real) performance numbers of improvement (instead of my VM
>>>>>>> setup)
>>>>>>> to
>>>>>>> help my case. However, it was reported 90% degradation for the
>>>>>>> read
>>>>>>> performance over krb5p when 1CPU is executing all ops.
>>>>>>>=20
>>>>>>> Is there a different way to make sure that on a multi-processor
>>>>>>> machine we can take advantage of all available CPUs? Simple
>>>>>>> kernel
>>>>>>> threads instead of a work queue?
>>>>>>=20
>>>>>> There is a trade-off between spreading the work, and ensuring it
>>>>>> is executed on a CPU close to the I/O and application. IMO
>>>>>> UNBOUND
>>>>>> is a good way to do that. UNBOUND will attempt to schedule the
>>>>>> work on the preferred CPU, but allow it to be migrated if that
>>>>>> CPU is busy.
>>>>>>=20
>>>>>> The advantage of this is that when the client workload is CPU
>>>>>> intensive (say, a software build), RPC client work can be
>>>>>> scheduled
>>>>>> and run more quickly, which reduces latency.
>>>>>>=20
>>>>>=20
>>>>> That should no longer be a huge issue, since queue_work() will now
>>>>> default to the WORK_CPU_UNBOUND flag, which prefers the local CPU,
>>>>> but
>>>>> will schedule elsewhere if the local CPU is congested.
>>>>=20
>>>> I don't believe NFS use workqueue_congested() to somehow schedule =
the
>>>> work elsewhere. Unless the queue is marked UNBOUNDED I don't =
believe
>>>> there is any intention of balancing the CPU load.
>>>>=20
>>>=20
>>> I shouldn't have to test the queue when scheduling with
>>> WORK_CPU_UNBOUND.
>>>=20
>>=20
>> Comments in the code says that "if CPU dies" it'll be re-scheduled on
>> another. I think the code requires to mark the queue UNBOUND to =
really
>> be scheduled on a different CPU. Just my reading of the code and it
>> matches what is seen with the krb5 workload.
>=20
> Trond, what's the path forward here? What about a run-time
> configuration that starts rpciod with the UNBOUND options instead?
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> =
<dd_read_single.html><dd_read_mult.html><dd_write_mult.html><dd_read_singl=
e1.html>

--
Chuck Lever



