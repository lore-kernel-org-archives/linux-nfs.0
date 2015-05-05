Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51104 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020AbbEFDsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 23:48:55 -0400
Date: Wed, 6 May 2015 08:27:02 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150506082702.0a867be4@notabene.brown>
In-Reply-To: <20150504214822.GA16827@fieldses.org>
References: <20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150501020324.GP889@ZenIV.linux.org.uk>
	<20150501122333.1476c999@notabene.brown>
	<20150501022939.GQ889@ZenIV.linux.org.uk>
	<20150501130826.40721dd0@notabene.brown>
	<20150501132953.GA2583@fieldses.org>
	<20150503091653.35169382@notabene.brown>
	<20150504214822.GA16827@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/7Qa0Q2.VdLmhqJut0_ywZbH"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/7Qa0Q2.VdLmhqJut0_ywZbH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 4 May 2015 17:48:22 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Sun, May 03, 2015 at 09:16:53AM +1000, NeilBrown wrote:
> > On Fri, 1 May 2015 09:29:53 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Fri, May 01, 2015 at 01:08:26PM +1000, NeilBrown wrote:
> > > > On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk>=
 wrote:
> > > >=20
> > > > > On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > > > > > What kind of consistency warranties do callers expect, BTW?  =
You do realize
> > > > > > > that between iterate_dir() and callbacks an entry might have =
been removed
> > > > > > > and/or replaced?
> > > > > >=20
> > > > > > For READDIR_PLUS, lookup_one_len is called on each name and it =
requires
> > > > > > i_mutex, so the code currently holds i_mutex over the whole seq=
uence.
> > > > > > This is triggering a deadlock.
> > > > >=20
> > > > > Yes, I've seen the context.  However, you are _not_ holding it be=
tween
> > > > > actual iterate_dir() and those callbacks, which opens a window wh=
en
> > > > > directory might have been changed.
> > > > >=20
> > > > > Again, what kind of consistency is expected by callers?  Are they=
 ready to
> > > > > cope with "there's no such entry anymore" or "inumber is nothing =
like
> > > > > what we'd put in ->ino, since it's no the same object" or "->d_ty=
pe is
> > > > > completely unrelated to what we'd found, since the damn thing had=
 been
> > > > > removed and created from scratch"?
> > > >=20
> > > > Ah, sorry.
> > > >=20
> > > > Yes, the callers are prepared for "there's no such entry anymore".
> > > > They don't use d_type, so don't care if it might be meaningless.
> > > > NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cau=
tious
> > > > about ino changing.
> > > >=20
> > > > In nfs3xdr, we should probably pass 'ino' to encode_entryplus_bagga=
ge() and
> > > > thence to compose_entry_fh() and it should report failure if
> > > > dchild->d_inode->i_ino doesn't match.
> > >=20
> > > Just to make sure I understand the concern..... So it shouldn't really
> > > be a problem if readdir and lookup find different objects for the same
> > > name, the problem is just when we mix attributes from the two objects,
> > > right?  Looks like the v3 code could return an inode number derived f=
rom
> > > the readdir and a filehandle from the lookup, which is a problem.  The
> > > v4 code will get everything from the result of the lookup, which shou=
ld
> > > be OK.
> >=20
> > That agrees with my understanding, yes.
> >=20
> > I did wonder for a little while about the possibility of a directory
> > containing both 'a' and 'b', and NFSv4 doing the readdir and the stat o=
f 'a',
> > and the a "mv a b" happening before the stat of 'b'.
> >=20
> > Then the readdir response will show both 'a' and 'b' referring to the s=
ame
> > object with a link count of 1.
> >=20
> > I can't quite decide if that is a problem or not.
> >=20
> >=20
> > >=20
> > > > Simply not returning the extra attributes is perfectly acceptable i=
n NFSv3.
> > >=20
> > > Right, so no big deal anyway.--b.
> >=20
> > Not a big deal, but we should really add a patch like the following ("l=
ike"
> > as in "actually compile tested and documented" which this one isn't).
>=20
> Doesn't seem to break anything.  Any second thoughts, or can I add a
> signed-off-by?

No second thoughts.

Signed-off-by: NeilBrown <neilb@suse.de>

Thanks.
NeilBrown

>=20
> --b.
>=20
> commit e11f8acace69
> Author: NeilBrown <neilb@suse.de>
> Date:   Sun May 3 09:16:53 2015 +1000
>=20
>     nfsd: stop READDIRPLUS returning inconsistent attributes
>    =20
>     The NFSv3 READDIRPLUS gets some of the returned attributes from the
>     readdir, and some from an inode returned from a new lookup.  The two
>     objects could be different thanks to intervening renames.
>    =20
>     The attributes in READDIRPLUS are optional, so let's just skip them if
>     we notice this case.
>    =20
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>=20
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index e4b2b4322553..f6e7cbabac5a 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -805,7 +805,7 @@ encode_entry_baggage(struct nfsd3_readdirres *cd, __b=
e32 *p, const char *name,
> =20
>  static __be32
>  compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
> -		const char *name, int namlen)
> +		 const char *name, int namlen, u64 ino)
>  {
>  	struct svc_export	*exp;
>  	struct dentry		*dparent, *dchild;
> @@ -830,19 +830,21 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struc=
t svc_fh *fhp,
>  		goto out;
>  	if (d_really_is_negative(dchild))
>  		goto out;
> +	if (dchild->d_inode->i_ino !=3D ino)
> +		goto out;
>  	rv =3D fh_compose(fhp, exp, dchild, &cd->fh);
>  out:
>  	dput(dchild);
>  	return rv;
>  }
> =20
> -static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __b=
e32 *p, const char *name, int namlen)
> +static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __b=
e32 *p, const char *name, int namlen, u64 ino)
>  {
>  	struct svc_fh	*fh =3D &cd->scratch;
>  	__be32 err;
> =20
>  	fh_init(fh, NFS3_FHSIZE);
> -	err =3D compose_entry_fh(cd, fh, name, namlen);
> +	err =3D compose_entry_fh(cd, fh, name, namlen, ino);
>  	if (err) {
>  		*p++ =3D 0;
>  		*p++ =3D 0;
> @@ -927,7 +929,7 @@ encode_entry(struct readdir_cd *ccd, const char *name=
, int namlen,
>  		p =3D encode_entry_baggage(cd, p, name, namlen, ino);
> =20
>  		if (plus)
> -			p =3D encode_entryplus_baggage(cd, p, name, namlen);
> +			p =3D encode_entryplus_baggage(cd, p, name, namlen, ino);
>  		num_entry_words =3D p - cd->buffer;
>  	} else if (*(page+1) !=3D NULL) {
>  		/* temporarily encode entry into next page, then move back to
> @@ -941,7 +943,7 @@ encode_entry(struct readdir_cd *ccd, const char *name=
, int namlen,
>  		p1 =3D encode_entry_baggage(cd, p1, name, namlen, ino);
> =20
>  		if (plus)
> -			p1 =3D encode_entryplus_baggage(cd, p1, name, namlen);
> +			p1 =3D encode_entryplus_baggage(cd, p1, name, namlen, ino);
> =20
>  		/* determine entry word length and lengths to go in pages */
>  		num_entry_words =3D p1 - tmp;


--Sig_/7Qa0Q2.VdLmhqJut0_ywZbH
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUlDtjnsnt1WYoG5AQLzsxAAxKQqiZQ6OtE2FTInWrRH4779Dv2jRKbd
hc6O/jRQV5XtyYOcHEmxJ6eoFS6LYHO0sADEXPnxd0czeQsdSrhrOH+oW/tHgzc/
WzFeOWlQptkXKKW8vgkfkKKWOWeL9n8QkGPTq99MDOEGnpZiCQW/+V6+r7fQkjma
j7LGcxXpAWv9tek+fx6R01ysSLzE2Sm6EiqfqhRa9FCeSMDT/JdJrhqDhYLu3Pgj
+IBsTSCbPnGrDQpyOteTDuOpejjWcIysklaKhmBQ0V8fDYhJ3fBMZPc6BxdtHLWc
tmaCrq6LT+T3Yg+Xvk1+f2zrXFRLUR7I4FSlahY1VvU7YpuuIkzZMJJPEbGGeB10
YzBSKtSmL2qO9VgSGm17Dl/+uoMphtTmNe8rogacbABNKIiOlwlQAW7AYL9TIjDk
t1/gY53/rCE0pSXY5h6tpUrkoUnH2htjuWC7wvkjl2zsB/do6e4YcRz5w+gAn6jU
cGBOZNRsg1JlMj6QBQJPzU8bU0NY2SJFS9tTip0iexU/tQJUEGLATGSdkHZRUPjX
eF5PLqD8Hr/CxIxOHFjYhAOl355RuLt77bTFrrKJXtzrQx+TeziVUphW01NEyoGM
0o6sVbrlRDIV1GbglxpVOaC8yt7c7GUn6r/c+rLxVbE7T87rM52d5+2zwV1Zmwdw
JDL7VEyTMEU=
=GS5k
-----END PGP SIGNATURE-----

--Sig_/7Qa0Q2.VdLmhqJut0_ywZbH--
