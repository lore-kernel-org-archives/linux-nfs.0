Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932963Ab3BSO1t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 09:27:49 -0500
Date: Tue, 19 Feb 2013 09:27:04 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130219092704.77458702@tlielax.poochiereds.net>
In-Reply-To: <20130219101031.123b1eb0@notabene.brown>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
	<20130218184609.GF4503@ZenIV.linux.org.uk>
	<20130219101031.123b1eb0@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZoqFdHFJ6FDkdnuqr5Ef.wG"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZoqFdHFJ6FDkdnuqr5Ef.wG
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 19 Feb 2013 10:10:31 +1100
NeilBrown <neilb@suse.de> wrote:

> On Mon, 18 Feb 2013 18:46:09 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrot=
e:
>=20
> > On Mon, Feb 18, 2013 at 01:25:09PM +1100, NeilBrown wrote:
> >=20
> > > I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag t=
hat
> > > works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips t=
he very
> > > last step and returns the mounted-on directory, not the mountpoint th=
at is
> > > mounted there - or at least makes sure not revalidate happens on that=
 final
> > > mounted directory.
> >=20
> > I don't think LOOKUP_MOUNTPOINT is a good idea.  For one thing, we have
> > fairly few places that might want it, all of them in core VFS.  Might as
> > well provide a separate function for them, a-la path_lookupat() vs.
> > path_openat().
> >=20
> > For another, we need to decide what to do with a really nasty corner ca=
se:
> > 	a/b is a mountpoint, with c/d bound on it.
> > 	c/d is a symlink to c/e
> > 	c/e is a mountpoint
> > What should umount("a/b", 0) do?  There are two possibilities - removing
> > vfsmount on top of a/b or one on top of c/e...
> >=20
> > We have the latter semantics; _that_ is what this GETATTR is about.  It=
's
> > a fairly obscure corner case - the question is not even whether to foll=
ow
> > symlinks, it's whether to follow _mounts_ on the last component.  Hell
> > knows; I'm seriously tempted to change it "don't follow mounts" and see=
 if
> > anyone complains.  The only case when behaviour would change would be
> > a symlink mounted somewhere (note that this is _not_ something that can=
 easily
> > happen; e.g. mount --bind does follow symlinks) and umount(2) given the
> > path resolving to the mountpoint of that symlink.
>=20
> Thinking about this some more, I now realise that my LOOKUP_MOUNTPOINT id=
ea
> was too simplistic and missed the real point.
>=20
> The real point is that for unmount, we want to resolve the the path witho=
ut
> any reference to any filesystem at all - the lookup should be handled
> entirely by the dcache.
> Any mountpoint is pinned in the dcache, and consequently any ancestor of =
any
> mount point also is.  So the dcache will lead us to the dentry that we wa=
nt.
>=20
> And the dentry is *all* we want.  It doesn't really matter what the inode=
 is
> like, or whether the filesystem thinks that the inode or name still exist.
> All we need to do is find a dentry that must be  in the cache, and detach=
 the
> mount that is there.
>=20
> Whether that is achieved by a LOOKUP_ flag or a separate lookup function
> doesn't matter much to me.
>=20
> I suspect we need to allow for passing a symlink to unmount, and the syml=
ink
> might not be in cache, so we cannot insist uniformly on only using the dc=
ache.
> However if a name is in the cache, and the cached data suggests that it i=
s a
> directory, then we should trust that and avoid referring to the filesyste=
m.
>=20
> umount is really quite unique in this.  All other times we lookup a path =
we
> want to use the thing we found.  With umount, we want to stop using it.
>=20

=46rom an IRC conversation with Al yesterday, which may point you in the
right direction:

12:49 < viro> jlayton: umount() simply shouldn't do full lookup for path
12:50 < viro> it should get the parent
12:50 < viro> _then_ do pure dcache lookup for the last step

...of course that's still tricky if the last component is a symlink
since you'd need to chase it by hand, but that seems like a reasonable
way to start.

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/ZoqFdHFJ6FDkdnuqr5Ef.wG
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRI4u4AAoJEAAOaEEZVoIVryYQALWRHBJKkLNelkjaukivkDvh
4dVPwWJwkowADdxVlj2kOnKUgvfHq0V2J1mhf2MD+n59j9n7tukIFRu6dTnfq37g
uTehu/iAn2goANkSPZdx9V9N60M5eGHMzobEBXdVfg2Q6QDAsDH0JX/p/KpE7Ott
agicx+ZGwwc7iZjrWeB2wKpaurrGonkhSUhM7IMT6l/2HDdmn8YrYeIAwO9pUMZY
8y86WexjoWkTUXxkJ39HumejKKKiCk93Hqj7s8re5/hqbZbGHUfilz8+6aIpcC3o
tYrCWcht+/i1IIyzkTYAb5AZv1ODE31Xy11B3n0VE9lb0Xj/fE0DuujtyI7sEFWA
2Z74dt4WSoOThk3xIq1QHLAFujBbWYklf6+IKe6WtnW9Lw0y/pHaJj+4p5C8PJVP
T8yXtAx4+nQc5BBdk2pp8XmaX2o9RAG+cJw/GJG/8gu/PjGe0bP3OJSYgkubYChD
c7Ihv0gbbCXSy+FQJYLdM73iUNmkZQBRv6dpfQETr3uA+XKPIQSytyw10+Lg10Pu
oQ/QnTuwsN2zmvpdNoknYVBMYX+/zfOzHW/ViHZ64df1NQfLmcZ9xGCIdGUrmOkL
BZ6AUPqyXRcOZaWIHWBOoRNpXT9ejREZA3H87A089g6ZQIP8kwjtNkW8hDc1nqI9
/Gs6bUywAcTWZ+GKwFUH
=5EaH
-----END PGP SIGNATURE-----

--Sig_/ZoqFdHFJ6FDkdnuqr5Ef.wG--
