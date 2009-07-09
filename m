From: Hans Kramer <hans.kramer-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Invalidating NFS attribute cache
Date: Thu, 09 Jul 2009 16:39:09 +0200
Message-ID: <1247150349.7427.84.camel@cancun.hanskramer.com>
References: <1247142894.7427.43.camel@cancun.hanskramer.com>
	 <5440D81E-BC29-4061-92B5-D750CEECFF62@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-XXsw6zVWoXsakpLNrGPK"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr16.xs4all.nl ([194.109.24.36]:4073 "EHLO
	smtp-vbr16.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759207AbZGIOjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2009 10:39:17 -0400
In-Reply-To: <5440D81E-BC29-4061-92B5-D750CEECFF62@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-XXsw6zVWoXsakpLNrGPK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Thanks Chuck,

I was not aware of this mount option.

I will try it.

Thanks!


On Thu, 2009-07-09 at 10:10 -0400, Chuck Lever wrote:
> On Jul 9, 2009, at 8:34 AM, Hans Kramer wrote:
> > Hi,
> >
> > For some silly reason I have an application that needs to poll for the
> > existence of a certain file on a NFS share.
> > (This is done from Sybase ASE ;-)
> >
> > Now I run into the issue of attribute caching. Turning of the =20
> > attribute
> > cache with the mount option of -o noac easily solves all the issues.
> >
> > However, it would be nice if we could still use attribute caching and
> > force to invalidate on-demand the attribute cache.
>=20
> Since you are only concerned with the existence of a file (and not its =20
> mtime, say). have you considered the new directory cache mount option: =20
> lookupcache=3D?
>=20
> I see it's not mentioned in nfs(8) so you should probably look in =20
> recent archives of this mailing list for information.
>=20
> > After a lot of trying, the following solution seems to work for me =20
> > now:
> > (pathname is the test file)
> >
> > #define _GNU_SOURCE
> >
> >    char *copy =3D strdup(pathname);
> >    char *path =3D dirname(copy);
> >
> >    int fd =3D open(path, O_DIRECTORY);
> >    if (fd >=3D 0)
> >        close(fd);
> >
> >    free(copy);
> >
> >    return access(pathname, F_OK);
> >
> > Just opening the parent directory with O_DIRECTORY seems to do the
> > trick.
> >
> > My questions: Is this hack going to work under every circumstance or
> > could it fail in the future with some update. Is there a ioctl call =20
> > that
> > could the the same thing? That is invalidate the parent directory =20
> > cache.
> > Or do I miss something completely ?-)
> >
> > Thanks in advance
> >
> > Hans
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" =20
> > in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=-XXsw6zVWoXsakpLNrGPK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpWAQ0ACgkQwGRENV8Xlu9A5QCdGmKnIrDaYMp2c8PH/4BcIFbh
hcYAnRkv0LeJ7sopUlMTOidIAxRiwoqL
=ngxa
-----END PGP SIGNATURE-----

--=-XXsw6zVWoXsakpLNrGPK--

