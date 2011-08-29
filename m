Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:55837 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754103Ab1H2W6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Aug 2011 18:58:01 -0400
Date: Tue, 30 Aug 2011 08:57:52 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Ben Hutchings <ben@decadent.org.uk>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arch@vger.kernel.org
Subject: Re: [PATCH] All Arch: remove linkage for sys_nfsservctl system call
Message-Id: <20110830085752.6db1ffa600f4c82135b3f3eb@canb.auug.org.au>
In-Reply-To: <20110826220311.GA18140@fieldses.org>
References: <1312810169.2591.1153.camel@deadeye>
	<20110808155538.GB904@fieldses.org>
	<20110808180658.GC29924@decadent.org.uk>
	<20110826220311.GA18140@fieldses.org>
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__30_Aug_2011_08_57_52_+1000_Uw9KG.Cbr6Myuj=k"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Signature=_Tue__30_Aug_2011_08_57_52_+1000_Uw9KG.Cbr6Myuj=k
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Bruce,

On Fri, 26 Aug 2011 18:03:11 -0400 "J. Bruce Fields" <bfields@fieldses.org>=
 wrote:
>
> From: NeilBrown <neilb@suse.de>
>=20
> The nfsservctl system call is now gone, so we should remove all
> linkage for it.
>=20
> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>=20
> I don't normally have to deal with this kind of cross-architecture
> patch; is this the right etiquette for it?

It turns out (with hindsight) that my reaction to this patch should have
been:

If you haven't built this on all architectures (an noone expects you to
actually do that), then it should spend a day or two in linux-next before
being sent to Linus.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__30_Aug_2011_08_57_52_+1000_Uw9KG.Cbr6Myuj=k
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOXBlwAAoJEDMEi1NhKgbssnMH/0Bb99IHgDTSfYa3/mtwN+Rg
JFZiEYu/kaqLwT9lBx2xElHwjRBb+Moi+GHdFcQYV2YtOKldJqeVptEFHLQScuHK
i2T3bYz2WjIRkfYjp58smmLk6pByLMDJBjO1E+x3MCiENvvze501nqooyrbd4eA0
Oa7dwrIKosmZBNImuZfpBIdmOELQo6n5ewqyXqKFB+g/YRAiifhj2Pq1pMuawPxa
JiEFywkrJuOSs8F6bk/p2WLydH70piIzdJsHxKisE0Pqvy1shHXS782gv/LTDWZp
UjaQ2e+CdmmHmm/6lMCoemwOfYX13O0lmXdJa2kPKuBukadH/SsBsrpFv0UghVY=
=zdQQ
-----END PGP SIGNATURE-----

--Signature=_Tue__30_Aug_2011_08_57_52_+1000_Uw9KG.Cbr6Myuj=k--
