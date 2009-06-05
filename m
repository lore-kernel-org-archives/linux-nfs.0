From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Fri, 5 Jun 2009 12:24:39 -0400
Message-ID: <200906051224.40592.vapier@gentoo.org>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1773580.symBjOaW3k";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:47910 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbZFEQYj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 12:24:39 -0400
In-Reply-To: <20090605073648.5a5497b5-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1773580.symBjOaW3k
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 05 June 2009 07:36:48 Jeff Layton wrote:
> Doing this now would add wider testing exposure for these codepaths and
> help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
> new library dependency for packagers, or they'll need to take the
> conscious step to --disable-tirpc when they configure.

or have the configure script dump a warning whenever libtirpc is not used ...

> We could make it so that configure looks for libtirpc and if it's not
> available, configures the build against legacy RPC interfaces. I think
> this is a bad idea however. While it should "just work" either way,
> there are some small behavioral differences when TIRPC support is built
> in. I think it's probably better to make enabling and disabling TIRPC a
> conscious step.

i think this is the correct behavior for unspecified configure flags
-mike

--nextPart1773580.symBjOaW3k
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iQIcBAABAgAGBQJKKUbIAAoJEEFjO5/oN/WB0MwQAL0a9vuLNnKytlw+Fvabm8y3
vb6LN1TqGv8H3tYpSMN+qFNERq3cl0C9t9ZMiY8Ydy01tVmYRSubcAwl3zoUQ4TS
qXudqxmsobzQO2OXf4N5eEc41wi4t1yF/Hk7HHn3Cw4cJdbkahQQLPqO/cKBefb1
xPWpQCnizEC9VqYz4ccMvDI9dfQ7Vb2rW989Y+MV0HY+YV+24MO+2UmIROlCoYyk
RrSWTyhoriBMh8YNjUVKXF3TATZJcbctTxnIwJNecEPOCeq+/O8gG8aWX8OWy3LN
4v6AQOLUcs4s2HjqZQ+zEkMV5AO77UhRidjMTeH4cBRxWW6xH/BcDGKjYR9512y3
+dAssJ4wUB9ZULukOucc/AjtY1aMzGTDouq1v5QHjJMeNjbhAhVeaX2EQsgcB9EP
gAPEkCQbh67FlZ41J/AiS4Hm03dZWXHN9ZMnZAJ1t7u0hDPTQU2Y7PVA2umikKkK
UwnjqNynJuac6DP6IYVJWsZXGqYtKlBvn8gRdvF2QBixfIxUeHdCni+n+OrZCg4G
42hSC+5NnKlYgRX2zLFGKaje9CbEMl5ItFECRCy5dhXx+PfZULSgcM1AXoD/4DdB
vIwqu5xDxwMucGTgnWovrob3nzT/ngf6li4VcHA1yBmD8rQ6PY+npzWPGsSMN4kh
ZLJj3Ifv9u1AASkmhQti
=2v3P
-----END PGP SIGNATURE-----

--nextPart1773580.symBjOaW3k--
