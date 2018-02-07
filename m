Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:26091 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753794AbeBGLqx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Feb 2018 06:46:53 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: Remove a redundant call to unmap_mapping_range()
Date: Wed, 7 Feb 2018 11:46:48 +0000
Message-ID: <1518003998.3483.0.camel@primarydata.com>
References: <20180129025822.5116-1-trond.myklebust@primarydata.com>
         <876079nvvc.fsf@notabene.neil.brown.name>
In-Reply-To: <876079nvvc.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-PayWf9/Bnt18en77Ndm/"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-PayWf9/Bnt18en77Ndm/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2018-02-07 at 17:42 +1100, NeilBrown wrote:
> On Sun, Jan 28 2018, Trond Myklebust wrote:
>=20
> > We don't need to call unmap_mapping_range() prior to calling
> > nfs_sync_mapping().
>=20
> Don't we?

See line 2 of nfs_sync_mapping(). =E2=98=BA

> Doesn't that allow a process which mapped the page to dirty it
> immediately after nfs_sync_mapping(), without the page being
> reloaded from the server first?
> Doesn't seem right..
>=20
> Thanks,
> NeilBrown
>=20
>=20
> >=20
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfs/inode.c | 1 -
> >  1 file changed, 1 deletion(-)
> >=20
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index deeb7d1097d0..49fba9ea5872 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -1170,7 +1170,6 @@ static int nfs_invalidate_mapping(struct
> > inode *inode, struct address_space *map
> > =20
> >  	if (mapping->nrpages !=3D 0) {
> >  		if (S_ISREG(inode->i_mode)) {
> > -			unmap_mapping_range(mapping, 0, 0, 0);
> >  			ret =3D nfs_sync_mapping(mapping);
> >  			if (ret < 0)
> >  				return ret;
> > --=20
> > 2.14.3
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-
> > nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-PayWf9/Bnt18en77Ndm/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlp65x4ACgkQZwvnipYK
APIEUw//S/blao5d39QAw7Xh8+7AZNdiSfnyBG0uYKQVUQ+D59ywNTFsI67PM9iw
BBGbyBJ2CYwaRcikV+Juj2h0tLHi032vsoamqPWdCh+WqAkzq4PiEM7yowx+zQt1
ZbPocE8mD4+EQWKfMqQrYaAbSvDxsPLym1BY0oo+YIoceGgqDtZ+TYve/gsjU6rr
/3mYNuLb0ouSoDH+byUeonfLC+k04sGhC7j8XWyhOcvLr5p6Cac5HdOiWiy1CBpp
qovkojY0hosJ/Q01cBcqBI/jdaj9M0eqSgRL9yi46wrhaP5g//t2XH8qKsEOPFnt
s3Ru6stQjDzdoL9szmbjnXfhdeK2/S2zSVeP0A6DD0xh3rgQ/3PvN0mt2b3eIPps
wcIN5yd5tpniM6gF5D73F5D/IwOgbyq1QzglrfrGB+H98sAN9NxlSNLXr9ZdZSA/
vJtzEw0tes6tZVsjN6IZBWo9e0KuOl1UBAzgQUDrG8YIPDsjyR5ApZ73F7P4PhZa
NQidGxU/uL1tiWQQDMg68hrJAaS2JxXq18bBp69HBkWhxyoA3AvLB5byFmMK0CPb
5TwIv+I0H5cXL/eXKXIU6CUbcmopFCNOvBqepZOYFJlE3neFyZOH8Y4/JwZffp8v
unNzU0MN8Vo9bNgl91K9OC0/yWqSlU8+mKbMUU33VGVNrTDsC7c=
=imXj
-----END PGP SIGNATURE-----

--=-PayWf9/Bnt18en77Ndm/--

