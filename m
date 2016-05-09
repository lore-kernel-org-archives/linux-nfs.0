Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbcEIM5f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 08:57:35 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20160508083543.GA14316@infradead.org>
References: <20160508083543.GA14316@infradead.org> <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 09 May 2016 13:57:32 +0100
Message-ID: <31651.1462798652@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> > 	int ret = statx(int dfd,
> > 			const char *filename,
> > 			unsigned int flags,
> > 			unsigned int mask,
> > 			struct statx *buffer);
> 
> Please move the flags and mask after the buffer, similar to how all
> the AT_ flags were added to the end for the statat calls.

Sure, if you really want.

> > AT_FORCE_ATTR_SYNC can be set in flags.  This will require a network
> > filesystem to synchronise its attributes with the server.
> > 
> > AT_NO_ATTR_SYNC can be set in flags.  This will suppress synchronisation
> > with the server in a network filesystem.  The resulting values should be
> > considered approximate.
> 
> And what happens if neither is set?

It does what stat() does now, whatever that is for each fs.  The assumption is
that this might be used to emulate stat() from userspace.  However, we want to
be able to make sure we get the two behaviours above.

> > mask is a bitmask indicating the fields in struct statx that are of
> > interest to the caller.  The user should set this to STATX_BASIC_STATS to
> > get the basic set returned by stat().
> 
> No a very good name for the constant.  I don't really see how this macro
> is useful to start with.

It's the bits that correspond to all the data in the the current stat struct.
So if you want to emulate stat(), you should pass this in mask.

> And _ALL? sure, but what's basic?

Actually, _ALL is perhaps the less useful of the two since the bitset is not
closed.  OTOH - anything not in _ALL won't be listed explicitly in the
structure, but would rather consume space space.

> > st_gen is
> > the inode generation number, st_btime is the file creation time, st_version
> > is the data version number (i_version),
> 
> Please define semantics for st_gen and st_version.

I've been asked to drop st_gen for security reasons.

I can't offhand think of a way to define st_version (or i_version, for that
matter) that would be consistent across all filesystems.  I would lean towards
"gets incremented monotonically by 1 for each data write operation committed,
but not for any metadata operations", but I'm fairly certain this won't jibe
with disk operations.  So I can leave it out for now and bring it back if we
find a real user for it.

> > Time fields are split into separate seconds and nanoseconds fields to make
> > packing easier and the granularities can be queried with the filesystem
> > info system call.  Note that times will be negative if before 1970; in such
> > a case, the nanosecond fields should also be negative if not zero.
> 
> Please coordinate with Arnd on the timespamp format - I'd hate to have
> a different encoding than he plans for all y2028/64-bit-time_t syscalls
> to be added soon.

I have discussed this with him previously.

> > 	STATX_VERSION		Want/got st_data_version
> 
> What is st_data_version?

Sorry, that should've been st_version.  It got renamed.

> > 	STATX_GEN		Want/got st_gen
> > 	STATX_ALL_STATS		[All currently available stuff]
> 
> Where does the STATS_ come from?  Why no simply _ALL?

Why not STATX_ALL_STATS?

David
