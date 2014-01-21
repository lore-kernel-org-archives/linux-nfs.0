Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36504 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbaAUDAX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 22:00:23 -0500
Date: Tue, 21 Jan 2014 14:00:11 +1100
From: NeilBrown <neilb@suse.de>
To: chuck.level@oracle.com, varekova@redhat.com
Cc: sysstat@orange.fr, linux-nfs@vger.kernel.org
Subject: Re: Too many programs calls nfsiostat.
Message-ID: <20140121140011.3c976ca3@notabene.brown>
In-Reply-To: <20130410094639.5debfc90@notabene.brown>
References: <20130410094639.5debfc90@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/oHgChX9ssPOgcsUvyCn3ZyS"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/oHgChX9ssPOgcsUvyCn3ZyS
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Not quite a year ago I wrote:

On Wed, 10 Apr 2013 09:46:39 +1000 NeilBrown <neilb@suse.de> wrote:

>=20
> Hi all,
>  it seems that in 2010, a program called nfsiostat was added to the sysst=
at
>  package (http://sebastien.godard.pagesperso-orange.fr/)
>=20
>  This is unfortunate because in 2008 a program called nfsiostat was added=
 to
>  the nfs-utils package.
>     (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)
>=20
>  The default install locations seem to be different (/usr/bin vs /usr/sbi=
n),
>  so packagers would not immediately notice.
>=20
>  This seems like something that should be "fixed".
>=20
>  Any suggestions what a good "fix" should look like?
>=20
> NeilBrown


No suggestions were forthcoming.
So I have a suggestion.
I propose we rename the "nfsiostat" in the "sysstat" package to
"nfsio-sysstat" and the "nfsiostat" in "nfs-utils" to
"nfs-utils-iostat".

Does anyone object?  If not I'll send off patches shortly :-)

NeilBrown

--Sig_/oHgChX9ssPOgcsUvyCn3ZyS
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUt3iuznsnt1WYoG5AQIN5Q//d6gR20Xkp7/jaOVSrBC0im5aYnxYHiI/
d3cbSyWtnSypxzcHuWl7LMfi3M+Q/wUHGP1vS+k4q11Zj6AptxqkxGjiykGGo207
32k3j6L1aAOOsdRafRNCo9/qHBieh+kTcuOcsXtWryrL5rz57YAK9Offieiv78pc
rXSyaS9nOPcbbVU0h8AMC0Os0mpYUClhYcN2k3svyS9brj7ADZOjpSZyPmGb82My
Fe1RERUG8chDN0RZZokAmiL/NN5F9Dz5lHQ1EKOjEkV38wlmYqAJlxSYukxcg6XE
sJDrRCUygM8RNZWM1P36kqFhvhAl6wWxqkdVhKHCWf+rUZj7l5qJrN13ic9wflZZ
sivxU0OaZX7/yIxBGWadPiZP/j29eU60kjq8XsUPQnXNQufCXSbpS2+/gNOFkLef
Q+jVfUpQqKLzSLIXuCraE/HP3A7EKhX0wHRNv1bvhX4a+V/w2PPKMTw+aPktorPV
xifPhzq7lDep2zXmiLA6P9QUf68w26GG2C1gao5c/FpdODYf38a4Lzrmf+7ULInq
YxCyuGT0M+RuAII5PdbfbzJuSM31bPgTyvOWGXcicLLvtsrsyQngR0QER+fEgD0L
6iwpC7OHGquoy5Ag9vdmU/6Na4In3N1VTauDn5nLDflUwLJSdxI72InXAl3EHjOH
WavX60FtqiI=
=Ugga
-----END PGP SIGNATURE-----

--Sig_/oHgChX9ssPOgcsUvyCn3ZyS--
