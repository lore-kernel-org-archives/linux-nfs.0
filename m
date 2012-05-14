Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757208Ab2ENTFS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 15:05:18 -0400
Date: Mon, 14 May 2012 15:05:08 -0400
From: Josef Bacik <josef@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Josef Bacik <josef@redhat.com>, "Ted Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger@dilger.ca>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120514190500.GC1894@localhost.localdomain>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <20120514152334.GB29902@fieldses.org>
 <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
 <20120514175822.GC1439@thunk.org>
 <20120514183316.GA1894@localhost.localdomain>
 <20120514185400.GA32026@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120514185400.GA32026@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2012 at 02:54:00PM -0400, J. Bruce Fields wrote:
> On Mon, May 14, 2012 at 02:33:17PM -0400, Josef Bacik wrote:
> > On Mon, May 14, 2012 at 01:58:22PM -0400, Ted Ts'o wrote:
> > > On Mon, May 14, 2012 at 11:27:42AM -0600, Andreas Dilger wrote:
> > > > > And if it at all possible I'd rather have it be something that Just
> > > > > Works rather than something that requires extra configuration.
> > > > 
> > > > Sure, but this is only useful for NFSv4, but costs everyone using
> > > > ext4 continuous overhead, so it isn't a clear-cut case to enable
> > > > the version just on the thought that NFS might one day be used on
> > > > any particular filesystem.
> > > 
> > > It's not a matter of "NFSv4 might one day be used"; if we don't turn
> > > on i_version updates until the file system is actually exported via
> > > NFSv4, there would be no deleterious effects.
> > > 
> > > I always thought that was going to be the plan; that there would be
> > > some flag that would be set in struct super_block when the file system
> > > was exported that would enable i_version updates.
> > > 
> > > That way we satisfy the "no extra configuration" needed requirement,
> > > which I agree is ideal, but we also don't waste any CPU overhead if
> > > the file system is not exported via NFSv4.  I tried to implement
> > > anything along these lines because I don't care enough, and I don't
> > > use NFSv4 personally....
> > > 
> > 
> > Seems like this is just a bad place to be doing inode_inc_iversion().  If
> > MS_IVERSION is set we will update iversion in file_update_time() and then call
> > mark_inode_dirty which will jack up the iversion again.
> 
> Agreed, that's weird.
> 
> > In btrfs we just change
> > it wherever we change ctime and that way you don't really notice the extra
> > overhead since you are doing it in paths where you are changing a bunch of stuff
> > in the inode already, and mostly where you hold the i_mutex so you aren't going
> > to be hitting any contention on the i_lock.  Thanks,
> 
> I don't think they're worried about the inode_inc_iversion() calls
> themselves, but the behavior of file_update_time():
> 
>         if (!timespec_equal(&inode->i_mtime, &now))
>                 sync_it = S_MTIME;
> 
>         if (!timespec_equal(&inode->i_ctime, &now))
>                 sync_it |= S_CTIME;
> 
>         if (IS_I_VERSION(inode))
>                 sync_it |= S_VERSION;
> 
>         if (!sync_it)
>                 return;
> 	...
> 	mark_inode_dirty_sync(inode);
> 
> So now mark_inode_dirty_sync() is called on every update, instead of
> merely on every update that sees a time change (so at most once a
> jiffy).
> 
> So mark_inode_dirty_sync (and hence ->dirty_inode = ext4_dirty_inode)
> may get called more often if you're writing very frequently.
> 
> I'm a bit surprised that's expected to add significant overhead to the
> write.
> 
> I guess I should stare at the code and try to follow Andreas's
> explanation....
>

It shouldn't, let's be honest, most systems aren't going to have such a coarse
jiffie counter that they'll be able to get away with doing 2 calls to write() or
->page_mkwrite() in the same jiffie and skip the update to mtime/ctime anyway.
If they do they are damned lucky, and again the amount of overhead added even if
they are should be negligible since 99% of us all incur the overhead from having
to update mtime/ctime anyway.  Thanks,

Josef 
