Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:57270
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751722Ab1HJKYq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 06:24:46 -0400
Date: Wed, 10 Aug 2011 06:24:36 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110810102436.GA6117@infradead.org>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
 <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com>
 <4E3A8225.1020309@linux.vnet.ibm.com>
 <20110804160344.GC12445@fieldses.org>
 <20110805133833.GA2282@infradead.org>
 <20110805191610.GA16880@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110805191610.GA16880@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 05, 2011 at 03:16:10PM -0400, J. Bruce Fields wrote:
> > Another scheme is to disconnect the file handles from the inode number.
> > I implemented this a couple years ago for a customer.  Basically add
> > an extended attribute into each inode that contains the nfs file handle,
> > and that handle stays the same independent of the inode number.  The
> > added complexity is that you need a new lookup data structure mapping
> 
> And that data structure should be persistent--how were you storing it?

In this case it was in a clustered database in userspace, which I didn't
really touch directly.  If doing outside of such an appliance I would
add a btree to XFS to do the mapping. 

> > from your nfs handle to something that can be used to find the inode
> > (inode number typically).
> 
> Interesting, I've wondered before how well that would work.  Any lessons
> learned?

Don't store the data in userspace, it just makes life hard :)  The
basic idea actually was pretty straight forward, and if doing it using
the xfs btree I mentioned above fairly easy.  Other filesystems might or
might not heave similar easily reusable persistant lookup data structures.
