Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53066 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755449Ab3GBBx0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 21:53:26 -0400
Date: Tue, 2 Jul 2013 11:53:13 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Bodo Stroesser <bstroesser@ts.fujitsu.com>
Subject: Re: [PATCH 0/5] Fix assorted races in the sunrpc cache.
Message-ID: <20130702115313.33602764@notabene.brown>
In-Reply-To: <20130702003958.GG19945@fieldses.org>
References: <20130613025132.31861.97407.stgit@notabene.brown>
	<20130702003958.GG19945@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/P0TAexp3H7MpXEVMQ5AUB6w"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/P0TAexp3H7MpXEVMQ5AUB6w
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 1 Jul 2013 20:39:58 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Jun 13, 2013 at 12:53:42PM +1000, NeilBrown wrote:
> > There are a few races possible in the sunrpc cache which can result in
> > messages being dropped or memory not being freed.
> >=20
> > These patches have been tested extensively and appear to remove all
> > dropped-message errors and memory leaks.
>=20
> OK, thanks very much to both of you for keeping at these.  Applied to
>=20
> 	git://linux-nfs.org/~bfields/linux.git for-3.11
>=20
> Some trivial fixup to the second patch was needed due to
> b6040f9706c4c81cc50b50855ed70840f022bebb "sunrpc: the cache_detail in
> cache_is_valid is unused any more" (but you might want to double-check
> to make sure I didn't typo something).
>=20
> --b.

Thanks.  I couldn't see any typos.  And if the compiler doesn't either, that
settles it :-)

NeilBrown

--Sig_/P0TAexp3H7MpXEVMQ5AUB6w
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdIyiTnsnt1WYoG5AQLm3w//WpJIzFJ3iNx8awQtJa6b3OV1GNelExAU
da5ItvhWKMOKjyhYStyrBcZhzMp33K2k6EfIF4dAa8LqmT9ufKk7MlmWnCdVvhGi
iuqX7sQnJxn+HMeuvKiqcOuFy5C8fUvscBkZ7Vt2qpCM/SH6JyY773uCzfps2vx3
rvbu27L10B4TxEQy7QhO6JEBju/rBSVYVDHLuhJF7gX8Ey/nLx6FnEhtk1Cgmpyr
aQLvhpQ5NRTySFR0FdVrDvWURPuRQjBGpZ+V9sFtm06LpN0s5unJRDhPSrEFFn7S
1pUvcDaFJZz3qNtoF5004hxU77I167LplFoY10z5R37GNGsjBeMf7LvZyA97gdUk
FMM7c9UkCVq+CBLMXHqbiFShhg3n4lnL3Wmo3jEJTGCBf6a/sQpNYBWx1GPrZ17+
FAace1awLUwZREFKnpFuME1zi4DgZ1RAy4y2eDQFpBHOdjNczhOHyz24SuG5dYHm
pSFmoUYSkb7PpvlUpBXfVqtRVgXcwYyCDvx6znRRnuj/qs5QKeWL6CL2+7Z4yuky
vPrSqzv0GAkepwJI10nQuHFO51S6GgDB3L+rPgTYGAmluyNlqT7USohF+zCHYqep
CkXi0xxbFh5H6aW0h6c6aCEuKf4IBaNXon0rGaqU7/VqG3Azr/mP4z2t8MrqcWNA
nXB0IQ24zt8=
=ztl8
-----END PGP SIGNATURE-----

--Sig_/P0TAexp3H7MpXEVMQ5AUB6w--
