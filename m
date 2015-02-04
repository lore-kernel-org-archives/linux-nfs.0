Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:48539 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbbBDH6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Feb 2015 02:58:00 -0500
Date: Wed, 4 Feb 2015 08:57:56 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@primarydata.com>, xfs@oss.sgi.com
Subject: Re: [PATCH 16/20] xfs: pass a 64-bit count argument to
	xfs_iomap_write_unwritten
Message-ID: <20150204075756.GA763@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <1421925006-24231-17-git-send-email-hch@lst.de> <20150129205232.GB11064@fieldses.org> <20150202073024.GA9399@lst.de> <20150202192404.GI6282@dastard> <20150202194300.GN6282@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202194300.GN6282@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 03, 2015 at 06:43:00AM +1100, Dave Chinner wrote:
> As to the pNFSD specific changes, I haven't really looked them over
> in any great detail yet. My main concern is that there are no
> specific regression tests for this yet, I'm not sure how we go about
> verifying it actually works properly and we don't inadvertantly
> break it in the future. Christoph?

Any chance you could review them this week so we can get them
merged in time for 3.20?  In the worst case Bruce will have to pull
the xfs tree into the nfsd tree so that we have all the dependencies
available.
