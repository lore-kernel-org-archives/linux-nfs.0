Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:42722 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab1CPFTT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 01:19:19 -0400
Date: Tue, 15 Mar 2011 22:19:17 -0700
From: Simon Kirby <sim@hostway.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mark Moseley <moseleymark@gmail.com>, linux-nfs@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [git pull] more vfs fixes for final
Message-ID: <20110316051917.GB27319@hostway.ca>
References: <20110310110931.GF22723@ZenIV.linux.org.uk> <AANLkTi=gv+iT6Lc_ADoBu9_P78ivhmOwLh-+Oki7WmD1@mail.gmail.com> <20110310115856.GG22723@ZenIV.linux.org.uk> <20110311210938.GB8211@hostway.ca> <20110311213519.GA9404@fieldses.org> <20110312010930.GD8211@hostway.ca> <20110315004655.GM25442@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110315004655.GM25442@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 14, 2011 at 08:46:56PM -0400, J. Bruce Fields wrote:

> On Fri, Mar 11, 2011 at 05:09:30PM -0800, Simon Kirby wrote:
> > On Fri, Mar 11, 2011 at 04:35:19PM -0500, J. Bruce Fields wrote:
> > 
> > > On Fri, Mar 11, 2011 at 01:09:38PM -0800, Simon Kirby wrote:
> > > > 
> > > > Hmm, I was hoping this or something recently would fix nfs_inode_cache
> > > > growing forever and flush processes taking lots of system time since
> > > > 2.6.36. For example:
> > > > 
> > > >   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> > > > 3457486 3454365  99%    0.95K 105601       33   3379232K nfs_inode_cache
> > > > 469638 248761  52%    0.10K  12042       39     48168K buffer_head
> > > > 243712 216348  88%    0.02K    952      256      3808K kmalloc-16
> > > > 232785 202185  86%    0.19K  11085       21     44340K dentry
> > > > 149696  54633  36%    0.06K   2339       64      9356K kmalloc-64
> > > > 115976 106806  92%    0.55K   4142       28     66272K radix_tree_node
> > > >  76064  45680  60%    0.12K   2377       32      9508K kmalloc-128
> > > >  62336  53427  85%    0.03K    487      128      1948K kmalloc-32
> > > >  41958  41250  98%    0.75K   1998       21     31968K ext3_inode_cache
> > > > 
> > > > This clears them all, similar to what you posted:
> > > > 
> > > > echo 2 > /proc/sys/vm/drop_caches
> > > > sync
> > > > echo 2 > /proc/sys/vm/drop_caches
> > > > 
> > > > ...but 2.6.38-rc8 still doesn't seem to fix it.
> > > > 
> > > > http://0x.ca/sim/ref/2.6.37/cpu3_nfs.png
> > > > http://www.spinics.net/lists/linux-nfs/msg18212.html
> > > > 
> > > > Any ideas?  This started with 2.6.36.
> > > 
> > > Do you have NFSv4 clients that are doing locking?  Then it's probably
> > > 0997b17360 and 529d7b2a7f on the for-2.6.39 branch at:
> > > 
> > > 	git://linux-nfs.org/~bfields/linux.git for-2.6.39
> > > 
> > > Let me know if not.
> 
> Pfft, I'm blind, sorry, I didn't pay attention to the slab name;
> nfs_inode_cache is client-side, not server-side, so nothing I've done 
> should affect it one way or the other.
> 
> Of course it's not necessarily a bug for the client to cache a lot of
> inodes, but millions sounds like a lot for your case?
> 
> Are you actually seeing this cause you problems?

Yes, manifesting in two ways..

On the log-crunching box I was referencing in my reports, system time
grows proportionally with nfs_inode_cache and eventually swamps the
entire system. (See http://0x.ca/sim/ref/2.6.37/cpu3_nfs.png for an
example of it using half of the CPU after a few weeks of uptime.) The
CPU seems to come from "flush" processes, and can be seen with "top"
and "perf top" (which shows mostly spinlock contention).

The other case is much less controlled, and is a large cluster of boxes
running Apache, etc. Some event seems to case reclaim of these all at
once, and the machine effectively goes out to lunch for a few minutes
while this happens, with 30 or more "flush" processes taking 100% CPU.
We were able to set up a script to detect this immediately and pull them
from the cluster pool, and after a few minutes, everything returns to
normal.

So, the problem seems to be two problems: the massive burst of spinlock
contention from the "flush" processes for every NFS mount (and we have
about 70 of them on average), and even without the burst, the flush
processes seem to take CPU proportionally to the number of them, even
though I would expect them to just be cache at that point.

None of this was an issue in 2.6.35. I can boot it on the log crunching
box and system time is 0% after every run. On 2.6.36-38, system time
increases by about 2% every day.

Simon-
