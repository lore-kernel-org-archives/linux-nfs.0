Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:6522 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753581AbbAFXfd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:35:33 -0500
Date: Wed, 7 Jan 2015 10:18:46 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 18/18] xfs: recall pNFS layouts on conflicting access
Message-ID: <20150106231846.GE31508@dastard>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-19-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420561721-9150-19-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 05:28:41PM +0100, Christoph Hellwig wrote:
> Recall all outstanding pNFS layouts and truncates, writes and similar extent
> list modifying operations.

This is not sufficient to isolate extent manipulations. mmap writes
can trigger allocation through ->page_mkwrite, and can also trigger
extent conversion at IO completion without first needing allocation.

Maybe I'm missing something - this patchset needs some comments
documenting the locking used in XFS to co-ordinate layout coherency
at the client side with IO that is in progress for clients with
overlapping block maps, as well as against server side application
IO.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
