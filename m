Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:42018 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757161AbbCCWo7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 17:44:59 -0500
Date: Wed, 4 Mar 2015 09:44:56 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150303224456.GV4251@dastard>
References: <20150303221033.GB19439@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150303221033.GB19439@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2015 at 05:10:33PM -0500, J. Bruce Fields wrote:
> I'm getting mysterious crashes on a server exporting an xfs filesystem.
> 
> Strangely, I've reproduced this on
> 
> 	93aaa830fc17 "Merge tag 'xfs-pnfs-for-linus-3.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/dgc/linux-xfs
> 
> but haven't yet managed to reproduce on either of its parents
> (24a52e412ef2 or 781355c6e5ae).  That might just be chance, I'll try
> again.

I think you'll find that the bug is only triggered after that XFS
merge because it's what enabled block layout support in the server,
i.e.  nfsd4_setup_layout_type() is now setting the export type to
LAYOUT_BLOCK_VOLUME because XFS has added the necessary functions to
it's export ops.

> I can also try a serial console or something, but for now I'm not
> getting a lot of information about the crashes.

Really need a stack trace - even a photo of the screen with the
stack trace on it will do for starters. ;)

> The filesystem in question isn't on a block device available to the
> client, but I'm still seeing occasional GETLAYOUT and GETDEVICEINFO
> calls; I suppose the client's getting that far, finding no devices it
> can use, and giving up?

I can't see anything in the XFS code that would obviously cause a
problem - its completely unaware to the state of the visibility
of the underlying block device to the pnfs clients or the error
handling paths that PNFS server/clients might take when the block
device is not visible at the client side....

> Sorry for the incomplete report, I'll pass along more when I have it.

No worries, good to have an early heads up. :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
