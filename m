From: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
Date: Fri, 13 Feb 2009 23:08:25 +0300
Message-ID: <4995D339.5050502@vlnb.net>
References: <492BDAA9.4090405@vlnb.net> <20081125113048.GB16422@localhost> <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
	"Vitaly V. Bursov" <vitalyb-CNXmb7IdZIXO1JJkmS+EZg@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:59864 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbZBMUIL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2009 15:08:11 -0500
In-Reply-To: <20090213015721.GA5565@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wu Fengguang, on 02/13/2009 04:57 AM wrote:
> On Thu, Feb 12, 2009 at 09:35:18PM +0300, Vladislav Bolkhovitin wrote:
>> Sorry for such a huge delay. There were many other activities I had to  
>> do before + I had to be sure I didn't miss anything.
>>
>> We didn't use NFS, we used SCST (http://scst.sourceforge.net) with  
>> iSCSI-SCST target driver. It has similar to NFS architecture, where N  
>> threads (N=5 in this case) handle IO from remote initiators (clients)  
>> coming from wire using iSCSI protocol. In addition, SCST has patch  
>> called export_alloc_io_context (see  
>> http://lkml.org/lkml/2008/12/10/282), which allows for the IO threads  
>> queue IO using single IO context, so we can see if context RA can  
>> replace grouping IO threads in single IO context.
>>
>> Unfortunately, the results are negative. We find neither any advantages  
>> of context RA over current RA implementation, nor possibility for  
>> context RA to replace grouping IO threads in single IO context.
>>
>> Setup on the target (server) was the following. 2 SATA drives grouped in  
>> md RAID-0 with average local read throughput ~120MB/s ("dd if=/dev/zero  
>> of=/dev/md0 bs=1M count=20000" outputs "20971520000 bytes (21 GB)  
>> copied, 177,742 s, 118 MB/s"). The md device was partitioned on 3  
>> partitions. The first partition was 10% of space in the beginning of the  
>> device, the last partition was 10% of space in the end of the device,  
>> the middle one was the rest in the middle of the space them. Then the  
>> first and the last partitions were exported to the initiator (client).  
>> They were /dev/sdb and /dev/sdc on it correspondingly.
> 
> Vladislav, Thank you for the benchmarks! I'm very interested in
> optimizing your workload and figuring out what happens underneath.
> 
> Are the client and server two standalone boxes connected by GBE?

Yes, they directly connected using GbE.

> When you set readahead sizes in the benchmarks, you are setting them
> in the server side? I.e. "linux-4dtq" is the SCST server?

Yes, it's the server. On the client all the parameters were left default.

> What's the
> client side readahead size?

Default, i.e. 128K

> It would help a lot to debug readahead if you can provide the
> server side readahead stats and trace log for the worst case.
> This will automatically answer the above questions as well as disclose
> the micro-behavior of readahead:
> 
>         mount -t debugfs none /sys/kernel/debug
> 
>         echo > /sys/kernel/debug/readahead/stats # reset counters
>         # do benchmark
>         cat /sys/kernel/debug/readahead/stats
> 
>         echo 1 > /sys/kernel/debug/readahead/trace_enable
>         # do micro-benchmark, i.e. run the same benchmark for a short time
>         echo 0 > /sys/kernel/debug/readahead/trace_enable
>         dmesg
> 
> The above readahead trace should help find out how the client side
> sequential reads convert into server side random reads, and how we can
> prevent that.

We will do it as soon as we have a free window on that system.

Thanks,
Vlad
