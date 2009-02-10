From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC PATCH 0/2] Add VFS support for looking up paths on remote
 servers using a temporary mount namespace
Date: Tue, 10 Feb 2009 17:48:55 -0500
Message-ID: <1234306135.7423.171.camel@heimdal.trondhjem.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
	 <20090210155820.GB29075@fieldses.org>
	 <1234290708.7423.72.camel@heimdal.trondhjem.org>
	 <20090210214822.GF32393@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63994 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756504AbZBJWtS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2009 17:49:18 -0500
In-Reply-To: <20090210214822.GF32393@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-02-10 at 16:48 -0500, J. Bruce Fields wrote:
> On Tue, Feb 10, 2009 at 01:31:48PM -0500, Trond Myklebust wrote:
> > On Tue, 2009-02-10 at 10:58 -0500, J. Bruce Fields wrote:
> > > On Mon, Feb 09, 2009 at 01:45:34PM -0500, Trond Myklebust wrote:
> > > > The following two patches attempt to improve NFSv4's ability to look up
> > > > the mount path on a remote server.
> > > > 
> > > > The first patch adds VFS support for walking the remote path, using a
> > > > temporary mount namespace to represent the server's namespace, so that
> > > > symlinks
> > > 
> > > I'm a bit confused about the symlink case--I take it you're assuming
> > > that symlinks in the pseudofs should be interpreted as relative to the
> > > server's namespace (in keeping with traditional implementations of
> > > server exports), while symlinks elsewhere should continue to be
> > > intepreted relative to the client's namespace.
> 
> Maybe I shouldn't have said "symlinks in the pseudofs", as that's not
> entirely well defined--a complicated namespace may transition between
> "pseudofs" and "real" filesystems multiple times.  So it's really a
> statement about the client's mount behavior: symlinks found along the
> mount path will be interpreted one way, symlinks found elsewhere
> another.  Right?
> 
> Though put that way it's harder to decide what to store in a symlink,
> since you can't necessarily control which paths a given client may
> decide to mount.

That has been the nature of an NFS mount path string since it was first
introduced in NFSv2: it refers to the server namespace. People haven't
complained about this previously, so why should we start changing the
meaning of the mount path when we move to NFSv4?

> > > Do the rfc's say anything about this?
> > 
> > No, the RFCs say nothing, but interpreting symlinks as being relative to
> > the server namespace would be consistent with the mount behaviour of
> > NFSv2/v3. It also makes me uncomfortable to have a remote mount path
> > that could refer back to the client's namespace: that would not be an
> > NFS mount, but a local bind mount...
> 
> Some may be surprised to find that /mntsymlink/ and /mnt/symlink/ will
> be different after
> 
> 	mount file:/path/symlink/ /mntsymlink/
> 	mount file:/path/	  /mnt/

So, what then if I do

	ln -s ../foo /bar/baz/symlink

on the server, then compare

	mount server:/bar/baz /mnt
and
	mount server:/bar/baz/symlink /mnt

Would you argue that those two should produce the same result? My
interpretation would be as follows:

In the first case, the symlink is visible as /mnt/symlink, and so
'cd /mnt/symlink' will take you to the local path '/foo' on the client.

In the second case, I'd be very surprised if the mount code did anything
other than to follow /bar/baz/symlink to remote path /bar/foo, and then
mount that on '/mnt'

If you agree that the above behaviour is correct, then how would you
argue that replacing '/bar/baz/symlink' with an absolute symlink
(i.e. 'ln -sf /bar/foo /bar/baz/symlink') should suddenly cause mount to
do a bind mount?

> I see your point, though it might also be an argument for continuing to
> error out on symlinks.

Again, why? We don't do that today with NFSv2/v3.

> It could also be argued that if a given symlink is expected to be
> interpreted on the server side, then the server should just go ahead and
> do that for the client, rather than returning it as a symlink.

How would the server distinguish between a client that is doing a lookup
of a mount path and one that is looking up a normal path?

> Seems worth at least mentioning to the ietf group, as different behavior
> across different clients would be confusing.

...as would different behaviour across different versions of NFS.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
