Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbcEINiY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 May 2016 09:38:24 -0400
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
Date: Mon, 09 May 2016 14:38:21 +0100
Message-ID: <1734.1462801101@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph Hellwig <hch@infradead.org> wrote:

> How are the semantics defined when userspace asks for fields not
> available?  I'd expect them to be ignored, but we should documentat that
> fact.

I went into this in some detail.

> > Fields in struct statx come in a number of classes:
> 
> I really disagree with all these special cases.  You should get
> what you ask for, or rather what you ask for IFF the fs can provide it.
> And we need to document for each field if it's optional if we want
> to treat it as option.

I did document this.  You saw it as a bunch of special cases.  It is not.
stat() fabricates some of the data it returns under certain circumstances.

> A hodge podge bag of special cases is not an API that a normal person can
> use.

Let's look at the list, and please bear in mind I'm trying to make it so that
you can emulate stat() through this interface.  If you want to waive that
requirement - or push the emulation out to userspace - then I can forego
providing unsupported data from the basic stat set.

| (0) st_information, st_dev_*, st_blksize.

st_dev_* and st_blksize must always be available from whatever we stat.
Because this is the case, there's no point providing mask bits for them.

My implementation defines st_information to be in this class, but it doesn't
have to be.  Note that st_information really needs a way to ask the filesystem
what flags it actually supports so that you can distinguish being 0 -> not set
from 0 -> not supported, hence the fsinfo() interface that I've dropped for
now.

| (1) st_nlinks, st_uid, st_gid, st_[amc]time*, st_ino, st_size, st_blocks.

These data are all in the bog standard struct stat.  As it is, they must all
be given values as for stat().  However, mask bits are provided to indicate
when the value presented here is actually fabricated so that the user can
decide not to use them.

| (2) st_mode.

This is actually in two parts.  There's the file type (which must always be
set correctly) and the mode bits (which may be fabricated).  STATX_MODE covers
the mode bits only.

| (3) st_rdev_*.

This datum is part of the bog standard struct stat, and as such must be set to
something.  However, the value is only relevant in the case that the mode
indicates a blockdev or chardev.  STATX_RDEV can be considered redundant in
such a case.

| (4) File creation time (st_btime*), data version (st_version), inode
|     generation number (st_gen).

These are all new data and have no counterpart in the Linux struct stat.
However, they do in the struct stat on other Unix variants (st_birthtime and
st_gen, for example, exist on BSD).  Not all filesystems provide them so if
they are requested but are not actually supported by a filesystem, the bit in
the mask is cleared upon returning.

However, even if you didn't ask for a datum, it may still be available - and I
am permitting a filesystem to give you the datum and mark the mask to indicate
the value's availability, even if you didn't ask for it.  You are free to
ignore it.

At this time, I think it likely that all new attributes would be in this
class.  One could argue that something like st_win_attrs (in patch 5) could be
in class 0 if added immediately, but anything added later *must* have a mask
bit to indicate its presence.


So, barring st_information, classes (0) - (3) are all current stat stuff.
That is how they work *now*.  All I'm doing is defining which data have mask
bits, and under what conditions the mask bit might not be set.

David
