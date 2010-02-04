Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:47081 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593Ab0BDSO6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 13:14:58 -0500
Date: Thu, 4 Feb 2010 12:15:29 -0600
From: bpm@sgi.com
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [RFC PATCH 0/4] wsync export option
Message-ID: <20100204181529.GK5702@sgi.com>
References: <20100203233755.17677.96582.stgit@case> <20100204153006.GC22014@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100204153006.GC22014@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 04, 2010 at 10:30:06AM -0500, Christoph Hellwig wrote:
> On Wed, Feb 03, 2010 at 05:44:24PM -0600, Ben Myers wrote:
> > The following series is adds a 'wsync' export option to nfsd.  It is intended
> > to be used on XFS with the wsync mount option.  When you already have a
> > synchronous log there is no need to sync metadata separately.
>
> You don't need the xfs wsync option, as the existing write_inode calls
> or your new fsync calls are doing the same as the wsync mount option,
> just from a higher layer.

Ok, I see that now.  write_inode_now is basically a superset of what we
need.  The important thing is to force the log (which
xfs_file_operations.xfs_file_fsync does do) but not to call
xfs_super_operations.write_inode (via write_inode_now) which eventually
gets into xfs_iflush and takes forever.  We can take forever later-- when
the log is full.  ;)

> The wsync option causes the log to be synchronously forced up to the
> log sequence number of the commit for the metadata operation, that is
> make all the operations affected by it synchronous.  That's exactly
> what we'll do using fsync (actually right now we force the whole log,
> but I have a patch to optimize it to only force nuntil the last commit
> lsn), and approqimately the same as we do using write_inode, just a
> lot less efficiently.

Rather than having X number of synchronous log transactions written
separately as with wsync you have X number of log transactions written
out together in one go by vfs_fsync (if datasync==0).  That should be
faster than wsync.
 
> > Curious to hear if this is a reasonable thing to do.  Suggestions
> > welcome.
> 
> I think it's reasonable.  What might be even better it to have an
> export operation call out into the filesystem so that we can force
> wsync and not let nfsd deal with it at all.  There is a fair chance
> that the filesystem can do the sync more efficiently.

Trond also suggested an export_operation and I think it's a good idea.
I'll explore that and repost.

Thanks,
	Ben
