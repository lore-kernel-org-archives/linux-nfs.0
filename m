Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:48974 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751381AbZBSCFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Feb 2009 21:05:45 -0500
Date: Thu, 19 Feb 2009 10:05:42 +0800
From: Wu Fengguang <wfg@linux.intel.com>
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Message-ID: <20090219020542.GC5743@localhost>
References: <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <499B0994.8040000@vlnb.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <499B0994.8040000@vlnb.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 17, 2009 at 10:01:40PM +0300, Vladislav Bolkhovitin wrote:
> Wu Fengguang, on 02/13/2009 04:57 AM wrote:
>> On Thu, Feb 12, 2009 at 09:35:18PM +0300, Vladislav Bolkhovitin wrote:
>>> Sorry for such a huge delay. There were many other activities I had 
>>> to  do before + I had to be sure I didn't miss anything.
>>>
>>> We didn't use NFS, we used SCST (http://scst.sourceforge.net) with   
>>> iSCSI-SCST target driver. It has similar to NFS architecture, where N 
>>>  threads (N=5 in this case) handle IO from remote initiators 
>>> (clients)  coming from wire using iSCSI protocol. In addition, SCST 
>>> has patch  called export_alloc_io_context (see   
>>> http://lkml.org/lkml/2008/12/10/282), which allows for the IO threads 
>>>  queue IO using single IO context, so we can see if context RA can   
>>> replace grouping IO threads in single IO context.
>>>
>>> Unfortunately, the results are negative. We find neither any 
>>> advantages  of context RA over current RA implementation, nor 
>>> possibility for  context RA to replace grouping IO threads in single 
>>> IO context.
>>>
>>> Setup on the target (server) was the following. 2 SATA drives grouped 
>>> in  md RAID-0 with average local read throughput ~120MB/s ("dd 
>>> if=/dev/zero  of=/dev/md0 bs=1M count=20000" outputs "20971520000 
>>> bytes (21 GB)  copied, 177,742 s, 118 MB/s"). The md device was 
>>> partitioned on 3  partitions. The first partition was 10% of space in 
>>> the beginning of the  device, the last partition was 10% of space in 
>>> the end of the device,  the middle one was the rest in the middle of 
>>> the space them. Then the  first and the last partitions were exported 
>>> to the initiator (client).  They were /dev/sdb and /dev/sdc on it 
>>> correspondingly.
>>
>> Vladislav, Thank you for the benchmarks! I'm very interested in
>> optimizing your workload and figuring out what happens underneath.
>>
>> Are the client and server two standalone boxes connected by GBE?
>>
>> When you set readahead sizes in the benchmarks, you are setting them
>> in the server side? I.e. "linux-4dtq" is the SCST server? What's the
>> client side readahead size?
>>
>> It would help a lot to debug readahead if you can provide the
>> server side readahead stats and trace log for the worst case.
>> This will automatically answer the above questions as well as disclose
>> the micro-behavior of readahead:
>>
>>         mount -t debugfs none /sys/kernel/debug
>>
>>         echo > /sys/kernel/debug/readahead/stats # reset counters
>>         # do benchmark
>>         cat /sys/kernel/debug/readahead/stats
>>
>>         echo 1 > /sys/kernel/debug/readahead/trace_enable
>>         # do micro-benchmark, i.e. run the same benchmark for a short time
>>         echo 0 > /sys/kernel/debug/readahead/trace_enable
>>         dmesg
>>
>> The above readahead trace should help find out how the client side
>> sequential reads convert into server side random reads, and how we can
>> prevent that.
>
> See attached. Could you comment the logs, please, so I will also be able  
> to read them in the future?

Vladislav, thank you for the logs!

The printk format for the following lines is:

+       printk(KERN_DEBUG "readahead-%s(pid=%d(%s), dev=%02x:%02x(%s), "
+               "ino=%lu(%s), req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d\n",
+               ra_pattern_names[pattern],
+               current->pid, current->comm,
+               MAJOR(mapping->host->i_sb->s_dev),
+               MINOR(mapping->host->i_sb->s_dev),
+               mapping->host->i_sb->s_id,
+               mapping->host->i_ino,
+               filp->f_path.dentry->d_name.name,
+               offset, req_size,
+               ra->start, ra->size, ra->async_size,
+               async,
+               actual);

readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10596+1, ra=10628+32-32, async=1) = 32
readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10628+1, ra=10660+32-32, async=1) = 32
readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=10660+1, ra=10692+32-32, async=1) = 32
readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10692+1, ra=10724+32-32, async=1) = 32
readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10724+1, ra=10756+32-32, async=1) = 32
readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10756+1, ra=10788+32-32, async=1) = 32
readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10788+1, ra=10820+32-32, async=1) = 32
readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=10820+1, ra=10852+32-32, async=1) = 32
readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=10852+1, ra=10884+32-32, async=1) = 32
readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10884+1, ra=10916+32-32, async=1) = 32
readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=10916+1, ra=10948+32-32, async=1) = 32
readahead-marker(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=10948+1, ra=10980+32-32, async=1) = 32
readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=10980+1, ra=11012+32-32, async=1) = 32
readahead-marker(pid=3838(vdiskd3_3), dev=00:02(bdev), ino=0(raid-1st), req=11012+1, ra=11044+32-32, async=1) = 32
readahead-marker(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=11044+1, ra=11076+32-32, async=1) = 32
readahead-subsequent(pid=3836(vdiskd3_1), dev=00:02(bdev), ino=0(raid-1st), req=11076+1, ra=11108+32-32, async=1) = 32
readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11108+1, ra=11140+32-32, async=1) = 32
readahead-subsequent(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11140+1, ra=11172+32-32, async=1) = 32
readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11172+1, ra=11204+32-32, async=1) = 32
readahead-subsequent(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11204+1, ra=11236+32-32, async=1) = 32
readahead-marker(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=11236+1, ra=11268+32-32, async=1) = 32
readahead-subsequent(pid=3837(vdiskd3_2), dev=00:02(bdev), ino=0(raid-1st), req=11268+1, ra=11300+32-32, async=1) = 32
readahead-marker(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11300+1, ra=11332+32-32, async=1) = 32
readahead-subsequent(pid=3835(vdiskd3_0), dev=00:02(bdev), ino=0(raid-1st), req=11332+1, ra=11364+32-32, async=1) = 32
readahead-marker(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11364+1, ra=11396+32-32, async=1) = 32
readahead-subsequent(pid=3839(vdiskd3_4), dev=00:02(bdev), ino=0(raid-1st), req=11396+1, ra=11428+32-32, async=1) = 32

The above trace shows that the readahead logic is working pretty well,
however the max readahead size(32 pages) is way too small. This can
also be confirmed in the following table, where the average readahead
request size/async_size and actual readahead I/O size are all 30.

linux-4dtq:/ # cat /sys/kernel/debug/readahead/stats
pattern         count sync_count  eof_count       size async_size     actual
none                0          0          0          0          0          0
initial0           71         71         41          4          3          2
initial            23         23          0          4          3          4
subsequent       3845          4         21         31         31         31
marker           4222          0          1         31         31         31
trail               0          0          0          0          0          0
oversize            0          0          0          0          0          0
reverse             0          0          0          0          0          0
stride              0          0          0          0          0          0
thrash              0          0          0          0          0          0
mmap              135        135         15         32          0         17
fadvise           180        180        180          0          0          1
random             23         23          2          1          0          1
all              8499        436        260         30         30         30
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^

I suspect that your main performance problem comes from the small read/readahead size.
If larger values are used, even the vanilla 2.6.27 kernel will perform well.

Thanks,
Fengguang
