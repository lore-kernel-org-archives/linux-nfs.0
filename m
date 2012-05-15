Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758823Ab2EON3C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 09:29:02 -0400
Date: Tue, 15 May 2012 09:28:57 -0400
From: Josef Bacik <josef@redhat.com>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Josef Bacik <josef@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Ted Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120515132857.GA1907@localhost.localdomain>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <20120514152334.GB29902@fieldses.org>
 <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
 <20120514175822.GC1439@thunk.org>
 <20120514183316.GA1894@localhost.localdomain>
 <20120514185400.GA32026@fieldses.org>
 <20120514190500.GC1894@localhost.localdomain>
 <60F0B94D-FDB9-4401-B0EA-1A1C6DE4086F@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <60F0B94D-FDB9-4401-B0EA-1A1C6DE4086F@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2012 at 03:27:47PM -0600, Andreas Dilger wrote:
> On 2012-05-14, at 1:05 PM, Josef Bacik wrote:
> > On Mon, May 14, 2012 at 02:54:00PM -0400, J. Bruce Fields wrote:
> >> I don't think they're worried about the inode_inc_iversion() calls
> >> themselves, but the behavior of file_update_time():
> >> 
> >>        if (!timespec_equal(&inode->i_mtime, &now))
> >>                sync_it = S_MTIME;
> >> 
> >>        if (!timespec_equal(&inode->i_ctime, &now))
> >>                sync_it |= S_CTIME;
> >> 
> >>        if (IS_I_VERSION(inode))
> >>                sync_it |= S_VERSION;
> >> 
> >>        if (!sync_it)
> >>                return;
> >> 	...
> >> 	mark_inode_dirty_sync(inode);
> >> 
> >> So now mark_inode_dirty_sync() is called on every update, instead of
> >> merely on every update that sees a time change (so at most once a
> >> jiffy).
> >> 
> >> So mark_inode_dirty_sync (and hence ->dirty_inode = ext4_dirty_inode)
> >> may get called more often if you're writing very frequently.
> >> 
> >> I'm a bit surprised that's expected to add significant overhead to the
> >> write.
> > 
> > It shouldn't, let's be honest, most systems aren't going to have such
> > a coarse jiffie counter that they'll be able to get away with doing
> > 2 calls to write() or ->page_mkwrite() in the same jiffie and skip the
> > update to mtime/ctime anyway.  If they do they are damned lucky, and
> > again the amount of overhead added even if they are should be
> > negligible since 99% of us all incur the overhead from having
> > to update mtime/ctime anyway.  Thanks,
> 
> Seriously?  The whole reason the above checks for timespec_equal()
> are there is to avoid calling mark_inode_dirty_sync() thousands of
> times per second.  If doing write() calls in the same jiffie were
> so rare as you suggest then I don't think such an optimization
> would ever have appeared in the first place.
> 

So here is the commit log

commit ce06e0b21d6732a2bab10a585a3ec6909499be28
Author: Andi Kleen <andi@firstfloor.org>
Date:   Fri Sep 18 13:05:48 2009 -0700

    vfs: optimize touch_time() too
    
    Do a similar optimization as earlier for touch_atime.  Getting the lock in
    mnt_get_write is relatively costly, so try all avenues to avoid it first.
    
    This patch is careful to still only update inode fields inside the lock
    region.
    
    This didn't show up in benchmarks, but it's easy enough to do.

Notice that last bit?  I'm sure maybe at some point in the future we'll be able
to see the overhead, but right now I highly doubt we can, and if we can I'd like
to see benchmarks before blanket dismissing a feature that would be super
helpful for people exporting nfs volumes.  Thanks,

Josef
