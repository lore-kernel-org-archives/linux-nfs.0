Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36743 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbcEIMDE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 08:03:04 -0400
Received: by mail-qk0-f171.google.com with SMTP id x7so92574758qkd.3
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2016 05:03:03 -0700 (PDT)
Message-ID: <1462795378.4481.31.camel@poochiereds.net>
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>, David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Mon, 09 May 2016 08:02:58 -0400
In-Reply-To: <20160508083543.GA14316@infradead.org>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
	 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
	 <20160508083543.GA14316@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-05-08 at 01:35 -0700, Christoph Hellwig wrote:
> > 
> > 	int ret = statx(int dfd,
> > 			const char *filename,
> > 			unsigned int flags,
> > 			unsigned int mask,
> > 			struct statx *buffer);
> 
> Please move the flags and mask after the buffer, similar to how all
> the AT_ flags were added to the end for the statat calls.
> 
> > AT_FORCE_ATTR_SYNC can be set in flags.  This will require a network
> > filesystem to synchronise its attributes with the server.
> > 
> > AT_NO_ATTR_SYNC can be set in flags.  This will suppress synchronisation
> > with the server in a network filesystem.  The resulting values should be
> > considered approximate.
> 
> And what happens if neither is set?
> 

I'd suggest we have the documentation state that the lack of either
flag leaves it up to the filesystem. In the case of NFS, you'd get
"normal" attribute cache behavior, for instance which is governed by
the ac* attributes.

We should also note that in the case of something like AT_NO_ATTR_SYNC
on NFS, you might _still_ end up talking to the server if the client
has nothing in-core for that inode.

> > mask is a bitmask indicating the fields in struct statx that are of
> > interest to the caller.  The user should set this to STATX_BASIC_STATS to
> > get the basic set returned by stat().
> 
> No a very good name for the constant.  I don't really see how this macro
> is useful to start with.  And _ALL? sure, but what's basic?
> 
> > buffer points to the destination for the data.  This must be 256 bytes in
> > size.
> 
> 256 bytes or sizeof(struct statx)?  Even if they end up the same the
> latter is a much more useful value.
> 

ACK. We should also consider that while we have a fair bit of padding
in this structure now, we could end up running out of space in it at
some point. We should at least have a clear idea of how we'll handle
such a situation.

The obvious solution would be to add a new flag that says that we're
passing in an extended statx structure. The kernel would know not to
touch stuff in the extended part unless the flag was set. Userland
would know that that part had not been touched by the kernel if the
outbound flag wasn't set.


> > where st_information is local system information about the file,
> 
> What the heck is "local system information"?  Please define each
> newly added field in detail.
> 
> > st_gen is
> > the inode generation number, st_btime is the file creation time, st_version
> > is the data version number (i_version),
> 
> Please define semantics for st_gen and st_version.
> 
> > Time fields are split into separate seconds and nanoseconds fields to make
> > packing easier and the granularities can be queried with the filesystem
> > info system call.  Note that times will be negative if before 1970; in such
> > a case, the nanosecond fields should also be negative if not zero.
> 
> Please coordinate with Arnd on the timespamp format - I'd hate to have
> a different encoding than he plans for all y2028/64-bit-time_t syscalls
> to be added soon.
> 
> > 	STATX_MTIME		Want/got st_mtime
> > 	STATX_CTIME		Want/got st_ctime
> > 	STATX_INO		Want/got st_ino
> > 	STATX_SIZE		Want/got st_size
> > 	STATX_BLOCKS		Want/got st_blocks
> > 	STATX_BASIC_STATS	[The stuff in the normal stat struct]
> > 	STATX_BTIME		Want/got st_btime
> > 	STATX_VERSION		Want/got st_data_version
> 
> What is st_data_version?
> 
> > 	STATX_GEN		Want/got st_gen
> > 	STATX_ALL_STATS		[All currently available stuff]
> 
> Where does the STATS_ come from?  Why no simply _ALL?
> 
> How are the semantics defined when userspace asks for fields not
> available?  I'd expect them to be ignored, but we should documentat that
> fact.
> 
> > The defined bits in the st_information field give local system data on a
> > file, how it is accessed, where it is and what it does:
> 
> Oh, here we get st_information.  The name sounds very wrong for these
> flags, though.
> 
> > 	STATX_INFO_ENCRYPTED		File is encrypted
> 
> How do you define "encrypted", and what can the user do with this
> information?
> 
> > 	STATX_INFO_TEMPORARY		File is temporary
> 
> How do you define "temporary", and what can the user do with this
> information?
> 
> > 	STATX_INFO_FABRICATED		File was made up by filesystem
> 
> How do you define "fabricated", and what can the user do with this
> information?
> 
> > 	STATX_INFO_KERNEL_API		File is kernel API (eg: procfs/sysfs)
> 
> How do you define "kernel API" and what can the user do with this
> information?
> 
> > 	STATX_INFO_REMOTE		File is remote
> 
> How do you define "remote" and what can the user do with this
> information?
> 
> > 	STATX_INFO_AUTOMOUNT		Dir is automount trigger
> 
> How do you define "automount trigger" and what can the user do with this
> information?
> 
> > 	STATX_INFO_AUTODIR		Dir provides unlisted automounts
> 
> How do you define "unlisted automount" and what can the user do with this
> information?
> 
> > 	STATX_INFO_NONSYSTEM_OWNERSHIP	File has non-system ownership details
> 
> How do you define "non-system ownership" and what can the user do with this
> information?
> 

Good questions all around.

My personal opinion is that if we have any attrs that are of
questionable value or that don't have a clear definition, that we
should just leave them out for now. This interface is designed to be
extendable, so there's no need to add it all in in the first pass. We
should focus on getting the API right and sort out the gory details of
specific attributes on a case-by-case basis.

> > 
> > These are for the use of GUI tools that might want to mark files specially,
> > depending on what they are.
> 
> So far I don't see good definition of either flag, nor a good reason
> to add.
> 
> > Fields in struct statx come in a number of classes:
> 
> I really disagree with all these special cases.  You should get
> what you ask for, or rather what you ask for IFF the fs can provide it.
> And we need to document for each field if it's optional if we want
> to treat it as option.  A hodge podge bag of special cases is not an
> API that a normal person can use.
> 

Agreed. In fact, the required attributes might be a good place to draw
the line on the initial submission of this patchset. Maybe just say "no
optional attributes yet" and we'll add them in later patches?

> > The following test program can be used to test the statx system call:
> > 
> > 	samples/statx/test-statx.c
> 
> Please add xfstests test cases that test all the corner cases.
> 
> And please prepare a man page to document this system call properly.

Nothing wrong with preparing that ahead of time, but I see that as
something that should go along with the userland submission. In fact,
what's the plan for userland here? Should this be added to glibc or do
would it be better/simpler to have a new library for this?

Either way, what would be best for now though is to do What Neil
suggested, and lift most of this commit log into a file under
Documentation/.

Furthermore, it'd probably be nice to document each mask bit in the
header file that userland will end up including. It's often the case
that the manpage may not reflect what the currently installed kernel
actually supports. The kernel headers are often more authoritative.
Being able to look at the header file for would be ideal.

-- 
Jeff Layton <jlayton@poochiereds.net>
