Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:23505 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753957AbZDXIoI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 04:44:08 -0400
Date: Fri, 24 Apr 2009 16:43:21 +0800
From: Wu Fengguang <wfg@linux.intel.com>
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lukasz.jurewicz@gmail.com
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Message-ID: <20090424084321.GA5585@localhost>
References: <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <499B0994.8040000@vlnb.net> <20090219020542.GC5743@localhost> <49C2846D.5030500@vlnb.net> <20090323014220.GA10448@localhost> <49EE0DF1.6000502@vlnb.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <49EE0DF1.6000502@vlnb.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 21, 2009 at 10:18:25PM +0400, Vladislav Bolkhovitin wrote:
> Wu Fengguang, on 03/23/2009 04:42 AM wrote:
>>> Here are the conclusions from tests:
>>>
>>>  1. Making all IO threads work in the same IO context with CFQ 
>>> (vanilla  RA and default RA size) brings near 100% link utilization 
>>> on single  stream reads (100MB/s) and with deadline about 50% 
>>> (50MB/s). I.e. there  is 100% improvement of CFQ over deadline. With 
>>> 2 read streams CFQ has  ever more advantage: >400% (23MB/s vs 5MB/s).
>>
>> The ideal 2-stream throughput should be >60MB/s, so I guess there are
>> still room of improvements for the CFQ's 23MB/s?
>
> Yes, plenty. But, I think, not in CFQ, but in readahead. With RA 4096K  
> we were able to get ~40MB/s, see the previous e-mail and below.

Why do you think it's in readahead? The readahead account/tracing data
you provided in a previous email shows context readahead to work just fine:

        On initiator run benchmark:
        dd if=/dev/sdb of=/dev/null bs=64K count=8000
        dd if=/dev/sdc of=/dev/null bs=64K count=8000

        linux-4dtq:/.kernels/scst-kernel-4 # cat /sys/kernel/debug/readahead/stats
        pattern         count sync_count  eof_count       size async_size     actual
        initial0            4          4          1          4          3          3
        subsequent        288          0          0        470        251        251
        marker            722          0          0        255        255        255
        mmap                2          2          2         32          0         12
        fadvise             2          2          2          0          0         69
        all              1018          8          5        314        252        252

The last line says the server side does 1018 readaheads with average
size 1008K, which is pretty close to the max readahead size 1024K.

Raw performance numbers are not enough here. The readahead size and
the actual IO size, and possibly the readahead traces and IO traces
are the most vivid and ultimate way to judge who's behaving wrong
and provide the hint to a solution.

>> The one fact I cannot understand is that SCST seems to breaking up the
>> client side 64K reads into server side 4K reads(above readahead layer).
>> But I remember you told me that SCST don't do NFS rsize style split-ups.
>> Is this a bug? The 4K read size is too small to be CPU/network friendly...
>> Where are the split-up and re-assemble done? On the client side or
>> internal to the server?
>
> This is on the client's side. See the target's log in the attachment.  
>
> Here is the summary of commands data sizes, came to the server, for "dd  
> if=/dev/sdb of=/dev/null bs=64K count=200" ran on the client:
>
> 4K                       11
> 8K                       0
> 16K                      0
> 32K                      0
> 64K                      0
> 128K                     81
> 256K                     8
> 512K                     0
> 1024K                    0
> 2048K                    0
> 4096K                    0
>
> There's a way too many 4K requests. Apparently, the requests submission  
> path isn't optimal.

So it's the client side that splits 128K (default sized) readahead IO
into 4-256K SCST requests that sent over the network?

It looks good enough since it's mostly 128K requests. However this is
still not in line with previous data:

        req=0+1, ra=0+4-3, async=0) = 4
        req=1+1, ra=4+16-16, async=1) = 16
        req=4+1, ra=20+32-32, async=1) = 32
        req=20+1, ra=52+64-64, async=1) = 64
        req=52+1, ra=116+128-128, async=1) = 128
        req=116+1, ra=244+256-256, async=1) = 256
        req=244+1, ra=500+256-256, async=1) = 256
        req=500+1, ra=756+256-256, async=1) = 256
        req=756+1, ra=1012+256-256, async=1) = 256
        req=1012+1, ra=1268+256-256, async=1) = 256
        req=1268+1, ra=1268+512-256, async=1) = 256
        req=1524+1, ra=1780+256-256, async=1) = 256
        req=1780+1, ra=2036+256-256, async=1) = 256
        req=2036+1, ra=2292+256-256, async=1) = 256
        req=2292+1, ra=2548+256-256, async=1) = 256
        req=2548+1, ra=2804+256-256, async=1) = 256
        req=2804+1, ra=2804+512-256, async=1) = 256
        req=3060+1, ra=3060+512-256, async=1) = 256
        req=3316+1, ra=3572+256-256, async=1) = 256
        req=3572+1, ra=3828+256-256, async=1) = 256
        req=3828+1, ra=4084+256-256, async=1) = 256
        req=4084+1, ra=4340+256-256, async=1) = 256
        req=4340+1, ra=4596+256-256, async=1) = 256
        req=4596+1, ra=4596+512-256, async=1) = 256
        req=4852+1, ra=5108+256-256, async=1) = 256
        req=5108+1, ra=5108+512-256, async=1) = 256
        [and 480 more lines of pattern "req=*+1,...= 256")

Basically, the server side ondemand_readahead()
        - perceived *all* about 1-page read requests
        - submitted *always* 256-page readahead IO
          (except during the initial size ramp up process)

Maybe the runtime condition is somehow different for the above and the
below traces.

        [  457.003661] [4208]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.008686] [4210]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.010915] [4210]: vdisk_exec_read:2198:reading(iv_count 63, full_len 258048)
        [  457.015238] [4209]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.015419] [4211]: vdisk_exec_read:2198:reading(iv_count 63, full_len 258048)
        [  457.021696] [4208]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.024205] [4207]: vdisk_exec_read:2198:reading(iv_count 63, full_len 258048)
        [  457.028455] [4210]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.028695] [4210]: vdisk_exec_read:2198:reading(iv_count 31, full_len 126976)
        [  457.033565] [4211]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.035750] [4209]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.037323] [4208]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.041132] [4207]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.043251] [4207]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.045455] [4210]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.047949] [4211]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.051463] [4209]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.052136] [4208]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.057734] [4207]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.058007] [4207]: vdisk_exec_read:2198:reading(iv_count 63, full_len 258048)
        [  457.063185] [4210]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.063404] [4210]: vdisk_exec_read:2198:reading(iv_count 63, full_len 258048)
        [  457.068749] [4211]: vdisk_exec_read:2198:reading(iv_count 1, full_len 4096)
        [  457.069007] [4211]: vdisk_exec_read:2198:reading(iv_count 31, full_len 126976)
        [  457.071339] [4208]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.075250] [4207]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.077416] [4207]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.079892] [4209]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)
        [  457.080492] [4210]: vdisk_exec_read:2198:reading(iv_count 32, full_len 131072)

There is an interesting pattern in the above trace: it tend to be
32-page aligned. An unligned 1-page read will always be followed by an
31-page or 63-page read, which then again make it aligned to 32-page
boundaries :-)

> Actually, this is another question I wanted to rise from the very  
> beginning.
>
>>>  6. Unexpected result. In case, when ll IO threads work in the same 
>>> IO  context with CFQ increasing RA size *decreases* throughput. I 
>>> think this  is, because RA requests performed as single big READ 
>>> requests, while  requests coming from remote clients are much smaller 
>>> in size (up to  256K), so, when the read by RA data transferred to 
>>> the remote client on  100MB/s speed, the backstorage media gets 
>>> rotated a bit, so the next  read request must wait the rotation 
>>> latency (~0.1ms on 7200RPM). This is  well conforms with (3) above, 
>>> when context RA has 40% advantage over  vanilla RA with default RA, 
>>> but much smaller with higher RA.
>>
>> Maybe. But the readahead IOs (as showed by the trace) are _async_ ones...
>
> That doesn't matter, because new request from the client won't come  
> until all data for the previous one transferred to it. And that transfer  
> is done on a very *finite* speed.

Async readahead does matter. The readahead pipeline is all you need to
*fully* fill the storage/network channels (with good readahead size).

The client side request time doesn't matter (ie. not too late to
impact performance). The 

Let's look at the default case, where
        - client readahead size = 128K
        - server readahead size = 128K
        - no split of request size by SCST or max_sectors_kb
and assume
        - application read size = huge
        - application read bw = infinite
        - disk bw = network bw = limited

Imagine three 128K chunks in the file:

         chunk A                             chunk B                         chunk C
================================--------------------------------________________________________
application read blocked here   client side readahead IO        server side readahead IO
(ongoing network IO)            (ongoing network IO)            (ongoing disk IO)

Normally the application can read and consume data very fast.
So in most time, it will be blocked somewhere for network IO.
Let's assume it is blocking at the first page of chunk A.

Just before the application blocks on chunk A, it will trigger a
(client side) readahead request for chunk B, which in turn will
trigger a (server side) readahead request for chunk C.

When disk bw = network bw, it _will_ quickly enter a steady state, in
which the network transfer of B and disk read of C proceed concurrently.

The below tables demonstrate the steps into this pipelined steady state.
(we ignore disk seek time for simplicity)

1) no request merging in SCST and block layer:
        time    0       3       5       6       7
        client  ab      ab      ABcd    ABCde   ABCDef
        server  abc     ABC     ABCde   ABCDef  ABCDEfg
        net transfers   ...     AB      C       D
        disk transfers  ABC     ..      D       E

2) disk merge, no SCST merge:
        time    0       3       5       6       7       8       9
        client  ab      ab      ABcd    ABCde   ABCde   ABCDef  ABCDEfg
        server  abc     ABC     ABCde   ABCdef  ABCDEf  ABCDEFg ABCDEFGh
        net transfers   ...     AB      C       .       D       E
        disk transfers  ABC     ..              DE      F       G

3) application (limited) read speed = 2 * disk bw:
        time    0       3       5       5.5     6       6.5     7
        client  ab      ab      AB      ABc     ABcd    ABCd    ABCde
        server  abc     ABC     ABC     ABCd    ABCDe   ABCDe   ABCDEf
        net transfers   ...     AB      .               C       D
        disk transfers  ABC     ..      .               D       E

Legends:
- lower case 'a': request for chunk A submitted, but IO has not completed
- upper case 'A': request for chunk A submitted, and IO has completed
- dot '.': net/disk idled for one time slot

Annotations for case (2):
T0: single network IO request for chunk A&B, or AB in short;
    single disk IO request for chunk ABC.
T3: disk IO for ABC completes; network idle
T5: disk idle; network IO for AB completes;
    application proceeds quickly to B and then C,
    which triggers two network IO requests, one for C and another for D;
    which triggers one disk IO request for DE(requests for them come
    close and hence get merged into one).
T6: disk busy(half way in DE); network completes request C;
    which quickly triggers network request for E and disk request for F.
T7: disk completes DE; network idle before that.
T8: disk completes F; network completes D;
    which in turn lead to network request for F and disk request for G.
    ==> pipeline established!

Case (2)/(3) are more realistic cases, where two requests come close in
time will be merged in the block layer, but not at SCST client side.

For all three cases, we start by single large request for several
chunks, and quickly converges to a steady state: a pipeline of
single-chunk disk/network requests.

>>> Bottom line IMHO conclusions:
>>>
>>> 1. Context RA should be considered after additional examination to   
>>> replace current RA algorithm in the kernel
>>
>> That's my plan to push context RA to mainline. And thank you very much
>> for providing and testing out a real world application for it!
>
> You're welcome!

Good news: context readahead is now queued in the -mm tree :-)

>>> 2. It would be better to increase default RA size to 1024K
>>
>> That's a long wish to increase the default RA size. However I have a
>> vague feeling that it would be better to first make the lower layers
>> more smart on max_sectors_kb granularity request splitting and batching.
>
> Can you elaborate more on that, please?

Not exactly the above words. But the basic idea is to reduce latency
on sync IO:
- readahead algorithm classify its IO requests into sync/async ones;
- use the SATA/SCSI priority bit for sync/async requests
Each of them could introduce some problems though...

>>> *AND* one of the following:
>>>
>>> 3.1. All RA requests should be split in smaller requests with size up 
>>> to  256K, which should not be merged with any other request
>>
>> Are you referring to max_sectors_kb?
>
> Yes
>
>> What's your max_sectors_kb and nr_requests? Something like
>>
>>         grep -r . /sys/block/sda/queue/
>
> Default: 512 and 128 correspondingly.

OK.

>>> OR
>>>
>>> 3.2. New RA requests should be sent before the previous one completed 
>>> to  don't let the storage device rotate too far to need full rotation 
>>> to  serve the next request.
>>
>> Linus has a mmap readahead cleanup patch that can do this. It
>> basically replaces a {find_lock_page(); readahead();} sequence into
>> {find_get_page(); readahead(); lock_page();}.
>>
>> I'll try to push that patch into mainline.
>
> Good!

Good news 2: mmap readahead is also sitting in the -mm tree :-)

>>> I like suggestion 3.1 a lot more, since it should be simple to 
>>> implement  and has the following 2 positive side effects:
>>>
>>> 1. It would allow to minimize negative effect of higher RA size on 
>>> the  I/O delay latency by allowing CFQ to switch to too long waiting  
>>> requests, when necessary.
>>>
>>> 2. It would allow better requests pipelining, which is very important 
>>> to  minimize uplink latency for synchronous requests (i.e. with only 
>>> one IO  request at time, next request issued, when the previous one 
>>> completed).  You can see in 
>>> http://www.3ware.com/kb/article.aspx?id=11050 that 3ware  recommends 
>>> for maximum performance set max_sectors_kb as low as *64K*  with 16MB 
>>> RA. It allows to maximize serving commands pipelining. And  this 
>>> suggestion really works allowing to improve throughput in 50-100%!
>
> Seems I should elaborate more on this. Case, when client is remote has a  
> fundamental difference from the case, when client is local, for which  
> Linux currently optimized. When client is local data delivered to it  
> from the page cache with a virtually infinite speed. But when client is  
> remote data delivered to it from the server's cache on a *finite* speed.  
> In our case this speed is about the same as speed of reading data to the  
> cache from the storage. It has the following consequences:
>
> 1. Data for any READ request at first transferred from the storage to  
> the cache, then from the cache to the client. If those transfers are  
> done purely sequentially without overlapping, i.e. without any  
> readahead, resulting throughput T can be found from equation: 1/T =  
> 1/Tlocal + 1/Tremote, where Tlocal and Tremote are throughputs of the  
> local (i.e. from the storage) and remote links. In case, when Tlocal ~=  
> Tremote, T ~= Tremote/2. Quite unexpected result, right? ;)

Fortunately I can quickly absorb your idea ;-) Because I can recall
vividly when downloading files in a pretty old kernel, the network IO
and writeback works by turns instead of in a pipelined way. Hmm, it's
an interesting behavior that deserves more researches :-)

> 2. If data transfers on the local and remote links aren't coordinated,  
> it is possible that only one link transfers data at some time. From the  
> (1) above you can calculate that % of this "idle" time is % of the lost  
> throughput. I.e. to get the maximum throughput both links should  
> transfer data as simultaneous as possible. For our case, when Tlocal ~=  
> Tremote, both links should be all the time busy. Moreover, it is  
> possible that the local transfer finished, but during the remote  
> transfer the storage media rotated too far, so for the next request it  
> will be needed to wait the full rotation to finish (i.e. several ms of  
> lost bandwidth).

This is merely a possible state. Can you prove that it is in fact a
*stable* one?

> Thus, to get the maximum possible throughput, we need to maximize  
> simultaneous load of both local and remote links. It can be done by  
> using well known pipelining technique. For that client should read the  
> same amount of data at once, but those read should be split on smaller  
> chunks, like 64K at time. This approach looks being against the  
> "conventional wisdom", saying that bigger request means bigger  
> throughput, but, in fact, it doesn't, because the same (big) amount of  
> data are read at time. Bigger count of smaller requests will make more  
> simultaneous load on both participating in the data transfers links. In  
> fact, even if client is local, in most cases there is a second data  
> transfer link. It's in the storage. This is especially true for RAID  
> controllers. Guess, why 3ware recommends to set max_sectors_kb to 64K  
> and increase RA in the above link? ;)

Sure 64K is good for 3ware - hw raid stripe sizes are typically small.
I wonder if there is a 'stripe size' concept for multi-channel SSDs,
and their typical values :-)

> Of course, max_sectors_kb should be decreased only for smart devices,  
> which allow >1 outstanding requests at time, i.e. for all modern  
> SCSI/SAS/SATA/iSCSI/FC/etc. drives.

But I guess the gain of tiny max_sectors_kb is more marginal for
single spindle case. Just a guess.

> There is an objection against having too many outstanding requests at  
> time. This is latency. But, since overall size of all requests remains  
> unchanged, this objection isn't relevant in this proposal. There is the  
> same latency-related objection against increasing RA. But many small  
> individual RA requests it isn't relevant as well.
>
> We did some measurements to support the this proposal. They were done  
> only with deadline scheduler to make the picture clearer. They were done  
> with context RA. The tests were the same as before.
>
> --- Baseline, all default:
>
> # dd if=/dev/sdb of=/dev/null bs=64K count=80000
>          a) 51,1 MB/s
>          b) 51,4 MB/s
>          c) 51,1 MB/s
>
> Run at the same time:
> # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> # dd if=/dev/sdb of=/dev/null bs=64K count=80000
>          a) 4,7 MB/s
>          b) 4,6 MB/s
>          c) 4,8 MB/s
>
> --- Client - all default, on the server max_sectors_kb set to 64K:
>
> # dd if=/dev/sdb of=/dev/null bs=64K count=80000
>     - 100 MB/s
>     - 100 MB/s
>     - 102 MB/s
>
> # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> # dd if=/dev/sdb of=/dev/null bs=64K count=80000
>     - 5,2 MB/s
>     - 5,3 MB/s
>     - 4,2 MB/s
>
> 100% and 8% improvement comparing to the baseline.

They are definitely encouraging numbers. The 64K max_sectors_kb is
obviously doing good here. However.. How do you know it's essentially
a pipeline issue?  What exactly happened behind the scheme?

> From the previous e-mail you can see that with 4096K RA
>
> # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 39,9 MB/s
> 	b) 39,5 MB/s
> 	c) 38,4 MB/s
>
> I.e. there is 760% improvement over the baseline.

Which baseline? You are comparing 128K/4MB RA sizes, under the default
max_sectors_kb?

> Thus, I believe, that for all devices, supporting queue depths >1,  
> max_sectors_kb should be set by default to 64K (or to 128K, maybe, but  
> not more), and default RA increased to at least 1M, better 2-4M.
>
>> (Can I wish a CONFIG_PRINTK_TIME=y next time? :-)
>
> Sure

Thanks,
Fengguang
