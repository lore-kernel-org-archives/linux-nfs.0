Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:45600 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbbBBT30 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 14:29:26 -0500
Date: Tue, 3 Feb 2015 06:24:04 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 16/20] xfs: pass a 64-bit count argument to
 xfs_iomap_write_unwritten
Message-ID: <20150202192404.GI6282@dastard>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-17-git-send-email-hch@lst.de>
 <20150129205232.GB11064@fieldses.org>
 <20150202073024.GA9399@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202073024.GA9399@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 02, 2015 at 08:30:24AM +0100, Christoph Hellwig wrote:
> On Thu, Jan 29, 2015 at 03:52:32PM -0500, J. Bruce Fields wrote:
> > Who can give us ACKs on these last five fs/xfs patches?  (And is it
> > going to cause trouble if they go in through the nfsd tree?)
> 
> 
> We'd need ACKs from Dave.  He already has pulled in two patches so
> we might run into some conflicts.  Maybe the best idea is to add the
> exportfs patch to both the XFS and nfsd trees, so each of them can
> pull in the rest?  Or we could commit the two XFS preparation patches
> to both tree and get something that compiles and works in the nfsd
> tree.

This patch has already been committed to the XFS repo.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
