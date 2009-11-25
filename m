From: Christoph Hellwig <hch@infradead.org>
Subject: Re: XFS, NFS and inode64 on 2.6.27
Date: Wed, 25 Nov 2009 16:13:24 -0500
Message-ID: <20091125211324.GA12833@infradead.org>
References: <200911231419.50678@zmi.at> <20091123155109.GA3292@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Monnerie <michael.monnerie@is.it-management.at>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38313 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678AbZKYVNU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2009 16:13:20 -0500
In-Reply-To: <20091123155109.GA3292@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2009 at 10:51:09AM -0500, J. Bruce Fields wrote:
> But not the other four directories?  What error do you get when you try?
> What client are you using, and are you mounting with NFSv2, NFSv3, or
> NFSv4?  Could we see a network trace of a failed mount?  (So, run

>From information Michael posted on the xfs list he is not exporting the
root of filesystems, which means we use a file system handle format that
needs to encode the inode.  And all but the uuid16 format can only
encode 32 bit inode numbers.  I very strongly suspect that this is the
underlying issue here, but I'm currenly not uptodate on the filesystem
handle selection in nfsutils.

