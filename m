Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40959 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbcD1QPW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 12:15:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 10/10] svcrdma: Switch CQs from IB_POLL_SOFTIRQ to IB_POLL_WORKQUEUE
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <00ec01d1a166$fd134650$f739d2f0$@opengridcomputing.com>
Date: Thu, 28 Apr 2016 12:15:16 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <56ECC5E6-62DB-4498-8E2D-FD6F887C0EEA@oracle.com>
References: <20160428150915.13068.94602.stgit@klimt.1015granger.net> <20160428151550.13068.24199.stgit@klimt.1015granger.net> <00ec01d1a166$fd134650$f739d2f0$@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 28, 2016, at 11:59 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
> 
> 
>> -----Original Message-----
>> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>> Sent: Thursday, April 28, 2016 10:16 AM
>> To: linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
>> Subject: [PATCH 10/10] svcrdma: Switch CQs from IB_POLL_SOFTIRQ to
>> IB_POLL_WORKQUEUE
>> 
>> Spread NFSD completion handling across CPUs, and replace
>> BH-friendly spin locking with plain spin locks.
>> 
>> iozone -i0 -i1 -s128m -y1k -az -I -N
>> 
>> Microseconds/op Mode. Output is in microseconds per operation.
>> 
>> Before:
>>              KB  reclen   write rewrite    read    reread
>>          131072       1      51      51       43       43
>>          131072       2      53      52       42       43
>>          131072       4      53      52       43       43
>>          131072       8      55      54       44       44
>>          131072      16      62      59       49       47
>>          131072      32      72      69       53       53
>>          131072      64      92      87       66       66
>>          131072     128     144     130       94       93
>>          131072     256     225     216      146      145
>>          131072     512     485     474      251      251
>>          131072    1024     573     540      514      512
>>          131072    2048    1007     941      624      618
>>          131072    4096    1672    1699      976      969
>>          131072    8192    3179    3158     1660     1649
>>          131072   16384    5836    5659     3062     3041
>> 
>> After:
>>              KB  reclen   write rewrite    read    reread
>>          131072       1      54      54       43       43
>>          131072       2      55      55       43       43
>>          131072       4      56      57       44       45
>>          131072       8      59      58       45       45
>>          131072      16      64      62       47       47
>>          131072      32      76      74       54       54
>>          131072      64      96      91       67       66
>>          131072     128     148     133       97       97
>>          131072     256     229     227      148      147
>>          131072     512     488     445      252      255
>>          131072    1024     582     534      511      540
>>          131072    2048     998     988      614      620
>>          131072    4096    1685    1679      946      965
>>          131072    8192    3113    3048     1650     1644
>>          131072   16384    6010    5745     3046     3053
>> 
>> NFS READ is roughly the same, NFS WRITE is marginally worse.
>> 
>> Before:
>> GETATTR:
>> 	242 ops (0%)
>> 	avg bytes sent per op: 127
>> 	avg bytes received per op: 112
>> 	backlog wait: 0.000000
>> 	RTT: 0.041322
>> 	total execute time: 0.049587 (milliseconds)
>> 
>> After:
>> GETATTR:
>> 	242 ops (0%)
>> 	avg bytes sent per op: 127
>> 	avg bytes received per op: 112
>> 	backlog wait: 0.000000
>> 	RTT: 0.045455
>> 	total execute time: 0.053719 (milliseconds)
>> 
>> Small op latency increased by 4usec.
>> 
> 
> 
> Hey Chuck, in what scenario or under what type of load do you expect this change to help performance?  I guess it would help as you scale out the number of clients and thus the number of CQs in use?

Allowing completions to run on any CPU should help if the
softIRQ thread is constrained to one CPU.

Flapping bottom-halfs fewer times for each incoming RPC
_should_ also be beneficial.

We are also interested in posting RDMA Read requests during
Receive completion processing. That would reduce the
latency of any request involving a Read chunk by removing
a heavyweight context switch.

I've also noticed that changing just the Receive CQ to use
workqueue has only negligible impact on performance (as
measured using the above tool).


> Do you do any measurements along these lines?

I don't have the quantity of hardware needed for that kind
of analysis. You might have a few more clients in your
lab...

I think my basic question is whether I've missed something,
if the approach can be improved, am I using the correct
metrics, etc.


--
Chuck Lever



