Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53288 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757174Ab2EILOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 07:14:33 -0400
Date: Wed, 9 May 2012 07:14:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dave Chinner <david@fromorbit.com>
Cc: David Howells <dhowells@redhat.com>, adilger@dilger.ca, smfrench@gmail.com,
        ben@decadent.org.uk, Trond.Myklebust@netapp.com, roland@hack.frob.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Message-ID: <20120509111420.GA23636@fieldses.org>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
 <16281.1336508382@redhat.com>
 <20120509002420.GL5091@dastard>
 <20120509010941.GC20160@fieldses.org>
 <20120509042532.GO5091@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120509042532.GO5091@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 09, 2012 at 02:25:32PM +1000, Dave Chinner wrote:
> On Tue, May 08, 2012 at 09:09:41PM -0400, J. Bruce Fields wrote:
> > On Wed, May 09, 2012 at 10:24:20AM +1000, Dave Chinner wrote:
> > > On Tue, May 08, 2012 at 09:19:42PM +0100, David Howells wrote:
> > > > 
> > > > Should I split the file-specific info and the fs-specific info and make the
> > > > second optional?  What I'm thinking of is something like this:
> > > > 
> > > > Have a file information structure:
> > > > 
> > > > struct statx {
> > > > 	/* 0x00 */
> > > > 	uint32_t	st_mask;	/* What results were written */
> > > > 	uint32_t	st_information;	/* Information about the file */
> > > > 	uint16_t	st_mode;	/* File mode */
> > > > 	uint16_t	__spare0[3];
> > > > 	/* 0x10 */
> > > > 	uint32_t	st_uid;		/* User ID of owner */
> > > > 	uint32_t	st_gid;		/* Group ID of owner */
> > > > 	uint32_t	st_nlink;	/* Number of hard links */
> > > > 	uint32_t	st_blksize;	/* Optimal size for filesystem I/O */
> > > > 	/* 0x20 */
> > > > 	struct statx_dev st_rdev;	/* Device ID of special file */
> > > > 	struct statx_dev st_dev;	/* ID of device containing file */
> > > > 	/* 0x30 */
> > > > 	int32_t		st_atime_ns;	/* Last access time (ns part) */
> > > > 	int32_t		st_btime_ns;	/* File creation time (ns part) */
> > > > 	int32_t		st_ctime_ns;	/* Last attribute change time (ns part) */
> > > > 	int32_t		st_mtime_ns;	/* Last data modification time (ns part) */
> > > > 	/* 0x40 */
> > > > 	int64_t		st_atime;	/* Last access time */
> > > > 	int64_t		st_btime;	/* File creation time */
> > > > 	int64_t		st_ctime;	/* Last attribute change time */
> > > > 	int64_t		st_mtime;	/* Last data modification time */
> > > > 	/* 0x60 */
> > > > 	uint64_t	st_ino;		/* Inode number */
> > > > 	uint64_t	st_size;	/* File size */
> > > > 	uint64_t	st_blocks;	/* Number of 512-byte blocks allocated */
> > > > 	uint64_t	st_gen;		/* Inode generation number */
> > > 
> > > I don't think we want to expose the inode generation numbers. It is
> > > trivial to construct NFS file handles (usually just fsid, inode
> > > number and generation) with that information and hence bypass
> > > security checks to access files.
> > 
> > I'm not convinced there's much value in trying to keep filehandles
> > secret.
> 
> Sure, but I can't really see any good reason to expose filesystem
> internal implementation details like this - a generation number is
> usually used to differentiate between inode life cycles which
> userspace has no concept of and is different for every filesystem,
> so it's behaviour and values are not going to be consistent across
> filesystems.

That's OK.  The only requirement would be that the (inode number, inode
generation) pair be different for different inodes on the same
filesystem.

> Some filesystems might not even have a generation
> number they can export, and that makes me wonder if there is any
> good reason for exposing it at all.

That's true of a number of these new attributes.

> If you need to discriminate between versions of files with the same
> name, then use name_to_handle_at() and compare filehandles....

Sure.

Since the only use case given for this has been constructing
filehandles, and since we already have an interface for that, I don't
feel particularly strongly about this.

--b.
