From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC PATCH 0/2] Add VFS support for looking up paths on remote
	servers using a temporary mount namespace
Date: Tue, 10 Feb 2009 16:48:22 -0500
Message-ID: <20090210214822.GF32393@fieldses.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org> <20090210155820.GB29075@fieldses.org> <1234290708.7423.72.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756416AbZBJVs1@vger.kernel.org>
In-Reply-To: <1234290708.7423.72.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2009 at 01:31:48PM -0500, Trond Myklebust wrote:
> On Tue, 2009-02-10 at 10:58 -0500, J. Bruce Fields wrote:
> > On Mon, Feb 09, 2009 at 01:45:34PM -0500, Trond Myklebust wrote:
> > > The following two patches attempt to improve NFSv4's ability to look up
> > > the mount path on a remote server.
> > > 
> > > The first patch adds VFS support for walking the remote path, using a
> > > temporary mount namespace to represent the server's namespace, so that
> > > symlinks
> > 
> > I'm a bit confused about the symlink case--I take it you're assuming
> > that symlinks in the pseudofs should be interpreted as relative to the
> > server's namespace (in keeping with traditional implementations of
> > server exports), while symlinks elsewhere should continue to be
> > intepreted relative to the client's namespace.

Maybe I shouldn't have said "symlinks in the pseudofs", as that's not
entirely well defined--a complicated namespace may transition between
"pseudofs" and "real" filesystems multiple times.  So it's really a
statement about the client's mount behavior: symlinks found along the
mount path will be interpreted one way, symlinks found elsewhere
another.  Right?

Though put that way it's harder to decide what to store in a symlink,
since you can't necessarily control which paths a given client may
decide to mount.

> > Do the rfc's say anything about this?
> 
> No, the RFCs say nothing, but interpreting symlinks as being relative to
> the server namespace would be consistent with the mount behaviour of
> NFSv2/v3. It also makes me uncomfortable to have a remote mount path
> that could refer back to the client's namespace: that would not be an
> NFS mount, but a local bind mount...

Some may be surprised to find that /mntsymlink/ and /mnt/symlink/ will
be different after

	mount file:/path/symlink/ /mntsymlink/
	mount file:/path/	  /mnt/

I see your point, though it might also be an argument for continuing to
error out on symlinks.

It could also be argued that if a given symlink is expected to be
interpreted on the server side, then the server should just go ahead and
do that for the client, rather than returning it as a symlink.

Seems worth at least mentioning to the ietf group, as different behavior
across different clients would be confusing.

--b.
