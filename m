Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:47594 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab1FMUhf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 16:37:35 -0400
Subject: Re: [PATCH 1/2] locks: introduce i_blockleases to close lease races
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Eric Paris <eparis@redhat.com>
In-Reply-To: <20110613121939.GL12149@fieldses.org>
References: <20110610000944.GC22215@fieldses.org>
	 <20110610001011.GD22215@fieldses.org>
	 <1307737440.3281.5.camel@localhost.localdomain>
	 <20110610213446.GC27837@fieldses.org> <20110612040826.GD9246@fieldses.org>
	 <1307905804.3564.28.camel@localhost.localdomain>
	 <20110612191220.GK12149@fieldses.org>
	 <1307912073.3564.80.camel@localhost.localdomain>
	 <20110613121939.GL12149@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 13 Jun 2011 16:37:03 -0400
Message-ID: <1307997423.13410.63.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-06-13 at 08:19 -0400, J. Bruce Fields wrote:
> On Sun, Jun 12, 2011 at 04:54:33PM -0400, Mimi Zohar wrote:
> > On Sun, 2011-06-12 at 15:12 -0400, J. Bruce Fields wrote: 
> > > On Sun, Jun 12, 2011 at 03:10:04PM -0400, Mimi Zohar wrote:
> > > > On Sun, 2011-06-12 at 00:08 -0400, J. Bruce Fields wrote:
> > > > > On Fri, Jun 10, 2011 at 05:34:46PM -0400, J. Bruce Fields wrote:
> > > > > > On Fri, Jun 10, 2011 at 04:24:00PM -0400, Mimi Zohar wrote:
> > > > > > > On Thu, 2011-06-09 at 20:10 -0400, J. Bruce Fields wrote:
> > > > > > > > From: J. Bruce Fields <bfields@redhat.com>
> > > > > > > > 
> > > > > > > > Since break_lease is called before i_writecount is incremented, there's
> > > > > > > > a window between the two where a setlease call would have no way to know
> > > > > > > > that an open is about to happen.
> > > > > > > 
> > > > > > > So unless the break_lease() call is moved from may_open() to after 
> > > > > > > nameidata_to_filp(), I don't see any other options.
> > > > > > 
> > > > > > Actually, offhand I can't see why that wouldn't be OK.
> > > > > > 
> > > > > > Though I think we still end up needing something like i_blockleases to
> > > > > > handle unlink, link, rename, chown, and chmod.
> > > > > 
> > > > > Well, I guess there's a bizarre alternative that wouldn't require a new
> > > > > inode field:
> > > > 
> > > > In lieu of adding a new inode field, another possible option, a bit
> > > > kludgy, would be extending i_flock with an additional fl_flag
> > > > FL_BLOCKLEASE.
> > > > 
> > > > #define IS_BLOCKLEASE(fl)    (fl->fl_flags & FL_BLOCKLEASE)
> > > 
> > > Alas, that would mean adding and removing one of these file locks around
> > > every single link, unlink, rename,....
> > > 
> > > --b.
> > 
> > You're adding a call to break_lease() for each of them.  Currently
> > __break_lease() is only called if a lease exists. Assuming there aren't
> > any existing leases, couldn't break_lease() call something like
> > block_lease()?  The free would be after the link, unlink, ...,
> > completed/failed.
> > 
> > (You wouldn't actually need to alloc/free the 'struct file_lock' each
> > time, just set the pointer and reset to NULL.)
> 
> Well, the pointer has to be set to something.  I suppose we could put a
> struct file_lock on the stack.
> 
> --b.

Instead of putting the struct file_lock on the stack, how about creating
a dummy list containing a single element with FL_BLOCKLEASE set?

Mimi

