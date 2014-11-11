Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:44009 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbaKKW1p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 17:27:45 -0500
Date: Wed, 12 Nov 2014 09:27:10 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141111222710.GY23575@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141111162849.GA12527@lst.de>
 <20141111162704.GA12103@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 05:27:04PM +0100, Christoph Hellwig wrote:
> On Tue, Nov 11, 2014 at 07:36:48AM -0500, Trond Myklebust wrote:
> > Just out of curiosity, though, why does XFS update i_version on every
> > block allocation? For NFSv4 compatibility, it really should suffice
> > for it to just do the update once in the above case. Did Lustre have
> > more stringent requirements?
> 
> It's literatlly updated everytime inode metadata changes.  Dave implemented
> this, so I don't know the real rationale behind it.  I don't think anyone
> sane cares about Lustre ever, certainly not for XFS.

/me goes for the thread to understand the context of the question

To clarify what Christoph wrote, XFS updates i_version is updated
once per transaction that modifies the inode. So if a VFS level
operation results in multiple transactions then each transaction
will but the version.

It was implemented that way because nobody could tell me what the
actual granularity requirement for change detection was.  Hence what
I implemented was "be able to detect any persistent change that is
made" to cover all bases.

On Tue, Nov 11, 2014 at 05:28:49PM +0100, Christoph Hellwig wrote:
> On Tue, Nov 11, 2014 at 05:27:04PM +0100, Christoph Hellwig wrote:
> > On Tue, Nov 11, 2014 at 07:36:48AM -0500, Trond Myklebust wrote:
> > > Just out of curiosity, though, why does XFS update i_version on every
> > > block allocation? For NFSv4 compatibility, it really should suffice
> > > for it to just do the update once in the above case. Did Lustre have
> > > more stringent requirements?
> > 
> > It's literatlly updated everytime inode metadata changes.  Dave implemented
> > this, so I don't know the real rationale behind it.  I don't think anyone
> > sane cares about Lustre ever, certainly not for XFS.
> 
> Btw, I think we have an even more important issue with di_changecount:
> as far as I tell we never initialize i_version to di_changecount when
> reading the inode from disk, so inodes might move backwards in their
> version.  I'll take care of this once we have settled the nfs semantics.

Yup, that's an oversight. The problem of adding functionality that
people want but aren't using and don't know exactly how they are
going to use it is that there's nothing to test that it's really
doing the right thing...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
