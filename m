Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58031 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966225AbeBNBPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 20:15:15 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 14 Feb 2018 12:15:06 +1100
Cc: "Wang\, Alan 1. \(NSB - CN\/Hangzhou\)" <alan.1.wang@nokia-sbell.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: cache: ignore timestamp written to 'flush' file.
In-Reply-To: <20180213210314.GA12201@fieldses.org>
References: <VI1PR07MB342127E2A55088F691693A3BA2F00@VI1PR07MB3421.eurprd07.prod.outlook.com> <87inb0r7cd.fsf@notabene.neil.brown.name> <20180213210314.GA12201@fieldses.org>
Message-ID: <877ergqsmd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The interface for flushing the sunrpc auth cache was poorly
designed and has caused problems a number of times.

The design is that you write a timestamp, and all entries
created before that time are discarded.
The most obvious problem is that this is not what people
actually want.  They want to just flush the whole cache.
The 1-second granularity can be a problem, as can the use
of wall-clock time.

A current problem is that code will write the current time to
this file - expecting it to clear everything - and if the
seconds number ticks over before this timestamp is checked,
the test "then >=3D now" fails, and a full flush isn't forced.

So lets just drop the subtleties and always flush the whole
cache.  The worst this could do is impose an extra cost
refilling it, but that would require someone to be using
non-standard tools.

We still report an error if the string written is not a number,
but we cause any valid number to flush the whole cache.

Reported-by: "Wang, Alan 1. (NSB - CN/Hangzhou)" <alan.1.wang@nokia-sbell.c=
om>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/cache.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8a7e1c774f9c..26582e27be6a 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1450,8 +1450,8 @@ static ssize_t write_flush(struct file *file, const c=
har __user *buf,
 			   struct cache_detail *cd)
 {
 	char tbuf[20];
=2D	char *bp, *ep;
=2D	time_t then, now;
+	char *ep;
+	time_t now;
=20
 	if (*ppos || count > sizeof(tbuf)-1)
 		return -EINVAL;
@@ -1461,24 +1461,24 @@ static ssize_t write_flush(struct file *file, const=
 char __user *buf,
 	simple_strtoul(tbuf, &ep, 0);
 	if (*ep && *ep !=3D '\n')
 		return -EINVAL;
+	/* Note that while we check that 'buf' holds a valid number,
+	 * we always ignore the value and just flush everything.
+	 * Making use of the number leads to races.
+	 */
=20
=2D	bp =3D tbuf;
=2D	then =3D get_expiry(&bp);
 	now =3D seconds_since_boot();
=2D	cd->nextcheck =3D now;
=2D	/* Can only set flush_time to 1 second beyond "now", or
=2D	 * possibly 1 second beyond flushtime.  This is because
=2D	 * flush_time never goes backwards so it mustn't get too far
=2D	 * ahead of time.
+	/* Always flush everything, so behave like cache_purge()
+	 * Do this by advancing flush_time to the current time,
+	 * or by one second if it has already reached the current time.
+	 * Newly added cache entries will always have ->last_refresh greater
+	 * that ->flush_time, so they don't get flushed prematurely.
 	 */
=2D	if (then >=3D now) {
=2D		/* Want to flush everything, so behave like cache_purge() */
=2D		if (cd->flush_time >=3D now)
=2D			now =3D cd->flush_time + 1;
=2D		then =3D now;
=2D	}
=20
=2D	cd->flush_time =3D then;
+	if (cd->flush_time >=3D now)
+		now =3D cd->flush_time + 1;
+
+	cd->flush_time =3D now;
+	cd->nextcheck =3D now;
 	cache_flush();
=20
 	*ppos +=3D count;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqDjZoACgkQOeye3VZi
gblySA/8Cs6sMmWnfeV4wLFMM2yN6BSlnp77DEtCc7raCna87fAKfYiEzxcc2hTT
5qhR8qPIzzr2U05BOP4zaoFeucMYWEUN6Dtoc1DtsA8ZG2Nha6g8GfMEInbKS+h2
SQYcEzrrRPTxVYxChkKE2YBu0Kb1NBmGAM06Ljsrwyrq7x91o0yh/Em5CAduqWBA
AiRSUs/Jsit9kZvJxtZ36wn+U1N5nZbdbV6TML8Gz3q14hNcGNWaWLbm3ERqud+T
9mZi5iaBLhaJ5pFC8NnZNoUXMuWDxgGdZvxTeifcj06mabsNQbXGwrKwoRHt/+gU
tDlyLVXufy9DxvQpgb71+ZjOMtn+xct2+DnoaUokniTAeQlNhygXgamARb9ZKPPf
buR0rAUkn10pwCHSfr7PQX8kOKdJJo1T8CQrUu2R0hSrI37os0sJgPjZ3YBjSIV2
M/Aupmr24hfckpgZS9c40H7fRGTrrO8vO8DnIFS3DCOzhAQ4ZCc3x+ktQ3/VS6GM
6GUKda4whtyze2T0N3HzDZOq2+Hwxb6B1nhMkte8N6bDJrCygnjO3U62hJbzSDys
m8cHz2AEr0RnOtOGyawPd60iq/u+LeKPxSRYYaXg6BQqVtnbC4Db/iV2rDM04LCX
cIkU95xATMhFGkMH25euh/HTdq2ZgTfoMc2Y839KtKlaET9VvNE=
=RCgV
-----END PGP SIGNATURE-----
--=-=-=--
