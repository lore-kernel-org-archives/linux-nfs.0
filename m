Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:54221 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690AbZBLSfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2009 13:35:05 -0500
Message-ID: <49946BE6.1040005@vlnb.net>
Date: Thu, 12 Feb 2009 21:35:18 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
To: Wu Fengguang <wfg@linux.intel.com>, Jens Axboe <jens.axboe@oracle.com>
CC: Jeff Moyer <jmoyer@redhat.com>, "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
References: <20081112190227.GS26778@kernel.dk> <1226566313.199910.29888@de> <492BDAA9.4090405@vlnb.net> <20081125113048.GB16422@localhost> <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost>
In-Reply-To: <20081128004830.GA8874@localhost>
Content-Type: multipart/mixed;
 boundary="------------030909090709030109010503"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------030909090709030109010503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Wu Fengguang, on 11/28/2008 03:48 AM wrote:
>> Actually, there's one more thing, which should have been mentioned. It
>> is possible that remote clients have several sequential read streams at
>> time together with some "noise" of random requests. A good read-ahead
>> subsystem should handle such case by keeping big read-ahead windows for
>> the sequential streams and don't do any read ahead for the random
>> requests. And all at the same time.
>>
>> Currently on such workloads read ahead will be completely disabled for
>> all the requests. Hence, there is a possibility here to improve
>> performance in 3-5 times or even more by making the workload more linear.
> 
> Are you sure? I'd expect such mixed-sequential-random pattern to be
> handled by the current readahead code pretty well: sequential ones
> will get large readahead and random ones won't get readahead at all.

No, sorry, my data was outdated. I rechecked and it works quite well now.

> Attached is the context readahead patch plus a kernel module for
> readahead tracing and accounting, which will hopefully help clarify the
> read patterns and readahead behaviors on production workloads. It is
> based on 2.6.27 for your convenience, but also applies to 2.6.28.
> 
> The patch is not targeted for code review, but if anyone are interested,
> you can take a look at try_context_readahead(). This is the only newly
> introduced readahead policy, the other majorities are code refactor
> and tracing facilities.
> 
> The newly introduced context readahead policy is disabled by default.
> To enable it:
>         echo 1 > /sys/block/sda/queue/context_readahead
> I'm not sure for now whether this parameter will be a long term one, or
> whether the context readahead policy should be enabled unconditionally.
> 
> The readahead accounting stats can be viewed by
>         mount -t debugfs none /sys/kernel/debug
>         cat /sys/kernel/debug/readahead/stats
> The numbers can be reset by
>         echo > /sys/kernel/debug/readahead/stats
> 
> Here is a sample output from my desktop:
> 
> % cat /sys/kernel/debug/readahead/stats
> pattern         count sync_count  eof_count       size async_size     actual
> none                0          0          0          0          0          0
> initial0         3009       3009       2033          5          4          2
> initial            35         35          0          5          4          3
> subsequent       1294        240        827         52         49         26
> marker            220          0        109         54         53         29
> trail               0          0          0          0          0          0
> oversize            0          0          0          0          0          0
> reverse             0          0          0          0          0          0
> stride              0          0          0          0          0          0
> thrash              0          0          0          0          0          0
> mmap             2833       2833       1379        142          0         47
> fadvise             7          7          7          0          0         40
> random           7621       7621         69          1          0          1
> all             15019      13745       4424         33          5         12
> 
> The readahead/read tracing messages are disabled by default.
> To enable them:
>         echo 1 > /sys/kernel/debug/readahead/trace_enable
>         echo 1 > /sys/kernel/debug/readahead/read_jprobes
> They(especially the latter one) will generate a lot of printk messages like:
> 
> [  828.151013] readahead-initial0(pid=4644(zsh), dev=00:10(0:10), ino=351452(whoami), req=0+1, ra=0+4-3, async=0) = 4
> [  828.167853] readahead-mmap(pid=4644(whoami), dev=00:10(0:10), ino=351452(whoami), req=0+0, ra=0+60-0, async=0) = 3
> [  828.195652] readahead-initial0(pid=4629(zsh), dev=00:10(0:10), ino=115569(zsh_prompt), req=0+128, ra=0+120-60, async=0) = 3
> [  828.225081] readahead-initial0(pid=4629(zsh), dev=00:10(0:10), ino=342086(.zsh_history), req=0+128, ra=0+120-60, async=0) = 4
> 
> [  964.471450] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=351445(wc), pos=0, count=128)
> [  964.471544] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=351445(wc), pos=64, count=448)
> [  964.471575] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=351445(wc), pos=512, count=28)
> [  964.472659] do_generic_file_read(pid=4685(zsh), dev=00:10(0:10), ino=383002(ld-2.7.so), pos=0, count=128)
> [  964.473431] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=383002(ld-2.7.so), pos=64, count=336)
> [  964.475639] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=383010(libc-2.7.so), pos=0, count=832)
> [  964.479037] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=196085(locale.alias), pos=0, count=524288)
> [  964.479166] do_generic_file_read(pid=4685(wc), dev=00:10(0:10), ino=196085(locale.alias), pos=2586, count=524288)
> 
> So please enable them only when necessary.
> 
> My recommendation for the double readahead in NFS client and NFS servers,
> is to keep client side readahead size small and the server side one large.
> For example, 128K-512K/1M-2M(more for RAID). The NFS client side readahead size
> is not directly tunable, but setting rsize to a small value does the trick.
> Currently the NFS magic is readahead_size=N*rsize. The default numbers in my
> 2.6.28 kernel are rsize=512k, N=15, readahead_size=7680k. The latter is
> obviously way too large.

Sorry for such a huge delay. There were many other activities I had to 
do before + I had to be sure I didn't miss anything.

We didn't use NFS, we used SCST (http://scst.sourceforge.net) with 
iSCSI-SCST target driver. It has similar to NFS architecture, where N 
threads (N=5 in this case) handle IO from remote initiators (clients) 
coming from wire using iSCSI protocol. In addition, SCST has patch 
called export_alloc_io_context (see 
http://lkml.org/lkml/2008/12/10/282), which allows for the IO threads 
queue IO using single IO context, so we can see if context RA can 
replace grouping IO threads in single IO context.

Unfortunately, the results are negative. We find neither any advantages 
of context RA over current RA implementation, nor possibility for 
context RA to replace grouping IO threads in single IO context.

Setup on the target (server) was the following. 2 SATA drives grouped in 
md RAID-0 with average local read throughput ~120MB/s ("dd if=/dev/zero 
of=/dev/md0 bs=1M count=20000" outputs "20971520000 bytes (21 GB) 
copied, 177,742 s, 118 MB/s"). The md device was partitioned on 3 
partitions. The first partition was 10% of space in the beginning of the 
device, the last partition was 10% of space in the end of the device, 
the middle one was the rest in the middle of the space them. Then the 
first and the last partitions were exported to the initiator (client). 
They were /dev/sdb and /dev/sdc on it correspondingly.

Then 4 2.6.27.12 kernels were build:

1. With all SCST patches

2. With all SCST patches, except export_alloc_io_context

3. With all SCST patches + context RA patch

4. With all SCST patches, except export_alloc_io_context, but with 
context RA patch.

Memory on both initiator and target was limited to 512MB. Link was 1GbE.

Then for those kernels the following tests were ran:

1. dd if=/dev/sdb of=/dev/null bs=64K count=80000

2. dd if=/dev/sdc of=/dev/null bs=64K count=80000

3. while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done and 
simultaneously dd if=/dev/sdb of=/dev/null bs=64K count=80000. Results 
from the latter dd was written. This test allowed to see how well 
simultaneous reads are handled.

You can find the results in the attachement.

You can see that context RA doesn't improve anything, while grouping IO 
in single IO context provides almost 100% improvement in throughput.

Additional interesting observation is how badly simultaneous read IO 
streams are handled, if they aren't grouped in the corresponding IO 
contexts. In test 3 the result was as low as 4(!)MB/s. Wu, Jens, do you 
have any explanation on this? Why the inner tracks have so big preference?

Another thing looks suspicious for me. If simultaneous read IO streams 
are sent and they are grouped in the corresponding IO contexts, dd from 
sdb has only 20MB/s throughput. Considering that a single stream from it 
has about 100MB/s, shouldn't that value be at least 30-35MB/s? Is it the 
same issue as above, but with smaller implication?

Thanks,
Vlad

--------------030909090709030109010503
Content-Type: text/plain;
 name="cfq-scheduler.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cfq-scheduler.txt"

kernel: 2.6.27.12-all_patches - all scst patches


#cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]
#cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]

#free
             total       used       free     shared    buffers     cached
Mem:        508180     502448       5732          0     430704      27740
-/+ buffers/cache:      44004     464176
Swap:            0          0          0


scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 102 MB/s
	b) 102 MB/s
	c) 102 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 74,3 MB/s
	b) 74,5 MB/s
	c) 74,4 MB/s

Run at the same time:		
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 21,6 MB/s
	b) 22,8 MB/s
	c) 24,1 MB/s
	d) 23,1 MB/s
	
------------------------------------------------------------------------
kernel: 2.6.27.12-except_export_alloc - all scst patches, except export_alloc_io_context.patch

# cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
# cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]


scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 48,6 MB/s
	b) 49,2 MB/s
	c) 48,9 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 48,3 MB/s
	b) 48,5 MB/s
	c) 47,9 MB/s

Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 4,2 MB/s
	b) 3,9 MB/s
	c) 4,1 MB/s


	
---------------------------------------------------------------
kernel: uname -r 2.6.27.12-readahead - all scst patches + readahead-context.patch
default /dev/md0 readahead = 512
linux-4dtq:~ #
linux-4dtq:~ #
linux-4dtq:~ # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # blockdev --setra 1024 /dev/sda
linux-4dtq:~ # blockdev --setra 1024 /dev/sdb
linux-4dtq:~ # echo 1 > /sys/block/sda/queue/context_readahead
linux-4dtq:~ # echo 1 > /sys/block/sdb/queue/context_readahead
linux-4dtq:~ # cat /sys/block/sdb/queue/context_readahead
1
linux-4dtq:~ # cat /sys/block/sda/queue/context_readahead
1
linux-4dtq:~ # blockdev --getra /dev/md0
256
linux-4dtq:~ # mdadm --assemble /dev/md0 /dev/sd[ab]
mdadm: /dev/md/0 has been started with 2 drives.
linux-4dtq:~ # vgchange -a y
  3 logical volume(s) in volume group "raid" now active
linux-4dtq:~ # blockdev --getra /dev/md0
512
linux-4dtq:~ # free
             total       used       free     shared    buffers     cached
Mem:        508168     104480     403688          0       4516      64632
-/+ buffers/cache:      35332     472836
Swap:            0          0          0


	
scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048


#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 96,9 MB/s
	b) 101 MB/s
	c) 101, MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 73,9 MB/s
	b) 74,1 MB/s
	c) 73,3 MB/s

Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 22,1 MB/s
	b) 21,6 MB/s
	c) 21,1 MB/s

	
	
	
-----------------------------------------------------------------------------------
kernel: uname -r 2.6.27.12-readahead - all scst patches + readahead-context.patch
set: /dev/md0 readahead = 1024

linux-4dtq:~ # blockdev --setra 1024 /dev/sdb
linux-4dtq:~ # blockdev --setra 1024 /dev/sda
linux-4dtq:~ # blockdev --setra 1024 /dev/md0
linux-4dtq:~ # echo 1 > /sys/block/sda/queue/context_readahead
linux-4dtq:~ # echo 1 > /sys/block/sdb/queue/context_readahead
linux-4dtq:~ # cat /sys/block/sdb/queue/context_readahead
1
linux-4dtq:~ # cat /sys/block/sda/queue/context_readahead
1
linux-4dtq:~ # mdadm --assemble /dev/md0 /dev/sd[ab]
mdadm: /dev/md/0 has been started with 2 drives.
linux-4dtq:~ # vgchange -a y
  3 logical volume(s) in volume group "raid" now active
linux-4dtq:~ # blockdev --getra /dev/md0
1024
linux-4dtq:~ # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]

scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a)  102 MB/s
	b)  100 MB/s
	c)  104 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a)  74,1 MB/s
	b)  73,7 MB/s
	c)  74,0 MB/s

Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a)  22,0 MB/s
	b)  21,5 MB/s
	c)  22,9 MB/s

------------------------------------------------------------------------
kernel: uname -r 2.6.27.12-readahead - all scst patches + readahead-context.patch
set: /dev/md0 readahead = 2048

linux-4dtq:~ # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # echo 1 > /sys/block/sdb/queue/context_readahead
linux-4dtq:~ # echo 1 > /sys/block/sda/queue/context_readahead
linux-4dtq:~ # blockdev --setra 1024 /dev/sda
linux-4dtq:~ # blockdev --setra 1024 /dev/sdb
linux-4dtq:~ # blockdev --setra 2048 /dev/md0
linux-4dtq:~ # mdadm --assemble /dev/md0 /dev/sd[ab]
mdadm: /dev/md/0 has been started with 2 drives.
linux-4dtq:~ # vgchange -a y
  3 logical volume(s) in volume group "raid" now active
linux-4dtq:~ # cat /sys/block/sdb/queue/context_readahead
1
linux-4dtq:~ # cat /sys/block/sda/queue/context_readahead
1
linux-4dtq:~ # blockdev --getra /dev/md0
2048


scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 103 MB/s
	b) 102 MB/s
	c) 102 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 73,7 MB/s
	b) 74,1 MB/s
	c) 74,3 MB/s

Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 20,1 MB/s
	b) 21,5 MB/s
	c) 21,8 MB/s

---------------------------------------------------
Kernel uname -r: 2.6.27.12-readahead
readahead set to: 4M

linux-4dtq:~ # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # blockdev --setra 4096 /dev/sda
linux-4dtq:~ # blockdev --setra 4096 /dev/sdb
linux-4dtq:~ # blockdev --getra /dev/sdb
4096
linux-4dtq:~ # blockdev --getra /dev/sda
4096
inux-4dtq:~ # echo 1 > /sys/block/sdb/queue/context_readahead
linux-4dtq:~ # echo 1 > /sys/block/sda/queue/context_readahead
linux-4dtq:~ # cat /sys/block/sdb/queue/context_readahead
1
linux-4dtq:~ # cat /sys/block/sda/queue/context_readahead
1
linux-4dtq:~ # mdadm --assemble /dev/md0 /dev/sd[ab]
mdadm: /dev/md/0 has been started with 2 drives.
linux-4dtq:~ # vgchange -a y
  3 logical volume(s) in volume group "raid" now active
linux-4dtq:~ # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]

scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 99,4 MB/s
	b) 96,4 MB/s
	c) 101 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 73,5 MB/s
	b) 74,3 MB/s
	c) 73,9 MB/s

Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 21,0 MB/s
	b) 19,8 MB/s
	c) 22,4 MB/s

------------------------------------------------------------------------
kernel: uname -r 2.6.27.12-except_export+readahead - all scst patches except export_alloc_io_context.patch + readahead-contex.patch
default /dev/md0 readahead = 512

linux-4dtq:/.kernels/scst-kernel-4/scstadmin # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:/.kernels/scst-kernel-4/scstadmin # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:/.kernels/scst-kernel-4/scstadmin # blockdev --getra /dev/sda
1024
linux-4dtq:/.kernels/scst-kernel-4/scstadmin # blockdev --getra /dev/sdb
1024
linux-4dtq:/.kernels/scst-kernel-4/scstadmin # blockdev --getra /dev/md0
512
linux-4dtq:/.kernels/scst-kernel-4/scstadmin # cat /sys/block/sdb/queue/context_readahead
1
linux-4dtq:/.kernels/scst-kernel-4/scstadmin # cat /sys/block/sda/queue/context_readahead
1


scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 47,7 MB/s
	b) 47,6 MB/s
	c) 47,6 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 47,6 MB/s
	b) 47,2 MB/s
	c) 46,8 MB/s

Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 3,5 MB/s
	b) 3,1 MB/s
	c) 3,5 MB/s

-----------------------------------------	
kernel: uname -r: 2.6.27.12-except_export+readahead
readahead set to: 4M

linux-4dtq:~ # cat /sys/block/sdb/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # cat /sys/block/sda/queue/scheduler
noop anticipatory deadline [cfq]
linux-4dtq:~ # echo 1 > /sys/block/sda/queue/context_readahead
linux-4dtq:~ # echo 1 > /sys/block/sdb/queue/context_readahead
linux-4dtq:~ # blockdev --setra 4096 /dev/sdb
linux-4dtq:~ # blockdev --setra 4096 /dev/sda
linux-4dtq:~ # cat /sys/block/sdb/queue/context_readahead
1
linux-4dtq:~ # cat /sys/block/sda/queue/context_readahead
1
linux-4dtq:~ # blockdev --getra /dev/sda
4096
linux-4dtq:~ # blockdev --getra /dev/sdb
4096
linux-4dtq:~ # mdadm --assemble /dev/md0 /dev/sd[ab]
mdadm: /dev/md/0 has been started with 2 drives.
linux-4dtq:~ # vgchange -a y
  3 logical volume(s) in volume group "raid" now active
linux-4dtq:~ #

scst: Using security group "Default" for initiator "iqn.1996-04.de.suse:01:aadab8bc4be5"
iscsi-scst: Negotiated parameters: InitialR2T No, ImmediateData Yes, MaxConnections 1, MaxRecvDataSegmentLength 1048576, MaxXmitDataSegmentLength 131072,
iscsi-scst:     MaxBurstLength 1048576, FirstBurstLength 262144, DefaultTime2Wait 2, DefaultTime2Retain 0,
iscsi-scst:     MaxOutstandingR2T 1, DataPDUInOrder Yes, DataSequenceInOrder Yes, ErrorRecoveryLevel 0,
iscsi-scst:     HeaderDigest None, DataDigest None, OFMarker No, IFMarker No, OFMarkInt 2048, IFMarkInt 2048

#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 49,1 MB/s
	b) 49,0 MB/s
	c) 48,7 MB/s
#dd if=/dev/sdc of=/dev/null bs=64K count=80000
	a) 47,9 MB/s
	b) 46,6 MB/s
	c) 47,2 MB/s
Run at the same time:	
#while true; do dd if=/dev/sdc  of=/dev/null bs=64K; done	
#dd if=/dev/sdb of=/dev/null bs=64K count=80000
	a) 3,6 MB/s
	b) 3,4 MB/s
	c) 3,6 MB/s


--------------030909090709030109010503--
