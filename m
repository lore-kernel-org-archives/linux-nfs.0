Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:44766 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbaGORb2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:31:28 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so2731905qcy.16
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 10:31:28 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 13:31:23 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/7] locks: add file_has_lease to prevent delegation
 break races
Message-ID: <20140715133123.5dcb3d6c@tlielax.poochiereds.net>
In-Reply-To: <20140715171752.GA12059@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
	<1405420669-4030-4-git-send-email-jlayton@primarydata.com>
	<20140715171752.GA12059@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 10:17:52 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jul 15, 2014 at 06:37:45AM -0400, Jeff Layton wrote:
> > Once we remove the client_mutex, we'll have a potential race between
> > setting a lease on a file and breaking the delegation. We may set the
> > lease, but by the time we go to hash it, it may have already been
> > broken. Currently, we know that this won't happen as the nfs4_laundromat
> > takes the client_mutex, but we want to remove that.
> > 
> > As part of that fix, add a function that can tell us whether a
> > particular file has a lease set on it. In a later nfsd patch, we'll use
> > that to close the potential race window.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> 
> Looks reasonable, I don't really understand why we can drop out of the
> loop when finding the first non-lease, but other code in locks.c also
> does this, so I assume it is intentional.
> 

It is intentional. The i_flock list is ordered. See the comments over
the struct file_lock definition. Took me a while to understand that too
(which is why I added the comment a few months ago).

> The only real question I have is why this is in locks.c, while
> check_for_locks that does the equivalent for real file locks is
> implemented in the nfsd code.  But I think it's better to have these
> sorts of interfaces in locks.c and check_for_locks should move there
> eventually.
> 

Agreed, though I'll defer that until after this series is merged.

> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks!
-- 
Jeff Layton <jlayton@primarydata.com>
