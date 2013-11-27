Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43847 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab3K0Lsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 06:48:39 -0500
Date: Wed, 27 Nov 2013 03:48:38 -0800
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, libc-alpha@sourceware.org,
        linux-api@vger.kernel.org, andreas.gruenbacher@gmail.com,
        samba-technical@lists.samba.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] statxat: Add a system call to make extended file
 stats available
Message-ID: <20131127114838.GB13491@infradead.org>
References: <20131112173518.25813.67568.stgit@warthog.procyon.org.uk>
 <20131112173534.25813.70732.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131112173534.25813.70732.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 12, 2013 at 05:35:34PM +0000, David Howells wrote:
> Add a system call to make extended file stats available, including file
> creation time, inode version and data version where available through the
> underlying filesystem.

Adding the glibc list as a new stat version that can't be nicely
exposed to user program is rather pointless, and as it tends to have
a higher concentration of people involved in the standards processes,
which would be useful input here.

> 
>  (1) Creation time: The SMB protocol carries the creation time, which could be
>      exported by Samba, which will in turn help CIFS make use of FS-Cache as
>      that can be used for coherency data.

We'll want this in the next stat version for sure.

>  (2) Lightweight stat: Ask for just those details of interest, and allow a
>      netfs (such as NFS) to approximate anything not of interest, possibly
>      without going to the server [Trond Myklebust, Ulrich Drepper, Andreas
>      Dilger].

Seems useful, too.

>  (3) Heavyweight stat: Force a netfs to go to the server, even if it thinks its
>      cached attributes are up to date [Trond Myklebust].

Needs a much better rational an explanation.  Unless I get that I'm
very much tempted to say no here.

>  (4) Data version number: Could be used by userspace NFS servers [Aneesh Kumar].
> 
>      Can also be used to modify fill_post_wcc() in NFSD which retrieves
>      i_version directly, but has just called vfs_getattr().  It could get it
>      from the kstat struct if it used vfs_xgetattr() instead.

Way to NFS specific to export it I think.

>  (5) BSD stat compatibility: Including more fields from the BSD stat such as
>      creation time (st_btime) and inode generation number (st_gen) [Jeremy
>      Allison, Bernd Schubert].

We already mentioned the creation time earlier.  The inode generation is
an implementation detail and should not be exported.

>  (6) Inode generation number: Useful for FUSE and userspace NFS servers [Bernd
>      Schubert].  This was asked for but later deemed unnecessary with the
>      open-by-handle capability available

Your lists seem to have some duplication, don't they?

>  (8) Allow the filesystem to indicate what it can/cannot provide: A filesystem
>      can now say it doesn't support a standard stat feature if that isn't
>      available, so if, for instance, inode numbers or UIDs don't exist or are
>      fabricated locally...

What should a usr do about that?

> 	int ret = statxat(int dfd,
> 			  const char *filename,
> 			  unsigned int flags,
> 			  unsigned int mask,
> 			  struct statx *buffer,
> 			  struct statx_auxinfo *auxinfo_buffer);

Please make the whole AUX thing a separate system call.

> 
> The dfd, filename and flags parameters indicate the file to query.  There is no
> equivalent of lstat() as that can be emulated with statxat() by passing
> AT_SYMLINK_NOFOLLOW in flags.  There is also no equivalent of fstat() as that
> can be emulated by passing a NULL filename to statxat() with the fd of interest
> in dfd.
> 
> AT_FORCE_ATTR_SYNC can also be set in flags.  This will require a network
> filesystem to synchronise its attributes with the server.
> 
> mask is a bitmask indicating the fields in struct statx that are of interest to
> the caller.  The user should set this to STATX_BASIC_STATS to get the basic set
> returned by stat().
> 
> buffer points to the destination for the main data and auxinfo_buffer points to
> the destination for the optional auxiliary data.  auxinfo_buffer can be NULL if
> the auxiliary data is not required.
> 
> At the moment, this will only work on x86_64 and i386 as it requires the system
> call to be wired up.
> 
> 
> ======================
> MAIN ATTRIBUTES RECORD
> ======================
> 
> The following structures are defined in which to return the main attribute set:
> 
> 	struct statx_dev {
> 		uint32_t		major, minor;
> 	};

Having a special, oddly named dev_t that isn't compatible to any other
of the userspace APIs doesn't make sense. 

> 
> 	struct statx {
> 		uint32_t		st_mask;
> 		uint32_t		st_information;

Pleae provide a detailed specification of the semantics for each
field.

> 		uint16_t		st_mode;
> 		uint16_t		__spare0[1];
> 		uint32_t		st_nlink;
> 		uint32_t		st_uid;
> 		uint32_t		st_gid;
> 		uint32_t		st_alloc_blksize;
> 		uint32_t		st_blksize;
> 		uint32_t		st_small_io_size;
> 		uint32_t		st_large_io_size;

Exporting a per-file I/O toplogy makes sense similar to how we do
this for block devices.  Forcing this into every stat call make
less sense.  Also pleae provide the dio alignment information in
an I/O topology call.

> 		struct statx_dev	st_rdev;
> 		struct statx_dev	st_dev;
> 		int32_t			st_atime_ns;
> 		int32_t			st_btime_ns;
> 		int32_t			st_ctime_ns;
> 		int32_t			st_mtime_ns;
> 		int64_t			st_atime;
> 		int64_t			st_btime;
> 		int64_t			st_ctime;
> 		int64_t			st_mtime;

Same argument as above, don't introduce incompatible time formats that
nothing else in the syscall layer can deal with.

