Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43130 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932594AbbBBHa3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 02:30:29 -0500
Date: Mon, 2 Feb 2015 08:30:24 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 16/20] xfs: pass a 64-bit count argument to
	xfs_iomap_write_unwritten
Message-ID: <20150202073024.GA9399@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <1421925006-24231-17-git-send-email-hch@lst.de> <20150129205232.GB11064@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150129205232.GB11064@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 29, 2015 at 03:52:32PM -0500, J. Bruce Fields wrote:
> Who can give us ACKs on these last five fs/xfs patches?  (And is it
> going to cause trouble if they go in through the nfsd tree?)


We'd need ACKs from Dave.  He already has pulled in two patches so
we might run into some conflicts.  Maybe the best idea is to add the
exportfs patch to both the XFS and nfsd trees, so each of them can
pull in the rest?  Or we could commit the two XFS preparation patches
to both tree and get something that compiles and works in the nfsd
tree.
