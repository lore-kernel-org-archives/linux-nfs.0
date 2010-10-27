Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52581 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab0J0Ijc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 04:39:32 -0400
Date: Wed, 27 Oct 2010 04:39:24 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027083924.GA28129@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101026214441.GC1842@fieldses.org>
 <20101026221156.GD1842@fieldses.org>
 <201010270921.37032.arnd@arndb.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201010270921.37032.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> If you don't hold lock_flocks throughout fcntl_setlease, the flp variable
> points to a flock that may get modified by another thread and you call
> time_out_leases() without holding lock_flocks, which it requires.
> 
> The two alternatives I can see are to either use GFP_ATOMIC or to
> take the lock inside of generic_setlease and drop it outside.
> Neither of the two sounds particularly appealing.


Do locks_alloc_lock and initialization of the heap struct file_lock
in the caller.  This also avoids an entirely useless copy of the
lock structure.  free the passed in structure if we are modifying
an existing lock structure.

