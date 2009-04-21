Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:53492 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbZDUSTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 14:19:42 -0400
Message-ID: <49EE0DF1.6000502@vlnb.net>
Date: Tue, 21 Apr 2009 22:18:25 +0400
From: Vladislav Bolkhovitin <vst@vlnb.net>
To: Wu Fengguang <wfg@linux.intel.com>
CC: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lukasz.jurewicz@gmail.com
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
References: <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <499B0994.8040000@vlnb.net> <20090219020542.GC5743@localhost> <49C2846D.5030500@vlnb.net> <20090323014220.GA10448@localhost>
In-Reply-To: <20090323014220.GA10448@localhost>
Content-Type: multipart/mixed;
 boundary="------------080004080804080904030708"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080004080804080904030708
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Wu Fengguang, on 03/23/2009 04:42 AM wrote:
>> Here are the conclusions from tests:
>>
>>  1. Making all IO threads work in the same IO context with CFQ (vanilla  
>> RA and default RA size) brings near 100% link utilization on single  
>> stream reads (100MB/s) and with deadline about 50% (50MB/s). I.e. there  
>> is 100% improvement of CFQ over deadline. With 2 read streams CFQ has  
>> ever more advantage: >400% (23MB/s vs 5MB/s).
> 
> The ideal 2-stream throughput should be >60MB/s, so I guess there are
> still room of improvements for the CFQ's 23MB/s?

Yes, plenty. But, I think, not in CFQ, but in readahead. With RA 4096K 
we were able to get ~40MB/s, see the previous e-mail and below.

> The one fact I cannot understand is that SCST seems to breaking up the
> client side 64K reads into server side 4K reads(above readahead layer).
> But I remember you told me that SCST don't do NFS rsize style split-ups.
> Is this a bug? The 4K read size is too small to be CPU/network friendly...
> Where are the split-up and re-assemble done? On the client side or
> internal to the server?

This is on the client's side. See the target's log in the attachment. 
Here is the summary of commands data sizes, came to the server, for "dd 
if=/dev/sdb of=/dev/null bs=64K count=200" ran on the client:

4K                       11
8K                       0
16K                      0
32K                      0
64K                      0
128K                     81
256K                     8
512K                     0
1024K                    0
2048K                    0
4096K                    0

There's a way too many 4K requests. Apparently, the requests submission 
path isn't optimal.

Actually, this is another question I wanted to rise from the very 
beginning.

>>  6. Unexpected result. In case, when ll IO threads work in the same IO  
>> context with CFQ increasing RA size *decreases* throughput. I think this  
>> is, because RA requests performed as single big READ requests, while  
>> requests coming from remote clients are much smaller in size (up to  
>> 256K), so, when the read by RA data transferred to the remote client on  
>> 100MB/s speed, the backstorage media gets rotated a bit, so the next  
>> read request must wait the rotation latency (~0.1ms on 7200RPM). This is  
>> well conforms with (3) above, when context RA has 40% advantage over  
>> vanilla RA with default RA, but much smaller with higher RA.
> 
> Maybe. But the readahead IOs (as showed by the trace) are _async_ ones...

That doesn't matter, because new request from the client won't come 
until all data for the previous one transferred to it. And that transfer 
is done on a very *finite* speed.

>> Bottom line IMHO conclusions:
>>
>> 1. Context RA should be considered after additional examination to  
>> replace current RA algorithm in the kernel
> 
> That's my plan to push context RA to mainline. And thank you very much
> for providing and testing out a real world application for it!

You're welcome!

>> 2. It would be better to increase default RA size to 1024K
> 
> That's a long wish to increase the default RA size. However I have a
> vague feeling that it would be better to first make the lower layers
> more smart on max_sectors_kb granularity request splitting and batching.

Can you elaborate more on that, please?

>> *AND* one of the following:
>>
>> 3.1. All RA requests should be split in smaller requests with size up to  
>> 256K, which should not be merged with any other request
> 
> Are you referring to max_sectors_kb?

Yes

> What's your max_sectors_kb and nr_requests? Something like
> 
>         grep -r . /sys/block/sda/queue/

Default: 512 and 128 correspondingly.

>> OR
>>
>> 3.2. New RA requests should be sent before the previous one completed to  
>> don't let the storage device rotate too far to need full rotation to  
>> serve the next request.
> 
> Linus has a mmap readahead cleanup patch that can do this. It
> basically replaces a {find_lock_page(); readahead();} sequence into
> {find_get_page(); readahead(); lock_page();}.
> 
> I'll try to push that patch into mainline.

Good!

>> I like suggestion 3.1 a lot more, since it should be simple to implement  
>> and has the following 2 positive side effects:
>>
>> 1. It would allow to minimize negative effect of higher RA size on the  
>> I/O delay latency by allowing CFQ to switch to too long waiting  
>> requests, when necessary.
>>
>> 2. It would allow better requests pipelining, which is very important to  
>> minimize uplink latency for synchronous requests (i.e. with only one IO  
>> request at time, next request issued, when the previous one completed).  
>> You can see in http://www.3ware.com/kb/article.aspx?id=11050 that 3ware  
>> recommends for maximum performance set max_sectors_kb as low as *64K*  
>> with 16MB RA. It allows to maximize serving commands pipelining. And  
>> this suggestion really works allowing to improve throughput in 50-100%!

Seems I should elaborate more on this. Case, when client is remote has a 
fundamental difference from the case, when client is local, for which 
Linux currently optimized. When client is local data delivered to it 
from the page cache with a virtually infinite speed. But when client is 
remote data delivered to it from the server's cache on a *finite* speed. 
In our case this speed is about the same as speed of reading data to the 
cache from the storage. It has the following consequences:

1. Data for any READ request at first transferred from the storage to 
the cache, then from the cache to the client. If those transfers are 
done purely sequentially without overlapping, i.e. without any 
readahead, resulting throughput T can be found from equation: 1/T = 
1/Tlocal + 1/Tremote, where Tlocal and Tremote are throughputs of the 
local (i.e. from the storage) and remote links. In case, when Tlocal ~= 
Tremote, T ~= Tremote/2. Quite unexpected result, right? ;)

2. If data transfers on the local and remote links aren't coordinated, 
it is possible that only one link transfers data at some time. From the 
(1) above you can calculate that % of this "idle" time is % of the lost 
throughput. I.e. to get the maximum throughput both links should 
transfer data as simultaneous as possible. For our case, when Tlocal ~= 
Tremote, both links should be all the time busy. Moreover, it is 
possible that the local transfer finished, but during the remote 
transfer the storage media rotated too far, so for the next request it 
will be needed to wait the full rotation to finish (i.e. several ms of 
lost bandwidth).

Thus, to get the maximum possible throughput, we need to maximize 
simultaneous load of both local and remote links. It can be done by 
using well known pipelining technique. For that client should read the 
same amount of data at once, but those read should be split on smaller 
chunks, like 64K at time. This approach looks being against the 
"conventional wisdom", saying that bigger request means bigger 
throughput, but, in fact, it doesn't, because the same (big) amount of 
data are read at time. Bigger count of smaller requests will make more 
simultaneous load on both participating in the data transfers links. In 
fact, even if client is local, in most cases there is a second data 
transfer link. It's in the storage. This is especially true for RAID 
controllers. Guess, why 3ware recommends to set max_sectors_kb to 64K 
and increase RA in the above link? ;)

Of course, max_sectors_kb should be decreased only for smart devices, 
which allow >1 outstanding requests at time, i.e. for all modern 
SCSI/SAS/SATA/iSCSI/FC/etc. drives.

There is an objection against having too many outstanding requests at 
time. This is latency. But, since overall size of all requests remains 
unchanged, this objection isn't relevant in this proposal. There is the 
same latency-related objection against increasing RA. But many small 
individual RA requests it isn't relevant as well.

We did some measurements to support the this proposal. They were done 
only with deadline scheduler to make the picture clearer. They were done 
with context RA. The tests were the same as before.

--- Baseline, all default:

# dd if=/dev/sdb of=/dev/null bs=64K count=80000
          a) 51,1 MB/s
          b) 51,4 MB/s
          c) 51,1 MB/s

Run at the same time:
# while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
# dd if=/dev/sdb of=/dev/null bs=64K count=80000
          a) 4,7 MB/s
          b) 4,6 MB/s
          c) 4,8 MB/s

--- Client - all default, on the server max_sectors_kb set to 64K:

# dd if=/dev/sdb of=/dev/null bs=64K count=80000
     - 100 MB/s
     - 100 MB/s
     - 102 MB/s

# while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
# dd if=/dev/sdb of=/dev/null bs=64K count=80000
     - 5,2 MB/s
     - 5,3 MB/s
     - 4,2 MB/s

100% and 8% improvement comparing to the baseline.

 From the previous e-mail you can see that with 4096K RA

# while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
# dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 39,9 MB/s
	b) 39,5 MB/s
	c) 38,4 MB/s

I.e. there is 760% improvement over the baseline.

Thus, I believe, that for all devices, supporting queue depths >1, 
max_sectors_kb should be set by default to 64K (or to 128K, maybe, but 
not more), and default RA increased to at least 1M, better 2-4M.

> (Can I wish a CONFIG_PRINTK_TIME=y next time? :-)

Sure

Thanks,
Vlad


--------------080004080804080904030708
Content-Type: application/x-bzip;
 name="req_split.log.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="req_split.log.bz2"

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

--------------080004080804080904030708--
