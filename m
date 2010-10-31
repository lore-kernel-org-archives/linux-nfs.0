Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50997 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab0JaCHM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 22:07:12 -0400
Date: Sat, 30 Oct 2010 22:07:08 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101031020707.GB29702@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101030212500.GE480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Oct 30, 2010 at 05:25:00PM -0400, J. Bruce Fields wrote:
> We still need to do this part.  I just did the minimum required to fix
> the problem--I figure splitting out a separate ->delete_lease method
> (which I agree would be cleaner) could wait till the next merge window.

I'd say please do it now.  The pre-allocated file_lock changes make
the semantics inside ->setlease really nasty right now.  I think it's a
dumb idea to leave it that way even for a single merge window.

