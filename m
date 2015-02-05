Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:11140 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755922AbbBEAvt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 19:51:49 -0500
Date: Thu, 5 Feb 2015 11:51:05 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 20/20] xfs: recall pNFS layouts on conflicting access
Message-ID: <20150205005105.GP4251@dastard>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-21-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421925006-24231-21-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 12:10:06PM +0100, Christoph Hellwig wrote:
> Recall all outstanding pNFS layouts and truncates, writes and similar extent
> list modifying operations.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

This looks fine, assuming break_layout() doesn't require any other
VFS inode locks to be held for serialisation.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
