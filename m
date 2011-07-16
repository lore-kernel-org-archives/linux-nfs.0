Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:33034
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751197Ab1GPBxu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 21:53:50 -0400
Date: Fri, 15 Jul 2011 21:53:46 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, xfs-masters@oss.sgi.com,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [xfs-masters] [PATCH] xfs: failure mapping nfs fh to inode
 should return ESTALE
Message-ID: <20110716015346.GA589@infradead.org>
References: <20110714205036.GA19457@fieldses.org>
 <20110714223126.GA28694@infradead.org>
 <20110716015014.GF21663@dastard>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110716015014.GF21663@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 16, 2011 at 11:50:14AM +1000, Dave Chinner wrote:
> Bulkstat also checks for ENOENT returns from xfs_iget() as the
> lookup it does is inherently racy. That is, if the inode is
> allocated when it is read from the IBT, but then has been unlinked
> before the actual xfs_iget() call, it expects to get back an ENOENT
> to tell it the inode has been unlinked and shouldn't be included in
> the bulkstat output. Otherwise, it returns the error to userspace.
> 
> So converting the mode checks to return ESTALE definitely has the
> chance of breaking stuff that uses bulkstat (e.g. xfsdump) because
> it will return errors now where it previously just skipped the
> (unlinked) inode.

Sounds like we should simply go with the original version of the patch
then.
