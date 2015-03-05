Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59562 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755808AbbCEPVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2015 10:21:17 -0500
Date: Thu, 5 Mar 2015 10:21:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150305152117.GB15674@fieldses.org>
References: <20150303221033.GB19439@fieldses.org>
 <20150303224456.GV4251@dastard>
 <20150304020826.GD19439@fieldses.org>
 <20150304044141.GQ18360@dastard>
 <20150305131901.GB16235@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150305131901.GB16235@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 05, 2015 at 02:19:01PM +0100, Christoph Hellwig wrote:
> On Wed, Mar 04, 2015 at 03:41:41PM +1100, Dave Chinner wrote:
> > As I understand it, nothing will prevent this - if you don't change
> > the UUID on the filesystem when you clone it, then the UUID will
> > still match and writes can be directed to any block deice with a
> > matching offset/UUID pair.
> 
> Unfortunately that's the case indeed.  The whole discovery part of
> the block layout protocol is fundamentally flawed, as is the recall
> part.  This is my attempt to fix it, but I have no idea how to proceed
> from posting my draft to the IETF to actually making it a standard:
> 
> http://tools.ietf.org/html/draft-hellwig-nfsv4-scsi-layout-00

Keep asking, I guess.

I'll try to give it a review too.

May be another reason we can't keep it on by default, if it all it takes
is some confusion with snapshots and something disastrous happens on
upgrade to a block pnfs-supporting kernel.

Though maybe that's really a client bug, as it should probably be
getting an OK from someone before using a device.  Arguably the
"systemctl start nfs-blkmap" or equivalent is that, but something more
explicit might be better.

--b.
