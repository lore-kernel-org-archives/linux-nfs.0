Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39622 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933342Ab0J0PUc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 11:20:32 -0400
Date: Wed, 27 Oct 2010 11:19:59 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027151959.GA17370@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101027151645.GD6328@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101027151645.GD6328@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 11:16:46AM -0400, J. Bruce Fields wrote:
> On Wed, Oct 27, 2010 at 10:59:29AM -0400, Christoph Hellwig wrote:
> > On Wed, Oct 27, 2010 at 10:55:39AM -0400, J. Bruce Fields wrote:
> > > Hm, two problems:
> > > 	- We introduce the possibility of fcntl(fd, F_SETLEASE, F_UNLCK)
> > > 	  failing with ENOMEM.
> > 
> > splitt ->setlease into ->add_least and ->delete_lease.  No need to pass
> > in a structure for the later.  No need to return one either.
> 
> Sounds fine to me.
> 
> > 
> > > 	- fasync_helper(.,.,1,.) sleeps.  Argh.
> > 
> > That's not new..
> 
> So we could do
> 
> 	unlock_flocks();
> 	error = fasync_helper(fd, filp, 1, &fl->fl_fasync);
> 	lock_flocks();
> 
> and say, hey, we didn't introduce any new bug there.  But....
> 
> I don't know, maybe add a version of fasync_add_entry() that takes a
> preallocated fasync_struct??

Or just convert the lock to a sleeping mutex.  Now that we have adaptive
spinning the horrible behaviour that Willy saw years ago might not be
that bad any more.  That'll need some benchmarking, though.
