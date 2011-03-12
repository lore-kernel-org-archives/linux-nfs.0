Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:40645 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394Ab1CLBJc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2011 20:09:32 -0500
Date: Fri, 11 Mar 2011 17:09:30 -0800
From: Simon Kirby <sim@hostway.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mark Moseley <moseleymark@gmail.com>, linux-nfs@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [git pull] more vfs fixes for final
Message-ID: <20110312010930.GD8211@hostway.ca>
References: <20110310110931.GF22723@ZenIV.linux.org.uk> <AANLkTi=gv+iT6Lc_ADoBu9_P78ivhmOwLh-+Oki7WmD1@mail.gmail.com> <20110310115856.GG22723@ZenIV.linux.org.uk> <20110311210938.GB8211@hostway.ca> <20110311213519.GA9404@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110311213519.GA9404@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 11, 2011 at 04:35:19PM -0500, J. Bruce Fields wrote:

> On Fri, Mar 11, 2011 at 01:09:38PM -0800, Simon Kirby wrote:
> > On Thu, Mar 10, 2011 at 11:58:56AM +0000, Al Viro wrote:
> > 
> > > commit d891eedbc3b1b0fade8a9ce60cc0eba1cccb59e5
> > > Author: J. Bruce Fields <bfields@fieldses.org>
> > > Date:   Tue Jan 18 15:45:09 2011 -0500
> > > 
> > >     fs/dcache: allow d_obtain_alias() to return unhashed dentries
> > 
> > Hmm, I was hoping this or something recently would fix nfs_inode_cache
> > growing forever and flush processes taking lots of system time since
> > 2.6.36. For example:
> > 
> >   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
> > 3457486 3454365  99%    0.95K 105601       33   3379232K nfs_inode_cache
> > 469638 248761  52%    0.10K  12042       39     48168K buffer_head
> > 243712 216348  88%    0.02K    952      256      3808K kmalloc-16
> > 232785 202185  86%    0.19K  11085       21     44340K dentry
> > 149696  54633  36%    0.06K   2339       64      9356K kmalloc-64
> > 115976 106806  92%    0.55K   4142       28     66272K radix_tree_node
> >  76064  45680  60%    0.12K   2377       32      9508K kmalloc-128
> >  62336  53427  85%    0.03K    487      128      1948K kmalloc-32
> >  41958  41250  98%    0.75K   1998       21     31968K ext3_inode_cache
> > 
> > This clears them all, similar to what you posted:
> > 
> > echo 2 > /proc/sys/vm/drop_caches
> > sync
> > echo 2 > /proc/sys/vm/drop_caches
> > 
> > ...but 2.6.38-rc8 still doesn't seem to fix it.
> > 
> > http://0x.ca/sim/ref/2.6.37/cpu3_nfs.png
> > http://www.spinics.net/lists/linux-nfs/msg18212.html
> > 
> > Any ideas?  This started with 2.6.36.
> 
> Do you have NFSv4 clients that are doing locking?  Then it's probably
> 0997b17360 and 529d7b2a7f on the for-2.6.39 branch at:
> 
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.39
> 
> Let me know if not.

Yes, but when this started, it was all NFSv3. I tried NFSv4 to see if
it made any different (no, other than more I/O wait due to idmapd and
flock(LOCK_EX) breaking on a file opened O_RDONLY, which works locally
and on NFSv3 -- fixed by changing to open(O_RDWR) in my code), but
otherwise NFSv3 and NFSv4 look pretty much the same and "leak" at the
same rate.

Actually, I only changed the mount where it writes the log results, and
not where it reads them from (a bunch of NFSv3 mounts that will take a
lot more work to make NFSv4 since they currently run without libnss-mysql
set up), so I haven't actually tested to see if it happens with purely
NFSv4 mounts.

Anyway, it's locking on one file only, and it was purely for reducing
writeback thrashing, so I could try without it if you think it might be
related, but it all started without NFSv4. All this thing does is read a
bunch of log files, crunch them into reports, and write them to another
mount point, all run from xargs -P. Pretty basic readdir, read, write,
unlink...not anything exotic.

Simon-
