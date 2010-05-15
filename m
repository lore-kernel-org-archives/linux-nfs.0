From: Pierre Ossman <pierre-list-vCPtPcF4ZGuHXe+LvDLADg@public.gmane.org>
Subject: Different options for subdir? Possible?
Date: Sat, 15 May 2010 15:31:04 +0200
Message-ID: <20100515153104.51f5e4ab@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-3653-1273930266-0001-2"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:36460 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682Ab0EONgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 15 May 2010 09:36:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-3653-1273930266-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

I'd like to export the filesystem /exports as ro, but the
subdir /exports/dump as rw. I can't seem to get it to work though, so
before I start digging deeper I figured I might ask if this is even
possible? :)

I tried this in /etc/exports:

/exports/dump	1.2.3.4(rw)
/exports	1.2.3.4(ro)

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--=_freyr.ossman.eu-3653-1273930266-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.13 (GNU/Linux)

iEYEARECAAYFAkvuohoACgkQ7b8eESbyJLg/HQCeI65ADcwfc9tkFMGpWNVuMewG
2gYAnRQhrgMw0SI0SYPGHDQPQO85gIsT
=8m4p
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-3653-1273930266-0001-2--
