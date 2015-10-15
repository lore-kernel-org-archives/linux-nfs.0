Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:28044 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbbJOIgE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 04:36:04 -0400
Date: Thu, 15 Oct 2015 19:35:47 +1100
From: Dave Chinner <david@fromorbit.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, P??draig Brady <P@draigBrady.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
Message-ID: <20151015083547.GR31326@dastard>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142939.GA30905@infradead.org>
 <561B8A09.5070507@draigBrady.com>
 <20151012143444.GA10156@infradead.org>
 <20151012234106.GD11398@birch.djwong.org>
 <20151013072959.GB10794@infradead.org>
 <20151014184608.GK850@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151014184608.GK850@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:46:08AM -0700, Darrick J. Wong wrote:
> On Tue, Oct 13, 2015 at 12:29:59AM -0700, Christoph Hellwig wrote:
> > On Mon, Oct 12, 2015 at 04:41:06PM -0700, Darrick J. Wong wrote:
> > > One of the patches in last week's XFS reflink patchbomb adds FALLOC_FL_UNSHARE
> > > flag; at the moment it _only_ forces copy-on-write of shared blocks, and it
> > > leaves holes alone.
> > 
> > Yes, I've seen the implementation. 
> > 
> > > Obviously we haven't yet figured out what are peoples' preferences in terms of
> > > "fill the holes and unshare the shared" vs. "only unshare the shared" vs. "only
> > > fill the holes".  It isn't that hard to add a FALLOC_FL_UNSHARE_FILL_HOLES flag
> > > that fills the holes while unsharing is going on.
> > > 
> > > Personally I suspect that the most interest is in filling holes and unsharing,
> > > because they don't want to pay for allocation at a critical stage for anywhere
> > > in the file.  But I could be wrong, so allowing both goals to be expressed via
> > > mode allows flexibility.
> > 
> > Exactly.  And a normal falloc should do just that - fill holes and
> > ensure that we don't need to COW already allocated locks.  So I don't
> > think we need a new fallocate interface for that.
> 
> The documentation for fallocate ought to be updated to include that as part of
> guaranteeing that subsequent writes to the range won't fail due to ENOSPC,
> shared blocks will be unshared.
> 
> Incidentally, btrfs leaves shared blocks alone.  OTOH, given that it's totally
> COW it probably doesn't make sense to unshare blocks anyway... but maybe I
> also don't want to dive into btrfs f-allocation behavior at this time. :)
> 
> Ok, so I'll rework the XFS funshare code into something that hangs off the
> regular fallocate call, and get rid of the explicit 'funshare' bits.

Makes sense given we have the FALLOC_FL_ZERO_RANGE operation which
returns a zero to and preallocates all the holes in the range. I
would expect this operation on shared blocks to unshare blocks,
too...

> > The question is if we
> > want a copy interface that gives you the same semantics as if you also
> > called an fallocate on the destination range.  For that case we'd
> > usually want to avoid doing the clone and instead do a in-kernel or
> > hardware assisted copy and then fill the holes with unwritten extents.

If hole filling was required, then I'd do the operation the other
way around - prealloc the entire range, then do hardware assisted
copy of each separate data range in the source file with unwritten
extent conversion on offload completion...

> Probably; I can easily imagine people wanting to fill the holes and also
> not wanting them filled.

*nod*.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
