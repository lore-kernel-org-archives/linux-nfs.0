Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40707 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755897Ab0J0Nje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Oct 2010 09:39:34 -0400
Date: Wed, 27 Oct 2010 09:39:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027133924.GB6328@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101026214441.GC1842@fieldses.org>
 <20101026221156.GD1842@fieldses.org>
 <201010270921.37032.arnd@arndb.de>
 <20101027083924.GA28129@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101027083924.GA28129@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Arnd Bergmann wrote:
> > If you don't hold lock_flocks throughout fcntl_setlease, the flp variable
> > points to a flock that may get modified by another thread and you call
> > time_out_leases() without holding lock_flocks, which it requires.

Whoops, thanks for catching that.

On Wed, Oct 27, 2010 at 04:39:24AM -0400, Christoph Hellwig wrote:
> Do locks_alloc_lock and initialization of the heap struct file_lock
> in the caller.  This also avoids an entirely useless copy of the
> lock structure.  free the passed in structure if we are modifying
> an existing lock structure.

That sounds good; I'll give it a try.

--b.
