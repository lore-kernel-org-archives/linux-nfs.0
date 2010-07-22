Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45825 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab0GVGrg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jul 2010 02:47:36 -0400
Message-ID: <4C47E97D.7080809@pengutronix.de>
Date: Thu, 22 Jul 2010 08:47:25 +0200
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Dave Chinner <dchinner@redhat.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC auth: add context argument to shrinker callback
References: <1279698095-17287-1-git-send-email-mkl@pengutronix.de> <20100722001355.GB31881@devil>
In-Reply-To: <20100722001355.GB31881@devil>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEE47A55F2BA7BA67A0262B71"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enigEE47A55F2BA7BA67A0262B71
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Dave Chinner wrote:
> On Wed, Jul 21, 2010 at 09:41:35AM +0200, Marc Kleine-Budde wrote:
>> Hello,
>>
>> I found this regression in the current mainline tree.
>=20
> The fix is already in Linus' current git tree (commit
> 567c7b0edec0200c5c6613f07c3d3b4034fdc836 ("mm: add context argument to
> shrinker callback to remaining shrinkers"). Thanks for catching
> it, anyway.

After pulling yesterday I noticed the warning was gone.

BTW: Do you know Coccinelle[1]? It's a semantic patch tool, this is
exactly what you need if you change function signatures, etc....

Wolfram has written a very good lwn article[2] about it.

cheers,
Marc

[1] http://coccinelle.lip6.fr/
[2] http://lwn.net/Articles/380835/
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigEE47A55F2BA7BA67A0262B71
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkxH6YIACgkQjTAFq1RaXHMHEwCfddSSQF9xWHJegta/wpD9sp5N
ancAn05hByMeymYc01mbi0XfJDx2WNja
=SPJJ
-----END PGP SIGNATURE-----

--------------enigEE47A55F2BA7BA67A0262B71--
