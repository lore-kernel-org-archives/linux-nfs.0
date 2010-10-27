Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41280 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760949Ab0J0PAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 11:00:03 -0400
Date: Wed, 27 Oct 2010 10:59:29 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101027145929.GA5788@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101027145538.GC6328@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 10:55:39AM -0400, J. Bruce Fields wrote:
> Hm, two problems:
> 	- We introduce the possibility of fcntl(fd, F_SETLEASE, F_UNLCK)
> 	  failing with ENOMEM.

splitt ->setlease into ->add_least and ->delete_lease.  No need to pass
in a structure for the later.  No need to return one either.

> 	- fasync_helper(.,.,1,.) sleeps.  Argh.

That's not new..

