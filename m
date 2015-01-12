Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:58584 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750976AbbAMU1f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 15:27:35 -0500
Date: Mon, 12 Jan 2015 14:04:01 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/18] xfs: implement pnfs export operations
Message-ID: <20150112030401.GA29484@destitution>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-18-git-send-email-hch@lst.de>
 <20150107002434.GG31508@dastard>
 <20150107104010.GD28783@lst.de>
 <20150107211140.GC25000@dastard>
 <20150108124327.GA15222@lst.de>
 <20150108210405.GG25000@dastard>
 <20150109114159.GA25728@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150109114159.GA25728@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 12:41:59PM +0100, Christoph Hellwig wrote:
> On Fri, Jan 09, 2015 at 08:04:05AM +1100, Dave Chinner wrote:
> > > If the client sends the opaqueue device ID that contains the generation
> > > after the grow to a server that had crashed / restarted the server
> > > will reject it as the server starts at zero.  The causes the client
> > > to get a new, valid device ID from the server.
> > 
> > But if the server fs has a generation number of zero when it
> > crashes, how does the client tell that it needs a new device ID from
> > the server?
> >
> > > Unlike the NFS file hadles which are persistent the device IDs are volatile
> > > handles that can go away (and have really horrible life time rules..).
> > 
> > Right. How the clients detect that "going away" when the device
> > generation is zero both before and after a server crash is the
> > question I'm asking....
> 
> The server tells the client by rejecting the operation using the
> device ID.

Ok, so:

client				server

get layout
dev id == 0
				grow
				gen++ (=1)
				crash
				....
				gen = 0 (initialised after boot)

commit layout
dev id == 0
				server executes op, even though
				device has changed....

What prevents this? Shouldn't the server be rejecting the commit
layout operation as there was a grow operation between the client
operations?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
