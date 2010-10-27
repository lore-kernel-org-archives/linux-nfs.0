Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50118 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549Ab0J0UYr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Oct 2010 16:24:47 -0400
Date: Wed, 27 Oct 2010 16:24:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027202442.GF18974@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <201010272148.47376.arnd@arndb.de>
 <20101027200145.GE18974@fieldses.org>
 <201010272220.20567.arnd@arndb.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201010272220.20567.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 10:20:20PM +0200, Arnd Bergmann wrote:
> On Wednesday 27 October 2010 22:01:45 J. Bruce Fields wrote:
> > (You're missing Linus's comment fix, though, unless I'm confused.)
> 
> Right, I didn't look into the attachment, so I hadn't noticed
> the new changelog. I've updated the changelog to Linus' version,
> as it's more verbose than mine.

He fixed a code comment too, though.  No big deal.

> I also checked that the version in your tree is actually the
> right one, so I left the code untouched.

Yup, looks good.

--b.
