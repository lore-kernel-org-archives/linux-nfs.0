Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53275 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494Ab3BRXKu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 18:10:50 -0500
Date: Tue, 19 Feb 2013 10:10:31 +1100
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130219101031.123b1eb0@notabene.brown>
In-Reply-To: <20130218184609.GF4503@ZenIV.linux.org.uk>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
	<20130218184609.GF4503@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/N1N.nRAQ8Fnq2k4beO5zwL2"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/N1N.nRAQ8Fnq2k4beO5zwL2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Feb 2013 18:46:09 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Feb 18, 2013 at 01:25:09PM +1100, NeilBrown wrote:
>=20
> > I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag that
> > works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips the=
 very
> > last step and returns the mounted-on directory, not the mountpoint that=
 is
> > mounted there - or at least makes sure not revalidate happens on that f=
inal
> > mounted directory.
>=20
> I don't think LOOKUP_MOUNTPOINT is a good idea.  For one thing, we have
> fairly few places that might want it, all of them in core VFS.  Might as
> well provide a separate function for them, a-la path_lookupat() vs.
> path_openat().
>=20
> For another, we need to decide what to do with a really nasty corner case:
> 	a/b is a mountpoint, with c/d bound on it.
> 	c/d is a symlink to c/e
> 	c/e is a mountpoint
> What should umount("a/b", 0) do?  There are two possibilities - removing
> vfsmount on top of a/b or one on top of c/e...
>=20
> We have the latter semantics; _that_ is what this GETATTR is about.  It's
> a fairly obscure corner case - the question is not even whether to follow
> symlinks, it's whether to follow _mounts_ on the last component.  Hell
> knows; I'm seriously tempted to change it "don't follow mounts" and see if
> anyone complains.  The only case when behaviour would change would be
> a symlink mounted somewhere (note that this is _not_ something that can e=
asily
> happen; e.g. mount --bind does follow symlinks) and umount(2) given the
> path resolving to the mountpoint of that symlink.

Thinking about this some more, I now realise that my LOOKUP_MOUNTPOINT idea
was too simplistic and missed the real point.

The real point is that for unmount, we want to resolve the the path without
any reference to any filesystem at all - the lookup should be handled
entirely by the dcache.
Any mountpoint is pinned in the dcache, and consequently any ancestor of any
mount point also is.  So the dcache will lead us to the dentry that we want.

And the dentry is *all* we want.  It doesn't really matter what the inode is
like, or whether the filesystem thinks that the inode or name still exist.
All we need to do is find a dentry that must be  in the cache, and detach t=
he
mount that is there.

Whether that is achieved by a LOOKUP_ flag or a separate lookup function
doesn't matter much to me.

I suspect we need to allow for passing a symlink to unmount, and the symlink
might not be in cache, so we cannot insist uniformly on only using the dcac=
he.
However if a name is in the cache, and the cached data suggests that it is a
directory, then we should trust that and avoid referring to the filesystem.

umount is really quite unique in this.  All other times we lookup a path we
want to use the thing we found.  With umount, we want to stop using it.

???

NeilBrown


--Sig_/N1N.nRAQ8Fnq2k4beO5zwL2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSK05znsnt1WYoG5AQLK/Q/6AqixXUY83P2BozDbUoN8Y9M4cs1mkBSz
tuGrnnG3R4+JqfI2JekKQ4UOdAPAITw6OxvjQMAsXnW0gO8SISNzOdemM546pUTN
HsP3B8feH8GxXbB64cu1x2HMjrEnaOrdLIx0rUgQbc5ptCDnozaLRr2Mc1uQg1V3
DUtE7NYFkVtS581XB/4PFwDSBqOt8lyl+pjl8a+RVUPEY7tdjF7R3yS7ZhU/+7MD
5UgNbkDSWNN8/Ezu0ykoTZgvzDfdLrfBx2kQxs2ySsg9Ng6VttTNcTBJ3WUlj+50
whbrFVKR47PDHX+h2Z2gXLBhQOHChMwAgRBRECion3xFIMT/nf4JsFnMlskYZA9I
UsZBmvqZUjeKBZAHadvSD6oN1B0na+RPHggngm8s/4Dg+kcHQqguuXI6X8nvXg4q
wBrgVnxdQqrE83ppANBkmF7KYe8jZ0zRSH7B9J/WLnNWtQnLFB6qqnDV2VaVip29
If2+9JWl8Ey5sqthjaEgOjn59qDnTfD8Ywt4tsjZ0wqd1RAjBWegRK+Nd4MCCmqD
MJxqoFm53lEJ8AR6tNs3Vw6eKsr9Iq1/JlVK3P2QXzpNF/7VF3HdLlH0UBpJYjqe
YYZFTMLhB92VHYGzkCzAauxqIyYkknq9ka085yEKEbWfj6wGKI9C7zQu76H/Sq/v
Qxt+tEAsvYo=
=ga2U
-----END PGP SIGNATURE-----

--Sig_/N1N.nRAQ8Fnq2k4beO5zwL2--
