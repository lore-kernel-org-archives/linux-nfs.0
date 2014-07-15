Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42232 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbaGORRy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:17:54 -0400
Date: Tue, 15 Jul 2014 10:17:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 3/7] locks: add file_has_lease to prevent delegation
 break races
Message-ID: <20140715171752.GA12059@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
 <1405420669-4030-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405420669-4030-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:37:45AM -0400, Jeff Layton wrote:
> Once we remove the client_mutex, we'll have a potential race between
> setting a lease on a file and breaking the delegation. We may set the
> lease, but by the time we go to hash it, it may have already been
> broken. Currently, we know that this won't happen as the nfs4_laundromat
> takes the client_mutex, but we want to remove that.
> 
> As part of that fix, add a function that can tell us whether a
> particular file has a lease set on it. In a later nfsd patch, we'll use
> that to close the potential race window.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks reasonable, I don't really understand why we can drop out of the
loop when finding the first non-lease, but other code in locks.c also
does this, so I assume it is intentional.

The only real question I have is why this is in locks.c, while
check_for_locks that does the equivalent for real file locks is
implemented in the nfsd code.  But I think it's better to have these
sorts of interfaces in locks.c and check_for_locks should move there
eventually.

Reviewed-by: Christoph Hellwig <hch@lst.de>
