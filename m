From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC PATCH 0/2] Add VFS support for looking up paths on remote
 servers using a temporary mount namespace
Date: Wed, 11 Feb 2009 15:59:30 -0500
Message-ID: <1234385970.7423.274.camel@heimdal.trondhjem.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
	 <20090210155820.GB29075@fieldses.org>
	 <1234290708.7423.72.camel@heimdal.trondhjem.org>
	 <20090210214822.GF32393@fieldses.org>
	 <1234306135.7423.171.camel@heimdal.trondhjem.org>
	 <20090211195352.GA23974@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090211195352.GA23974@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-11 at 14:53 -0500, J. Bruce Fields wrote:
> On Tue, Feb 10, 2009 at 05:48:55PM -0500, Trond Myklebust wrote:
> > On Tue, 2009-02-10 at 16:48 -0500, J. Bruce Fields wrote:
> > > On Tue, Feb 10, 2009 at 01:31:48PM -0500, Trond Myklebust wrote:
> > > > On Tue, 2009-02-10 at 10:58 -0500, J. Bruce Fields wrote:
> > > > > On Mon, Feb 09, 2009 at 01:45:34PM -0500, Trond Myklebust wrote:
> > > > > > The following two patches attempt to improve NFSv4's ability to look up
> > > > > > the mount path on a remote server.
> > > > > > 
> > > > > > The first patch adds VFS support for walking the remote path, using a
> > > > > > temporary mount namespace to represent the server's namespace, so that
> > > > > > symlinks
> > > > > 
> > > > > I'm a bit confused about the symlink case--I take it you're assuming
> > > > > that symlinks in the pseudofs should be interpreted as relative to the
> > > > > server's namespace (in keeping with traditional implementations of
> > > > > server exports), while symlinks elsewhere should continue to be
> > > > > intepreted relative to the client's namespace.
> > > 
> > > Maybe I shouldn't have said "symlinks in the pseudofs", as that's not
> > > entirely well defined--a complicated namespace may transition between
> > > "pseudofs" and "real" filesystems multiple times.  So it's really a
> > > statement about the client's mount behavior: symlinks found along the
> > > mount path will be interpreted one way, symlinks found elsewhere
> > > another.  Right?
> > > 
> > > Though put that way it's harder to decide what to store in a symlink,
> > > since you can't necessarily control which paths a given client may
> > > decide to mount.
> > 
> > That has been the nature of an NFS mount path string since it was first
> > introduced in NFSv2: it refers to the server namespace.
> > People haven't complained about this previously, so why should we
> > start changing the meaning of the mount path when we move to NFSv4?
> 
> It wasn't previously possible for servers to expose symlinks in the
> mount path to clients, so it's not clear to me how to apply precedent.

What are you talking about? Of course it was possible! What is
the /bar/baz mount example below doing that is specific to NFSv4? The
only difference here is the question of who is interpreting the mount
path.

The precedent is that in NFSv2/v3, the client sent _all_ mount path
lookup requests to the server's mount daemon. The mount daemon then did
a path lookup in its namespace, following symlinks if necessary, and
returned an NFSv2/v3 filehandle for the endpoint.
In all lookup requests that were sent to the NFS server, symlinks were
never followed, but were returned to the NFS client for interpretation
relative to the user's namespace.

In NFSv4, the mount path is looked up by the client. Why should it act
any differently to the NFSv2/v3 mount daemon, and interpret symlinks
relative to some other namespace?
After the mount is complete, then all subsequent lookups are interpreted
relative to the user's namespace, and so are the symlinks.

> > > > > Do the rfc's say anything about this?
> > > > 
> > > > No, the RFCs say nothing, but interpreting symlinks as being relative to
> > > > the server namespace would be consistent with the mount behaviour of
> > > > NFSv2/v3. It also makes me uncomfortable to have a remote mount path
> > > > that could refer back to the client's namespace: that would not be an
> > > > NFS mount, but a local bind mount...
> > > 
> > > Some may be surprised to find that /mntsymlink/ and /mnt/symlink/ will
> > > be different after
> > > 
> > > 	mount file:/path/symlink/ /mntsymlink/
> > > 	mount file:/path/	  /mnt/
> > 
> > So, what then if I do
> > 
> > 	ln -s ../foo /bar/baz/symlink
> > 
> > on the server, then compare
> > 
> > 	mount server:/bar/baz /mnt
> > and
> > 	mount server:/bar/baz/symlink /mnt
> > 
> > Would you argue that those two should produce the same result? My
> > interpretation would be as follows:
> > 
> > In the first case, the symlink is visible as /mnt/symlink, and so
> > 'cd /mnt/symlink' will take you to the local path '/foo' on the client.
> > 
> > In the second case, I'd be very surprised if the mount code did anything
> > other than to follow /bar/baz/symlink to remote path /bar/foo, and then
> > mount that on '/mnt'
> > 
> > If you agree that the above behaviour is correct, then how would you
> > argue that replacing '/bar/baz/symlink' with an absolute symlink
> > (i.e. 'ln -sf /bar/foo /bar/baz/symlink') should suddenly cause mount to
> > do a bind mount?
> 
> I certainly agree that mount shouldn't do a bind mount in that case.
> 
> > > I see your point, though it might also be an argument for continuing to
> > > error out on symlinks.
> > 
> > Again, why? We don't do that today with NFSv2/v3.
> 
> The question doesn't arise with NFSv2/v3, since the mount protocol can't
> return a symlink to the client.

The mount daemon returns the filehandle of the end point mount path
after interpreting the symlink relative to its namespace. It doesn't
error out.

Why should an NFSv4 mount that uses the exact same mount parameters
suddenly have to return an EINVAL when it could do exactly the same
thing as NFSv2/v3 did?

> > > It could also be argued that if a given symlink is expected to be
> > > interpreted on the server side, then the server should just go ahead and
> > > do that for the client, rather than returning it as a symlink.
> > 
> > How would the server distinguish between a client that is doing a lookup
> > of a mount path and one that is looking up a normal path?
> 
> Exactly, it can't--that's what worries me.  Under your proposal, the
> server will return symlinks to the client which the client will
> sometimes interpret relative to the server namespace, and sometimes
> relative to the client namespace.

No! It means that we _always_ interprets mount paths as being relative
to the server namespace, and that we _always_ interprets user path
lookups as being relative to the user's namespace.

That is fully consistent with all previous practice, and means that

1)
    mount -t nfs -overs=2 server:/bar/baz/mnt
    mount -t nfs -overs=3 server:/bar/baz /mnt
and
    mount -t nfs4 server:/bar/baz /mnt

always works and produces the same result. A subsequent
'ls /mnt/symlink' will refer to the resulting user namespace, and so the
symlink may point to a local file or directory

2)
    mount -t nfs -overs=2 server:/bar/baz/symlink /mnt
    mount -t nfs -overs=3 server:/bar/baz/symlink /mnt
and
    mount -t nfs4 server:/bar/baz/symlink /mnt

always produce the same result (but different to case 1). We mount the
directory that 'symlink' points to on the server. A subsequent 'ls /mnt'
shows no symlink, but points to the same NFS mounted directory in all 3
cases.

3)
    mount -t nfs -overs=2 server:/bar/baz/symlink/foo /mnt
    mount -t nfs -overs=3 server:/bar/baz/symlink/foo /mnt
and
    mount -t nfs4 server:/bar/baz/symlink/foo /mnt

always produce the same result (but different to cases 1 and 2). We
mount the same sub-directory of case 2 onto /mnt.

> Since the server can't know which the client will do, I don't see how to
> make any sensible decision about what the value of that symlink should
> be.
> 
> In your example, if the intention of creating /bar/baz/symlink was
> really to direct clients mounting that path to mount /bar/foo, I wonder
> if the most helpful thing might just be for the server to return
> a filehandle for the directory /bar/foo/ instead of for the symlink
> /bar/foo/symlink.

It can't do that. It has no idea whether or not this is a mount path
lookup or a user path lookup, and as I've said before, the two refer to
completely different namespaces.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
