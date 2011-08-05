Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733Ab1HETQR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Aug 2011 15:16:17 -0400
Date: Fri, 5 Aug 2011 15:16:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110805191610.GA16880@fieldses.org>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
 <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com>
 <4E3A8225.1020309@linux.vnet.ibm.com>
 <20110804160344.GC12445@fieldses.org>
 <20110805133833.GA2282@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110805133833.GA2282@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 05, 2011 at 09:38:33AM -0400, Christoph Hellwig wrote:
> On Thu, Aug 04, 2011 at 12:03:44PM -0400, J. Bruce Fields wrote:
> > The client has no way of knowing that an export is read only.  (Or that
> > the server guarantees the safety of looking up names again in the more
> > general cases Neil describes.)  Unless we decide that a server is making
> > an implicit guarantee of that just by exposing volatile filehandles at
> > all.  Doesn't sound like the existing spec really says that, though.
> > 
> > If an examination of existing implementations and/or some sort of new
> > spec language could reassure us that servers will only ever expose
> > volatile filehandles when it's safe to do so, then maybe it would make
> > sense for the client to implement volatile filehandle recovery?
> > 
> > But if there's a chance of "unsafe" servers out there, then it would
> > seem like a trap for the unwary user....
> > 
> > Your rootfs's probably aren't terribly large--could you copy around
> > compressed block-level images instead of doing rsync?
> 
> Another scheme is to disconnect the file handles from the inode number.
> I implemented this a couple years ago for a customer.  Basically add
> an extended attribute into each inode that contains the nfs file handle,
> and that handle stays the same independent of the inode number.  The
> added complexity is that you need a new lookup data structure mapping

And that data structure should be persistent--how were you storing it?

> from your nfs handle to something that can be used to find the inode
> (inode number typically).

Interesting, I've wondered before how well that would work.  Any lessons
learned?

--b.
