Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:59754 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098Ab1AGSFk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jan 2011 13:05:40 -0500
In-Reply-To: <AANLkTim6HoN5+m180-Du+oda+6N49qSaGga6ktMPV4U4@mail.gmail.com>
References: <20101208212505.GA18192@hostway.ca>
	<20101218010801.GE28367@hostway.ca>
	<20101229220313.GA13688@hostway.ca>
	<AANLkTinq074Q-B=5B4_aXuBm-3ELwGknsJv+OvS1z1OX@mail.gmail.com>
	<20110104214008.GH27727@hostway.ca>
	<AANLkTim6HoN5+m180-Du+oda+6N49qSaGga6ktMPV4U4@mail.gmail.com>
Date: Fri, 7 Jan 2011 10:05:39 -0800
Message-ID: <AANLkTinLsREtOqNGW2j5m0UYros1AgTu953JHjjJZ-F+@mail.gmail.com>
Subject: Re: System CPU increasing on idle 2.6.36
From: Mark Moseley <moseleymark@gmail.com>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 5, 2011 at 11:43 AM, Mark Moseley <moseleymark@gmail.com> wrote:
> On Tue, Jan 4, 2011 at 1:40 PM, Simon Kirby <sim@hostway.ca> wrote:
>> On Tue, Jan 04, 2011 at 09:42:14AM -0800, Mark Moseley wrote:
>>
>>> On Wed, Dec 29, 2010 at 2:03 PM, Simon Kirby <sim@hostway.ca> wrote:
>>>
>>> > I've noticed nfs_inode_cache is ever-increasing as well with 2.6.37:
>>> >
>>> > ?OBJS ACTIVE ?USE OBJ SIZE ?SLABS OBJ/SLAB CACHE SIZE NAME
>>> > 2562514 2541520 ?99% ? ?0.95K ?78739 ? ? ? 33 ? 2519648K nfs_inode_cache
>>> > 467200 285110 ?61% ? ?0.02K ? 1825 ? ? ?256 ? ? ?7300K kmalloc-16
>>> > 299397 242350 ?80% ? ?0.19K ?14257 ? ? ? 21 ? ? 57028K dentry
>>> > 217434 131978 ?60% ? ?0.55K ? 7767 ? ? ? 28 ? ?124272K radix_tree_node
>>> > 215232 ?81522 ?37% ? ?0.06K ? 3363 ? ? ? 64 ? ? 13452K kmalloc-64
>>> > 183027 136802 ?74% ? ?0.10K ? 4693 ? ? ? 39 ? ? 18772K buffer_head
>>> > 101120 ?71184 ?70% ? ?0.03K ? ?790 ? ? ?128 ? ? ?3160K kmalloc-32
>>> > ?79616 ?59713 ?75% ? ?0.12K ? 2488 ? ? ? 32 ? ? ?9952K kmalloc-128
>>> > ?66560 ?41257 ?61% ? ?0.01K ? ?130 ? ? ?512 ? ? ? 520K kmalloc-8
>>> > ?42126 ?26650 ?63% ? ?0.75K ? 2006 ? ? ? 21 ? ? 32096K ext3_inode_cache
>>> >
>>> > http://0x.ca/sim/ref/2.6.37/inodes_nfs.png
>>> > http://0x.ca/sim/ref/2.6.37/cpu2_nfs.png
>>> >
>>> > Perhaps I could bisect just fs/nfs changes between 2.6.35 and 2.6.36 to
>>> > try to track this down without having to wait too long, unless somebody
>>> > can see what is happening here.
>>>
>>> I'll get started bisecting too, since this is something of a
>>> show-stopper. Boxes that pre-2.6.36 would stay up for months at a time
>>> now have to be powercycled every couple of days (which is about how
>>> long it takes for this behavior to show up). This is across-the-board
>>> for about 50 boxes, ranging from 2.6.36 to 2.6.36.2.
>>>
>>> Simon: It's probably irrelevant since these are kernel threads, but
>>> I'm curious what distro your boxes are running. Ours are Debian Lenny,
>>> i386, Dell Poweredge 850s. Just trying to figure out any
>>> commonalities. I'll get my boxes back on 2.6.36.2 and start watching
>>> nfs_inode_cache as well.
>>
>> Same distro, x86_64, similar servers.
>>
>> I'm not sure if the two cases I am seeing are exactly the same problem,
>> but on the log crunching boxes, system time seems proportional to
>> nfs_inode_cache and nfs_inode_cache just keeps growing forever; however,
>> if I stop the load and unmount the NFS mount points, all of the
>> nfs_inode_cache objects do actually go away (after umount finishes).
>>
>> It seems the shrinker callback might not be working as intended here.
>>
>> On the shared server case, the crazy spinlock contention from all of the
>> flusher processes happens suddenly and overloads the boxes for 10-15
>> minutes, and then everything recovers.  Over 21 of these boxes, they
>> each have about 500k-700k nfs_inode_cache objects.  The log cruncher hit
>> 3.3 million nfs_inode_cache objects before I unmounted.
>>
>> Are your boxes repeating this behaviour at any predictable interval?
>
> Simon:
> My boxes definitely fall into the latter category, with spinlock
> regularly sitting at 60-80% CPU (according to 'perf top'). As far as
> predictability, not strictly, but it's typically after an uptime of
> 2-3 days. They take so long to get into this state that I've never
> seen the actual transition in person, just the after-effects of
> flush-0:xx gone crazy. These boxes have a number of other NFS mounts,
> but it's on the flush-0:xx's for the heavily written-to NFS mounts
> that are spinning wildly, which you'd expect to be the case. The
> infrequently written-to NFS servers' flush-0:xx isn't to be found in
> 'top' output.
>
> I'd booted into older kernels after my initial reply, so I'm 14 hrs
> into booting a box back into 2.6.36.2 and another box into a
> double-bisected 2.6.35-2.6.36 kernel (my first bisect hit compile
> errors). Both are running normally but that fits with the pattern so
> far.
>
> NFS Guys:
> Anything else we can be digging up to help debug this? This is a
> pretty ugly issue.
>

NOTE: NFS/Kernel guys: I've left the 2.6.36.2 box still thrashing
about in case there's something you'd like me to look at.

Ok, both my 2.6.36.2 kernel box and my 2.6.35->2.6.36 bisect box (was
bisected to ce7db282a3830f57f5b05ec48288c23a5c4d66d5 -- this is my
first time doing bisect, so I'll preemptively apologize for doing
anything silly) both went berserk within 15 mins of each other, after
an uptime of around 63 hours for 2.6.36.2 and 65 hours for the
bisected box. The 2.6.36.2 one is still running with all the various
flush-0:xx threads spinning wildly. The bisected box just keeled over
and died, but is back up now. The only kernel messages logged are just
of the "task kworker/4:1:359 blocked for more than 120 seconds"
variety, all with _raw_spin_lock_irq at the top of the stack trace.

Looking at slabinfo, specifically, this: stats=$(grep nfs_inode_cache
/proc/slabinfo | awk '{ print $2, $3 }')
the active_objs and num_objs both increase to over a million (these
boxes are delivering mail to NFS-mounted mailboxes, so that's
perfectly reasonable). On both boxes, looking at sar, things start to
go awry around 10am today EST. At that time on the 2.6.36.2 box, the
NFS numbers look like this:

Fri Jan  7 09:58:00 2011: 1079433 1079650
Fri Jan  7 09:59:00 2011: 1079632 1080300
Fri Jan  7 10:00:00 2011: 1080196 1080300
Fri Jan  7 10:01:01 2011: 1080599 1080716
Fri Jan  7 10:02:01 2011: 1081074 1081288

on the bisected, like this:

Fri Jan  7 09:59:34 2011: 1162786 1165320
Fri Jan  7 10:00:34 2011: 1163301 1165320
Fri Jan  7 10:01:34 2011: 1164369 1165450
Fri Jan  7 10:02:35 2011: 1164179 1165450
Fri Jan  7 10:03:35 2011: 1165795 1166958

When the bisected box finally died, the last numbers were:

Fri Jan  7 10:40:33 2011: 1177156 1177202
Fri Jan  7 10:42:21 2011: 1177157 1177306
Fri Jan  7 10:44:55 2011: 1177201 1177324
Fri Jan  7 10:45:55 2011: 1177746 1177826

On the still-thrashing 2.6.36.2 box, the highwater mark is:

Fri Jan  7 10:23:30 2011: 1084020 1084070

and once things went awry, the active_objs started falling away and
the number_objs has stayed at 1084070. Last numbers were:

Fri Jan  7 12:19:34 2011: 826623 1084070

The bisected box had reached 1mil entries (or more significantly
1048576 entries) by y'day evening. The 2.6.36.2 box hit that by 7am
EST today. So in neither case was there a big spike in entries.

These boxes have identical workloads. They're not accessible from the
net, so there's no chance of a DDoS or something. The significance of
10am EST could be either uptime-related (all these have gone down
after 2-3 days) or just due to the to-be-expected early morning spike
in mail flow.
