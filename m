Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933627Ab0GSOF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 10:05:27 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100718084824.GA27794@infradead.org>
References: <20100718084824.GA27794@infradead.org> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        drepper@redhat.com, torvalds@linux-foundation.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Mon, 19 Jul 2010 15:05:08 +0100
Message-ID: <8363.1279548308@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Christoph Hellwig <hch@infradead.org> wrote:

> Adding Uli to the Cc list to make sure this system call is useful
> for glibc / can be exported by it.  Otherwise it's rather pointless
> to add it.
> 
> > (6) BSD stat compatibility: Including more fields from the BSD stat such
> >     as creation time (st_btime) and inode generation number (st_gen)
> >     [Jeremy Allison, Bernd Schubert]
> 
> How is this different from (1) and (4)?

A matter of intent, really, and who proposed it.

> > (7) Extra coherency data may be useful in making backups [Andreas Dilger].
> 
> What do you mean with that?

There are extra dates and version numbers potentially available.  This may be
useful in making backups.  Ask Andreas.

> > (8) Allow the filesystem to indicate what it can/cannot provide: A
> >     filesystem can now say it doesn't support a standard stat feature if
> >     that isn't available.
> 
> What for?

So that you can decide not to use it.  Some of our filesystems fabricate things
that they don't actually store.

> >  (9) Make the fields a consistent size on all arches, and make them large.
> 
> Why making them large for the sake of it?  We'll need massive changes
> all through libc and applications to ever make use of this.  So please
> coordinate the types used with Uli.

Otherwise we end up with #ifdefs and duplicated fields of different sizes
within stat structs, and fields of "long" types which vary in size, depending
on the environment.

I just want to make sure that:

       - st_ino is stored as 64-bit
       - st_size and st_blocks are stored 64-bit
       - st.{a,b,c,m}time.tv_sec are stored 64-bit

We could probably stand to make st_blksize 32-bit.  I'd quite like to leave
st_gen as 64-bits and I definitely want to leave st_data_version as 64-bits.

> > The following structures are defined for the use of these new system calls:
> > 
> > 	struct xstat_parameters {
> > 		unsigned long long	request_mask;
> > 	};
> 
> Just pass this as a single flag by value.  And just make it an unsigned
> long to make the calling convention a lot simpler.

Already done.

> > 	struct xstat_dev {
> > 		unsigned int		major, minor;
> > 	};
> > 
> > 	struct xstat_time {
> > 		unsigned long long	tv_sec, tv_nsec;
> > 	};
> 
> No point in adding special types here that aren't genericly useful.
> Also this is the first and only system call using split major/minor
> values for the dev_t.  All this just creates more churn than it helps.

I can perhaps agree on the device numbers, though some filesystems we have can
store numbers that can't be represented by dev_t.  I think, however, everything
we have can be handled by a 32:32 split.  The numbers could then be encoded as
desired in userspace.

The problem with using extant time structs is they use "long" or "unsigned
long".  And I specifically want to get away from that, since it might be
32-bits or it might be 64-bits.

> > 
> > 	struct xstat {
> > 		unsigned long long	st_result_mask;
> 
> Just st_mask?

Perhaps, but it contrasts nicely with request_mask, and makes it easier to
document.

> > 		unsigned long long	st_data_version;
> 
> st version?

Acceptable.

> > 		unsigned long long	st_inode_flags;
> 
> 
> 
> > The defined bits in request_mask and st_result_mask are:
> > 
> > 	XSTAT_REQUEST_MODE		Want/got st_mode
> > 	XSTAT_REQUEST_NLINK		Want/got st_nlink
> > 	XSTAT_REQUEST_UID		Want/got st_uid
> > 	XSTAT_REQUEST_GID		Want/got st_gid
> > 	XSTAT_REQUEST_RDEV		Want/got st_rdev
> > 	XSTAT_REQUEST_ATIME		Want/got st_atime
> > 	XSTAT_REQUEST_MTIME		Want/got st_mtime
> > 	XSTAT_REQUEST_CTIME		Want/got st_ctime
> > 	XSTAT_REQUEST_INO		Want/got st_ino
> > 	XSTAT_REQUEST_SIZE		Want/got st_size
> > 	XSTAT_REQUEST_BLOCKS		Want/got st_blocks
> > 	XSTAT_REQUEST__BASIC_STATS	The stuff in the normal stat struct
> > 	XSTAT_REQUEST_BTIME		Want/got st_btime
> > 	XSTAT_REQUEST_GEN		Want/got st_gen
> > 	XSTAT_REQUEST_DATA_VERSION	Want/got st_data_version
> > 	XSTAT_REQUEST_INODE_FLAGS	Want/got st_inode_flags
> > 	XSTAT_REQUEST__EXTENDED_STATS	The stuff in the xstat struct
> > 	XSTAT_REQUEST__ALL_STATS	The defined set of requestables
> 
> What's the point of the REQUEST in the name?

Well, they are.

> Also no double underscores inside the identifier.  Instead adding a _MASK
> postfix for masks would make it a lot more clear.

Perhaps.

> > The defined bits in st_inode_flags are the usual FS_xxx_FL flags in the
> > LSW, plus some extra flags in the MSW:
> > 
> > 	FS_SPECIAL_FL		Special kernel file, such as found in procfs
> > 	FS_AUTOMOUNT_FL		Specific automount point
> > 	FS_AUTOMOUNT_ANY_FL	Free-form automount directory
> > 	FS_REMOTE_FL		File is remote
> > 	FS_ENCRYPTED_FL		File is encrypted
> > 	FS_SYSTEM_FL		File is marked system (DOS/NTFS/CIFS)
> > 	FS_TEMPORARY_FL		File is temporary (NTFS/CIFS)
> > 	FS_OFFLINE_FL		File is offline (CIFS)
> 
> Please don't overload the FL_ namespace even more.  It's already a
> complete mess given that it overloads the extN on-disk namespace.
> You're much better off just adding a clean new namespace.

Yeah.  I've been thinking that's probably the better thing to do.

> > The system calls are:
> > 
> > 	ssize_t ret = xstat(int dfd,
> > 			    const char *filename,
> > 			    unsigned flags,
> > 			    const struct xstat_parameters *params,
> > 			    struct xstat *buffer,
> > 			    size_t buflen);
> 
> If you already have a buflen parameter there is absolute no need for
> the extra results field.  Just define new fields at the end and include
> them if the bufsize is big enough and it's in the mask of requested
> fields.

Or, as someone else has already said, return -E2BIG if the result won't fit.

> > The request_mask should be set by the caller to specify extra results that
> > the caller may desire.  These come in a number of classes:
> > 
> >  (0) dev, blksize.
> > 
> >      These are local data and are always available.
> > 
> >  (1) mode, nlinks, uid, gid, [amc]time, ino, size, blocks.
> > 
> >      These will be returned whether the caller asks for them or not.  The
> >      corresponding bits in result_mask will be set to indicate their
> >      presence.
> > 
> >      If the caller didn't ask for them, then they may be approximated.  For
> >      example, NFS won't waste any time updating them from the server,
> >      unless as a byproduct of updating something requested.
> 
> Please don't introduce tons of special cases.  Instead use a simple rule
> like:
>
>  - a filesystem must return all attributes requests, or return an
>    error if it can't.
>  - a filesystem may return additional attributes, the caller can detect
>    this by looking at st_mask.
> 
> plus possibly a list of attributes the filesystem must be able to
> provide if requests.  I don't see a reason to make that mask different
> from the attributes required by Posix.

Firstly: Lightweight stat: I want to say that the filesystem may return data
that is out of date if it isn't asked for specifically, but the filesystem has
a copy available.  But I'm not sure that this should apply to non-standard
fields.

Secondly: It doesn't matter what POSIX wants; not all filesystems we support
have everything available.  Where something that's standard is not available,
we have the opportunity to indicate this, whilst still providing a fabricated
result, so that the user can take note of this fact if they choose to, whilst
totally ignoring the indication if they prefer, and just using the fabrication.

Davod
