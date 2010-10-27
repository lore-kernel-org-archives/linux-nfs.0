Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58035 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760867Ab0J0P2f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Oct 2010 11:28:35 -0400
Date: Wed, 27 Oct 2010 11:28:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027152829.GE6328@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <201010271723.59734.arnd@arndb.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201010271723.59734.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 05:23:59PM +0200, Arnd Bergmann wrote:
> On Wednesday 27 October 2010, Christoph Hellwig wrote:
> > On Wed, Oct 27, 2010 at 10:55:39AM -0400, J. Bruce Fields wrote:
> > > Hm, two problems:
> > > 	- We introduce the possibility of fcntl(fd, F_SETLEASE, F_UNLCK)
> > > 	  failing with ENOMEM.
> > 
> > splitt ->setlease into ->add_least and ->delete_lease.  No need to pass
> > in a structure for the later.  No need to return one either.
> 
> That sounds like a good way to get rid of a lot of special cases, too.
> 
> > > 	- fasync_helper(.,.,1,.) sleeps.  Argh.
> > 
> > That's not new..
> 
> It comes back to the original problem with Bruce's patch though:
> fcntl_setlease wants to atomically add a lease or fail. If
> fasync_helper fails, we want to remove the lease that was
> just added before anyone can see it. At the very least we need
> to keep the flock from getting freed in another thread while
> we call fasync_helper without the lock.
> 
> locks_delete_lock is also called with lock_flocks held and calls
> fasync_helper...

Yeah, but just the fasync_remove_entry() case.

It would really seem nicer to me if people called
fasync_{add,remove}_entry() instead of having this silly fasync_helper()
and making the reader remember what the third argument means.

--b.
