Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60893 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894Ab3FFAF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 20:05:28 -0400
Date: Thu, 6 Jun 2013 10:05:12 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [patch/rfc] allow exported (and *not* exported) filesystems to
 be unmounted.
Message-ID: <20130606100512.1c701a64@notabene.brown>
In-Reply-To: <20130605133658.GE24193@fieldses.org>
References: <20130605130541.5968d5c2@notabene.brown>
	<20130605034115.GD13110@ZenIV.linux.org.uk>
	<20130605161934.59ab6804@notabene.brown>
	<20130605133658.GE24193@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/KhT/_1T0ryihfq.G5jPBdfk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/KhT/_1T0ryihfq.G5jPBdfk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Jun 2013 09:36:58 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Jun 05, 2013 at 04:19:34PM +1000, NeilBrown wrote:
> > On Wed, 5 Jun 2013 04:41:15 +0100 Al Viro <viro@ZenIV.linux.org.uk> wro=
te:
> >=20
> > > On Wed, Jun 05, 2013 at 01:05:41PM +1000, NeilBrown wrote:
> > > >=20
> > > > Hi Bruce,
> > > >  this is a little issue that seems to keep coming up so I thought i=
t might be
> > > >  time to fix it.
> > > >=20
> > > >  As you know, a filesystem that is exported cannot be unmounted as =
the export
> > > >  cache holds a reference to it.  Though if it hasn't been accessed =
for a
> > > >  while then it can.
> > > >=20
> > > >  As I hadn't realised before sometimes *non* exported filesystems c=
an be
> > > >  pinned to.  A negative entry in the cache can pin a filesystem jus=
t as
> > > >  easily as a positive entry.
> > > >  An amusing, if somewhat contrived, example is that if you export '=
/' with
> > > >  crossmnt and:
> > > >=20
> > > >     mount localhost:/ /mnt
> > > >     ls -l /
> > > >     umount /mnt
> > > >=20
> > > >  the umount might fail.  This is because the "ls -l" tried to expor=
t every
> > > >  filesystem found mounted in '/'.  The export of "/mnt" failed of c=
ourse
> > > >  because you cannot re-export an NFS filesystem.  But it is still i=
n the
> > > >  cache.
> > > >  An 'exportfs -f' fixes this, but shouldn't be necessary.
>=20
> Yeah, ugh.  As a less contrived example, can the default v4 root export
> lead to arbitrary filesystems being pinned just because a client tried
> to mount the wrong path?

I think it can only pin filesystems that are exported, either explicitly or
via a parent being exported with 'crossmnt'.

>=20
> Could the export cache be indexed on a path string instead of a struct
> path?

Yes.  It would mean lots of extra pathname lookups and possibly lots of
"d_path()" calls.

>=20
> The problem of negative entries aside, anyone counting on the ability to
> unexport mounted filesystems on a running nfs server is setting
 ^unmount exported^?
> themselves up for trouble: suppose we fix this problem, what if an rpc
> is in progress, or a lock or v4 open or delegation is held?

All of these should prevent the unmount - and I think people would expect
that - you cannot unmount a filesystem that is still being used, and all of
these are examples of current use.  At the very least, the  filesystem must
be mounted on some client.

In the (few) times this has been raised over the years, the position has be=
en
"I'm not using it any more, why cannot I unmount it?  fuser/lsof doesn't
show any users!".

An alternate approach to the problem might be to get rpc.mountd to hold an
open file descriptor for every exported filesystem.  That would guide people
(via lsof/fuser) to stopping nfsd, which would make the filesystem
unmountable.
However I don't find that approach particularly elegant...

NeilBrown


--Sig_/KhT/_1T0ryihfq.G5jPBdfk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa/SODnsnt1WYoG5AQJ1BRAAskrRt727Bp+r+uymjEWNm9huY/aacQW0
1dvjG4A2JHLP7wFjC08nHnv4n0ucjJj4mSGttCaN0yLtzSSeCiD0PpcB/4P4gy+A
xndTqTZiXDRBufKP3GF6KWeaiR7faQdCDp2VH68EO1/cSN3r3bmFt0uDTZCSXD6F
D1N2usUqFtYXc+Nads/D1F27RJsLUFW5+Gt332GkuXKjWZ5/Va+h8R0rEg00Oxqb
htWKTLQ4cusJZofw6WU8U6r4s5orRqjDx3bAoiFyWIwXI95zHgnmqruRoDJIItdS
OG9CRyjAL3ZGwiCNQRD4odT/LeYg+WevmG5evkKPB/Z0j+1X+yuY2J1iEK3FKNm7
gzyIKa6F0A9OYqS6OQ7Hs+MmFFLGxAlcRtalXGCFmbBaCN/O7IsgZeBWjSDfapWF
MDvdQNSDM0ufysoBJF8Dy8Gh2AyUaQBSi+EUjAZT/sqqtw6lhlUgAjjgPzh8q8cg
8kS3lk7uDs+sXsL+tCOxEOUxGRU2nyaTbG8LDjSZ+bjsQd6iFhz+0B2NU2hEhlnX
fSbD09SwGKJJA4LykQ1uYyEfTqset9dVuQzRbyj01a5mynAP1HApc0r1QJF9f0mY
vDm3lRr4+iYKXvrpZ2UvjPLLKhGF2u6BYObh9RHAT6Q68Spz0xArNIzZbyD3XYOO
Vng5O4n6QQo=
=7mNe
-----END PGP SIGNATURE-----

--Sig_/KhT/_1T0ryihfq.G5jPBdfk--
