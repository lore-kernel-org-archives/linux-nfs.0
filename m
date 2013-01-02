Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eriks.xs4all.nl ([83.163.214.71]:56665 "EHLO eriks.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752Ab3ABSiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 13:38:03 -0500
Message-ID: <50E47E83.1030208@slagter.name>
Date: Wed, 02 Jan 2013 19:37:55 +0100
From: Erik Slagter <erik@slagter.name>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS client large rsize/wsize (tcp?) problems
References: <50E0393E.7040204@slagter.name> <20130102182147.GA25450@fieldses.org>
In-Reply-To: <20130102182147.GA25450@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02-01-13 19:21, J. Bruce Fields wrote:

>> The OOM-killer reports it needs blocks of 128k (probably for NFS,
>> but it doesn't say it), but can't find them.
>
> Details?  (Could you show us the log messages?)  Anything else
> interesting in the logs before then?  (E.g. any "order-n allocation
> failed" messages?)

Hmmm, that will be tricky. The one box that produces OOM-messages has 
this after about a week of usage, and they only log in memory :-(

Ah, I've found one!

> enigma2 invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
> Call Trace:
> [<80485708>] dump_stack+0x8/0x34
> [<80081f60>] dump_header.isra.9+0x88/0x1a4
> [<80082268>] oom_kill_process.constprop.16+0xc4/0x2b8
> [<800828c4>] out_of_memory+0x2a8/0x3a8
> [<80085e78>] __alloc_pages_nodemask+0x640/0x654
> [<8048683c>] cache_alloc_refill+0x350/0x668
> [<800b1f10>] kmem_cache_alloc+0xe0/0x104
> [<80185360>] nfs_create_request+0x40/0x178
> [<80187544>] readpage_async_filler+0x9c/0x1bc
> [<80089b98>] read_cache_pages+0xe4/0x144
> [<801886ac>] nfs_readpages+0xd4/0x1cc
> [<80089928>] __do_page_cache_readahead+0x218/0x2e4
> [<80089d58>] ra_submit+0x28/0x34
> [<8008a138>] page_cache_sync_readahead+0x48/0x70
> [<80080ae0>] generic_file_aio_read+0x55c/0x858
> [<80179560>] nfs_file_read+0xac/0x194
> [<800b5004>] do_sync_read+0xb8/0x120
> [<800b5ca0>] vfs_read+0xa0/0x180
> [<800b5dcc>] sys_read+0x4c/0x90
> [<8000c61c>] stack_done+0x20/0x40
>
> Mem-Info:
> Normal per-cpu:
> CPU    0: hi:   90, btch:  15 usd:  14
> CPU    1: hi:   90, btch:  15 usd:   0
> active_anon:22459 inactive_anon:57 isolated_anon:0
>  active_file:972 inactive_file:1968 isolated_file:0
>  unevictable:0 dirty:0 writeback:144 unstable:0
>  free:501 slab_reclaimable:526 slab_unreclaimable:2701
>  mapped:686 shmem:142 pagetables:137 bounce:0
> Normal free:2004kB min:2036kB low:2544kB high:3052kB active_anon:89836kB inactive_anon:228kB active_file:3888kB inactive_file:7872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:260096kB mlocked:0kB dirty:0kB writeback:576kB mapped:2744kB shmem:568kB slab_reclaimable:2104kB slab_unreclaimable:10804kB kernel_stack:792kB pagetables:548kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:14594 all_unreclaimable? yes
> lowmem_reserve[]: 0 0
> Normal: 317*4kB 90*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2004kB
> 3101 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 65536 pages RAM
> 28149 pages reserved
> 3039 pages shared
> 33680 pages non-shared
> [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> [  254]     0   254      474       16   1       0             0 wdog
> [  263]     0   263     1225       88   0       0             0 tpmd
> [  327]     0   327     1026      255   1       0             0 nmbd
> [  329]     0   329     1803      175   1       0             0 smbd
> [  349]     0   349     1803      175   0       0             0 smbd
> [  372]     1   372      499       19   1       0             0 portmap
> [  383]   998   383      762       37   1       0             0 dbus-daemon
> [  387]     0   387      666       24   1       0             0 dropbear
> [  392]     0   392      664       48   0       0             0 crond
> [  398]     0   398      758       22   1       0             0 inetd
> [  401]     0   401      664       35   1       0             0 syslogd
> [  403]     0   403      664       52   0       0             0 klogd
> [  410]   997   410      922       95   1       0             0 avahi-daemon
> [  411]   997   411      922       42   0       0             0 avahi-daemon
> [ 7811] 65534  7811     7424      187   1       0             0 msgd
> [ 7819]     0  7819     1266       45   0       0             0 oscam
> [ 7820]     0  7820     6733     2491   1       0             0 oscam
> [ 7821]     0  7821      664       16   1       0             0 enigma2.sh
> [ 7828]     0  7828    44920    19651   1       0             0 enigma2
> Out of memory: Kill process 7828 (enigma2) score 496 or sacrifice child
> Killed process 7828 (enigma2) total-vm:179680kB, anon-rss:77180kB, file-rss:1424kB

The other boxes simply lock up.

This does NOT happen with NFS mounted using smaller buffers!

>> I've "discovered" a few interesting things:
>>   - adding swap to the dm8000 makes the problem almost go away,
>> although without NFS it definitely doesn't need swap, ever.
>>   - when I ran my laptop (x86_64!) with a slightly older kernel
>> (2.6.35 iirc) from a rescue cd, at a certain point I also got nasty
>> dmesg reports and the "dd" proces got stuck in D state, this was
>> reproducable over reboots.
>
> Why do you believe that's the same problem?

Because all are solved with smaller nfs mount buffers. That is as much 
as I understand.

> OK, thanks for the reports, let us know i you're able to narrow it down
> farther.  It's not familiar off the top of my head.

Okay, at least it's good to know it's not a known problem with a known 
solution / workaround. I hope the kernel message helps.

As a temporary workaround (for "dumb users" that don't know what a mount 
option is, yes it's awful!) I'd like to modify the kernel of the clients 
to negotiate a smaller buffer size, 32k would probably suffice. I've had 
a few shots but have not been successful yet, can you give me a pointer 
please?

Thanks!
