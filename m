Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:33761 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754544AbbAHMna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2015 07:43:30 -0500
Date: Thu, 8 Jan 2015 13:43:27 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/18] xfs: implement pnfs export operations
Message-ID: <20150108124327.GA15222@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-18-git-send-email-hch@lst.de> <20150107002434.GG31508@dastard> <20150107104010.GD28783@lst.de> <20150107211140.GC25000@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150107211140.GC25000@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 08:11:40AM +1100, Dave Chinner wrote:
> So what happens if a grow occurs, then the server crashes, and the
> client on reboot sees the same generation as before the grow
> occured?

The client doesn't really see the generation.  It's party of the deviceid,
which is opaqueue to the client.

If the client sends the opaqueue device ID that contains the generation
after the grow to a server that had crashed / restarted the server
will reject it as the server starts at zero.  The causes the client
to get a new, valid device ID from the server.

Unlike the NFS file hadles which are persistent the device IDs are volatile
handles that can go away (and have really horrible life time rules..).

> > Every block allocation from a pNFS client goes through this path, so
> > yes it is performance critical.
> 
> Sure, but how many allocations per second are we expecting to have
> to support? We can do tens of thousands of synchronous transactions
> per second on luns with non-volatile write caches, so I'm really
> wondering how much of a limitation this is going to be in the real
> world. Do you have any numbers?

I don't have numbers right now without running specific benchmarks,
but the rate will be about the same as for local XFS use on the same
workload.

> 
> > > So whenever the server first starts up the generation number in a
> > > map is going to be zero - what purpose does this actually serve?
> > 
> > So that we can communicate if a device was grown to the client, which
> > in this case needs to re-read the device information.
> 
> Why does it need to reread the device information? the layouts that
> are handled to it are still going to be valid from the server POV...

The existing layouts are still valid.  But any new layout can reference the
added size, so any new layout needs to point to the new device ID.

Once the client sees the new device ID it needs to get the information for
it, which causes it to re-read the device information.
