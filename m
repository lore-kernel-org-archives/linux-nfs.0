Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:44054 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753870AbbIPKDr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 06:03:47 -0400
Date: Wed, 16 Sep 2015 11:54:45 +0200
From: William Dauchy <william@gandi.net>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: rpc.idmapd Too many open files
Message-ID: <20150916095445.GG21414@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nYySOmuH/HDX6pKp"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nYySOmuH/HDX6pKp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On a linux v3.14.x nfs client I'm getting many idmapd errors:
nfsopen: open(/var/lib/nfs/rpc_pipefs/nfs/clnt270d/idmap): Too many open fi=
les

I have 300+ nfs mounts but I can't see which limit I reach.
Do you have some hints about it?

Thanks,
--=20
William

--nYySOmuH/HDX6pKp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlX5PGUACgkQ1I6eqOUidQGg/gCfVlYPcB+22iN/MNWvX9/La7FI
OI0Ani5hg5S+Is54FpNnwQOtThfcCb3M
=oJWe
-----END PGP SIGNATURE-----

--nYySOmuH/HDX6pKp--
