Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55733 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261Ab0J3VZY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:25:24 -0400
Date: Sat, 30 Oct 2010 17:25:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101030212500.GE480@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101027145929.GA5788@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I noticed a couple problems with the lease patches.  Also:

On Wed, Oct 27, 2010 at 10:59:29AM -0400, Christoph Hellwig wrote:
> On Wed, Oct 27, 2010 at 10:55:39AM -0400, J. Bruce Fields wrote:
> > Hm, two problems:
> > 	- We introduce the possibility of fcntl(fd, F_SETLEASE, F_UNLCK)
> > 	  failing with ENOMEM.
> 
> splitt ->setlease into ->add_least and ->delete_lease.  No need to pass
> in a structure for the later.  No need to return one either.

We still need to do this part.  I just did the minimum required to fix
the problem--I figure splitting out a separate ->delete_lease method
(which I agree would be cleaner) could wait till the next merge window.

Patches follow, tested on top of the merge of Arnd's patches; if they
look OK they can go in, or I can commit them on top of a few pending
nfsd fixes and send another pull request.

It'd be nice if we get this fixed by -rc1, but not the end of the world
if we don't.

--b.
