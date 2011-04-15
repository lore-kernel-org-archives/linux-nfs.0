Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50995 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab1DORdU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 13:33:20 -0400
Date: Fri, 15 Apr 2011 13:33:17 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Message-ID: <20110415173317.GA21468@infradead.org>
References: <1302622335.3877.62.camel@badari-desktop>
 <1302623369.4801.28.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1302623369.4801.28.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 12, 2011 at 11:49:29AM -0400, Trond Myklebust wrote:
> Your approach goes in the direction of further special-casing O_DIRECT
> in the NFS client. I'd like to move away from that and towards
> integration with the ordinary read/write codepaths so that aside from
> adding request coalescing, we can also enable pNFS support.

What is the exact plan?  Split the direct I/O into two passes, one
to lock down the user pages and then a second one to send the pages
over the wire, which is shared with the writeback code?  If that's
the case it should naturally allow plugging in a scheme like Badari
to send pages from different iovecs in a single on the wire request -
after all page cache pages are non-continuous in virtual and physical
memory, too.

When do you plan to release your read/write code re-write?  If it's
not anytime soon how is applying Badari's patch going to hurt?  Most
of it probably will get reverted with a complete rewrite, but at least
the logic to check which direct I/O iovecs can coalesced would stay
in the new world order.

