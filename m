Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28153 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367Ab3ABSrc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2013 13:47:32 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Erik Slagter <erik@slagter.name>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS client large rsize/wsize (tcp?) problems
Date: Wed, 2 Jan 2013 18:47:30 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91198300A@SACEXCMBX04-PRD.hq.netapp.com>
References: <50E0393E.7040204@slagter.name>
	 <20130102182147.GA25450@fieldses.org> <50E47E83.1030208@slagter.name>
In-Reply-To: <50E47E83.1030208@slagter.name>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-01-02 at 19:37 +-0100, Erik Slagter wrote:
+AD4- On 02-01-13 19:21, J. Bruce Fields wrote:
+AD4- 
+AD4- +AD4APg- The OOM-killer reports it needs blocks of 128k (probably for NFS,
+AD4- +AD4APg- but it doesn't say it), but can't find them.
+AD4- +AD4-
+AD4- +AD4- Details?  (Could you show us the log messages?)  Anything else
+AD4- +AD4- interesting in the logs before then?  (E.g. any +ACI-order-n allocation
+AD4- +AD4- failed+ACI- messages?)
+AD4- 
+AD4- Hmmm, that will be tricky. The one box that produces OOM-messages has 
+AD4- this after about a week of usage, and they only log in memory :-(
+AD4- 
+AD4- Ah, I've found one+ACE-
+AD4- 
+AD4- +AD4- enigma2 invoked oom-killer: gfp+AF8-mask+AD0-0xd0, order+AD0-0, oom+AF8-adj+AD0-0, oom+AF8-score+AF8-adj+AD0-0
+AD4- +AD4- Call Trace:
+AD4- +AD4- +AFsAPA-80485708+AD4AXQ- dump+AF8-stack+-0x8/0x34
+AD4- +AD4- +AFsAPA-80081f60+AD4AXQ- dump+AF8-header.isra.9+-0x88/0x1a4
+AD4- +AD4- +AFsAPA-80082268+AD4AXQ- oom+AF8-kill+AF8-process.constprop.16+-0xc4/0x2b8
+AD4- +AD4- +AFsAPA-800828c4+AD4AXQ- out+AF8-of+AF8-memory+-0x2a8/0x3a8
+AD4- +AD4- +AFsAPA-80085e78+AD4AXQ- +AF8AXw-alloc+AF8-pages+AF8-nodemask+-0x640/0x654
+AD4- +AD4- +AFsAPA-8048683c+AD4AXQ- cache+AF8-alloc+AF8-refill+-0x350/0x668
+AD4- +AD4- +AFsAPA-800b1f10+AD4AXQ- kmem+AF8-cache+AF8-alloc+-0xe0/0x104
+AD4- +AD4- +AFsAPA-80185360+AD4AXQ- nfs+AF8-create+AF8-request+-0x40/0x178
+AD4- +AD4- +AFsAPA-80187544+AD4AXQ- readpage+AF8-async+AF8-filler+-0x9c/0x1bc
+AD4- +AD4- +AFsAPA-80089b98+AD4AXQ- read+AF8-cache+AF8-pages+-0xe4/0x144
+AD4- +AD4- +AFsAPA-801886ac+AD4AXQ- nfs+AF8-readpages+-0xd4/0x1cc
+AD4- +AD4- +AFsAPA-80089928+AD4AXQ- +AF8AXw-do+AF8-page+AF8-cache+AF8-readahead+-0x218/0x2e4
+AD4- +AD4- +AFsAPA-80089d58+AD4AXQ- ra+AF8-submit+-0x28/0x34
+AD4- +AD4- +AFsAPA-8008a138+AD4AXQ- page+AF8-cache+AF8-sync+AF8-readahead+-0x48/0x70
+AD4- +AD4- +AFsAPA-80080ae0+AD4AXQ- generic+AF8-file+AF8-aio+AF8-read+-0x55c/0x858
+AD4- +AD4- +AFsAPA-80179560+AD4AXQ- nfs+AF8-file+AF8-read+-0xac/0x194
+AD4- +AD4- +AFsAPA-800b5004+AD4AXQ- do+AF8-sync+AF8-read+-0xb8/0x120
+AD4- +AD4- +AFsAPA-800b5ca0+AD4AXQ- vfs+AF8-read+-0xa0/0x180
+AD4- +AD4- +AFsAPA-800b5dcc+AD4AXQ- sys+AF8-read+-0x4c/0x90
+AD4- +AD4- +AFsAPA-8000c61c+AD4AXQ- stack+AF8-done+-0x20/0x40
+AD4- +AD4-
+AD4- +AD4- Mem-Info:
+AD4- +AD4- Normal per-cpu:
+AD4- +AD4- CPU    0: hi:   90, btch:  15 usd:  14
+AD4- +AD4- CPU    1: hi:   90, btch:  15 usd:   0
+AD4- +AD4- active+AF8-anon:22459 inactive+AF8-anon:57 isolated+AF8-anon:0
+AD4- +AD4-  active+AF8-file:972 inactive+AF8-file:1968 isolated+AF8-file:0
+AD4- +AD4-  unevictable:0 dirty:0 writeback:144 unstable:0
+AD4- +AD4-  free:501 slab+AF8-reclaimable:526 slab+AF8-unreclaimable:2701
+AD4- +AD4-  mapped:686 shmem:142 pagetables:137 bounce:0
+AD4- +AD4- Normal free:2004kB min:2036kB low:2544kB high:3052kB active+AF8-anon:89836kB inactive+AF8-anon:228kB active+AF8-file:3888kB inactive+AF8-file:7872kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:260096kB mlocked:0kB dirty:0kB writeback:576kB mapped:2744kB shmem:568kB slab+AF8-reclaimable:2104kB slab+AF8-unreclaimable:10804kB kernel+AF8-stack:792kB pagetables:548kB unstable:0kB bounce:0kB writeback+AF8-tmp:0kB pages+AF8-scanned:14594 all+AF8-unreclaimable? yes
+AD4- +AD4- lowmem+AF8-reserve+AFsAXQ-: 0 0
+AD4- +AD4- Normal: 317+ACo-4kB 90+ACo-8kB 1+ACo-16kB 0+ACo-32kB 0+ACo-64kB 0+ACo-128kB 0+ACo-256kB 0+ACo-512kB 0+ACo-1024kB 0+ACo-2048kB 0+ACo-4096kB +AD0- 2004kB
+AD4- +AD4- 3101 total pagecache pages
+AD4- +AD4- 0 pages in swap cache
+AD4- +AD4- Swap cache stats: add 0, delete 0, find 0/0
+AD4- +AD4- Free swap  +AD0- 0kB
+AD4- +AD4- Total swap +AD0- 0kB
+AD4- +AD4- 65536 pages RAM
+AD4- +AD4- 28149 pages reserved
+AD4- +AD4- 3039 pages shared
+AD4- +AD4- 33680 pages non-shared
+AD4- +AD4- +AFs- pid +AF0-   uid  tgid total+AF8-vm      rss cpu oom+AF8-adj oom+AF8-score+AF8-adj name
+AD4- +AD4- +AFs-  254+AF0-     0   254      474       16   1       0             0 wdog
+AD4- +AD4- +AFs-  263+AF0-     0   263     1225       88   0       0             0 tpmd
+AD4- +AD4- +AFs-  327+AF0-     0   327     1026      255   1       0             0 nmbd
+AD4- +AD4- +AFs-  329+AF0-     0   329     1803      175   1       0             0 smbd
+AD4- +AD4- +AFs-  349+AF0-     0   349     1803      175   0       0             0 smbd
+AD4- +AD4- +AFs-  372+AF0-     1   372      499       19   1       0             0 portmap
+AD4- +AD4- +AFs-  383+AF0-   998   383      762       37   1       0             0 dbus-daemon
+AD4- +AD4- +AFs-  387+AF0-     0   387      666       24   1       0             0 dropbear
+AD4- +AD4- +AFs-  392+AF0-     0   392      664       48   0       0             0 crond
+AD4- +AD4- +AFs-  398+AF0-     0   398      758       22   1       0             0 inetd
+AD4- +AD4- +AFs-  401+AF0-     0   401      664       35   1       0             0 syslogd
+AD4- +AD4- +AFs-  403+AF0-     0   403      664       52   0       0             0 klogd
+AD4- +AD4- +AFs-  410+AF0-   997   410      922       95   1       0             0 avahi-daemon
+AD4- +AD4- +AFs-  411+AF0-   997   411      922       42   0       0             0 avahi-daemon
+AD4- +AD4- +AFs- 7811+AF0- 65534  7811     7424      187   1       0             0 msgd
+AD4- +AD4- +AFs- 7819+AF0-     0  7819     1266       45   0       0             0 oscam
+AD4- +AD4- +AFs- 7820+AF0-     0  7820     6733     2491   1       0             0 oscam
+AD4- +AD4- +AFs- 7821+AF0-     0  7821      664       16   1       0             0 enigma2.sh
+AD4- +AD4- +AFs- 7828+AF0-     0  7828    44920    19651   1       0             0 enigma2
+AD4- +AD4- Out of memory: Kill process 7828 (enigma2) score 496 or sacrifice child
+AD4- +AD4- Killed process 7828 (enigma2) total-vm:179680kB, anon-rss:77180kB, file-rss:1424kB
+AD4- 
+AD4- The other boxes simply lock up.
+AD4- 
+AD4- This does NOT happen with NFS mounted using smaller buffers+ACE-

You probably have a NIC that doesn't support scatter-gather.

+AD4- +AD4APg- I've +ACI-discovered+ACI- a few interesting things:
+AD4- +AD4APg-   - adding swap to the dm8000 makes the problem almost go away,
+AD4- +AD4APg- although without NFS it definitely doesn't need swap, ever.
+AD4- +AD4APg-   - when I ran my laptop (x86+AF8-64+ACE-) with a slightly older kernel
+AD4- +AD4APg- (2.6.35 iirc) from a rescue cd, at a certain point I also got nasty
+AD4- +AD4APg- dmesg reports and the +ACI-dd+ACI- proces got stuck in D state, this was
+AD4- +AD4APg- reproducable over reboots.
+AD4- +AD4-
+AD4- +AD4- Why do you believe that's the same problem?
+AD4- 
+AD4- Because all are solved with smaller nfs mount buffers. That is as much 
+AD4- as I understand.
+AD4- 
+AD4- +AD4- OK, thanks for the reports, let us know i you're able to narrow it down
+AD4- +AD4- farther.  It's not familiar off the top of my head.
+AD4- 
+AD4- Okay, at least it's good to know it's not a known problem with a known 
+AD4- solution / workaround. I hope the kernel message helps.
+AD4- 
+AD4- As a temporary workaround (for +ACI-dumb users+ACI- that don't know what a mount 
+AD4- option is, yes it's awful+ACE-) I'd like to modify the kernel of the clients 
+AD4- to negotiate a smaller buffer size, 32k would probably suffice. I've had 
+AD4- a few shots but have not been successful yet, can you give me a pointer 
+AD4- please?
+AD4- 

man nfsmount.conf

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
