Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:59205 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbbAGKby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 05:31:54 -0500
Date: Wed, 7 Jan 2015 11:31:52 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 18/18] xfs: recall pNFS layouts on conflicting access
Message-ID: <20150107103152.GC28783@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-19-git-send-email-hch@lst.de> <20150106231846.GE31508@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150106231846.GE31508@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 07, 2015 at 10:18:46AM +1100, Dave Chinner wrote:
> On Tue, Jan 06, 2015 at 05:28:41PM +0100, Christoph Hellwig wrote:
> > Recall all outstanding pNFS layouts and truncates, writes and similar extent
> > list modifying operations.
> 
> This is not sufficient to isolate extent manipulations. mmap writes
> can trigger allocation through ->page_mkwrite, and can also trigger
> extent conversion at IO completion without first needing allocation.
> 
> Maybe I'm missing something - this patchset needs some comments
> documenting the locking used in XFS to co-ordinate layout coherency
> at the client side with IO that is in progress for clients with
> overlapping block maps, as well as against server side application
> IO.

Ys, the description was a little to dense.  We only care about extent list
manipulations that remove or change existing block mappings.  Newly
allocated blocks don't concern the pNFS operation.

I'll take care of better documentation.
