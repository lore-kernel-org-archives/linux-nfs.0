From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: XFS, NFS and inode64 on 2.6.27
Date: Wed, 25 Nov 2009 18:55:44 -0500
Message-ID: <20091125235543.GA4928@fieldses.org>
References: <200911231419.50678@zmi.at> <20091123155109.GA3292@fieldses.org> <20091125211324.GA12833@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Monnerie <michael.monnerie@is.it-management.at>,
	linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37744 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965009AbZKYXzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2009 18:55:02 -0500
In-Reply-To: <20091125211324.GA12833@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2009 at 04:13:24PM -0500, Christoph Hellwig wrote:
> On Mon, Nov 23, 2009 at 10:51:09AM -0500, J. Bruce Fields wrote:
> > But not the other four directories?  What error do you get when you try?
> > What client are you using, and are you mounting with NFSv2, NFSv3, or
> > NFSv4?  Could we see a network trace of a failed mount?  (So, run
> 
> >From information Michael posted on the xfs list he is not exporting the
> root of filesystems, which means we use a file system handle format that
> needs to encode the inode.  And all but the uuid16 format can only
> encode 32 bit inode numbers.  I very strongly suspect that this is the
> underlying issue here, but I'm currenly not uptodate on the filesystem
> handle selection in nfsutils.

If using an nfs-utils recent enough to pass down a uuid (can check this
by looking at /proc/net/rpc/nfsd.export/filehandle after trying to
access those directories, and seeing whether there's a uuid= option
set), then I'd expect it to be using FSID_UUID16_INUM with v3 or v4 (v2
doesn't have large enough filehandles).

--b.
