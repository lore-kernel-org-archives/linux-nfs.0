Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60177 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab0J0PbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 11:31:18 -0400
Date: Wed, 27 Oct 2010 11:31:14 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027153114.GA23126@infradead.org>
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
> It comes back to the original problem with Bruce's patch though:
> fcntl_setlease wants to atomically add a lease or fail. If
> fasync_helper fails, we want to remove the lease that was
> just added before anyone can see it. At the very least we need
> to keep the flock from getting freed in another thread while
> we call fasync_helper without the lock.

a variant of fasync_add_entry that takes a preallocated
fasync_struct would indeed take care of that.

> locks_delete_lock is also called with lock_flocks held and calls
> fasync_helper...

but with on = 0, which calls into fasync_remove_entry, which doesn't
sleep.

