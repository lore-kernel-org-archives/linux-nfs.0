Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:8255 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753553AbZCWBnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2009 21:43:35 -0400
Date: Mon, 23 Mar 2009 09:42:20 +0800
From: Wu Fengguang <wfg@linux.intel.com>
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lukasz.jurewicz@gmail.com
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Message-ID: <20090323014220.GA10448@localhost>
References: <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <499B0994.8040000@vlnb.net> <20090219020542.GC5743@localhost> <49C2846D.5030500@vlnb.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <49C2846D.5030500@vlnb.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 19, 2009 at 08:44:13PM +0300, Vladislav Bolkhovitin wrote:
> Wu Fengguang, on 02/19/2009 05:05 AM wrote:
>> On Tue, Feb 17, 2009 at 10:01:40PM +0300, Vladislav Bolkhovitin wrote:
>>> Wu Fengguang, on 02/13/2009 04:57 AM wrote:
>>>> On Thu, Feb 12, 2009 at 09:35:18PM +0300, Vladislav Bolkhovitin wrote:
>>>>> Sorry for such a huge delay. There were many other activities I 
>>>>> had to  do before + I had to be sure I didn't miss anything.
>>>>>
>>>>> We didn't use NFS, we used SCST (http://scst.sourceforge.net) 
>>>>> with   iSCSI-SCST target driver. It has similar to NFS 
>>>>> architecture, where N  threads (N=5 in this case) handle IO from 
>>>>> remote initiators (clients)  coming from wire using iSCSI 
>>>>> protocol. In addition, SCST has patch  called 
>>>>> export_alloc_io_context (see    
>>>>> http://lkml.org/lkml/2008/12/10/282), which allows for the IO 
>>>>> threads  queue IO using single IO context, so we can see if 
>>>>> context RA can   replace grouping IO threads in single IO 
>>>>> context.
>>>>>
>>>>> Unfortunately, the results are negative. We find neither any  
>>>>> advantages  of context RA over current RA implementation, nor  
>>>>> possibility for  context RA to replace grouping IO threads in 
>>>>> single IO context.
>>>>>
>>>>> Setup on the target (server) was the following. 2 SATA drives 
>>>>> grouped in  md RAID-0 with average local read throughput ~120MB/s 
>>>>> ("dd if=/dev/zero  of=/dev/md0 bs=1M count=20000" outputs 
>>>>> "20971520000 bytes (21 GB)  copied, 177,742 s, 118 MB/s"). The md 
>>>>> device was partitioned on 3  partitions. The first partition was 
>>>>> 10% of space in the beginning of the  device, the last partition 
>>>>> was 10% of space in the end of the device,  the middle one was 
>>>>> the rest in the middle of the space them. Then the  first and the 
>>>>> last partitions were exported to the initiator (client).  They 
>>>>> were /dev/sdb and /dev/sdc on it correspondingly.
>>>> Vladislav, Thank you for the benchmarks! I'm very interested in
>>>> optimizing your workload and figuring out what happens underneath.
>>>>
>>>> Are the client and server two standalone boxes connected by GBE?
>>>>
>>>> When you set readahead sizes in the benchmarks, you are setting them
>>>> in the server side? I.e. "linux-4dtq" is the SCST server? What's the
>>>> client side readahead size?
>>>>
>>>> It would help a lot to debug readahead if you can provide the
>>>> server side readahead stats and trace log for the worst case.
>>>> This will automatically answer the above questions as well as disclose
>>>> the micro-behavior of readahead:
>>>>
>>>>         mount -t debugfs none /sys/kernel/debug
>>>>
>>>>         echo > /sys/kernel/debug/readahead/stats # reset counters
>>>>         # do benchmark
>>>>         cat /sys/kernel/debug/readahead/stats
>>>>
>>>>         echo 1 > /sys/kernel/debug/readahead/trace_enable
>>>>         # do micro-benchmark, i.e. run the same benchmark for a short time
>>>>         echo 0 > /sys/kernel/debug/readahead/trace_enable
>>>>         dmesg
>>>>
>>>> The above readahead trace should help find out how the client side
>>>> sequential reads convert into server side random reads, and how we can
>>>> prevent that.
>>> See attached. Could you comment the logs, please, so I will also be 
>>> able  to read them in the future?
>>
>> Vladislav, thank you for the logs!
>>
>> The printk format for the following lines is:
>>
>> +       printk(KERN_DEBUG "readahead-%s(pid=%d(%s), dev=%02x:%02x(%s), "
>> +               "ino=%lu(%s), req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d\n",
>> +               ra_pattern_names[pattern],
>> +               current->pid, current->comm,
>> +               MAJOR(mapping->host->i_sb->s_dev),
>> +               MINOR(mapping->host->i_sb->s_dev),
>> +               mapping->host->i_sb->s_id,
>> +               mapping->host->i_ino,
>> +               filp->f_path.dentry->d_name.name,
>> +               offset, req_size,
>> +               ra->start, ra->size, ra->async_size,
>> +               async,
>> +               actual);
>>
>> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10596+1, ra=10628+32-32, async=1) = 32
>> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10628+1, ra=10660+32-32, async=1) = 32
>> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=10660+1, ra=10692+32-32, async=1) = 32
>> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10692+1, ra=10724+32-32, async=1) = 32
>> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10724+1, ra=10756+32-32, async=1) = 32
>> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10756+1, ra=10788+32-32, async=1) = 32
>> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10788+1, ra=10820+32-32, async=1) = 32
>> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=10820+1, ra=10852+32-32, async=1) = 32
>> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10852+1, ra=10884+32-32, async=1) = 32
>> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10884+1, ra=10916+32-32, async=1) = 32
>> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10916+1, ra=10948+32-32, async=1) = 32
>> readahead-marker(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=10948+1, ra=10980+32-32, async=1) = 32
>> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10980+1, ra=11012+32-32, async=1) = 32
>> readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=11012+1, ra=11044+32-32, async=1) = 32
>> readahead-marker(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=11044+1, ra=11076+32-32, async=1) = 32
>> readahead-subsequent(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=11076+1, ra=11108+32-32, async=1) = 32
>> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11108+1, ra=11140+32-32, async=1) = 32
>> readahead-subsequent(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11140+1, ra=11172+32-32, async=1) = 32
>> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11172+1, ra=11204+32-32, async=1) = 32
>> readahead-subsequent(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11204+1, ra=11236+32-32, async=1) = 32
>> readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=11236+1, ra=11268+32-32, async=1) = 32
>> readahead-subsequent(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=11268+1, ra=11300+32-32, async=1) = 32
>> readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11300+1, ra=11332+32-32, async=1) = 32
>> readahead-subsequent(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11332+1, ra=11364+32-32, async=1) = 32
>> readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11364+1, ra=11396+32-32, async=1) = 32
>> readahead-subsequent(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11396+1, ra=11428+32-32, async=1) = 32
>>
>> The above trace shows that the readahead logic is working pretty well,
>> however the max readahead size(32 pages) is way too small. This can
>> also be confirmed in the following table, where the average readahead
>> request size/async_size and actual readahead I/O size are all 30.
>>
>> linux-4dtq:/ # cat /sys/kernel/debug/readahead/stats
>> pattern         count sync_count  eof_count       size async_size     actual
>> none                0          0          0          0          0          0
>> initial0           71         71         41          4          3          2
>> initial            23         23          0          4          3          4
>> subsequent       3845          4         21         31         31         31
>> marker           4222          0          1         31         31         31
>> trail               0          0          0          0          0          0
>> oversize            0          0          0          0          0          0
>> reverse             0          0          0          0          0          0
>> stride              0          0          0          0          0          0
>> thrash              0          0          0          0          0          0
>> mmap              135        135         15         32          0         17
>> fadvise           180        180        180          0          0          1
>> random             23         23          2          1          0          1
>> all              8499        436        260         30         30         30
>>                                                     ^^^^^^^^^^^^^^^^^^^^^^^^
>>
>> I suspect that your main performance problem comes from the small read/readahead size.
>> If larger values are used, even the vanilla 2.6.27 kernel will perform well.
>
> Yes, it was misconfiguration on our side: readahead size was not set  
> correctly on all devices. In the correct configuration context based RA  
> shows constant advantage over the current vanilla algorithm, but not as  
> much as I would expect. It still performs considerably worse, than in  
> case when all the IO threads work in the same IO context. To remind, our  
> setup and tests described in http://lkml.org/lkml/2009/2/12/277.

Vladislav, thank you very much for the great efforts and details!

> Here are the conclusions from tests:
>
>  1. Making all IO threads work in the same IO context with CFQ (vanilla  
> RA and default RA size) brings near 100% link utilization on single  
> stream reads (100MB/s) and with deadline about 50% (50MB/s). I.e. there  
> is 100% improvement of CFQ over deadline. With 2 read streams CFQ has  
> ever more advantage: >400% (23MB/s vs 5MB/s).

The ideal 2-stream throughput should be >60MB/s, so I guess there are
still room of improvements for the CFQ's 23MB/s?

>  2. All IO threads work in different IO contexts. With vanilla RA and  
> default RA size CFQ performs 50% worse (48MB/s), even worse than 
> deadline.
>
>  3. All IO threads work in different IO contexts. With default RA size  
> context RA brings on single stream 40% improvement with deadline (71MB/s  
> vs 51MB/s), no improvement with cfq (48MB/s).
>
>  4. All IO threads work in different IO contexts. With higher RA sizes  
> there is stable 6% improvement with context RA over vanilla RA with CFQ  
> starting from 20%. Deadline performs similarly. In parallel reads  
> improvement is bigger: 30% on 4M RA size with deadline (39MB/s vs 27MB/s)

Your attached readahead trace shows that context RA is submitting
perfect 256-page async readahead IOs. (However the readahead-subsequent
cache hits are puzzling.)

The vanilla RA detects concurrent streams in a passive/opportunistic way.
The context RA works in an active/guaranteed way. It's also better at
serving the NFS style cooperative io processes. And your SCST workload
looks very like NFS.

The one fact I cannot understand is that SCST seems to breaking up the
client side 64K reads into server side 4K reads(above readahead layer).
But I remember you told me that SCST don't do NFS rsize style split-ups.
Is this a bug? The 4K read size is too small to be CPU/network friendly...
Where are the split-up and re-assemble done? On the client side or
internal to the server?

>  5. All IO threads work in different IO contexts. The best performance  
> achieved with RA maximum size 4M on both RA algorithms, but starting  
> from size 1M it starts growing very slowly.

True.

>  6. Unexpected result. In case, when ll IO threads work in the same IO  
> context with CFQ increasing RA size *decreases* throughput. I think this  
> is, because RA requests performed as single big READ requests, while  
> requests coming from remote clients are much smaller in size (up to  
> 256K), so, when the read by RA data transferred to the remote client on  
> 100MB/s speed, the backstorage media gets rotated a bit, so the next  
> read request must wait the rotation latency (~0.1ms on 7200RPM). This is  
> well conforms with (3) above, when context RA has 40% advantage over  
> vanilla RA with default RA, but much smaller with higher RA.

Maybe. But the readahead IOs (as showed by the trace) are _async_ ones...

> Bottom line IMHO conclusions:
>
> 1. Context RA should be considered after additional examination to  
> replace current RA algorithm in the kernel

That's my plan to push context RA to mainline. And thank you very much
for providing and testing out a real world application for it!

> 2. It would be better to increase default RA size to 1024K

That's a long wish to increase the default RA size. However I have a
vague feeling that it would be better to first make the lower layers
more smart on max_sectors_kb granularity request splitting and batching.

> *AND* one of the following:
>
> 3.1. All RA requests should be split in smaller requests with size up to  
> 256K, which should not be merged with any other request

Are you referring to max_sectors_kb?

What's your max_sectors_kb and nr_requests? Something like

        grep -r . /sys/block/sda/queue/

> OR
>
> 3.2. New RA requests should be sent before the previous one completed to  
> don't let the storage device rotate too far to need full rotation to  
> serve the next request.

Linus has a mmap readahead cleanup patch that can do this. It
basically replaces a {find_lock_page(); readahead();} sequence into
{find_get_page(); readahead(); lock_page();}.

I'll try to push that patch into mainline.

> I like suggestion 3.1 a lot more, since it should be simple to implement  
> and has the following 2 positive side effects:
>
> 1. It would allow to minimize negative effect of higher RA size on the  
> I/O delay latency by allowing CFQ to switch to too long waiting  
> requests, when necessary.
>
> 2. It would allow better requests pipelining, which is very important to  
> minimize uplink latency for synchronous requests (i.e. with only one IO  
> request at time, next request issued, when the previous one completed).  
> You can see in http://www.3ware.com/kb/article.aspx?id=11050 that 3ware  
> recommends for maximum performance set max_sectors_kb as low as *64K*  
> with 16MB RA. It allows to maximize serving commands pipelining. And  
> this suggestion really works allowing to improve throughput in 50-100%!
>
> Here are the raw numbers. I also attached context RA debug output for  
> 2MB RA size case for your viewing pleasure.

Thank you, it helped a lot!

(Can I wish a CONFIG_PRINTK_TIME=y next time? :-)

Thanks,
Fengguang

> --------------------------------------------------------------------
>
> Performance baseline: all IO threads work in the same IO context,  
> current vanilla RA, default RA size:
>
> CFQ scheduler:
>
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 102 MB/s
>         b) 102 MB/s
>         c) 102 MB/s
>
> Run at the same time:
> #while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 21,6 MB/s
>         b) 22,8 MB/s
>         c) 24,1 MB/s
>         d) 23,1 MB/s
>
> Deadline scheduler:
>
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 51,1 MB/s
>         b) 51,4 MB/s
>         c) 51,1 MB/s
>
> Run at the same time:
> #while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 4,7 MB/s
>         b) 4,6 MB/s
>         c) 4,8 MB/s
>
> --------------------------------------------------------------------
>
> RA performance baseline: all IO threads work in different IO contexts,  
> current vanilla RA, default RA size:
>
> CFQ:
>
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 48,6 MB/s
>         b) 49,2 MB/s
>         c) 48,9 MB/s
>
> Run at the same time:
> #while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 4,2 MB/s
>         b) 3,9 MB/s
>         c) 4,1 MB/s
>
> Deadline:
>
> 1) dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 53,2 MB/s
>         b) 51,8 MB/s
>         c) 51,6 MB/s
>
> Run at the same time:
> #while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> #dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 5,1 MB/s
>         b) 4,6 MB/s
>         c) 4,8 MB/s
>
> --------------------------------------------------------------------
>
> Context RA, all IO threads work in different IO contexts, default RA size:
>
> CFQ:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 47,9 MB/s
>         b) 48,2 MB/s
>         c) 48,1 MB/s
>
> Run at the same time:
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 3,5 MB/s
>         b) 3,6 MB/s
>         c) 3,8 MB/s
>
> Deadline:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 72,4 MB/s
>         b) 68,3 MB/s
>         c) 71,3 MB/s
>
> Run at the same time:
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
>         a) 4,3 MB/s
>         b) 5,0 MB/s
>         c) 4,8 MB/s
>
> --------------------------------------------------------------------
>
> Vanilla RA, all IO threads work in different IO contexts, various RA sizes:
>
> CFQ:
>
> RA 512K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 60,5 MB/s
> 	b) 59,3 MB/s
> 	c) 59,7 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 9,4 MB/s
> 	b) 9,4 MB/s
> 	c) 9,1 MB/s
>
> --- RA 1024K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 74,7 MB/s
> 	b) 73,2 MB/s
> 	c) 74,1 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 13,7 MB/s
> 	b) 13,6 MB/s
> 	c) 13,1 MB/s
>
> --- RA 2048K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 76,7 MB/s
> 	b) 76,8 MB/s
> 	c) 76,6 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 21,8 MB/s
> 	b) 22,1 MB/s
> 	c) 20,3 MB/s
>
> --- RA 4096K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 80,8 MB/s
> 	b) 80.8 MB/s
> 	c) 80,3 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 29,6 MB/s
> 	b) 29,4 MB/s
> 	c) 27,2 MB/s
>
> === Deadline:
>
> RA 512K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 68,4 MB/s
> 	b) 67,0 MB/s
> 	c) 67,6 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 8,8 MB/s
> 	b) 8,9 MB/s
> 	c) 8,7 MB/s
>
> --- RA 1024K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 81,0 MB/s
> 	b) 82,4 MB/s
> 	c) 81,7 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 13,5 MB/s
> 	b) 13,1 MB/s
> 	c) 12,9 MB/s
>
> --- RA 2048K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 81,1 MB/s
> 	b) 80,1 MB/s
> 	c) 81,8 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 21,9 MB/s
> 	b) 20,7 MB/s
> 	c) 21,3 MB/s
>
> --- RA 4096K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 83,1 MB/s
> 	b) 82,7 MB/s
> 	c) 82,9 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 27,9 MB/s
> 	b) 23,5 MB/s
> 	c) 27,6 MB/s
>
> --------------------------------------------------------------------
>
> Context RA, all IO threads work in different IO contexts, various RA sizes:
>
> CFQ:
>
> RA 512K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 63,7 MB/s
> 	b) 63,5 MB/s
> 	c) 62,8 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 7,1 MB/s
> 	b) 6,7 MB/s
> 	c) 7,0 MB/s	
> 	d) 6,9 MB/s
>
> --- RA 1024K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 81,1 MB/s
> 	b) 81,8 MB/s
> 	c)  MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 14,1 MB/s
> 	b) 14,0 MB/s
> 	c) 14,1 MB/s
>
> --- RA 2048K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 81,6 MB/s
> 	b) 81,4 MB/s
> 	c) 86,0 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 22,3 MB/s
> 	b) 21,5 MB/s
> 	c) 21,7 MB/s
>
> --- RA 4096K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 83,1 MB/s
> 	b) 83,5 MB/s
> 	c) 82,9 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 32,8 MB/s
> 	b) 32,7 MB/s
> 	c) 30,2 MB/s
>
> === Deadline:
>
> RA 512K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 68,8 MB/s
> 	b) 68,9 MB/s
> 	c) 69,0 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 8,7 MB/s
> 	b) 9,0 MB/s
> 	c) 8,9 MB/s
>
> --- RA 1024K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 83,5 MB/s
> 	b) 83,1 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 14,0 MB/s
> 	b) 13.9 MB/s
> 	c) 13,8 MB/s
>
> --- RA 2048K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 82,6 MB/s
> 	b) 82,4 MB/s
> 	c) 81,9 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 21,9 MB/s
> 	b) 23,1 MB/s
> 	c) 17,8 MB/s	
> 	d) 21,1 MB/s
>
> --- RA 4096K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 84,5 MB/s
> 	b) 83,7 MB/s
> 	c) 83,8 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 39,9 MB/s
> 	b) 39,5 MB/s
> 	c) 38,4 MB/s
>
> --------------------------------------------------------------------
>
> all IO threads work in the same IO context, context RA, various RA sizes:
>
> === CFQ:
>
> --- RA 512K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 86,4 MB/s
> 	b) 87,9 MB/s
> 	c) 86,7 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 17,8 MB/s
> 	b) 18,3 MB/s
> 	c) 17,7 MB/s
>
> --- RA 1024K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 83,3 MB/s
> 	b) 81,6 MB/s
> 	c) 81,9 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 22,1 MB/s
> 	b) 21,5 MB/s
> 	c) 21,2 MB/s
>
> --- RA 2048K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 81,1 MB/s
> 	b) 81,0 MB/s
> 	c) 81,6 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 22,2 MB/s
> 	b) 20,2 MB/s
> 	c) 20,9 MB/s
>
> --- RA 4096K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 83,4 MB/s
> 	b) 82,8 MB/s
> 	c) 83,3 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 22,6 MB/s
> 	b) 23,4 MB/s
> 	c) 21,8 MB/s
>
> === Deadline:
>
> --- RA 512K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 70,0 MB/s
> 	b) 70,7 MB/s
> 	c) 69,7 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 9,1 MB/s
> 	b) 8,3 MB/s
> 	c) 8,4 MB/s	
>
> --- RA 1024K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 84,3 MB/s
> 	b) 83,2 MB/s
> 	c) 83,3 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 13,9 MB/s
> 	b) 13,1 MB/s
> 	c) 13,4 MB/s
>
> --- RA 2048K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 82,6 MB/s
> 	b) 82,1 MB/s
> 	c) 82,3 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 21,6 MB/s
> 	b) 22,4 MB/s
> 	c) 21,3 MB/s	
>
> --- RA 4096K:
>
> dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 83,8 MB/s
> 	b) 83,8 MB/s
> 	c) 83,1 MB/s
>
> Run at the same time:		
> linux-4dtq:~ # while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
> linux-4dtq:~ # dd if=/dev/sdb of=/dev/null bs=64K count=80000
> 	a) 39,5 MB/s
> 	b) 39,6 MB/s
> 	c) 37,0 MB/s
>
> Thanks,
> Vlad


