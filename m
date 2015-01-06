Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51801 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157AbbAFRcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2015 12:32:24 -0500
Date: Tue, 6 Jan 2015 12:32:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server
Message-ID: <20150106173222.GF12067@fieldses.org>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 05:28:23PM +0100, Christoph Hellwig wrote:
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
> More details are document in the individual patch descriptions and
> code comments.
> 
> This code is also available from:
> 
> 	git://git.infradead.org/users/hch/pnfs.git pnfsd-for-3.20

Neat, thanks!  I'll look at it.

Some naive questions:

	- do we have evidence that this is useful in its current form?

	- any advice on testing?  Is there was some simple virtual setup
	  that would allow any loser with no special hardware (e.g., me)
	  to check whether they've broken the block server?

	- any debugging advice?  E.g., have you checked if current
	  wireshark can handle the MDS traffic?

--b.
