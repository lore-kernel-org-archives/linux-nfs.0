Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:59206 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbZCSRna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 13:43:30 -0400
Message-ID: <49C2846D.5030500@vlnb.net>
Date: Thu, 19 Mar 2009 20:44:13 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
To: Wu Fengguang <wfg@linux.intel.com>
CC: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lukasz.jurewicz@gmail.com
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
References: <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <499B0994.8040000@vlnb.net> <20090219020542.GC5743@localhost>
In-Reply-To: <20090219020542.GC5743@localhost>
Content-Type: multipart/mixed;
 boundary="------------050103060508030804050409"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------050103060508030804050409
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Wu Fengguang, on 02/19/2009 05:05 AM wrote:
> On Tue, Feb 17, 2009 at 10:01:40PM +0300, Vladislav Bolkhovitin wrote:
>> Wu Fengguang, on 02/13/2009 04:57 AM wrote:
>>> On Thu, Feb 12, 2009 at 09:35:18PM +0300, Vladislav Bolkhovitin wrote:
>>>> Sorry for such a huge delay. There were many other activities I had 
>>>> to  do before + I had to be sure I didn't miss anything.
>>>>
>>>> We didn't use NFS, we used SCST (http://scst.sourceforge.net) with   
>>>> iSCSI-SCST target driver. It has similar to NFS architecture, where N 
>>>>  threads (N=5 in this case) handle IO from remote initiators 
>>>> (clients)  coming from wire using iSCSI protocol. In addition, SCST 
>>>> has patch  called export_alloc_io_context (see   
>>>> http://lkml.org/lkml/2008/12/10/282), which allows for the IO threads 
>>>>  queue IO using single IO context, so we can see if context RA can   
>>>> replace grouping IO threads in single IO context.
>>>>
>>>> Unfortunately, the results are negative. We find neither any 
>>>> advantages  of context RA over current RA implementation, nor 
>>>> possibility for  context RA to replace grouping IO threads in single 
>>>> IO context.
>>>>
>>>> Setup on the target (server) was the following. 2 SATA drives grouped 
>>>> in  md RAID-0 with average local read throughput ~120MB/s ("dd 
>>>> if=/dev/zero  of=/dev/md0 bs=1M count=20000" outputs "20971520000 
>>>> bytes (21 GB)  copied, 177,742 s, 118 MB/s"). The md device was 
>>>> partitioned on 3  partitions. The first partition was 10% of space in 
>>>> the beginning of the  device, the last partition was 10% of space in 
>>>> the end of the device,  the middle one was the rest in the middle of 
>>>> the space them. Then the  first and the last partitions were exported 
>>>> to the initiator (client).  They were /dev/sdb and /dev/sdc on it 
>>>> correspondingly.
>>> Vladislav, Thank you for the benchmarks! I'm very interested in
>>> optimizing your workload and figuring out what happens underneath.
>>>
>>> Are the client and server two standalone boxes connected by GBE?
>>>
>>> When you set readahead sizes in the benchmarks, you are setting them
>>> in the server side? I.e. "linux-4dtq" is the SCST server? What's the
>>> client side readahead size?
>>>
>>> It would help a lot to debug readahead if you can provide the
>>> server side readahead stats and trace log for the worst case.
>>> This will automatically answer the above questions as well as disclose
>>> the micro-behavior of readahead:
>>>
>>>         mount -t debugfs none /sys/kernel/debug
>>>
>>>         echo > /sys/kernel/debug/readahead/stats # reset counters
>>>         # do benchmark
>>>         cat /sys/kernel/debug/readahead/stats
>>>
>>>         echo 1 > /sys/kernel/debug/readahead/trace_enable
>>>         # do micro-benchmark, i.e. run the same benchmark for a short time
>>>         echo 0 > /sys/kernel/debug/readahead/trace_enable
>>>         dmesg
>>>
>>> The above readahead trace should help find out how the client side
>>> sequential reads convert into server side random reads, and how we can
>>> prevent that.
>> See attached. Could you comment the logs, please, so I will also be able  
>> to read them in the future?
> 
> Vladislav, thank you for the logs!
> 
> The printk format for the following lines is:
> 
> +       printk(KERN_DEBUG "readahead-%s(pid=%d(%s), dev=%02x:%02x(%s), "
> +               "ino=%lu(%s), req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d\n",
> +               ra_pattern_names[pattern],
> +               current->pid, current->comm,
> +               MAJOR(mapping->host->i_sb->s_dev),
> +               MINOR(mapping->host->i_sb->s_dev),
> +               mapping->host->i_sb->s_id,
> +               mapping->host->i_ino,
> +               filp->f_path.dentry->d_name.name,
> +               offset, req_size,
> +               ra->start, ra->size, ra->async_size,
> +               async,
> +               actual);
> 
> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10596+1, ra=10628+32-32, async=1) = 32
> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10628+1, ra=10660+32-32, async=1) = 32
> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=10660+1, ra=10692+32-32, async=1) = 32
> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10692+1, ra=10724+32-32, async=1) = 32
> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10724+1, ra=10756+32-32, async=1) = 32
> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10756+1, ra=10788+32-32, async=1) = 32
> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10788+1, ra=10820+32-32, async=1) = 32
> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=10820+1, ra=10852+32-32, async=1) = 32
> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10852+1, ra=10884+32-32, async=1) = 32
> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10884+1, ra=10916+32-32, async=1) = 32
> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10916+1, ra=10948+32-32, async=1) = 32
> readahead-marker(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=10948+1, ra=10980+32-32, async=1) = 32
> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10980+1, ra=11012+32-32, async=1) = 32
> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=11012+1, ra=11044+32-32, async=1) = 32
> readahead-marker(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=11044+1, ra=11076+32-32, async=1) = 32
> readahead-subsequent(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=11076+1, ra=11108+32-32, async=1) = 32
> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11108+1, ra=11140+32-32, async=1) = 32
> readahead-subsequent(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11140+1, ra=11172+32-32, async=1) = 32
> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11172+1, ra=11204+32-32, async=1) = 32
> readahead-subsequent(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11204+1, ra=11236+32-32, async=1) = 32
> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=11236+1, ra=11268+32-32, async=1) = 32
> readahead-subsequent(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=11268+1, ra=11300+32-32, async=1) = 32
> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11300+1, ra=11332+32-32, async=1) = 32
> readahead-subsequent(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11332+1, ra=11364+32-32, async=1) = 32
> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11364+1, ra=11396+32-32, async=1) = 32
> readahead-subsequent(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11396+1, ra=11428+32-32, async=1) = 32
> 
> The above trace shows that the readahead logic is working pretty well,
> however the max readahead size(32 pages) is way too small. This can
> also be confirmed in the following table, where the average readahead
> request size/async_size and actual readahead I/O size are all 30.
> 
> linux-4dtq:/ # cat /sys/kernel/debug/readahead/stats
> pattern         count sync_count  eof_count       size async_size     actual
> none                0          0          0          0          0          0
> initial0           71         71         41          4          3          2
> initial            23         23          0          4          3          4
> subsequent       3845          4         21         31         31         31
> marker           4222          0          1         31         31         31
> trail               0          0          0          0          0          0
> oversize            0          0          0          0          0          0
> reverse             0          0          0          0          0          0
> stride              0          0          0          0          0          0
> thrash              0          0          0          0          0          0
> mmap              135        135         15         32          0         17
> fadvise           180        180        180          0          0          1
> random             23         23          2          1          0          1
> all              8499        436        260         30         30         30
>                                                     ^^^^^^^^^^^^^^^^^^^^^^^^
> 
> I suspect that your main performance problem comes from the small read/readahead size.
> If larger values are used, even the vanilla 2.6.27 kernel will perform well.

Yes, it was misconfiguration on our side: readahead size was not set 
correctly on all devices. In the correct configuration context based RA 
shows constant advantage over the current vanilla algorithm, but not as 
much as I would expect. It still performs considerably worse, than in 
case when all the IO threads work in the same IO context. To remind, our 
setup and tests described in http://lkml.org/lkml/2009/2/12/277.

Here are the conclusions from tests:

  1. Making all IO threads work in the same IO context with CFQ (vanilla 
RA and default RA size) brings near 100% link utilization on single 
stream reads (100MB/s) and with deadline about 50% (50MB/s). I.e. there 
is 100% improvement of CFQ over deadline. With 2 read streams CFQ has 
ever more advantage: >400% (23MB/s vs 5MB/s).

  2. All IO threads work in different IO contexts. With vanilla RA and 
default RA size CFQ performs 50% worse (48MB/s), even worse than deadline.

  3. All IO threads work in different IO contexts. With default RA size 
context RA brings on single stream 40% improvement with deadline (71MB/s 
vs 51MB/s), no improvement with cfq (48MB/s).

  4. All IO threads work in different IO contexts. With higher RA sizes 
there is stable 6% improvement with context RA over vanilla RA with CFQ 
starting from 20%. Deadline performs similarly. In parallel reads 
improvement is bigger: 30% on 4M RA size with deadline (39MB/s vs 27MB/s)

  5. All IO threads work in different IO contexts. The best performance 
achieved with RA maximum size 4M on both RA algorithms, but starting 
from size 1M it starts growing very slowly.

  6. Unexpected result. In case, when ll IO threads work in the same IO 
context with CFQ increasing RA size *decreases* throughput. I think this 
is, because RA requests performed as single big READ requests, while 
requests coming from remote clients are much smaller in size (up to 
256K), so, when the read by RA data transferred to the remote client on 
100MB/s speed, the backstorage media gets rotated a bit, so the next 
read request must wait the rotation latency (~0.1ms on 7200RPM). This is 
well conforms with (3) above, when context RA has 40% advantage over 
vanilla RA with default RA, but much smaller with higher RA.

Bottom line IMHO conclusions:

1. Context RA should be considered after additional examination to 
replace current RA algorithm in the kernel

2. It would be better to increase default RA size to 1024K

*AND* one of the following:

3.1. All RA requests should be split in smaller requests with size up to 
256K, which should not be merged with any other request

OR

3.2. New RA requests should be sent before the previous one completed to 
don't let the storage device rotate too far to need full rotation to 
serve the next request.

I like suggestion 3.1 a lot more, since it should be simple to implement 
and has the following 2 positive side effects:

1. It would allow to minimize negative effect of higher RA size on the 
I/O delay latency by allowing CFQ to switch to too long waiting 
requests, when necessary.

2. It would allow better requests pipelining, which is very important to 
minimize uplink latency for synchronous requests (i.e. with only one IO 
request at time, next request issued, when the previous one completed). 
You can see in http://www.3ware.com/kb/article.aspx?id=11050 that 3ware 
recommends for maximum performance set max_sectors_kb as low as *64K* 
with 16MB RA. It allows to maximize serving commands pipelining. And 
this suggestion really works allowing to improve throughput in 50-100%!

Here are the raw numbers. I also attached context RA debug output for 
2MB RA size case for your viewing pleasure.

--------------------------------------------------------------------

Performance baseline: all IO threads work in the same IO context, 
current vanilla RA, default RA size:

CFQ scheduler:

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 102 MB/s
         b) 102 MB/s
         c) 102 MB/s

Run at the same time:
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 21,6 MB/s
         b) 22,8 MB/s
         c) 24,1 MB/s
         d) 23,1 MB/s

Deadline scheduler:

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 51,1 MB/s
         b) 51,4 MB/s
         c) 51,1 MB/s

Run at the same time:
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 4,7 MB/s
         b) 4,6 MB/s
         c) 4,8 MB/s

--------------------------------------------------------------------

RA performance baseline: all IO threads work in different IO contexts, 
current vanilla RA, default RA size:

CFQ:

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 48,6 MB/s
         b) 49,2 MB/s
         c) 48,9 MB/s

Run at the same time:
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 4,2 MB/s
         b) 3,9 MB/s
         c) 4,1 MB/s

Deadline:

1) dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 53,2 MB/s
         b) 51,8 MB/s
         c) 51,6 MB/s

Run at the same time:
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 5,1 MB/s
         b) 4,6 MB/s
         c) 4,8 MB/s

--------------------------------------------------------------------

Context RA, all IO threads work in different IO contexts, default RA size:

CFQ:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 47,9 MB/s
         b) 48,2 MB/s
         c) 48,1 MB/s

Run at the same time:
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 3,5 MB/s
         b) 3,6 MB/s
         c) 3,8 MB/s

Deadline:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 72,4 MB/s
         b) 68,3 MB/s
         c) 71,3 MB/s

Run at the same time:
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
         a) 4,3 MB/s
         b) 5,0 MB/s
         c) 4,8 MB/s

--------------------------------------------------------------------

Vanilla RA, all IO threads work in different IO contexts, various RA sizes:

CFQ:

RA 512K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 60,5 MB/s
	b) 59,3 MB/s
	c) 59,7 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 9,4 MB/s
	b) 9,4 MB/s
	c) 9,1 MB/s

--- RA 1024K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 74,7 MB/s
	b) 73,2 MB/s
	c) 74,1 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 13,7 MB/s
	b) 13,6 MB/s
	c) 13,1 MB/s

--- RA 2048K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 76,7 MB/s
	b) 76,8 MB/s
	c) 76,6 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 21,8 MB/s
	b) 22,1 MB/s
	c) 20,3 MB/s

--- RA 4096K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 80,8 MB/s
	b) 80.8 MB/s
	c) 80,3 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 29,6 MB/s
	b) 29,4 MB/s
	c) 27,2 MB/s

=== Deadline:

RA 512K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 68,4 MB/s
	b) 67,0 MB/s
	c) 67,6 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 8,8 MB/s
	b) 8,9 MB/s
	c) 8,7 MB/s

--- RA 1024K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 81,0 MB/s
	b) 82,4 MB/s
	c) 81,7 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 13,5 MB/s
	b) 13,1 MB/s
	c) 12,9 MB/s

--- RA 2048K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 81,1 MB/s
	b) 80,1 MB/s
	c) 81,8 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 21,9 MB/s
	b) 20,7 MB/s
	c) 21,3 MB/s

--- RA 4096K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 83,1 MB/s
	b) 82,7 MB/s
	c) 82,9 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 27,9 MB/s
	b) 23,5 MB/s
	c) 27,6 MB/s

--------------------------------------------------------------------

Context RA, all IO threads work in different IO contexts, various RA sizes:

CFQ:

RA 512K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 63,7 MB/s
	b) 63,5 MB/s
	c) 62,8 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 7,1 MB/s
	b) 6,7 MB/s
	c) 7,0 MB/s	
	d) 6,9 MB/s

--- RA 1024K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 81,1 MB/s
	b) 81,8 MB/s
	c)  MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 14,1 MB/s
	b) 14,0 MB/s
	c) 14,1 MB/s

--- RA 2048K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 81,6 MB/s
	b) 81,4 MB/s
	c) 86,0 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 22,3 MB/s
	b) 21,5 MB/s
	c) 21,7 MB/s

--- RA 4096K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 83,1 MB/s
	b) 83,5 MB/s
	c) 82,9 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 32,8 MB/s
	b) 32,7 MB/s
	c) 30,2 MB/s

=== Deadline:

RA 512K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 68,8 MB/s
	b) 68,9 MB/s
	c) 69,0 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 8,7 MB/s
	b) 9,0 MB/s
	c) 8,9 MB/s

--- RA 1024K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 83,5 MB/s
	b) 83,1 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 14,0 MB/s
	b) 13.9 MB/s
	c) 13,8 MB/s

--- RA 2048K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 82,6 MB/s
	b) 82,4 MB/s
	c) 81,9 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 21,9 MB/s
	b) 23,1 MB/s
	c) 17,8 MB/s	
	d) 21,1 MB/s

--- RA 4096K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 84,5 MB/s
	b) 83,7 MB/s
	c) 83,8 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 39,9 MB/s
	b) 39,5 MB/s
	c) 38,4 MB/s

--------------------------------------------------------------------

all IO threads work in the same IO context, context RA, various RA sizes:

=== CFQ:

--- RA 512K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 86,4 MB/s
	b) 87,9 MB/s
	c) 86,7 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 17,8 MB/s
	b) 18,3 MB/s
	c) 17,7 MB/s

--- RA 1024K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 83,3 MB/s
	b) 81,6 MB/s
	c) 81,9 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 22,1 MB/s
	b) 21,5 MB/s
	c) 21,2 MB/s

--- RA 2048K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 81,1 MB/s
	b) 81,0 MB/s
	c) 81,6 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 22,2 MB/s
	b) 20,2 MB/s
	c) 20,9 MB/s

--- RA 4096K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 83,4 MB/s
	b) 82,8 MB/s
	c) 83,3 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 22,6 MB/s
	b) 23,4 MB/s
	c) 21,8 MB/s

=== Deadline:

--- RA 512K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 70,0 MB/s
	b) 70,7 MB/s
	c) 69,7 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 9,1 MB/s
	b) 8,3 MB/s
	c) 8,4 MB/s	

--- RA 1024K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 84,3 MB/s
	b) 83,2 MB/s
	c) 83,3 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 13,9 MB/s
	b) 13,1 MB/s
	c) 13,4 MB/s

--- RA 2048K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 82,6 MB/s
	b) 82,1 MB/s
	c) 82,3 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 21,6 MB/s
	b) 22,4 MB/s
	c) 21,3 MB/s	

--- RA 4096K:

dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 83,8 MB/s
	b) 83,8 MB/s
	c) 83,1 MB/s

Run at the same time:		
linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 39,5 MB/s
	b) 39,6 MB/s
	c) 37,0 MB/s

Thanks,
Vlad

--------------050103060508030804050409
Content-Type: application/x-bzip;
 name="ra.tar.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ra.tar.bz2"

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
kSEMKICEYUITIkAyMxFW50PrdZLqUuuuS6mTFTvYOh0MhZNTgOSzRdzuGG/HHm1NSPgMFMGL8Wro
xKUdD7m3pYPxzamtTBwcGCmVYrml7tUjgqmA4vvfQ5JoxfsQbTefcnnN0ySqqpCJJKqUUcV3yjFJ
TzFPa+do8ToUpvK40hZbL7xXXNyYZdcm001K1prttajTV22NpiQssbVpNO0a1xhbBozYRmubJNc3
CRqVsV0qy9uXGc5KwkxKyO2tS0kbpm5tSthZKvO2VG7aRKS2awnW5qS3W1zzbHJLdVeuTMktzs2W
x3XV2JpnJmzG2dbrRmIa7bSkklwjmtMZptmw121y2NhcXE2axMqWVbia1c1YjtbLnCaNZJY5wpjW
1VTXsN22Edc2rrVWOKS3ZjHTGKTWkmkkla65K1pYqRiU12160pNTNjba5sqlbGYu7NLm3NpLWsWV
zYSaSupS3XWYxLaRbdSRk2ubcQms22i1klcprq7LckJs1pZHNNktkl2b1lUjquya2G2a5qSbYlWr
dZYoiJVM56mFa1ts0gW2667QaRSS2jtbraYijM11XFtMTTSGWktlyturo0sIzJdSYlEbi2ytouos
krc7RubLooaZrGmI5JjRpm7XXXNW0vTWq6rm4TbEEZnExCmo5zs5S6mITFpGS01urbuhCLXZYKVl
quHaQu2ljM11telo0YqVa6l1tJe3LqQZm2Ousy6yENDI0rYVt62zN0u165cxuzVsW60W2KkJ2ptL
jLouI5pqXDSW4dGGExcKSTbbStLjGcySOyTNpmVLW27bY2cjtZmaasK6mpJ0bipbHRe1rjdillyZ
VFjMXFxm2jrLmMzNaJr1kWtjC21w6ubcQRdUZB6WZk0cVRu1YlNrFEWboasNraa212bbrW5yVsrV
21uIzclJmRxBVNamwrM6jSW9JmLpSpjdMVHM1baa6UayUuXFwkvMREZW5IqSY2XCXXOR11ujnbSV
2txElSpiC0mySbnVyO0tbqusm0a6GcltuzKZNhtuc0nNzuRHLW2q/P9e/E/gO4O7tvDrr6Xp+Tp4
PLbkkmSREySSSJJJJkkkkkkkSSSTJJJJJJIkkkmSSSSSSRJJMmSSSSSSRJJJMkkkkkkiSSSJJJJJ
JJIkkkmSSSSTJIkkkmSSSSSSRJJJMkkkkkkiSSSZJETJJJIkkkmSSSTJJIkkkmSSSSSSRJJJMkkk
kiSSJJJJkkkkkkkSSSSkkRMkkkiSSSZJJJJJJEkkkySSSSSSJJJJkkkkkkkSSTJkkkkkkkSSSTJJ
JJJJIkkkmSSRMkkkiSSSZJJJJJJEkkkySSSSSSJJJJkkkkkkkSSSTJJImSSSRJJJEySSSSSSJJJJ
kkkkkySJJJJkkkkkkkSSTJkkkkkkkSSSTJJJJJJIkkkmSSSSSSRJJJMkkkkkkiSSSZJJJJJJEkkk
ySSSSSSJJJJkkRMkkkiSSSZJJJJJJEkkyZJJJJJJEkkkySSSSSSJJJkySSSSSSJJJJkkkkkkkSSS
TJJJJJJIkkkmSSSSSSRJJJMkkkkkkiSSSZJJUpSlKUpVKPO+9o/b+sfe6XgXKCh83fbzj6R8+X6B
JPuOj1550HQr1esI86Fetez13OtHmwdEhrzoV6yPLC0u6vJommK8zC2Zs1qW15LHQdB0lNq6E0sd
BC2FjzzYyaOjbTOaLiaq0srjOJrUZY4sHFcTS4jYalWE1r0edEhqw0d0Ho86Fer1WdMpNGWbnkts
eryaOaTR0hrntoOhVna861kEsr1aSwrzoVYbYWGNS9I6D1sHQTWXqRYQlez13V500WG06rDOJrY9
XqsJm5xqVw0b20ZnE1rYzOJm5xuo6Q1W03NjJoV6vV6vOjNC2FWGo6DmsZghuRtttMwlliWOhXrX
s9cwmbNKsMi87rudBxB0K8mledCuo4aw1LFgTlhXGpXq9W6leu6raXNmbnE0dGali26GI9tawS80
aSx0K86FkWE0r1qwdiGTe5e88h5p5JnqajoJrUrdSvOhVhM3YUb20K9Y82DrR5sK86QuzobQqwmg
6DoOtEZCptbK86Hv513nTQ8yOsdjUdGaupbBNa9EvauhjR1o9HnRITR0ZNHEHQrzoyaVkK4rhvV5
NHWkWGpXnRkM6N02F0FnOnOjJrWQej1jCDzYJo5pr1edB0HQqw0KWvLGTa565hqV6vJok15NHRmK
V6vOjNSvVxW4d1zDUseiwmbM3OJo6NxNta82FWdrya15sK9VhDJpnrVg0t3Z0kNR0HTnWXqsM41K
sNR0E0dB0Ya9XnT6cx5186+dXq9Xq4aN0JpYgsLSvWPPRYTdqs0hkyWDEM6MjHQr1aSwTRNK9asI
zaMmledCpYNg6MmbijrWQeteWFXkvNxqOgmjoV6vVYaOJRc7rmE0day0qwmiaOhYycg8sLWE0HQd
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

--------------050103060508030804050409--
