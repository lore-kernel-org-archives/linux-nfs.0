Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li207-46.members.linode.com ([173.255.197.46]:55526 "EHLO
	fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930AbbAVUBa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2015 15:01:30 -0500
Date: Thu, 22 Jan 2015 15:01:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server V2
Message-ID: <20150122200130.GH898@fieldses.org>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 12:09:46PM +0100, Christoph Hellwig wrote:
> This series adds support for the pNFS operations in NFS v4.1, as well
> as a block layout driver that can export block based filesystems that
> implement a few additional export operations.  Support for XFS is
> provided in this series, but other filesystems could be added easily.
> 
> The core pNFS code of course owns its heritage to the existing Linux
> pNFS server prototype, but except for a few bits and pieces in the
> XDR path nothing is left from it.
> 
> The design of this new pNFS server is fairly different from the old
> one - while the old one implemented very little semantics in nfsd
> and left almost everything to filesystems my implementation implements
> as much as possible in common nfsd code, then dispatches to a layout
> driver that still is part of nfsd and only then calls into the
> filesystem, thus keeping it free from intimate pNFS knowledge.
> 
> This version of the code has been rebased to the locks-for-3.20
> tree which adds a new lock context structure to the inode.  For now
> we still (ab)use the lease list like in the last version.  Adding
> a pNFS-specific list would duplicate a lot of code without much
> benefit.  But during this research I came up with way to associate
> a nfs4_file with a struct file at open time which should allow
> to greatly simplify the pNFS and delegation code.  So stay tuned
> for some patches in this area!

Good, that could definitely use simplification.--b.

> 
> For now this also doesn't take errata 3901 for rfc 5661 into account
> yet and sticks to the verified errata.  The changes in 3901 seem
> useful in the longer run one verified and will be implemented
> eventually. Note that the only existing pNFS block client (Linux)
> would not benefit from the longer layout lifetimes anyway.
> 
> More details are document in the individual patch descriptions and
> code comments.
> 
> This code is also available from:
> 
> 	git://git.infradead.org/users/hch/pnfs.git pnfsd-for-3.20-2
> 
> Changes since V1:
> 	- rebased to the locks-for-3.20 tree
> 	- fixed a memory leak in the nfsd4_encode_getdeviceinfo error path
> 	- removed the always one lg_roc field
> 	- added a nopnfs export option
> 	- use a synchronous transaction in layoutget to simplify recovery
> 	- various XFS fixes pointed out by Dave
> 	- various documentation typo fixes
