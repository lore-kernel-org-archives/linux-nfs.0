Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:36102 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752424AbbKKV2z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2015 16:28:55 -0500
Date: Wed, 11 Nov 2015 22:28:52 +0100
From: William Dauchy <william@gandi.net>
To: William Dauchy <william@gandi.net>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: strange behavior with nfsv3 using linux v4.1
Message-ID: <20151111212852.GC3641@gandi.net>
References: <20151106225715.GH12546@gandi.net>
 <20151107084150.GI12546@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="96YOpH+ONegL0A3E"
In-Reply-To: <20151107084150.GI12546@gandi.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--96YOpH+ONegL0A3E
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov07 09:41, William Dauchy wrote:
> On Nov06 23:57, William Dauchy wrote:
> > I am seeing strange behaviors with a single nfsv3 mount on linux
> > v4.1.x. I first started to see two kworker in D state while I was not
> > doing anything. The server is an opensolaris nfs server.
>=20
> forgot to mention this nfsv3 mount is a using CONFIG_ROOT_NFS
> it's a read only mount point
>=20
> the client seems to be looping on revalidation.

please forget this report I mixed it with a network card issue.
--=20
William

--96YOpH+ONegL0A3E
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlZDsxQACgkQ1I6eqOUidQE6RwCgnQNtfGDeYzM6/Aot0uuoHG/F
A8kAnjdUBQ4L63vc2WHs4HCVa1MozT/m
=ooKX
-----END PGP SIGNATURE-----

--96YOpH+ONegL0A3E--
