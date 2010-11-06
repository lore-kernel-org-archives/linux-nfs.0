Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60091 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab0KFTDl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Nov 2010 15:03:41 -0400
Date: Sat, 6 Nov 2010 15:03:32 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, willy@debian.org, sfr@canb.auug.org.au
Subject: Re: [PATCH 1/2] locks: let the caller free file_lock on ->setlease
 failure
Message-ID: <20101106190332.GA15850@infradead.org>
References: <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
 <20101031123510.GA4520@infradead.org>
 <20101103204147.GA6777@fieldses.org>
 <20101104014024.GA22498@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101104014024.GA22498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Nov 03, 2010 at 09:40:24PM -0400, J. Bruce Fields wrote:
> The irritating thing is that the only lease user I understand is the
> nfsd code, and it doesn't want this lease-merging behavior; the only
> reason that fl_change is there is so it can just turn this case into an
> error every time.

Yes.

> And I have no idea what the requirements are of any other users: do
> leases behave like this on purpose, or was it just an arbitrary choice,
> and does anyone depend on it now?

Adding Willy and Stephen to the Cc list as they wrote the code.

> In the end maybe it would be better just to leave leases as they are and
> define a new lock type for nfsd.
>
> We'd probably have to do that eventually anyway, and it'd save me trying
> to guess what the lease semantics are supposed to be....

I'd rather see both leases and the nfs4 delegations detangled from the
locks.c code.  It's far too much of a mess already anyway.

> Subject: [PATCH 1/2] locks: fix leak on merging leases
> 
> We must also free the passed-in lease in the case it wasn't used because
> an existing lease was upgrade/downgraded or already existed.
> 
> Note the nfsd caller doesn't care because it's fl_change callback
> returns an error in those cases.

The patch looks good to me.  Care to feed it to Linus?

