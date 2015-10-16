Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:8298 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750774AbbJPVov (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 17:44:51 -0400
Date: Sat, 17 Oct 2015 08:44:35 +1100
From: Dave Chinner <david@fromorbit.com>
To: Chris Mason <clm@fb.com>, Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        P??draig Brady <P@draigBrady.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        mtk.manpages@gmail.com, andros@netapp.com
Subject: Re: [PATCH v5 9/9] btrfs: btrfs_copy_file_range() only supports
 reflinks
Message-ID: <20151016214435.GA2786@dastard>
References: <20151011142939.GA30905@infradead.org>
 <561B8A09.5070507@draigBrady.com>
 <20151012143444.GA10156@infradead.org>
 <20151012234106.GD11398@birch.djwong.org>
 <20151013072959.GB10794@infradead.org>
 <20151014184608.GK850@birch.djwong.org>
 <20151015060045.GA23996@infradead.org>
 <20151016114919.GB6874@ret.masoncoding.com>
 <20151016122544.GC5889@infradead.org>
 <20151016131950.GC6874@ret.masoncoding.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151016131950.GC6874@ret.masoncoding.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 16, 2015 at 09:19:50AM -0400, Chris Mason wrote:
> On Fri, Oct 16, 2015 at 05:25:44AM -0700, Christoph Hellwig wrote:
> > On Fri, Oct 16, 2015 at 07:49:19AM -0400, Chris Mason wrote:
> > > > Yes, that would be my preference.  I'd also like to understand what
> > > > exactly btrfs does in fallocate.
> > > 
> > > For which part?  The answer changes based on how many references there
> > > are to a given fallocated region.
> > 
> > Both cases.  With btrfs allocating new block on every write how do you
> > avoid that ENOSPC?  Is there a unassigned block preallocation that's
> > made persistent in some way?
> 
> So:
> 
> fallocate 1g -> foo
> 
> reflink foo foo2
> 
> We've now implicitly doubled the size of the fallocate, but at reflink

No, I don't think it implies that at all. the posix_fallocate()
"future writes will succeed" guarantee only applies to foo, not to
/copies/ such as foo2. At it's core, reflink is just an optimised
file copy mechanism - the resultant copy should have the same
behaviour as a file copied by read/write. Copies done by physically
copying data do not duplicate fallocate() regions or guarantees from
the source file to the destination file.

> time btrfs doesn't account for the doubling.  It's actually much
> better in this case to just use a hole because neither foo or foo2 can
> use the preallocated space until the 1g is fully unshared.

Right - this implies unwritten extents should not be shared by
reflink, instead either skipped (i.e. leave as a hole in foo2 as you
suggest) or duplicated so that the next write to the region of foo2
will also succeed. I'd suggest that COPY_FALLOC (or whatever it'll
get called) implies the latter behaviour, the default behaviour
being the former...

> When we're doing writes, it'll check the preallocated extents for extra
> refs and force COW if any exist.  So writes into a preallocated region
> can enospc.

This really seems like an btrfs interpretation/implementation
issue, not a problem for reflink in general.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
