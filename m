Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35441 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbbEBXRF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 May 2015 19:17:05 -0400
Date: Sun, 3 May 2015 09:16:53 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150503091653.35169382@notabene.brown>
In-Reply-To: <20150501132953.GA2583@fieldses.org>
References: <553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150501020324.GP889@ZenIV.linux.org.uk>
	<20150501122333.1476c999@notabene.brown>
	<20150501022939.GQ889@ZenIV.linux.org.uk>
	<20150501130826.40721dd0@notabene.brown>
	<20150501132953.GA2583@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/lhm296nF2Z5/v2u+nhJIddh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/lhm296nF2Z5/v2u+nhJIddh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 1 May 2015 09:29:53 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Fri, May 01, 2015 at 01:08:26PM +1000, NeilBrown wrote:
> > On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk> wro=
te:
> >=20
> > > On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > > > What kind of consistency warranties do callers expect, BTW?  You =
do realize
> > > > > that between iterate_dir() and callbacks an entry might have been=
 removed
> > > > > and/or replaced?
> > > >=20
> > > > For READDIR_PLUS, lookup_one_len is called on each name and it requ=
ires
> > > > i_mutex, so the code currently holds i_mutex over the whole sequenc=
e.
> > > > This is triggering a deadlock.
> > >=20
> > > Yes, I've seen the context.  However, you are _not_ holding it between
> > > actual iterate_dir() and those callbacks, which opens a window when
> > > directory might have been changed.
> > >=20
> > > Again, what kind of consistency is expected by callers?  Are they rea=
dy to
> > > cope with "there's no such entry anymore" or "inumber is nothing like
> > > what we'd put in ->ino, since it's no the same object" or "->d_type is
> > > completely unrelated to what we'd found, since the damn thing had been
> > > removed and created from scratch"?
> >=20
> > Ah, sorry.
> >=20
> > Yes, the callers are prepared for "there's no such entry anymore".
> > They don't use d_type, so don't care if it might be meaningless.
> > NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cautious
> > about ino changing.
> >=20
> > In nfs3xdr, we should probably pass 'ino' to encode_entryplus_baggage()=
 and
> > thence to compose_entry_fh() and it should report failure if
> > dchild->d_inode->i_ino doesn't match.
>=20
> Just to make sure I understand the concern..... So it shouldn't really
> be a problem if readdir and lookup find different objects for the same
> name, the problem is just when we mix attributes from the two objects,
> right?  Looks like the v3 code could return an inode number derived from
> the readdir and a filehandle from the lookup, which is a problem.  The
> v4 code will get everything from the result of the lookup, which should
> be OK.

That agrees with my understanding, yes.

I did wonder for a little while about the possibility of a directory
containing both 'a' and 'b', and NFSv4 doing the readdir and the stat of 'a=
',
and the a "mv a b" happening before the stat of 'b'.

Then the readdir response will show both 'a' and 'b' referring to the same
object with a link count of 1.

I can't quite decide if that is a problem or not.


>=20
> > Simply not returning the extra attributes is perfectly acceptable in NF=
Sv3.
>=20
> Right, so no big deal anyway.--b.

Not a big deal, but we should really add a patch like the following ("like"
as in "actually compile tested and documented" which this one isn't).

NeilBrown

>=20
> > So it looks like we are mostly OK here - we don't really need i_mutex t=
o be
> > held for very long.
> >=20
> > NeilBrown
> >=20
>=20

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index e4b2b4322553..f6e7cbabac5a 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -805,7 +805,7 @@ encode_entry_baggage(struct nfsd3_readdirres *cd, __be3=
2 *p, const char *name,
=20
 static __be32
 compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
-		const char *name, int namlen)
+		 const char *name, int namlen, u64 ino)
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent, *dchild;
@@ -830,19 +830,21 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct =
svc_fh *fhp,
 		goto out;
 	if (d_really_is_negative(dchild))
 		goto out;
+	if (dchild->d_inode->i_ino !=3D ino)
+		goto out;
 	rv =3D fh_compose(fhp, exp, dchild, &cd->fh);
 out:
 	dput(dchild);
 	return rv;
 }
=20
-static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be3=
2 *p, const char *name, int namlen)
+static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be3=
2 *p, const char *name, int namlen, u64 ino)
 {
 	struct svc_fh	*fh =3D &cd->scratch;
 	__be32 err;
=20
 	fh_init(fh, NFS3_FHSIZE);
-	err =3D compose_entry_fh(cd, fh, name, namlen);
+	err =3D compose_entry_fh(cd, fh, name, namlen, ino);
 	if (err) {
 		*p++ =3D 0;
 		*p++ =3D 0;
@@ -927,7 +929,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, =
int namlen,
 		p =3D encode_entry_baggage(cd, p, name, namlen, ino);
=20
 		if (plus)
-			p =3D encode_entryplus_baggage(cd, p, name, namlen);
+			p =3D encode_entryplus_baggage(cd, p, name, namlen, ino);
 		num_entry_words =3D p - cd->buffer;
 	} else if (*(page+1) !=3D NULL) {
 		/* temporarily encode entry into next page, then move back to
@@ -941,7 +943,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, =
int namlen,
 		p1 =3D encode_entry_baggage(cd, p1, name, namlen, ino);
=20
 		if (plus)
-			p1 =3D encode_entryplus_baggage(cd, p1, name, namlen);
+			p1 =3D encode_entryplus_baggage(cd, p1, name, namlen, ino);
=20
 		/* determine entry word length and lengths to go in pages */
 		num_entry_words =3D p1 - tmp;

--Sig_/lhm296nF2Z5/v2u+nhJIddh
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUVa5jnsnt1WYoG5AQKDcQ//TgHqpTUOQLrbBbrFcNVGcqyNuuPIyft0
qUlYhqPGyQhHUBU80w10J1x9FotScY3vyAFqpFR37mhhG7eexE21gMkVPb+ImpdO
oJJW5sc6Mr/K/OE0u9a06dmHtzFyrXfXXOrYHTJJZYp4YrMpU2H8YcQ8S1W4r3EX
DogTWxAVEkQsKlNl4xZoWVW7RHNPuTpOWS7VC2EDE1SgmQpz34SRYX6140dxDCOM
KPToVHpdWvG2TscgkBkhy9G+sGgmxznyMMOGhk8gvYCw6LiAHal8bVRBjtMDpiLE
1kJVzW1tiLf/rg10icDEx/pATkGOyQf+qMrmYjbzCF0hyA/5SOfhgnzd5oZ/jrUO
pPz/ywu+yat6OWHpdAmotO6Sa8nkbWP8E/hYKGgmX72WOhTvRGLumieOP4hVDcc9
Vl8hH8zHhPRyEX37TIq0dQJSwE8SEHO2nHpFa3oGd6AfM3Oc69qOyxmWY5v6vCW4
fkKWL0TvEfczoKEuA4Os6gQg88YOMONdHrYZ81Hw0yYpqhOzDb8OUtC/JTvTagZa
6GEYHQB3JUjE5SurGOBs4ip+3RGnJA1dmqJKZABlM0YW5oq3QXkOXKrTKtGf6JIA
R0ixpMZw6uteGSA4YAB6Ko8QFFowXrG5D/u+A0AGx/HjQYfsU9LEqICwAepIzhWZ
woDewut8lYU=
=GqsP
-----END PGP SIGNATURE-----

--Sig_/lhm296nF2Z5/v2u+nhJIddh--
