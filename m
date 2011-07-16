Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:24961 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751197Ab1GPBzV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 21:55:21 -0400
Date: Sat, 16 Jul 2011 11:50:14 +1000
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, xfs-masters@oss.sgi.com,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [xfs-masters] [PATCH] xfs: failure mapping nfs fh to inode
 should return ESTALE
Message-ID: <20110716015014.GF21663@dastard>
References: <20110714205036.GA19457@fieldses.org>
 <20110714223126.GA28694@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110714223126.GA28694@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 14, 2011 at 06:31:26PM -0400, Christoph Hellwig wrote:
> On Thu, Jul 14, 2011 at 04:50:36PM -0400, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@redhat.com>
> > 
> > On xfs exports, nfsd is incorrectly returning ENOENT instead of ESTALE
> > on attempts to use a filehandle of a deleted file (spotted with pynfs
> > test PUTFH3).  The ENOENT was coming from xfs_iget.
> 
> With that you mean the ip->i_d.di_mode checks?  Given that we should
> only be bale to get these from NFS or the handle ioctls I suspect just
> turning them into ESTALE should be fine.

Bulkstat also checks for ENOENT returns from xfs_iget() as the
lookup it does is inherently racy. That is, if the inode is
allocated when it is read from the IBT, but then has been unlinked
before the actual xfs_iget() call, it expects to get back an ENOENT
to tell it the inode has been unlinked and shouldn't be included in
the bulkstat output. Otherwise, it returns the error to userspace.

So converting the mode checks to return ESTALE definitely has the
chance of breaking stuff that uses bulkstat (e.g. xfsdump) because
it will return errors now where it previously just skipped the
(unlinked) inode.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
