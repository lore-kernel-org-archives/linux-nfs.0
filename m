Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:59699 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932797AbbGJPHG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 11:07:06 -0400
Date: Fri, 10 Jul 2015 17:06:59 +0200
From: William Dauchy <william@gandi.net>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: William Dauchy <william@gandi.net>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net
Subject: Re: extra reference to fl->fl_file, possible regression
Message-ID: <20150710150659.GP15144@gandi.net>
References: <20150710092910.GI15144@gandi.net>
 <20150710072438.08b3417a@tlielax.poochiereds.net>
 <20150710125444.GL15144@gandi.net>
 <20150710103914.78189580@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HrsILUyxNtiOryfc"
In-Reply-To: <20150710103914.78189580@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--HrsILUyxNtiOryfc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Jul10 10:39, Jeff Layton wrote:
> So if a file happened to have some flock locks on it, then we could
> be taking a new reference to a file that has already had its refcount
> go to zero.

do you have any test case which may confirm that?
in the commit messages, you also were refering to some tests; I wonder
if you could share it.
--=20
William

--HrsILUyxNtiOryfc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWf35MACgkQ1I6eqOUidQHuKgCcDEV6Vs/rE+m6+diDnYujv0pu
k88AnAnddCCmDOfjrkJ/I0nDmF+0qB96
=vagU
-----END PGP SIGNATURE-----

--HrsILUyxNtiOryfc--
