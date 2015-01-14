Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:45995 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752279AbbANKIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 05:08:31 -0500
Date: Wed, 14 Jan 2015 11:08:27 +0100
From: Christoph Hellwig <hch@lst.de>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/18] xfs: implement pnfs export operations
Message-ID: <20150114100827.GA11788@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-18-git-send-email-hch@lst.de> <20150107002434.GG31508@dastard> <20150107104010.GD28783@lst.de> <20150107211140.GC25000@dastard> <20150108124327.GA15222@lst.de> <20150108210405.GG25000@dastard> <20150109114159.GA25728@lst.de> <20150112030401.GA29484@destitution>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150112030401.GA29484@destitution>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2015 at 02:04:01PM +1100, Dave Chinner wrote:
> Ok, so:
> 
> client				server
> 
> get layout
> dev id == 0
> 				grow
> 				gen++ (=1)
> 				crash
> 				....
> 				gen = 0 (initialised after boot)
> 
> commit layout
> dev id == 0
> 				server executes op, even though
> 				device has changed....
> 
> What prevents this? Shouldn't the server be rejecting the commit
> layout operation as there was a grow operation between the client
> operations?

There is no need to reject the commit.  Grows for the block layout
driver never invalidate existing layouts, as they are purely grow
operation.  The only reason to bother with the generation is
to ensure that new layouts might point into areas the client
didn't previously known about.  So the interesting variation of your
scenario above is:

client				server

				grow
 				gen++ (=1)

get layout
dev id == (x, 1)
 				crash
 				....
 				gen = 0 (initialised after boot)
 
commit layout
id == 1

Which will be rejected, and the client either choses to get a
new layout / deviceID, or just writes the data back through normal
I/O.

Now one interesting case would be a resize that completed in
memory, gets a layout refering to it send out, but not commited to disk,
and then anothe resize to a smaller size before the commit.  Not
really practical, but if it happend we could get writes beyond the
end of the filesystem.

I didn't assume this was possible as I assumed growfs to be synchronous,
but it turns out while we do various synchronous buffer writes the
transaction isn't actually commited synchronously.

I think we should just make growfs commit the transaction
synchronously to avoid both the pnfs problem, as well as the
problem of growfs potentially updating the secondary superblocks
before the transaction hit the disk.
