Return-Path: linux-nfs-owner@vger.kernel.org
Received: from haggis.pcug.org.au ([203.10.76.10]:41729 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798Ab3AQWzo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 17:55:44 -0500
Date: Fri, 18 Jan 2013 09:55:38 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v2 0/8] Add O_DENY* support for VFS and CIFS/NFS
Message-Id: <20130118095538.fdd0b3be90739b9fd9179b5d@canb.auug.org.au>
In-Reply-To: <1358441537-8672-1-git-send-email-piastry@etersoft.ru>
References: <1358441537-8672-1-git-send-email-piastry@etersoft.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__18_Jan_2013_09_55_38_+1100_7TSfPL.ufZ3ugG+I"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Fri__18_Jan_2013_09_55_38_+1100_7TSfPL.ufZ3ugG+I
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Pavel,

On Thu, 17 Jan 2013 20:52:09 +0400 Pavel Shilovsky <piastry@etersoft.ru> wr=
ote:
>
> This patchset adds support of O_DENY* flags for Linux fs layer. These fla=
gs can be used by any application that needs share reservations to organize=
 a file access. VFS already has some sort of this capability - now it's don=
e through flock/LOCK_MAND mechanis, but that approach is non-atomic. This p=
atchset build new capabilities on top of the existing one but doesn't bring=
 any changes into the flock call semantic.

This has probably been discussed, but is Linux's leases implementation
not sufficient?  Just wondering.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__18_Jan_2013_09_55_38_+1100_7TSfPL.ufZ3ugG+I
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ+IFqAAoJEECxmPOUX5FE+gAQAJwLoVKNYzoQS/zD5Qk+ahFn
4wS6YX/afeFPoQhLujcl+LtgSAH6/Ck2T+OxPfrzxCqVXyhtWDz5tZ7aomQTw9fr
J9nzWDzOYQRbn5UV07XzR0p4iQcglCBrHs1b4Jqt3f+p6zUYeGjxQNrCf4DFcB+b
EnBUYkpIkGCsEUgIeknN2EJuL3XKz0a1Th7V7QwhQwRMOQYxAt3/X0fCSpjyxLDJ
e0i/cnMshvI4ECLTG8YmPaU0aigU4zWO810NvlhUQByBxqMMy/x64mloPesI8SJd
magfHroh1Shsxay+QRYnEzOoQb+cm531radEzOsUiD30VzR8ANZi80S6zBS8DAYV
7Cc6WHGuoKvG3+uYaq7j6EyCcc/M0gzZHrj2kL9lPUpTcHdB15FCjysE67qX4eut
EKNWHQHOGN01XKqZgh/7uuKeqo2sM6igLdIqzU06/cjGFYlTncxQP41IPJs1xYBc
j+1M1TaDm5CPePUGq9YUk1mK977mQTsEE9+kMUhn+nlQBcY5HdIQbgB/K74qJqIt
1rUONBpSTdb6bXz6GKbJEIGZy+JRIhUFt8wDee9Qc7QZQKWlhSe0lx0vUREdUIqI
FCfhIw1atAcq0FyU9FGx3VEYJVdYuAz139zAMbC0AuJyR0tarDmY9ZuRxeW60z3h
NLDPSpog2wpX+jdtVTuF
=UbCB
-----END PGP SIGNATURE-----

--Signature=_Fri__18_Jan_2013_09_55_38_+1100_7TSfPL.ufZ3ugG+I--
