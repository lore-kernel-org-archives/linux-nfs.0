Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59079 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254Ab1FOPry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2011 11:47:54 -0400
Date: Wed, 15 Jun 2011 11:47:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/2] locks: introduce i_blockleases to close lease races
Message-ID: <20110615154751.GA5467@fieldses.org>
References: <20110610000944.GC22215@fieldses.org>
 <20110610001011.GD22215@fieldses.org>
 <1307737440.3281.5.camel@localhost.localdomain>
 <20110610213446.GC27837@fieldses.org>
 <20110612040826.GD9246@fieldses.org>
 <1307905804.3564.28.camel@localhost.localdomain>
 <20110612191220.GK12149@fieldses.org>
 <1307912073.3564.80.camel@localhost.localdomain>
 <20110613121939.GL12149@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110613121939.GL12149@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 13, 2011 at 08:19:39AM -0400, J. Bruce Fields wrote:
> On Sun, Jun 12, 2011 at 04:54:33PM -0400, Mimi Zohar wrote:
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

The locking code is under a global spinlock--instead of an atomic inc
and dec of inode->i_blockleases we'd be doing a pair of lock/unlocks of
file_lock_lock.

We could probably fix that: off the top of my head the only reason I see
for a global lock is the stupid deadlock-detection code.  Which is only
needed for posix locks (and I'm not at all convinced it's needed even
there).

With that fixed, it would be a choice between an i_lock-protected
list_add/list_del vs. an atomic inc/dec of a new inode field.

--b.
