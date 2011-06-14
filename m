Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755528Ab1FNAfz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 20:35:55 -0400
Date: Mon, 13 Jun 2011 20:35:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/2] locks: introduce i_blockleases to close lease races
Message-ID: <20110614003553.GA24557@fieldses.org>
References: <20110610000944.GC22215@fieldses.org>
 <20110610001011.GD22215@fieldses.org>
 <1307737440.3281.5.camel@localhost.localdomain>
 <20110610213446.GC27837@fieldses.org>
 <20110612040826.GD9246@fieldses.org>
 <1307905804.3564.28.camel@localhost.localdomain>
 <20110612191220.GK12149@fieldses.org>
 <1307912073.3564.80.camel@localhost.localdomain>
 <20110613121939.GL12149@fieldses.org>
 <1307997423.13410.63.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1307997423.13410.63.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 13, 2011 at 04:37:03PM -0400, Mimi Zohar wrote:
> On Mon, 2011-06-13 at 08:19 -0400, J. Bruce Fields wrote:
> > On Sun, Jun 12, 2011 at 04:54:33PM -0400, Mimi Zohar wrote:
> > > On Sun, 2011-06-12 at 15:12 -0400, J. Bruce Fields wrote: 
> > > > On Sun, Jun 12, 2011 at 03:10:04PM -0400, Mimi Zohar wrote:
> > > > > In lieu of adding a new inode field, another possible option, a bit
> > > > > kludgy, would be extending i_flock with an additional fl_flag
> > > > > FL_BLOCKLEASE.
> > > > > 
> > > > > #define IS_BLOCKLEASE(fl)    (fl->fl_flags & FL_BLOCKLEASE)
> > > > 
> > > > Alas, that would mean adding and removing one of these file locks around
> > > > every single link, unlink, rename,....
> > > > 
> > > > --b.
> > > 
> > > You're adding a call to break_lease() for each of them.  Currently
> > > __break_lease() is only called if a lease exists. Assuming there aren't
> > > any existing leases, couldn't break_lease() call something like
> > > block_lease()?  The free would be after the link, unlink, ...,
> > > completed/failed.
> > > 
> > > (You wouldn't actually need to alloc/free the 'struct file_lock' each
> > > time, just set the pointer and reset to NULL.)
> > 
> > Well, the pointer has to be set to something.  I suppose we could put a
> > struct file_lock on the stack.
> > 
> > --b.
> 
> Instead of putting the struct file_lock on the stack, how about creating
> a dummy list containing a single element with FL_BLOCKLEASE set?

I'm afraid I don't understand what you're proposing.  Could you explain
in more detail?

--b.
