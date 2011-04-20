Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:46314 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753815Ab1DTLIi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 07:08:38 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LJY005RK6YDK080@mta-1.ms.rz.RWTH-Aachen.de> for
 linux-nfs@vger.kernel.org; Wed, 20 Apr 2011 13:08:37 +0200 (CEST)
Received: from gheift ([unknown] [134.130.113.37])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LJY00EDP6YC9W70@relay-auth-2.ms.rz.rwth-aachen.de> for
 linux-nfs@vger.kernel.org; Wed, 20 Apr 2011 13:08:37 +0200 (CEST)
Date: Wed, 20 Apr 2011 13:08:36 +0200
From: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsdv4 leaks file descriptors
Message-id: <20110420110834.GB11224@gheift>
References: <20110412140148.GA17242@gheift>
 <20110413211211.GA25189@fieldses.org> <20110414054844.GF17242@gheift>
 <20110414191005.GB1721@fieldses.org> <20110415132025.GA6126@gheift>
 <20110415223621.GB12254@fieldses.org>
Content-type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary=LyciRD1jyfeSSjG0
In-reply-to: <20110415223621.GB12254@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--LyciRD1jyfeSSjG0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 15, 2011 at 06:36:21PM -0400, J. Bruce Fields wrote:
> On Fri, Apr 15, 2011 at 03:20:30PM +0200, Gerhard Heift wrote:
> > On Thu, Apr 14, 2011 at 03:10:06PM -0400, J. Bruce Fields wrote:
> > > On Thu, Apr 14, 2011 at 07:48:45AM +0200, Gerhard Heift wrote:
> > > > On Wed, Apr 13, 2011 at 05:12:11PM -0400, J. Bruce Fields wrote:
> > > > > On Tue, Apr 12, 2011 at 04:01:50PM +0200, Gerhard Heift wrote:
> > > > > > Hello,
> > > > > >=20
> > > > > > I have a linux kernel (2.6.38.2, armv5tel) running which export=
s a
> > > > > > directory with following options:
> > > > >=20
> > > > > Should be fixed in more recent stable kernel; let me know if not.
> > > >=20
> > > > An even more recent stable than 2.6.38.2? I just compiled 2.6.39-rc=
3 and
> > > > there the leak happens too.
> > >=20
> > > Ugh.  OK, investigating.
> >=20
> > It took me a bit of time, but I located the commit which introduced this
> > behavior: acfdf5c383b38f7f4dddae41b97c97f1ae058f49
>=20
> Doh--probably we just need this (lightly tested).
>=20
> Thanks for tracking this down.

This patch works for me. Thanks for fixing it.

> --b.

Regards,
  Gerhard

> commit 21cd8aaf5efb086361cf12f9245c14a3b19fbafd
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Apr 15 18:08:26 2011 -0400
>=20
>     nfsd4: fix struct file leak on delegation
>    =20
>     Introduced by acfdf5c383b38f7f4dddae41b97c97f1ae058f49.
>    =20
>     Reported-by: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index aa309aa..c79a983 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -258,6 +258,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
>  	if (atomic_dec_and_test(&fp->fi_delegees)) {
>  		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
>  		fp->fi_lease =3D NULL;
> +		fput(fp->fi_deleg_file);
>  		fp->fi_deleg_file =3D NULL;
>  	}
>  }
>=20

--LyciRD1jyfeSSjG0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk2uvrIACgkQa8fhU24j2flfvgCfaSVL56jt/xwE30jR3h9ItqlN
Zj0AnjvAYOn+d39PLEyHaIU28ehDDaog
=ZufP
-----END PGP SIGNATURE-----

--LyciRD1jyfeSSjG0--
