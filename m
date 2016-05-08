Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44854 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbcEHIfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 04:35:46 -0400
Date: Sun, 8 May 2016 01:35:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160508083543.GA14316@infradead.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 	int ret = statx(int dfd,
> 			const char *filename,
> 			unsigned int flags,
> 			unsigned int mask,
> 			struct statx *buffer);

Please move the flags and mask after the buffer, similar to how all
the AT_ flags were added to the end for the statat calls.

> AT_FORCE_ATTR_SYNC can be set in flags.  This will require a network
> filesystem to synchronise its attributes with the server.
> 
> AT_NO_ATTR_SYNC can be set in flags.  This will suppress synchronisation
> with the server in a network filesystem.  The resulting values should be
> considered approximate.

And what happens if neither is set?

> mask is a bitmask indicating the fields in struct statx that are of
> interest to the caller.  The user should set this to STATX_BASIC_STATS to
> get the basic set returned by stat().

No a very good name for the constant.  I don't really see how this macro
is useful to start with.  And _ALL? sure, but what's basic?

> buffer points to the destination for the data.  This must be 256 bytes in
> size.

256 bytes or sizeof(struct statx)?  Even if they end up the same the
latter is a much more useful value.

> where st_information is local system information about the file,

What the heck is "local system information"?  Please define each
newly added field in detail.

> st_gen is
> the inode generation number, st_btime is the file creation time, st_version
> is the data version number (i_version),

Please define semantics for st_gen and st_version.

> Time fields are split into separate seconds and nanoseconds fields to make
> packing easier and the granularities can be queried with the filesystem
> info system call.  Note that times will be negative if before 1970; in such
> a case, the nanosecond fields should also be negative if not zero.

Please coordinate with Arnd on the timespamp format - I'd hate to have
a different encoding than he plans for all y2028/64-bit-time_t syscalls
to be added soon.

> 	STATX_MTIME		Want/got st_mtime
> 	STATX_CTIME		Want/got st_ctime
> 	STATX_INO		Want/got st_ino
> 	STATX_SIZE		Want/got st_size
> 	STATX_BLOCKS		Want/got st_blocks
> 	STATX_BASIC_STATS	[The stuff in the normal stat struct]
> 	STATX_BTIME		Want/got st_btime
> 	STATX_VERSION		Want/got st_data_version

What is st_data_version?

> 	STATX_GEN		Want/got st_gen
> 	STATX_ALL_STATS		[All currently available stuff]

Where does the STATS_ come from?  Why no simply _ALL?

How are the semantics defined when userspace asks for fields not
available?  I'd expect them to be ignored, but we should documentat that
fact.

> The defined bits in the st_information field give local system data on a
> file, how it is accessed, where it is and what it does:

Oh, here we get st_information.  The name sounds very wrong for these
flags, though.

> 	STATX_INFO_ENCRYPTED		File is encrypted

How do you define "encrypted", and what can the user do with this
information?

> 	STATX_INFO_TEMPORARY		File is temporary

How do you define "temporary", and what can the user do with this
information?

> 	STATX_INFO_FABRICATED		File was made up by filesystem

How do you define "fabricated", and what can the user do with this
information?

> 	STATX_INFO_KERNEL_API		File is kernel API (eg: procfs/sysfs)

How do you define "kernel API" and what can the user do with this
information?

> 	STATX_INFO_REMOTE		File is remote

How do you define "remote" and what can the user do with this
information?

> 	STATX_INFO_AUTOMOUNT		Dir is automount trigger

How do you define "automount trigger" and what can the user do with this
information?

> 	STATX_INFO_AUTODIR		Dir provides unlisted automounts

How do you define "unlisted automount" and what can the user do with this
information?

> 	STATX_INFO_NONSYSTEM_OWNERSHIP	File has non-system ownership details

How do you define "non-system ownership" and what can the user do with this
information?

> 
> These are for the use of GUI tools that might want to mark files specially,
> depending on what they are.

So far I don't see good definition of either flag, nor a good reason
to add.

> Fields in struct statx come in a number of classes:

I really disagree with all these special cases.  You should get
what you ask for, or rather what you ask for IFF the fs can provide it.
And we need to document for each field if it's optional if we want
to treat it as option.  A hodge podge bag of special cases is not an
API that a normal person can use.

> The following test program can be used to test the statx system call:
> 
> 	samples/statx/test-statx.c

Please add xfstests test cases that test all the corner cases.

And please prepare a man page to document this system call properly.
