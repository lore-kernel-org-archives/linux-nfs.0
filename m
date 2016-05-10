Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54837 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbcEJHIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 May 2016 03:08:04 -0400
Date: Tue, 10 May 2016 00:08:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160510070803.GC30896@infradead.org>
References: <20160508083543.GA14316@infradead.org>
 <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <1734.1462801101@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1734.1462801101@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 09, 2016 at 02:38:21PM +0100, David Howells wrote:
> Let's look at the list, and please bear in mind I'm trying to make it so that
> you can emulate stat() through this interface.  If you want to waive that
> requirement - or push the emulation out to userspace - then I can forego
> providing unsupported data from the basic stat set.

why would you want to emulate stat?

> | (0) st_information, st_dev_*, st_blksize.
> 
> st_dev_* and st_blksize must always be available from whatever we stat.
> Because this is the case, there's no point providing mask bits for them.
> 
> My implementation defines st_information to be in this class, but it doesn't
> have to be.  Note that st_information really needs a way to ask the filesystem
> what flags it actually supports so that you can distinguish being 0 -> not set
> from 0 -> not supported, hence the fsinfo() interface that I've dropped for
> now.

All of these are easily available.  But why special case them so that
userspace must not ask for them?  This makes an otherwise totally
regular interface special now.  Note that filesystems could always fill
it out anyway and set it in the return mask.

> | (1) st_nlinks, st_uid, st_gid, st_[amc]time*, st_ino, st_size, st_blocks.
> 
> These data are all in the bog standard struct stat.  As it is, they must all
> be given values as for stat().  However, mask bits are provided to indicate
> when the value presented here is actually fabricated so that the user can
> decide not to use them.

Next special case..

> | (2) st_mode.
> 
> This is actually in two parts.  There's the file type (which must always be
> set correctly) and the mode bits (which may be fabricated).  STATX_MODE covers
> the mode bits only.

Next special case.

> 
> | (3) st_rdev_*.
> 
> This datum is part of the bog standard struct stat, and as such must be set to
> something.  However, the value is only relevant in the case that the mode
> indicates a blockdev or chardev.  STATX_RDEV can be considered redundant in
> such a case.
> 
> | (4) File creation time (st_btime*), data version (st_version), inode
> |     generation number (st_gen).
> 
> These are all new data and have no counterpart in the Linux struct stat.
> However, they do in the struct stat on other Unix variants (st_birthtime and
> st_gen, for example, exist on BSD).  Not all filesystems provide them so if
> they are requested but are not actually supported by a filesystem, the bit in
> the mask is cleared upon returning.
> 
> However, even if you didn't ask for a datum, it may still be available - and I
> am permitting a filesystem to give you the datum and mark the mask to indicate
> the value's availability, even if you didn't ask for it.  You are free to
> ignore it.

I think the fs may return it anyway case is fine, but let's make that
a 100% generic thing and not special case fields.

> At this time, I think it likely that all new attributes would be in this
> class.  One could argue that something like st_win_attrs (in patch 5) could be
> in class 0 if added immediately, but anything added later *must* have a mask
> bit to indicate its presence.
> 
> 
> So, barring st_information, classes (0) - (3) are all current stat stuff.
> That is how they work *now*.  All I'm doing is defining which data have mask
> bits, and under what conditions the mask bit might not be set.

Who cares about stat?  You are adding a new system call and are not
bound by what certain versions of stat did at specific points in time.
