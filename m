Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:42030 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750938Ab3LBXet (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 18:34:49 -0500
Date: Tue, 3 Dec 2013 10:34:44 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, xfs@oss.sgi.com, Mark Fasheh <mfasheh@suse.com>,
        reiserfs-devel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-mtd@lists.infradead.org,
        Joel Becker <jlbec@evilplan.org>, jfs-discussion@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 14/18] xfs: use generic posix ACL infrastructure
Message-ID: <20131202233444.GH10988@dastard>
References: <20131201115903.910559036@bombadil.infradead.org>
 <20131201120656.194735588@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131201120656.194735588@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 01, 2013 at 03:59:17AM -0800, Christoph Hellwig wrote:
> Also create inodes with the proper mode instead of fixing it up later.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Nice cleanup work, Christoph.

Reviewed-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com
