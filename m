Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:6828 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753124AbbBAXJM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Feb 2015 18:09:12 -0500
Date: Mon, 2 Feb 2015 10:06:53 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>,
        xfs@oss.sgi.com
Subject: Re: [PATCH 18/20] xfs: factor out a xfs_update_prealloc_flags()
 helper
Message-ID: <20150201230653.GE4251@dastard>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-19-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421925006-24231-19-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 12:10:04PM +0100, Christoph Hellwig wrote:
> This logic is duplicated in xfs_file_fallocate and xfs_ioc_space, and
> we'll need another copy of it for pNFS block support.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

This stands alone, so I'm pulling it into the XFS tree without
waiting for the rest of the patch set.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
