From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sat, 30 Aug 2008 16:47:41 +0100
Message-ID: <1220111261.31172.14.camel@localhost.localdomain>
References: <1219435207.27921.51.camel@localhost.localdomain>
	 <1219440202.9097.14.camel@localhost>
	 <1219441041.27921.57.camel@localhost.localdomain>
	 <1219442213.9097.25.camel@localhost>
	 <1219603981.27921.145.camel@localhost.localdomain>
	 <1219605422.14389.2.camel@localhost> <1219605596.14389.5.camel@localhost>
	 <1219615789.27921.152.camel@localhost.localdomain>
	 <1219616136.14389.12.camel@localhost>
	 <48B2D7F8.5020206@opengridcomputing.com>
	 <20080826192711.GJ4380@fieldses.org>
	 <48B567F5.2090605@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-N+xzNbkT5pn/TJhoODfv"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:17427 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753371AbYH3Prv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Aug 2008 11:47:51 -0400
In-Reply-To: <48B567F5.2090605@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-N+xzNbkT5pn/TJhoODfv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-08-27 at 09:43 -0500, Tom Tucker wrote:
> Sure. I've actually tried to reproduce it here unsuccessfully.
>=20
> As a starter, I would suggest turning on transport debugging:
>=20
> # echo 256 > /proc/sys/sunrpc/rpc_debug
> [...]
> If Ian is willing to create the log (or already has one), I'm
> certainly willing to look at it.

It produced only the following (is that what was expected?):

[146866.448112] -pid- proc flgs status -client- -prog- --rqstp- -timeout -r=
pcwait -action- ---ops--
[146866.448112] 30576 0001 00a0      0 f77a1600 100003 f7903340    15000 xp=
rt_pending fa0ba88e fa0c9df4
[146866.448112] 30577 0004 0080    -11 f77a1600 100003 f7903000        0 xp=
rt_sending fa0ba88e fa0c9df4

Ian.
--=20
Ian Campbell

Life is a concentration camp.  You're stuck here and there's no way
out and you can only rage impotently against your persecutors.
		-- Woody Allen

--=-N+xzNbkT5pn/TJhoODfv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAki5a50ACgkQM0+0qS9rzVkKVgCffqWaEb2ozXNfneXRttb4Dr1d
4JEAnRuuBKBw8K0HNcSJU+mr29qgEsjF
=qFux
-----END PGP SIGNATURE-----

--=-N+xzNbkT5pn/TJhoODfv--

