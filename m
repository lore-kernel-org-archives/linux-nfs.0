Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:40919 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750903Ab1GST3d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jul 2011 15:29:33 -0400
Subject: Re: [xfs-masters] [PATCH] xfs: failure mapping nfs fh to inode
 should return ESTALE
From: Alex Elder <aelder@sgi.com>
Reply-To: <aelder@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@infradead.org>, <xfs-masters@oss.sgi.com>,
        <linux-nfs@vger.kernel.org>, <xfs@oss.sgi.com>
In-Reply-To: <20110718133710.GB9741@fieldses.org>
References: <20110714205036.GA19457@fieldses.org>
	 <20110714223126.GA28694@infradead.org> <20110716015014.GF21663@dastard>
	 <20110716015346.GA589@infradead.org>  <20110718133710.GB9741@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Jul 2011 14:29:25 -0500
Message-ID: <1311103765.1964.20.camel@doink>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-07-18 at 09:37 -0400, J. Bruce Fields wrote:
> On Fri, Jul 15, 2011 at 09:53:46PM -0400, Christoph Hellwig wrote:
> > On Sat, Jul 16, 2011 at 11:50:14AM +1000, Dave Chinner wrote:
> > > Bulkstat also checks for ENOENT returns from xfs_iget() as the
> > > lookup it does is inherently racy. That is, if the inode is
> > > allocated when it is read from the IBT, but then has been unlinked
> > > before the actual xfs_iget() call, it expects to get back an ENOENT
> > > to tell it the inode has been unlinked and shouldn't be included in
> > > the bulkstat output. Otherwise, it returns the error to userspace.
> > > 
> > > So converting the mode checks to return ESTALE definitely has the
> > > chance of breaking stuff that uses bulkstat (e.g. xfsdump) because
> > > it will return errors now where it previously just skipped the
> > > (unlinked) inode.
> > 
> > Sounds like we should simply go with the original version of the patch
> > then.
> 
> OK.  Let me know if someone needs that resent....
> 
> --b.

No need.  I'll use the original one.  Thanks.	-Alex

