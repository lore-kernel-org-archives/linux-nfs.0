Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39232 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712Ab1FLEIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Jun 2011 00:08:30 -0400
Date: Sun, 12 Jun 2011 00:08:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/2] locks: introduce i_blockleases to close lease races
Message-ID: <20110612040826.GD9246@fieldses.org>
References: <20110610000944.GC22215@fieldses.org>
 <20110610001011.GD22215@fieldses.org>
 <1307737440.3281.5.camel@localhost.localdomain>
 <20110610213446.GC27837@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110610213446.GC27837@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 10, 2011 at 05:34:46PM -0400, J. Bruce Fields wrote:
> On Fri, Jun 10, 2011 at 04:24:00PM -0400, Mimi Zohar wrote:
> > On Thu, 2011-06-09 at 20:10 -0400, J. Bruce Fields wrote:
> > > From: J. Bruce Fields <bfields@redhat.com>
> > > 
> > > Since break_lease is called before i_writecount is incremented, there's
> > > a window between the two where a setlease call would have no way to know
> > > that an open is about to happen.
> > 
> > So unless the break_lease() call is moved from may_open() to after 
> > nameidata_to_filp(), I don't see any other options.
> 
> Actually, offhand I can't see why that wouldn't be OK.
> 
> Though I think we still end up needing something like i_blockleases to
> handle unlink, link, rename, chown, and chmod.

Well, I guess there's a bizarre alternative that wouldn't require a new
inode field:

What we care about is conflicts between read leases and operations that
modify the metadata of the inode or the set of names pointing to it.

As far as I can tell those operations all take the i_mutex either on the
inode itself or on the parents of one of its aliases.

So, you could prevent break_lease/setlease races by calling setlease
under *all* of those i_mutexes:

	- take i_mutex on the inode
	- take i_lock to prevent the set of aliases from changing
	- take i_mutex for parent of each alias
	- set the lease
	- drop the parent i_mutexes, etc.

where the i_mutexes would all be taken with mutex_trylock, and we'd just
fail the whole setlease if any of them failed.

???

--b.
