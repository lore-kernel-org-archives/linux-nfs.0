Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35603 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbbDHQYF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 12:24:05 -0400
Date: Wed, 8 Apr 2015 18:24:03 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, xfs@oss.sgi.com, linux-nfs@vger.kernel.org,
        viro@zeniv.linux.org.uk
Subject: Re: [PATCH] xfs: unlock i_mutex in xfs_break_layouts
Message-ID: <20150408162403.GD16052@lst.de>
References: <1428420944-20965-1-git-send-email-hch@lst.de> <20150407221927.GD15810@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150407221927.GD15810@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2015 at 08:19:27AM +1000, Dave Chinner wrote:
> That's kinda nasty, and it has no documentation explaining when or
> why we'd need to drop the i_mutex. How are we supposed to know if we
> need to drop the i_mutex or not?

We need to drop it if we hold it, pretty easy.

> What happens if the upper VFS
> layers change or we have a multiple call paths that have different
> i_mutex contexts (i.e. one holds, another doesn't)?

We avoid this in the VFS, as everytime we had it filesystems were getting it
wrong.

However you have a point in that we should probably have asserts that the
right locks are held.

> Which makes me wonder - is this layout breaking stuff at the right
> layer?

We can't do it in the VFS as it needs to be atomic vs the lock that
protects write in ->write and ->fallocate, which is only taken in
the filesystem.  For ->setattr in theory we could do it in the VFS,
but if the other callers can't do it in the VFS that will just lead
to code duplication.
