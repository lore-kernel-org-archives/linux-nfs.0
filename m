Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52449 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755607Ab1DOSAn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 14:00:43 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20110415173317.GA21468@infradead.org>
References: <1302622335.3877.62.camel@badari-desktop>
	 <1302623369.4801.28.camel@lade.trondhjem.org>
	 <20110415173317.GA21468@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 15 Apr 2011 14:00:39 -0400
Message-ID: <1302890439.7454.24.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-04-15 at 13:33 -0400, Christoph Hellwig wrote:
> On Tue, Apr 12, 2011 at 11:49:29AM -0400, Trond Myklebust wrote:
> > Your approach goes in the direction of further special-casing O_DIRECT
> > in the NFS client. I'd like to move away from that and towards
> > integration with the ordinary read/write codepaths so that aside from
> > adding request coalescing, we can also enable pNFS support.
> 
> What is the exact plan?  Split the direct I/O into two passes, one
> to lock down the user pages and then a second one to send the pages
> over the wire, which is shared with the writeback code?  If that's
> the case it should naturally allow plugging in a scheme like Badari
> to send pages from different iovecs in a single on the wire request -
> after all page cache pages are non-continuous in virtual and physical
> memory, too.

You can't lock the user pages unfortunately: they may need to be faulted
in.

What I was thinking of doing is splitting out the code in the RPC
callbacks that plays around with page flags and puts the pages on the
inode's dirty list so that they don't get called in the case of
O_DIRECT.
I then want to attach the O_DIRECT pages to the nfsi->nfs_page_tree
radix tree so that they can be tracked by the NFS layer. I'm assuming
that nobody is going to be silly enough to require simultaneous writes
via O_DIRECT to the same locations.
Then we can feed the O_DIRECT pages into nfs_page_async_flush() so that
they share the existing page cache write coalescing and pnfs code.

The commit code will be easy to reuse too, since the requests are listed
in the radix tree and so nfs_scan_list() can find and process them in
the usual fashion.

The main problem that I have yet to figure out is what to do if the
server flags a reboot and the requests need to be resent. One option I'm
looking into is using the aio 'kick handler' to resubmit the writes.
Another may be to just resend directly from the nfsiod work queue.

> When do you plan to release your read/write code re-write?  If it's
> not anytime soon how is applying Badari's patch going to hurt?  Most
> of it probably will get reverted with a complete rewrite, but at least
> the logic to check which direct I/O iovecs can coalesced would stay
> in the new world order.

I'm hoping that I can do the rewrite fairly quickly once the resend
problem is solved. It shouldn't be more than a couple of weeks of
coding.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

