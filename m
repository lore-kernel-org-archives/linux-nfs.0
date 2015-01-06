Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55197 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbbAFQ3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:30 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: a simple and scalable pNFS block layout server
Date: Tue,  6 Jan 2015 17:28:23 +0100
Message-Id: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series adds support for the pNFS operations in NFS v4.1, as well
as a block layout driver that can export block based filesystems that
implement a few additional export operations.  Support for XFS is
provided in this series, but other filesystems could be added easily.

The core pNFS code of course owns its heritage to the existing Linux
pNFS server prototype, but except for a few bits and pieces in the
XDR path nothing is left from it.

The design of this new pNFS server is fairly different from the old
one - while the old one implemented very little semantics in nfsd
and left almost everything to filesystems my implementation implements
as much as possible in common nfsd code, then dispatches to a layout
driver that still is part of nfsd and only then calls into the
filesystem, thus keeping it free from intimate pNFS knowledge.

More details are document in the individual patch descriptions and
code comments.

This code is also available from:

	git://git.infradead.org/users/hch/pnfs.git pnfsd-for-3.20

