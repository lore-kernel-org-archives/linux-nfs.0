Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:32499 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757345AbbAHVEJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 16:04:09 -0500
Date: Fri, 9 Jan 2015 08:04:05 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/18] xfs: implement pnfs export operations
Message-ID: <20150108210405.GG25000@dastard>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-18-git-send-email-hch@lst.de>
 <20150107002434.GG31508@dastard>
 <20150107104010.GD28783@lst.de>
 <20150107211140.GC25000@dastard>
 <20150108124327.GA15222@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150108124327.GA15222@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 01:43:27PM +0100, Christoph Hellwig wrote:
> On Thu, Jan 08, 2015 at 08:11:40AM +1100, Dave Chinner wrote:
> > So what happens if a grow occurs, then the server crashes, and the
> > client on reboot sees the same generation as before the grow
> > occured?
> 
> The client doesn't really see the generation.  It's party of the deviceid,
> which is opaqueue to the client.
> 
> If the client sends the opaqueue device ID that contains the generation
> after the grow to a server that had crashed / restarted the server
> will reject it as the server starts at zero.  The causes the client
> to get a new, valid device ID from the server.

But if the server fs has a generation number of zero when it
crashes, how does the client tell that it needs a new device ID from
the server?

> Unlike the NFS file hadles which are persistent the device IDs are volatile
> handles that can go away (and have really horrible life time rules..).

Right. How the clients detect that "going away" when the device
generation is zero both before and after a server crash is the
question I'm asking....

> > > So that we can communicate if a device was grown to the client, which
> > > in this case needs to re-read the device information.
> > 
> > Why does it need to reread the device information? the layouts that
> > are handled to it are still going to be valid from the server POV...
> 
> The existing layouts are still valid.  But any new layout can reference the
> added size, so any new layout needs to point to the new device ID.
> 
> Once the client sees the new device ID it needs to get the information for
> it, which causes it to re-read the device information.

OK.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
