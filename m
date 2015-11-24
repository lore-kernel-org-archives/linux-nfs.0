Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:49371 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbbKXTxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 14:53:08 -0500
Date: Tue, 24 Nov 2015 14:52:56 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/12] statx: Provide IOC flags for Windows fs attributes
Message-ID: <20151124195256.GB3482@thunk.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <20151120145447.18930.5308.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151120145447.18930.5308.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2015 at 02:54:47PM +0000, David Howells wrote:
> Provide IOC flags for Windows fs attributes so that they can be retrieved (or
> even altered) using the FS_IOC_[GS]ETFLAGS ioctl and read using statx().

We have a real problem with numberspace used by FS_IOC_[GS]ETFLAGS.
This ioctl was originally defined for use with ext2, but then later on
other file systems decided they wanted to use the same ioctl for their
file system, and so now we have the situation where some of the bits
are used in a way where they are intended to be file system
independent, and some are file system specific.  And ext[234] use
these bits as its on-disk encoding --- which given that
FS_IOC[GS]ETFLAGS was originally ext[234] specific, is understandable,
but it makes things really messy at this point.

So for example, the bits you have chosen are in conflict with ext4's use:

#define EXT4_INLINE_DATA_FL		0x10000000 /* Inode has inline data. */
#define EXT4_PROJINHERIT_FL		0x20000000 /* Create with parents projid */

> +#define FS_HIDDEN_FL			0x10000000 /* Windows hidden file attribute */
> +#define FS_SYSTEM_FL			0x20000000 /* Windows system file attribute */
> +#define FS_ARCHIVE_FL			0x40000000 /* Windows archive file attribute */


As a result, I would suggest that we not try to use the
FS_IOC_[GS]ETFLAGS number scheme for any new interface, so we're at
least not making a bad situation worse.

The only reason why some other file systems have chosen to use
FS_IOC_[GS]ETFLAGS, instead of defining their own ioctl, is so they
can use lsattr/chattr from e2fsprogs instead of creating their own
utility.  But for statx, there isn't a good reason use the same flags
number space.  At the very least, can we use a new flags field for the
Windows file attributes?  It's not like lsattr/chattr has the ability
to set those flags today anyway.  So we might as well use a new flags
field and a new flags numberspace for them.

						- Ted
