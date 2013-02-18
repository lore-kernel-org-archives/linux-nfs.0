Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:34655 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab3BRSqS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 13:46:18 -0500
Date: Mon, 18 Feb 2013 18:46:09 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130218184609.GF4503@ZenIV.linux.org.uk>
References: <20130212113813.427b8e05@notabene.brown>
 <20130214104230.013b7f71@tlielax.poochiereds.net>
 <20130218132509.0ce779de@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130218132509.0ce779de@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 18, 2013 at 01:25:09PM +1100, NeilBrown wrote:

> I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag that
> works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips the very
> last step and returns the mounted-on directory, not the mountpoint that is
> mounted there - or at least makes sure not revalidate happens on that final
> mounted directory.

I don't think LOOKUP_MOUNTPOINT is a good idea.  For one thing, we have
fairly few places that might want it, all of them in core VFS.  Might as
well provide a separate function for them, a-la path_lookupat() vs.
path_openat().

For another, we need to decide what to do with a really nasty corner case:
	a/b is a mountpoint, with c/d bound on it.
	c/d is a symlink to c/e
	c/e is a mountpoint
What should umount("a/b", 0) do?  There are two possibilities - removing
vfsmount on top of a/b or one on top of c/e...

We have the latter semantics; _that_ is what this GETATTR is about.  It's
a fairly obscure corner case - the question is not even whether to follow
symlinks, it's whether to follow _mounts_ on the last component.  Hell
knows; I'm seriously tempted to change it "don't follow mounts" and see if
anyone complains.  The only case when behaviour would change would be
a symlink mounted somewhere (note that this is _not_ something that can easily
happen; e.g. mount --bind does follow symlinks) and umount(2) given the
path resolving to the mountpoint of that symlink.
 
> I think FS_REVAL_DOT is needed so that if you call stat("."), it will update
> attributes from the server if the cache is old.  However it seems to do a
> whole lot more than that, including "lookup" calls which it I'm sure is wrong.

Far from only that.  FS_REVAL_DOT is a misnomer - it's not just ".".  Take
a look at the places where LOOKUP_JUMPED is set; _that_ is what drives the
damn thing.  Essentially, LOOKUP_JUMPED is "we hadn't arrived here by
lookup in parent"; "." (or "/") obviously qualify, but so does following
a procfs-style symlink, or .., for that matter.  "foo/.", OTOH, does *not*.

It matters only in the end of the pathname, of course.  So we don't need to do
revalidate every time we step on e.g. .. or cross a mountpoint (let alone
when we step on .), as long as we make sure that revalidate isn't missing in
the end of path.
