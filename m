Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32706 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbZBSBfr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Feb 2009 20:35:47 -0500
Date: Thu, 19 Feb 2009 09:35:43 +0800
From: Wu Fengguang <wfg@linux.intel.com>
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Message-ID: <20090219013543.GA5743@localhost>
References: <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <4995D339.5050502@vlnb.net> <20090216023402.GA6199@localhost> <499B09FB.1070909@vlnb.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <499B09FB.1070909@vlnb.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 17, 2009 at 10:03:23PM +0300, Vladislav Bolkhovitin wrote:
> Wu Fengguang, on 02/16/2009 05:34 AM wrote:
>> On Fri, Feb 13, 2009 at 11:08:25PM +0300, Vladislav Bolkhovitin wrote:
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
>>> Yes, they directly connected using GbE.
>>>
>>>> When you set readahead sizes in the benchmarks, you are setting them
>>>> in the server side? I.e. "linux-4dtq" is the SCST server?
>>> Yes, it's the server. On the client all the parameters were left default.
>>>
>>>> What's the
>>>> client side readahead size?
>>> Default, i.e. 128K
>>>
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
>>> We will do it as soon as we have a free window on that system.
>>
>> Thank you. For NFS, the client side read/readahead requests will be
>> split into units of rsize which will be served by a pool of nfsd
>> concurrently and possibly out of order. Does SCST have the same
>> process? If so, what's the rsize value for your SCST benchmarks?
>
> No, there is no such splitting in SCST. Client sees raw SCSI disks from  
> server and what client sends is directly and in full size sent by the  
> server to its backstorage using regular buffered read()  
> (fd->f_op->aio_read() followed by  
> wait_on_retry_sync_kiocb()/wait_on_sync_kiocb() to be precise).

Then it's weird that the server is seeing 1-page sized read requests:

        readahead-marker(pid=3844(vdiskd4_4), dev=00:02(bdev), ino=0(raid-3rd), req=9160+1, ra=9192+32-32, async=1) = 32
        readahead-marker(pid=3842(vdiskd4_2), dev=00:02(bdev), ino=0(raid-3rd), req=9192+1, ra=9224+32-32, async=1) = 32
        readahead-marker(pid=3841(vdiskd4_1), dev=00:02(bdev), ino=0(raid-3rd), req=9224+1, ra=9256+32-32, async=1) = 32
        readahead-marker(pid=3844(vdiskd4_4), dev=00:02(bdev), ino=0(raid-3rd), req=9256+1, ra=9288+32-32, async=1) = 32

Here the first line means a 32-page readahead I/O was submitted for a
1-page read request.

The 1-page read size only adds overheads to CPU/NIC, but not disk I/O.
The trace shows that readahead is doing a good job, however the
readahead size is the default 128K, not 2M. That's a big problem.

The command "blockdev --setra 4096 /dev/sda" takes no effect at all.
Maybe you should put that command after mdadm? i.e.

        linux-4dtq:~ # mdadm --assemble /dev/md0 /dev/sd[ab]

        linux-4dtq:~ # blockdev --setra 4096 /dev/sda
        linux-4dtq:~ # blockdev --setra 4096 /dev/sdb

Thanks,
Fengguang
