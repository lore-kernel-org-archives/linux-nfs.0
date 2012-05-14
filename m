Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754951Ab2ENSdW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 14:33:22 -0400
Date: Mon, 14 May 2012 14:33:17 -0400
From: Josef Bacik <josef@redhat.com>
To: "Ted Ts'o" <tytso@mit.edu>
Cc: Andreas Dilger <adilger@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120514183316.GA1894@localhost.localdomain>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <20120514152334.GB29902@fieldses.org>
 <14B38D68-FAE4-444A-BCD9-7EBF7E1BBFE1@dilger.ca>
 <20120514175822.GC1439@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120514175822.GC1439@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2012 at 01:58:22PM -0400, Ted Ts'o wrote:
> On Mon, May 14, 2012 at 11:27:42AM -0600, Andreas Dilger wrote:
> > > And if it at all possible I'd rather have it be something that Just
> > > Works rather than something that requires extra configuration.
> > 
> > Sure, but this is only useful for NFSv4, but costs everyone using
> > ext4 continuous overhead, so it isn't a clear-cut case to enable
> > the version just on the thought that NFS might one day be used on
> > any particular filesystem.
> 
> It's not a matter of "NFSv4 might one day be used"; if we don't turn
> on i_version updates until the file system is actually exported via
> NFSv4, there would be no deleterious effects.
> 
> I always thought that was going to be the plan; that there would be
> some flag that would be set in struct super_block when the file system
> was exported that would enable i_version updates.
> 
> That way we satisfy the "no extra configuration" needed requirement,
> which I agree is ideal, but we also don't waste any CPU overhead if
> the file system is not exported via NFSv4.  I tried to implement
> anything along these lines because I don't care enough, and I don't
> use NFSv4 personally....
> 

Seems like this is just a bad place to be doing inode_inc_iversion().  If
MS_IVERSION is set we will update iversion in file_update_time() and then call
mark_inode_dirty which will jack up the iversion again.  In btrfs we just change
it wherever we change ctime and that way you don't really notice the extra
overhead since you are doing it in paths where you are changing a bunch of stuff
in the inode already, and mostly where you hold the i_mutex so you aren't going
to be hitting any contention on the i_lock.  Thanks,

Josef
